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
	/// EntityLogic for table <c>SectionName</c>
	/// </summary>
	public class SectionName : StateLessEntityLogic
	{
		public SectionName()
		{
			CanEdit("Ident_SectionName", "AppsNotDriver")
				.From(State.IsLoaded)
				.As((bool isLoaded) => !isLoaded);

			Value("Ident_SectionName")
				.From("AppsNotDriver",
					State.IsLoaded,
					@"Config(Software\Application\Group\Prefix)",
					@"Config(Software\Driver\Section\Prefix)",
					"Ident_SectionName")
				.As<bool, bool, string, string, string, TryResult<string>>(_ValueSectionName);

			Value("AppsNotDriver")
				.From("Ident_SectionName",
					State.IsLoaded,
					@"Config(Software\Application\Group\Prefix)",
					@"Config(Software\Driver\Section\Prefix)")
				.As<string, bool, string, string, TryResult<bool>>(_ValueAppsNotDriver);
		}

		private TryResult<string> _ValueSectionName(bool isApp, bool isLoaded, string appPrefix, string drvPrefix,
			string identSectionName)
		{
			if (isLoaded)
				return TryResult<string>.Failed;

			string prefix = isApp ? appPrefix : drvPrefix;

			if (!String.IsNullOrEmpty(prefix))
			{
				if (identSectionName.StartsWith(appPrefix))
					identSectionName = identSectionName.Substring(appPrefix.Length);

				if (identSectionName.StartsWith(drvPrefix))
					identSectionName = identSectionName.Substring(drvPrefix.Length);

				return TryResult<string>.FromResult(prefix + identSectionName);
			}

			return TryResult<string>.Failed;
		}

		private TryResult<bool> _ValueAppsNotDriver(string identSectionName, bool isLoaded, string appPrefix, string drvPrefix)
		{
			if (isLoaded)
				return TryResult<bool>.Failed;

			if (identSectionName.StartsWith(appPrefix, StringComparison.OrdinalIgnoreCase))
				return TryResult<bool>.FromResult(true);

			if (identSectionName.StartsWith(drvPrefix, StringComparison.OrdinalIgnoreCase))
				return TryResult<bool>.FromResult(false);

			return TryResult<bool>.Failed;
		}

		public override async Task<Diff> OnSavingAsync(IEntity entity, LogicReadWriteParameters parameters,
			CancellationToken cancellationToken)
		{
			ISession session = parameters.Session;

			if (! entity.IsDeleted())
			{
				await _IsValidSectionNamePrefix(session, entity, cancellationToken).ConfigureAwait(false);

				if (!entity.IsLoaded)
				{

					if ( await session.Source().ExistsAsync("SectionName", session.SqlFormatter()
							.Comparison("Ident_SectionName", entity.GetValue<string>("Ident_SectionName"), ValType.String,
											CompareOperator.Equal, FormatterOptions.IgnoreCase), ct: cancellationToken).ConfigureAwait(false))
					{
						throw new ViException(2116031, ExceptionRelevance.EndUser, entity.GetValue<string>("Ident_SectionName"));
					}
				}
			}

			return await base.OnSavingAsync(entity, parameters, cancellationToken).ConfigureAwait(false);
		}

		private async Task _IsValidSectionNamePrefix(ISession session, IEntity entity, CancellationToken cancellationToken)
		{
			string identSectionName = entity.GetValue<string>("Ident_SectionName");
			string prefix;

			if (String.IsNullOrEmpty(identSectionName))
			{
				return;
			}

			if (entity.GetValue<bool>("AppsNotDriver"))
			{
				prefix =
					await
						session.Config().GetConfigParmAsync(@"Software\Application\Group\Prefix", cancellationToken).ConfigureAwait(false);
			}
			else
			{
				prefix =
					await
						session.Config().GetConfigParmAsync(@"Software\Driver\Section\Prefix", cancellationToken).ConfigureAwait(false);
			}

			if (! String.IsNullOrEmpty(prefix))
			{
				if (! identSectionName.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
				{
					throw new ViException(2116036, ExceptionRelevance.EndUser, identSectionName);
				}

				if (String.Equals(identSectionName, prefix))
				{
					throw new ViException(2116042, ExceptionRelevance.EndUser, identSectionName);
				}
			}
		}
	}
}
