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
using VI.DB;
using VI.DB.Entities;




namespace SDL.Customizer
{
	/// <summary>
	/// EntityLogic for table <c>ApplicationServer</c>
	/// </summary>
	public class ApplicationServer : StateLessEntityLogic
	{
		public ApplicationServer()
		{
			Check("IsCentralLibrary")
				.AsExpensive<bool>(Check_IsCentralLibrary);

			Check("UID_ParentApplicationServer")
				.AsExpensive<string>(Check_UidParentApplicationServer);

			CanEdit("UID_ParentApplicationServer", "UID_ApplicationServerRedirect")
				.From("IsCentralLibrary")
				.As((bool isCentralLibrary) => !isCentralLibrary)
				.ClearValueOnFalse();

			CanEdit("UseAlwaysLimit", "OnLineLimit")
				.From("UID_ApplicationServerRedirect")
				.As((string s) => string.IsNullOrEmpty(s))
				.ClearValueOnFalse();

			CanEdit("UseShadowFolder")
				.From("UID_ApplicationServerRedirect", "OnLineLimit")
				.As((string s, int limit) => string.IsNullOrEmpty(s) && limit == 0)
				.ClearValueOnFalse();

			PreventLoops("UID_ParentApplicationServer");

			Value("UseShadowFolder")
				.From("OnLineLimit")
				.As( (int onLineLimit) => TryResult.FromResult(onLineLimit>0, true));
		}

		private static async Task<bool> Check_IsCentralLibrary(ISession session, IEntity entity, IEntityWalker walker,
			bool isCentralLibrary, CancellationToken ct)
		{
			if (isCentralLibrary)
			{
				if (! String.IsNullOrEmpty(entity.GetValue<string>("UID_ParentApplicationServer")))
					throw new ViException(2116021, ExceptionRelevance.EndUser);

				if (!entity.GetValue<bool>("IsCentralLibrary"))
				{
					string identOtherCl = await IsThereAnotherCentralLibrary(session, entity, ct).ConfigureAwait(false);

					if (! string.IsNullOrEmpty(identOtherCl))
						throw new ViException(2116027, ExceptionRelevance.EndUser, identOtherCl);

				}

				if (! String.IsNullOrEmpty(entity.GetValue<string>("UID_ApplicationServerRedirect")))
					throw new ViException(2116167, ExceptionRelevance.EndUser);
			}

			return true;
		}

		private static async Task<string> IsThereAnotherCentralLibrary(ISession session, IEntity entity, CancellationToken ct)
		{
			if (String.IsNullOrEmpty(entity.GetValue<string>("UID_Applicationserver")))
			{
				return "";
			}

			ISqlFormatter fSQL = session.Resolve<ISqlFormatter>();

			string strWhereClause = fSQL.AndRelation(
				fSQL.UidComparison("UID_ApplicationServer", entity.GetValue<string>("UID_Applicationserver"), CompareOperator.NotEqual),
				fSQL.Comparison("IsCentralLibrary", true, ValType.Bool));

			Query qApplicationServer = Query.From("ApplicationServer")
				.Where(strWhereClause)
				.SelectDisplays();

			IEntityCollection colApplicationServer = await session.Source().GetCollectionAsync(qApplicationServer, EntityCollectionLoadType.Default, ct).ConfigureAwait(false);

			return colApplicationServer.Count>0 ? colApplicationServer[0].Display : "";
		}

		private static async Task<bool> Check_UidParentApplicationServer(ISession session, IEntity entity, IEntityWalker walker,
			string uidParentApplicationServer, CancellationToken ct)
		{
			//die Tests sind nur interessant, wenn ein Wert eingetragen wird
			if (String.IsNullOrEmpty(uidParentApplicationServer))
				return true;

			// Die CentralLibrary muss im Root liegen
			if (entity.GetValue<bool>("IsCentralLibrary"))
			{
				throw new ViException(2116021, ExceptionRelevance.EndUser);
			}

			Query qParent = Query.From("ApplicationServer")
				.Where(c => c.Column("UID_ApplicationServer") == uidParentApplicationServer)
				.Select("UID_SDLDomain");

			string uidDomainParent = await session.Source().GetSingleValueAsync<string>(qParent, ct).ConfigureAwait(false);

			if ( ! string.Equals(uidDomainParent, entity.GetValue<string>("UID_SDLDomain"), StringComparison.Ordinal))
			{
				throw new ViException(2116140, ExceptionRelevance.EndUser);
			}

			return true;
		}
	}
}
