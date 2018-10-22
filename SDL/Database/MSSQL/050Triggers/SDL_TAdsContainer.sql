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
   --  Tabelle AdsContainer   neu 2001-09-20
   --------------------------------------------------------------------------------  


exec QBM_PTriggerDrop 'SDL_TIAdsContainer' 
go





create trigger SDL_TIAdsContainer on adscontainer  
-- with encryption 
	for insert 
	not for Replication    
 as
 begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID

BEGIN TRY

      if exists (select top 1 1 from inserted) goto start
            return
start:
 
 declare @GenProcID varchar(38)
 declare @OperationLevel int 
 declare @XUser nvarchar(64)
	exec @OperationLevel = QBM_PGenprocidGetFromContext @GenProcID output, @XUser output , @CodeID = @@ProcID

  declare @uid_ADSContainer varchar(38)

--  declare @alt_isAppContainer bit
  declare @neu_isAppContainer bit

  DECLARE SDL_TIAdsContainerschritt CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
  select isnull(isAppcontainer,0) ,uid_adscontainer 
	from inserted
  

  open SDL_TIAdsContainerschritt
  FETCH NEXT FROM SDL_TIAdsContainerschritt into @neu_isAppContainer, @uid_adsContainer

  WHILE (@@fetch_status <> -1)
  BEGIN
	  if @neu_isAppcontainer = 1 
	    begin
--		exec viInsertAppGroupInADSContainer @uid_adsContainer
		exec     QBM_PDBQueueInsert_Single 'SDL-K-AppContainerInsert', @uid_adsContainer, '', @GenProcID
	    end
     FETCH NEXT FROM SDL_TIAdsContainerschritt into @neu_isAppContainer, @uid_adsContainer
  END
  close SDL_TIAdsContainerschritt
  deallocate SDL_TIAdsContainerschritt

END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'SDL_TIAdsContainerschritt'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	

 end
go


exec QBM_PTriggerDrop 'SDL_TUAdsContainer'
go
-- wirkt bei nderung der Eigenschaft IsAppContainer
-- veranlat erzeugen bzw. lschen der Applikationsgruppen in diesem Container





create trigger SDL_TUAdsContainer on adscontainer  
-- with encryption 
	for update 
	not for Replication    
 as
 begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID

BEGIN TRY

      if exists (select top 1 1 from inserted) goto start
      if exists (select top 1 1 from deleted) goto start
            return
start:
 
 declare @GenProcID varchar(38)
 declare @OperationLevel int 
 declare @XUser nvarchar(64)
	exec @OperationLevel = QBM_PGenprocidGetFromContext @GenProcID output, @XUser output , @CodeID = @@ProcID

  declare @uid_ADSContainer varchar(38)

  declare @alt_isAppContainer bit
  declare @neu_isAppContainer bit
if dbo.QBM_FGIColumnUpdatedThis('adscontainer', 'isAppcontainer', columns_updated()) = 1
 begin
  DECLARE SDL_TUAdsContainerschritt CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
  select isnull(adscontainer.isAppcontainer,0) ,isnull(deleted.isAppContainer,0), adscontainer.uid_adscontainer 
	from adscontainer, deleted
		where adscontainer.uid_adscontainer = deleted.uid_adscontainer
  
  open SDL_TUAdsContainerschritt
  FETCH NEXT FROM SDL_TUAdsContainerschritt into @neu_isAppContainer, @alt_isAppContainer, @uid_adsContainer
  WHILE (@@fetch_status <> -1)
  BEGIN
  if @alt_isappcontainer <> @neu_isappContainer 
   begin
	  if @neu_isAppcontainer = 1 
	    begin
--		exec viInsertAppGroupInADSContainer @uid_adsContainer
		exec     QBM_PDBQueueInsert_Single 'SDL-K-AppContainerInsert', @uid_adsContainer, '', @GenProcID
	    end
	  else
	    begin
--		exec viDeleteAppGroupInADSContainer @uid_adsContainer
		exec     QBM_PDBQueueInsert_Single 'SDL-K-AppContainerDelete', @uid_adsContainer, '', @GenProcID
	    end
   end
     FETCH NEXT FROM SDL_TUAdsContainerschritt into @neu_isAppContainer, @alt_isAppContainer, @uid_adsContainer
  END
  close SDL_TUAdsContainerschritt
  deallocate SDL_TUAdsContainerschritt
 end

END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'SDL_TUAdsContainerschritt'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	
 end
go




----------------------------------------------
-- wegen Buglist 10009
----------------------------------------------
-- IR 2008-09-04 hat sich wegen 9948 erledigt

--exec QBM_PTriggerDrop 'SDL_TDAdsContainer'
--go



-- update BaseTree set ObjectKeyUNSContainer = null
--	where ObjectKeyUNSContainer in (select XObjectKey from deleted)

----------------------------------------------
-- / wegen Buglist 10009
----------------------------------------------

