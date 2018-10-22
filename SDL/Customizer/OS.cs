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
using VI.DB.MetaData;

namespace SDL.Customizer
{
	/// <summary>
	/// Customizer for table <c>OS</c>.
	/// </summary>
	/// <remarks>
	/// The following events can be triggered by the object:
	///	<list type="table">
	///		<listheader>
	///			<term>Event</term><description>Description</description>
	///		</listheader>
	///		<item><term>INSERT</term><description>The new object is inserted into the database.</description></item>
	///		<item><term>UPDATE</term><description>The object was changed in the database.</description></item>
	///		<item><term>DELETE</term><description>The object was deleted from the database.</description></item>
	/// </list>
	/// </remarks>
	public class OS : StateLessEntityLogic
	{
		public override async Task OnSavedAsync(IEntity entity, LogicReadWriteParameters parameters,
			CancellationToken cancellationToken)
		{
			await _FillOsInsttype(parameters.Session, entity, parameters.UnitOfWork, cancellationToken).ConfigureAwait(false);

			await base.OnSavedAsync(entity, parameters, cancellationToken).ConfigureAwait(false);
		}

		private async Task _FillOsInsttype(ISession session, IEntity entity, IUnitOfWork uoWork, CancellationToken ct)
		{
			// nur bei insert
			if (entity.IsLoaded)
				return;

			// zieltabelle deaktiviert
			IMetaTable mt = await session.MetaData().GetTableAsync("InstallationType", ct).ConfigureAwait(false);

			if (mt.IsDeactivated)
				return;

			string uidOs = entity.GetValue("UID_OS").String;

			Query qInstallationType = Query.From("InstallationType")
				.Select("UID_InstallationType");

			IEntityCollection colInstallationType = await
					session.Source().GetCollectionAsync(qInstallationType, EntityCollectionLoadType.Slim, ct).ConfigureAwait(false);

			foreach (IEntity colElem in colInstallationType)
			{
				// create a new object
				IEntity eOsInstType = await session.Source().CreateNewAsync("OsInstType",
					EntityCreationType.DelayedLogic, ct)
					.ConfigureAwait(false);

				await eOsInstType.PutValueAsync("UID_OS", uidOs, ct).ConfigureAwait(false);
				await eOsInstType.PutValueAsync("UID_InstallationType", colElem.GetValue("UID_InstallationType"), ct).ConfigureAwait(false);

				// and save
				await uoWork.PutAsync(eOsInstType, ct).ConfigureAwait(false);
			}
		}
	}
}
