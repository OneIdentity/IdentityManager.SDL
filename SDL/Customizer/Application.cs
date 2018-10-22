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
	public class Application : StateLessEntityLogic
	{
		public Application()
		{
			RegisterExpensive("_IsAdministrativeAccount")
				.As((session, ct) => Task.FromResult(session.User().IsAdministrativeAccount));

			CanEdit("SortOrderForProfile")
				.From("_IsAdministrativeAccount")
				.As((bool b) => b);

			MinLen("UID_SectionName")
				.From("IsProfileApplication")
				.As<bool>( isProfileApplication  => isProfileApplication ? 1 : 0);
		}

		public override async Task<Diff> OnSavingAsync(IEntity entity, LogicReadWriteParameters parameters, CancellationToken cancellationToken)
		{
			LogicParameter lp = new LogicParameter(entity, parameters, cancellationToken);

			if (! entity.IsDeleted())
			{
				await Check_IdentSectionName(lp).ConfigureAwait(false);

				await Handle_TroubleProduct(lp).ConfigureAwait(false);
			}

			return await base.OnSavingAsync(entity, parameters, cancellationToken).ConfigureAwait(false);
		}

		public override async Task OnSavedAsync(IEntity entity, LogicReadWriteParameters parameters, CancellationToken cancellationToken)
		{
			LogicParameter lp = new LogicParameter(entity, parameters, cancellationToken);

			if (! entity.IsDeleted())
			{
				await Handle_ApplicationProfiles(lp).ConfigureAwait(false);
			}

			await base.OnSavedAsync(entity, parameters, cancellationToken).ConfigureAwait(false);
		}

		private async Task Check_IdentSectionName(LogicParameter lp)
		{
			string identSectionName = lp.Entity.GetValue<string>("Ident_SectionName");

			//Leerer SectionName wird nicht getestet
			if (String.IsNullOrEmpty(identSectionName)) return;

			ISqlFormatter fSQL = lp.SqlFormatter;

			string strWhereClause = fSQL.AndRelation(
				fSQL.Comparison("Ident_SectionName", identSectionName, ValType.String),
				fSQL.Comparison("AppsNotDriver", false, ValType.Bool));

			//Test, ob es eine TreiberSection mit diesem Ident gibt
			if ( await lp.Session.Source().ExistsAsync("SectionName", strWhereClause, lp.CancellationToken).ConfigureAwait(false))
			{
				throw new ViException(2117033, ExceptionRelevance.EndUser, identSectionName);
			}

			strWhereClause = fSQL.Comparison("Ident_SectionName", identSectionName, ValType.String);

			if (lp.Entity.IsLoaded)
			{
				//wenn es sich um die eigene Applikation handelt
				strWhereClause = fSQL.AndRelation(
						strWhereClause,
						fSQL.UidComparison("UID_Application", lp.Entity.GetValue<string>("UID_Application"), CompareOperator.NotEqual));
			}

			if ( await lp.Session.Source().ExistsAsync("Application", strWhereClause, lp.CancellationToken).ConfigureAwait(false))
			{
				throw new ViException(2117031, ExceptionRelevance.EndUser, identSectionName);
			}
		}

		private Task Handle_TroubleProduct(LogicParameter lp)
		{
			ISqlFormatter fSQL = lp.SqlFormatter;

			return TroubleProductHelper.HandleTroubleProduct(
				lp,
				"Application",
				lp.Entity.GetValue<string>("NameFull"),
				"ApplicationProfile",
				fSQL.UidComparison("UID_Application", lp.Entity.GetValue<string>("UID_Application")));
		}

		private async Task Handle_ApplicationProfiles(LogicParameter lp)
		{
			bool bUpdateProfiles =
				(lp.Session.MetaData().IsTableEnabled("ApplicationProfile")
				 &&
				 (
					 lp.Entity.Columns["Ident_SectionName"].IsDifferent ||
					 lp.Entity.Columns["Ident_Application"].IsDifferent ||
					 lp.Entity.Columns["Ident_Language"].IsDifferent ||
					 lp.Entity.Columns["Version"].IsDifferent
					 )
					);

			if (! bUpdateProfiles)
				return;

			ISqlFormatter fSQL = lp.SqlFormatter;

			string strWhereClause = fSQL.AndRelation(
										fSQL.UidComparison("UID_Application", lp.Entity.GetValue<string>("UID_Application")),
										fSQL.OrRelation(
											fSQL.Comparison("UpdatePathVII", false, ValType.Bool),
											fSQL.Comparison("UpdateProfileVII", false, ValType.Bool))
									);

			Query qApplicationProfile = Query.From("ApplicationProfile")
				.Where(strWhereClause)
				.SelectAll();

			IEntityCollection colApplicationProfile = await lp.Session.Source().GetCollectionAsync(qApplicationProfile, EntityCollectionLoadType.Bulk, lp.CancellationToken).ConfigureAwait(false);

			foreach (IEntity eApplicationProfile in colApplicationProfile)
			{
				// set the flags
				eApplicationProfile.SetValue("UpdatePathVII", true);
				eApplicationProfile.SetValue("UpdateProfileVII", true);

				// and save
				await lp.UnitOfWork.PutAsync(eApplicationProfile).ConfigureAwait(false);
			}

		}
	}
}
