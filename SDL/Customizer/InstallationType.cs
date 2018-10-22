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
using VI.DB;
using VI.DB.Entities;

namespace SDL.Customizer
{
	/// <summary>
	/// EntityLogic for table <c>InstallationType</c>
	/// </summary>
	public class InstallationType : StateLessEntityLogic
	{
		public InstallationType()
		{

		}

		public async override Task OnSavedAsync(IEntity entity, LogicReadWriteParameters parameters,
			CancellationToken cancellationToken)
		{
			await _FillOsInsttype(parameters.Session, entity, parameters.UnitOfWork, cancellationToken).ConfigureAwait(false);

			await base.OnSavedAsync(entity, parameters, cancellationToken).ConfigureAwait(false);
		}

		private async Task _FillOsInsttype(ISession session, IEntity entity, IUnitOfWork uoWork, CancellationToken ct)
		{
			// Insert
			if (entity.IsLoaded)
				return;

			Query qOS = Query.From("OS")
				.Select("UID_OS");

			IEntityCollection colOS = await 
				session.Source().GetCollectionAsync(qOS, EntityCollectionLoadType.Slim, ct).ConfigureAwait(false);

			string uidInstallationType = entity.GetValue("UID_InstallationType");

			foreach (IEntity colElem in colOS)
			{
				// create a new object
				IEntity eOsInstType = await session.Source().CreateNewAsync("OsInstType",
					EntityCreationType.DelayedLogic, ct)
					.ConfigureAwait(false);

				await eOsInstType.PutValueAsync("UID_OS", colElem.GetValue("UID_OS").String, ct).ConfigureAwait(false);
				await eOsInstType.PutValueAsync("UID_InstallationType", uidInstallationType, ct).ConfigureAwait(false);

				// and save
				await uoWork.PutAsync(eOsInstType, ct).ConfigureAwait(false);
			}
		}
	}
}
