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
	/// EntityLogic for table <c>Workdesk</c>.
	/// </summary>
	public class Workdesk : StateLessEntityLogic
	{
		public Workdesk()
		{
			Check("UID_OS")
				.AsExpensive<string>(_CheckUID_OS);
		}

		public override async Task<Diff> OnSavingAsync(IEntity entity, LogicReadWriteParameters parameters, CancellationToken cancellationToken)
		{
			LogicParameter lp = new LogicParameter(entity, parameters, cancellationToken);

			await _SyncOSInheritance(lp).ConfigureAwait(false);

			return await base.OnSavingAsync(entity, parameters, cancellationToken).ConfigureAwait(false);
		}

		public override async Task OnSavedAsync(IEntity entity, LogicReadWriteParameters parameters, CancellationToken cancellationToken)
		{
			if (entity.Columns["DisableVIClient"].IsDifferent)
			{
				await SetUpdateCNameInPC(parameters.Session, entity, parameters.UnitOfWork, cancellationToken).ConfigureAwait(false);
			}

			await base.OnSavedAsync(entity, parameters, cancellationToken).ConfigureAwait(false);
		}

		#region private members

		private async Task<bool> _CheckUID_OS(ISession session, IEntity entity, string uidOSWorkdesk, CancellationToken ct)
		{
			LogicParameter lp = new LogicParameter(session, null, entity, null, null, ct);

			// Keine Überprüfung bei internem Aufruf
			if (IsInternalProcess || String.IsNullOrEmpty(uidOSWorkdesk))
			{
				return true;
			}

			string cp = await session.Config().GetConfigParmAsync(@"Hardware\Workdesk\ParentOSInherite", ct).ConfigureAwait(false);

			if (String.Equals("HARDWARE", cp, StringComparison.OrdinalIgnoreCase))
			{
				// hole Hardware entity als PC
				IEntity eHardware = await GetCorrespondingPC(lp).ConfigureAwait(false);

				if (null == eHardware)
					return true;

				string osWorkdesk = await GetIdentOs(lp, uidOSWorkdesk).ConfigureAwait(false);

				if (String.IsNullOrEmpty(osWorkdesk))
					return true;

				string osHardware = eHardware.GetValue<string>("OperatingSystem");

				if ((!String.IsNullOrEmpty(osWorkdesk))
					   && (!String.IsNullOrEmpty(osHardware))
					   && (StringComparer.OrdinalIgnoreCase.Compare(osWorkdesk, osHardware) != 0)
				   )
				{
					throw new ViException(2133069, ExceptionRelevance.EndUser, "OS of workdesk - " + osWorkdesk, "OS of assigned hardware - " + osHardware);
				}
			}

			return true;
		}

		/// <exclude/>
		/// <summary>
		/// ermittelt einen PC zum Workdesk
		/// </summary>
		/// <returns>HardwareObject oder null</returns>
		private async Task<IEntity> GetCorrespondingPC(LogicParameter lp)
		{
			Query qHardware = Query.From("Hardware")
				.Where(c =>
					c.Column("UID_WorkDesk") == lp.Entity.GetValue<string>("UID_WorkDesk") &&
					c.Column("IsPC") == true)
				.SelectAll();

			var tHardware = await lp.Session.Source().TryGetAsync(qHardware, EntityLoadType.Default, lp.CancellationToken).ConfigureAwait(false);

			return tHardware.Success ? tHardware.Result : null;
		}

		private async Task<string> GetIdentOs(LogicParameter lp, string uidOS)
		{
			if (string.IsNullOrEmpty(uidOS))
				return null;

			return await lp.Session.Source().GetSingleValueAsync<string>("OS", "Ident_OS",
				lp.SqlFormatter.UidComparison("UID_OS", uidOS), lp.CancellationToken).ConfigureAwait(false);
		}

		/// <exclude/>
		/// <summary>
		/// Synchronisiert Betriebssystem zw. Workdesk und Hardware
		/// </summary>
		private async Task _SyncOSInheritance(LogicParameter lp)
		{
			if (String.Equals("WORKDESK", await lp.Session.Config().GetConfigParmAsync(@"Hardware\Workdesk\ParentOSInherite").ConfigureAwait(false), StringComparison.OrdinalIgnoreCase))
			{
				// get our Ident_OS
				string uidOsWorkdesk = lp.Entity.GetValue<string>("UID_OS");

				// is configured ?
				if (!String.IsNullOrEmpty(uidOsWorkdesk))
				{
					IEntity eHardware = await GetCorrespondingPC(lp).ConfigureAwait(false);

					if (eHardware == null)
					{
						return;
					}

					if (!String.Equals(eHardware.GetValue<string>("UID_OS"), uidOsWorkdesk, StringComparison.Ordinal))
					{
						using (StartInternalProcess())
						{
							// update operationssystem at hardware
							eHardware.SetValue("UID_OS", uidOsWorkdesk);

							await lp.UnitOfWork.PutAsync(eHardware, lp.CancellationToken).ConfigureAwait(false);
						}
					}
				}
			}
		}

		#endregion




		/// <exclude/>
		/// sets UpdateCName flag in our PC
		private async Task SetUpdateCNameInPC(ISession session, IEntity entity, IUnitOfWork unitOfWork, CancellationToken ct )
		{
			Query qPC = Query.From("Hardware")
				.Where(c => c.Column("UID_WorkDesk") == entity.GetValue<string>("UID_WorkDesk") && c.Column("IsVIPc") == true)
				.GetQuery();

			var trHardware = await session.Source().TryGetAsync(qPC, ct).ConfigureAwait(false);

			if (trHardware.Success)
			{
				await trHardware.Result.PutValueAsync("UpdateCNAME", true, ct).ConfigureAwait(false);

				await unitOfWork.PutAsync(trHardware.Result, ct).ConfigureAwait(false);
			}
		}
	}
}