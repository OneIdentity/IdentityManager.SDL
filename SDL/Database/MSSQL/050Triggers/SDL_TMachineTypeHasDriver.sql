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
   --  Tabelle MachineTypeHasDriver
   --------------------------------------------------------------------------------  

exec QBM_PTriggerDrop 'SDL_TDMachineTypeHasDriver' 
go





create trigger SDL_TDMachineTypeHasDriver on MachineTypeHasDriver  
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

   -- spezielle Variablen 
  declare @uid_Hardware varchar(38)

   --  allgemeine Variablen 
  declare @operation nvarchar(64)
  declare  @zeilen int
  declare  @errno   int
  declare  @errmsg  nvarchar(255)

   --  Standard-Vorbehandlung  
--  select @operation = 'MachineHasDriver'
   -- Schrittbetrieb aufmachen  

  DECLARE SDL_TDMachineTypeHasDriverSchritt CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
  -- alle Maschinen dieses Typs  selektieren 
	  select h.uid_Hardware
	      from deleted d, Hardware h
              where h.UID_MachineType = d.UID_MachineType and (h.isPC = 1 or h.isServer = 1)

  
  OPEN SDL_TDMachineTypeHasDriverSchritt
  FETCH NEXT FROM SDL_TDMachineTypeHasDriverSchritt into @uid_Hardware

  WHILE (@@fetch_status <> -1)
  BEGIN

	
	   -- Einfgen in DianlogDBQueue 
	     exec     QBM_PDBQueueInsert_Single  'SDL-K-MACHInEHasDriver',  @uid_Hardware, '', @GenProcID


       FETCH NEXT FROM SDL_TDMachineTypeHasDriverSchritt into @uid_Hardware
  END
  close SDL_TDMachineTypeHasDriverSchritt
  deallocate SDL_TDMachineTypeHasDriverSchritt

  -- Standard-Abschlussbehandlung 

END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'SDL_TDMachineTypeHasDriverSchritt'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	
ende:
  return

end
go



exec QBM_PTriggerDrop 'SDL_TIMachineTypeHasDriver' 
go





create trigger SDL_TIMachineTypeHasDriver on MachineTypeHasDriver  
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

   -- spezielle Variablen 

  declare @uid_Hardware varchar(38)

   --  allgemeine Variablen 
  declare @operation nvarchar(64)
  declare  @zeilen int
  declare  @errno   int
  declare  @errmsg  nvarchar(255)

-- Für Trigger SDL_TIMachineTypeHasDriver
-- wegen IsInactive-Filterung auf Driver
-- zu überwachen:  Relationid = R/640
	if exists (select top 1 1 from inserted i join Driver p on i.UID_Driver = p.UID_Driver
										and p.isInactive = 1
			)
	 begin
-- 11587 User - Relevanz gesetzt
		      raiserror( '#LDS#Assignment cannot take place, because the object to be assigned is disabled.|', 18, 3) with nowait
	 end

-- Für Trigger SDL_TIMachineTypeHasDriver
-- wegen IsInactive-Filterung auf MachineType
-- zu überwachen:  Relationid = R/641
	if exists (select top 1 1 from inserted i join MachineType p on i.UID_MachineType = p.UID_MachineType
										and p.isInactive = 1
			)
	 begin
-- 11587 User - Relevanz gesetzt
		      raiserror( '#LDS#Assignment cannot take place, because the object to be assigned is disabled.|', 18, 3) with nowait
	 end

-- 11550

 if exists (select top 1 1 from inserted i --join Machinetype dest on i.uid_Machinetype = dest.uid_Machinetype
									-- join auf 'dest' NICHT notwendig, da @ObjectKeyDestination nur auf ITShopOrg, ITShopSrc und Eset geprüft wird
									join Driver elem on i.uid_Driver = elem.uid_Driver
			where dbo.QER_FGIITShopFlagCombineValid (i.XObjectKey, null, null, elem.XObjectKey, elem.IsForITShop, elem.IsITShopOnly) = 0
			)
	begin
-- 11587 User - Relevanz gesetzt
		raiserror ('#LDS#Assignment is not permitted due to the combination of IT Shop flags.|', 18, 2) with nowait
	end


   --  Standard-Vorbehandlung  
--  select @operation = 'MachineHasDriver'
   -- Schrittbetrieb aufmachen  

  DECLARE SDL_TIMachineTypeHasDriverSchritt CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 

  -- alle betroffenen Maschinen selektieren 
  select h.uid_Hardware
     from MachineTypeHasDriver mthd, inserted i, Hardware h
     where mthd.UID_MachineType = i.UID_MachineType  and
           mthd.UID_MachineType = h.UID_MachineType and (h.isPC = 1 or isServer = 1)

  
  OPEN SDL_TIMachineTypeHasDriverSchritt
  FETCH NEXT FROM SDL_TIMachineTypeHasDriverSchritt into @uid_Hardware

  WHILE (@@fetch_status <> -1)
  BEGIN

	   -- Einfgen in DianlogDBQueue 
	     exec     QBM_PDBQueueInsert_Single  'SDL-K-MACHInEHasDriver',  @uid_Hardware, '', @GenProcID
	

       FETCH NEXT FROM SDL_TIMachineTypeHasDriverSchritt INTO @uid_Hardware
  END
  close SDL_TIMachineTypeHasDriverSchritt
  deallocate SDL_TIMachineTypeHasDriverSchritt

  -- Standard-Abschlussbehandlung 

END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'SDL_TIMachineTypeHasDriverSchritt'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	
ende:
  return

end
go

