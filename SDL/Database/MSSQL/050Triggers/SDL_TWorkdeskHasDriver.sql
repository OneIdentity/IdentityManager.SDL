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
   --  Tabelle WorkDeskHasDriver
   --------------------------------------------------------------------------------  


exec QBM_PTriggerDrop 'SDL_TIWorkDeskHasDriver' 
go





create trigger SDL_TIWorkDeskHasDriver on WorkDeskHasDriver  
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

  declare @uid_WorkDesk varchar(38)

   --  allgemeine Variablen 
  declare @operation nvarchar(64)
  declare  @zeilen int
  declare  @errno   int
  declare  @errmsg  nvarchar(255)

-- Für Trigger SDL_TIWorkDeskHasDriver
-- wegen IsInactive-Filterung auf Driver
-- zu überwachen:  Relationid = R/644
	if exists (select top 1 1 from inserted i join Driver p on i.UID_Driver = p.UID_Driver
										and p.isInactive = 1
			)
	 begin
-- 11587 User - Relevanz gesetzt
		      raiserror( '#LDS#Assignment cannot take place, because the object to be assigned is disabled.|', 18, 3) with nowait
	 end

-- 11550
 if exists (select top 1 1 from inserted i --join WorkDesk dest on i.uid_WorkDesk = dest.uid_WorkDesk
									-- join auf 'dest' NICHT notwendig, da @ObjectKeyDestination nur auf ITShopOrg, ITShopSrc und Eset geprüft wird
									join Driver elem on i.uid_Driver = elem.uid_Driver
			where dbo.QER_FGIITShopFlagCombineValid(i.XObjectKey, null, null, elem.XObjectKey, elem.IsForITShop, elem.IsITShopOnly) = 0
			and i.XOrigin & dbo.QBM_FGIBitPatternXOrigin('|Direct|', 0) > 0
			)
	begin
-- 11587 User - Relevanz gesetzt
		raiserror ('#LDS#Assignment is not permitted due to the combination of IT Shop flags.|', 18, 2) with nowait
	end


	delete  @DBQueueElements 
	
	insert into @DBQueueElements (object, subobject, genprocid)
	select x.uid, null, @GenProcID
    from (   select distinct i.UID_WorkDesk as uid
				from inserted i
--				where i.XIsInEffect = 0 -- nicht die noch nicht berechneten
				-- wenn es nicht über Erbschaft kam, nachberechnen
				where i.XOrigin & dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 1) > 0
		) as x 
	
	 exec QBM_PDBQueueInsert_Bulk 'SDL-K-WorkdeskHasDriver', @DBQueueElements


		delete  @DBQueueElements 
	
		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
	    from ( 
				select h.uid_Hardware 	as uid
					from inserted  i join Hardware h on i.uid_WorkDesk = h.uid_WorkDesk
													 and (h.ispc = 1 or h.isServer = 1)
					where i.XIsInEffect = 1
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
	                                	        	
ende:
  return

end
go



exec QBM_PTriggerDrop 'SDL_TUWorkDeskHasDriver' 
go





create trigger SDL_TUWorkDeskHasDriver on WorkDeskHasDriver  
-- with encryption 
	for update 
	not for Replication    
  as
 begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID
declare @DBQueueElements QBM_YDBQueueRaw 

BEGIN TRY

      if exists (select top 1 1 from deleted) goto start
      if exists (select top 1 1 from inserted) goto start
            return
start:
 
 declare @GenProcID varchar(38)
 declare @OperationLevel int 
 declare @XUser nvarchar(64)
	exec @OperationLevel = QBM_PGenprocidGetFromContext @GenProcID output, @XUser output , @CodeID = @@ProcID

-- wenn sich eines der Bits außer 0 x 0 2 ändert, Nachberechnung
if dbo.QBM_FGIColumnUpdatedThis('WorkDeskHasDriver', 'XOrigin', columns_updated()) = 1
 begin 

	delete @DBQueueElements 
	insert into @DBQueueElements (object, subobject, genprocid)
	select x.uid, null, @GenProcID
    from (
			select distinct d.UID_WorkDesk as uid
			 from deleted d join WorkDeskHasDriver dd on d.UID_WorkDesk = dd.UID_WorkDesk
															and d.UID_Driver = dd.UID_Driver
			where dbo.QBM_FGIXOriginChanged_Except2(d.XOrigin, dd.XOrigin) = 1
				-- wegen 20349 weg
--				and dd.XIsInEffect = 1

		) as x 	

	exec QBM_PDBQueueInsert_Bulk 'SDL-K-WorkdeskHasDriver', @DBQueueElements 

 end -- if dbo.QBM_FGIColumnUpdatedThis('WorkDeskHasDriver', 'XOrigin', columns_updated()) = 1


if dbo.QBM_FGIColumnUpdatedThis('WorkDeskHasDriver', 'XIsInEffect', columns_updated()) = 1
 or dbo.QBM_FGIColumnUpdatedThis('WorkDeskHasDriver', 'XOrigin', columns_updated()) = 1
 begin 

		delete  @DBQueueElements 
	
		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
	    from ( 
				select h.uid_Hardware 	as uid
					from deleted  i join WorkDeskHasDriver dd on i.UID_WorkDesk = dd.UID_WorkDesk
															and i.UID_Driver = dd.UID_Driver
															and dbo.QBM_FGIXOriginChanged_Effect(i.XOrigin, dd.XOrigin, i.XIsInEffect, dd.XIsInEffect) = 1
									join Hardware h on i.uid_WorkDesk = h.uid_WorkDesk
													 and (h.ispc = 1 or h.isServer = 1)
			) as x 	
		
		exec QBM_PDBQueueInsert_Bulk 'SDL-K-MACHInEHasDriver', @DBQueueElements
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
	                                	        	
ende:
  return

end
go



------------------------------------------------------------------
-- no Delete Trigger needed (XOrigin-Tabelle mit XisIneffect)
------------------------------------------------------------------
