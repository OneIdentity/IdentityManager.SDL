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
   --  Tabelle DriverDependsOnDriver
   --------------------------------------------------------------------------------  

exec QBM_PTriggerDrop 'SDL_TDDriverDependsOnDriver' 
go





create trigger SDL_TDDriverDependsOnDriver on DriverDependsOnDriver  
-- with encryption 
for Delete 
	not for Replication    
as
 begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID

BEGIN TRY

      if exists (select top 1 1 from deleted) goto start
            return
start:
 
 declare @GenProcID varchar(38)
 declare @OperationLevel int 
 declare @XUser nvarchar(64)
	exec @OperationLevel = QBM_PGenprocidGetFromContext @GenProcID output, @XUser output , @CodeID = @@ProcID


   --  allgemeine Variablen 
  declare  @zeilen int
  declare  @errno   int
  declare  @errmsg  nvarchar(255)

	-- wenn die Verarbeitung hier ankommt, war mindestens eine Zeile Betroffen
     exec     QBM_PDBQueueInsert_Single 'SDL-K-DriverMakeSortOrder', '', '', @GenProcID

  if exists (select top 1 1 from deleted where IsPhysicalDependent = 1)
    begin
     exec     QBM_PDBQueueInsert_Single 'SDL-K-SoftwareDependsPhysical', '', '', @GenProcID
    end


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


exec QBM_PTriggerDrop 'SDL_TIDriverDependsOnDriver' 
go





create trigger SDL_TIDriverDependsOnDriver on DriverDependsOnDriver  
-- with encryption 
	for Insert 
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

  declare  @errno   int
  declare  @errmsg  nvarchar(255)

-- Für Trigger SDL_TIDriverDependsOnDriver
-- wegen IsInactive-Filterung auf Driver
-- zu überwachen:  Relationid = R/1276
	if exists (select top 1 1 from inserted i join Driver p on i.UID_DriverParent = p.UID_Driver
										and p.isInactive = 1
			)
	 begin
-- 11587 User - Relevanz gesetzt
		      raiserror( '#LDS#Assignment cannot take place, because the object to be assigned is disabled.|', 18, 3) with nowait
		      
	 end

-- Für Trigger SDL_TIDriverDependsOnDriver
-- wegen IsInactive-Filterung auf Driver
-- zu überwachen:  Relationid = R/1277
	if exists (select top 1 1 from inserted i join Driver p on i.UID_DriverChild = p.UID_Driver
										and p.isInactive = 1
			)
	 begin
-- 11587 User - Relevanz gesetzt
		      raiserror( '#LDS#Assignment cannot take place, because the object to be assigned is disabled.|', 18, 3) with nowait
		      
	 end


	-- wenn die Verarbeitung hier ankommt, war mindestens eine Zeile Betroffen
     exec     QBM_PDBQueueInsert_Single 'SDL-K-DriverMakeSortOrder', '', '', @GenProcID

  if exists (select top 1 1 from inserted where IsPhysicalDependent = 1)
    begin
     exec     QBM_PDBQueueInsert_Single 'SDL-K-SoftwareDependsPhysical', '', '', @GenProcID
    end


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





exec QBM_PTriggerDrop 'SDL_TUDriverDependsOnDriver' 
go





create trigger SDL_TUDriverDependsOnDriver on DriverDependsOnDriver  
-- with encryption 
	for Update  
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

   --  allgemeine Variablen 
  declare  @errno   int
  declare  @errmsg  nvarchar(255)


  if exists (select top 1 1 
		from DriverDependsOnDriver a join deleted d on a.UID_DriverChild = d.UID_DriverChild
								and a.UID_DriverParent = d.UID_DriverParent
								and isnull(a.IsPhysicalDependent,0) <> isnull(d.IsPhysicalDependent,0) 
	   )
    begin
     exec     QBM_PDBQueueInsert_Single 'SDL-K-SoftwareDependsPhysical', '', '', @GenProcID
    end



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

