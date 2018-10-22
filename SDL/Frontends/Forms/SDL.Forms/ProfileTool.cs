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
using System.Text.RegularExpressions;
using System.Diagnostics;
using System.IO;
using System.Collections;

using Microsoft.Win32;

using VI.DB;
using VI.Base;

namespace SDL.Forms
{
	/// <summary>
	/// Methoden für die Bearbeitung von Applikations- und Treiberprofilen.
	/// Die Klasse ist nicht instanziierbar.
	/// Das Interface enthält ausschließlich statische Methoden
	/// </summary>
	public class ProfileTool
	{

		#region Members

		#region Private Methods

		/// <summary>
		/// Speichere Parameter als Registrykey.
		/// </summary>
		/// <param name="pname">Keyname.</param>
		/// <param name="pvalue">Keyvalue.</param>
		private static void saveProfileEditParm(string pname, string pvalue)
		{
			//  SaveSetting "ProfileEdit", "Parameter", pname, pvalue
			RegistryKey rk = Registry.CurrentUser.CreateSubKey(@"Software\VB and VBA Program Settings\ProfileEdit\Parameter");
			rk.SetValue(pname, pvalue);
			rk.Close();
		}


		/// <summary>
		/// Prüft, ob das Objekt ein ApplikationsProfil ist.
		/// </summary>
		/// <param name="dbObject">ISingleDbObject.</param>
		/// <returns>Boolean.</returns>
		private static bool isApplicationProfile(ISingleDbObject dbObject)
		{
			return (dbObject.Tablename.ToLowerInvariant() == "applicationprofile");
		}


		/// <summary>
		/// Liefert den Wert aus Profile.vii für einen gegebenen Schlüssel.
		/// </summary>
		/// <param name="profvii">Inhalt der Profile.vii asl String.</param>
		/// <param name="prop">Schlüssel als String.</param>
		/// <returns>Wert als String.</returns>
		private static string getViiValue(string profvii, string prop)
		{
			foreach (Match match in m_ProfileVIIEntry.Matches(profvii))
			{
				if (string.Equals(match.Groups["Key"].Value.Trim(), prop, StringComparison.OrdinalIgnoreCase))
					return match.Groups["Value"].Value.Trim();
			}

			return "";
		}


		/// <summary>
		/// Verleich zweier profile.vii Dateien.
		/// </summary>
		/// <param name="profvii1">Inhalt der ersten profile.vii als String.</param>
		/// <param name="profvii2">Inhalt der zweiten profile.vii als String.</param>
		/// <returns>Wahr, wenn beide Dateien übereinstimmen.</returns>
		private static bool profileViiHasChanged(string profvii1, string profvii2)
		{
			return getViiValue(profvii1, "ChgNr") != getViiValue(profvii2, "ChgNr") ||
				   getViiValue(profvii1, "AnzahlEintraege") != getViiValue(profvii2, "AnzahlEintraege") ||
				   getViiValue(profvii1, "Speicherbedarf") != getViiValue(profvii2, "Speicherbedarf") ||
				   getViiValue(profvii1, "ProfileHash") != getViiValue(profvii2, "ProfileHash");
		}


		/// <summary>
		/// Abspeichern der Übergabeparementer für Profile Eidtor.
		/// </summary>
		/// <param name="profile">Applikations- bzw. Treiberprofil.</param>
		/// <param name="domain">Domäne.</param>
		/// <param name="application">Application bzw. Treiber</param>
		/// <param name="path">Pfad des Profils, wenn bekannt.</param>
		/// <returns></returns>
		private static bool storeParameters(ISingleDbObject profile, ISingleDbObject domain, ISingleDbObject application, params string[] path)
		{
			try
			{
				string profpath = "";

				if (path.Length > 0)
					profpath = path[0];
				else if (!GetProfilePathOnTas(profile, out profpath))
					profpath = "";

				if (string.IsNullOrEmpty(profpath))
					return false;

				bool isapp = isApplicationProfile(profile);

				ISingleDbObject ptas = domain.GetFK("UID_ServerTAS").Create();
				string server = "";

				if (isapp && profile.GetValue("ServerDrive").String.Length != 0)
				{
					server = profile.GetValue("PackagePath").String.Length >= 0 ?
							 @"\\" + ptas.GetValue("Ident_Server").String + @"\" + domain.GetValue("ServerPartShareOnTAS").String + @"\" + profile.GetValue("PackagePath").String :
							 @"\\" + ptas.GetValue("Ident_Server").String + @"\" + domain.GetValue("ServerPartShareOnTAS").String + @"\" + profile.GetValue("SubPath").String ;
				}


				saveProfileEditParm("Language", LanguageManager.Instance.Language);
				saveProfileEditParm("SectionName", application.GetValue("Ident_SectionName").String);
				saveProfileEditParm("ProfileName", profile.GetValue("DisplayName").String);
				saveProfileEditParm("OrderNumber", FormatOrderNumber(profile.GetValue("OrderNumber").String));
				saveProfileEditParm("ChgNr", profile.GetValue("ChgTest").String);

				saveProfileEditParm("ProfilePath", profpath);
				saveProfileEditParm("ProfileKind", (isapp ? "ApplicationProfile" : "DriverProfile"));
				saveProfileEditParm("ProfilePathServer", server);
				saveProfileEditParm("MasterDomain", domain.GetValue("Ident_Domain").String);
//				saveProfileEditParm("DomainClientDrive", domain.GetValue("ClientDrive").String);
				saveProfileEditParm("DomainAppsDrive", (isapp ? profile.GetValue("ServerDrive").String : ""));
				saveProfileEditParm("DefDriveTarget", profile.GetValue("DefDriveTarget").String);
				saveProfileEditParm("ClientPartPathOnServers", domain.GetValue("ClientPartPathOnServers").String);
				saveProfileEditParm("DomainClientPart", (isapp ? domain.GetValue("ClientPartApps").String : domain.GetValue("ClientPartDriver").String));
				saveProfileEditParm("ProfileSubPath", profile.GetValue("subpath").String);
				saveProfileEditParm("VariableStart", profile.Connection.GetConfigParm(@"Software\SoftwareDistribution\Variable\Start"));
				saveProfileEditParm("VariableEnd", profile.Connection.GetConfigParm(@"Software\SoftwareDistribution\Variable\End"));
				
				saveProfileEditParm("CachingBehavior", profile.GetValue("CachingBehavior").String);
				saveProfileEditParm("RemoveHKeyCurrentUser", profile.GetValue("RemoveHKeyCurrentUser").Bool ? "1" : "0");
				saveProfileEditParm("ProfileType", profile.GetValue("ProfileType").String);
				saveProfileEditParm("OSMode", profile.GetValue("OSMode").String);


				saveProfileEditParm("ScanType", "NT4"); // in AE3 imemr NT4 damit der ProfilEditor CMDs schreibt

				return true;
			}
			catch (Exception exception)
			{
				VI.FormBase.ExceptionMgr.Instance.HandleException(exception, null);
			}

			return false;
		}


		#endregion Private Methods

		#endregion Members

		#region Interface

		#region Methods

		/// <summary>
		/// Test, ob Pfad unerlaubte Zeichen enthält.
		/// </summary>
		/// <param name="path">Pfad als String.</param>
		/// <returns>Wahr, wenn Pfad keine unerlaubten Zeichen enthält.</returns>
		public static bool CheckCharactersInPathname(string path)
		{
			if (path != null && path.Length > 0)
				return (path.IndexOfAny(Path.GetInvalidFileNameChars()) == -1);

			// else
			return true;
		}


		/// <summary>
		/// Erzeugen des Profilesubpfads auf dem TAS.
		/// </summary>
		/// <param name="pathOnTas">Path on TAS.</param>
		/// <param name="subPath">Subpath.</param>
		/// <returns>Wahr, wenn Aktion erfolgreich war.</returns>
		public static bool CreateSubPathOnTas(string pathOnTas, string subPath)
		{
			try
			{
				string path = Path.Combine(pathOnTas, subPath);

				if (Directory.Exists(path))
					return true;

				Directory.CreateDirectory(path);
				return Directory.Exists(path);
			}
			catch {}

			return false;
		}


		/// <summary>
		/// Synchrones Ausführen eines Betriebssystem-Kommandos.
		/// </summary>
		/// <param name="cmdline">Kommandozeile als String.</param>
		/// <returns>Returncode als Long.</returns>
		public static int ExecCmd(string fileName, string arguments)
		{
			ProcessStartInfo processStartInfo = new ProcessStartInfo();

			processStartInfo.FileName = fileName;
			processStartInfo.Arguments = arguments;

			processStartInfo.UseShellExecute = false;
			processStartInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Normal;

			Process process = Process.Start(processStartInfo);
			process.WaitForExit();

			return process.ExitCode;
		}


		/// <summary>
		/// Formatiert Ordernumber.
		/// </summary>
		/// <param name="orderNumber">Ordernumber als String.</param>
		/// <returns>Formatierte Ordernumber als String.</returns>
		public static string FormatOrderNumber(string orderNumber)
		{
			string[] parts = orderNumber.Replace(",", ".").Split('.');

			if (parts.Length == 1)
			{
				return parts[0] + ".00000";
			}
			else
			{
				parts[1] += "00000";
				return parts[0] + "." + parts[1].Substring(0, 5);
			}
		}


		/// <summary>
		/// Den Pfad des Profile Editors aus der Registry holen und prüfen.
		/// </summary>
		/// <returns>Pfad als String, wenn der Profile Editor existiert, sonst Leerstring.</returns>
		public static string FindProfileEditExe()
		{
			string path = Path.Combine(System.Windows.Forms.Application.StartupPath, "ProfileEdit.exe");

			if (File.Exists(path)) return path;

			// erst einmal den AE ProfileEdior suchen
			RegistryKey rk = Registry.LocalMachine.OpenSubKey(_AdaptRegKey(@"Software\voelcker\viinstall\ActiveEntry Profile Editor\version"));

			if ( rk != null)
			{
				object rkval = rk.GetValue("AppPath");
				rk.Close();

				if (rkval != null)
				{
					string ppath = Path.Combine(rkval.ToString(), "ProfileEditor.exe");

					if (File.Exists(ppath))
						return ppath;
				}
			}

			// wenn nicht vorhanden, dann den Wizard ProfileEdior suchen
			rk = Registry.LocalMachine.OpenSubKey(_AdaptRegKey(@"Software\Voelcker\VIInstall\viProfileEdit7\Version"));

			if ( rk != null)
			{
				object rkval = rk.GetValue("AppPath");
				rk.Close();

				if (rkval != null)
				{
					string ppath = Path.Combine(rkval.ToString(), "viProfileEdit7.exe");

					if (File.Exists(ppath))
						return ppath;
				}
			}

			// keiner von beiden da
			return "";
		}

		/// <summary>
		/// Adaption for x64 vs. x86 differences.
		/// </summary>
		/// <param name="key"></param>
		/// <returns></returns>
		private static string _AdaptRegKey(string key)
		{
			if (IntPtr.Size == 4) return key;

			key = Regex.Replace(key, @"^Software\\", @"Software\WOW6432Node\", RegexOptions.CultureInvariant | RegexOptions.IgnoreCase);

			return key;
		}

		/// <summary>
		/// Ermittelt den Pfad auf dem TAS.
		/// </summary>
		/// <param name="profile_object"></param>
		/// <param name="strReturn">Pfad als String oder Fehlermeldung</param>
		/// <returns>Wahr, wenn der Pfad vollständig ermittelt werden konnte.</returns>
		public static bool GetPathOnTas(ISingleDbObject profile, string strReturn)
		{
			try
			{
				bool isapp = isApplicationProfile(profile);
				string prefix = "VIP7_Sync" + (isapp ? "App" : "Driver") + "Profile_";

				if (profile.GetValue("UID_SDLDomainRD").String.Length == 0)
				{
					strReturn = LanguageManager.Instance[prefix + "ErrNoDomain"];
					return false;
				}

				ISingleDbObject domain = profile.GetFK("UID_SDLDomainRD").Create();

				if (domain.GetValue("UID_ServerTAS").String.Length == 0)
				{
					strReturn = LanguageManager.Instance[prefix + "ErrNoTASinDomain"];
					return false;
				}

				string shareontas = domain.GetValue("ShareOnTAS").String;

				if (shareontas.Length == 0)
				{
					strReturn = LanguageManager.Instance[prefix + "ErrNoShareOnTASinDomain"];
					return false;
				}

				string clientpart = domain.GetValue((isapp ? "ClientPartApps" :	"ClientPartDriver")).String;

				if (clientpart.Length == 0)
				{
					strReturn = LanguageManager.Instance[prefix + "ErrNoClientPartinDomain"];
					return false;
				}

				strReturn = @"\\" + domain.GetFK("UID_ServerTAS").Create().GetValue("Ident_Server") +
							@"\" + shareontas + @"\" + clientpart + @"\";

				return true;
			}
			catch (Exception exception)
			{
				strReturn = exception.Message;
			}

			return false;
		}


		/// <summary>
		/// Liefert den Pfad des Profils auf dem TAS.
		/// </summary>
		/// <param name="profile_object"></param>
		/// <param name="strReturn">Pfad als String oder Fehlermeldung</param>
		/// <returns>Wahr, wenn der Pfad vollständig ermittelt werden konnte und der Pfad existiert.</returns>
		public static bool GetProfilePathOnTas(ISingleDbObject profile, out string strReturn)
		{
			try
			{
				bool isapp = isApplicationProfile(profile);
				string prefix = "VIP7_Sync" + (isapp ? "App" : "Driver") + "Profile_";

				string subpath = profile.GetValue("SubPath").String;

				if (subpath.Length == 0)
				{
					strReturn = LanguageManager.Instance[prefix + "ErrNoSubPath"];
					return false;
				}

				if (profile.GetValue("UID_SDLDomainRD").String.Length == 0)
				{
					strReturn = LanguageManager.Instance[prefix + "ErrNoDomain"];
					return false;
				}

				ISingleDbObject domain = profile.GetFK("UID_SDLDomainRD").Create();

				if (domain.GetValue("UID_ServerTAS").String.Length == 0)
				{
					strReturn = LanguageManager.Instance[prefix + "ErrNoTASinDomain"];
					return false;
				}

				string shareontas = domain.GetValue("ShareOnTAS").String;

				if (shareontas.Length == 0)
				{
					strReturn = LanguageManager.Instance[prefix + "ErrNoShareOnTASinDomain"];
					return false;
				}

				string clientpart = domain.GetValue((isapp ? "ClientPartApps" :	"ClientPartDriver")).String;

				if (clientpart.Length == 0)
				{
					strReturn = LanguageManager.Instance[prefix + "ErrNoClientPartinDomain"];
					return false;
				}

				string clientpartonservers = domain.GetValue("ClientPartPathOnServers").String;

				if (clientpartonservers.Length == 0)
				{
					strReturn = LanguageManager.Instance[prefix + "ErrNoClientPartPathOnServersinDomain"];
					return false;
				}

				strReturn = @"\\" + domain.GetFK("UID_ServerTAS").Create().GetValue("Ident_Server") +
							@"\" + shareontas + @"\" + clientpartonservers + @"\" + clientpart + @"\" + subpath;

				if (!Directory.Exists(strReturn))
				{
					strReturn = LanguageManager.Instance[prefix + "ErrFindPath"];
					return false;
				}

				return true;
			}
			catch (Exception exception)
			{
				strReturn = exception.Message;
			}

			return false;
		}


		/// <summary>
		/// Test, ob in das Profilverzeichnis geschrieben werden kann.
		/// </summary>
		/// <param name="dirpath">Kompletter Pfad (inkl. Dateinamen)</param>
		/// <returns>Wahr, wenn in das Verzeichnis geschreiben werden kann.</returns>
		public static bool IsProfilePathWriteable(string dirpath)
		{
			if (File.Exists(dirpath))
			{
				try
				{
					string fpath = Path.Combine(dirpath, "~test~.tmp");
					StreamWriter w = File.AppendText(fpath);
					w.Write("0");
					w.Close();
					File.Delete(fpath);
					return true;
				}
				catch {}
			}

			return false;
		}


		/// <summary>
		/// Test, ob profile.vii korrekt ist.
		/// </summary>
		/// <param name="dirpath">Kompletter Pfad (inkl. Dateinamen)</param>
		/// <returns></returns>
		public static bool IsProfileViiCorrect(string dirpath)
		{
			bool[] b = new bool[8] {false, false, false, false, false, false, false, false};

			try
			{
				if (!File.Exists(dirpath)) return false;

				using (StreamReader sr = new StreamReader(dirpath))
				{
					string wert = "";
					string line = "";
					int i = -1;

					while ((line = sr.ReadLine()) != null)
					{
						if (m_ProfileVIISection.IsMatch(line))
							b[0] = true;

						Match match = m_ProfileVIIEntry.Match(line);

						if (!match.Success) continue;

						wert = match.Groups["Value"].Value.Trim();

						switch (match.Groups["Key"].Value.Trim().ToLowerInvariant())
						{
							case "chgnr" :
								i = -1;

								try { i = int.Parse(wert); }
								catch {}

								b[1] = (i > -1);
								break;

							case "anzahleintraege" :
								i = -1;

								try { i = int.Parse(wert); }
								catch {}

								b[2] = (i > -1);
								break;

							case "speicherbedarf" :
								b[3] = (wert.Length > 0);
								break;

							case "osmode" :
								b[4] = (wert.Length > 0);
								break;

							case "profiletype" :
								b[5] = (wert.Length > 0);
								break;

							case "profilehash" :
								b[6] = (wert.Length > 0);
								break;

							case "autark" :
								b[7] = (wert.ToUpperInvariant() == "TRUE");
								break;
						}
					}
				}

			}
			catch
			{
				return false;
			}

			return b[0] && b[1] && b[2] && b[3] && b[4] && b[5] && b[6]; // && b[7];
		}


		/// <summary>
		/// Test, ob die profile.vii geschrieben werden kann.
		/// </summary>
		/// <param name="dirpath">Kompletter Pfad (inkl. Dateinamen)</param>
		/// <returns>Wahr, wenn die Profile.vii geschrieben werden kann.</returns>
		public static bool IsProfileViiWriteable(string dirpath)
		{
			if (File.Exists(dirpath))
			{
				try
				{
					FileStream f = File.Open(dirpath, FileMode.Open, FileAccess.Write);
					f.Close();
					return true;
				}
				catch {}
			}

			return false;
		}


		/// <summary>
		/// Liest den Inhalt der Datei und gibt ihn im zweiten Parameter zurück.
		/// </summary>
		/// <param name="dirpath">Kompletter Pfad (inkl. Dateinamen)</param>
		/// <param name="strReturn">Achtung: ByRef Parameter! Enthält den Inhalt der Datei oder Fehlermeldung.</param>
		/// <returns>Wahr, wenn Datei gelesen werden konnte.</returns>
		public static bool ReadFileFromProfile(string dirpath, out string strReturn)
		{
			try
			{
				if (File.Exists(dirpath))
				{
					StreamReader file = File.OpenText(dirpath);
					strReturn = file.ReadToEnd();
					file.Close();
					return true;
				}

				strReturn = LanguageManager.Instance["VIP7_ErrorFileNotFound"] + " " + dirpath;
			}
			catch (Exception exception)
			{
				strReturn = exception.Message;
			}

			return false;
		}


		/// <summary>
		/// Holt den Sektionsnamen aus der Profile.vii.
		/// </summary>
		/// <param name="profvii">Inhalt der Profile.vii als String.</param>
		/// <returns>Sektionsname als String.</returns>
		public static string SectionName(string profvii)
		{
			Match match = m_ProfileVIISection.Match(profvii);

			if (match.Success)
				return match.Groups["Section"].Value.Trim();

			return "";
		}


		/// <summary>
		/// Startet den Profil Editor.
		/// </summary>
		/// <param name="profile">Applikations- oder Treiberprofil als SingleDbObject.</param>
		/// <param name="domain">Domäne als SingleDbObject.</param>
		/// <param name="application">Applikation oder Treiber als SingleDbObject.</param>
		/// <returns>Wahr, wenn Änderungen an der Profile.vii vorgenommen wurden.</returns>
		public static bool StarteProfileEditor(ISingleDbObject profile, ISingleDbObject domain, ISingleDbObject application)
		{
			try
			{
				// 1. Schritt: ProfileEdit suchen.
				string pepath = FindProfileEditExe();

				if (string.IsNullOrEmpty(pepath))
					throw new ViException(LanguageManager.Instance["VIP7_frmEditNoProfileEdit"]);

				// 2. Schritt: Path on TAS ermitteln.
				string pathontas = "";

				if (!GetProfilePathOnTas(profile, out pathontas))
					throw new ViException(pathontas);

				// 3. Schritt: alte Profile.vii lesen.
				string profvii1 = "";
				string profvii2 = "";

				if (!ReadFileFromProfile(Path.Combine(pathontas, "profile.vii"), out profvii1))
					profvii1 = "";	 // Neue profile.vii wird von profile edit angelegt.

				// 4. Schritt: Übergabeparameter in Registry ablegen.
				if (storeParameters(profile, domain, application, pathontas))
				{
					// 5. Schritt: ProfileEdit synchron starten und neue Profile.vii einlesen.
					int ret = ExecCmd(pepath, "Packager");

					if (!ReadFileFromProfile(Path.Combine(pathontas, "profile.vii"), out profvii2))
						profvii2 = "";

					// 6. Schritt: Feststellen, ob Profile.vii geändert wurde.
					return profileViiHasChanged(profvii1, profvii2);
				}
			}
			catch (Exception exception)
			{
				VI.FormBase.ExceptionMgr.Instance.HandleException(exception, null);
			}

			return false;
		}



		/// <summary>
		/// Synchronisation zwischen rofile.vii und Profil-Objekt.
		/// </summary>
		/// <param name="profile">Profil Objekt.</param>
		/// <param name="profviiPath">Vollständiger Pfad zur Profile.vii.</param>
		/// <returns></returns>
		public static bool SyncWithProfileVii(ISingleDbObject profile, string profviiPath)
		{

			/*
			    profile_object               profile.vii						master
			    ----------------------------------------------------------------------
			    App.Ident_Sectionname        Sektion            				db
			    ChgTest                      ChgNr              				max
			    Displayname                  Bezeichnung        				db
			    ClientStepCounter            AnzahlEintraege    				vii
			    OSMode                       OSMode             				vii
			    MemoryUsage                  Speicherbedarf     				vii
			    OrderNumber                  OrdnungsNr         				db
			    ProfileType                  ProfileType        				vii
			    HashValueTAS                 ProfileHash        				vii
				CachingBehavior              LokaleZwischenspeicherbarkeit		vii
				RemoveHKeyCurrentUser        VerarbeitungHkcuBeimDeinstallieren vii
			*/
			try
			{
				string profvii = "";

				if (!ReadFileFromProfile(profviiPath, out profvii))
					throw new ViException(profviiPath);

				if (string.IsNullOrEmpty(getViiValue(profvii, "ProfileHash")))
					throw new ViException(LanguageManager.Instance["VIP7_SyncAppProfile_ErrProfileNotAutark"]);

				bool profviiChanged = false;

				string section			= SectionName(profvii);
				string chgnr			= getViiValue(profvii, "ChgNr");
				string bezeichnung		= getViiValue(profvii, "Bezeichnung");
				string anzahleintraege	= getViiValue(profvii, "AnzahlEintraege");
				string osmode			= getViiValue(profvii, "OSMode");
				string speicherbedarf	= getViiValue(profvii, "Speicherbedarf");
				string ordnungsnr		= getViiValue(profvii, "OrdnungsNr");

				if (string.IsNullOrEmpty(ordnungsnr))
					ordnungsnr = FormatOrderNumber("0");

				string profiletype		= getViiValue(profvii, "ProfileType");
				string profilehash		= getViiValue(profvii, "ProfileHash");
				string cachingbehavior = getViiValue(profvii, "LokaleZwischenspeicherbarkeit").Trim();
				bool  removehkeycurrentuser = false;


				if (string.IsNullOrEmpty(chgnr))
				{
					chgnr = "0";
					profviiChanged = true;
				}

				//ChgNr or Changetest ? - take allways the max of both chgNumbers
				int intchgnr = int.Parse(chgnr);
				int objchgnr = profile.GetValue("ChgTest").Int;

				if (intchgnr > objchgnr)
					profile.PutValue("ChgTest", intchgnr);
				else if (intchgnr < objchgnr)
				{
					chgnr = profile.GetValue("ChgTest").String;
					profviiChanged = true;
				}

				if (string.IsNullOrEmpty(anzahleintraege))
				{
					anzahleintraege = profile.GetValue("ClientStepCounter").String;
					profviiChanged = true;
				}

				if (string.IsNullOrEmpty(osmode))
				{
					osmode = profile.GetValue("OSMode").String;
					profviiChanged = true;
				}

				if (string.IsNullOrEmpty(speicherbedarf))
				{
					speicherbedarf = profile.GetValue("MemoryUsage").String;
					profviiChanged = true;
				}

				if (string.IsNullOrEmpty(profiletype))
				{
					profiletype = profile.GetValue("ProfileType").String;
					profviiChanged = true;
				}

				if (string.IsNullOrEmpty(cachingbehavior))
				{
					cachingbehavior = profile.GetValue("CachingBehavior").String;
					profviiChanged = true;
				}

				string dummy = getViiValue(profvii, "VerarbeitungHkcuBeimDeinstallieren").Trim().ToLowerInvariant();

				if (string.IsNullOrEmpty(dummy))
				{
					removehkeycurrentuser = profile.GetValue("RemoveHKeyCurrentUser").Bool;
					profviiChanged = true;
				}
				else
				{
					if (dummy == "wahr") removehkeycurrentuser = true;
					else if (dummy == "falsch") removehkeycurrentuser = false;
					else removehkeycurrentuser = bool.Parse(dummy);
				}

				// profile.vii is master
				if (profile.GetValue("ClientStepCounter").String != anzahleintraege)
					profile.PutValue("ClientStepCounter", int.Parse(anzahleintraege));

				if (profile.GetValue("OSMode").String != osmode)
					profile.PutValue("OSMode", osmode);

				if (profile.GetValue("MemoryUsage").String != speicherbedarf)
					profile.PutValue("MemoryUsage", speicherbedarf);

				if (profile.GetValue("ProfileType").String != profiletype)
					profile.PutValue("ProfileType", profiletype);

				if (profile.GetValue("HashValueTAS").String != profilehash)
					profile.PutValue("HashValueTAS", int.Parse(profilehash));

				if (profile.GetValue("CachingBehavior").String != cachingbehavior)
					profile["CachingBehavior"].NewValue = cachingbehavior;

				if (profile.GetValue("RemoveHKeyCurrentUser").Bool != removehkeycurrentuser)
					profile["RemoveHKeyCurrentUser"].NewValue = removehkeycurrentuser;

				// db is master
				ISingleDbObject appobject = (isApplicationProfile(profile) ? profile.GetFK("UID_Application").Create() :
											 profile.GetFK("UID_Driver").Create());

				if (appobject.GetValue("Ident_Sectionname").String != section)
				{
					section = appobject.GetValue("Ident_Sectionname").String;
					profviiChanged = true;
				}

				if (profile.GetValue("Displayname").String != bezeichnung)
				{
					bezeichnung = profile.GetValue("Displayname").String;
					profviiChanged = true;
				}

				string objordnungsnr = FormatOrderNumber(profile.GetValue("OrderNumber").String);

				if (ordnungsnr != objordnungsnr)
				{
					ordnungsnr = objordnungsnr;
					profviiChanged = true;
				}

				if (profviiChanged && IsProfileViiWriteable(profviiPath))
				{
					profvii = "[" + section + "]" + Environment.NewLine +
							  "ChgNr=" + chgnr + Environment.NewLine +
							  "Bezeichnung=" + bezeichnung + Environment.NewLine +
							  "AnzahlEintraege=" + anzahleintraege + Environment.NewLine  +
							  "OSMode=" + osmode + Environment.NewLine +
							  "Speicherbedarf=" + speicherbedarf + Environment.NewLine +
							  "OrdnungsNr=" + ordnungsnr + Environment.NewLine +
							  "ProfileType=" + profiletype + Environment.NewLine +
							  "ProfileHash=" + profilehash + Environment.NewLine +
							  "LokaleZwischenspeicherbarkeit=" + cachingbehavior + Environment.NewLine +
							  "VerarbeitungHkcuBeimDeinstallieren=" + removehkeycurrentuser.ToString();

					// + "Autark=TRUE";
					WriteToFile(profviiPath, profvii);
				}

				return true;

			}
			catch (Exception exception)
			{
				VI.FormBase.ExceptionMgr.Instance.HandleException(exception, null);
			}

			return false;
		}


		/// <summary>
		/// Inhalt in eine Datei schreiben.
		/// </summary>
		/// <param name="dirpath">Pfad der Datei.</param>
		/// <param name="content">Inhalt als String.</param>
		/// <returns>Wahr, wenn Aktion erfolgreich war.</returns>
		public static bool WriteToFile(string dirpath, string content)
		{
			try
			{
				StreamWriter file = File.CreateText(dirpath);
				file.Write(content);
				file.Close();
				return true;
			}
			catch {}

			return false;
		}


		#endregion Methods

		#endregion Interface

		#region Constructors

		private ProfileTool()
		{
			//
			// TODO: Add constructor logic here
			//
		}


		#endregion

		private static Regex m_ProfileVIISection = new Regex(@"^\s*\[(?<Section>[^\]]+)\]", RegexOptions.CultureInvariant);
		private static Regex m_ProfileVIIEntry = new Regex(@"(?<Key>\w+)\s*=\s*(?<Value>.*)", RegexOptions.CultureInvariant);

	}
}
