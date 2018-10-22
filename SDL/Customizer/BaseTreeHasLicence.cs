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
using VI.Base;
using VI.DB.Entities;

namespace SDL.Customizer
{
	/// <summary>
	/// EntityLogic for all views based on BaseTreeHasLicence.
	/// </summary>
	/// <remarks>
	/// Adds functionality to check integrity of <c>UID_Licence</c>, <c>ValidFrom</c> and <c>ValidTo</c>.
	/// </remarks>
	public class BaseTreeHasLicence : StateLessEntityLogic
	{
		public BaseTreeHasLicence()
		{
			Check("ValidFrom")
				.AsExpensive<DateTime>(_CheckValidFrom);

			Check("ValidTo")
				.AsExpensive<DateTime>(_CheckValidTo);
		}

		private async Task<bool> _CheckValidFrom(ISession session, IEntity entity, IEntityWalker walker, DateTime dtValidFrom, CancellationToken ct)
		{
			string uidLicence = entity.GetValue("UID_Licence");

			// do not check Empty values
			if (DbVal.IsEmpty(uidLicence, ValType.String)) return true;

			if (DbVal.IsEmpty(dtValidFrom, ValType.Date)) return true;

			// Get VailidFrom Licence
			DateTime dtValidFromLicence = await walker.GetValueAsync<DateTime>( "FK(UID_Licence).ValidFrom", ct).ConfigureAwait(false);

			// Date in Licence is defined ?
			if (!DbVal.IsEmpty(dtValidFromLicence, ValType.Date))
			{
				// and higher than our Date?
				if (dtValidFromLicence > dtValidFrom)
				{
					// Get Licence-Display
					string strLicence = await entity.Columns["UID_Licence"].GetDisplayValueAsync(session, ct).ConfigureAwait(false);

					// throw exception
					throw new ViException(2133214, ExceptionRelevance.EndUser, strLicence, dtValidFromLicence);
				}
			}

			return true;
		}

		private async Task<bool> _CheckValidTo(ISession session, IEntity entity, IEntityWalker walker, DateTime dtValidTo, CancellationToken ct)
		{
			string uidLicence = entity.GetValue("UID_Licence");

			// do not check Empty values
			if (DbVal.IsEmpty(uidLicence, ValType.String)) return true;

			if (DbVal.IsEmpty(dtValidTo, ValType.Date)) return true;

			// Get VailidFrom Licence
			DateTime dtValidToLicence = await walker.GetValueAsync<DateTime>("FK(UID_Licence).ValidTo", ct).ConfigureAwait(false);

			// Date in Licence is defined ?
			if (!DbVal.IsEmpty(dtValidToLicence, ValType.Date))
			{
				// and smaler than our Date?
				if (dtValidToLicence < dtValidTo)
				{
					// Get Licence-Display
					string strLicence = await entity.Columns["UID_Licence"].GetDisplayValueAsync(session, ct).ConfigureAwait(false);

					// throw exception
					throw new ViException(2133215, ExceptionRelevance.EndUser, strLicence, dtValidToLicence);
				}
			}

			return true;
		}
	}
}
