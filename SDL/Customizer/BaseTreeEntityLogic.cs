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

using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using VI.Base;
using VI.DB.Entities;
using VI.DB.MetaData;

namespace SDL.Customizer
{
	/// <summary>
	/// EntityLogic to handle all BaseTree.IsLicenceNode
	/// </summary>
	public class BaseTreeEntityLogic : StateLessEntityLogic
	{
		public override async Task<Diff> OnSavingAsync(IEntity entity, LogicReadWriteParameters parameters, System.Threading.CancellationToken cancellationToken)
		{
			var ret = await base.OnSavingAsync(entity, parameters, cancellationToken).ConfigureAwait(false);

			await RemoveBaseTreeHasLicence(entity, parameters.Session, parameters.UnitOfWork, cancellationToken)
				.ConfigureAwait(false);

			return ret;
		}

		private async Task RemoveBaseTreeHasLicence(IEntity entity, ISession session, IUnitOfWork unitOfWork,  CancellationToken ct)
		{
			// Object is new or deleted --> return direct
			if (!entity.IsLoaded || entity.IsDeleted())
				return;

			// #27178 do not check if the licence management is deactivated
			if (!entity.Columns.Contains("IsLicenceNode"))
				return;

			var bOld = await entity.GetValueAsync<bool>("IsLicenceNode[O]", ct).ConfigureAwait(false);
			var bNew = await entity.GetValueAsync<bool>("IsLicenceNode", ct).ConfigureAwait(false);

			// Flag is removed
			if (bOld && !bNew)
			{
				// Build MN-TableName and FK-ColumName
				string strMNTable = entity.Tablename + "HasLicence";

				IMetaTable mTable = await session.MetaData().GetTableAsync(entity.Tablename, ct).ConfigureAwait(false);

				var mRels = await mTable.GetChildRelationsAsync(ct).ConfigureAwait(false);
				IMetaTableRelation mnRelation = mRels.FirstOrDefault((r) => r.ChildTableName == strMNTable);

				Query qOhL = Query.From(strMNTable)
					.Where(c => c.Column(mnRelation.ChildColumnName) == entity.GetValue(mnRelation.ParentColumnName))
					.GetQuery();

				// Get the MN-RelationObject
				IEntityCollection colMN = await session.Source().GetCollectionAsync(qOhL, EntityCollectionLoadType.Bulk, ct).ConfigureAwait(false);

				// Process each Object in ObjectHasLicence Table
				foreach (IEntity eMN in colMN)
				{
					// Delete and Save
					eMN.MarkForDeletion();

					await unitOfWork.PutAsync(eMN, cancellationToken: ct).ConfigureAwait(false);
				}
			}
		}
	}
}
