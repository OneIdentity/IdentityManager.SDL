#region One Identity - Open Source License
//
// One Identity - Open Source License
//
// Copyright 2018 One Identity LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software. Any and all copies of the above
// copyright and this permission notice contained in the Software shall not be
// removed, obscured, or modified.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
#endregion


using System;
using System.Collections.Generic;

using VI.Base;
using VI.DB;

using static System.String;


namespace VI.JobService.JobComponents
{
	/// <summary>
	/// Abstrakte Basisklasse für Namespace-Implementierungen.
	/// </summary>
	public abstract class AccountNameSpace
	{
		protected AccountNameSpace(ConnectData connData)
		{
			if (connData == null)
				throw new ArgumentNullException("connData");

			ConnectData = connData;
			Formatter = connData.Connection.SqlFormatter;
		}

		/// <summary>
		/// Name eines Accounts in diesem Namespace.
		/// </summary>
		public abstract string AccountName { get; }

		/// <summary>
		/// Hole den Schlüssel des Accounts aus dem Objekt.
		/// </summary>
		/// <param name="obj"></param>
		/// <returns></returns>
		public abstract string GetAccountUID(ISingleDbObject obj);

		/// <summary>
		/// Hole das zugehörige Account-Objekt zu einem ApplicationInfo.
		/// </summary>
		/// <param name="app"></param>
		/// <returns></returns>
		public virtual ISingleDbObject GetUserAccount(ApplicationInfo app)
		{
			// SystemAccounts werden nicht verarbeitet
			if ( String.Equals(app.UserAccount, "SYSTEM", StringComparison.OrdinalIgnoreCase) )
				return null;

			IColDbObject colUserAccount = CreateColUserAccount(app);

			if (colUserAccount.Count < 1)
			{
				throw new ViException(2662004,
									  AccountName,
									  Format("{0}\\{1}", app.UserDomainContext, app.UserAccount));
			}

			if (colUserAccount.Count > 1)
			{
				throw new ViException(2662003,
									  AccountName,
									  Format("{0}\\{1}", app.UserDomainContext, app.UserAccount));
			}

			return colUserAccount[0].Create();
		}

		/// <summary>
		/// Hole das zugehörige Hardware-Objekt zu einem ApplicationInfo.
		/// </summary>
		/// <param name="app"></param>
		/// <returns></returns>
		public virtual ISingleDbObject GetMachine(ApplicationInfo app)
		{
			// SystemAccounts werden nicht verarbeitet
			if ( string.Equals(app.MachineAccount, "SYSTEM", StringComparison.OrdinalIgnoreCase) )
				return null;

			var colMachineAccount = CreateColHardware(app);

			if (colMachineAccount.Count < 1)
			{
				throw new ViException(2662004, "Hardware",
									  Format("{0}\\{1}", app.MachineDomainContext, app.MachineAccount));
			}

			if (colMachineAccount.Count > 1)
			{
				throw new ViException(2662003, "Hardware",
									  Format("{0}\\{1}", app.MachineDomainContext, app.MachineAccount));
			}

			return colMachineAccount[0].Create();
		}

		/// <summary>
		/// Gibt es in der Datenbank bereits neuere Einträge für Installationen?
		/// </summary>
		/// <param name="lastModified">Letzte Modifikation des Feedback-Files.</param>
		/// <param name="account"></param>
		/// <param name="machine"></param>
		public bool NewerInstallDataDoesExist(DateTime lastModified, ISingleDbObject account, ISingleDbObject machine)
		{
			var exec = Conn.CreateSqlExecutor(ConnectData.PublicKey);
			var sql = GetCountOfNewerStatement(lastModified, account, machine);

			int cnt = (int)DbVal.ConvertTo(exec.SqlExecuteScalar(sql), ValType.Int);

			return cnt > 0;
		}

		/// <summary>
		/// Führt die Mengenbehandlung zwischen Feedback-File und DB durch.
		/// Einträge werden dabei neu angelegt bzw. als deinstalliert markiert.
		/// </summary>
		public void SetUserInstallStateInDB(string uid, IDictionary<string, DBAppDrvInfo> appInfos, DateTime lastModified)
		{
			IColDbObject colAppsInfo = Conn.CreateCol(AppsInfoTable);
			ISingleDbObject proto = colAppsInfo.Prototype;

			proto["UID_Application"].IsDisplayItem = true;
			proto["Revision"].IsDisplayItem = true;
			proto.PutValue(AppsInfoKeyColumn, uid);
			proto.PutValue("CurrentlyActive", true);
			proto.OrderBy = "InstallDate desc";

			colAppsInfo.Load();

			/*
			 * Überprüfe den Status aller als installiert
			 * gesetzten AppInfo-Einträge in der DB.
			 * Setze deren Status gegebenenfalls auf
			 * deinstalliert, wenn sie im Feedback-File
			 * nicht vorkommen oder als deselektiert markiert
			 * sind.
			 */
			foreach (IColElem elem in colAppsInfo)
			{
				var deinstalled = false;

				// AppsInfo voahnden und Revision gleich
				DBAppDrvInfo appInfo;

				if ( appInfos.TryGetValue(elem.GetValue<string>("UID_Application"), out appInfo) &&
					 string.Equals(appInfo.AssociatedAppsDrvProfileInfo.Revision, elem.GetValue("Revision").String, StringComparison.Ordinal))
				{
					if (appInfo.IsDeselected)
					{
						// Applikation is abgewählt -> markiere als deinstalliert
						deinstalled = true;
					}
					else
					{
						// Merke: Diese Applikation ist bereits als installiert vermerkt
						appInfo.IsInstalledInDB = true;
					}
				}
				else
				{
					// Applikation war im Feedback-File nicht vorhanden
					// -> markiere als deinstalled
					deinstalled = true;
				}

				if (deinstalled)
				{
					// Wir markieren dieses AppInfo als deinstalliert
					ISingleDbObject currAppsInfo = elem.Create();

					currAppsInfo.PutValue("DeInstallByUser", true);
					currAppsInfo.PutValue("CurrentlyActive", false);
					currAppsInfo.PutValue("DeInstallDate", lastModified);

					currAppsInfo.Save();
				}
			}

			/*
			 * Lege alle Einträge an, die nicht bereits in der Datenbank
			 * als installiert vorhanden sind.
			 */
			foreach (DBAppDrvInfo info in appInfos.Values)
			{
				if (!info.IsInstalledInDB && !info.IsDeselected)
				{
					CreateApplicationEntryInDB(info, lastModified);
				}
			}
		}

		/// <summary>
		/// Entferne alle ClientLog-Einträge für diese Nutzer-Maschine-Kombination
		/// </summary>
		/// <param name="machine"></param>
		/// <param name="account"></param>
		public void RemoveClientLogEntries(ISingleDbObject machine, ISingleDbObject account)
		{
			IColDbObject colClientLog = Conn.CreateCol("ClientLog");

			if (machine != null)
				colClientLog.Prototype.PutValue("UID_Hardware", machine.GetValue("UID_Hardware"));

			if (account != null)
				colClientLog.Prototype.PutValue(ClientLogKeyColumn, GetAccountUID(account));

			colClientLog.Load();

			foreach (IColElem elem in colClientLog)
			{
				ISingleDbObject clientLog = elem.Create();
				clientLog.Delete();
				clientLog.Save();
			}
		}

		/// <summary>
		/// Erzeuge einen ClientLog-Eintrag.
		/// </summary>
		/// <param name="machine"></param>
		/// <param name="account"></param>
		/// <param name="lastModified"></param>
		/// <param name="appInfo"></param>
		public void CreateClientLogEntry(ISingleDbObject machine, ISingleDbObject account,
										 DateTime lastModified, ApplicationInfo appInfo)
		{
			ISingleDbObject clientLog = Conn.CreateSingle("ClientLog");

			if (account != null) clientLog.PutValue(ClientLogKeyColumn, GetAccountUID(account));

			if (machine != null) clientLog.PutValue("UID_Hardware", machine.GetValue("UID_Hardware"));

			clientLog.PutValue("InstallDate", lastModified);
			clientLog.PutValue("LogContent", appInfo.InstallLog);

			clientLog.Save();
		}

		/// <summary>
		/// Hole eine Collection der zu diesem AppInfo-Objekt gehörenden Accounts.
		/// </summary>
		/// <param name="app"></param>
		/// <returns></returns>
		protected abstract IColDbObject CreateColUserAccount(ApplicationInfo app);

		/// <summary>
		/// Hole eine Collection der zu diesem AppInfo-Objekt gehörenden Hardware.
		/// </summary>
		/// <param name="app"></param>
		/// <returns></returns>
		protected abstract IColDbObject CreateColHardware(ApplicationInfo app);

		/// <summary>
		/// Baue ein Statement, um die Anzahl neuerer Einträge zu bestimmen.
		/// </summary>
		/// <param name="date"></param>
		/// <param name="account"></param>
		/// <param name="machine"></param>
		/// <returns></returns>
		protected abstract string GetCountOfNewerStatement(DateTime date, ISingleDbObject account, ISingleDbObject machine);

		/// <summary>
		/// Tabelle, die die AppsInfo-Einträge enthält.
		/// </summary>
		protected abstract string AppsInfoTable { get; }

		/// <summary>
		/// Schlüsselspalte in der AppsInfo-Tabelle.
		/// </summary>
		protected abstract string AppsInfoKeyColumn { get; }

		/// <summary>
		/// Key des Accounts im ClientLog.
		/// </summary>
		protected abstract string ClientLogKeyColumn { get; }

		/// <summary>
		/// Erzeuge den AppsInfo-Eintrag für die angegebene Applikation.
		/// </summary>
		/// <param name="info"></param>
		/// <param name="lastModified"></param>
		protected abstract void CreateApplicationEntryInDB(DBAppDrvInfo info, DateTime lastModified);

		protected ConnectData ConnectData { get; }
		protected ISqlFormatter Formatter { get; }

		protected IConnection Conn => ConnectData.Connection;

	}
}
