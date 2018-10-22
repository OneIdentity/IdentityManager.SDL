--
-- One Identity - Open Source License
--
-- Copyright 2018 One Identity LLC
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software. Any and all copies of the above
-- copyright and this permission notice contained in the Software shall not be
-- removed, obscured, or modified.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--


   --------------------------------------------------------------------------------
   --  Tabelle domain  
   --------------------------------------------------------------------------------  

exec QBM_PTriggerDrop 'SDL_TUSDLDomain' 
go





create trigger SDL_TUSDLDomain on SDLDomain    
-- with encryption 
	for Update  
	not for Replication    
as
begin


-- exec QBM_PProcedureNestLevelCheck @@ProcID

declare @DBQueueElements QBM_YDBQueueRaw 

BEGIN TRY


      if exists (select top 1 1 from inserted) goto start
      if exists (select top 1 1 from deleted) goto start
            return
start:
 
 declare @GenProcID varchar(38)
 declare @OperationLevel int 
 declare @XUser nvarchar(64)
	exec @OperationLevel = QBM_PGenprocidGetFromContext @GenProcID output, @XUser output , @CodeID = @@ProcID


  declare  @errno   int
  declare  @errmsg  nvarchar(255)

declare @Parameter nvarchar(1000)

-- 14636

-- wegen Buglist 9910
-- wenn an Forest-Informationen gedreht wurde, kann das alle möglichen Auswirkungen haben
-- hat sich wegen 10549 und 9913 erledigt

if dbo.QBM_FGIColumnUpdatedThis('SDLDomain', 'DomainGroupName', columns_updated()) = 1
 begin

	delete  @DBQueueElements 
	
	insert into @DBQueueElements (object, subobject, genprocid)
	select x.uid, null, @GenProcID
    from (    select a.uid_adsaccount as uid
		from SDLDomain t join deleted d on t.UID_SDLDomain = d.UID_SDLDomain
					and isnull(t.DomainGroupName,N'') <> isnull(d.DomainGroupName,N'')
				join ADSaccount a on a.UID_SDLDomainrd = t.UID_SDLDomain

	) as x 

	 exec QBM_PDBQueueInsert_Bulk 'SDL-K-ADSAccountInADSGroup', @DBQueueElements

end --if dbo.QBM_FGIColumnUpdatedThis('SDLDomain', 'DomainGroupName', columns_updated()) = 1


END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	

  -- Standard-Abschlussbehandlung 
ende:
  return

end
go



----------------------------------------------
-- wegen Buglist 10009
----------------------------------------------
-- IR 2008-09-04 hat sich wegen 9948 erledigt

--exec QBM_PTriggerDrop 'SDL_TDDomain'
--go



-- update BaseTree set ObjectKeyUNSContainer = null
--	where ObjectKeyUNSContainer in (select XObjectKey from deleted)

----------------------------------------------
-- / wegen Buglist 10009
----------------------------------------------

