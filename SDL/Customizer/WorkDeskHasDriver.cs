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

	using System.Threading;
	using System.Threading.Tasks;
	using QER.Customizer;
	using VI.DB;
	using VI.DB.Entities;


namespace SDL.Customizer
{
	/// <summary>
	/// EntityLogic for table <c>WorkdeskHasDriver</c>
	/// </summary>
	public class WorkdeskHasDriver : StateBasedEntityLogic
	{
		public WorkdeskHasDriver()
		{
			RegisterMethod("CreateITShopWorkdeskOrder")
				.As<string, string>(CreateITShopWorkdeskOrder)
				.Description("Method_CreateITShopWorkdeskOrder")
				.Enabled().Default(false)
				.Enabled().From("XOrigin").As((int xOrigin) => (xOrigin & (int) XOrigin.Ordered) == 0)
				.Visible().Default(false)
				.Visible().From("XOrigin").As((int xOrigin) => (xOrigin & (int) XOrigin.Ordered) == 0);
		}

		/// <summary>
		/// Create a granted IT shop order for this group membership.
		///  </summary>
		/// <param name="entity"></param>
		/// <param name="uidPerson"></param>
		/// <param name="customScriptName">
		/// This script name has to be the VB.net name of script and not the name of the DialogScript object in the database. This parameter can be null or empty.
		/// </param>
		/// <param name="session"></param>
		/// <param name="ct"></param>
		private Task CreateITShopWorkdeskOrder(ISession session, IEntity entity, string uidPerson, string customScriptName,
			CancellationToken ct)
		{
			using (StartInternalProcess())
			{
				return ITShopHelperAsync.CreateWorkdeskITShopOrder(
					session,
					entity,
					"FK(UID_Driver).UID_AccProduct",
					"UID_Workdesk",
					uidPerson,
					customScriptName,
					ct);
			}
		}
	}
}
