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
using VI.Base;
using VI.DB;
using VI.DB.Entities;

namespace SDL.Customizer
{
	/// <summary>
	/// EntityLogic for table <c>ProfileCanUsedAlso</c>.
	/// </summary>
	public class ProfileCanUsedAlso : StateLessEntityLogic
	{
		public async override Task OnSavedAsync(IEntity entity, LogicReadWriteParameters parameters, CancellationToken cancellationToken)
		{
			// update of path.vii required ???
			bool bUpdatePathVii = ! entity.IsLoaded ||
							   entity.IsDeleted () ||
							   entity.Columns["UID_Profile"].IsChanged ||
							   entity.Columns["Ident_InstTypeAlso"].IsChanged ||
							   entity.Columns["Ident_OSAlso"].IsChanged;

			if (bUpdatePathVii)
			{
				IEntityForeignKey fkProfile = await entity.GetFkAsync(parameters.Session, "UID_Profile", cancellationToken: cancellationToken).ConfigureAwait(false);

				if (!fkProfile.IsEmpty())
				{
					IEntity eProfile = await fkProfile.GetParentAsync(EntityLoadType.Default, cancellationToken).ConfigureAwait(false);

					if (! eProfile.GetValue<bool>("UpdatePathVII"))
					{
						await eProfile.PutValueAsync("UpdatePathVII", true, cancellationToken).ConfigureAwait(false);

						await parameters.UnitOfWork.PutAsync(eProfile, cancellationToken).ConfigureAwait(false);
					}
				}
			}

			await base.OnSavedAsync(entity, parameters, cancellationToken).ConfigureAwait(false);
		}

	
	}
}
