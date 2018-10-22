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
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using VI.Base;
using VI.DB;
using VI.DB.Entities;


namespace SDL.Customizer
{
	/// <summary>
	/// EntityLogic for table SDLDomain
	/// </summary>
	public class SDLDomain : StateLessEntityLogic
	{
		public SDLDomain()
		{
			Check("IsMaster")
				.AsExpensive<bool>( _CheckIsMaster);

			Check("ServerPartShareOnServers")
				.AsExpensive<string>(_CheckServerPartShareOnServers);

			Check("ServerPartShareOnTAS")
				.AsExpensive<string>(_CheckServerPartShareOnTAS);

			Check("ShareOnServers")
				.AsExpensive<string>(_CheckShareOnServers);

			Check("ShareOnTAS")
				.AsExpensive<string>(_CheckShareOnTAS);

			Check("UID_ServerTAS")
				.AsExpensive<string>(_CheckUidServerTas);

			Event("DistributeNetlogon")
				.CustomGenerated();

			RegisterFunction("GetRootAppServer")
				.As<bool,IEntity>(_GetRootAppServer)
				.Description("Method_Domain_GetRootAppServer");

			RegisterFunction("GetRootAppServerName")
					.As<string>(_GetRootAppServerName)
				.Description("Method_Domain_GetRootAppServerName");

			RegisterFunction("GetNetPath")
				.As<bool,string>(_GetNetPath)
				.Description("Method_Domain_GetNetPath");

			RegisterFunction("GetTAS")
				.As<bool, IEntity>(_GetTAS)
				.Description("Method_Domain_GetTAS");

			RegisterFunction("GetTASName")
				.As<string>(_GetTASName)
				.Description("Method_Domain_GetTASName");

			RegisterFunction("GetCLServer")
				.As<bool, IEntity>(_GetCLServer)
				.Description("Method_Domain_GetCLServer");

			RegisterMethod("DistributeNetlogon")
				.As<string, string>(_DistributeNetlogon)
				.Description("Method_Domain_DistributeNetlogon_PathFile")
				.NeedsSaving();

			RegisterMethod("DistributeNetlogon")
				.As<string>( async (s, e, filePath, ct) => await _DistributeNetlogon(s, e, filePath, null, ct).ConfigureAwait(false))
				.Description("Method_Domain_DistributeNetlogon_PathFile")
				.NeedsSaving();

			RegisterFunction("RootAppsIsTAS")
				.As<string, bool, bool>(_RootAppsIsTAS)
				.Description("Method_Domain_RootAppsIsTAS");

			RegisterFunction("RootAppsIsTAS")
				.As<string, bool>( async (s,e, uidServerTas, ct) => await _RootAppsIsTAS(s,e, uidServerTas, true, ct).ConfigureAwait(false))
				.Description("Method_Domain_RootAppsIsTAS");
		}

		#region public functions

		private static async Task<IEntity> _GetRootAppServer(ISession session, IEntity entity, bool doWithoutTasNotFoundError, CancellationToken ct)
		{
			string uidSdlDomain = entity.GetValue<string>("UID_SDLDomain");

			//wenn Domäne nicht belegt ==> 'rausgehen
			if (String.IsNullOrEmpty(uidSdlDomain))
			{
				return null;
			}

			Query qApplicationServer = Query.From("ApplicationServer")
				.Where(c => c.Column("UID_SDLDomain") == uidSdlDomain &&
							c.Column("UID_ParentApplicationServer") == "")
				.SelectAll();

			var trApplicationServer = await session.Source().TryGetAsync(qApplicationServer, ct).ConfigureAwait(false);

			if (!trApplicationServer.Success)
			{
				if (!doWithoutTasNotFoundError)
				{
					throw new ViException(2116145, ExceptionRelevance.EndUser, entity.GetValue("Ident_Domain"));
				}

				return null;
			}

			// get the ApplicationServer
			IEntity appServer = trApplicationServer.Result;

			IEntityForeignKey fkServer = await appServer.GetFkAsync(session, "UID_Server", ct).ConfigureAwait(false);

			if (fkServer.IsEmpty())
			{
				if (!doWithoutTasNotFoundError)
				{
					throw new ViException(2116146, ExceptionRelevance.EndUser, "ApplicationServer[\"UID_Server\"]");
				}

				return null;
			}

			return await fkServer.GetParentAsync(EntityLoadType.Default, ct).ConfigureAwait(false);
		}

		private async Task<string> _GetRootAppServerName(ISession session, IEntity entity, CancellationToken ct)
		{
			IEntity theServer = await _GetRootAppServer(session, entity, false, ct).ConfigureAwait(false);

			return theServer.GetValue<string>("Ident_Server");
		}

		private async Task _DistributeNetlogon(ISession session, IEntity entity, string filePath, string fileName, CancellationToken ct)
		{
			Dictionary<string, object> param = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);

			if (!String.IsNullOrEmpty(filePath))
			{
				param.Add("FilePath", filePath);
			}

			if (!String.IsNullOrEmpty(fileName))
			{
				param.Add("FileName", fileName);
			}

			using (var uoWork = session.StartUnitOfWork())
			{
				await uoWork.GenerateAsync(entity, "DistributeNetlogon", param, ct).ConfigureAwait(false);
			}
		}

		private async Task<string> _GetNetPath(ISession session, IEntity entity, bool doForTas, CancellationToken ct)
		{
			string theShare;
			string theServer;
			string theClient = await entity.GetValueAsync<string>("ClientPartPathOnServers", cancellationToken: ct).ConfigureAwait(false);

			if (doForTas)
			{
				theShare = entity.GetValue<string>("ShareOnTAS");
				theServer = await _GetTASName(session, entity, ct).ConfigureAwait(false);
			}
			else
			{
				theShare = entity.GetValue<string>("ShareOnServers");
				theServer = await _GetRootAppServerName(session, entity, ct).ConfigureAwait(false);
			}

			if (String.IsNullOrEmpty(theShare) || 
				String.IsNullOrEmpty(theClient) || 
				String.IsNullOrEmpty(theServer))
			{
				throw new ViException(2116147, ExceptionRelevance.EndUser);
			}
			
			return  String.Concat(@"\\", theServer, @"\", theShare, @"\", theClient);;
		}

		private async Task<IEntity> _GetTAS(ISession session, IEntity entity, bool doWithoutTasNotFoundError, CancellationToken ct)
		{
			IEntityForeignKey fkServerTas = await entity.GetFkAsync(session, "UID_ServerTAS", ct).ConfigureAwait(false);

			if ( fkServerTas.IsEmpty())
			{
				if (doWithoutTasNotFoundError)
					return null;
			
				throw new ViException(2116148, ExceptionRelevance.EndUser, "TAS", entity.GetValue<string>("Ident_Domain"));
			}

			return await fkServerTas.GetParentAsync(EntityLoadType.Default, ct).ConfigureAwait(false);
		}

		private async Task<string> _GetTASName(ISession session, IEntity entity, CancellationToken ct)
		{
			IEntity theServer = await _GetTAS(session, entity, false, ct).ConfigureAwait(false);

			return theServer.GetValue<string>("Ident_Server");
		}

		private async Task<IEntity> _GetCLServer(ISession session, IEntity entity, bool doWithoutNotFoundError, CancellationToken ct)
		{
			Query qApplicationServer = Query.From("ApplicationServer")
				.Where(c => c.Column("IsCentralLibrary") == true)
				.SelectAll();

			var trCentralLibrary = await session.Source().TryGetAsync(qApplicationServer, ct).ConfigureAwait(false);

			if (!trCentralLibrary.Success)
			{
				if (!doWithoutNotFoundError)
				{
					throw new ViException(2116145, ExceptionRelevance.EndUser, entity.GetValue<string>("Ident_Domain"));
				}

				return null;
			}

			// get the ApplicationServer
			IEntity appServer = trCentralLibrary.Result;

			IEntityForeignKey fkServer = await appServer.GetFkAsync(session, "UID_Server", ct).ConfigureAwait(false);

			if (fkServer.IsEmpty())
			{
				if (!doWithoutNotFoundError)
				{
					throw new ViException(2116146, ExceptionRelevance.EndUser, "ApplicationServer[\"UID_Server\"]");
				}

				return null;
			}

			return await fkServer.GetParentAsync(EntityLoadType.Default, ct).ConfigureAwait(false);
		}


		private static async Task<bool> _RootAppsIsTAS(ISession session, IEntity entity, string uidServerTas, bool with2116144, CancellationToken ct)
		{
			IEntity dbTasServer ;

			if (!String.IsNullOrEmpty(uidServerTas))
			{
				DbObjectKey dbokServerTas = DbObjectKey.GetObjectKey("QBMServer", uidServerTas);
				var trServerTas = await session.Source().TryGetAsync(dbokServerTas, ct).ConfigureAwait(false);

				if ( ! trServerTas.Success)
				{
					throw new ViException(2116052, ExceptionRelevance.EndUser, uidServerTas);
				}

				dbTasServer = trServerTas.Result;
			}
			else
			{
				IEntityForeignKey fkServerTas = await entity.GetFkAsync(session, "UID_ServerTas", ct).ConfigureAwait(false);
				if (! fkServerTas.IsEmpty())
				{
					dbTasServer = await fkServerTas.GetParentAsync(EntityLoadType.Default, ct).ConfigureAwait(false);
				}
				else
				{
					if (with2116144)
					{
						throw new ViException(2116144, ExceptionRelevance.EndUser);
					}

					return false;
				}
			}

			IEntity dbRootAppServer = await _GetRootAppServer(session, entity, false, ct).ConfigureAwait(false);

			return String.Equals(dbRootAppServer.GetValue<string>("Ident_Server"), dbTasServer.GetValue<string>("Ident_Server"));
		}

		#endregion

		#region eventhandler

		private static async Task<bool> _CheckIsMaster(ISession session, IEntity entity, bool isMaster, CancellationToken ct)
		{
			if (!isMaster)
				return true;

			string uidSdlDomain = entity.GetValue("UID_SDLDomain");

			Query qIsMaster = Query.From("SDLDomain")
				.Where(c => c.Column("IsMaster") == true && c.Column("UID_SDLDomain") != uidSdlDomain)
				.SelectDisplays();

			var eOther = await session.Source().TryGetAsync(qIsMaster, ct).ConfigureAwait(false);

			if (eOther.Success)
				throw new ViException(2116022, ExceptionRelevance.EndUser, eOther.Result.Display);

			return true;
		}

		private static async Task<bool> _CheckServerPartShareOnServers(ISession session, IEntity entity, string serverPartShareOnServers,
			CancellationToken ct)
		{
			if ( await _RootAppsIsTAS(session,entity,"", false, ct).ConfigureAwait(false) &&
				String.Equals(serverPartShareOnServers, entity.GetValue<string>("ServerPartShareOnTas"), StringComparison.OrdinalIgnoreCase))
			{
				throw new ViException(2116016, ExceptionRelevance.EndUser, "ServerPartShareOnServers", "ServerPartShareOnTAS");
			}

			return true;
		}

		private static async Task<bool> _CheckShareOnServers(ISession session, IEntity entity, string serverOnServers,
			CancellationToken ct)
		{
			if (await _RootAppsIsTAS(session, entity, "", false, ct).ConfigureAwait(false) &&
			    String.Equals(serverOnServers, entity.GetValue<string>("ShareOnTas"), StringComparison.OrdinalIgnoreCase))
			{
				throw new ViException(2116016, ExceptionRelevance.EndUser, "ShareOnServers", "ShareOnTAS");
			}
			return true;
		}

		private static async Task<bool> _CheckServerPartShareOnTAS(ISession session, IEntity entity, string serverPartShareOnTAS,
			CancellationToken ct)
		{
			if (await _RootAppsIsTAS(session, entity, "", false, ct).ConfigureAwait(false) &&
				 String.Equals(serverPartShareOnTAS ,entity.GetValue<string>("ServerPartShareOnServers")))
			{
				throw new ViException(2116016, ExceptionRelevance.EndUser, "ServerPartShareOnTAS", "ServerPartShareOnServers");
			}

			return true;
		}

		private static async Task<bool> _CheckShareOnTAS(ISession session, IEntity entity, string serverOnTAS,
			CancellationToken ct)
		{
			if (await _RootAppsIsTAS(session, entity, "", false, ct).ConfigureAwait(false) &&
				String.Equals(serverOnTAS, entity.GetValue<string>("ShareOnServers"), StringComparison.OrdinalIgnoreCase))
			{
				throw new ViException(2116016, ExceptionRelevance.EndUser, "ShareOnTAS", "ShareOnServers");
			}
			return true;
		}

		private static async Task<bool> _CheckUidServerTas(ISession session, IEntity entity, string uidServerTas,
			CancellationToken ct)
		{
			IEntity theRootApp = await _GetRootAppServer(session, entity, true, ct).ConfigureAwait(false);

			if ((theRootApp != null) && 
				String.Equals( theRootApp.GetValue<string>("UID_QBMServer"), uidServerTas))
			{
				string strMessage = "";

				if (String.Equals( 
						entity.GetValue<string>("ShareOnServers"), 
						entity.GetValue<string>("ShareOnTAS"), StringComparison.OrdinalIgnoreCase))
				{
					strMessage = LanguageManager.Instance.FormatString("strError2116016", "ShareOnServers", "ShareOnTAS");
				}

				if (String.Equals( entity.GetValue<string>("NetLogonOnTAS"), "NETLOGON", StringComparison.OrdinalIgnoreCase))
				{
					strMessage = LanguageManager.Instance.FormatString("strError2116016", "NETLOGON", "NetlogonOnTAS");
				}

				if ( String.Equals( 
						entity.GetValue<string>("ServerPartShareOnServers"), 
						entity.GetValue<string>("ServerPartShareOnTAS"), StringComparison.OrdinalIgnoreCase))
				{
					strMessage = LanguageManager.Instance.FormatString("strError2116016", "ServerPartShareOnServers",
								 "ServerPartShareOnTAS");
				}

				if (!String.IsNullOrEmpty(strMessage))
				{
					throw new ViException(2116016, ExceptionRelevance.EndUser, strMessage, null);
				}
			}

			return true;
		}

		#endregion
	}
}
