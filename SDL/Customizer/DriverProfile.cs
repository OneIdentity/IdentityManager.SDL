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
using System.Collections;
using System.ComponentModel;
using VI.Base;
using VI.DB;
using System.Threading;
using System.Threading.Tasks;

using VI.DB.Entities;



using QER.Customizer;
using VI.DB.Compatibility;
using VI.DB.JobGeneration;
using VI.DB.Sync;

namespace SDL.Customizer
{
	/// <summary>
	/// Customizer for table <c>DriverProfile</c>.
	/// </summary>
	/// <remarks>
	/// The following events can be triggered by the object:
	///	<list type="table">
	///		<listheader>
	///			<term>Event</term><description>Description</description>
	///		</listheader>
	///		<item><term>INSERT</term><description>The new object is inserted into the database.</description></item>
	///		<item><term>UPDATE</term><description>The object was changed in the database.</description></item>
	///		<item><term>DELETE</term><description>The object was deleted from the database.</description></item>
	/// </list>
	/// </remarks>
	public class DriverProfile : VI.DB.Customizer
	{
		#region additional member variables

		private DateTime m_InitDate;

		#endregion

		#region protected override methods

		/// <summary>
		/// Initialize the customizer instance and assign the functionality to the given object.
		/// </summary>
		/// <param name="theObj">ISingleDbObject to be initialized with this customizer.</param>
		protected override void Initialize(ISingleDbObject theObj)
		{
			// call baseobject
			base.Initialize(theObj);

			// property - events
			theObj["ChgNumber"].ValueChecking += ChgNumber_ValueChecking;
			theObj["ChgTest"].ValueChecking += ChgTest_ValueChecking;
			theObj["ClientStepCounter"].ValueChecking += ClientStepCounter_ValueChecking;
			theObj["Ident_DomainRD"].ValueChecking += Ident_DomainRD_ValueChecking;
			theObj["Ident_DomainRD"].ValueSet += Ident_DomainRD_ValueSet;
			theObj["MemoryUsage"].ValueChecking += MemoryUsage_ValueChecking;
			theObj["OrderNumber"].ValueChecking += OrderNumber_ValueChecking;
			theObj["OSMode"].ValueChecking += OSMode_ValueChecking;
			theObj["SubPath"].ValueChecking += SubPath_ValueChecking;
			theObj["UID_Driver"].ValueChecking += UID_Driver_ValueChecking;

			theObj["ProfileType"].ValueSet += ProfileType_ValueSet;

			m_InitDate = DbObject.Connection.GetServerTime();

			_Handle_InitColumns();
		}

		/// <summary>
		/// Ends the customizer. All side effects of the object will be removed.
		/// </summary>
		protected override void Terminate()
		{
			base.Terminate();

			// remove property events
			DbObject["ChgNumber"].ValueChecking -= ChgNumber_ValueChecking;
			DbObject["ChgTest"].ValueChecking -= ChgTest_ValueChecking;
			DbObject["ClientStepCounter"].ValueChecking -= ClientStepCounter_ValueChecking;
			DbObject["Ident_DomainRD"].ValueChecking -= Ident_DomainRD_ValueChecking;
			DbObject["Ident_DomainRD"].ValueSet -= Ident_DomainRD_ValueSet;
			DbObject["MemoryUsage"].ValueChecking -= MemoryUsage_ValueChecking;
			DbObject["OrderNumber"].ValueChecking -= OrderNumber_ValueChecking;
			DbObject["OSMode"].ValueChecking -= OSMode_ValueChecking;
			DbObject["SubPath"].ValueChecking -= SubPath_ValueChecking;
			DbObject["UID_Driver"].ValueChecking -= UID_Driver_ValueChecking;

			DbObject["ProfileType"].ValueSet -= ProfileType_ValueSet;
		}

		/// <summary>
		/// Initialize column order for correct automatic filling
		/// </summary>
		/// <param name="store">ColumnRelationStore to initialize</param>
		protected override void InitializeColumnRelations(IColumnRelationStore store)
		{
			base.InitializeColumnRelations(store);

			store.AddRelation("ProfileType", "PackagePath");
		}


		/// <summary>
		/// Do customization after the object was loaded.
		/// </summary>
		/// <remarks>
		/// The <c>PackagePath</c> customization will be processed depending of the <c>ProfileType</c>
		/// </remarks>
		protected override void OnLoaded()
		{
			_Handle_ProfileType(false);

			base.OnLoaded();
		}

		/// <summary>
		/// Process the customizations after the object changes were discarded.
		/// </summary>
		protected override void OnDiscarded()
		{
			if (DbObject.IsLoaded)
			{
				_Handle_ProfileType(true);
			}
			else
			{
				_Handle_InitColumns();
			}

			base.OnDiscarded();
		}


		/// <summary>
		/// Will be executed before the object is saved to the database.
		/// </summary>
		protected override void OnSaving()
		{
			if (!DbObject.IsLoaded &&
				DbVal.IsEmpty(DbObject.GetValue("OrderNumber").Int, ValType.Int))
			{
				_SetRightOrderNumber();
			}

			ModProfile.CheckAndSetOSMode(DbObject, "OSMode", DbObject["OSMode"].New.String);

			if (!DbObject.IsLoaded)
			{
				ModProfile.IsUniqueAKProfile(DbObject);
			}

			_Handle_ProfileType(true);

			if (!DbObject.IsDeleted)
			{
				_HandleTroubleProduct();
			}

			base.OnSaving();
		}

		/// <summary>
		/// The method will be processed after the object was saved.
		/// </summary>
		protected override void OnSaved()
		{
			_CheckIsProfileDriver();

			base.OnSaved();
		}


		#endregion protected override methods

		#region Property-Events

		/// <summary>
		/// Ist der Wert von Ident_DomainOwner noch leer, so wird er mit dem neuen Wert besetzt
		/// </summary>
		private void Ident_DomainRD_ValueSet(object sender, ColumnEventArgs e)
		{
			using (NoRightsCheck())
			{
				if ((DbObject["Ident_DomainRD"].New.String.Length > 0) && (DbObject["Ident_DomainRDOwner"].New.String.Length == 0))
				{
					DbObject["Ident_DomainRDOwner"].NewValue = DbObject["Ident_DomainRD"].New.String;
				}
			}
		}

		/// <summary>
		/// Wenn sich ChgNumber ändert, wird UpdateProfileVII auf TRUE gesetzt
		/// </summary>
		/// <param name="sender">Eventsender</param>
		/// <param name="e">geänderter Spaltenwert</param>
		private void ChgNumber_ValueChecking(object sender, ColumnEventArgs e)
		{
			SetSafeIfChanged(e, "UpdateProfileVII", true);
		}

		/// <summary>
		/// Wenn sich ChgTest ändert, wird UpdateProfileVII auf TRUE gesetzt
		/// </summary>
		/// <param name="sender">Eventsender</param>
		/// <param name="e">geänderter Spaltenwert</param>
		private void ChgTest_ValueChecking(object sender, ColumnEventArgs e)
		{
			SetSafeIfChanged(e, "UpdateProfileVII", true);
		}

		/// <summary>
		/// Wenn sich ClientStepCounter ändert, wird UpdateProfileVII auf TRUE gesetzt
		/// </summary>
		/// <param name="sender">Eventsender</param>
		/// <param name="e">geänderter Spaltenwert</param>
		private void ClientStepCounter_ValueChecking(object sender, ColumnEventArgs e)
		{
			SetSafeIfChanged(e, "UpdateProfileVII", true);
		}

		/// <summary>
		/// wenn in dem DbObject des Properties DomainRD schon ein Wert stand, wird die Zuweisung abgelehnt
		/// </summary>
		/// <param name="sender">Eventsender</param>
		/// <param name="e">Parameter</param>
		private void Ident_DomainRD_ValueChecking(object sender, ColumnEventArgs e)
		{
			using (NoRightsCheck())
			{
				e.Cancel = (DbObject["Ident_DomainRD"].Old.String.Length > 0);
			}
		}

		/// <summary>
		/// Wenn sich der Wert ändert, wird UpdatePathVII auf True gesetzt
		/// </summary>
		private void MemoryUsage_ValueChecking(object sender, ColumnEventArgs e)
		{
			SetSafeIfChanged(e, "UpdateProfileVII", true);
		}

		/// <summary>
		/// Der Wert muss größer gleich 0 und kleiner als 10000 sein, hat sich der Wert geändert, wird UpdateProfileVII auf
		/// true gesetzt
		/// </summary>
		private void OrderNumber_ValueChecking(object sender, ColumnEventArgs e)
		{
			if ((e.New.Double <= 0) || (e.New.Double > 9999))
			{
				throw new ViException(881149, ExceptionRelevance.EndUser);
			}

			SetSafeIfChanged(e, "UpdateProfileVII", true);
		}

		/// <summary>
		/// Wenn sich der Wert ändert, wird UpdatePathVII auf True gesetzt
		/// </summary>
		private void OSMode_ValueChecking(object sender, ColumnEventArgs e)
		{
			if (StringComparer.OrdinalIgnoreCase.Compare(e.Old.String, e.New.String) != 0)
			{
				using (NoRightsCheck())
				{
					SetValue("UpdateProfileVII", true);
				}
			}
		}

		/// <summary>
		/// Entfent führende und nachstehende Leerzeichen im Wert sowie nachstehende \
		/// </summary>
		private void SubPath_ValueChecking(object sender, ColumnEventArgs e)
		{
			if (!string.Equals(e.New.String, e.Old.String, StringComparison.OrdinalIgnoreCase))
			{
				using (NoRightsCheck())
				{
					string str = e.New.String.Trim();

					while (str.Substring(str.Length - 1, 1) == @"\")
					{
						str = str.Remove(str.Length - 1, 1);
					}

					if (!string.Equals(e.New.String, str, StringComparison.OrdinalIgnoreCase))
					{
						e.NewValue = str;
					}

					if (!string.Equals(DbObject["SubPath"].Old.String, str, StringComparison.OrdinalIgnoreCase))
					{
						SetValue("UpdatePathVII", true);
					}
				}
			}
		}

		/// <summary>
		/// Test, ob es sich bei dem ausgewählten Driver um einen ProfileDriver handelt
		/// Setzt bei erfolgreichem Test die Flags UpdatePathVII und UpdateProfileVII auf true
		/// </summary>
		private void UID_Driver_ValueChecking(object sender, ColumnEventArgs e)
		{
			using (NoRightsCheck())
			{
				if (!string.Equals(e.Old.String, e.New.String, StringComparison.OrdinalIgnoreCase))
				{
					if (!_IsProfileDriver(e.New.String))
					{
						throw new ViException(881105, ExceptionRelevance.EndUser);
					}

					SetValue("UpdateProfileVII", true);
					SetValue("UpdatePathVII", true);
				}
			}
		}

		/// <summary>
		/// Set <c>ProfilePath</c> depending on <c>ProfileType</c>
		/// </summary>
		private void ProfileType_ValueSet(object sender, ColumnEventArgs e)
		{
			using (NoRightsCheck())
			{
				_Handle_ProfileType(true);
			}
		}
		#endregion

		#region Public NoCustom methods
		/// <summary>
		/// CustomMethod ohne User-Interaktion
		/// Stellt Jobs zum Einfügen, Ändern oder Löschen aller Installationtypes für diesen treiber ein
		/// </summary>
		/// <returns></returns>
		protected override bool OnCustomGenerate(String eventname)
		{
			Hashtable param = __GetInstallationTypeParam();
			using (NoRightsCheck())
			{
				if (!DbObject.IsLoaded)
				{
					JobGen.Generate(DbObject, "INSERT", param);
					return false;
				}
				else if (DbObject.IsDeleted)
				{
					JobGen.Generate(DbObject, "DELETE", param);
					return false;
				}
				else
				{
					JobGen.Generate(DbObject, "UPDATE", param);
					return false;
				}
			}
		}


		/// <summary>
		/// Copy all significant properties from the other <c>DriverProfile</c> to this instance.
		/// </summary>
		/// <param name="oOther">source <c>DriverProfile</c></param>
		[CustomMethod(false)]
		public bool Assign(ISingleDbObject oOther)
		{
			if (null == oOther)
			{
				return false;
			}

			using (NoRightsCheck())
			{
				//nicht auf sich selbst
				if (oOther.Equals(DbObject))
				{
					return false;
				}

				SetValue("Ident_DomainRD", oOther["Ident_DomainRD"].New.String);
				SetValue("ChgNumber", oOther["ChgNumber"].New.Int);
				SetValue("OrderNumber", oOther["OrderNumber"].New.Double);
				SetValue("DefDriveTarget", oOther["DefDriveTarget"].New.String);
				SetValue("OSMode", oOther["OSMode"].New.String);
				SetValue("MemoryUsage", oOther["MemoryUsage"].New.String);
				SetValue("ChgTest", oOther["ChgTest"].New.Int);
				SetValue("SubPath", oOther["SubPath"].New.String);
				SetValue("ClientStepCounter", oOther["ClientStepCounter"].New.Int);
				SetValue("Description", oOther["Description"].New.String);
				SetValue("Ident_DomainRDOwner", oOther["Ident_DomainRDOwner"].New.String);
				SetValue("UID_Driver", oOther["UID_Driver"].New.String);
				SetValue("ChgCL", oOther["ChgCL"].New.Int);
				SetValue("DisplayName", oOther["DisplayName"].New.String);
				SetValue("ProfileType", oOther["ProfileType"].New.String);
				SetValue("RemoveHKeyCurrentUser", oOther["RemoveHKeyCurrentUser"].New.String);

				SetValue("UID_SDLDomainRD", oOther["UID_SDLDomainRD"].New.String);
				SetValue("UID_SDLDomainRDOwner", oOther["UID_SDLDomainRDOwner"].New.String);

				// can we write this property ???
				if (DbObject["PackagePath"].CanEdit)
				{
					SetValue("PackagePath", oOther["PackagePath"].New.String);
				}

			}
			return true;
		}


		/// <summary>
		/// Returns true if this <c>DriverProfile</c> is referenced in a <c>Driver</c> object.
		/// </summary>
		/// <param name="UID_Driver"></param>
		/// <returns></returns>
		public bool _IsProfileDriver(string UID_Driver)
		{
			ISqlFormatter fSQL = DbObject.Connection.SqlFormatter;

			if (UID_Driver.Length > 0)
			{
				//MSSQL:(UID_Driver = '08e4d48f-0f3e-11d6-b1e8-00508b8f0145') and (IsProfileApplication= 1)
				//Oracle:(UID_Driver = '08e4d48f-0f3e-11d6-b1e8-00508b8f0145') and (IsProfileApplication= 1)
				return DbObject.Connection.Exists("Driver",
												  fSQL.AndRelation(
													  fSQL.Comparison("UID_Driver", UID_Driver, ValType.String, CompareOperator.Equal, FormatterOptions.None),
													  fSQL.Comparison("IsProfileApplication", true, ValType.Bool)));
			}

			return false;
		}


		#endregion

		#region Custom methods

		/// <summary>
		/// Returs the profile path from client for TAS or FDS
		/// </summary>
		/// <param name="DoForTAS"><c>True</c> -> path for TAS; <c>False</c> -> path for FDS</param>
		/// <returns></returns>
		[CustomMethod(false)]
		[Description("Method_DriverProfile_GetProfilePathClient")]
		public string GetProfilePathClient(bool DoForTAS)
		{
			string strProfPath = "";
			ISingleDbObject oDomain;

			using (NoRightsCheck())
			{
				if (String.IsNullOrEmpty(DbObject["Ident_DomainRD"].New.String))
				{
					throw new ViException(881034, ExceptionRelevance.EndUser, "Ident_DomainRD");
				}

				oDomain = DbObject.GetFK("Ident_DomainRD").Create();
				strProfPath = oDomain.Custom.CallMethod("GetNetPath", DoForTAS).ToString();

				if (!String.IsNullOrEmpty(strProfPath))
				{
					strProfPath += String.Concat(@"\", oDomain["ClientPartDriver"].New.String, @"\", DbObject["SubPath"].New.String);
				}
			}
			return strProfPath;
		}

		/// <summary>
		/// Returns client part of profile path
		/// </summary>
		/// <returns></returns>
		/// <exception cref="ViException">Error number:<b>881037</b><para>No application server exists which acts as Main Library Server.</para></exception>
		[CustomMethod(false)]
		[Description("Method_DriverProfile_GetCLProfilePathClient")]
		public string GetCLProfilePathClient()
		{
			string strProfPath = "";
			ISingleDbObject oDomain = _GetCLDomain();

			if (null != oDomain)
			{
				using (NoRightsCheck())
				{
					strProfPath = oDomain.Custom.CallMethod("GetNetPath", false).ToString();

					if (!String.IsNullOrEmpty(strProfPath))
					{
						strProfPath += String.Concat(@"\", oDomain["ClientPartDriver"].New.String, @"\", DbObject["SubPath"].New.String);
					}
				}
			}
			else
			{
				throw new ViException(881037, ExceptionRelevance.EndUser);
			}

			return strProfPath;
		}


		/// <summary>
		/// Enable all ressource domains to use this driver profile.
		/// </summary>
		/// <exception cref="ViException">Error number:<b>881067</b><para>This task can only be called as MLS profile.</para></exception>
		/// <exception cref="ViException">Error number:<b>881037</b><para>No application server exists which acts as Main Library Server.</para></exception>
		[CustomMethod(false)]
		[Description("Method_DriverProfile_AllowUsageAllRDs")]
		public void AllowUsageAllRDs()
		{
			ISingleDbObject dbObjCanUsedByRD;       // profile/driver can used by rd
			IColDbObject colRDs;        // list of all rds
			ISingleDbObject dbDomain = _GetCLDomain();      // CL-domain
			ISqlFormatter fSQL = DbObject.Connection.SqlFormatter;
			string strWhereClause = String.Empty;

			if (null != dbDomain)
			{
				using (NoRightsCheck())
				{
					string strUID_Profile = DbObject["UID_PROFILE"].New.String;

					if (String.IsNullOrEmpty(strUID_Profile))
					{
						return;
					}

					if (String.Compare(dbDomain["Ident_Domain"].New.String, DbObject["Ident_DomainRD"].New.String, StringComparison.OrdinalIgnoreCase) != 0)
					{
						throw new ViException(881067, ExceptionRelevance.EndUser);
					}

					colRDs = DbObject.Connection.CreateCol("Domain");
					colRDs.Prototype.WhereClause = fSQL.Comparison("Ident_Domain", dbDomain["Ident_Domain"].NewValue, ValType.String,
												   CompareOperator.NotEqual, FormatterOptions.ConvertNull);

					colRDs.Load();

					foreach (IColElem colElem in colRDs)
					{
						//MSSQL:(IDENT_DOMAINALLOWED = 'dhernmes01') and (UID_PROFILE = '08e4d48f-0f3e-11d6-b1e8-00508b8f0145')
						//Oracle:(upper(IDENT_DOMAINALLOWED) = 'DHERNMES01') and (UID_PROFILE = '08e4d48f-0f3e-11d6-b1e8-00508b8f0145')
						strWhereClause =
							fSQL.AndRelation(
								fSQL.Comparison("IDENT_DOMAINALLOWED", colElem.GetValue("IDENT_DOMAIN").String, ValType.String, CompareOperator.Equal, FormatterOptions.IgnoreCase),
								fSQL.Comparison("UID_PROFILE", strUID_Profile, ValType.String, CompareOperator.Equal, FormatterOptions.None));

						// only create entry, if not yet exists
						if (!DbObject.Connection.Exists("DriverCanUsedByRD", strWhereClause))
						{
							dbObjCanUsedByRD = DbObject.Connection.CreateSingle("DriverCanUsedByRD");
							dbObjCanUsedByRD["IDENT_DOMAINALLOWED"].NewValue = colElem.GetValue("IDENT_DOMAIN").String;
							dbObjCanUsedByRD["UID_PROFILE"].NewValue = strUID_Profile;
							dbObjCanUsedByRD.Save();
						}
					}
				}
			}
			else
			{
				throw new ViException(881037, ExceptionRelevance.EndUser);
			}
		}

		/// <summary>
		/// Generate a copy job for this driver profile from start server(CL,FDS,TAS) to destination server (CL,FDS,TAS)
		/// </summary>
		/// <param name="CopyEvent">Valid copy events: CopyCL2FDS, CopyCL2TAS, CopyFDS2CL, CopyFDS2TAS, CopyTAS2FDS</param>
		/// <param name="argUID_SourceServer">UID source server</param>
		/// <param name="argUID_DestServer">UID destination server</param>
		/// <param name="StartTime">Start time</param>
		/// <param name="Ident_DestDomain">Destination domain</param>
		/// <param name="DoOffline">Copy offline</param>
		[CustomMethod(false)]
		[Description("Method_DriverProfile_SvrCopy")]
		public void SvrCopy(string CopyEvent, string argUID_SourceServer, string argUID_DestServer, DateTime StartTime, string Ident_DestDomain, bool DoOffline)
		{
			using (NoRightsCheck())
			{
				try
				{
					DbObject.Connection.Variables.Put("SvrCopy", true);

					ModProfile.SvrCopy(DbObject, CopyEvent, argUID_SourceServer, argUID_DestServer, StartTime, Ident_DestDomain, DoOffline);
				}
				finally
				{
					DbObject.Connection.Variables.Remove("SvrCopy");
				}

			}
		}


		/// <summary>
		/// Count the lines in the MacFiles.VIP, MacReg.VIP, UsrFiles.VIP and UsrReg.VIP and put the result in in property <c>ClientStepCounter</c>.
		/// </summary>
		[CustomMethod(false)]
		[Description("Method_DriverProfile_UpdateOfClientStepCounter")]
		public void UpdateOfClientStepCounter()
		{
			using (NoRightsCheck())
			{
				ModProfile.UpdateOfClientStepCounter(DbObject);
			}
		}


		/// <summary>
		/// Generate a job to write the VII files for all installation types.
		/// </summary>
		/// <remarks>A message box will show up after successful processing.</remarks>
		[CustomDisplayMethod("strMethodDisplay881003", true)]
		[Description("Method_DriverProfile_WriteVIIFiles")]
		public void WriteVIIFiles()
		{
			using (NoRightsCheck())
			{
				ModProfile.WriteVIIFiles(DbObject);

				DbObject.Connection.ShowMessage(
					LanguageManager.Instance["str881_WriteVIIFiles"],
					LanguageManager.Instance["str881_Information"]);
			}
		}


		/// <summary>
		/// Generate a event for the given server.
		/// </summary>
		/// <param name="DelEvent">Allowed events <c>DeleteOnFDS</c> <c>DeleteOnTAS</c></param>
		/// <param name="UID_Server">Server</param>
		[CustomMethod(true)]
		[Description("Method_DriverProfile_DeleteOn")]
		public void DeleteOn(string DelEvent, string UID_Server)
		{
			using (NoRightsCheck())
			{
				ModProfile.DeleteOn(DbObject, DelEvent, UID_Server);

				DbObject.Connection.ShowMessage(
					LanguageManager.Instance["str881_DeleteProfile"],
					LanguageManager.Instance["str881_Information"]);
			}
		}

		#endregion

		#region Object Functions

		/// <exclude/>
		/// <summary>
		/// Befüllt die Properties initial
		/// </summary>
		private void _Handle_InitColumns()
		{
			/* #28523 Wird via template gelöst
			using (NoRightsCheck())
			{
				SetValue("ProfileDate", m_InitDate);
				SetValue("OSMode", "AUTO");
			}
			*/
		}

		/// <exclude/>
		/// <summary>
		/// Wenn es sich bei dem ProfileType um MSI oder SSM handelt, wird der PackagePath editierbar und zum Pflichtfels
		/// Wenn es sich bei dem ProfileType nicht um MSI oder SSM handelt, wird der PackagePath gelöscht und nicht editierbar
		/// </summary>
		private void _Handle_ProfileType(bool bChange)
		{
			string strProfileType = DbObject["ProfileType"].New.String;

			if ((StringComparer.OrdinalIgnoreCase.Compare(strProfileType, "MSI") == 0) ||
				(StringComparer.OrdinalIgnoreCase.Compare(strProfileType, "SSM") == 0))  // it's an MSI- or SSM -Profile
			{
				// enable the column
				SetCanEdit("PackagePath", true);
				//DbObject["PackagePath"].MinLen = 1;
			}
			else
			{
				// lock and clear the column
				SetMinLen("PackagePath", 0);
				SetCanEdit("PackagePath", false);

				if (bChange) DbObject["PackagePath"].ClearValue();
			}
		}

		/// <exclude/>
		/// <summary>
		/// setzt die OrderNumber auf den Höchsten Wert in dieser Domäne außer dieses Profile
		/// </summary>
		private void _SetRightOrderNumber()
		{
			Double number = 0;
			using (NoRightsCheck())
			{
				// Do not check empty values
				if (String.IsNullOrEmpty(DbObject["Ident_DomainRD"].New.String))
				{
					return;
				}

				ISqlFormatter fSQL = DbObject.Connection.SqlFormatter;
				//Code vor Optimierung
				//MSSQL:ordernumber = (Select Max(ordernumber) from DriverProfile where Ident_DomainRD = 'domainRD' and isnull(UID_Profile, '') <> '08e4d48f-0f3e-11d6-b1e8-00508b8f0145')
				//Oracle:ordernumber = (Select Max(ordernumber) from DriverProfile where upper(Ident_DomainRD) = 'DOMAINRD' and upper(UID_Profile) <> '08E4D48F-0F3E-11D6-B1E8-00508B8F0145')

				//string strWhere = f.Comparison("Ident_DomainRD",DbObject["Ident_DomainRD"].New.String,ValType.String);
				//strWhere += " and " + f.Comparison("UID_Profile",DbObject["UID_Profile"].New.String,ValType.String,CompareOperator.NotEqual);
				//strWhere = "ordernumber = (Select Max(ordernumber) from DriverProfile where " + strWhere + ")";
				//Code nach Optimierung

				//MSSQL:ordernumber = (Select Max(ordernumber) from DriverProfile where Ident_DomainRD = 'domainRD' and (UID_Profile <> '08e4d48f-0f3e-11d6-b1e8-00508b8f0145'))
				//Oracle:ordernumber = (Select Max(ordernumber) from DriverProfile where upper(Ident_DomainRD) = 'DOMAINRD' and (UID_Profile <> '08e4d48f-0f3e-11d6-b1e8-00508b8f0145'))
				string strWhereClause = string.Format(
											DbObject.Connection.SqlStrings["DriverProfile_MaxOrderNumber"],
											fSQL.FormatValue(DbObject["Ident_DomainRD"].New.String, ValType.String),
											fSQL.FormatValue(DbObject["UID_Profile"].New.String, ValType.String));

				number = DbObject.Connection.GetSingleProperty("DriverProfile", "OrderNumber", strWhereClause).Double;

				if (number >= 9999)
				{
					throw new ViException(881045, ExceptionRelevance.EndUser);
				}

				SetValue("OrderNumber", number + 1);
			}
		}

		/// <exclude/>
		/// <summary>
		/// Gibt die Domäne des Servers gesetztem IsCentralLibrary Flag zurück
		/// </summary>
		/// <returns>Domäne des CL-Servers bzw. null, wenn keiner existiert</returns>
		private ISingleDbObject _GetCLDomain()
		{
			ISingleDbObject oDomain = null;
			ISqlFormatter fSQL = DbObject.Connection.SqlFormatter;
			using (NoRightsCheck())
			{
				if (DbObject.Connection.Exists("ApplicationServer", fSQL.Comparison("IsCentralLibrary", true, ValType.Bool)))
				{
					string strIdent_Domain = DbObject.Connection.GetSingleProperty("ApplicationServer", "Ident_domain", fSQL.Comparison("IsCentralLibrary", true, ValType.Bool));
					oDomain = DbObject.Connection.CreateSingle("Domain", strIdent_Domain);
				}
			}
			return oDomain;
		}

		/// <exclude/>
		/// <summary>
		/// Ermittelt Parameter für Copy-unktion
		/// </summary>
		/// <param name="CopyEvent">Name des Copy-Ereignisses</param>
		/// <param name="UID_SourceServer">ref-Param, UID des Quell-Servers, wenn von FDS kopiert wird</param>
		/// <param name="UID_DestServer">ref-Param UID des Zielservers, wenn nach FDS kopiert wird</param>
		/// <param name="SourceDomain">Quell-Domäne</param>
		/// <param name="DestDomain">Ziel-Domäne</param>
		private void _CompleteUnknownFDS(string CopyEvent, ref string UID_SourceServer, ref string UID_DestServer, string SourceDomain, ref string DestDomain)
		{
			ISingleDbObject oServer;
			using (NoRightsCheck())
			{
				// Copyoperation from FDS
				if (((CopyEvent.IndexOf("FDS2", StringComparison.OrdinalIgnoreCase) >= 0) ||
					 (CopyEvent.IndexOf("FDS_P2", StringComparison.OrdinalIgnoreCase) >= 0) ||
					 (CopyEvent.IndexOf("FDS_C2", StringComparison.OrdinalIgnoreCase) >= 0))
					&& (0 == UID_SourceServer.Length))
				{
					oServer = _ServerExists("FDS", SourceDomain, false);

					if (null == oServer)
					{
						UID_SourceServer = oServer["UID_Server"].New.String;
					}
				}

				// Copyoperation to FDS
				if ((CopyEvent.IndexOf("2FDS", StringComparison.OrdinalIgnoreCase) >= 0) && (0 == UID_DestServer.Length))
				{
					if (0 == DestDomain.Length)
					{
						DestDomain = SourceDomain;
					}

					oServer = _ServerExists("FDS", DestDomain, false);

					if (null != oServer)
					{
						UID_DestServer = oServer["UID_Server"].New.String;
					}
				}
			}
		}

		/// <exclude/>
		/// <summary>
		/// Gibt den TAS-, FDS- oder CL - Server der Domain zurück
		/// die Domaine muss in Ihren Nebenwirkungen die entsprechenden Methoden bereitstellen
		/// </summary>
		/// <param name="strServerRole">TAS, FDS oder CL</param>
		/// <param name="strIdentDomain"> Ident_Domain</param>
		/// <param name="bWithError">True...es werden Exceptions gefeuert, False...ohne Exceptions</param>
		/// <returns>TAS, FDS oder CL - Object bzw. null wenn ein Fehler auftrat</returns>
		private ISingleDbObject _ServerExists(string strServerRole, string strIdentDomain, bool bWithError)
		{
			ISingleDbObject dbServer = null;
			ISingleDbObject dbDomain = null;    // profiledomain for test, if FDS and/or TAS exists

			using (NoRightsCheck())
			{
				if ((String.IsNullOrEmpty(strServerRole)) ||
					(String.IsNullOrEmpty(strIdentDomain)))
				{
					return dbServer;
				}

				dbDomain = DbObject.Connection.CreateSingle("Domain", strIdentDomain);

				if (null == dbDomain.Custom)
				{
					if (bWithError)
					{
						throw new ViException(881150, ExceptionRelevance.EndUser, dbDomain.Tablename);
					}
					else
					{
						return dbServer;
					}
				}

				if (String.Equals(strServerRole, "TAS", StringComparison.OrdinalIgnoreCase))
				{
					dbServer = dbDomain.Custom.CallMethod("GetTAS", true) as ISingleDbObject;

					if (null == dbServer)
					{
						if (bWithError)
						{
							throw new ViException(881096, ExceptionRelevance.EndUser, strServerRole, strIdentDomain);
						}
						else
						{
							return dbServer;
						}
					}
				}

				if (String.Equals(strServerRole, "FDS", StringComparison.OrdinalIgnoreCase))
				{
					dbServer = dbDomain.Custom.CallMethod("GetRootAppServer", true) as ISingleDbObject;

					if (null == dbServer)
					{
						if (bWithError)
						{
							throw new ViException(881096, ExceptionRelevance.EndUser, strServerRole, strIdentDomain);
						}
						else
						{
							return dbServer;
						}
					}
				}

				if (String.Equals(strServerRole, "CL", StringComparison.OrdinalIgnoreCase))
				{
					dbServer = dbDomain.Custom.CallMethod("GetCLServer", true) as ISingleDbObject;

					if (null == dbServer)
					{
						if (bWithError)
						{
							throw new ViException(881096, ExceptionRelevance.EndUser, strServerRole, strIdentDomain);
						}
						else
						{
							return dbServer;
						}
					}
				}
			}

			return dbServer;
		}

		/// <exclude/>
		/// <summary>
		/// Gibt alle Ident_InstType der Tabelle InstallationType als ParameterCollection für Jobgenerierung zurück
		/// </summary>
		/// <remarks>Optimierung: ColElem.GetValue in foreach</remarks>
		/// <returns>ParameterCollection aus InstTypenn und Ident_InstType</returns>
		private Hashtable __GetInstallationTypeParam()
		{
			Hashtable param = new Hashtable(StringComparer.OrdinalIgnoreCase);
			long zae = 0;
			using (NoRightsCheck())
			{
				IColDbObject colInstType = DbObject.Connection.CreateCol("InstallationType");
				colInstType.Prototype["Ident_InstType"].IsDisplayItem = true;
				colInstType.Load();

				foreach (IColElem colElem in colInstType)
				{
					param.Add("InstType" + zae.ToString(), colElem.GetValue("Ident_InstType").String);
					zae++;
				}
			}

			return param;
		}

		/// <exclude/>
		/// <summary>
		/// Testet, ob ein Server für das konkrete Copy-Event existiert
		/// </summary>
		/// <param name="argCopyEvent">CopyEvent</param>
		/// <param name="SourceDomain">QuellDomäne</param>
		/// <param name="argDestDomain">ZielDomäne</param>
		/// <returns></returns>
		private bool _CheckServerExists(string argCopyEvent, string SourceDomain, string argDestDomain)
		{
			bool bRetVal = true;
			string CopyEvent = argCopyEvent;
			string DestDomain = argDestDomain;
			ISingleDbObject oServer;

			using (NoRightsCheck())
			{
				// is destination domain empty
				if (String.IsNullOrEmpty(DestDomain))
				{
					DestDomain = SourceDomain;
				}


				if (CopyEvent.IndexOf("TAS2", StringComparison.OrdinalIgnoreCase) >= 0)
				{
					oServer = _ServerExists("TAS", SourceDomain, true);

					if (null == oServer)
					{
						bRetVal = false;
					}
				}

				if (CopyEvent.IndexOf("2TAS", StringComparison.OrdinalIgnoreCase) >= 0)
				{
					oServer = _ServerExists("TAS", DestDomain, true);

					if (null == oServer)
					{
						bRetVal = false;
					}
				}

				if (CopyEvent.IndexOf("FDS2", StringComparison.OrdinalIgnoreCase) >= 0)
				{
					oServer = _ServerExists("FDS", SourceDomain, true);

					if (null == oServer)
					{
						bRetVal = false;
					}
				}

				if (CopyEvent.IndexOf("2FDS", StringComparison.OrdinalIgnoreCase) >= 0)
				{
					oServer = _ServerExists("FDS", DestDomain, true);

					if (null == oServer)
					{
						bRetVal = false;
					}
				}

				if (CopyEvent.IndexOf("CL2", StringComparison.OrdinalIgnoreCase) >= 0)
				{
					oServer = _ServerExists("CL", SourceDomain, true);

					if (null == oServer)
					{
						bRetVal = false;
					}
				}

				if (CopyEvent.IndexOf("2CL", StringComparison.OrdinalIgnoreCase) >= 0)
				{
					oServer = _ServerExists("CL", SourceDomain, true);

					if (null == oServer)
					{
						bRetVal = false;
					}
				}

				if (CopyEvent.IndexOf("FDS_C2", StringComparison.OrdinalIgnoreCase) >= 0)
				{
					oServer = _ServerExists("FDS", SourceDomain, true);

					if (null == oServer)
					{
						bRetVal = false;
					}
				}

				if (CopyEvent.IndexOf("FDS_P2", StringComparison.OrdinalIgnoreCase) >= 0)
				{
					oServer = _ServerExists("FDS", SourceDomain, true);

					if (null == oServer)
					{
						bRetVal = false;
					}
				}
			}

			return bRetVal;
		}

		/// <exclude/>
		/// <summary>
		/// Es wird geprüft, ob zu der zu diesem Profil zugehürigen Treiber Profile vorhanden sind.
		/// Falls ja, wird das Flag IsProfileApplication in Driver auf 1 gesetzt
		/// Falls nicht, wird das Flag IsProfileApplication in Driver auf 0 gesetzt.
		/// </summary>
		private void _CheckIsProfileDriver()
		{
			IColDbObject colDriverProfile = DbObject.Connection.CreateCol("DriverProfile"); ;
			ISqlFormatter fSQL = DbObject.Connection.SqlFormatter;

			// geloescht
			if (DbObject.IsDeleted)
			{
				// gibt es noch andere Profile ???
				colDriverProfile.Prototype.WhereClause =
					fSQL.AndRelation(fSQL.Comparison("UID_Driver", DbObject["UID_Driver"].New.String,
													  ValType.String, CompareOperator.Equal, FormatterOptions.None),
									  fSQL.Comparison("UID_Profile", DbObject["UID_Profile"].New.String,
													  ValType.String, CompareOperator.NotEqual, FormatterOptions.None)
									);

				// nein
				if (colDriverProfile.DBCount == 0)
				{
					// exists the Driver ( we are not in DeleteCascade )
					// This Check is required because the UID_Driver is filled, but the Object is already deleted
					if (DbObject.Connection.Exists("Driver", fSQL.Comparison("UID_Driver", DbObject["UID_Driver"].New.String,
													ValType.String, CompareOperator.Equal, FormatterOptions.None)))
					{
						// auf false setzen
						ISingleDbObject dbDriver = DbObject.GetFK("UID_Driver").Create();

						if (dbDriver != null)
						{
							if (dbDriver["IsProfileApplication"].New.Bool == true)
							{
								dbDriver["IsProfileApplication"].NewValue = false;
								dbDriver.Save();
							}
						}
					}
				}
			}

			// Insert
			if (!DbObject.IsLoaded)
			{
				ISingleDbObject dbDriver = DbObject.GetFK("UID_Driver").Create();

				if (dbDriver != null)
				{
					if (dbDriver["IsProfileApplication"].New.Bool == false)
					{
						dbDriver["IsProfileApplication"].NewValue = true;
						dbDriver.Save();
					}
				}
			}
		}

		/// <exclude/>
		/// <summary>
		/// Beschreibung: Es wird ein Eintrag in TroubleProduct fuer diesen Treiber vorgenommen.
		///  Ident_TroubleProduct = substring(NameFull, 1, 64)
		///  Description = substring(NameFull, 1, 64),
		///  SupportLevel = 1,
		///  IsInActive = 0.
		/// Voraussetzungen:
		///   * Der Configparm 'Helpdesk\AutoProduct\Driver' ist gesetzt,
		///   * Für den Treiber gibt es noch keinen Eintrag in TroubleProduct  --> substring(Driver.NameFull, 1, 64) != Ident_TroubleProduct,
		///   * zu diesem Treiber gibt es mindestens ein DriverProfil.
		/// </summary>
		private void _HandleTroubleProduct()
		{
			ISqlFormatter fSQL = DbObject.Connection.SqlFormatter;

			TroubleProductHelper.HandleTroubleProduct(
				DbObject.Connection,
				"Driver",
				DbObject.ObjectWalker.GetValue("FK(UID_Driver).NameFull").String,
				null, null);
		}

		#endregion
	}

	/// <summary>
	/// EntityLogic for table <c>DriverProfile</c>
	/// </summary>
	internal class _DriverProfile : StateBasedEntityLogic
	{
		public _DriverProfile()
		{
			string[] vUpdateProfile = { "ChgNumber", "ChgTest", "ClientStepCounter", "MemoryUsage", "OrderNumber", "OSMode", "ServerDrive", "UID_Driver" };

			foreach (string strColumn in vUpdateProfile)
			{
				Value("UpdateProfileVII")
					.From(strColumn, strColumn + "[o]")
					.As((object iNew, object iOld) => TryResult.FromResult(iNew != iOld, true));
			}

			string[] vUpdatePath = { "Ident_InstType", "Ident_OS", "SubPath", "UID_Driver" };

			foreach (string strColumn in vUpdatePath)
			{
				Value("UpdatePathVII")
					.From(strColumn, strColumn + "[o]")
					.As((object iNew, object iOld) => TryResult.FromResult(iNew != iOld, true));
			}

			Check("OrderNumber")
				.As((double dOrderNumer) =>
				{
					if (dOrderNumer < 0) throw new ViException(2116149, ExceptionRelevance.EndUser);
					if (dOrderNumer > 10000) throw new ViException(2116149, ExceptionRelevance.EndUser);
					return true;
				});


			Value("OSMode").Default("AUTO");
			Format("OSMode").As((string osMode) =>
			{

				osMode = osMode.Trim().ToUpperInvariant();

				if (string.IsNullOrEmpty(osMode)) osMode = "AUTO";

				return osMode;
			});

			Format("SubPath").As<string, string>(subPath => subPath.TrimEnd('\\'));

			Check("UID_Driver")
				.AsExpensive<string>(_Check_UID_Driver);

			RegisterMethod("Assign")
				.As<IValueProvider>(AssignAsync);

			RegisterFunction("GetCLProfilePathClient")
				.As<string>(_GetCLProfilePathClient)
				.Description("Method_DriverProfile_GetCLProfilePathClient");

			RegisterFunction("GetProfilePathClient")
				.As<bool, string>(_GetProfilePathClient)
				.Description("Method_DriverProfile_GetProfilePathClient");


			RegisterMethod("WriteVIIFiles")
				.As(WriteViiFilesAsync)
				.Description("Method_DriverProfile_WriteVIIFiles")
				.IsDisplayMethod("strMethodDisplay881003");
		}

		private static Task WriteViiFilesAsync(ISession session, IEntity entity, CancellationToken ct)
		{
			ISingleDbObject dbObject = entity.CreateSingleDbObject(session);

			ModProfile.WriteVIIFiles(dbObject);

			dbObject.Connection.ShowMessage(
				LanguageManager.Instance["str881_WriteVIIFiles"],
				LanguageManager.Instance["str881_Information"]);

			return NullTask.Instance;
		}

		private async Task<string> _GetProfilePathClient(ISession session, IEntity entity, bool DoForTAS, CancellationToken ct)
		{
			string strProfPath = "";
			

			if (String.IsNullOrEmpty(entity.GetValue<string>("Ident_DomainRD")))
			{
				throw new ViException(881034, ExceptionRelevance.EndUser, "Ident_DomainRD");
			}

			var fkDomain = await entity.GetFkAsync(session, "UID_SDLDomainRD", ct).ConfigureAwait(false);

			var oDomain = await fkDomain.GetParentAsync(EntityLoadType.Interactive,ct).ConfigureAwait(false);

			strProfPath = oDomain.CallFunction("GetNetPath", DoForTAS).ToString();

			if (!String.IsNullOrEmpty(strProfPath))
			{
				strProfPath += String.Concat(@"\", oDomain.GetValue<string>("ClientPartDriver"), @"\", oDomain.GetValue < string >("SubPath"));
			}

			return strProfPath;
		}

		private static async Task<bool> _Check_UID_Driver(ISession session, IEntity entity, string uidDriver, CancellationToken ct)
		{
			// do not check empty values
			if (String.IsNullOrEmpty(uidDriver))
				return true;

			Query qApplication = Query.From("Driver")
				.Where(c => c.Column("UID_Driver") == uidDriver)
				.Select("IsProfileApplication");

			bool isProfileApplication = await session.Source().GetSingleValueAsync<bool>(qApplication, ct).ConfigureAwait(false);

			if (!isProfileApplication)
				throw new ViException(2116105, ExceptionRelevance.EndUser);

			return true;
		}


		private async Task<string> _GetCLProfilePathClient(ISession session, IEntity entity, CancellationToken ct)
		{
			string strProfPath = "";
			IEntity eDomain = await _GetCLDomain(session, ct).ConfigureAwait(false);

			if (null != eDomain)
			{
				strProfPath = (string) await eDomain.CallFunctionAsync("GetNetPath", false, cancellationToken: ct).ConfigureAwait(false);

				if (!String.IsNullOrEmpty(strProfPath))
				{
					strProfPath += String.Concat(@"\", eDomain.GetValue<string>("ClientPartDriver"), @"\", entity.GetValue<string>("SubPath"));
				}
			}
			else
			{
				throw new ViException(2116037, ExceptionRelevance.EndUser);
			}

			return strProfPath;
		}

		/// <exclude/>
		/// <summary>
		/// Gibt die Domäne des Servers gesetztem IsCentralLibrary Flag zurück
		/// </summary>
		/// <returns>Domäne des CL-Servers bzw. null, wenn keiner existiert</returns>
		private async Task<IEntity> _GetCLDomain( ISession session, CancellationToken ct )
		{
			ISqlFormatter fSQL = session.SqlFormatter();

			Query qCL = Query.From("SDLDomain")
				.Where(fSQL.FkComparison("UID_SDLDomain", "ApplicationServer",
					fSQL.Comparison("IsCentralLibrary", true, ValType.Bool)))
				.SelectAll();

			var tr = await session.Source().TryGetAsync(qCL, ct).ConfigureAwait(false);

			return tr.Success ? tr.Result : null;
		}

		private Task AssignAsync(ISession session, IEntity entity, IValueProvider vpSource, CancellationToken ct)
		{
			if (vpSource == null) throw new ArgumentNullException("vpSource");

			//nicht auf sich selbst
			if (vpSource == entity) throw new InvalidOperationException("Source can not be the same object.");

			entity.SetValue("Ident_DomainRD", vpSource.GetValue<string>("Ident_DomainRD"));
			entity.SetValue("ChgNumber", vpSource.GetValue<int>("ChgNumber"));
			entity.SetValue("OrderNumber", vpSource.GetValue<double>("OrderNumber"));
			entity.SetValue("DefDriveTarget", vpSource.GetValue<string>("DefDriveTarget"));
			entity.SetValue("OSMode", vpSource.GetValue<string>("OSMode"));
			entity.SetValue("MemoryUsage", vpSource.GetValue<string>("MemoryUsage"));
			entity.SetValue("ChgTest", vpSource.GetValue<int>("ChgTest"));
			entity.SetValue("SubPath", vpSource.GetValue<string>("SubPath"));
			entity.SetValue("ClientStepCounter", vpSource.GetValue<int>("ClientStepCounter"));
			entity.SetValue("Description", vpSource.GetValue<string>("Description"));
			entity.SetValue("Ident_DomainRDOwner", vpSource.GetValue<string>("Ident_DomainRDOwner"));
			entity.SetValue("UID_Driver", vpSource.GetValue<string>("UID_Driver"));
			entity.SetValue("ChgCL", vpSource.GetValue<int>("ChgCL"));
			entity.SetValue("DisplayName", vpSource.GetValue<string>("DisplayName"));
			entity.SetValue("ProfileType", vpSource.GetValue<string>("ProfileType"));
			entity.SetValue("RemoveHKeyCurrentUser", vpSource.GetValue<string>("RemoveHKeyCurrentUser"));

			// TODO: Check this! can we write this property ???
			if (entity.Columns["PackagePath"].CanEdit)
			{
				entity.SetValue("PackagePath", vpSource.GetValue<string>("PackagePath"));
			}

			return NullTask.Instance;
		}

		public override async Task<Diff> OnSavingAsync(IEntity entity, LogicReadWriteParameters parameters, CancellationToken cancellationToken)
		{
			LogicParameter lp = new LogicParameter(entity, parameters, cancellationToken);

			if (!entity.IsLoaded &&
				DbVal.IsEmpty(entity.GetValue<int>("OrderNumber"), ValType.Int))
			{
				await _SetRightOrderNumber(lp).ConfigureAwait(false); ;
			}

			if (!entity.IsLoaded)
			{
				await ModProfile.IsUniqueAKProfile(lp).ConfigureAwait(false);
			}

			if (!entity.IsDeleted())
			{
				await _HandleTroubleProduct(lp).ConfigureAwait(false);
			}


			return await base.OnSavingAsync(entity, parameters, cancellationToken).ConfigureAwait(false);
		}

		public override async Task<bool> OnGenerate(IEntity entity, string eventname, LogicReadWriteParameters parameters, CancellationToken cancellationToken)
		{
			Hashtable param = new Hashtable(StringComparer.OrdinalIgnoreCase);
			long ulCo = 0;

			Query qProfileCanUsedAlso = Query.From("ProfileCanUsedAlso")
				.Where(c => c.Column("UID_Profile") == entity.GetValue<string>("UID_Profile"))
				.SelectAll();

			IEntityCollection colAlso = await parameters.Session.Source().GetCollectionAsync(qProfileCanUsedAlso, EntityCollectionLoadType.Bulk, cancellationToken).ConfigureAwait(false);

			foreach (IEntity colElem in colAlso)
			{
				IEntityWalker w = colElem.CreateWalker(parameters.Session);
				param.Add("ProfileCUA_Ident_InstTypeAlso" + ulCo, w.GetValue<string>("Ident_InstTypeAlso"));
				param.Add("ProfileCUA_Ident_OSAlso" + ulCo, w.GetValue<string>("Ident_OSAlso"));
				param.Add("ProfileCUA_UID_InstTypeAlso" + ulCo, w.GetValue<string>("UID_InstallationType"));
				param.Add("ProfileCUA_UID_OSAlso" + ulCo, w.GetValue<string>("UID_OS"));
				ulCo++;
			}

			return await base.OnGenerate(entity, eventname, parameters, cancellationToken).ConfigureAwait(false);
		}

		private async Task _SetRightOrderNumber(LogicParameter lp)
		{
			ISqlFormatter fSql = lp.SqlFormatter;

			string strWhereClause = SqlStrings.Format(lp.Session.Database().SystemIdentifier,
				"SDL_DriverProfile_MaxOrderNumber",
				fSql.AndRelation(
					fSql.UidComparison("UID_SDLDomainRD", lp.Entity.GetValue<string>("UID_SDLDomainRD")),
					fSql.UidComparison("UID_Profile", lp.Entity.GetValue<string>("UID_Profile"), CompareOperator.NotEqual))
				);

			var trNumber = await lp.Session.Source().TryGetSingleValueAsync<double>("DriverProfile", "OrderNumber", strWhereClause, lp.CancellationToken).ConfigureAwait(false);

			double number = trNumber.Success ? trNumber.Result : 0;

			if (number >= 9999)
			{
				throw new ViException(2116045, ExceptionRelevance.EndUser);
			}

			lp.Entity.SetValue("OrderNumber", number + 1);
		}

		private Task _HandleTroubleProduct(LogicParameter lp)
		{
			return TroubleProductHelper.HandleTroubleProduct(lp,
				"Driver",
				lp.ObjectWalker.GetValue<string>("FK(UID_Driver).NameFull"),
				null, null);
		}

		private async Task _HandleIsProfileApplication(LogicParameter lp)
		{
			ISqlFormatter fSQL = lp.SqlFormatter;

			// Objekt wurde gelöscht
			if (lp.Entity.IsDeleted())
			{
				// geloescht
				// gibt es noch andere Profile ???
				string strWhereClause =
					fSQL.AndRelation(fSQL.UidComparison("UID_Application", lp.Entity.GetValue<string>("UID_Application")),
									   fSQL.UidComparison("UID_Profile", lp.Entity.GetValue<string>("UID_Profile"), CompareOperator.NotEqual)
									);

				// nein
				if (!await lp.Session.Source().ExistsAsync("ApplicationProfile", strWhereClause, lp.CancellationToken).ConfigureAwait(false))
				{
					DbObjectKey dbokApplication = DbObjectKey.GetObjectKey("Application", lp.Entity.GetValue<string>("UID_Application"));

					TryResult<IEntity> trApplication = await lp.Session.Source().TryGetAsync(dbokApplication, lp.CancellationToken).ConfigureAwait(false);

					if (trApplication.Success &&
						trApplication.Result.GetValue<bool>("IsProfileApplication"))
					{
						trApplication.Result.SetValue("IsProfileApplication", false);

						await lp.UnitOfWork.PutAsync(trApplication.Result, lp.CancellationToken).ConfigureAwait(false);
					}
				}
			}

			// Objekt wurde neu angelegt
			if (!lp.Entity.IsLoaded)
			{
				DbObjectKey dbokApplication = DbObjectKey.GetObjectKey("Application", lp.Entity.GetValue<string>("UID_Application"));

				TryResult<IEntity> trApplication = await lp.Session.Source().TryGetAsync(dbokApplication, lp.CancellationToken).ConfigureAwait(false);

				if (trApplication.Success && !
					trApplication.Result.GetValue<bool>("IsProfileApplication"))
				{
					// mark as IsProfileApplication
					trApplication.Result.SetValue("IsProfileApplication", true);

					await lp.UnitOfWork.PutAsync(trApplication.Result, lp.CancellationToken).ConfigureAwait(false);
				}
			}
		}
	}
}
	