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
   --  Tabelle HardwareTypeHasDriver
   --------------------------------------------------------------------------------  

exec QBM_PTriggerDrop 'SDL_TDHardwareTypeHasDriver' 
go





create trigger SDL_TDHardwareTypeHasDriver on HardwareTypeHasDriver  
-- with encryption 
	for Delete 
	not for Replication    
  as
 begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID
declare @DBQueueElements QBM_YDBQueueRaw 

BEGIN TRY


      if exists (select top 1 1 from deleted) goto start
            return
start:
 
 declare @GenProcID varchar(38)
 declare @OperationLevel int 
 declare @XUser nvarchar(64)
	exec @OperationLevel = QBM_PGenprocidGetFromContext @GenProcID output, @XUser output , @CodeID = @@ProcID


		delete  @DBQueueElements 
	
		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
	    from (    select distinct h.uid_Hardware as uid
			from Hardware h join deleted d on h.uid_Hardwaretype = d.uid_Hardwaretype
		) as x 
		
		exec QBM_PDBQueueInsert_Bulk 'SDL-K-MACHInEHasDriver', @DBQueueElements

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



exec QBM_PTriggerDrop 'SDL_TIHardwareTypeHasDriver' 
go





create trigger SDL_TIHardwareTypeHasDriver on HardwareTypeHasDriver  
-- with encryption 
	for Insert 
	not for Replication    
  as
 begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID
declare @DBQueueElements QBM_YDBQueueRaw 

BEGIN TRY


      if exists (select top 1 1 from inserted) goto start
            return
start:
 
 declare @GenProcID varchar(38)
 declare @OperationLevel int 
 declare @XUser nvarchar(64)
	exec @OperationLevel = QBM_PGenprocidGetFromContext @GenProcID output, @XUser output , @CodeID = @@ProcID

   -- spezielle Variablen 
  --  allgemeine Variablen 
  declare  @errmsg  nvarchar(255)

/*
-- Für Trigger SDL_TIHardwaretypeHasDriver
-- wegen IsInactive-Filterung auf HardwareType
-- zu überwachen:  Relationid = R/1312
	if exists (select top 1 1 from inserted i join HardwareType p on i.UID_Hardwaretype = p.UID_Hardwaretype
										and p.isInactive = 1
			)
	 begin
		      raise rror( N' # L D S # A s s i  gnment cannot take place, because the object to be assigned is disabled.|', 18, 3) with nowait
		      
	 end
*/

		delete  @DBQueueElements 
	
		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
	    from (    select distinct h.uid_Hardware as uid
			from Hardware h join inserted d on h.uid_Hardwaretype = d.uid_Hardwaretype
		) as x 
		
		exec QBM_PDBQueueInsert_Bulk 'SDL-K-MACHInEHasDriver', @DBQueueElements

  -- Standard-Abschlussbehandlung 

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
	                                	        	
ende:
  return

end
go


