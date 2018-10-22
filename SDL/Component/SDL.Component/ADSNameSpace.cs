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

using VI.Base;
using VI.DB;

namespace VI.JobService.JobComponents
{
	public class ADSNameSpace : AccountNameSpace
	{
		public ADSNameSpace(ConnectData connData)
		: base(connData)
		{}

		public override string AccountName => "ADSAccount";

		public override string GetAccountUID(ISingleDbObject obj)
		{
			return obj.GetValue<string>("UID_ADSAccount");
		}


		protected override IColDbObject CreateColUserAccount(ApplicationInfo app)
		{
			var colUserAccount = Conn.CreateCol("ADSAccount");
			colUserAccount.Prototype.WhereClause = string.Format(
					"({0}) AND (UID_ADSDomain IN ( SELECT UID_ADSDomain FROM ADSDomain WHERE {1}))",
					Formatter.Comparison("SAMACCOUNTNAME", app.UserAccount, ValType.String),
					Formatter.Comparison("IDENT_DOMAIN", app.UserDomainContext, ValType.String));

			colUserAccount.Load();
			return colUserAccount;
		}

		protected override IColDbObject CreateColHardware(ApplicationInfo app)
		{
			var colMachineAccount = Conn.CreateCol("Hardware");

			colMachineAccount.Prototype.WhereClause = $@"exists (
	select 1
	from ADSMachine m
	join ADSDomain d on m.UID_ADSDomain = d.UID_ADSDomain
	where m.UID_Hardware = Hardware.UID_Hardware
	and {Formatter.Comparison("m.SAMAccountName", app.MachineAccount, ValType.String)}
	and {Formatter.Comparison("d.Ident_Domain", app.MachineDomainContext, ValType.String)}
)";

			colMachineAccount.Load();
			return colMachineAccount;
		}

		protected override string GetCountOfNewerStatement(DateTime date, ISingleDbObject account, ISingleDbObject machine)
		{
			return string.Format(
					   Conn.SqlStrings["COUNT_ADS_ACCOUNT"],
					   account == null ? "1=0" :
					   Formatter.Comparison("UID_ADSAccount", account["UID_ADSAccount"].NewValue, ValType.String, CompareOperator.Equal, FormatterOptions.None),
					   machine == null ? "1=0" :
					   Formatter.Comparison("UID_Hardware", machine["UID_Hardware"].NewValue, ValType.String, CompareOperator.Equal, FormatterOptions.None),
					   Formatter.Comparison("InstallDate", date, ValType.Date, CompareOperator.GreaterOrEqual));
		}

		protected override string AppsInfoTable
		{
			get { return "ADSAccountAppsInfo"; }
		}

		protected override string AppsInfoKeyColumn
		{
			get { return "UID_ADSAccount"; }
		}

		protected override string ClientLogKeyColumn
		{
			get { return "UID_ADSAccount"; }
		}


		protected override void CreateApplicationEntryInDB(DBAppDrvInfo info, DateTime lastModified)
		{
			var adsAccountAppsInfo = Conn.CreateSingle("ADSAccountAppsInfo");

			adsAccountAppsInfo.PutValue("CurrentlyActive", true);
			adsAccountAppsInfo.PutValue("InstallDate", lastModified);
			adsAccountAppsInfo.PutValue("DeInstallDate", null);
			adsAccountAppsInfo.PutValue("UID_InstallationType", info.UidInstallationType);
			adsAccountAppsInfo.PutValue("UID_OS", info.UidOperatingSystem);
			adsAccountAppsInfo.PutValue("Revision", Convert.ToInt32(info.AssociatedAppsDrvProfileInfo.Revision));
			adsAccountAppsInfo.PutValue("UID_ADSAccount", info.UidAccount);
			adsAccountAppsInfo.PutValue("UID_Application", info.UidAppDrv);

			// removed #8136
			// adsAccountAppsInfo.PutValue("DisplayName", info.AppDrvNameFull);

			adsAccountAppsInfo.Save();
		}

	}
}
