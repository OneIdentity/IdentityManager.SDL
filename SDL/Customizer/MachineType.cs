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
using VI.DB.Compatibility;
using VI.DB.Entities;

namespace SDL.Customizer
{

	/// <summary>
	/// EntityLogic for table <c>DriverProfile</c>
	/// </summary>
	public class MachineType : StateBasedEntityLogic
	{
		public MachineType()
		{
			CanEdit("MakeFullCopy")
				.From("MakeFullCopy")
				.As((bool makeFullCopy) => !makeFullCopy);

			RegisterMethod("Assign")
				.As<IValueProvider>(AssignAsync);

			RegisterMethod("SvrCopy")
				.As<string, string, string, DateTime, string>(_SvrCopyAsync)
				.Description("Method_MachineType_SvrCopy");
		}

		public Task AssignAsync(ISession session, IEntity entity, IValueProvider vpSource, CancellationToken ct)
		{
			if (vpSource == null) throw new ArgumentNullException("vpSource");

			//nicht auf sich selbst
			if (vpSource == entity) throw new InvalidOperationException("Source can not be the same object.");

			entity.SetValue("Ident_MachineType", vpSource.GetValue<string>("Ident_MachineType"));
			entity.SetValue("Ident_DomainMachineType", vpSource.GetValue<string>("Ident_DomainMachineType"));
			entity.SetValue("BootImageWin", vpSource.GetValue<string>("BootImageWin"));
			entity.SetValue("GraphicCard", vpSource.GetValue<string>("GraphicCard"));
			entity.SetValue("RemoteBoot", vpSource.GetValue<bool>("RemoteBoot"));
			entity.SetValue("BootImageWin", vpSource.GetValue<string>("BootImageWin"));
			entity.SetValue("ChgNumber", vpSource.GetValue<int>("ChgNumber"));
			entity.SetValue("Netcard", vpSource.GetValue<string>("Netcard"));
			entity.SetValue("MakeFullcopy", vpSource.GetValue<bool>("MakeFullcopy"));

			entity.SetValue("UID_SDLDomain", vpSource.GetValue<string>("UID_SDLDomain"));

			return NullTask.Instance;
		}

		public override async Task<Diff> OnSavingAsync(IEntity entity, LogicReadWriteParameters parameters, CancellationToken cancellationToken)
		{
			LogicParameter lp = new LogicParameter(entity, parameters, cancellationToken);

			if (!entity.IsDeleted())
			{
				await _HandleTroubleProduct(lp).ConfigureAwait(false);
			}

			return await base.OnSavingAsync(entity, parameters, cancellationToken).ConfigureAwait(false);
		}

		private Task _HandleTroubleProduct(LogicParameter lp)
		{
			return TroubleProductHelper.HandleTroubleProduct(lp,
				"MachineType",
				lp.ObjectWalker.GetValue<string>("Ident_MachineType"),
				null, null);
		}


		/// <summary>
		/// Generate a copy process in the <c>JobQueue</c>.
		/// </summary>
		/// <param name="CopyEvent">COPYCL2FDS, COPYFDS2CL</param>
		/// <param name="UID_SourceServer">Source server</param>
		/// <param name="UID_DestServer">Destination server</param>
		/// <param name="StartTime">Start time for the process</param>
		/// <param name="DestDomain">Destination domain</param>
		public Task _SvrCopyAsync(ISession session, IEntity entity,string CopyEvent, string UID_SourceServer, string UID_DestServer, DateTime StartTime, string DestDomain, CancellationToken ct)
		{
			// missusing(Missbrauch) this method, because code is partitialy equal
			try
			{
				session.Variables.Put("SvrCopy", true);

				ModProfile.SvrCopy(entity.CreateSingleDbObject(session), CopyEvent, UID_SourceServer, UID_DestServer, StartTime, DestDomain, false);
			}
			finally
			{
				session.Variables.Remove("SvrCopy");
			}

			return NullTask.Instance;
		}
	}
}
