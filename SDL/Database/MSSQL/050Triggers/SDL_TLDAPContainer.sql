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
   --  Tabelle LDAPContainer   
   --------------------------------------------------------------------------------  


exec QBM_PTriggerDrop 'SDL_TILDAPContainer' 
go





create trigger SDL_TILDAPContainer on LDAPContainer  
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

  declare @uid_LDAPContainer varchar(38)

--  declare @alt_isAppContainer bit
  declare @neu_isAppContainer bit
--  declare @operation nvarchar(64)

if dbo.QBM_FGIColumnUpdatedThis('LDAPContainer', 'isAppcontainer', columns_updated()) = 1
 begin
  DECLARE SDL_TILDAPContainerschritt CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
  select isnull(isAppcontainer,0) ,uid_LDAPContainer 
	from inserted
  

  open SDL_TILDAPContainerschritt
  FETCH NEXT FROM SDL_TILDAPContainerschritt into @neu_isAppContainer, @uid_LDAPContainer

  WHILE (@@fetch_status <> -1)
  BEGIN
	  if @neu_isAppcontainer = 1 
	    begin
--		exec viInsertAppGroupInLDAPContainer @uid_LDAPContainer
		exec     QBM_PDBQueueInsert_Single 'SDL-K-LDAPAppContainerInsert', @uid_LDAPContainer, '', @GenProcID
	    end
     FETCH NEXT FROM SDL_TILDAPContainerschritt into @neu_isAppContainer, @uid_LDAPContainer
  END
  close SDL_TILDAPContainerschritt
  deallocate SDL_TILDAPContainerschritt
 end


END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'SDL_TILDAPContainerschritt'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	
 end
go


exec QBM_PTriggerDrop 'SDL_TULDAPContainer'
go
-- wirkt bei nderung der Eigenschaft IsAppContainer
-- veranlat erzeugen bzw. lschen der Applikationsgruppen in diesem Container





create trigger SDL_TULDAPContainer on LDAPContainer  
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

  declare @uid_LDAPContainer varchar(38)

  declare @alt_isAppContainer bit
  declare @neu_isAppContainer bit

if dbo.QBM_FGIColumnUpdatedThis('LDAPContainer', 'isAppcontainer', columns_updated()) = 1
 begin
  DECLARE SDL_TULDAPContainerschritt CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
  select isnull(LDAPContainer.isAppcontainer,0) ,isnull(deleted.isAppContainer,0), LDAPContainer.uid_LDAPContainer 
	from LDAPContainer, deleted
		where LDAPContainer.uid_LDAPContainer = deleted.uid_LDAPContainer
  
  open SDL_TULDAPContainerschritt
  FETCH NEXT FROM SDL_TULDAPContainerschritt into @neu_isAppContainer, @alt_isAppContainer, @uid_LDAPContainer
  WHILE (@@fetch_status <> -1)
  BEGIN
  if @alt_isappcontainer <> @neu_isappContainer 
   begin
	  if @neu_isAppcontainer = 1 
	    begin
			exec     QBM_PDBQueueInsert_Single 'SDL-K-LDAPAppContainerInsert', @uid_LDAPContainer, '', @GenProcID
	    end
	  else
	    begin
			exec     QBM_PDBQueueInsert_Single 'SDL-K-LDAPAppContainerDelete', @uid_LDAPContainer, '', @GenProcID
	    end
   end
     FETCH NEXT FROM SDL_TULDAPContainerschritt into @neu_isAppContainer, @alt_isAppContainer, @uid_LDAPContainer
  END
  close SDL_TULDAPContainerschritt
  deallocate SDL_TULDAPContainerschritt
 end

END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'SDL_TULDAPContainerschritt'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	
 end
go




----------------------------------------------
-- wegen Buglist 10009
----------------------------------------------
-- IR 2008-09-04 hat sich wegen 9948 erledigt

--exec QBM_PTriggerDrop 'SDL_TDLDAPContainer'
--go


-- update BaseTree set ObjectKeyUNSContainer = null
--	where ObjectKeyUNSContainer in (select XObjectKey from deleted)


----------------------------------------------
-- / wegen Buglist 10009
----------------------------------------------


