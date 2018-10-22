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
using System.Data;
using System.IO;
using System.Linq;

using VI.Base;
using VI.DB;
using VI.DB.Entities;
using VI.DB.Sync;
using VI.Samba.Tools;

namespace VI.JobService.JobComponents
{
    public class ImportComponent : DbJobComponent
    {
	    public override void Activate(string task)
	    {
		    base.Activate(task);

		    switch (task.ToUpperInvariant())
		    {
				case "COLLECTSOFTWAREFEEDBACK":
					CheckRequiredParameters("DirName");

					var localDir = _GetLocalPath(Parameters["DirName"].Value);

					_CollectSoftwareFeedback(localDir);
					break;

				default:
					throw new ViException(2662001, task);
			}
	    }

		private void _CollectSoftwareFeedback(string directory)
		{
			/*
			 * Garbage Collection für Einträge, die älter als das
			 * eingestellte Intervall sind.
			 */
			_RemoveOutdatedAppsInfo();

			var userDBAppDrvs = new Dictionary<string, DBAppDrvInfo>(StringComparer.Ordinal);
			var machineDBAppDrvs = new Dictionary<string, DBAppDrvInfo>(StringComparer.Ordinal);

			var installationTypesById = _GetIdMapping("InstallationType", "Ident_InstType", "UID_InstallationType");
			var operatingSystemsById = _GetIdMapping("OS", "Ident_OS", "UID_OS");

			foreach (string currFileName in Directory.GetFiles(directory, "*.ia"))
			{
				SetProgressInfo(LanguageManager.Instance.FormatString("SDL_ProcessingFile", currFileName));

				try
				{
					using (Transaction t = new Transaction(ConnectData.Connection))
					{
						// Hole Zeit der letzten Modifikation
						DateTime lastModified = File.GetLastWriteTimeUtc(currFileName);

						// cleanup hashtables
						userDBAppDrvs.Clear();
						machineDBAppDrvs.Clear();

						// Befülle das ApplicationInfo-Objekt aus der Datei
						FeedBackFile currFeedBackFile = new FeedBackFile(currFileName);
						ApplicationInfo appInformation = currFeedBackFile.GetApplicationInfo();

						// Hole den passenden Namespace
						AccountNameSpace ns;

						switch (appInformation.MachineNamespace.ToUpperInvariant())
						{
							case "ADS":
								ns = new ADSNameSpace(ConnectData);
								break;

							default:
								// Default: NT, LDAP
								throw new NotSupportedException($"Namespace {appInformation.MachineNamespace} is not supported (anymore).");
						}

						// Hole den passenden User-Account zu den Informationen des ApplicationInfos.
						ISingleDbObject userAccount = ns.GetUserAccount(appInformation);

						if (userAccount == null)
						{
							Result.Messages.Add(LanguageManager.Instance["UserInformationNotSupported"]);
						}

						// Hole das Hardware-Objekt zu den Informationen des ApplicationInfos.
						ISingleDbObject machineAccount = ns.GetMachine(appInformation);

						if (machineAccount == null)
						{
							Result.Messages.Add(LanguageManager.Instance.FormatString("MachineInformationNotSupported", appInformation.MachineNamespace));
						}

						// nicht bei ClientAbbruch
						if (appInformation.ErrorLevel != "4")
						{
							#region Client erfolgreich

							if (ns.NewerInstallDataDoesExist(lastModified, userAccount, machineAccount))
							{
								/*
								 * Es gibt bereits neuere Daten in der Datenbank.
								 */
								Result.Messages.Add(LanguageManager.Format("SDL_WarnNewerData", currFileName));
							}
							else
							{
								/*
								 * Einsammeln der DB-Daten für die Nutzerapplikationen
								 */
								if (userAccount != null)
								{
									_CollectDBAppInfos(
										appInformation.UserApplications,
										installationTypesById,
										operatingSystemsById,
										ns.GetAccountUID(userAccount),
										userDBAppDrvs,
										true);
								}

								/*
								 * Einsammeln der DB-Daten für die Maschinenapplikationen
								 */
								if (machineAccount != null)
								{
									_CollectDBAppInfos(
										appInformation.MachineApplications,
										installationTypesById,
										operatingSystemsById,
										machineAccount.GetValue("UID_Hardware").String,
										machineDBAppDrvs,
										false);
								}

								/*
								 * Behandle die dem Nutzer zugeordneten Applikationen
								 */
								if (userAccount != null)
								{
									foreach (DBAppDrvInfo currUserDbAppDrvInfo in userDBAppDrvs.Values)
									{
										// Applikationen sind deselektiert, wenn ein Nutzeranteil existiert,
										// aber kein Maschinenanteil.
										if (!machineDBAppDrvs.ContainsKey(currUserDbAppDrvInfo.UidAppDrv))
											currUserDbAppDrvInfo.IsDeselected = true;
									}

									// Führe die Über- bzw. Untermengenbehandlung in der DB
									// durch. Dabei werden AppsInfo-Einträge angelegt bzw. als
									// deinstalliert markiert.
									ns.SetUserInstallStateInDB(
										ns.GetAccountUID(userAccount),
										userDBAppDrvs,
										lastModified);
								}

								/*
								 * Behandle die der Maschine zugeordneten Applikationen
								 * und Treiber.
								 */
								if (machineAccount != null)
								{
									_SetMachineInstallStateInDB(
										machineAccount.GetValue("UID_Hardware").String,
										machineDBAppDrvs,
										lastModified);
								}
							}

							#endregion
						}


						if (_MaxAgeClientLog == 0)
						{
							// remove all associated client log entries
							ns.RemoveClientLogEntries(machineAccount, userAccount);
						}
						else if (appInformation.InstallLog != null)
						{
							// create new client log entry
							ns.CreateClientLogEntry(machineAccount, userAccount, lastModified,
													appInformation);
						}

						t.Commit();
					}

					if (File.Exists(currFileName))
					{
						File.Delete(currFileName);
					}
				}
				finally
				{
					// rename response file, if still exists (to handle those files
					// that caused error messages / exceptions)
					if ( File.Exists(currFileName) )
						File.Move(currFileName, string.Format("{0}_{1:yyyyMMddHHmmss}", currFileName, DateTime.Now));
				}
			} // foreach file
		}

	    private IDictionary<string, string> _GetIdMapping(string table, string idColumn, string uidColumn)
	    {
		    var query = Query
			    .From(table)
			    .Select(uidColumn, idColumn);

		    return ConnectData.Connection.Session.Source()
			    .GetCollection(query, EntityCollectionLoadType.Slim)
			    .ToDictionarySafe(
				    e => e.GetValue<string>(idColumn),
				    e => e.GetValue<string>(uidColumn),
				    StringComparer.OrdinalIgnoreCase);
	    }

		/// <summary>
		/// Sammle die Informationen aus Sectionname und Driver zu unseren Feedback-Einträgen ein.
		/// </summary>
		/// <param name="appInfos">Liste von Feedback-Einträgen</param>
		/// <param name="installationTypesById">Mapping from ID to UID</param>
		/// <param name="operatingSystemsById">Mapping from ID to UID</param>
		/// <param name="uid">UID des zugehörigen Namespace-Objektes.</param>
		/// <param name="destination">Dictionary, das Einträge aufnehmen soll.</param>
		/// <param name="ignoreDrivers">Sollen Einträge für Treiber ignoriert werden?</param>
		private void _CollectDBAppInfos(
			IList<AppsDrvProfileInfo> appInfos,
			IDictionary<string, string> installationTypesById,
			IDictionary<string, string> operatingSystemsById,
			string uid,
			IDictionary<string, DBAppDrvInfo> destination,
			bool ignoreDrivers)
		{
			var f = ConnectData.Connection.SqlFormatter;
			var exec = ConnectData.Connection.CreateSqlExecutor(ConnectData.PublicKey);
			var sectionNames = new Dictionary<string, bool>(StringComparer.OrdinalIgnoreCase);

			/*
			 * Hole die Liste der Sectionnames.
			 */
			if (appInfos.Count > 0)
			{
				var sql = "select ident_sectionname, appsnotdriver from sectionname where " +
							 f.InClause("ident_sectionname", ValType.String, appInfos.Select(a => a.SectionName));

				using (var rd = exec.SqlExecute(sql))
				{
					while ( rd.Read() )
						sectionNames[rd.GetString(0)] = rd.GetBoolean(1);
				}
			}

			/*
			 * Teile die Info-Objekte in Applikationen und
			 * Treiber auf.
			 */
			var appsBySectionName = new Dictionary<string, AppsDrvProfileInfo>(sectionNames.Count, StringComparer.OrdinalIgnoreCase);
			var driversBySectionName = new Dictionary<string, AppsDrvProfileInfo>(sectionNames.Count, StringComparer.OrdinalIgnoreCase);

			foreach (AppsDrvProfileInfo info in appInfos)
			{
				if (!sectionNames.ContainsKey(info.SectionName))
				{
					// Der SectionName existiert nicht
					Result.Messages.Add(string.Format(LanguageManager.Instance.GetString("SDL_WarnSectionNameNotFound"),
													  info.SectionName));
				}
				else
				{
					if (sectionNames[info.SectionName])
						appsBySectionName[info.SectionName] = info;
					else
						driversBySectionName[info.SectionName] = info;
				}
			}

			/*
			 * Erzeuge die zugehörige DBAppDrvInfo-Objekte,
			 * das die Daten aus Application und den
			 * Accout-Schlüssel enthält.
			 */
			if ( appsBySectionName.Count > 0)
			{
				string sql = "select ident_sectionname, uid_application, namefull from application where " +
							 f.InClause("ident_sectionname", ValType.String, appsBySectionName.Values.Select(i => i.SectionName));

				using (IDataReader rd = exec.SqlExecute(sql))
				{
					while (rd.Read())
					{
						AppsDrvProfileInfo info;

						var sectionName = rd.GetString(0);

						if (appsBySectionName.TryGetValue(sectionName, out info))
						{
							// Entferne den Eintrag, um auf fehlende Einträge zu testen.
							appsBySectionName.Remove(sectionName);

							string uidInstallationType;
							string uidOperatingSystem;

							if ( !installationTypesById.TryGetValue(info.InstallType, out uidInstallationType) )
							{
								Result.Messages.Add(LanguageManager.Format("SDL_WarnInstallationTypeNotFound", info.InstallType));
								continue;
							}

							if (!operatingSystemsById.TryGetValue(info.OS, out uidOperatingSystem))
							{
								Result.Messages.Add(LanguageManager.Format("SDL_WarnOSNotFound", info.OS));
								continue;
							}

							var dbinfo = new DBAppDrvInfo(
								info,
								rd.GetString(1),
								uid,
								rd.GetString(2),
								uidInstallationType,
								uidOperatingSystem,
								true);

							destination.Add(dbinfo.UidAppDrv, dbinfo);
						}
					}
				}
			}

			foreach (AppsDrvProfileInfo info in appsBySectionName.Values)
			{
				// Für die übrigen gibt es keinen Apps-Eintrag
				Result.Messages.Add(
					LanguageManager.Instance.FormatString(
						"SDL_WarnNoAppsEntry",
						info.SectionName,
						"Application"));
			}

			/*
			 * Erzeuge die zugehörige DBAppDrvInfo-Objekte,
			 * die die Daten aus Driver und den
			 * Accout-Schlüssel enthalten.
			 */

			if (!ignoreDrivers)
			{
				if (driversBySectionName.Count > 0)
				{
					string sql = "select ident_sectionname, uid_driver, namefull from driver where " +
								 f.InClause("ident_sectionname", ValType.String, driversBySectionName.Values.Select(i => i.SectionName));

					using (IDataReader rd = exec.SqlExecute(sql))
					{
						while (rd.Read())
						{
							AppsDrvProfileInfo info;

							var sectionName = rd.GetString(0);

							if (driversBySectionName.TryGetValue(sectionName, out info))
							{
								// Entferne den Eintrag, um auf fehlende Einträge zu testen.
								driversBySectionName.Remove(sectionName);

								string uidInstallationType;
								string uidOperatingSystem;

								if (!installationTypesById.TryGetValue(info.InstallType, out uidInstallationType))
								{
									Result.Messages.Add(LanguageManager.Format("SDL_WarnInstallationTypeNotFound", info.InstallType));
									continue;
								}

								if (!operatingSystemsById.TryGetValue(info.OS, out uidOperatingSystem))
								{
									Result.Messages.Add(LanguageManager.Format("SDL_WarnOSNotFound", info.OS));
									continue;
								}

								var dbinfo = new DBAppDrvInfo(
									info,
									rd.GetString(1),
									uid,
									rd.GetString(2),
									uidInstallationType,
									uidOperatingSystem,
									false);

								destination.Add(dbinfo.UidAppDrv, dbinfo);
							}
						}
					}
				}

				foreach (AppsDrvProfileInfo info in driversBySectionName.Values)
				{
					// Für die übrigen gibt es keinen Apps-Eintrag
					Result.Messages.Add(
						LanguageManager.Instance.FormatString(
							"SDL_WarnNoAppsEntry",
							info.SectionName,
							"Driver"));
				}
			}
		}

		/// <summary>
		/// Führt die Mengenbehandlung zwischen Feedback-File und DB durch.
		/// Einträge werden dabei neu angelegt bzw. als deinstalliert markiert.
		/// </summary>
		public void _SetMachineInstallStateInDB(string uid, IDictionary<string, DBAppDrvInfo> appInfos, DateTime lastModified)
		{
			IColDbObject colMachineAppsInfo = ConnectData.Connection.CreateCol("MachineAppsInfo");
			ISingleDbObject proto = colMachineAppsInfo.Prototype;

			proto.Columns["UID_Hardware"].IsDisplayItem = true;
			proto.Columns["UID_Application"].IsDisplayItem = true;
			proto.Columns["UID_Driver"].IsDisplayItem = true;
			proto.Columns["AppsNotDriver"].IsDisplayItem = true;
			proto.Columns["Revision"].IsDisplayItem = true;

			proto.PutValue("UID_Hardware", uid);
			proto.PutValue("CurrentlyActive", true);
			proto.OrderBy = "InstallDate desc";

			colMachineAppsInfo.Load();

			/*
			 * Überprüfe den Status aller als installiert
			 * gesetzten AppInfo-Einträge in der DB.
			 * Setze deren Status gegebenenfalls auf
			 * deinstalliert, wenn sie im Feedback-File
			 * nicht vorkommen.
			 */
			foreach (IColElem elem in colMachineAppsInfo)
			{
				var uidAppDrv = elem.GetValue<bool>("AppsNotDriver")
					? elem.GetValue<string>("UID_Application")
					: elem.GetValue<string>("UID_Driver");

				// AppsInfo vorhanden und Revision gleich
				DBAppDrvInfo appInfo;
				if ( appInfos.TryGetValue(uidAppDrv, out appInfo) &&
					 string.Equals(appInfo.AssociatedAppsDrvProfileInfo.Revision, elem.GetValue("Revision").String))
				{
					// Applikation oder Treiber sind bereits installiert -> merken
					appInfo.IsInstalledInDB = true;
				}
				else
				{
					// Diese Applikation oder dieser Treiber ist nicht
					// mehr installiert -> setze den Status in der DB
					ISingleDbObject machineAppsInfo = elem.Create();

					machineAppsInfo.PutValue("CurrentlyActive", false);
					machineAppsInfo.PutValue("DeInstallDate", lastModified);

					machineAppsInfo.Save();
				}
			}

			/*
			 * Lege alle Einträge an, die nicht bereits in der Datenbank
			 * als installiert vorhanden sind.
			 */
			foreach (DBAppDrvInfo info in appInfos.Values)
			{
				if (!info.IsInstalledInDB)
				{
					ISingleDbObject machineAppsInfo = ConnectData.Connection.CreateSingle("MachineAppsInfo");

					machineAppsInfo.PutValue("CurrentlyActive", true);
					machineAppsInfo.PutValue("InstallDate", lastModified);
					machineAppsInfo.PutValue("UID_InstallationType", info.UidInstallationType);
					machineAppsInfo.PutValue("UID_OS", info.UidOperatingSystem);
					machineAppsInfo.PutValue("Revision", Convert.ToInt32(info.AssociatedAppsDrvProfileInfo.Revision));
					machineAppsInfo.PutValue("UID_Hardware", uid);

					if (info.IsApplication)
					{
						machineAppsInfo.PutValue("UID_Application", info.UidAppDrv);
						//machineAppsInfo.PutValue("DisplayName", info.AppDrvNameFull);
						machineAppsInfo.PutValue("AppsNotDriver", true);
					}
					else
					{
						machineAppsInfo.PutValue("UID_Driver", info.UidAppDrv);
						//machineAppsInfo.PutValue("DisplayName", info.AppDrvNameFull);
						machineAppsInfo.PutValue("AppsNotDriver", false);
					}

					machineAppsInfo.Save();
				}
			}
		}


		private void _RemoveOutdatedAppsInfo()
		{
			// remove outdated entries in MachineAppsInfo
			ISqlFormatter sqlFormatter = ConnectData.Connection.SqlFormatter;
			DateTime outDate;
			int age;

			age = _MaxAgeMachine;

			if (age < int.MaxValue)
			{
				outDate = DateTime.UtcNow.Subtract(new TimeSpan(age, 0, 0, 0));

				if (outDate > DbVal.MinDate)
				{
					_RemoveTableEntries(
						"MachineAppsInfo",
						sqlFormatter.AndRelation(
							sqlFormatter.Comparison("CurrentlyActive", false, ValType.Bool),
							sqlFormatter.Comparison("DeInstallDate", outDate,
													ValType.Date, CompareOperator.LowerThan)));

				}
			}

			age = _MaxAgeUser;

			if (age < int.MaxValue)
			{
				outDate = DateTime.UtcNow.Subtract(new TimeSpan(age, 0, 0, 0));

				if (outDate > DbVal.MinDate)
				{
					// remove outdated entries in ADSAccountAppsInfo
					_RemoveTableEntries(
						"ADSAccountAppsInfo",
						sqlFormatter.AndRelation(
							sqlFormatter.Comparison("CurrentlyActive", false, ValType.Bool),
							sqlFormatter.Comparison("DeInstallDate", outDate,
													ValType.Date, CompareOperator.LowerThan)));

				}
			}

			age = _MaxAgeClientLog;

			if (age < int.MaxValue)
			{
				outDate = DateTime.UtcNow.Subtract(new TimeSpan(age, 0, 0, 0));

				if (outDate > DbVal.MinDate)
				{
					// remove outdated entries in ClientLog
					_RemoveTableEntries(
						"ClientLog",
						sqlFormatter.Comparison("InstallDate",
												outDate, ValType.Date,
												CompareOperator.LowerThan));
				}
			}
		}

		private void _RemoveTableEntries(string tablename, string whereclause)
		{
			// Deaktivierte Tabellen nicht verarbeiten
			var tabDef = ConnectData.Connection.Tables[tablename];

			if (tabDef.IsDeactivated)
				return;

			IColDbObject col = ConnectData.Connection.CreateCol(tablename);
			ISingleDbObject obj;
			int pos;
			string tablecaption;

			col.Prototype.WhereClause = whereclause;
			col.Load();

			pos = 0;

			try
			{
				tablecaption = col.Prototype.TableDef.DialogObjects.Default.CaptionList;
			}
			catch
			{
				tablecaption = tablename;
			}

			foreach (IColElem elem in col)
			{
				if (++pos % 100 == 0)
					SetProgressInfo(LanguageManager.Instance.FormatString("SDL_RemovingEntry", pos, col.Count, tablecaption));

				obj = elem.Create();

				obj.Delete();
				obj.Save();
			}
		}

		private int _MaxAgeMachine
		{
			get
			{
				var cfg = ConnectData.Connection.GetConfigParm(@"Software\Inventory\MaxAge\Machine");
				return !string.IsNullOrEmpty(cfg) ? Convert.ToInt32(cfg) : int.MaxValue;
			}
		}

		private int _MaxAgeClientLog
		{
			get
			{
				var cfg = ConnectData.Connection.GetConfigParm(@"Software\Inventory\MaxAge\ClientLog");
				return !string.IsNullOrEmpty(cfg) ? Convert.ToInt32(cfg) : 0;
			}
		}

		private int _MaxAgeUser
		{
			get
			{
				var cfg = ConnectData.Connection.GetConfigParm(@"Software\Inventory\MaxAge\User");
				return !string.IsNullOrEmpty(cfg) ? Convert.ToInt32(cfg) : int.MaxValue;
			}
		}

		private static string _GetLocalPath(string uncPath)
		{
			if ( !AppData.Instance.RuntimeEnvironment.IsMono )
				return PathHelper.ConvertSeparators(uncPath);

			var sambaUncPath = new SambaUncPath(uncPath);

			if ( !sambaUncPath.IsLocal )
				throw new ViException(2662002, ExceptionRelevance.EndUser, uncPath);

			return sambaUncPath.LocalPath;
		}
	}
}
