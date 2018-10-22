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
--  Tabelle BaseTreeHasDriver
--------------------------------------------------------------------------------  



exec QBM_PTriggerDrop 'SDL_TIBaseTreeHasDriver'
go





create trigger SDL_TIBaseTreeHasDriver on BaseTreeHasDriver  
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

declare @AssignCheckValues QBM_YparameterList

insert into @AssignCheckValues(Parameter1, Parameter2)
select i.UID_Org, i.XOrigin
	from inserted i
exec QER_PAssignmentCheckValid 'SDL-AsgnBT-Driver', @AssignCheckValues, @GenProcID

-- Für Trigger SDL_TIBaseTreeHasDriver
-- wegen IsInactive-Filterung auf Driver
-- zu überwachen:  Relationid = R/244
	if exists (select top 1 1 from inserted i join Driver p on i.UID_Driver = p.UID_Driver
										and p.isInactive = 1
									join BaseTree b on i.uid_org = b.uid_org
												and (b.uid_orgroot < N'QER-V-ITShopOrg'
														or b.uid_orgroot > N'QER-V-ITShopOrg'
													)
			)
	 begin
-- 11587 User - Relevanz gesetzt
		      raiserror( '#LDS#Assignment cannot take place, because the object to be assigned is disabled.|', 18, 3) with nowait
	 end



-- \wegen Buglist 7879
--   wenn BaseTree innerhalb eines Warenkorbes liegt, aber Driver IsForITShop = 0 hat , dann abschmettern 
-- 11550
 if exists (select top 1 1 from inserted i join BaseTree dest on i.uid_Org = dest.uid_Org
									-- join auf 'dest' notwendig, da @ObjectKeyDestination auf ITShopOrg, ITShopSrc und Eset geprüft wird
									join Driver elem on i.uid_Driver = elem.uid_Driver
			where dbo.QER_FGIITShopFlagCombineValid(dest.XObjectKey, null, null, elem.XObjectKey, elem.IsForITShop, elem.IsITShopOnly) = 0
			and i.XOrigin & dbo.QBM_FGIBitPatternXOrigin('|Direct|', 0) > 0
			)
	begin
-- 11587 User - Relevanz gesetzt
		raiserror ('#LDS#Assignment is not permitted due to the combination of IT Shop flags.|', 18, 2) with nowait
	end
-- \wegen Buglist 7879



        delete @DBQueueElements 
	  insert into @DBQueueElements (object, subobject, genprocid) 
	  select x.uid, 'SDL-K-OrgHasDriver', @GenProcID
    from (    select distinct d.uid_org as uid
				  from inserted d
				  -- wenn es nur geerbte sind, müssen wir für die Kinder nicht noch einmal rechnen
				  where d.XOrigin & dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 1) > 0
		) as x 
		
	exec QBM_PDBQueueInsert_Bulk 'QER-K-AllChildrenOfOrg', @DBQueueElements



	delete  @DBQueueElements 
	
	insert into @DBQueueElements (object, subobject, genprocid)
	select x.uid, null, @GenProcID
    from (    select distinct b.uid_org as uid
				  from inserted d join BaseTree b on d.uid_org = b.uid_org
				where b.ITShopInfo = 'BO'
				and d.XIsInEffect = 1

	) as x 

	 exec QBM_PDBQueueInsert_Bulk 'QER-K-OrgAutoChild', @DBQueueElements



		delete  @DBQueueElements 
	
		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
	    from ( 
				select distinct i.uid_org as uid
					from inserted  i 
					where i.XIsInEffect = 1

			) as x 	
			
		exec QBM_PDBQueueInsert_Bulk 'SDL-K-BaseTreeHasObject', @DBQueueElements



   -- Einstellen von Jobs fr alle evtl. betroffenen Arbeitspltze 

		delete  @DBQueueElements 
	
		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
	    from ( 
				 select distinct hwo.uid_WorkDesk as uid 
				       from inserted  i  join (select pio.uid_WorkDesk, pio.uid_org
													from WorkDeskinBaseTree pio 
													where pio.XOrigin > 0
												union all
												select uid_WorkDesk, uid_org
													from helperWorkDeskOrg
												)  hwo on hwo.uid_org = i.uid_org 
				where i.XIsInEffect = 1

			) as x 	
		
		exec QBM_PDBQueueInsert_Bulk 'SDL-K-WorkdeskHasDriver', @DBQueueElements

	-- Einstellen von Jobs fr alle evtl. betroffenen HardwareObjekte 

		delete  @DBQueueElements 
	
		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
	    from ( 
				select distinct  hho.uid_Hardware  as uid 
					        from inserted i join (select pio.uid_Hardware, pio.uid_org
														from HardwareinBaseTree pio 
															where pio.XOrigin > 0
															union all
													select uid_Hardware, uid_org
														from helperHardwareOrg
													) hho on hho.uid_org = i.uid_org 
										join Hardware h   on hho.uid_Hardware = h.uid_Hardware
				 where (h.ispc = 1 or h.isServer = 1)
				 and i.XIsInEffect = 1
						  
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


exec QBM_PTriggerDrop 'SDL_TUBaseTreeHasDriver' 
go





create trigger SDL_TUBaseTreeHasDriver on BaseTreeHasDriver
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


if dbo.QBM_FGIColumnUpdatedThis('BaseTreeHasDriver', 'XOrigin', columns_updated()) = 1
	or dbo.QBM_FGIColumnUpdatedThis('BaseTreeHasDriver', 'XIsInEffect', columns_updated()) = 1
 begin 

	delete  @DBQueueElements 
	
	insert into @DBQueueElements (object, subobject, genprocid)
	select x.uid, null, @GenProcID
    from (
			select distinct a.UID_Org as uid
			 from BaseTreeHasDriver a join deleted d on a.UID_Org = d.UID_Org
										and a.UID_Driver = d.UID_Driver
			 	where  ( dbo.QBM_FGIXOriginChanged_Effect(d.XOrigin, a.XOrigin, d.XIsInEffect, a.XIsInEffect) = 1
						or dbo.QER_FCVXOriginToInheritInfo(d.XOrigin) <> dbo.QER_FCVXOriginToInheritInfo(a.XOrigin)
						)


		) as x 	
		
	exec QBM_PDBQueueInsert_Bulk 'SDL-K-BaseTreeHasObject', @DBQueueElements


      delete @DBQueueElements 
	  insert into @DBQueueElements (object, subobject, genprocid) 
	  select x.uid, 'SDL-K-OrgHasDriver', @GenProcID
    from (    select distinct d.uid_org as uid
				  from deleted d join BaseTreeHasDriver a on d.UID_Driver = a.UID_Driver
														and d.UID_Org = a.UID_Org
				where dbo.QBM_FGIXOriginChanged_Effect(d.XOrigin, a.XOrigin, d.XIsInEffect, a.XIsInEffect) = 1
		) as x 
		
	exec QBM_PDBQueueInsert_Bulk 'QER-K-AllChildrenOfOrg', @DBQueueElements



	delete  @DBQueueElements 
	
	insert into @DBQueueElements (object, subobject, genprocid)
	select x.uid, null, @GenProcID
    from (    select distinct b.uid_org as uid
				  from deleted d join BaseTreeHasDriver a on d.UID_Driver = a.UID_Driver
														and d.UID_Org = a.UID_Org
					join BaseTree b on d.uid_org = b.uid_org
				where b.ITShopInfo = 'BO'
				and dbo.QBM_FGIXOriginChanged_Effect(d.XOrigin, a.XOrigin, d.XIsInEffect, a.XIsInEffect) = 1
	) as x 

	 exec QBM_PDBQueueInsert_Bulk 'QER-K-OrgAutoChild', @DBQueueElements




   -- Einstellen von Jobs fr alle evtl. betroffenen Arbeitspltze 

		delete  @DBQueueElements 
	
		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
	    from ( 
				 select distinct hwo.uid_WorkDesk as uid 
				       from deleted  d  join BaseTreeHasDriver a on d.UID_Driver = a.UID_Driver
														and d.UID_Org = a.UID_Org
							join (select pio.uid_WorkDesk, pio.uid_org
													from WorkDeskinBaseTree pio 
													where pio.XOrigin > 0
												union all
												select uid_WorkDesk, uid_org
													from helperWorkDeskOrg
												)  hwo on hwo.uid_org = d.uid_org 
					where dbo.QBM_FGIXOriginChanged_Effect(d.XOrigin, a.XOrigin, d.XIsInEffect, a.XIsInEffect) = 1
			) as x 	
		
		exec QBM_PDBQueueInsert_Bulk 'SDL-K-WorkdeskHasDriver', @DBQueueElements

	-- Einstellen von Jobs fr alle evtl. betroffenen HardwareObjekte 

		delete  @DBQueueElements 
	
		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
	    from ( 
				select distinct  hho.uid_Hardware  as uid 
					        from deleted d join BaseTreeHasDriver a on d.UID_Driver = a.UID_Driver
														and d.UID_Org = a.UID_Org
										join (select pio.uid_Hardware, pio.uid_org
																from HardwareinBaseTree pio 
																	where pio.XOrigin > 0
																	union all
															select uid_Hardware, uid_org
																from helperHardwareOrg
															) hho on hho.uid_org = d.uid_org 
													join Hardware h   on hho.uid_Hardware = h.uid_Hardware
				 where (h.ispc = 1 or h.isServer = 1)
					and  dbo.QBM_FGIXOriginChanged_Effect(d.XOrigin, a.XOrigin, d.XIsInEffect, a.XIsInEffect) = 1
			) as x 	
			
		exec QBM_PDBQueueInsert_Bulk 'SDL-K-MACHInEHasDriver', @DBQueueElements
		
 end  -- if dbo.QBM_FGIColumnUpdatedThis('BaseTreeHasDriver', 'XOrigin', columns_updated()) = 1




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
-- no Delete Trigger needed (XOrigin-Tabelle ohne XisIneffect)
------------------------------------------------------------------
