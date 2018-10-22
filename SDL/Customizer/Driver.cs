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
	/// EntityLogic for table <c>Driver</c>
	/// </summary>
	public class Driver : StateLessEntityLogic
	{
		public Driver()
		{
			RegisterExpensive("_IsAdministrativeAccount")
				.As((session, ct) => Task.FromResult(session.User().IsAdministrativeAccount));

			RegisterExpensive("_Now")
				.As((session, ct) => Task.FromResult(QERHelper.GetServerTime(session, ct)));

			CanEdit("SortOrderForProfile")
				.From("_IsAdministrativeAccount")
				.As((bool b) => b);

			MinLen("UID_SectionName")
				.From("IsProfileApplication")
				.As<bool>(isProfileApplication => isProfileApplication ? 1 : 0);

			Value("DateStatusIndicatorChanged")
				.From("AppStatusIndicator", "AppStatusIndicator[o]", "_Now")
				.As((string n, string o, DateTime now) => TryResult.FromResult(!String.Equals(n, o), now));
		}

		public override async Task<Diff> OnSavingAsync(IEntity entity, LogicReadWriteParameters parameters, CancellationToken cancellationToken)
		{
			LogicParameter lp = new LogicParameter(entity, parameters, cancellationToken);

			if (!entity.IsDeleted())
			{
				await Check_IdentSectionName(lp).ConfigureAwait(false);

				await Handle_TroubleProduct(lp).ConfigureAwait(false);
			}

			return await base.OnSavingAsync(entity, parameters, cancellationToken).ConfigureAwait(false);
		}

		public override async Task OnSavedAsync(IEntity entity, LogicReadWriteParameters parameters, CancellationToken cancellationToken)
		{
			LogicParameter lp = new LogicParameter(entity, parameters, cancellationToken);

			if (!entity.IsDeleted())
			{
				await Handle_DriverProfiles(lp).ConfigureAwait(false);
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
				fSQL.Comparison("AppsNotDriver", true, ValType.Bool));

			//Test, ob es eine ApplicationSection mit diesem Ident gibt
			if (await lp.Session.Source().ExistsAsync("SectionName", strWhereClause, lp.CancellationToken).ConfigureAwait(false))
			{
				throw new ViException(2117033, ExceptionRelevance.EndUser, identSectionName);
			}

			strWhereClause = fSQL.Comparison("Ident_SectionName", identSectionName, ValType.String);

			if (lp.Entity.IsLoaded)
			{
				//wenn es sich um die eigene Applikation handelt
				strWhereClause = fSQL.AndRelation(
						strWhereClause,
						fSQL.UidComparison("UID_Driver", lp.Entity.GetValue<string>("UID_Driver"), CompareOperator.NotEqual));
			}

			if (await lp.Session.Source().ExistsAsync("Driver", strWhereClause, lp.CancellationToken).ConfigureAwait(false))
			{
				throw new ViException(2117031, ExceptionRelevance.EndUser, identSectionName);
			}
		}

		private Task Handle_TroubleProduct(LogicParameter lp)
		{
			ISqlFormatter fSQL = lp.SqlFormatter;

			return TroubleProductHelper.HandleTroubleProduct(
				lp,
				"Driver",
				lp.Entity.GetValue<string>("NameFull"),
				"DriverProfile",
				fSQL.UidComparison("UID_Driver", lp.Entity.GetValue<string>("UID_Driver")));
		}

		private async Task Handle_DriverProfiles(LogicParameter lp)
		{
			bool bUpdateProfiles =
				(lp.Session.MetaData().IsTableEnabled("DriverProfile")
				 &&
				 (
					 lp.Entity.Columns["Ident_Driver"].IsDifferent ||
					 lp.Entity.Columns["Ident_Language"].IsDifferent ||
					 lp.Entity.Columns["Ident_Sectionname"].IsDifferent ||
					 lp.Entity.Columns["Version"].IsDifferent ||
					 lp.Entity.Columns["Ident_OS"].IsDifferent
					 )
					);

			if (!bUpdateProfiles)
				return;

			ISqlFormatter fSQL = lp.SqlFormatter;

			string strWhereClause = fSQL.AndRelation(
										fSQL.UidComparison("UID_Driver", lp.Entity.GetValue<string>("UID_Driver")),
										fSQL.OrRelation(
											fSQL.Comparison("UpdatePathVII", false, ValType.Bool),
											fSQL.Comparison("UpdateProfileVII", false, ValType.Bool))

									);

			Query qDriverProfile = Query.From("DriverProfile")
				.Where(strWhereClause)
				.SelectAll();

			IEntityCollection colDriverProfile = await lp.Session.Source().GetCollectionAsync(qDriverProfile, EntityCollectionLoadType.Bulk, lp.CancellationToken).ConfigureAwait(false);

			foreach (IEntity eDriverProfile in colDriverProfile)
			{
				// set the flags
				eDriverProfile.SetValue("UpdatePathVII", true);
				eDriverProfile.SetValue("UpdateProfileVII", true);

				// and save
				await lp.UnitOfWork.PutAsync(eDriverProfile).ConfigureAwait(false);
			}

		}
	}
}
