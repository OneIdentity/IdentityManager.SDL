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


namespace VI.JobService.JobComponents
{
	public class DBAppDrvInfo
	{
		public DBAppDrvInfo(AppsDrvProfileInfo associatedAppsDrvProfileInfo, string uidAppDrv,
							string uidAccount, string appDrvNameFull,
							string uidInstallationType, string uidOperatingSystem,
							bool isApplication)
		{
			AssociatedAppsDrvProfileInfo = associatedAppsDrvProfileInfo;
			UidAppDrv = uidAppDrv;
			UidAccount = uidAccount;
			AppDrvNameFull = appDrvNameFull;
			UidInstallationType = uidInstallationType;
			UidOperatingSystem = uidOperatingSystem;
			IsApplication = isApplication;

			IsDeselected = false;
			IsInstalledInDB = false;
		}

		public AppsDrvProfileInfo AssociatedAppsDrvProfileInfo { get; set; }
		public string UidAppDrv { get; set; }
		public string UidAccount { get; set; }
		public string AppDrvNameFull { get; set; }
		public string UidInstallationType { get; }
		public string UidOperatingSystem { get; }
		public bool IsApplication { get; set; }
		public bool IsDeselected { get; set; }
		public bool IsInstalledInDB { get; set; }
	}
}
