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
using System.IO;
using System.Text;
using System.Windows.Forms;
using System.Collections.Generic;

using VI.Base;
using VI.Base.JobProcessing;
using VI.Samba.Tools;

namespace VI.JobService.JobComponents
{
	/// <summary>
	/// Summary description for ControlFilesComponent.
	/// </summary>
	public class ControlFilesComponent : JobComponent
	{
		private static readonly Dictionary<string, IDictionary<string, string>> _languages =
			new Dictionary<string, IDictionary<string, string>>(StringComparer.OrdinalIgnoreCase);

		[Flags]
		private enum _FileActionFlagsMachine
		{
			CNameVii = 1,
			MactypeUdf = 2,
			Mac2NameVii = 4,
			RplLst = 8
		}

		private enum _IPAddressFormat
		{
			Short,
			Long
		}

		[Flags]
		private enum _FileActionFlagsProfile
		{
			PathVii = 1,
			ProfileVii = 2
		}

		private enum _ProfileType
		{
			ApplicationProfile,
			DriverProfile
		}

		private enum _ProfileKind
		{
			Old,
			New
		}

		/// <summary>
		/// Release all external resources
		/// </summary>
		public override void Dispose()
		{
			// Add all your code here to release external resources
		}

		#region Public Methods

		/// <summary>
		/// This function is called for every component activation
		/// </summary>
		/// <param name="task">Task to execute.</param>
		public override void Activate(string task)
		{
			base.Activate(task);

			_Activate(task);

			Result.ReturnCode = JobReturnCode.OK;
		}

		#endregion // Public Methods

		#region private methods

		private void _Activate(string task)
		{
			switch ( task.ToUpperInvariant() )
			{
				case "REPAIRAPPPROFILE":
					_RepairProfile(_ProfileType.ApplicationProfile, _ProfileKind.Old);
					break;

				case "REPAIRDRVPROFILE":
					_RepairProfile(_ProfileType.DriverProfile, _ProfileKind.Old);
					break;

				case "DELAPPPROFILE":
					_DelProfile();
					break;

				case "DELDRVPROFILE":
					_DelProfile();
					break;

				case "REPAIRNEWAPPPROFILE":
					_RepairProfile(_ProfileType.ApplicationProfile, _ProfileKind.New);
					break;

				case "REPAIRNEWDRVPROFILE":
					_RepairProfile(_ProfileType.DriverProfile, _ProfileKind.New);
					break;

				case "ADDMACHINE":
					// add machine
					_AddMachine();
					break;

				case "DELMACHINE":
					// delete machine
					_DelMachine();
					break;

				case "ADDFOLDERVIIENTRY":
					// add "folder<Domain>.vii" entry
					_AddFolderVIIEntry();
					break;

				case "DELFOLDERVIIENTRY":
					// delete "folder<Domain>.vii" entry
					_DelFolderVIIEntry();
					break;

				case "INSERTGROUPS":
					// insert groups
					_InsertGroups();
					break;

				case "REMOVEGROUPS":
					// remove groups
					_RemoveGroups();
					break;

				case "WRITEBOOTP":
					throw new Exception("Task \"WriteBootP\" is not implemented yet.");

				case "DELETEBOOTP":
					throw new Exception("Task \"DeleteBootP\" is not implemented yet.");

				case "WRITEVIISECTION":
					_WriteVIISection();
					break;

				default:
					throw new ViException(818002, task);

			}
		}

		#region task functions

		// method for job task "RepairProfile", "RepairNewProfile"
		private void _RepairProfile(_ProfileType type, _ProfileKind kind)
		{
			// check required parameters
			CheckRequiredParameters("Ident_OS", "Version", "Ident_Language",
									"ClientPartPathOnServers", "SectionName",
									"ShareOnServers", "SubPath", "ClientDrive", "OrderNumber",
									"ChgTest", "ChgNumber", "IsFDSProfile", "FileAction", "DomainMasterShare",
									"ServerVariable");

			IDictionary<string, string> strings = _GetStrings(GetSafeParameter("FileLanguage", "deutsch"));

			// build server net root path
			StringBuilder svrNetRootPath = new StringBuilder();

			svrNetRootPath.Append(_GetCombinedPath(true, Parameters["ShareOnServers"].Value,
												   Parameters["ClientPartPathOnServers"].Value));

			long fileAction = Convert.ToInt64(Parameters["FileAction"].Value);

			if ( (((_FileActionFlagsProfile)fileAction) & _FileActionFlagsProfile.PathVii) == _FileActionFlagsProfile.PathVii )
			{
				Result.Messages.Add("Try to write 'path.vii'.");

				_WritePathVii(svrNetRootPath.ToString(), type);
			}

			if ( (((_FileActionFlagsProfile)fileAction) & _FileActionFlagsProfile.ProfileVii) == _FileActionFlagsProfile.ProfileVii )
			{
				Result.Messages.Add("Try to write 'profile.vii'.");

				_WriteProfileVii(svrNetRootPath.ToString(), type, kind, strings);
			}
		}

		// method for job task "DelProfile"
		private void _DelProfile()
		{
			// check required parameters
			CheckRequiredParameters("ShareOnServers", "ClientPartPathOnServers",
									"SectionName", "SubPath");

			// build server net root path
			string svrNetRootPath = _GetCombinedPath(true, Parameters["ShareOnServers"].Value,
									Parameters["ClientPartPathOnServers"].Value);

			// build path.vii path
			string pathViiPath = Path.Combine(svrNetRootPath, "path.vii");

			string localPath = _GetLocalPath(pathViiPath);

			Result.Messages.Add(string.Format("Try to remove profile entry in \"{0}\"",
											  localPath));

			// remove profile section in path.vii
			FileTransaction pathvii = new FileTransaction(localPath, _GetEncodingFromParameters());

			pathvii.BeginSection(Parameters["SectionName"].Value, true);
			pathvii.Commit();

			// build profile.vii path
			string profileViiPath;

			if (_IsValidParameter("ClientPartApplication"))
			{
				profileViiPath = _GetCombinedPath(false, svrNetRootPath,
												  Parameters["ClientPartApplication"].Value, Parameters["SubPath"].Value);
			}
			else
			{
				profileViiPath = _GetCombinedPath(false, svrNetRootPath,
												  Parameters["ClientPartDriver"].Value, Parameters["SubPath"].Value, "profile.vii");
			}

			try
			{
				string localPathProfileVii = _GetLocalPath(profileViiPath);

				if (File.Exists(localPathProfileVii))
				{
					// delete profile.vii
					File.Delete(localPathProfileVii);
				}
			}
			catch ( Exception exc )
			{
				throw new ViException(818003, exc, profileViiPath);
			}
		}

		// method for job task "AddMachine"
		private void _AddMachine()
		{
			// check required parameters
			CheckRequiredParameters("FileAction");

			IDictionary<string, string> strings = _GetStrings(GetSafeParameter("FileLanguage", "deutsch"));

			long fileAction = Convert.ToInt64(Parameters["FileAction"].Value);

			if ( ( ((_FileActionFlagsMachine)fileAction) & _FileActionFlagsMachine.CNameVii ) == _FileActionFlagsMachine.CNameVii )
			{
				_WriteCNameVii(strings);
			}

			if ( ( ((_FileActionFlagsMachine)fileAction) & _FileActionFlagsMachine.MactypeUdf ) == _FileActionFlagsMachine.MactypeUdf )
			{
				_WriteMacTypeUdfEntry();
			}

			if ( ( ((_FileActionFlagsMachine)fileAction) & _FileActionFlagsMachine.Mac2NameVii ) == _FileActionFlagsMachine.Mac2NameVii )
			{
				_WriteMac2NameViiEntry(strings);
			}

			if ( ( ((_FileActionFlagsMachine)fileAction) & _FileActionFlagsMachine.RplLst ) == _FileActionFlagsMachine.RplLst )
			{
				_WriteRplLst('A');
			}
		}

		// method for job task "DelMachine"
		private void _DelMachine()
		{
			// check required parameters (unconditional)
			CheckRequiredParameters("FileAction");

			IDictionary<string, string> strings = _GetStrings(GetSafeParameter("FileLanguage", "deutsch"));

			long fileAction = Convert.ToInt64(Parameters["FileAction"].Value);

			if ( ( ((_FileActionFlagsMachine)fileAction) & _FileActionFlagsMachine.CNameVii ) == _FileActionFlagsMachine.CNameVii )
			{
				// check required parameters (conditional)
				CheckRequiredParameters("CNamePath", "Ident_Machine");

				string fileName = _GetCombinedPath(true, Parameters["CNamePath"].Value,
												   Parameters["Ident_Machine"].Value) + ".vii";

				Result.Messages.Add(string.Format("Try to resolve local path for Unc - path: \"{0}\".", fileName));

				try
				{
					string localPath = _GetLocalPath(fileName);

					Result.Messages.Add(string.Format("Local path is \"{0}\".", localPath));

					if (File.Exists(localPath))
					{
						// delete <CName>.vii - file
						File.Delete(localPath);
					}
				}
				catch ( Exception exc )
				{
					throw new ViException(818003, exc, fileName);
				}
			}

			if ( ( ((_FileActionFlagsMachine)fileAction) & _FileActionFlagsMachine.MactypeUdf ) == _FileActionFlagsMachine.MactypeUdf )
			{
				_RemoveMactypeUdfEntry();
			}

			if ( ( ((_FileActionFlagsMachine)fileAction) & _FileActionFlagsMachine.Mac2NameVii ) == _FileActionFlagsMachine.Mac2NameVii )
			{
				_RemoveMac2NameViiEntry(strings);
			}

			if ( ( ((_FileActionFlagsMachine)fileAction) & _FileActionFlagsMachine.RplLst ) == _FileActionFlagsMachine.RplLst )
			{
				_WriteRplLst('D');
			}
		}

		// method for job task "AddFolderVIIEntry"
		private void _AddFolderVIIEntry()
		{
			// check required parameters
			CheckRequiredParameters("CNameInSubDir", "ShareOnServers",
									"Ident_DomainGlobalGroup", "PathType", "Description", "PathValue",
									"Ident_GlobalGroup", "Ident_WorkFolder");

			// build "folder<GlobalGroup>.vii" path
			StringBuilder folderViiPath = new StringBuilder();

			folderViiPath.Append(_GetCombinedPath(true, "NETLOGON"));

			if ( (_IsValidParameter("CNameInSubDir") && GetParameterAsBoolean("CNameInSubDir"))
				 && (Parameters["ShareOnServers"].Value.Length > 0) )
			{
				folderViiPath.Append(Path.DirectorySeparatorChar);
				folderViiPath.Append(Parameters["ShareOnServers"].Value);
			}

			folderViiPath.Append(Path.DirectorySeparatorChar);
			folderViiPath.Append("folder");
			folderViiPath.Append(Parameters["Ident_DomainGlobalGroup"].Value);
			folderViiPath.Append(".vii");

			// build key value
			string iniValue = string.Format("{0}|{1}|{2}", Parameters["PathType"].Value,
											Parameters["Description"].Value, Parameters["PathValue"].Value);

			// add or update new key
			FileTransaction foldervii = new FileTransaction(_GetLocalPath(folderViiPath.ToString()), _GetEncodingFromParameters());

			foldervii.BeginSection(Parameters["Ident_GlobalGroup"].Value, false);
			foldervii.WriteKey(Parameters["Ident_WorkFolder"].Value, iniValue);
			foldervii.Commit();
		}

		// method for job task "DelFolderVIIEntry"
		private void _DelFolderVIIEntry()
		{
			// check required parameters
			CheckRequiredParameters("CNameInSubDir", "ShareOnServers",
									"Ident_DomainGlobalGroup", "Ident_GlobalGroup", "Ident_WorkFolder");

			// build "folder<GlobalGroup>.vii" path
			StringBuilder folderViiPath = new StringBuilder();

			folderViiPath.Append(_GetCombinedPath(true, "NETLOGON"));

			if ( (_IsValidParameter("CNameInSubDir") && GetParameterAsBoolean("CNameInSubDir"))
				 && (Parameters["ShareOnServers"].Value.Length > 0) )
			{
				folderViiPath.Append(Path.DirectorySeparatorChar);
				folderViiPath.Append(Parameters["ShareOnServers"].Value);
			}

			folderViiPath.Append(Path.DirectorySeparatorChar);
			folderViiPath.Append("folder");
			folderViiPath.Append(Parameters["Ident_DomainGlobalGroup"].Value);
			folderViiPath.Append(".vii");

			// remove work folder key from global group section
			FileTransaction foldervii = new FileTransaction(_GetLocalPath(folderViiPath.ToString()), _GetEncodingFromParameters());

			foldervii.BeginSection(Parameters["Ident_GlobalGroup"].Value, false);
			foldervii.WriteKey(Parameters["Ident_WorkFolder"].Value, null);
			foldervii.Commit();
		}

		// method for job task "InsertGroups"
		private void _InsertGroups()
		{
			// check required parameters
			CheckRequiredParameters("FileName");

			FileTransaction trans = new FileTransaction(_GetLocalPath(Parameters["FileName"].Value), _GetEncodingFromParameters());

			bool initGroupSection = ( Parameters.Contains("Append")
									  && GetParameterAsBoolean("Append") )
									|| (!Parameters.Contains("Append"));

			trans.BeginSection("Gruppen", initGroupSection);

			if (Parameters.Contains("Groups"))
			{
				string []groups = Parameters["Groups"].Value.Split('|');

				foreach (string group in groups)
				{
					trans.WriteKey(group, "True");
				}
			}

			for (long index = 0; Parameters.Contains("Group_" + index); index ++)
			{
				trans.WriteKey(Parameters["Group_" + index].Value, "True");
			}

			if (Parameters.Contains("Comment"))
			{
				trans.BeginSection("Diverse", true);

				trans.WriteKey("Kommentar", Parameters["Comment"].Value);
			}

			trans.Commit();
		}

		// method for job task "RemoveGroups"
		private void _RemoveGroups()
		{
			// check required parameters
			CheckRequiredParameters("FileName");

			FileTransaction trans = new FileTransaction(_GetLocalPath(Parameters["FileName"].Value), _GetEncodingFromParameters());

			trans.BeginSection("Gruppen", false);

			if (Parameters.Contains("Groups"))
			{
				string []groups = Parameters["Groups"].Value.Split('|');

				foreach (string group in groups)
				{
					trans.WriteKey(group, null);
				}
			}

			for (long index = 0; Parameters.Contains("Group_" + index); index ++)
			{
				trans.WriteKey(Parameters["Group_" + index].Value, null);
			}

			trans.Commit();
		}

		private void _WriteVIISection()
		{
			CheckRequiredParameters("FileName", "Sections");

			string filename = Parameters["FileName"].Value;

#if DEBUG
			string sections = Parameters["Sections"].Value.Replace("\\n", "\n");
#else
			string sections = Parameters["Sections"].Value;
#endif

			bool append = GetParameterAsBoolean("Append");

			FileTransaction vii = new FileTransaction(_GetLocalPath(filename), _GetEncodingFromParameters());
			vii.WriteSections(sections, !append);
			vii.Commit();
		}

		#endregion // task functions

		private static string _GetComputerName()
		{
			return AppData.Instance.RuntimeEnvironment.IsMono ? Environment.MachineName : SystemInformation.ComputerName;
		}

		private void _WriteProfileVii(string serverNetRootPath,
									  _ProfileType type, _ProfileKind kind, IDictionary<string, string> strings)
		{
			// build profile.vii path
			string profileViiPath;

			if (_IsValidParameter("ClientPartApplication"))
			{
				profileViiPath = _GetCombinedPath(false, serverNetRootPath,
												  Parameters["ClientPartApplication"].Value, Parameters["SubPath"].Value);
			}
			else
			{
				// check required parameters
				CheckRequiredParameters("ClientPartDriver");

				profileViiPath = _GetCombinedPath(false, serverNetRootPath,
												  Parameters["ClientPartDriver"].Value, Parameters["SubPath"].Value);
			}

			string workPath = profileViiPath;

			string usrShellVipPath = _GetCombinedPath(false, profileViiPath, "usrshell.vip");

			profileViiPath = Path.Combine(profileViiPath, "profile.vii");

			string localProfileViiPath = _GetLocalPath(profileViiPath);

			if (!Directory.Exists(Path.GetDirectoryName(localProfileViiPath)))
			{
				throw new DirectoryNotFoundException(string.Format("Directory '{0}' does not exists",
													 Path.GetDirectoryName(localProfileViiPath)));
			}

			Result.Messages.Add(string.Format("Prepare to write '{0}'.", localProfileViiPath));

			FileTransaction profilevii = new FileTransaction(localProfileViiPath, _GetEncodingFromParameters());

			profilevii.BeginSection(Parameters["SectionName"].Value,
									kind == _ProfileKind.Old);

			StringBuilder clientPath = new StringBuilder();

			if (Parameters["ServerVariable"].Value.Length == 0)
			{
				clientPath.AppendFormat("\\\\{0}\\", Parameters["TASName"].Value);
			}
			else
			{
				if (Parameters["ServerVariable"].Value.IndexOf(':') >= 0)
					clientPath.AppendFormat("{0}\\", Parameters["ServerVariable"].Value);
				else
					clientPath.AppendFormat("\\\\{0}\\", Parameters["ServerVariable"].Value);
			}

			if (Parameters["DomainMasterShare"].Value.Length == 0)
			{
				clientPath.AppendFormat("{0}\\{1}\\{2}", Parameters["ShareOnServers"].Value,
										Parameters["ClientPartPathOnServers"].Value, Parameters["SubPath"].Value);
			}
			else
			{
				clientPath.AppendFormat("{0}\\{1}\\{2}", Parameters["DomainMasterShare"].Value,
										Parameters["ClientPartPathOnServers"].Value, Parameters["SubPath"].Value);
			}

			StringBuilder link = new StringBuilder();

			if (Parameters["ServerVariable"].Value.Length == 0)
			{
				link.AppendFormat("\\\\{0},", Parameters["TASName"].Value);
			}
			else
			{
				link.AppendFormat(Parameters["ServerVariable"].Value.IndexOf(':') >= 0 ? "{0}," : "\\\\{0},",
								  Parameters["ServerVariable"].Value);
			}

			if (_IsValidParameter("ServerDrive"))
			{
				if (_IsValidParameter("DomainServerShare"))
				{
					link.AppendFormat("{0},{1}", Parameters["DomainServerShare"].Value,
									  Parameters["ServerDrive"].Value);
				}
				else
				{
					// check required parameters
					CheckRequiredParameters("ServerPartShareOnServers");

					link.AppendFormat("{0},{1}", Parameters["ServerPartShareOnServers"].Value,
									  Parameters["ServerDrive"].Value);
				}

				if (Parameters["ServerDrive"].Value.Length == 1)
				{
					link.Append(':');
				}

				profilevii.WriteKey(_GetString(strings, "gStrVIFile_PROFILE_LINK"), link.ToString());
			}

			if (_IsValidParameter("ProfileType"))
			{
				profilevii.WriteKey(_GetString(strings, "gStrVIFile_PROFILE_ProfileType"), Parameters["ProfileType"].Value);
			}

			if (_IsValidParameter("Autark"))
			{
				profilevii.WriteKey(_GetString(strings, "gStrVIFile_PROFILE_Autarkic"),
									Parameters["Autark"].Value.ToUpperInvariant());
			}

			if (_IsValidParameter("HashValue"))
			{
				profilevii.WriteKey(_GetString(strings, "gStrVIFile_PROFILE_HashValue"),
									Parameters["HashValue"].Value);
			}

			StringBuilder tempLink = new StringBuilder();

			if (Parameters["ServerVariable"].Value.Length == 0)
			{
				tempLink.AppendFormat("\\\\{0},", Parameters["TASName"].Value);
			}
			else
			{
				if (Parameters["ServerVariable"].Value.IndexOf(':') == -1)
				{
					tempLink.Append("\\\\");
				}

				tempLink.AppendFormat("{0},", Parameters["ServerVariable"].Value);
			}

			tempLink.AppendFormat("{0},{1}",
								  Parameters["DomainServerShare"].Value.Length == 0
								  ? Parameters["ShareOnServers"].Value
								  : Parameters["DomainMasterShare"].Value,
								  Parameters["ClientDrive"].Value);

			if (Parameters["ClientDrive"].Value.Length == 1)
				tempLink.Append(':');

			profilevii.WriteKey(_GetString(strings, "gStrVIFile_PROFILE_TEMPLINK"),
								tempLink.ToString());

			long chgNumber = _IsValidParameter("IsFDSProfile") && GetParameterAsBoolean("IsFDSProfile")
							 ? Convert.ToInt64(Parameters["ChgNumber"].Value)
							 : Convert.ToInt64(Parameters["ChgTest"].Value);

			profilevii.WriteKey(_GetString(strings, "gStrVIFile_PROFILE_CHGNR"),
								chgNumber.ToString());

			if (_IsValidParameter("OSMode"))
				profilevii.WriteKey(_GetString(strings, "gStrVIFile_PROFILE_OSMODE"),
									Parameters["OSMode"].Value);

			if (_IsValidParameter("ClientStepCounter"))
				profilevii.WriteKey(_GetString(strings, "gStrVIFile_PROFILE_AnzahlEintraege"),
									Parameters["ClientStepCounter"].Value);

			if (_IsValidParameter("Description"))
				profilevii.WriteKey(_GetString(strings, "gStrVIFile_PROFILE_Bezeichnung"),
									Parameters["Description"].Value);

			if (_IsValidParameter("OrderNumber"))
				profilevii.WriteKey(_GetString(strings, "gStrVIFile_PROFILE_OrdnungsNr"),
									Parameters["OrderNumber"].Value);

			if (_IsValidParameter("MemoryUsage"))
				profilevii.WriteKey(_GetString(strings, "gStrVIFile_PROFILE_Speicherbedarf"),
									Parameters["MemoryUsage"].Value);

			if (_IsValidParameter("PackagePath"))
				profilevii.WriteKey(_GetString(strings, "gStrVIFile_PROFILE_PackagePath"),
									Parameters["PackagePath"].Value);

			if (_IsValidParameter("CachingBehavior"))
				profilevii.WriteKey(_GetString(strings, "gStrVIFile_PROFILE_CachingBehaviour"),
									Parameters["CachingBehavior"].Value);

			if (_IsValidParameter("RemoveHKeyCurrentUser"))
				profilevii.WriteKey(_GetString(strings, "gStrVIFile_PROFILE_RemoveHKeyCurrentUser"),
									GetParameterAsBoolean("RemoveHKeyCurrentUser") ? "TRUE" : "FALSE");

			Result.Messages.Add(string.Format("Begin to write '{0}'.", localProfileViiPath));

			profilevii.Commit();

			Result.Messages.Add(string.Format("'{0}' successfully written.", localProfileViiPath));

			if (type == _ProfileType.ApplicationProfile)
				_CreateFileIfNotExist(usrShellVipPath);

			if (workPath.Length > 0)
			{
				_CreateFileIfNotExist(workPath, "macfiles.vip");
				_CreateFileIfNotExist(workPath, "usrfiles.vip");
				_CreateFileIfNotExist(workPath, "usrreg.vip");
				_CreateFileIfNotExist(workPath, "macreg.vip");
				_CreateFileIfNotExist(workPath, "usrshell.vip");
				_CreateFileIfNotExist(workPath, "macshell.vip");
				_CreateFileIfNotExist(workPath, "vivars.ini");
				_CreateFileIfNotExist(workPath, "usrini.vip");
				_CreateFileIfNotExist(workPath, "macini.vip");
			}
		}

		private void _WritePathVii(string serverNetRootPath, _ProfileType type)
		{
			// build path.vii path
			string pathViiPath = Path.Combine(serverNetRootPath, "path.vii");

			string localPathViiPath = _GetLocalPath(pathViiPath);

			StringBuilder clientPath = new StringBuilder();
			string chgNumber = null;

			if (Parameters["ServerVariable"].Value.Length == 0)
			{
				clientPath.AppendFormat("\\\\{0}\\", Parameters["TASName"].Value);
			}
			else
			{
				clientPath.AppendFormat(Parameters["ServerVariable"].Value.IndexOf(':') == -1 ? "\\\\{0}\\" : "{0}\\",
										Parameters["ServerVariable"].Value);

				clientPath.AppendFormat("{0}\\{1}",
										Parameters["DomainMasterShare"].Value.Length == 0
										? Parameters["ShareOnServers"].Value
										: Parameters["DomainMasterShare"].Value,
										Parameters["ClientPartPathOnServers"].Value);

				clientPath.AppendFormat("\\{0}",
										type == _ProfileType.ApplicationProfile
										? Parameters["ClientPartApplication"].Value
										: Parameters["ClientPartDriver"].Value);

				clientPath.AppendFormat("\\{0}", Parameters["SubPath"].Value);
			}

			/*
			 * Append change number
			 */
			if ( GetParameterAsBoolean("IsFDSProfile") )
			{
				if ( Parameters.Contains("ChgNumber") )
					chgNumber = Parameters["ChgNumber"].Value;
			}
			else
			{
				if ( Parameters.Contains("ChgTest") )
					chgNumber = Parameters["ChgTest"].Value;
			}

			if ( chgNumber != null )
			{
				clientPath.Append(":");
				clientPath.Append(chgNumber);
			}

			Result.Messages.Add(string.Format("Begin to write '{0}' entry", localPathViiPath));

			// following check will be removed in a later version
			// if is sure, that only valid application or driver profiles are given
			if (!_IsValidParameter("InstType0") && !Parameters.Contains("Ident_InstType"))
			{
				Result.Messages.Add("The given profile does neither have a parameter \"InstType0\" nor a parameter \"Ident_InstType\", so it is not a valid application or driver profile.");
			}
			else
			{
				FileTransaction pathvii = new FileTransaction(localPathViiPath, _GetEncodingFromParameters());

				if (_IsValidParameter("InstType0"))
				{
					pathvii.BeginSection(Parameters["SectionName"].Value, false);

					for (long index = 0; Parameters.Contains("InstType" + index); index ++)
					{
						string key =
							string.Format("{0} {1}", Parameters["Ident_OS"].Value, Parameters["InstType" + index].Value);

						pathvii.WriteKey(key, clientPath.ToString());
					}
				}
				else
				{
					// check required parameters
					CheckRequiredParameters("Ident_OS", "Ident_InstType");

					pathvii.BeginSection(Parameters["SectionName"].Value, false);

					for (long index = 0; Parameters.Contains("ProfileCUA_Ident_InstTypeAlso" + index); index ++)
					{
						string alias =
							string.Format("{0} {1}", Parameters["ProfileCUA_Ident_OSAlso" + index], Parameters["ProfileCUA_Ident_InstTypeAlso" + index].Value);

						pathvii.WriteKey(alias, clientPath);
					}

					string key =
						string.Format("{0} {1}", Parameters["Ident_OS"].Value, Parameters["Ident_InstType"].Value);

					pathvii.WriteKey(key, clientPath.ToString());
				}

				pathvii.Commit();

				Result.Messages.Add(string.Format("'{0}' successfully written.", localPathViiPath));
			}
		}

		private void _WriteCNameVii(IDictionary<string, string> strings)
		{
			string fileName =
				_GetCombinedPath(true, Parameters["CNamePath"].Value, Parameters["Ident_Machine"].Value) + ".vii";

			string localPath = _GetLocalPath(fileName);

			Result.Messages.Add(string.Format("Local path for \"{0}\" is \"{1}\"",
											  fileName, localPath));

			// All in one transaction
			FileTransaction cname = new FileTransaction(localPath, _GetEncodingFromParameters());

			// groups section
			cname.BeginSection(_GetString(strings, "gStrVIFile_CNAME_GRUPPEN"), true);

			for (long index = 0; Parameters.Contains("INISection" + index); index ++)
			{
				cname.WriteKey(Parameters["INISection" + index].Value, "True");
			}

			// roles section
			cname.BeginSection(_GetString(strings, "gStrVIFile_CNAME_ROLLEN"), true);

			for (long index = 0; Parameters.Contains("ORG" + index); index ++)
			{
				cname.WriteKey(Parameters["ORG" + index].Value, Parameters["ORG" + index].Value);
			}

			// divers section
			cname.BeginSection(_GetString(strings, "gStrVIFile_CNAME_DIVERSE"), true);

			if (_IsValidParameter("Ident_OS"))
				cname.WriteKey(_GetString(strings, "gStrVIFile_CNAME_VIOS"), Parameters["Ident_OS"].Value);

			if (_IsValidParameter("Ident_InstType"))
				cname.WriteKey(_GetString(strings, "gStrVIFile_CNAME_VIINSTTYPE"), Parameters["Ident_InstType"].Value);

			cname.WriteKey(_GetString(strings, "gStrVIFile_CNAME_DisableClient"),
						   Parameters.Contains("DisableVIClient") ? Parameters["DisableVIClient"].Value : "0");

			if (Parameters.Contains("VIDomainGroupName") && (Parameters["VIDomainGroupName"].Value.Length > 0))
				cname.WriteKey(_GetString(strings, "gStrVIFile_CNAME_VI_DOMAINGROUP"),
							   Parameters["VIDomainGroupName"].Value);


			if (_IsValidParameter("CNameWithSetup") && GetParameterAsBoolean("CNameWithSetup"))
			{
				// setup section
				cname.BeginSection("SETUP", true);

				if (_IsValidParameter("Ident_Machine"))
					cname.WriteKey("ComputerName", Parameters["Ident_Machine"].Value);

				if (_IsValidParameter("Ident_DomainMachine"))
					cname.WriteKey("Domain", Parameters["Ident_DomainMachine"].Value);

				if (_IsValidParameter("Ident_MachineType"))
					cname.WriteKey("INF", Parameters["Ident_MachineType"].Value + ".INF");

				if (_IsValidParameter("Ident_MachineType"))
					cname.WriteKey("MacType", Parameters["Ident_MachineType"].Value);

				if (_IsValidParameter("Ident_OS"))
					cname.WriteKey("Ostype", Parameters["Ident_OS"].Value);

				if (_IsValidParameter("DefaultUserContext"))
					cname.WriteKey("DefContext", Parameters["DefaultUserContext"].Value);

				if (_IsValidParameter("MacSetupLIC"))
					cname.WriteKey("ORG", Parameters["MacSetupLIC"].Value);

				if (Parameters.Contains("NDSPreferedServer")
					&& (Parameters["NDSPreferedServer"].Value.Length > 0))
					cname.WriteKey(Parameters["NDSPreferedServer"].Value, Parameters["HomeServerOfDefaultUser"].Value);

				if (_IsValidParameter("DefaultWorkGroup"))
					cname.WriteKey("WGroup", Parameters["DefaultWorkGroup"].Value);

				if (_IsValidParameter("Ident_Machine"))
					cname.WriteKey("Owner", Parameters["Ident_Machine"].Value);

				if (Parameters.Contains("Ident_Locality")
					&& (Parameters["Ident_Locality"].Value.Length > 0))
					cname.WriteKey("Location", Parameters["Ident_Locality"].Value);

				if (Parameters.Contains("LocalityFree")
					&& (Parameters["LocalityFree"].Value.Length > 0))
					cname.WriteKey("FullName", Parameters["LocalityFree"].Value);

				if (_IsValidParameter("Ident_Machine"))
					cname.WriteKey("Owner", Parameters["Ident_Machine"].Value);

				if (_IsValidParameter("DisplayBitsPerPel"))
					cname.WriteKey("BitsPerPel", Parameters["DisplayBitsPerPel"].Value);

				if (_IsValidParameter("DisplayXRes"))
					cname.WriteKey("XResolution", Parameters["DisplayXRes"].Value);

				if (_IsValidParameter("DisplayYRes"))
					cname.WriteKey("YResolution", Parameters["DisplayYRes"].Value);

				if (_IsValidParameter("DisplayVRefresh"))
					cname.WriteKey("VRefresh", Parameters["DisplayVRefresh"].Value);

				if (_IsValidParameter("UseDHCP") && GetParameterAsBoolean("UseDHCP"))
					cname.WriteKey("DHCP", "yes");
				else
					cname.WriteKey("DHCP", "no");

				if (_IsValidParameter("IPAddress"))
					cname.WriteKey("IPAddr", _GetFormattedIPAddress(Parameters["IPAddress"].Value, _IPAddressFormat.Short));

				if (_IsValidParameter("SubnetMask"))
					cname.WriteKey("Subnet", _GetFormattedIPAddress(Parameters["SubnetMask"].Value, _IPAddressFormat.Short));

				if (_IsValidParameter("DefaultGateway"))
					cname.WriteKey("Gateway", _GetFormattedIPAddress(Parameters["DefaultGateway"].Value, _IPAddressFormat.Short));

				if (_IsValidParameter("UseDNS") && GetParameterAsBoolean("UseDNS"))
				{
					cname.WriteKey("DNS", "yes");

					StringBuilder dnsServer = new StringBuilder();

					for (int count = 1; Parameters.Contains("DNSServer" + count); count ++)
					{
						if (Parameters["DNSServer" + count].Value.Length > 0)
						{
							dnsServer.AppendFormat("{0},",
												   _GetFormattedIPAddress(Parameters["DNSServer" + count].Value, _IPAddressFormat.Short));
						}
					}

					cname.WriteKey("DNSServer", dnsServer.ToString().TrimEnd(','));

					if (Parameters["DNSName"].Value.Length > 0)
						cname.WriteKey("DNSName", Parameters["DNSName"].Value);

					if (Parameters["ScopeID"].Value.Length > 0)
						cname.WriteKey("ScopeID", Parameters["ScopeID"].Value);
				}
				else
				{
					cname.WriteKey("DNS", "no");
				}

				if (_IsValidParameter("UseWINS") && GetParameterAsBoolean("UseWINS"))
				{
					cname.WriteKey("WINS", "yes");

					if (Parameters["WINSPrimary"].Value.Length > 0)
						cname.WriteKey("WINSPrimary", _GetFormattedIPAddress(Parameters["WINSPrimary"].Value, _IPAddressFormat.Short));

					if (Parameters["WINSSecondary"].Value.Length > 0)
						cname.WriteKey("WINSSecondary", _GetFormattedIPAddress(Parameters["WINSSecondary"].Value, _IPAddressFormat.Short));
				}
				else
				{
					cname.WriteKey("WINS", "no");
				}
			}

			if (_IsValidParameter("CNameWithWorkdesk") && GetParameterAsBoolean("CNameWithWorkdesk"))
			{
				cname.BeginSection("WORKDESK", true);

				if (_IsValidParameter("Ident_WorkDesk"))
					cname.WriteKey("Name", Parameters["Ident_WorkDesk"].Value);

				if (_IsValidParameter("PrinterQueueName"))
					cname.WriteKey("PrinterQueueName", Parameters["PrinterQueueName"].Value);

				if (_IsValidParameter("DefContext"))
					cname.WriteKey("DefContext", Parameters["DefContext"].Value);

				if ( Parameters.Contains("NDSPreferedServer")
					 && (Parameters["NDSPreferedServer"].Value.Length > 0) )
					cname.WriteKey(Parameters["NDSPreferedServer"].Value, Parameters["HomeServerOfDefaultUser"].Value);
			}

			// Write cname.vii
			cname.Commit();
		}

		private void _WriteMacTypeUdfEntry()
		{
			string localityFree = Parameters["LocalityFree"].Value;

			localityFree.Trim(' ', '"', '\'');

			if (localityFree.IndexOf(' ') >= 0)
			{
				localityFree.Insert(0, "\"");
				localityFree += "\"";
			}

			string fileName = _GetCombinedPath(true, Parameters["MacTypePath"].Value);

			string subDir = Path.Combine(fileName, Parameters["Ident_MachineType"].Value);

			if (Directory.Exists(_GetLocalPath(subDir)))
			{
				fileName = Path.Combine(fileName, Parameters["Ident_MachineType"].Value);
			}

			fileName = Path.Combine(fileName, Parameters["Ident_MachineType"].Value);
			fileName += ".udf";

			string localPath = _GetLocalPath(fileName);

			Result.Messages.Add(string.Format("Local path for \"{0}\" is \"{1}\"",
											  fileName, localPath));

			FileTransaction udf = new FileTransaction(localPath, _GetEncodingFromParameters());

			udf.BeginSection("UniqueIds", false);

			if (_IsValidParameter("MACID"))
			{
				udf.WriteKey(Parameters["MACID"].Value,
							 "Network,TCParameters,UserData,Display,Identification");
			}

			if (_IsValidParameter("Ident_Machine"))
			{
				udf.WriteKey(Parameters["Ident_Machine"].Value,
							 "Network,TCParameters,UserData,Display,Identification");
			}

			string [] sectionPrefixes = {Parameters["MACID"].Value, Parameters["Ident_Machine"].Value};

			foreach (string sectionPrefix in sectionPrefixes)
			{
				// [<Prefix>:Network]
				udf.BeginSection(sectionPrefix + ":Network", true);

				if (_IsValidParameter("Ident_DomainMachine"))
				{
					udf.WriteKey("JoinDomain", Parameters["Ident_DomainMachine"].Value);
				}

				// [<Prefix>:Identification]
				udf.BeginSection(sectionPrefix + ":Identification", true);

				if (_IsValidParameter("Ident_DomainMachine"))
				{
					udf.WriteKey("JoinDomain", Parameters["Ident_DomainMachine"].Value);
				}

				if (Parameters.Contains("MachineObjectOU")
					&& Parameters["MachineObjectOU"].Value.Length > 0)
				{
					udf.WriteKey("MachineObjectOU", Parameters["MachineObjectOU"].Value);
				}

				// [<Prefix>:UserData]
				udf.BeginSection(sectionPrefix + ":UserData", true);

				if (localityFree.Length > 0)
				{
					udf.WriteKey("FullName", localityFree);
				}

				if (_IsValidParameter("Ident_Machine"))
				{
					udf.WriteKey("ComputerName", Parameters["Ident_Machine"].Value);
				}

				// [<Prefix>:Display]
				udf.BeginSection(sectionPrefix + ":Display", true);

				if (_IsValidParameter("DisplayBitsPerPel"))
				{
					udf.WriteKey("BitsPerPel", Parameters["DisplayBitsPerPel"].Value);
				}

				if (_IsValidParameter("DisplayXRes"))
				{
					udf.WriteKey("XResolution", Parameters["DisplayXRes"].Value);
				}

				if (_IsValidParameter("DisplayYRes"))
				{
					udf.WriteKey("YResolution", Parameters["DisplayYRes"].Value);
				}

				if (_IsValidParameter("DisplayVRefresh"))
				{
					udf.WriteKey("VRefresh", Parameters["DisplayVRefresh"].Value);
				}

				// [<Prefix>:TCParameters]
				udf.BeginSection(sectionPrefix + ":TCParameters", true);

				if (_IsValidParameter("UseDHCP") && GetParameterAsBoolean("UseDHCP"))
				{
					udf.WriteKey("DHCP", "yes");
				}
				else
				{
					udf.WriteKey("DHCP", "no");
				}

				if (_IsValidParameter("IPAddress"))
				{
					udf.WriteKey("IPAddress",
								 _GetFormattedIPAddress(Parameters["IPAddress"].Value, _IPAddressFormat.Short));
				}

				if (_IsValidParameter("SubnetMask"))
				{
					udf.WriteKey("Subnet",
								 _GetFormattedIPAddress(Parameters["SubnetMask"].Value, _IPAddressFormat.Short));

					udf.WriteKey("SubnetMask",
								 _GetFormattedIPAddress(Parameters["SubnetMask"].Value, _IPAddressFormat.Short));
				}

				if (_IsValidParameter("DefaultGateway"))
				{
					udf.WriteKey("Gateway",
								 _GetFormattedIPAddress(Parameters["DefaultGateway"].Value, _IPAddressFormat.Short));

					udf.WriteKey("DefaultGateway",
								 _GetFormattedIPAddress(Parameters["DefaultGateway"].Value, _IPAddressFormat.Short));
				}

				if (_IsValidParameter("UseDNS") && GetParameterAsBoolean("UseDNS"))
				{
					udf.WriteKey("DNS", "yes");

					StringBuilder dnsServer = new StringBuilder();

					for (int count = 1; Parameters.Contains("DNSServer" + count); count ++)
					{
						if (Parameters["DNSServer" + count].Value.Length > 0)
						{
							dnsServer.AppendFormat("{0},",
												   _GetFormattedIPAddress(Parameters["DNSServer" + count].Value, _IPAddressFormat.Short));
						}
					}

					udf.WriteKey("DNSServer", dnsServer.ToString().TrimEnd(','));
					udf.WriteKey("DNSServerSearchOrder", dnsServer.ToString().TrimEnd(','));

					if ( Parameters.Contains("DNSName") &&
						 (Parameters["DNSName"].Value.Length > 0) )
					{
						udf.WriteKey("DNSName", Parameters["DNSName"].Value);
						udf.WriteKey("DNSDomain", Parameters["DNSName"].Value);
					}

					if ( Parameters.Contains("ScopeID") &&
						 (Parameters["ScopeID"].Value.Length > 0) )
					{
						udf.WriteKey("ScopeID", Parameters["ScopeID"].Value);
					}
				}
				else
				{
					udf.WriteKey("DNS", "no");
				}

				if (_IsValidParameter("UseWINS") && GetParameterAsBoolean("UseWINS"))
				{
					udf.WriteKey("WINS", "yes");

					StringBuilder wins = new StringBuilder();

					string strIP;

					if ( Parameters.Contains("WINSPrimary") &&
						 (Parameters["WINSPrimary"].Value.Length > 0) )
					{
						strIP = _GetFormattedIPAddress(Parameters["WINSPrimary"].Value, _IPAddressFormat.Short);

						udf.WriteKey("WINSPrimary", strIP);
						wins.AppendFormat("{0},", strIP);
					}

					if ( Parameters.Contains("WINSSecondary") &&
						 (Parameters["WINSSecondary"].Value.Length > 0) )
					{
						strIP = _GetFormattedIPAddress(Parameters["WINSSecondary"].Value, _IPAddressFormat.Short);

						udf.WriteKey("WINSSecondary", strIP);
						wins.Append(strIP);
					}

					udf.WriteKey("WinsServerList", wins.ToString().TrimEnd(','));
				}
				else
				{
					udf.WriteKey("WINS", "no");
				}
			}

			udf.Commit();
		}

		private void _RemoveMactypeUdfEntry()
		{
			string fileName = _GetCombinedPath(true, Parameters["MacTypePath"].Value);

			Result.Messages.Add(string.Format("Try to resolve local path for Unc - path: \"{0}\".", fileName));

			string subDir = Path.Combine(fileName, Parameters["Ident_MachineType"].Value);

			if (Directory.Exists(_GetLocalPath(subDir)))
			{
				fileName = Path.Combine(fileName, Parameters["Ident_MachineType"].Value);
			}

			fileName = Path.Combine(fileName, Parameters["Ident_MachineType"].Value);
			fileName += ".udf";

			string localPath = _GetLocalPath(fileName);

			Result.Messages.Add(string.Format("Local path for \"{0}\" is \"{1}\"",
											  fileName, localPath));

			if (File.Exists(localPath))
			{
				FileTransaction udf = new FileTransaction(localPath, _GetEncodingFromParameters());

				udf.BeginSection("UniqueIds", false);

				udf.WriteKey(Parameters["MACID"].Value, null);
				udf.WriteKey(Parameters["Ident_Machine"].Value, null);

				string [] sectionPrefixes = {Parameters["MACID"].Value, Parameters["Ident_Machine"].Value};

				foreach (string sectionPrefix in sectionPrefixes)
				{
					// [<Prefix>:Network]
					udf.BeginSection(sectionPrefix + ":Network", true);

					// [<Prefix>:Identification]
					udf.BeginSection(sectionPrefix + ":Identification", true);

					// [<Prefix>:UserData]
					udf.BeginSection(sectionPrefix + ":UserData", true);

					// [<Prefix>:Display]
					udf.BeginSection(sectionPrefix + ":Display", true);

					// [<Prefix>:TCParameters]
					udf.BeginSection(sectionPrefix + ":TCParameters", true);
				}

				udf.Commit();
			}
		}

		private void _WriteMac2NameViiEntry(IDictionary<string, string> strings)
		{
			string fileName = _GetCombinedPath(true, Parameters["NetPath"].Value, "mac2name.vii");

			Result.Messages.Add(string.Format("Try to resolve local path for Unc - path: \"{0}\".", fileName));

			string localPath = _GetLocalPath(fileName);

			Result.Messages.Add(string.Format("Local path for \"{0}\" is \"{1}\"", fileName, localPath));

			if ( _IsValidParameter("Ident_Machine")
				 && _IsValidParameter("Ident_MachineType") )
			{
				FileTransaction mac2name = new FileTransaction(localPath, _GetEncodingFromParameters());

				mac2name.BeginSection(_GetString(strings, "gStrVIFile_MAC2NAME_MACTYPE"), false);
				mac2name.WriteKey(Parameters["Ident_Machine"].Value, Parameters["Ident_MachineType"].Value);

				mac2name.BeginSection(_GetString(strings, "gStrVIFile_MAC2NAME_MAC2NAME"), false);
				mac2name.WriteKey(Parameters["MACID"].Value, Parameters["Ident_Machine"].Value);

				mac2name.Commit();
			}
		}

		private void _RemoveMac2NameViiEntry(IDictionary<string, string> strings)
		{
			string fileName = _GetCombinedPath(true, Parameters["NetPath"].Value, "mac2name.vii");

			Result.Messages.Add(string.Format("Try to resolve local path for Unc - path: \"{0}\".", fileName));

			string localPath = _GetLocalPath(fileName);

			Result.Messages.Add(string.Format("Local path for \"{0}\" is \"{1}\"", fileName, localPath));

			if (File.Exists(localPath))
			{
				if ( _IsValidParameter("Ident_Machine")
					 && _IsValidParameter("Ident_MachineType") )
				{
					FileTransaction mac2name = new FileTransaction(localPath, _GetEncodingFromParameters());

					mac2name.BeginSection(_GetString(strings, "gStrVIFile_MAC2NAME_MACTYPE"), false);
					mac2name.WriteKey(Parameters["Ident_Machine"].Value, null);

					mac2name.BeginSection(_GetString(strings, "gStrVIFile_MAC2NAME_MAC2NAME"), false);
					mac2name.WriteKey(Parameters["MACID"].Value, null);

					mac2name.Commit();
				}
			}
		}

		private void _WriteRplLst(char action)
		{
			string fileName = _GetCombinedPath(true, Parameters["NetPath"].Value, "RPL.LST");

			Result.Messages.Add(string.Format("Try to resolve local path for Unc - path: \"{0}\".", fileName));

			try
			{
				using ( StreamWriter streamWriter = new StreamWriter(_GetLocalPath(fileName), true, Encoding.Default) )
				{
					streamWriter.WriteLine("{0}:{1}:#{2}:{3}", action, Parameters["MACID"].Value,
										   Parameters["Ident_Machine"].Value, Parameters["Ident_MachineType"].Value);
				}
			}
			catch ( Exception exc )
			{
				throw new ViException(818005, exc, fileName);
			}
		}

		private bool _IsValidParameter(string parameterName)
		{
			return Parameters.Contains(parameterName)
				   && (Parameters[parameterName].Value.Length > 0);
		}

		private string _GetCombinedPath(bool isRootPath, params string[] pathParts)
		{
			StringBuilder stbRet = new StringBuilder();
			long lowerBoundStart = pathParts.GetLowerBound(0);

			if (isRootPath)
			{
				if (pathParts.Length > 0)
				{

					if ( _IsValidParameter("ServerName") )
					{
						// set defined Servername
						stbRet.AppendFormat("\\\\{0}\\", Parameters["ServerName"].Value);
					}
					else if (!pathParts[0].StartsWith("\\\\"))
					{
						stbRet.AppendFormat("\\\\{0}\\", _GetComputerName());
					}
					else
					{
						stbRet.Append(pathParts[0]);
						lowerBoundStart++;
					}
				}
			}

			for (long count = lowerBoundStart; count <= pathParts.GetUpperBound(0); count ++)
			{
				string currPathPart = pathParts.GetValue(count).ToString();

				if (!currPathPart.StartsWith("\\\\"))
				{
					currPathPart = currPathPart.Trim('\\');
				}

				stbRet.AppendFormat("{0}{1}", currPathPart, Path.DirectorySeparatorChar);
			}

			// remove trailing '\'
			stbRet.Remove(stbRet.Length - 1, 1);

			return stbRet.ToString();
		}

		private static string _GetLocalPath(string uncPath)
		{
			SambaUncPath sambaUncPath = new SambaUncPath(uncPath);

			if (!sambaUncPath.IsLocal)
			{
				if ( AppData.Instance.RuntimeEnvironment.IsMono )
					throw new ViException(818000, uncPath);

				// All paths are "local" on windows
				return Path.Combine(sambaUncPath.SharePart, sambaUncPath.RemotePathPart);
			}

			return sambaUncPath.LocalPath;
		}

		private static string _GetFormattedIPAddress(string ipAddress, _IPAddressFormat addressFormat)
		{
			string ipRet = "";
			string []ipSeg = ipAddress.Split('.');

			if (ipSeg.Length == 4)
			{
				switch (addressFormat)
				{
					case _IPAddressFormat.Short:
						ipRet = string.Format("{0}.{1}.{2}.{3}",
											  Convert.ToInt32(ipSeg[0]), Convert.ToInt32(ipSeg[1]),
											  Convert.ToInt32(ipSeg[2]), Convert.ToInt32(ipSeg[3]));
						break;

					case _IPAddressFormat.Long:
						ipRet = string.Format("{0:000}.{1:000}.{2:000}.{3:000}",
											  Convert.ToInt32(ipSeg[0]), Convert.ToInt32(ipSeg[1]),
											  Convert.ToInt32(ipSeg[2]), Convert.ToInt32(ipSeg[3]));
						break;
				}
			}

			return ipRet;
		}

		private IDictionary<string, string> _GetStrings(string language)
		{
			lock ( _languages )
			{
				IDictionary<string, string> strings;

				if ( _languages.TryGetValue(language, out strings) )
					return strings;

				VIIStringProvider provider = new VIIStringProvider(
					GetType().Assembly,	// read from resources
					"VI.JobService.JobComponents.Resources.ControlFilesComponent.VII");

				strings = provider.GetStrings(language);
				_languages.Add(language, strings);

				return strings;

			}
		}

		private static string _GetString(IDictionary<string, string> strings, string key)
		{
			if ( string.IsNullOrEmpty(key) )
				return string.Empty;

			string ret;

			return strings.TryGetValue(key, out ret) ? ret : string.Empty;
		}

		private static void _CreateFileIfNotExist(string fName)
		{
			try
			{
				string local = _GetLocalPath(fName);

				if ( ! File.Exists(local) )
				{
					FileStream fileStream = new FileStream(local,
														   FileMode.Append, FileAccess.Write);

					fileStream.Close();
				}
			}
			catch ( Exception exc )
			{
				throw new ViException(818004, exc, fName);
			}
		}

		private static void _CreateFileIfNotExist(string path, string name)
		{
			_CreateFileIfNotExist(Path.Combine(path, name));
		}

		private Encoding _GetEncodingFromParameters()
		{
			return Parameters.Contains("Encoding")
				   ? Encoding.GetEncoding(Parameters["Encoding"].Value)
				   : Encoding.Default;
		}

		#endregion // private methods
	}
}