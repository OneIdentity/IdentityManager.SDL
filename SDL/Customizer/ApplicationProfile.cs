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

namespace SDL.Customizer
{
	/// <summary>
	/// Customizer for table <c>ApplicationProfile</c>.
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
	public class ApplicationProfile : VI.DB.Customizer
	{
		#region additional member variables

		// Die Variable wird genutzt, um nach Init und verwerfen das gleiche Datum eintragen zu können
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

			// proterty - events
			theObj["ChgNumber"].ValueSet += UpdateProfileVII_ValueSet;
			theObj["ChgTest"].ValueSet += UpdateProfileVII_ValueSet;
			theObj["ClientStepCounter"].ValueSet += UpdateProfileVII_ValueSet;
			theObj["Ident_DomainRD"].ValueSet += Ident_DomainRD_ValueSet;
			theObj["Ident_InstType"].ValueSet += UpdatePathVII_ValueSet;
			theObj["Ident_OS"].ValueSet += UpdatePathVII_ValueSet;
			theObj["MemoryUsage"].ValueSet += UpdateProfileVII_ValueSet;
			theObj["OrderNumber"].ValueSet += UpdateProfileVII_ValueSet;
			theObj["OrderNumber"].ValueChecking += OrderNumber_ValueChecking;
			theObj["OSMode"].ValueSet += UpdateProfileVII_ValueSet;
			theObj["OSMode"].ValueChecking += OSMode_ValueChecking;
			theObj["ServerDrive"].ValueSet += UpdateProfileVII_ValueSet;
			theObj["SubPath"].ValueChecking += SubPath_ValueChecking;
			theObj["SubPath"].ValueSet += UpdatePathVII_ValueSet;
			theObj["UID_Application"].ValueChecking += UID_Application_ValueChecking;
			theObj["UID_Application"].ValueSet += UID_Application_ValueSet;

			// Objekt initialisieren
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
			DbObject["ChgNumber"].ValueSet -= UpdateProfileVII_ValueSet;
			DbObject["ChgTest"].ValueSet -= UpdateProfileVII_ValueSet;
			DbObject["ClientStepCounter"].ValueSet -= UpdateProfileVII_ValueSet;
			DbObject["Ident_DomainRD"].ValueSet -= Ident_DomainRD_ValueSet;
			DbObject["Ident_InstType"].ValueSet -= UpdatePathVII_ValueSet;
			DbObject["Ident_OS"].ValueSet -= UpdatePathVII_ValueSet;
			DbObject["MemoryUsage"].ValueSet -= UpdateProfileVII_ValueSet;
			DbObject["OrderNumber"].ValueSet -= UpdateProfileVII_ValueSet;
			DbObject["OrderNumber"].ValueChecking -= OrderNumber_ValueChecking;
			DbObject["OSMode"].ValueSet -= UpdateProfileVII_ValueSet;
			DbObject["OSMode"].ValueChecking -= OSMode_ValueChecking;
			DbObject["ServerDrive"].ValueSet -= UpdateProfileVII_ValueSet;
			DbObject["SubPath"].ValueChecking -= SubPath_ValueChecking;
			DbObject["SubPath"].ValueSet -= UpdatePathVII_ValueSet;
			DbObject["UID_Application"].ValueChecking -= UID_Application_ValueChecking;
			DbObject["UID_Application"].ValueSet -= UID_Application_ValueSet;
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

			ModProfile.CheckAndSetOSMode(DbObject, "OSMode", DbObject["OsMode"].New.String);

			if (!DbObject.IsLoaded)
			{
				ModProfile.IsUniqueAKProfile(DbObject);
			}

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
			_CheckIsProfileApplication();

			base.OnSaved();
		}


		/// <summary>
		///  Process the customizations after the object changes were discarded.
		/// </summary>
		protected override void OnDiscarded()
		{
			if (!DbObject.IsLoaded)
			{
				_Handle_InitColumns();
			}

			base.OnDiscarded();
		}

		#endregion protected override methods

		#region Property-Events

		private void Ident_DomainRD_ValueSet(object sender, ColumnEventArgs e)
		{
			using (NoRightsCheck())
			{
				if ((DbObject["Ident_DomainRD"].New.String.Length > 0) && (DbObject["Ident_DomainRDOwner"].New.String.Length == 0))
				{
					SetValue("Ident_DomainRDOwner", DbObject["Ident_DomainRD"].New.String);
				}
			}
		}


		/// <summary>
		/// Ist die OrderNumber kleiner als 10000 wird der Wert abgewiesen
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		private void OrderNumber_ValueChecking(object sender, ColumnEventArgs e)
		{
			using (NoRightsCheck())
			{
				if (e.New.Double < 10000)
				{
					throw new ViException(881134, ExceptionRelevance.EndUser);
				}

				if (e.New.Double > 100000000)
				{
					throw new ViException(881126, ExceptionRelevance.EndUser, e.Column.ColDef.Display, "100000000");
				}
			}
		}


		private void OSMode_ValueChecking(object sender, ColumnEventArgs e)
		{
			using (NoRightsCheck())
			{
				_Handle_OSMode_ValueChecking(e.New.String);
			}
		}


		private void SubPath_ValueChecking(object sender, ColumnEventArgs e)
		{
			using (NoRightsCheck())
			{
				string wert = e.New.String.TrimEnd('\\');

				if (e.New.String != wert)
				{
					e.NewValue = wert;
				}
			}
		}


		private void UID_Application_ValueChecking(object sender, ColumnEventArgs e)
		{
			string strWhereClause = "";
			using (NoRightsCheck())
			{
				if (0 < e.New.String.Length)
				{
					ISqlFormatter fSQL = DbObject.Connection.SqlFormatter;

					//MSSQL:(UID_Application = '0f90b30e-f1cc-11d4-9700-00508b8f013d') and (isnull(IsProfileApplication, 0) = 0)
					//Oracle:(UID_Application = '0f90b30e-f1cc-11d4-9700-00508b8f013d') and (nvl(IsProfileApplication, 0) = 0)
					strWhereClause =
						fSQL.AndRelation(
							fSQL.Comparison("UID_Application", e.New.String, ValType.String, CompareOperator.Equal, FormatterOptions.None),
							fSQL.Comparison("IsProfileApplication", false, ValType.Bool));

					// Die zugewiesene Applikation ist keine ProfilApplikation
					if (DbObject.Connection.Exists("Application", strWhereClause))
					{
						throw new ViException(881106, ExceptionRelevance.EndUser);
					}
				}
			}
		}

		private void UID_Application_ValueSet(object sender, ColumnEventArgs e)
		{
			using (NoRightsCheck())
			{
				if (DbObject["UID_Application"].Old.String != e.New.String)
				{
					SetValue("UpdateProfileVII", true);
					SetValue("UpdatePathVII", true);
				}
			}
		}

		/// <summary>
		/// hat sich der Wert der Spalte geändert, wird UpdateProfileVII auf TRUE gesetzt
		/// </summary>
		private void UpdateProfileVII_ValueSet(object sender, ColumnEventArgs e)
		{
			if (String.IsNullOrEmpty(e.Column.Columnname))
			{
				return;
			}

			using (NoRightsCheck())
			{
				switch (e.Column.ColDef.Type)
				{
					case ValType.Binary:

						if (DbObject[e.Column.Columnname].Old.Binary != e.New.Binary)
						{
							SetValue("UpdateProfileVII", true);
						}

						break;

					case ValType.Bool:

						if (DbObject[e.Column.Columnname].Old.Bool != e.New.Bool)
						{
							SetValue("UpdateProfileVII", true);
						}

						break;

					case ValType.Date:

						if (DbObject[e.Column.Columnname].Old.Date != e.New.Date)
						{
							SetValue("UpdateProfileVII", true);
						}

						break;

					case ValType.Decimal:

						if (DbObject[e.Column.Columnname].Old.Decimal != e.New.Decimal)
						{
							SetValue("UpdateProfileVII", true);
						}

						break;

					case ValType.Double:

						if (DbObject[e.Column.Columnname].Old.Double != e.New.Double)
						{
							SetValue("UpdateProfileVII", true);
						}

						break;

					case ValType.Int:

						if (DbObject[e.Column.Columnname].Old.Int != e.New.Int)
						{
							SetValue("UpdateProfileVII", true);
						}

						break;

					case ValType.Long:

						if (DbObject[e.Column.Columnname].Old.Long != e.New.Long)
						{
							SetValue("UpdateProfileVII", true);
						}

						break;

					default: //ValType.String

						if (DbObject[e.Column.Columnname].Old.String != e.New.String)
						{
							SetValue("UpdateProfileVII", true);
						}

						break;
				}
			}
		}


		/// <summary>
		/// hat sich der Wert der Spalte geändert, wird UpdatePathVII auf TRUE gesetzt
		/// </summary>
		private void UpdatePathVII_ValueSet(object sender, ColumnEventArgs e)
		{
			using (NoRightsCheck())
			{
				if (DbVal.Compare(e.OldValue, e.NewValue, e.Column.ColDef.Type) != 0)
					SetValue("UpdatePathVII", true);
			}
		}

		#endregion

		#region Public NoCustom methods

		/// <summary>
		/// The method is called by Customizer for generation of events.
		/// </summary>
		/// <remarks>The parameters "ProfileCUA_Ident_InstTypeAlso" and "ProfileCUA_Ident_OSAlso" will be added to the parameter collection.
		/// </remarks>
		/// <param name="eventName">INSERT, UPDATE, DELETE</param>
		/// <returns>Always False</returns>
		protected override bool OnCustomGenerate(String eventName)
		{
			IColDbObject colChild;
			ISingleDbObject oProfileCUA;
			Hashtable param = new Hashtable(StringComparer.OrdinalIgnoreCase);
			long ulCo = 0;

			using (NoRightsCheck())
			{
				colChild = DbObject.GetCR("ProfileCanUsedAlso", "UID_Profile").Children;

				foreach (IColElem colElem in colChild)
				{
					oProfileCUA = colElem.Create();
					param.Add("ProfileCUA_Ident_InstTypeAlso" + ulCo.ToString(), oProfileCUA["Ident_InstTypeAlso"].New.String);
					param.Add("ProfileCUA_Ident_OSAlso" + ulCo.ToString(), oProfileCUA["Ident_OSAlso"].New.String);
					ulCo++;
				}

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
		/// Copy all required properties from the given object to this <c>Applicationprofile</c>.
		/// </summary>
		/// <remarks>
		/// Custom schema extensions will no be copied.
		/// </remarks>
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
				SetValue("Ident_OS", oOther["Ident_OS"].New.String);
				SetValue("Ident_InstType", oOther["Ident_InstType"].New.String);
				SetValue("Description", oOther["Description"].New.String);
				SetValue("ChgNumber", oOther["ChgNumber"].New.Int);
				SetValue("SubPath", oOther["SubPath"].New.String);
				SetValue("OrderNumber", oOther["OrderNumber"].New.Double);
				SetValue("ServerDrive", oOther["ServerDrive"].New.String);
				SetValue("DefDriveTarget", oOther["DefDriveTarget"].New.String);
				SetValue("OSMode", oOther["OSMode"].New.String);
				SetValue("MemoryUsage", oOther["MemoryUsage"].New.String);
				SetValue("ChgTest", oOther["ChgTest"].New.Int);
				SetValue("ClientStepCounter", oOther["ClientStepCounter"].New.Int);
				SetValue("Ident_DomainRDOwner", oOther["Ident_DomainRDOwner"].New.String);
				SetValue("ProfileType", oOther["ProfileType"].New.String);
				SetValue("UID_Application", oOther["UID_Application"].New.String);
				SetValue("ChgCL", oOther["ChgCL"].New.Int);
				SetValue("DisplayName", oOther["DisplayName"].New.String);
				SetValue("RemoveHKeyCurrentUser", oOther["RemoveHKeyCurrentUser"].New.String);

				SetValue("UID_OS", oOther["UID_OS"].New.String);
				SetValue("UID_InstallationType", oOther["UID_InstallationType"].New.String);
				SetValue("UID_SDLDomainRD", oOther["UID_SDLDomainRD"].New.String);
				SetValue("UID_SDLDomainRDOwner", oOther["UID_SDLDomainRDOwner"].New.String);

				// TODO: Check this! can we write this property ???
				if (DbObject["PackagePath"].CanEdit)
				{
					SetValue("PackagePath", oOther["PackagePath"].New.String);
				}
			}
			return true;
		}


		#endregion

		#region Custom methods

		/// <summary>
		/// Returns the path of this <c>ApplicationProfile</c>
		/// </summary>
		/// <remarks>
		/// The path will be computed <see cref="Domain.GetNetPath"/> + <c>ClientPartApps</c> + <c>SubPath</c>.
		/// </remarks>>
		/// <param name="DoForTAS">
		/// true ... DoForTas
		/// false ... DoForFDS
		/// </param>
		/// <returns>Fullpath for this <c>ApplicationProfile</c></returns>
		/// <exception cref="ViException">Error number:<b>881146</b><para>The foreign key '{0}' is invalid.</para></exception>
		/// <exception cref="ViException">Error number:<b>881150</b><para>Processing failed because there is no customizer defined for object of type {0}.</para></exception>
		[CustomMethod(false)]
		[Description("Method_ApplicationProfile_GetProfilePathClient")]
		public string GetProfilePathClient(bool DoForTAS)
		{
			string strProfPath = "";
			ISingleDbObject oDomain;

			using (NoRightsCheck())
			{
				if (String.IsNullOrEmpty(DbObject["Ident_DomainRD"].New.String))
				{
					throw new ViException(881146, ExceptionRelevance.EndUser, "Ident_DomainRD");
				}

				oDomain = DbObject.GetFK("Ident_DomainRD").Create();

				if (null == oDomain.Custom)
				{
					throw new ViException(881150, ExceptionRelevance.EndUser, "Domain");
				}

				strProfPath = (string) oDomain.Custom.CallMethod("GetNetPath", DoForTAS);

				if (!String.IsNullOrEmpty(strProfPath))
				{
					strProfPath += String.Concat(@"\", oDomain["ClientPartApps"].New.String, @"\", DbObject["SubPath"].New.String);
				}
			}

			return strProfPath;
		}

		/// <summary>
		/// Profile path on server
		/// </summary>
		/// <remarks>
		/// The path will be computed <see cref="Domain.GetTASName"/> + <c>ServerPartShareOn...TAS/Servers</c> + <c>SubPath</c>.
		/// </remarks>
		/// <param name="DoForTAS">
		/// <c>true</c> -> DoForTas
		/// <c>false</c> -> DoForFDS
		/// </param>
		/// <returns></returns>
		/// <exception cref="ViException">Error number:<b>881146</b><para>The foreign key '{0}' is invalid.</para></exception>
		/// <exception cref="ViException">Error number:<b>881150</b><para>Processing failed because there is no customizer defined for object of type {0}.</para></exception>
		[CustomMethod(false)]
		[Description("Method_ApplicationProfile_GetProfilePathServer")]
		public string GetProfilePathServer(bool DoForTAS)
		{
			string strProfPath = "";

			using (NoRightsCheck())
			{
				if (String.IsNullOrEmpty(DbObject["Ident_DomainRD"].New.String))
				{
					throw new ViException(881146, ExceptionRelevance.EndUser, "Ident_DomainRD");
				}

				ISingleDbObject dbDomain = DbObject.GetFK("Ident_DomainRD").Create();

				if (DoForTAS)
				{
					string strTAS = (string) dbDomain.Custom.CallMethod("GetTASName");

					if (String.IsNullOrEmpty(strTAS))
					{
						return String.Empty;
					}

					strProfPath = String.Concat(@"\\", strTAS, @"\", dbDomain["ServerPartShareOnTAS"].New.String, @"\", DbObject["SubPath"].New.String);
				}
				else
				{
					strProfPath = String.Concat(dbDomain["ServerPartShareOnServers"].New.String, @"\", DbObject["SubPath"].New.String);
				}
			}

			return strProfPath;
		}

		/// <summary>
		/// Count the lines in the MacFiles.VIP, MacReg.VIP, UsrFiles.VIP and UsrReg.VIP and put the result in in property <c>ClientStepCounter</c>.
		/// </summary>
		//[CustomDisplayMethod("strMethodDisplay881002",false)]
		[CustomMethod(false)]
		[Description("Method_ApplicationProfile_UpdateOfClientStepCounter")]
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
		[Description("Method_ApplicationProfile_WriteVIIFiles")]
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
		/// Enable this <c>ApplicationProfile</c> for all valid ressource domains.
		/// </summary>
		[CustomMethod(false)]
		[Description("Method_ApplicationProfile_AllowUsageAllRDs")]
		public void AllowUsageAllRDs()
		{
			using (NoRightsCheck())
			{
				ModProfile.AllowUsageAllRDs(DbObject);
			}
		}


		/// <summary>
		/// Return ClientPath for the central library
		/// </summary>
		/// <returns></returns>
		[CustomMethod(false)]
		[Description("Method_ApplicationProfile_GetCLProfilePathClient")]
		public string GetCLProfilePathClient()
		{
			string strProfPath;
			ISingleDbObject oDomain;

			using (NoRightsCheck())
			{
				oDomain = ModProfile.GetCLDomain(DbObject);

				if (oDomain == null)
				{
					return String.Empty;
				}

				strProfPath = (string) oDomain.Custom.CallMethod( "GetNetPath", false);

				if (!String.IsNullOrEmpty(strProfPath))
				{
					strProfPath += String.Concat(@"\", oDomain["ClientPartApps"].New.String, @"\", DbObject["SubPath"].New.String);
				}
			}

			return strProfPath;
		}

		/// <summary>
		/// Generate a copy job for this application profile from start server(CL,FDS,TAS) to destination server (CL,FDS,TAS)
		/// </summary>
		/// <param name="CopyEvent">Valid copy events: CopyCL2FDS, CopyCL2TAS, CopyFDS2CL, CopyFDS2TAS, CopyTAS2FDS</param>
		/// <param name="argUID_SourceServer">UID source server</param>
		/// <param name="argUID_DestServer">UID destination server</param>
		/// <param name="StartTime">Start time</param>
		/// <param name="Ident_DestDomain">Destination domain</param>
		/// <param name="DoOffline">Copy offline</param>
		[CustomMethod(false)]
		[Description("Method_ApplicationProfile_SvrCopy")]
		public void SvrCopy(string CopyEvent, string argUID_SourceServer, string argUID_DestServer, DateTime StartTime, string Ident_DestDomain, bool DoOffline)
		{
			using (NoRightsCheck())
			{
				try
				{
					DbObject.Connection.Variables.Put("SvrCopy", true);

					//SvrCopy(ISingleDbObject oSrcProfile, string CopyEvent,	string UID_SourceServer, string UID_DestServer, DateTime StartTime, string Ident_DomainTo, bool DoOffline)
					ModProfile.SvrCopy(DbObject, CopyEvent, argUID_SourceServer, argUID_DestServer, StartTime, Ident_DestDomain, DoOffline);
				}
				finally
				{
					DbObject.Connection.Variables.Remove("SvrCopy");
				}

			}
		}

		#endregion

		#region Object Functions

		/// <exclude/>
		/// <summary>
		/// Nutzt die Hilfsklasse ModProfile zum Füllen der Spalte OsMode mit einem gültigen Wert
		/// </summary>
		/// <param name="osmode"></param>
		private void _Handle_OSMode_ValueChecking(string osmode)
		{
			using (NoRightsCheck())
			{
				ModProfile.CheckAndSetOSMode(DbObject, "OSMode", osmode);
			}
		}

		/// <exclude/>
		/// <summary>
		/// Spalteninitialisierung für neues Objekt
		/// </summary>
		private void _Handle_InitColumns()
		{
			/* #28523 Wird via template gelöst
			using (NoRightsCheck())
			{
				DbObject["OSMode"].New = new DbVal("AUTO");
				DbObject["ProfileDate"].New = new DbVal(m_InitDate);
			}
			*/
		}

		/// <exclude/>
		/// <summary>
		///
		/// </summary>
		private void _SetRightOrderNumber()
		{
			Double number = 0;
			ISqlFormatter fSQL = DbObject.Connection.SqlFormatter;
			//MSSQL:isnull(ordernumber, 0) = (Select MAX(ordernumber) from ApplicationProfile where (Ident_DomainRD = 'domainRD') and (UID_Profile <> '08e4d48f-0f3e-11d6-b1e8-00508b8f0145'))
			//Oracle:ordernumber = (SELECT MAX(ORDERNUMBER) FROM APPLICATIONPROFILE WHERE (UPPER(IDENT_DOMAINRD) = 'DOMAINRD') AND (UID_PROFILE <> '08e4d48f-0f3e-11d6-b1e8-00508b8f0145'))

			string strWhereClause = string.Format(
										DbObject.Connection.SqlStrings["AppProfile_MaxOrderNumber"],
										fSQL.Comparison("Ident_DomainRD", DbObject["Ident_DomainRD"].NewValue, ValType.String),
										fSQL.Comparison("UID_Profile", DbObject["UID_Profile"].NewValue, ValType.String, CompareOperator.NotEqual, FormatterOptions.None));


			number = DbObject.Connection.GetSingleProperty("ApplicationProfile", "OrderNumber", strWhereClause).Double;

			if (number < 10000)
			{
				number += 10000;
			}

			SetValue("OrderNumber", number + 1);
		}

		/// <exclude/>
		/// <summary>
		/// Es wird geprüft, ob zu der zu diesem Profil zugehörigen Applikation Profile vorhanden sind.
		/// Falls ja, wird das Flag IsProfileApplication in Application auf 1 gesetzt
		/// Falls nicht, wird das Flag IsProfileApplication in Application auf 0 gesetzt.
		/// </summary>
		private void _CheckIsProfileApplication()
		{
			IColDbObject colApplicationProfile = DbObject.Connection.CreateCol("ApplicationProfile"); ;
			ISqlFormatter fSQL = DbObject.Connection.SqlFormatter;

			// Objekt wurde gelöscht
			if (DbObject.IsDeleted)
			{
				// geloescht

				// gibt es noch andere Profile ???
				colApplicationProfile.Prototype.WhereClause =
					fSQL.AndRelation(fSQL.Comparison("UID_Application", DbObject["UID_Application"].New.String,
													  ValType.String, CompareOperator.Equal, FormatterOptions.None),
									  fSQL.Comparison("UID_Profile", DbObject["UID_Profile"].New.String,
													  ValType.String, CompareOperator.NotEqual, FormatterOptions.None)
									);

				// nein
				if (colApplicationProfile.DBCount == 0)
				{
					// exists the Application ( we are not in DeleteCascade )
					// This Check is required because the UID_Application is filled, but the Object is already deleted
					if (DbObject.Connection.Exists("Application", fSQL.Comparison("UID_Application", DbObject["UID_Application"].New.String,
													ValType.String, CompareOperator.Equal, FormatterOptions.None)))
					{
						// auf false setzen
						ISingleDbObject dbApplication = DbObject.GetFK("UID_Application").Create();

						if (dbApplication != null)
						{
							if (dbApplication["IsProfileApplication"].New.Bool == true)
							{
								dbApplication["IsProfileApplication"].NewValue = false;
								dbApplication.Save();
							}
						}
					}
				}
			}

			// Objekt wurde neu angelegt
			if (!DbObject.IsLoaded)
			{
				// Insert
				ISingleDbObject dbApplication = DbObject.GetFK("UID_Application").Create();

				if (dbApplication != null)
				{
					if (dbApplication["IsProfileApplication"].New.Bool == false)
					{
						dbApplication["IsProfileApplication"].NewValue = true;
						dbApplication.Save();
					}
				}
			}
		}

		/// <exclude/>
		/// <summary>
		/// Beschreibung: Es wird ein Eintrag in TroubleProduct für die Applikation vorgenommen.
		///  Ident_TroubleProduct = substring(NameFull, 1, 64)
		///  Description = substring(NameFull, 1, 64),
		///  SupportLevel = 1,
		///  IsInActive = 0.
		/// Voraussetzungen: der Configparm 'Helpdesk\AutoProduct\Application' ist gesetzt,
		/// für die Applikation gibt es noch keinen Eintrag in TroubleProduct  --> substring(application.NameFull, 1, 64) &lt;&gt; Ident_TroubleProduct,
		/// zu dieser Applikation gibt es mindestens ein Applikationsprofil.
		/// </summary>
		private void _HandleTroubleProduct()
		{
			ISqlFormatter fSQL = DbObject.Connection.SqlFormatter;

			TroubleProductHelper.HandleTroubleProduct(
				DbObject.Connection,
				"Application",
				DbObject.ObjectWalker.GetValue("FK(UID_Application).NameFull").String,
				null, null);
		}
		#endregion
	}


	/// <summary>
	/// EntityLogic for table <c>ApplicationProfile</c>
	/// </summary>
	internal class _ApplicationProfile : StateBasedEntityLogic
	{
		public _ApplicationProfile()
		{
			string[] vUpdateProfile =
			{
				"ChgNumber", "ChgTest", "ClientStepCounter", "MemoryUsage", "OSMode", "ServerDrive",
				"UID_Application"
			};

			foreach (string strColumn in vUpdateProfile)
			{
				Value("UpdateProfileVII")
					.From(strColumn, strColumn + "[o]")
					.As((object iNew, object iOld) => TryResult.FromResult(iNew != iOld, true));
			}

			string[] vUpdatePath = {"Ident_InstType", "Ident_OS", "SubPath", "UID_Application"};

			foreach (string strColumn in vUpdatePath)
			{
				Value("UpdatePathVII")
					.From(strColumn, strColumn + "[o]")
					.As((object iNew, object iOld) => TryResult.FromResult(iNew != iOld, true));
			}

			Value("UID_SDLDomainRDOwner")
				.From("UID_SDLDomainRD", "UID_SDLDomainRDOwner")
				.As((string uidSDLDomainRD, string uidSDLDomainRDOwner) =>
					TryResult.FromResult<string>(!String.IsNullOrEmpty(uidSDLDomainRD) && String.IsNullOrEmpty(uidSDLDomainRDOwner),
						uidSDLDomainRD));

			Check("OrderNumber")
				.As((double dOrderNumer) =>
				{
					if (dOrderNumer < 10000) throw new ViException(2116134, ExceptionRelevance.EndUser);
					if (dOrderNumer > 100000000)
						throw new ViException(2116126, ExceptionRelevance.EndUser, "OrderNumber", "100000000");
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

			Check("UID_Application")
				.AsExpensive<string>(_Check_UID_Application);

			RegisterMethod("Assign")
				.As<IValueProvider>(AssignAsync);

			RegisterFunction("GetProfilePathClient")
				.As<bool, string>(_GetProfilePathClient)
				.Description("Method_ApplicationProfile_GetProfilePathClient");

			RegisterMethod("WriteVIIFiles")
				.As(WriteViiFilesAsync)
				.Description("Method_ApplicationProfile_WriteVIIFiles")
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

		private static async Task<bool> _Check_UID_Application(ISession session, IEntity entity, string uidApplication, CancellationToken ct)
		{
			// do not check empty values
			if (String.IsNullOrEmpty(uidApplication))
				return true;

			Query qApplication = Query.From("Application")
				.Where( c => c.Column("UID_Application") == uidApplication)
				.Select("IsProfileApplication");

			bool isProfileApplication = await session.Source().GetSingleValueAsync<bool>(qApplication, ct).ConfigureAwait(false);

			if (!isProfileApplication)
				throw new ViException(2116106, ExceptionRelevance.EndUser);

			return true;
		}

		private static Task AssignAsync(ISession session, IEntity entity, IValueProvider vpSource, CancellationToken ct)
		{
			if (vpSource == null) throw new ArgumentNullException("vpSource");

			//nicht auf sich selbst
			if (vpSource == entity) throw new InvalidOperationException("Source can not be the same object.");

			entity.SetValue("Ident_DomainRD", vpSource.GetValue<string>("Ident_DomainRD"));
			entity.SetValue("Ident_OS", vpSource.GetValue<string>("Ident_OS"));
			entity.SetValue("Ident_InstType", vpSource.GetValue<string>("Ident_InstType"));
			entity.SetValue("Description", vpSource.GetValue<string>("Description"));
			entity.SetValue("ChgNumber", vpSource.GetValue<int>("ChgNumber"));
			entity.SetValue("SubPath", vpSource.GetValue<string>("SubPath"));
			entity.SetValue("OrderNumber", vpSource.GetValue<double>("OrderNumber"));
			entity.SetValue("ServerDrive", vpSource.GetValue<string>("ServerDrive"));
			entity.SetValue("DefDriveTarget", vpSource.GetValue<string>("DefDriveTarget"));
			entity.SetValue("OSMode", vpSource.GetValue<string>("OSMode"));
			entity.SetValue("MemoryUsage", vpSource.GetValue<string>("MemoryUsage"));
			entity.SetValue("ChgTest", vpSource.GetValue<int>("ChgTest"));
			entity.SetValue("ClientStepCounter", vpSource.GetValue<int>("ClientStepCounter"));
			entity.SetValue("Ident_DomainRDOwner", vpSource.GetValue<string>("Ident_DomainRDOwner"));
			entity.SetValue("ProfileType", vpSource.GetValue<string>("ProfileType"));
			entity.SetValue("UID_Application", vpSource.GetValue<string>("UID_Application"));
			entity.SetValue("ChgCL", vpSource.GetValue<int>("ChgCL"));
			entity.SetValue("DisplayName", vpSource.GetValue<string>("DisplayName"));
			entity.SetValue("RemoveHKeyCurrentUser", vpSource.GetValue<string>("RemoveHKeyCurrentUser"));
			entity.SetValue("UID_OS", vpSource.GetValue<string>("UID_OS"));
			entity.SetValue("UID_InstallationType", vpSource.GetValue<string>("UID_InstallationType"));
			entity.SetValue("UID_SDLDomainRD", vpSource.GetValue<string>("UID_SDLDomainRD"));
			entity.SetValue("UID_SDLDomainRDOwner", vpSource.GetValue<string>("UID_SDLDomainRDOwner"));

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

			if (! entity.IsLoaded &&
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
				.Where( c => c.Column("UID_Profile") == entity.GetValue<string>("UID_Profile"))
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

		private async Task _SetRightOrderNumber( LogicParameter lp)
		{
			ISqlFormatter fSQL = lp.SqlFormatter;

			string strWhereClause = SqlStrings.Format(lp.Session.Database().SystemIdentifier,
				"SDL_AppProfile_MaxOrderNumber",
				fSQL.AndRelation(
					fSQL.UidComparison("UID_SDLDomainRD", lp.Entity.GetValue<string>("UID_SDLDomainRD")),
					fSQL.UidComparison("UID_Profile", lp.Entity.GetValue<string>("UID_Profile"), CompareOperator.NotEqual)
					));

			// try to get the highest OrderNumber
			var trumber = await lp.Session.Source().TryGetSingleValueAsync<double>("ApplicationProfile", "OrderNumber", strWhereClause, lp.CancellationToken).ConfigureAwait(false);

			double number = trumber.Success ? trumber.Result : 0;

			if (number < 10000)
			{
				number += 10000;
			}

			lp.Entity.SetValue("OrderNumber", number + 1);
		}

		private Task _HandleTroubleProduct(LogicParameter lp)
		{
			return TroubleProductHelper.HandleTroubleProduct(lp,
				"Application",
				lp.ObjectWalker.GetValue<string>("FK(UID_Application).NameFull"),
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
				if (  ! await lp.Session.Source().ExistsAsync("ApplicationProfile", strWhereClause, lp.CancellationToken).ConfigureAwait(false) )
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
			if (! lp.Entity.IsLoaded)
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

		private async Task<string> _GetProfilePathClient(ISession session, IEntity entity, bool forTas, CancellationToken ct)
		{
			string strProfPath = "";

			IEntityForeignKey fkDomainRd = await entity.GetFkAsync(session, "UID_SDLDomainRD", ct).ConfigureAwait(false);

			if (fkDomainRd.IsEmpty())
			{
				throw new ViException(881146, ExceptionRelevance.EndUser, "Ident_DomainRD");
			}

			IEntity eDomain = await fkDomainRd.GetParentAsync(cancellationToken: ct).ConfigureAwait(false);

			strProfPath = (string) await eDomain.CallFunctionAsync("GetNetPath", forTas, ct).ConfigureAwait(false);

			if (!String.IsNullOrEmpty(strProfPath))
			{
				strProfPath += String.Concat(@"\", eDomain.GetValue("ClientPartApps"), @"\", entity.GetValue("SubPath"));
			}

			return strProfPath;
		}}
}
