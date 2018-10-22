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
using System.IO;
using VI.Base;
using VI.DB;
using VI.DB.JobGeneration;
using System.Diagnostics;
using System.Threading.Tasks;
using VI.DB.Compatibility;
using VI.DB.Entities;

namespace SDL.Customizer
{
	/// <exclude/>
	/// <summary>
	/// Helper class for ProfileModus
	/// </summary>
	internal class ModProfile
	{
		/// <exclude/>
		private enum ProfileType
		{
			ApplicationProfile,
			DriverProfile,
			MachineType
		}

		/// <summary>
		/// Konstruktor
		/// </summary>
		public ModProfile()
		{

		}

		#region Public static Functions

		/// <exclude/>
		/// <summary>
		/// Testet, ob der Wert gültig ist und setzt diesen
		/// genutzt in ApplicationProfile
		/// </summary>
		/// <param name="pProfile">zu testendes Profil</param>
		/// <param name="columnname">Spaltenname</param>
		/// <param name="newval">Wurde kein Wert eingetragen wird AUTO gesetzt.</param>
		public static void CheckAndSetOSMode(ISingleDbObject pProfile, string columnname, string newval)
		{
			newval = newval.Trim();
			newval = newval.ToUpperInvariant();

			if (String.IsNullOrEmpty(newval))
			{
				pProfile[columnname].NewValue = "AUTO";
			}
		}

		public static async Task IsUniqueAKProfile(QER.Customizer.LogicParameter lp)
		{
			String strTable = lp.Entity.Tablename.ToUpperInvariant();
			String strWhereClause = "";
			ISqlFormatter fSQL = lp.SqlFormatter;

			switch (strTable)
			{
				case "APPLICATIONPROFILE":
					strWhereClause = fSQL.AndRelation(
						fSQL.UidComparison("UID_Application", lp.Entity.GetValue<string>("UID_Application")),
						fSQL.UidComparison("UID_InstallationType", lp.Entity.GetValue<string>("UID_InstallationType")),
						fSQL.UidComparison("UID_OS", lp.Entity.GetValue<string>("UID_OS")),
						fSQL.UidComparison("UID_SDLDomainRD", lp.Entity.GetValue<string>("UID_SDLDomainRD")));

					// Für die zugewiesene Applikation existiert schon ein Profil
					if ( await lp.Session.Source().ExistsAsync("ApplicationProfile", strWhereClause, lp.CancellationToken).ConfigureAwait(false))
					{
						throw new ViException(2116136, ExceptionRelevance.EndUser, 
							await lp.Entity.Columns["UID_OS"].GetDisplayValueAsync( lp.Session, lp.CancellationToken).ConfigureAwait(false),
							await lp.Entity.Columns["UID_InstallationType"].GetDisplayValueAsync( lp.Session, lp.CancellationToken).ConfigureAwait(false),
							await lp.Entity.Columns["UID_SDLDomainRD"].GetDisplayValueAsync( lp.Session, lp.CancellationToken).ConfigureAwait(false) );
					}

					break;

				case "DRIVERPROFILE":
					strWhereClause = fSQL.AndRelation(
						fSQL.UidComparison("UID_Driver", lp.Entity.GetValue<string>("UID_Driver")),
						fSQL.UidComparison("UID_SDLDomainRD", lp.Entity.GetValue<string>("UID_SDLDomainRD")));

					if ( await lp.Session.Source().ExistsAsync("DriverProfile", strWhereClause, lp.CancellationToken).ConfigureAwait(false))
					{
						throw new ViException(2116137, ExceptionRelevance.EndUser, 
							await lp.Entity.Columns["UID_SDLDomainRD"].GetDisplayValueAsync( lp.Session, lp.CancellationToken).ConfigureAwait(false));
					}

					break;

				default:
					throw new ViException(2116138, ExceptionRelevance.EndUser, strTable);
			}
		}

		/// <exclude/>
		/// <summary>
		/// Zählt der ClientStepCounter entsprechend der Anzahl der Zeilen in div. .vip-Dateien hoch
		/// </summary>
		public static void UpdateOfClientStepCounter(ISingleDbObject oProfile)
		{
			bool bIsAppProf = "APPLICATIONPROFILE" == oProfile.Tablename.ToUpperInvariant();
			string strFileName = "", netPath = "", clientPart = "";
			long lCountAll = 0;
			ISingleDbObject oDomain;

			oDomain = oProfile.GetFK("UID_SDLDomainRD").Create();

			netPath = oDomain.Custom.CallMethod("GetNetPath", false).ToString();

			if (bIsAppProf)
			{
				clientPart = oDomain.GetValue<string>("ClientPartApps");
			}
			else
			{
				clientPart = oDomain.GetValue<string>("ClientPartDriver");
			}

			strFileName = Path.Combine(netPath, clientPart);
			strFileName = Path.Combine(strFileName, oProfile.GetValue<string>("SUBPATH"));
			// recount Files

			lCountAll = LineCount(Path.Combine(strFileName, "macfiles.vip"));

			if (bIsAppProf)
			{
				lCountAll += LineCount( Path.Combine(strFileName, "usrfiles.vip"));
			}

			// recount registrysteps

			lCountAll += LineCount(  Path.Combine(strFileName, "macreg.vip"));

			if (bIsAppProf)
			{
				lCountAll += LineCount( Path.Combine(strFileName, "usrreg.vip"));
			}

			oProfile["ClientStepCounter"].NewValue = lCountAll;
		}

		/// <exclude/>
		/// <summary>
		/// Zählt die Anzahl der Zeilen in einer Datei
		/// </summary>
		/// <param name="strFileName">Name der Datei, in der gezählt werden soll</param>
		/// <returns>Zeilenzahl</returns>
		public static long LineCount(string strFileName)
		{
			long anz = 0;

			if (File.Exists(strFileName))
			{
				using (StreamReader sr = new StreamReader(strFileName))
				{
					while (sr.Peek() != -1)
					{
						anz++;
						sr.ReadLine();
					}
				}
			}

			return anz;
		}

		/// <summary>
		/// Generate a process to write the VII-Files for a profile.
		/// </summary>
		/// <param name="oProfile">Application- or Driverprofil</param>
		public static void WriteVIIFiles(ISingleDbObject oProfile)
		{
			IColDbObject colInstallationType;
			ISingleDbObject dbInstallationType;
			IColDbObject colProfileCanUsedAlso;
			ISingleDbObject oProfileCUA;
			Hashtable param = new Hashtable(StringComparer.OrdinalIgnoreCase);
			int anz = 0;

			if (oProfile.Tablename.ToUpperInvariant() == "APPLICATIONPROFILE")
			{
				colProfileCanUsedAlso = oProfile.GetCR("ProfileCanUsedAlso", "UID_Profile").Children;

				foreach (IColElem ColElem in colProfileCanUsedAlso)
				{
					oProfileCUA = ColElem.Create();
					param.Add("ProfileCUA_Ident_InstTypeAlso" + anz.ToString(), oProfileCUA.GetValue<string>("Ident_InstTypeAlso"));
					param.Add("ProfileCUA_Ident_OSAlso" + anz.ToString(), oProfileCUA.GetValue<string>("Ident_OSAlso"));
					anz++;
				}
			}
			else
			{
				colInstallationType = oProfile.Connection.CreateCol("InstallationType");
				colInstallationType.PrepareBulkLoad();
				colInstallationType.Load();

				foreach (IColElem ColElem in colInstallationType)
				{
					dbInstallationType = ColElem.Create();
					param.Add("InstType" + anz.ToString(), dbInstallationType.GetValue<string>("Ident_InstType"));
					anz++;
				}
			}

			if (oProfile.GetValue<string>("MemoryUsage").Length > 0)
			{
				JobGen.Generate(oProfile, "VIIFiles", param);
			}
			else
			{
				throw new ViException(2116063, ExceptionRelevance.EndUser);
			}
		}

		/// <summary>
		/// Generate a process to delete the profile on the server
		/// </summary>
		/// <param name="oProfile"> Profile to delete</param>
		/// <param name="DelEvent">JobEvent</param>
		/// <param name="UID_Server">Server</param>
		public static void DeleteOn(ISingleDbObject oProfile, string DelEvent, string UID_Server)
		{
			Hashtable param = new Hashtable(StringComparer.OrdinalIgnoreCase);

			if (UID_Server.Length > 0)
			{
				param.Add("UID_Server", UID_Server);
				JobGen.Generate(oProfile, DelEvent, param);
			}
			else
			{
				JobGen.Generate(oProfile, DelEvent);
			}
		}

		/// <exclude/>
		/// <summary>
		/// Stellt einen Job ein zum Kopiert eines Treiberprofils, eines Applikationsprofiles oder eines MachineTypes
		/// von einem StartServer(CL,FDS,TAS) zu einem Zielserver (CL,FDS,TAS) ein
		/// </summary>
		/// <param name="oSrcProfile">Profil, welches kopiert werden soll.</param>
		/// <param name="CopyEvent">Bestimmt das Kopierereignis: mgl.Werte z.Z. CopyCL2FDS, CopyCL2TAS, CopyFDS2CL, CopyFDS2TAS, CopyTAS2FDS</param>
		/// <param name="UID_SourceServer">Quellserver</param>
		/// <param name="UID_DestServer">Zielserver</param>
		/// <param name="StartTime">Startzeit der Jobkette</param>
		/// <param name="Ident_DomainTo">Zieldomäne</param>
		/// <param name="DoOffline">OffLine ausführen</param>
		public static void SvrCopy(ISingleDbObject oSrcProfile, string CopyEvent, string UID_SourceServer, string UID_DestServer, DateTime StartTime, string Ident_DomainTo, bool DoOffline)
		{
			bool			bToCL = false;

			Hashtable param = new Hashtable(StringComparer.OrdinalIgnoreCase);

			ISingleDbObject	oGeneratorProfile	= oSrcProfile; // Profile used for the job generation
			ISingleDbObject	oCLDomain			= null;
			ISingleDbObject	dbDestProfile		= null;
			ISingleDbObject	oObj;		//Element in foreach
			ISingleDbObject	oRootAppS;
			IColDbObject	colListProfiles;
			IColDbObject	colCanUsedByRD;
			IColDbObject	colRootAppS;
			string			strCopyEvent;
			string			strDomainFrom		= null;
			string			strWhereClause;
			string			strUID_SourceServer	= UID_SourceServer;
			string			strUID_DestServer	= UID_DestServer;
			string			strDomainTo			= Ident_DomainTo;
			ProfileType		tpProfile;

			long			zae = 0;

			/*	The profile object and a copy event definition must be there
			 *	to perform a copy operation.
			 */

			if ( oSrcProfile == null ||  String.IsNullOrEmpty(CopyEvent))
				return;

			ISqlFormatter f  = oSrcProfile.Connection.SqlFormatter;

			switch ( oSrcProfile.Tablename.ToUpperInvariant() )
			{
				case "APPLICATIONPROFILE":
					tpProfile = ProfileType.ApplicationProfile;
					break;

				case "DRIVERPROFILE":
					tpProfile = ProfileType.DriverProfile;
					break;

				case "MACHINETYPE":
					tpProfile = ProfileType.MachineType;
					break;

				default:
					throw new ViException(999999, ExceptionRelevance.Technical, "ProfileType " + oSrcProfile.Tablename);
			}

#if DEBUG

			switch ( tpProfile )
			{
				case ProfileType.ApplicationProfile:
				case ProfileType.DriverProfile:
					Trace.WriteLine("UID_Profile: " + oSrcProfile.GetValue<string>("UID_PROFILE") + ", Ident_DomainRD: " + oSrcProfile.GetValue<string>("IDENT_DOMAINRD") + " of source profile.");
					break;

				case ProfileType.MachineType:
					Trace.WriteLine("Ident_MachineType: <" + oSrcProfile.GetValue<string>("IDENT_MACHINETYPE") + ">, Ident_DomainMachineType: <" + oSrcProfile.GetValue<string>("IDENT_DOMAINMACHINETYPE") + "> of source machinetype.");
					break;
			}

#endif

			// Was it updated?
			if (oSrcProfile.IsChanged)
			{
				// Zwischenspeichern
				oSrcProfile.Save();
				oSrcProfile.Load();
			}

			// Cut leading and trailing spaces from our event definition
			strCopyEvent = CopyEvent.Trim();

			switch ( tpProfile )
			{
				case ProfileType.ApplicationProfile:
				case ProfileType.DriverProfile:
					#region Copy Profiles

					// ---------------- copy Profiles -----------------------------
					strDomainFrom = oSrcProfile.GetValue<string>("IDENT_DOMAINRD");

					// Get values for unknown FDS
					_CompleteUnknownFDS( oSrcProfile, strCopyEvent, ref strUID_SourceServer, ref strUID_DestServer, strDomainFrom, ref strDomainTo  );

					if (strCopyEvent.IndexOf("CL", StringComparison.OrdinalIgnoreCase) >= 0)
					{
						#region From/To CL

						// intialize strUID_DestServer with CL of Domain
						strUID_DestServer = GetCLServer(oSrcProfile);

						// --- copy events from/to CL ---

						/*
							*	Special check for copy operations between CL and FDS.
							*	These must be in different domains or else the profile
							*	would be copied on itself.
							*/

						//	CL --> FDS
						if ( string.Equals(strCopyEvent, "COPYCL2FDS", StringComparison.OrdinalIgnoreCase) )
						{
							if ( String.IsNullOrEmpty(Ident_DomainTo))
							{
								throw new ViException(2116059, ExceptionRelevance.EndUser);
							}

							if ( string.Equals( oSrcProfile.GetValue<string>("IDENT_DOMAINRD"),
												Ident_DomainTo, StringComparison.OrdinalIgnoreCase) )
							{
								throw new ViException(2116039, ExceptionRelevance.EndUser);
							}
						}

						// FDS --> CL
						if ( string.Equals(strCopyEvent, "COPYFDS2CL", StringComparison.OrdinalIgnoreCase))
						{
							oCLDomain = GetCLDomain(oSrcProfile);

							if (null == oCLDomain)
							{
								throw new ViException(2116037, ExceptionRelevance.EndUser);
							}

							if ( string.Equals(oSrcProfile.GetValue<string>("Ident_DomainRD"),
											   oCLDomain.GetValue<string>("Ident_Domain"), StringComparison.OrdinalIgnoreCase) )
							{
								throw new ViException(2116039, ExceptionRelevance.EndUser);
							}
						}

						// FDS --> CL + fill ProfileCanUsedByRD/DriverCanUsedByRD for all RDs
						if ( (string.Equals(strCopyEvent, "COPYFDS2CL_USEDBYAllRDS", StringComparison.OrdinalIgnoreCase)) ||
							 (string.Equals(strCopyEvent, "COPYFDS2CL_FDS_USEDBYAllRDS", StringComparison.OrdinalIgnoreCase)) )
						{
							oCLDomain = GetCLDomain(oSrcProfile);

							if (null == oCLDomain)
							{
								throw new ViException(2116037, ExceptionRelevance.EndUser);
							}

							if ( string.Equals( oSrcProfile.GetValue<string>("Ident_DomainRD"),
												oCLDomain.GetValue<string>("Ident_Domain"), StringComparison.OrdinalIgnoreCase))
							{
								throw new ViException(2116039, ExceptionRelevance.EndUser);
							}
						}


						//von CL
						string strtmp = strCopyEvent.Substring(0, 6);
						strtmp = strtmp.ToUpperInvariant();

						if (strtmp == "COPYCL")
						{
							bToCL = false;

							// Domain must be given
							if (String.IsNullOrEmpty(Ident_DomainTo))
							{
								throw new ViException(2116059, ExceptionRelevance.EndUser);
							}

							strDomainTo = Ident_DomainTo;

							if (!_CopyIsAllowed(oSrcProfile, strDomainTo))
							{
								throw new ViException(2116041, ExceptionRelevance.EndUser, strDomainTo);
							}
						}
						else
						{
							//	To CL
							bToCL = true;

							if (null == oCLDomain)
							{
								oCLDomain = GetCLDomain(oSrcProfile);

								if (null == oCLDomain)
								{
									throw new ViException(2116037, ExceptionRelevance.EndUser);
								}
							}

							strDomainTo = oCLDomain.GetValue<string>("Ident_Domain");
						}

						//	Get the corresponding profile in the other domain
						if ( tpProfile == ProfileType.ApplicationProfile )
						{
							colListProfiles = oSrcProfile.Connection.CreateCol("ApplicationProfile");
							strWhereClause = f.UidComparison("UID_APPLICATION", oSrcProfile.GetValue<string>("UID_Application")) + " and " +
											 f.Comparison("IDENT_INSTTYPE", oSrcProfile.GetValue<string>("IDENT_INSTTYPE"), ValType.String) + " and " +
											 f.Comparison("IDENT_OS", oSrcProfile.GetValue<string>("IDENT_OS"), ValType.String) + " and " +
											 f.Comparison("IDENT_DOMAINRD", strDomainTo, ValType.String);
						}
						else
						{
							colListProfiles = oSrcProfile.Connection.CreateCol("DriverProfile");
							strWhereClause = f.UidComparison("UID_DRIVER", oSrcProfile.GetValue<string>("UID_DRIVER")) + " and " +
											 f.Comparison("IDENT_DOMAINRD", strDomainTo, ValType.String);

						}

						colListProfiles.Prototype.WhereClause = strWhereClause;
						colListProfiles.PrepareBulkLoad();
						colListProfiles.Load();

						//	There is no profile?
						if (0 == colListProfiles.Count)
						{
							//	Then create one...
							if ( tpProfile == ProfileType.ApplicationProfile )
							{
								// Create application profile
								dbDestProfile = oSrcProfile.Connection.CreateSingle("ApplicationProfile");

								// copy all required properties of the source profile
								dbDestProfile.Custom.CallMethod("Assign", oSrcProfile);

								dbDestProfile["UID_SDLDomainRD"].NewValue = _IdentDomainToUid(oSrcProfile.Connection, strDomainTo);
								dbDestProfile["UID_SDLDomainRDOwner"].NewValue = oSrcProfile.GetValue<string>("UID_SDLDomainRD");

								//Set the change numbers to zero (only xxx --> CL)
								if (bToCL)
								{
									dbDestProfile["ChgCL"].NewValue = 0;
								}

								dbDestProfile["ChgNumber"].NewValue = 0;
								dbDestProfile["ChgTest"].NewValue = 0;

								dbDestProfile.Save();
								dbDestProfile.Load();
							}
							else
							{
								// Create driver profile
								dbDestProfile = oSrcProfile.Connection.CreateSingle("DriverProfile");

								// copy all required properties of the source profile
								dbDestProfile.Custom.CallMethod("Assign", oSrcProfile);

								dbDestProfile["UID_SDLDomainRD"].NewValue = _IdentDomainToUid(oSrcProfile.Connection, strDomainTo);
								dbDestProfile["UID_SDLDomainRDOwner"].NewValue = oSrcProfile.GetValue<string>("UID_SDLDomainRD");

								//	Set the change numbers to zero (only xxx --> CL)
								if (bToCL)
								{
									dbDestProfile["ChgCL"].NewValue = 0;
								}

								dbDestProfile["ChgNumber"].NewValue = 0;
								dbDestProfile["ChgTest"].NewValue = 0;

								dbDestProfile.Save();
								dbDestProfile.Load();
							}
						}
						else //count >0
						{
							//The profile exists already
							/*
								*	Get the corresponding object
								*	VERY redundant!!!
								*/

							// Create it
							dbDestProfile = colListProfiles[0].Create();

							Trace.WriteLine ("UID_Profile: <" + dbDestProfile.GetValue<string>("UID_PROFILE") + ">, Ident_DomainRD: <" + dbDestProfile.GetValue<string>("IDENT_DOMAINRD") + "> of master profile.");

							if (bToCL)
							{
								if (dbDestProfile.GetValue<string>("Ident_DomainRDOwner").ToUpperInvariant() != oSrcProfile.GetValue<string>("Ident_DomainRD").ToUpperInvariant())
								{
									throw new ViException(2116038, ExceptionRelevance.EndUser, dbDestProfile.GetValue<string>("Ident_DomainRDOwner"), oSrcProfile.GetValue<string>("Ident_DomainRD") );
								}
							}

							// Copy relevant data to this profile
							if ( tpProfile == ProfileType.ApplicationProfile )
							{
								CopyIfAllowed( "ServerDrive" , oSrcProfile , dbDestProfile );
								CopyIfAllowed( "UID_OS" , oSrcProfile , dbDestProfile );
							}

							dbDestProfile["SubPath"].NewValue =  oSrcProfile.GetValue<string>("SubPath");
							dbDestProfile["OrderNumber"].NewValue =  oSrcProfile["OrderNumber"].New.Double;
							dbDestProfile["DefDriveTarget"].NewValue =  oSrcProfile.GetValue<string>("DefDriveTarget");
							dbDestProfile["OSMode"].NewValue =  oSrcProfile.GetValue<string>("OSMode");
							dbDestProfile["MemoryUsage"].NewValue =  oSrcProfile.GetValue<string>("MemoryUsage");
							dbDestProfile["ClientStepCounter"].NewValue =  oSrcProfile.GetValue<int>("ClientStepCounter");
							dbDestProfile["ProfileCreator"].NewValue =  oSrcProfile.GetValue<string>("ProfileCreator");
							dbDestProfile["ProfileDate"].NewValue =  oSrcProfile.GetValue<DateTime>("ProfileDate");
							dbDestProfile["ProfileModifier"].NewValue =  oSrcProfile.GetValue<string>("ProfileModifier");
							dbDestProfile["ProfileModDate"].NewValue =  oSrcProfile.GetValue<DateTime>("ProfileModDate");
							dbDestProfile["Description"].NewValue = oSrcProfile.GetValue<string>("Description");
							dbDestProfile["HashValueFDS"].NewValue = oSrcProfile.GetValue<string>("HashValueFDS");
							dbDestProfile["HashValueTAS"].NewValue = oSrcProfile.GetValue<string>("HashValueTAS");
							dbDestProfile["ProfileType"].NewValue = oSrcProfile.GetValue<string>("ProfileType");
							dbDestProfile["RemoveHKeyCurrentUser"].NewValue = oSrcProfile.GetValue<string>("RemoveHKeyCurrentUser");

							// can we write this property ???
							CopyIfAllowed( "PackagePath" , oSrcProfile , dbDestProfile );

							// And save it
							if (dbDestProfile.IsChanged)
							{
								// Then save it
								dbDestProfile.Save();
								dbDestProfile.Load();
							}
						}

						//	Set the profile which is used for job generation
						oGeneratorProfile = dbDestProfile;

						// Apps-Profiles copy Aliases ? ( SZ 21.06.2001 - Driverprofiles do not have Aliases ! )
						if ( tpProfile == ProfileType.ApplicationProfile )
						{
							//Copy aliases, came from down
							if (oSrcProfile.Connection.GetConfigParm(@"Software\SoftwareDistribution\Aliasing\CopyZBWithAlias") == "1")
							{
								_CopyAliases(oSrcProfile, oGeneratorProfile, strCopyEvent, strDomainTo);
							}
						}

						// --- end copy events from/to CL ---
						#endregion
					}

					IColDbObject colCanUsedAlso = oSrcProfile.Connection.CreateCol("ProfileCanUsedAlso");

					if ( tpProfile == ProfileType.ApplicationProfile )
					{
						#region ProfileCanUsedAlso Handling for AppProfiles
						// --> special for ParamCol

						colCanUsedAlso = oSrcProfile.Connection.CreateCol("ProfileCanUsedAlso");
						colCanUsedAlso.Prototype.WhereClause = f.UidComparison("UID_Profile", oGeneratorProfile.GetValue<string>("UID_Profile"));
						colCanUsedAlso.PrepareBulkLoad();
						colCanUsedAlso.Load();

						zae = 0;

						foreach (IColElem colElem in colCanUsedAlso)
						{
							oObj = colElem.Create();
							param.Add("ProfileCUA_Ident_InstTypeAlso" + zae.ToString(), oObj.GetValue<string>("Ident_InstTypeAlso"));
							param.Add("ProfileCUA_Ident_OSAlso" + zae.ToString(), oObj.GetValue<string>("Ident_OSAlso"));
							zae++;
						}

						// <-- special for ParamCol
						#endregion
					}
					else
					{
						#region InstallationType handling for DrvProfiles
						//* Write InstTypes as parameters

						// --> special for ParamCol
						colCanUsedAlso = oSrcProfile.Connection.CreateCol("InstallationType");
						colCanUsedAlso.PrepareBulkLoad();
						colCanUsedAlso.Load();
						// <-- special for ParamCol

						// --> special for ParamCol

						zae = 0;

						foreach (IColElem colElem in colCanUsedAlso)
						{
							oObj = colElem.Create();
							param.Add("InstType" + zae.ToString(), oObj.GetValue<string>("Ident_InstType"));
							zae++;
						}

						// <-- special for ParamCol
						#endregion
					}

					// Create parameters out of resultset entries
					//	Column: "Col" --> Parameter: "CL_Col"

					if (null != dbDestProfile)
					{
						// DESTIDENT_DOMAINRDOWNER
						param.Add("DESTIDENT_DOMAINRDOWNER", dbDestProfile.GetValue<string>("IDENT_DOMAINRDOWNER"));

						// DESTUID_PROFILE
						param.Add("DESTUID_PROFILE", dbDestProfile.GetValue<string>("UID_PROFILE"));
					}

					// Add parameter SRCUID_Profile
					param.Add("SRCUID_Profile", oSrcProfile.GetValue<string>("UID_PROFILE"));

					// ---------------- end copy Profiles -----------------------------
					#endregion
					break;

				case ProfileType.MachineType:
					#region Copy MacType

					// ---------------- copy MacType ----------------------------------

					// get the source-domain
					strDomainFrom = oSrcProfile.GetValue<string>("IDENT_DOMAINMACHINETYPE");
					// Get values for unknown FDS
					_CompleteUnknownFDS( oSrcProfile, strCopyEvent, ref strUID_SourceServer, ref strUID_DestServer, strDomainFrom, ref strDomainTo  );

					// Copy only from and to CL

					if (strCopyEvent.IndexOf("CL", StringComparison.OrdinalIgnoreCase) >= 0)
					{
						//	Special check for copy operations between CL and FDS.
						//	These must be in different domains or else the profile
						//	would be copied on itself.

						//	CL --> FDS
						if ( String.Compare(strCopyEvent, "COPYCL2FDS", StringComparison.OrdinalIgnoreCase) == 0 )
						{
							if ( String.IsNullOrEmpty(strDomainTo) )
							{
								throw new ViException(2116059, ExceptionRelevance.EndUser);
							}
						}

						// FDS --> CL
						if ( String.Compare(strCopyEvent, "COPYFDS2CL", StringComparison.OrdinalIgnoreCase) == 0 )
						{
							oCLDomain = GetCLDomain(oSrcProfile);

							if (null == oCLDomain)
							{
								throw new ViException(2116037, ExceptionRelevance.EndUser);
							}
						}

						// Find the destination domain
						string strtmp = strCopyEvent.Substring(0, 6);
						strtmp = strtmp.ToUpperInvariant();

						if (strtmp == "COPYCL")
						{
							//	From CL

							bToCL = false;

							// Domain must be given
							if ( String.IsNullOrEmpty(strDomainTo) )
							{
								throw new ViException(2116059, ExceptionRelevance.EndUser);
							}
						}
						else
						{
							//	To CL

							bToCL = true;

							if (null == oCLDomain)
							{
								oCLDomain = GetCLDomain(oSrcProfile);

								if (null == oCLDomain)
								{
									throw new ViException(2116037, ExceptionRelevance.EndUser);
								}
							}

							strDomainTo = oCLDomain.GetValue<string>("Ident_Domain");
						}

						// check of equal domain for machinetype-copy

						if (String.Compare(strDomainTo, strDomainFrom, StringComparison.OrdinalIgnoreCase) == 0)
						{
							throw new ViException(2116039, ExceptionRelevance.EndUser);
						}

						// Select Machine Type from destination domain

						strWhereClause = f.Comparison("IDENT_MACHINETYPE", oSrcProfile.GetValue<string>("IDENT_MACHINETYPE"), ValType.String) + " and " +
										 f.Comparison("IDENT_DOMAINMACHINETYPE", strDomainTo, ValType.String);

						if (!oSrcProfile.Connection.Exists("MachineType", strWhereClause))
						{
							// The machine type doesn't exit. Create one.
							dbDestProfile = oSrcProfile.Connection.CreateSingle("MachineType");

							// copy all required properties of the source profile
							dbDestProfile.Custom.CallMethod("Assign", oSrcProfile);

							dbDestProfile["Ident_DomainMachineType"].NewValue = strDomainTo;
							dbDestProfile["UID_SDLDomain"].NewValue = _IdentDomainToUid(oSrcProfile.Connection, strDomainTo);
							dbDestProfile.Save();
							dbDestProfile.Load();
						}
						else		// SZ 23.5.2001
						{
							// get the destinationobject
							dbDestProfile = oSrcProfile.Connection.CreateSingle("Machinetype");
							dbDestProfile["UID_MachineType"].NewValue = oSrcProfile.Connection.GetSingleProperty("MachineType", "UID_MachineType", strWhereClause);
							dbDestProfile["Ident_MachineType"].NewValue = oSrcProfile.GetValue<string>("Ident_MachineType");
							dbDestProfile["IDENT_DOMAINMACHINETYPE"].NewValue = strDomainTo;
							dbDestProfile["UID_SDLDomain"].NewValue = _IdentDomainToUid(oSrcProfile.Connection, strDomainTo);
							dbDestProfile.Load();

							// copy/update some properties
							dbDestProfile["BootImageWin"].NewValue = oSrcProfile.GetValue<string>("BootImageWin");
							dbDestProfile["Netcard"].NewValue = oSrcProfile.GetValue<string>("Netcard");
							dbDestProfile["GraphicCard"].NewValue = oSrcProfile.GetValue<string>("GraphicCard");

							// copy flag if posible
							if (dbDestProfile["MakeFullCopy"].CanEdit)
								dbDestProfile["MakeFullcopy"].NewValue = oSrcProfile.GetValue<bool>("MakeFullcopy");

							// And save it
							if (dbDestProfile.IsChanged)
							{
								dbDestProfile.Save();
								dbDestProfile.Load();
							}
						}

						// Set the machinetype which is used for job generation

						oGeneratorProfile = dbDestProfile;

						if (null != dbDestProfile)
						{

							// DESTIDENT_DOMAINMACHINETYPE
							param.Add("DESTIDENT_DOMAINMACHINETYPE", dbDestProfile.GetValue<string>("IDENT_DOMAINMACHINETYPE"));

							// DESTIdent_MachineType
							param.Add("DESTIDENT_MACHINETYPE", dbDestProfile.GetValue<string>("Ident_MachineType"));
						}

						// Add parameter SRCIdent_MachineType
						param.Add("SRCIDENT_MACHINETYPE", oSrcProfile.GetValue<string>("IDENT_MACHINETYPE"));

						// Add parameter SRCIDENT_DOMAINMACHINETYPE
						param.Add("SRCIDENT_DOMAINMACHINETYPE", oSrcProfile.GetValue<string>("IDENT_DOMAINMACHINETYPE"));
					}

					// ---------------- end copy MacType ------------------------------

					#endregion
					break;
			}

			// check server existence
			if ( ! _CheckServerExists( oSrcProfile, strCopyEvent, strDomainFrom, strDomainTo ))
				return;

			// *** special handling for "CopyCL2FDS_AllAllowed" (speedrelease)
			// *** raise "CopyCL2FDS" for all FDS
			// ***
			if (strCopyEvent.ToUpperInvariant() == "COPYCL2FDS_ALLALLOWED")
			{
				#region Speed Release

				if ( tpProfile == ProfileType.ApplicationProfile )
					colCanUsedByRD = oSrcProfile.Connection.CreateCol("ProfileCanUsedByRD");
				else
					colCanUsedByRD = oSrcProfile.Connection.CreateCol("DriverCanUsedByRD");


				strWhereClause = f.UidComparison("UID_PROFILE", oSrcProfile.GetValue<string>("UID_PROFILE"));
				colCanUsedByRD.Prototype.WhereClause = strWhereClause;
				colCanUsedByRD.PrepareBulkLoad();
				colCanUsedByRD.Load();

				foreach (IColElem colElem in colCanUsedByRD)
				{
					oObj = colElem.Create();

					colRootAppS = oSrcProfile.Connection.CreateCol("ApplicationServer");

					strWhereClause = f.EmptyClause("UID_ParentApplicationServer", ValType.String) + " and " +
									 f.Comparison("Ident_Domain", oObj.GetValue<string>("Ident_DomainAllowed"), ValType.String);
					colRootAppS.Prototype.WhereClause = strWhereClause;
					colRootAppS.PrepareBulkLoad();
					colRootAppS.Load();

					if (colRootAppS.Count > 0)
					{
						oRootAppS = colRootAppS[0].Create();

						try
						{
							SvrCopy(oSrcProfile, "CopyCL2FDS", UID_SourceServer,
									oRootAppS.GetValue<string>("UID_APPLICATIONSERVER"), StartTime,
									oRootAppS.GetValue<string>("IDENT_DOMAIN"), false);
						}
						catch (ViException ex)
						{
							throw new ViException(2116155, ExceptionRelevance.EndUser, ex.InnerException, strCopyEvent, "CopyCL2FDS", oRootAppS.GetValue<string>("IDENT_DOMAIN"));
						}

						return;
					}
				}

				#endregion
			}

			#region Add Params

			if ( ! String.IsNullOrEmpty(strUID_SourceServer) )
			{
				// Check if destination is a redirected server
				string where = f.AndRelation(
								   f.UidComparison("UID_Server", strUID_SourceServer),
								   f.Comparison("Ident_Domain", strDomainFrom, ValType.String ) );

				string strApplicationServerRedirect = oSrcProfile.Connection.GetSingleProperty("ApplicationServer", "UID_ApplicationServerRedirect", where);

				// With redirect of Source
				if ( ! String.IsNullOrEmpty(strApplicationServerRedirect) )
				{
					if ( (! String.IsNullOrEmpty(strUID_DestServer)) &&
						 string.Equals( strApplicationServerRedirect, strUID_DestServer, StringComparison.OrdinalIgnoreCase) )
					{
						throw new ViException(2116251, ExceptionRelevance.EndUser);
					}
				}

				// Add Parameter
				param.Add("UID_SourceServer", strUID_SourceServer);
			}

			if ( ! String.IsNullOrEmpty(strUID_DestServer) )
			{
				// TODO: Is this always set for FDS copies????

				// get destination is a redirected server
				string where = f.AndRelation(
								   f.UidComparison("UID_Server", strUID_DestServer),
								   f.Comparison("Ident_Domain", strDomainTo, ValType.String)
							   );

				string strApplicationServerRedirect = oSrcProfile.Connection.GetSingleProperty("ApplicationServer", "UID_ApplicationServerRedirect", where);

				// with redirect of destination
				if ( ! String.IsNullOrEmpty(strApplicationServerRedirect) )
				{
					// Destination is redirected
					if ( ! strCopyEvent.ToUpperInvariant().StartsWith("COPYCL") )
					{
						// Only CL is allowed to do so
						throw new ViException(2116168, ExceptionRelevance.EndUser);
					}

					if ( (! String.IsNullOrEmpty(strUID_SourceServer)) &&
						 string.Equals( strApplicationServerRedirect, strUID_SourceServer, StringComparison.OrdinalIgnoreCase) )
					{
						throw new ViException(2116251, ExceptionRelevance.EndUser);
					}
				}

				// Add Parameter
				param.Add("UID_DestServer", strUID_DestServer);
			}

			if (StartTime > DbVal.MinDate)
			{
				param.Add("__STARTTIME", StartTime);
			}

			param.Add("DoOffline", DoOffline);

			#endregion

			JobGen.Generate(oGeneratorProfile, CopyEvent, param);
		}

		private static string _IdentDomainToUid(IConnection connection, string identDomain)
		{
			ISqlFormatter fSql = connection.SqlFormatter;

			IColDbObject colDomain = connection.CreateCol("SDLDomain");
			colDomain.Prototype.WhereClause = fSql.UidComparison("Ident_Domain", identDomain);
			colDomain.Prototype["UID_SDLDomain"].IsDisplayItem = true;
			colDomain.Load();

			if (colDomain.Count < 1)
				return null;

			return colDomain[0].GetValue("UID_SDLDomain");
		}


		/// <exclude/>
		/// <summary>
		/// Gibt die Domäne der Zentralbibliothek zurück
		/// </summary>
		/// <param name="dbProfile"></param>
		/// <returns></returns>
		public static ISingleDbObject GetCLDomain(ISingleDbObject dbProfile)
		{
			string strWhereClause = dbProfile.Connection.SqlFormatter.Comparison("IsCentralLibrary", 1, ValType.Bool);
			string uidDomain = dbProfile.Connection.GetSingleProperty("ApplicationServer", "UID_SDLDomain", strWhereClause);
			ISingleDbObject dbDomain = null;

			if (! String.IsNullOrEmpty(uidDomain))
			{
				dbDomain = dbProfile.Connection.CreateSingle("SDLDomain", uidDomain);
			}

			return dbDomain;
		}

		/// <exclude/>
		/// <summary>
		/// Gibt die UID_ApplicationServer der Zentralbibliothek der Domain zurück
		/// </summary>
		/// <param name="oProfile"></param>
		/// <returns></returns>
		public static string GetCLServer(ISingleDbObject oProfile)
		{
			string strWhereClause = oProfile.Connection.SqlFormatter.Comparison("IsCentralLibrary", 1, ValType.Bool);

			return oProfile.Connection.GetSingleProperty("ApplicationServer", "UID_ApplicationServer", strWhereClause);
		}

		/// <exclude/>
		/// <summary>
		/// Generiert einen Eintrag für alle Domänen außer der ZB(CL) in der Tabelle ProfileCanUsedbyRD bzw. DriverCanUsedbyRD
		/// für das übergebene Application-/Driverprofile
		/// </summary>
		/// <param name="oProfile"></param>
		public static void AllowUsageAllRDs(ISingleDbObject oProfile)
		{
			bool bIsAppProf = false;
			ISingleDbObject oCLDomain; 		// CL-domain
			IColDbObject colCanUsedByRD;		// list for profile/driver can used by rd
			IColDbObject colRDs;		// list of all rds
			string strWhereClause = "";
			ISingleDbObject oRD;
			ISingleDbObject oObjCanUsedByRD;

			if (null == oProfile)
			{
				return;
			}

			ISqlFormatter fSQL = oProfile.Connection.SqlFormatter;

			//	Is it an application profile?
			bIsAppProf = ("APPLICATIONPROFILE" == oProfile.Tablename.ToUpperInvariant());

			oCLDomain = GetCLDomain(oProfile);

			if (null == oCLDomain)
			{
				return;
			}

			if (oCLDomain.GetValue<string>("UID_SDLDomain").ToUpperInvariant() != oProfile.GetValue<string>("UID_SDLDomainRD").ToUpperInvariant())
			{
				throw new ViException(2116067, ExceptionRelevance.EndUser);
			}

			colRDs = oProfile.Connection.CreateCol("SDLDomain");
			strWhereClause = fSQL.Comparison("UID_SDLDomain", oCLDomain.GetValue<string>("UID_SDLDomain"), ValType.String, CompareOperator.NotEqual);
			colRDs.Prototype.WhereClause = strWhereClause;
			colRDs.PrepareBulkLoad();
			colRDs.Load();

			foreach (IColElem colElem in colRDs )
			{
				oRD = colElem.Create();

				if (bIsAppProf)
				{
					colCanUsedByRD = oProfile.Connection.CreateCol("ProfileCanUsedByRD");
				}
				else
				{
					colCanUsedByRD = oProfile.Connection.CreateCol("DriverCanUsedByRD");
				}

				strWhereClause = fSQL.Comparison("UID_SDLDomainAllowed", oRD.GetValue<string>("UID_SDLDomain"), ValType.String) + " and " +
								 fSQL.UidComparison("UID_PROFILE", oProfile.GetValue<string>("UID_PROFILE"));
				colCanUsedByRD.Prototype.WhereClause = strWhereClause;
				colCanUsedByRD.PrepareBulkLoad();
				colCanUsedByRD.Load();

				// only create entry, if not yet exists
				if (colCanUsedByRD.Count == 0)
				{
					if (bIsAppProf)
					{
						oObjCanUsedByRD = oProfile.Connection.CreateSingle("ProfileCanUsedByRD");
					}
					else
					{
						oObjCanUsedByRD = oProfile.Connection.CreateSingle("DriverCanUsedByRD");
					}

					oObjCanUsedByRD["UID_SDLDomainAllowed"].NewValue = oRD.GetValue<string>("UID_SDLDomain");
					oObjCanUsedByRD["UID_PROFILE"].NewValue = oProfile.GetValue<string>("UID_PROFILE");
					oObjCanUsedByRD.Save();
				}
			}
		}

		/// <exclude/>
		/// <summary>
		/// Test, ob das App/Treiber-Profil in der Domäne eindeutig ist.
		/// </summary>
		/// <param name="pProfile">Datenbankobjekt, welches mit CreateSingle angelegt wurde (wegen Zugriffsrechten)  </param>
		public static void IsUniqueAKProfile(ISingleDbObject pProfile)
		{
			String strTable = pProfile.Tablename.ToUpperInvariant();
			String strWhereClause = "";
			ISqlFormatter fSQL = pProfile.Connection.SqlFormatter;

			switch (strTable)
			{
				case "APPLICATIONPROFILE":
					strWhereClause = fSQL.Comparison("UID_Application", pProfile["UID_Application"].New.String, ValType.String, CompareOperator.Equal, FormatterOptions.None);
					strWhereClause += " and ";
					strWhereClause += fSQL.Comparison("Ident_InstType", pProfile["Ident_InstType"].New.String, ValType.String);
					strWhereClause += " and ";
					strWhereClause += fSQL.Comparison("Ident_OS", pProfile["Ident_OS"].New.String, ValType.String);
					strWhereClause += " and ";
					strWhereClause += fSQL.Comparison("Ident_DomainRD", pProfile["Ident_DomainRD"].New.String, ValType.String);

					// Für die zugewiesene Applikation existiert schon ein Profil
					if (pProfile.Connection.Exists("ApplicationProfile", strWhereClause))
					{
						throw new ViException(2116136, ExceptionRelevance.EndUser, pProfile["Ident_OS"].New.String, pProfile["Ident_InstType"].New.String, pProfile["Ident_DomainRD"].New.String);
					}

					break;

				case "DRIVERPROFILE":
					strWhereClause = fSQL.Comparison("UID_Driver", pProfile["UID_Driver"].New.String, ValType.String, CompareOperator.Equal, FormatterOptions.None);
					strWhereClause += " and ";
					strWhereClause += fSQL.Comparison("Ident_DomainRD", pProfile["Ident_DomainRD"].New.String, ValType.String);

					if (pProfile.Connection.Exists("DriverProfile", strWhereClause))
					{
						throw new ViException(2116137, ExceptionRelevance.EndUser, pProfile["Ident_DomainRD"].New.String);
					}

					break;

				default:
					throw new ViException(2116138, ExceptionRelevance.EndUser, strTable);
			}
		}



		#endregion

		#region private Memberfunctions

		/// <exclude/>
		/// <summary>
		///
		/// </summary>
		/// <param name="strColumnName"></param>
		/// <param name="dbSource"></param>
		/// <param name="dbDest"></param>
		private static void CopyIfAllowed(string strColumnName, ISingleDbObject dbSource, ISingleDbObject dbDest)
		{
			if (dbDest[strColumnName].CanEdit)
			{
				dbDest[strColumnName].NewValue = dbSource[strColumnName].NewValue;
			}
		}

		// complete unknown FDS
		/// <exclude/>
		private static void _CompleteUnknownFDS( ISingleDbObject oSrcProfile, string CopyEvent, ref string UID_SourceServer,
				ref string UID_DestServer, string identSourceDomain, ref string identDestDomain )
		{
			ISingleDbObject  oServer;
			string   strCopyEvent = CopyEvent.ToUpperInvariant();

			// Copy operation from FDS
			if (((strCopyEvent.IndexOf("FDS2", StringComparison.OrdinalIgnoreCase) >= 0) ||
				 (strCopyEvent.IndexOf("FDS_P2", StringComparison.OrdinalIgnoreCase) >= 0) ||
				 (strCopyEvent.IndexOf("FDS_C2", StringComparison.OrdinalIgnoreCase) >= 0))
				&&
				(String.IsNullOrEmpty(UID_SourceServer)))
			{
				oServer = _ServerExists( oSrcProfile, "FDS", identSourceDomain, false );

				if (null != oServer)
				{
					UID_SourceServer = oServer.GetValue<string>("UID_QBMServer");
				}
			}

			// Copyoperation to FDS
			if ((strCopyEvent.IndexOf("2FDS", StringComparison.OrdinalIgnoreCase) >= 0) && (String.IsNullOrEmpty(UID_DestServer)))
			{
				if ( String.IsNullOrEmpty(identDestDomain) )
				{
					identDestDomain = identSourceDomain;

				}

				oServer = _ServerExists( oSrcProfile, "FDS", identDestDomain, false );

				if (null != oServer)
				{
					UID_DestServer = oServer.GetValue<string>("UID_QBMServer");
				}
			}
		}

		/// <exclude/>
		private static ISingleDbObject _ServerExists(ISingleDbObject dbProfile, string strServerRole, string domain, bool bWithError)
		{
			IEntity eServer = null;
			
			if ((null == dbProfile) || String.IsNullOrEmpty(strServerRole) || String.IsNullOrEmpty(domain))
			{
				return null;
			}

			ISqlFormatter fSql = dbProfile.Connection.SqlFormatter;

			IColDbObject colDomain = dbProfile.Connection.CreateCol("SDLDomain");
			colDomain.Prototype.WhereClause = fSql.OrRelation(
				fSql.UidComparison("UID_SDLDomain", domain),
				fSql.UidComparison("Ident_Domain", domain));
			colDomain.Load();

			if (colDomain.Count < 1)
				return null;

			ISingleDbObject dbDomain = colDomain[0].Create();

			try
			{
				switch ( strServerRole.ToUpperInvariant() )
				{
					case "TAS":
						eServer = dbDomain.Custom.CallMethod("GetTAS", true) as IEntity;

						if (eServer == null)
						{
							throw new ViException(2116096, ExceptionRelevance.EndUser, strServerRole, domain);
						}

						break;

					case "FDS":
						eServer = dbDomain.Custom.CallMethod("GetRootAppServer", true) as IEntity;

						if (eServer == null)
						{
							throw new ViException(2116096, ExceptionRelevance.EndUser, strServerRole, domain);
						}

						break;

					case "CL":
						eServer = dbDomain.Custom.CallMethod("GetCLServer", true) as IEntity;

						if (eServer == null)
						{
							throw new ViException(2116103, ExceptionRelevance.EndUser);
						}

						break;
				}
			}
			catch
			{
				if (bWithError)
					throw;
			} 

			return eServer?.CreateSingleDbObject(dbProfile.Connection);
		}

		/// <exclude/>
		private static bool _CopyIsAllowed(ISingleDbObject oProfile, string strToDomain)
		{
			string strTable;

			if ((oProfile == null) ||
				(String.IsNullOrEmpty(strToDomain)))
			{
				return false;
			}

			ISqlFormatter fSQL = oProfile.Connection.SqlFormatter;

			if (String.Equals(oProfile.Tablename, "APPLICATIONPROFILE", StringComparison.OrdinalIgnoreCase) )
			{
				strTable = "ProfileCanUsedByRD";
			}
			else
			{
				strTable = "DriverCanUsedByRD";
			}

			string strWhereClause = fSQL.AndRelation(
										fSQL.UidComparison("UID_Profile", oProfile.GetValue<string>("UID_Profile")),
										fSQL.Comparison("Ident_DomainAllowed", strToDomain, ValType.String)
									);

			return oProfile.Connection.Exists(strTable, strWhereClause);
		}

		/// <exclude/>
		private static void _CopyAliases(ISingleDbObject oSrcProfile, ISingleDbObject oDestProfile,  string strCopyEvent, string Ident_DomainTo)
		{
			IColDbObject col;
			ISingleDbObject oObj,
							oProfCanUsedAlsoDest;

			Trace.WriteLine ("UID_Profile: <" + oSrcProfile.GetValue<string>("UID_PROFILE") + ">, Ident_DomainRD: <" + oSrcProfile.GetValue<string>("IDENT_DOMAINRD") + "> of source profile.");
			Trace.WriteLine ("UID_Profile: <" + oDestProfile.GetValue<string>("UID_PROFILE") + ">, Ident_DomainRD: <" + oDestProfile.GetValue<string>("IDENT_DOMAINRD") + "> of destination profile.");

			// löscht vorhandene Einträge im ZielProfile
			col = oDestProfile.GetCR("ProfileCanUsedAlso", "UID_Profile").Children;

			foreach (IColElem colElem in col)
			{
				oObj = colElem.Create();
				oObj.Delete();
				oObj.Save();
			}

			col.Clear();
			col = oSrcProfile.GetCR("ProfileCanUsedAlso", "UID_Profile").Children;

			foreach (IColElem colElem in col)
			{
				oObj  = colElem.Create();
				oProfCanUsedAlsoDest = oSrcProfile.Connection.CreateSingle("ProfileCanUsedAlso");
				oProfCanUsedAlsoDest["UID_Profile"].NewValue = oDestProfile.GetValue<string>("UID_PROFILE");

				oProfCanUsedAlsoDest["UID_OsInstType"].NewValue = oObj.GetValue<string>("UID_OsInstType");
				oProfCanUsedAlsoDest["Ident_OSAlso"].NewValue = oObj.GetValue<string>("Ident_OSAlso");
				oProfCanUsedAlsoDest["Ident_InstTypeAlso"].NewValue = oObj.GetValue<string>("Ident_InstTypeAlso");

				// #28523
				oProfCanUsedAlsoDest["UID_OS"].NewValue = oObj.GetValue<string>("UID_OS");
				oProfCanUsedAlsoDest["UID_InstallationType"].NewValue = oObj.GetValue<string>("UID_InstallationType");

				oProfCanUsedAlsoDest.Save();
			}
		}

		// Checkup that the servers for this Copy-Event exits
		/// <exclude/>
		private static bool _CheckServerExists(ISingleDbObject oProfile, string strCopyEvent, string strSourceDomain, string strDestDomain)
		{
			ISingleDbObject oServer;

			// is destination domain empty
			if ( String.IsNullOrEmpty(strDestDomain) )
			{
				// so copy the sourcedomain
				strDestDomain = strSourceDomain;
			}


			if (strCopyEvent.IndexOf("TAS2", StringComparison.OrdinalIgnoreCase) >= 0)
			{
				oServer = _ServerExists( oProfile, "TAS", strSourceDomain, true );

				if (null == oServer )
				{
					return false;
				}
			}

			if (strCopyEvent.IndexOf("2TAS", StringComparison.OrdinalIgnoreCase) >= 0)
			{
				oServer = _ServerExists( oProfile, "TAS", strDestDomain, true );

				if (null == oServer)
				{
					return false;
				}
			}

			if (strCopyEvent.IndexOf("FDS2", StringComparison.OrdinalIgnoreCase) >= 0)
			{
				oServer = _ServerExists( oProfile, "FDS", strSourceDomain, true);

				if ( null ==  oServer )
				{
					return false;
				}
			}

			if (strCopyEvent.IndexOf("2FDS", StringComparison.OrdinalIgnoreCase) >= 0)
			{
				oServer = _ServerExists( oProfile, "FDS", strDestDomain, true );

				if ( null == oServer )
				{
					return false;
				}
			}


			if (strCopyEvent.IndexOf("CL2", StringComparison.OrdinalIgnoreCase) >= 0)
			{
				oServer = _ServerExists( oProfile, "CL", strSourceDomain, true );

				if (null == oServer )
				{
					return false;
				}
			}

			if (strCopyEvent.IndexOf("2CL", StringComparison.OrdinalIgnoreCase) >= 0)
			{
				oServer = _ServerExists( oProfile, "CL", strSourceDomain, true );

				if ( null == oServer )
				{
					return false;
				}
			}

			if (strCopyEvent.IndexOf("FDS_C2", StringComparison.OrdinalIgnoreCase) >= 0)
			{
				oServer = _ServerExists( oProfile, "FDS", strSourceDomain, true );

				if ( null == oServer )
				{
					return false;
				}
			}

			if (strCopyEvent.IndexOf("FDS_P2", StringComparison.OrdinalIgnoreCase) >= 0)
			{
				oServer = _ServerExists( oProfile, "FDS", strSourceDomain, true );

				if ( null == oServer )
				{
					return false;
				}
			}

			// it's ok
			return true;
		}

		#endregion
	}
}
