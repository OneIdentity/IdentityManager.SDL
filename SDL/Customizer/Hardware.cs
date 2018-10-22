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
using System.Threading;
using System.Threading.Tasks;
using QER.Customizer;
using VI.Base;
using VI.DB;
using VI.DB.Entities;


namespace SDL.Customizer
{
	/// <summary>
	/// EntityLogic for table <c>Hardware</c>
	/// </summary>
	public class Hardware : StateBasedEntityLogic
	{
		private const string CpWithSetup = @"Hardware\UnattendedSetup\CName\WithSetup";
		private const string CpWithWorkdesk = @"Hardware\UnattendedSetup\CName\WithWorkdesk";

		private static readonly string[][] updateCNameTrigger =
			{
				new[] {"Ident_Hardwarelist", null },
				new[] {"DefaultUserContext", null },
				new[] {"UID_InstallationType", null },
				new[] {"UID_OS", null },
				new[] {"UID_MachineType", CpWithSetup },
				new[] {"UID_PrinterLocation" ,  CpWithWorkdesk},
				new[] {"UID_Workdesk", CpWithWorkdesk },
				new[] {"IsVIPC", null },
				new[] {"DEFAULTGATEWAY", CpWithSetup},
				new[] {"DEFAULTUSERCONTEXT", CpWithSetup},
				new[] {"DEFAULTWORKGROUP", CpWithSetup},
				new[] {"DISPLAYBITSPERPEL", CpWithSetup},
				new[] {"DISPLAYVREFRESH", CpWithSetup},
				new[] {"DISPLAYXRESOLUTION", CpWithSetup},
				new[] {"DISPLAYYRESOLUTION", CpWithSetup},
				new[] {"DNSNAME", CpWithSetup},
				new[] {"DNSSERVER1", CpWithSetup},
				new[] {"DNSSERVER2", CpWithSetup},
				new[] {"DNSSERVER3", CpWithSetup},
				new[] {"HOMESERVEROFDEFAULTUSER", CpWithSetup},
				new[] {"IDENT_DOMAINMACHINE", CpWithSetup},
				new[] {"IPADDRESS", CpWithSetup},
				new[] {"SCOPEID", CpWithSetup},
				new[] {"SUBNETMASK", CpWithSetup},
				new[] {"UID_ADSContainer", CpWithSetup},
				new[] {"USEDHCP", CpWithSetup},
				new[] {"USEDNS", CpWithSetup},
				new[] {"USEWINS", CpWithSetup},
				new[] {"WINSPRIMARY", CpWithSetup},
				new[] {"WINSSECONDARY", CpWithSetup }
			};

			private static readonly string[] updateUDFTrigger =
			{
				"DefaultGateway",
				"DefaultUserContext",
				"DefaultWorkGroup",
				"DisplayBitsPerPel",
				"DisplayVRefresh",
				"DisplayXResolution",
				"DisplayYResolution",
				"DNSName",
				"DNSServer1",
				"DNSServer2",
				"DNSServer3",
				"HomeServerOfDefaultUser",
				"Ident_Hardwarelist",
				"IsVIPC",
				"MACID",
				"ScopeID",
				"SubnetMask",
				"UID_MachineType",
				"UseDHCP",
				"UseDNS",
				"UseWINS",
				"WINSPrimary",
				"WINSSecondary"
			};

		private static readonly string[] updateMac2NameTrigger =
			{
				"IsVIPC",
				"Ident_Hardwarelist",
				"MacId",
				"UID_MachineType"
			};

		public Hardware()
		{
			Check("UID_SDLDomainRD")
				.AsExpensive<string>(Check_SDLDomainRD);

			Check("UID_MachineType")
				.AsExpensive<string>(Check_MachineType);

			Value("UID_OS")
				.From(@"Config(Hardware\Workdesk\ParentOSInherite)", "IsPc", "IsPC[o]", "FK(UID_Workdesk).UID_OS")
				.As((string cp, bool isPC, bool isPCo, string uidOS)
					=> TryResult.FromResult(
						string.Equals(cp, "Workdesk", StringComparison.OrdinalIgnoreCase) && isPC && ! isPCo &&
						!String.IsNullOrEmpty(uidOS), uidOS));

			foreach (string[] trigger in updateCNameTrigger)
			{
				if (trigger[1] != null)
				{
					// trigger with CP
					Value("UpdateCName")
						.From(trigger[0], trigger[0] + "[o]", "Config(+"+trigger[1]+")")
						.As((object oNew, object oOld, string cp) => TryResult.FromResult(oNew != oOld && cp == "1", true));
				}
				else
				{
					// trigger withou CP
					Value("UpdateCName")
						.From(trigger[0], trigger[0] + "[o]")
						.As((object oNew, object oOld) => TryResult.FromResult(oNew != oOld, true));
				}

			}

			foreach (string trigger in updateUDFTrigger)
			{
				Value("UpdateUDF")
					.From(trigger, trigger + "[o]")
					.As((object oNew, object oOld) => TryResult.FromResult(oNew != oOld, true));
			}

			foreach (string trigger in updateMac2NameTrigger)
			{
				Value("UpdateMac2Name")
					.From(trigger, trigger + "[o]")
					.As((object oNew, object oOld) => TryResult.FromResult(oNew != oOld, true));
			}

		}

		public override async Task OnSavedAsync(IEntity entity, LogicReadWriteParameters parameters, CancellationToken cancellationToken)
		{
			LogicParameter lp = new LogicParameter(entity, parameters, cancellationToken);

			// autocreate workdesk
			if (entity.IsLoaded)
			{
				// Workdesk / Hardware Ident_OS - Inheritance
				await _SyncOSInheritance(lp).ConfigureAwait(false);
			}

			await base.OnSavedAsync(entity, parameters, cancellationToken).ConfigureAwait(false);
		}

		/// <exclude/>
		/// <summary>
		/// Wenn das OS lt. ConfigParm von der HW kommt, wird der Workdesk damit synchronisiert
		/// </summary>
		private async Task _SyncOSInheritance(LogicParameter lp)
		{
			if (!lp.Entity.GetValue<bool>("IsPC"))
				return;

			if (IsInternalProcess)
				return;

			// is syncronisation enabeld ???
			if (!String.Equals(await lp.Session.Config().GetConfigParmAsync(@"Hardware\Workdesk\ParentOSInherite").ConfigureAwait(false), "HARDWARE", StringComparison.OrdinalIgnoreCase))
				return;

			string uidOSHardware = lp.Entity.GetValue<string>("UID_OS");

			if (String.IsNullOrEmpty(uidOSHardware))
				return;

			string uidWorkdesk = lp.Entity.GetValue<string>("UID_Workdesk");

			if (String.IsNullOrEmpty(uidWorkdesk))
				return;

			Query qWorkdesk = Query.From("Workdesk")
							.Where(c => c.Column("UID_Workdesk") == lp.Entity.GetValue<string>("UID_Workdesk"))
							.GetQuery();

			IEntity eWorkdesk = await lp.Session.Source().GetAsync(qWorkdesk, EntityLoadType.Default, lp.CancellationToken).ConfigureAwait(false);

			// insert our OS if not equal
			if (!String.Equals(eWorkdesk.GetValue<string>("UID_OS"), uidOSHardware))
			{
				using (StartInternalProcess())
				{
					eWorkdesk.SetValue("UID_OS", uidOSHardware);

					await lp.UnitOfWork.PutAsync(eWorkdesk, lp.CancellationToken).ConfigureAwait(false);
				}
			}
		}

		/// <exclude/>
		/// <summary>
		/// Test, ob HW und MachineType der HW in der gleichen Domäne sind
		/// </summary>
		private async Task<bool> Check_SDLDomainRD(ISession session, IEntity entity, IEntityWalker walker, string uidSDLDomainRD, CancellationToken ct)
		{
			if (!session.MetaData().IsTableEnabled("MachineType"))
				return true;

			// wenn Spalte leer ist -> raus
			if ( String.IsNullOrEmpty(uidSDLDomainRD))
			{
				return true;
			}

			DbObjectKey dbokMachineType = DbObjectKey.GetObjectKey("MachineType", entity.GetValue<string>("UID_MachineType"));

			var trMachineType = await session.Source().TryGetAsync(dbokMachineType, ct).ConfigureAwait(false);

			// FK not valid
			if (!trMachineType.Success)
				return true;

			// compare the domain-id's
			if (!String.Equals(uidSDLDomainRD, trMachineType.Result.GetValue<string>("UID_SDLDomain"), StringComparison.OrdinalIgnoreCase))
			{
				// try to find same mactype name in new resource domain
				ISqlFormatter fSQL = session.Resolve<ISqlFormatter>();
				string strWhereClause = fSQL.AndRelation(
					fSQL.Comparison("Ident_MachineType", trMachineType.Result.GetValue<string>("Ident_MachineType"), ValType.String, CompareOperator.Equal),
					fSQL.UidComparison("UID_SDLDomain", uidSDLDomainRD));

				// query for this object
				var uidMachineType = await session.Source().TryGetSingleValueAsync<string>("MachineType", "UID_MachineType", strWhereClause, ct).ConfigureAwait(false);

				await entity.PutValueAsync("UID_MachineType", uidMachineType.Success ? uidMachineType.Result : "", ct).ConfigureAwait(false);
			}

			return true;
		}

		private async Task<bool> Check_MachineType(ISession session, IEntity entity, IEntityWalker walker, string uidMachineType, CancellationToken ct)
		{
			if (!session.MetaData().IsTableEnabled("MachineType"))
				return true;

			// wenn Spalte nicht geladen wurde
			if ( String.IsNullOrEmpty(uidMachineType))
			{
				return true;
			}

			// no SDL domain defined
			string sdlDomain = entity.GetValue<string>("UID_SDLDomainRD");

			if (String.IsNullOrEmpty(sdlDomain))
			{
				return true;
			}

			DbObjectKey dbokMachineType = DbObjectKey.GetObjectKey("MachineType", uidMachineType);

			var trMachineType = await session.Source().TryGetAsync(dbokMachineType, ct).ConfigureAwait(false);

			// FK not valid
			if (!trMachineType.Success)
				return true;

			// compare the domain-id's
			if (!String.Equals(sdlDomain, trMachineType.Result.GetValue<string>("UID_SDLDomain"), StringComparison.OrdinalIgnoreCase))
			{
				throw new ViException(2133091, ExceptionRelevance.EndUser);
			}

			return true;
		}
	}
}