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
using System.Runtime.InteropServices;
using System.Xml;

namespace VI.JobService.JobComponents
{
	/// <summary>
	/// Summary description for FeedBackFile.
	/// </summary>
	[ComVisible(true)]
	public class FeedBackFile
	{
		public enum InstallState
		{
			IsUninstalled = 0,
			IsInstalled,
			IsDeselected
		}

		#region private members

		const string _c_xml_tag_viclienterrorlevel = "VIClientErrorLevel";
		const string _c_xml_tag_application_info = "ApplicationInfo";
		const string _c_xml_tag_user_info = "UserInfo";
		const string _c_xml_tag_machine_info = "MachineInfo";
		const string _c_xml_tag_install_log = "InstallLog";
		const string _c_xml_tag_apps = "Apps";
		const string _c_xml_tag_log = "InstallLog";

		const string _c_xml_attr_account = "Account";
		const string _c_xml_attr_name_space = "NameSpace";
		const string _c_xml_attr_domain_context = "DomainKontext";

		const string _c_xml_attr_section_name = "SectionName";
		const string _c_xml_attr_revision = "Revision";
		const string _c_xml_attr_install_type = "InstallType";
		const string _c_xml_attr_operating_system = "OS";


		string _file_name;

		#endregion // private members

		#region Constructors

		public FeedBackFile(string fileName)
		{
			if (fileName == null)
			{
				throw new ArgumentNullException("fileName");
			}

			_file_name = fileName;
		}

		public FeedBackFile()
			: this(null)
		{ }

		#endregion // Constructors

		#region Properties

		public string FileName
		{
			get { return _file_name; }
			set { _file_name = value; }
		}

		#endregion // Properties

		#region Public methods

		public ApplicationInfo GetApplicationInfoFromFile(string fileName)
		{
			ApplicationInfo appRet = new ApplicationInfo();

			XmlDocument SWFeedBackFile = new XmlDocument();

			SWFeedBackFile.PreserveWhitespace = true;

			SWFeedBackFile.Load(fileName);

			XmlElement applicationInfoElement = SWFeedBackFile[_c_xml_tag_application_info];

			if (applicationInfoElement.HasChildNodes)
			{
				XmlElement viclienterrorlevelElement = applicationInfoElement[_c_xml_tag_viclienterrorlevel];

				if (viclienterrorlevelElement != null)
				{
					appRet.ErrorLevel = viclienterrorlevelElement.InnerText;
				}

				// UserInfo
				XmlNode userInfoNode = applicationInfoElement[_c_xml_tag_user_info];

				if (userInfoNode != null)
				{
					appRet.UserAccount = userInfoNode.Attributes[_c_xml_attr_account].Value;
					appRet.UserNamespace = userInfoNode.Attributes[_c_xml_attr_name_space].Value;
					appRet.UserDomainContext = userInfoNode.Attributes[_c_xml_attr_domain_context].Value;

					if (userInfoNode.HasChildNodes)
					{
						foreach (XmlNode currAppsNode in userInfoNode)
						{
							if (currAppsNode.Name == _c_xml_tag_apps)
							{
								var resultAppsDrvProfileInfo = new AppsDrvProfileInfo(currAppsNode.Attributes[_c_xml_attr_section_name].Value,
									currAppsNode.Attributes[_c_xml_attr_revision].Value,
									currAppsNode.Attributes[_c_xml_attr_install_type].Value,
									currAppsNode.Attributes[_c_xml_attr_operating_system].Value);

								appRet.UserApplications.Add(resultAppsDrvProfileInfo);
							}
						}
					}
				}

				// MachineInfo
				XmlNode machineInfoNode = applicationInfoElement[_c_xml_tag_machine_info];

				if (machineInfoNode != null)
				{
					appRet.MachineAccount = machineInfoNode.Attributes[_c_xml_attr_account].Value;
					appRet.MachineNamespace = machineInfoNode.Attributes[_c_xml_attr_name_space].Value;
					appRet.MachineDomainContext = machineInfoNode.Attributes[_c_xml_attr_domain_context].Value;

					if (machineInfoNode.HasChildNodes)
					{
						foreach (XmlNode currAppsNode in machineInfoNode)
						{
							if (currAppsNode.Name == _c_xml_tag_apps)
							{
								var resultAppsDrvProfileInfo = new AppsDrvProfileInfo(currAppsNode.Attributes[_c_xml_attr_section_name].Value,
									currAppsNode.Attributes[_c_xml_attr_revision].Value,
									currAppsNode.Attributes[_c_xml_attr_install_type].Value,
									currAppsNode.Attributes[_c_xml_attr_operating_system].Value);

								appRet.MachineApplications.Add(resultAppsDrvProfileInfo);
							}
						}
					}
				}

				// InstallLog
				XmlNode installLogNode = applicationInfoElement[_c_xml_tag_log];

				if (installLogNode != null)
				{
					appRet.InstallLog = installLogNode.InnerText;
				}

			}

			return appRet;
		}

		public ApplicationInfo GetApplicationInfo()
		{
			if (_file_name == null)
			{
				throw new NullReferenceException("Property FileName has not been set yet.");
			}

			return GetApplicationInfoFromFile(_file_name);
		}

		#endregion // Public methods
	}
}