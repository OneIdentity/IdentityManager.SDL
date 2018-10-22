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
   --  Tabelle Driver
   --------------------------------------------------------------------------------  

-- IR 2005-03-15 Trigger umgestellt, ruft nicht mehr Prozedur auf sondern stellt dbscheduler-Job ein

exec QBM_PTriggerDrop 'SDL_TUDriver' 
go





create trigger SDL_TUDriver on Driver  
-- with encryption 
	for Update  
	not for Replication    
as
begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID
declare @AdditionalObjectKeysAffected_CSU QBM_YParameterList -- compiler shut up

	declare @ObjectkeyOrdered varchar(138)
	declare @uid_accproduct varchar(38)

	declare @whereclauseOrg nvarchar(max)
declare @whereclauseMuster nvarchar(max) = 
' UID_ITShopOrg in ( select UID_OrgPR 
							from QER_VPWOProductNodesSlim
							where ObjectkeyOrdered = ''@ObjectkeyOrdered'' 
								and isnull(UID_AccProduct, '''') <> ''@UID_AccProduct''
					)
' 

declare @CursorBuffer QBM_YParameterList

BEGIN TRY

      if exists (select top 1 1 from inserted) goto start
      if exists (select top 1 1 from deleted) goto start
            return
start:
 
 declare @GenProcID varchar(38)
 declare @OperationLevel int 
 declare @XUser nvarchar(64)
	exec @OperationLevel = QBM_PGenprocidGetFromContext @GenProcID output, @XUser output , @CodeID = @@ProcID

   -- spezielle Variablen 

  declare @uid_Driver varchar(38)

  declare @alt_Ident_Sectionname nvarchar(64)
  declare @neu_Ident_Sectionname nvarchar(64)

  declare @alt_Ident_OS nvarchar(64)
  declare @neu_Ident_OS nvarchar(64)




---------------------------------------------------------------------------
-- Tests bei Veränderung der ITShopFlags (IsForITShop, IsITShopOnly)
---------------------------------------------------------------------------
if dbo.QBM_FGIColumnUpdatedThis('Driver', 'isForITShop', columns_updated()) = 1
 or dbo.QBM_FGIColumnUpdatedThis('Driver', 'isITShopOnly', columns_updated()) = 1
 begin 
-- Test 0/1
	if exists (select top 1 1 from inserted i
				where i.IsForITShop = 0 
					and i.IsITShopOnly = 1
				)
	 begin
-- 11587 User - Relevanz gesetzt
		raiserror( '#LDS#Invalid flag combination for IsForITShop and IsITShopOnly.|', 18, 2) with nowait
	 end

-- Test 0/0
-- unzulässig, wenn es Zuweisungen des Elementes zu BaseTree ITShopOrg gibt
	if exists (select top 1 1 
				from inserted i join BaseTreeHasDriver bha on i.uid_Driver = bha.uid_Driver
															and bha.XOrigin > 0
								join BaseTree b on bha.uid_org = b.uid_Org
				 where i.IsForITShop = 0 
					and i.IsITShopOnly = 0
					and b.XObjectKey like '<Key><T>ITShop___</T>%'
				)
					
	 begin
-- 11587 User - Relevanz gesetzt
		 raiserror( '#LDS#Changes cannot take place, because assignments still exist within IT Shop structures.|', 18, 2) with nowait
	 end

-- test 1/1
	if exists (select top 1 1 from inserted i
				where i.IsForITShop = 1 and i.IsITShopOnly = 1
			)
	begin
-- nur dann machen wir uns die Mühe, weiter zu suchen
-- unzulässig, wenn es Zuweisungen zu BaseTree <> ITShop gibt
		if exists (select top 1 1 
					from inserted i join BaseTreeHasDriver bha on i.uid_Driver = bha.uid_Driver
																and bha.XOrigin > 0
									join BaseTree b on bha.uid_Org = b.UId_Org
					where i.IsForITShop = 1
					and i.IsITShopOnly = 1
					and b.XObjectKey not like '<Key><T>ITShop___</T>%'
				)
			begin
-- 11587 User - Relevanz gesetzt
				raiserror( '#LDS#Changes cannot take place, because assignments still exist outside IT Shop structures.|', 18, 2) with nowait
			end
-- unzulässig, wenn es Zuweisungen zu Person, WorkDesk, ... gibt		
		if exists (select top 1 1 
					from inserted i join MachineHasDriver zuw on i.uid_Driver = zuw.uid_Driver
															and zuw.XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
					 where i.IsForITShop = 1
					  and i.IsITShopOnly = 1
					)
		 or exists (select top 1 1 
					from inserted i join WorkDeskHasDriver zuw on i.uid_Driver = zuw.uid_Driver
																and zuw.XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
					 where i.IsForITShop = 1 
					  and i.IsITShopOnly = 1
					)
			begin
-- 11587 User - Relevanz gesetzt
				raiserror( '#LDS#Changes cannot take place because direct assignments still exist.|', 18, 2) with nowait
			end



	end -- if exists (select top 1 1 from inserted  where i.IsForITShop = 1 and i.IsITShopOnly = 1

 end -- if dbo.QBM_FGIColumnUpdatedThis('Driver', 'isForITShop', columns_updated()) = 1
---------------------------------------------------------------------------
-- / Tests bei Veränderung der ITShopFlags (IsForITShop, IsITShopOnly)
---------------------------------------------------------------------------

 
   -- Schrittbetrieb aufmachen  

if dbo.QBM_FGIColumnUpdatedThis('Driver', 'Ident_SectionName', columns_updated()) = 1
	or dbo.QBM_FGIColumnUpdatedThis('Driver', 'UID_OS', columns_updated()) = 1
 begin
  DECLARE SDL_TUDriverSchritt CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 

    -- interessierende Werte selektieren 
  select rtrim(isnull(Driver.uid_Driver, '')), rtrim(isnull(deleted.Ident_SectionName,N'')), rtrim(isnull(Driver.Ident_SectionName,N'')),
		rtrim(isnull(deleted.UID_OS,'')), rtrim(isnull(Driver.UID_OS,''))
     from Driver, deleted
     where Driver.UID_Driver = deleted.UID_Driver 

  
  OPEN SDL_TUDriverSchritt
  FETCH NEXT FROM SDL_TUDriverSchritt into @uid_Driver, @alt_ident_sectionname, @neu_ident_sectionname, @alt_Ident_OS, @neu_Ident_OS

  WHILE (@@fetch_status <> -1)
  BEGIN

-- Buglist 7645
	if @alt_Ident_OS <> @neu_Ident_OS
	 begin
		if exists (select top 1 1 from machinehasdriver 
					where uid_driver = @uid_driver
					and XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
					)
		  begin
-- 11587 User - Relevanz gesetzt
		               raiserror( '#LDS#Cannot change operating system because the driver is still assigned to machines.|', 18, 2) with nowait
		  end
	 end
-- \Buglist 7645

       if @alt_ident_sectionname <> @neu_ident_sectionname
         begin
		exec QBM_PDBQueueInsert_Single 'SDL-K-AllMachinesForDriver',  @uid_Driver, '' , @GenProcID
         end 



       FETCH NEXT FROM SDL_TUDriverSchritt into @uid_Driver, @alt_ident_sectionname, @neu_ident_sectionname, @alt_Ident_OS, @neu_Ident_OS
  END
  close SDL_TUDriverSchritt
  deallocate SDL_TUDriverSchritt
 end -- if dbo.QBM_FGIColumnUpdatedThis('Driver', 'Ident_SectionName', columns_updated()) = 1 
  -- Standard-Abschlussbehandlung 

-----------

-- Wegen Buglist 8005

if dbo.QBM_FGIColumnUpdatedThis('Driver', 'uid_accproduct', columns_updated()) = 1
 begin 
	insert into @CursorBuffer(Parameter1, Parameter2)
	 select x.XObjectKey, isnull(x.uid_accproduct,'')
		from Driver x join deleted d on x.uid_Driver = d.uid_Driver
										and isnull(x.uid_accproduct,'') <> isnull(d.uid_accproduct,'')
-- Buglist 11341 nur wenn vorher schon ein Wert drin war, nur dann kann es schon im ITShop gewesen sein
										and d.uid_accproduct > ' '
--16592
						join dialogColumn c on c.UID_DialogTable = 'QER-T-ITShopOrg'
											and c.columnname = 'uid_ACCProduct'
											and c.IsDeactivatedByPreProcessor = 0
--/ 16592
	select @ObjectkeyOrdered = '#'
	while @ObjectkeyOrdered > ' '
	 begin

		select @ObjectkeyOrdered = null
		
		select top 1 @ObjectkeyOrdered = bu.Parameter1
				, @UID_AccProduct = bu.Parameter2
			from @CursorBuffer bu

		if @ObjectkeyOrdered is null
		 begin
			continue
		 end

			select @whereclauseOrg = @whereclauseMuster
			select @whereclauseOrg = replace(@whereclauseOrg, N'@ObjectkeyOrdered' , @ObjectkeyOrdered)
			select @whereclauseOrg = replace(@whereclauseOrg, N'@uid_accproduct' , rtrim(@uid_accproduct))
			
--			print @whereclauseOrg
			
-- keine Behandlung dieses Updates in der Simulation	
			exec QBM_PJobCreate_HOUpdate_B  N'ITShopOrg', @whereclauseOrg, @GenProcID
									, @p1 = 'uid_ACCProduct', @v1 = @uid_accproduct
									, @AdditionalObjectKeysAffected = @AdditionalObjectKeysAffected_CSU
			
		delete @CursorBuffer
			where Parameter1 = @ObjectkeyOrdered
	end  --while @ObjectkeyOrdered > ' '

 end
-- \ Wegen Buglist 8005



END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'SDL_TUDriverSchritt'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	
ende:
  return

end
go


exec QBM_PTriggerDrop 'SDL_TDDriver' 
go





create trigger SDL_TDDriver on Driver  
-- with encryption 
	for DELETE 
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
  declare  @errno   int
  declare  @errmsg  nvarchar(255)


  exec     QBM_PDBQueueInsert_Single 'SDL-K-SoftwareDependsPhysical', '', '', @GenProcID



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

-- wegen 13437 gleich beim Insert Wert berechnen, so daß keine 0 ensteht

exec QBM_PTriggerDrop 'SDL_TIDriver' 
go





create trigger SDL_TIDriver on Driver  
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


    exec     QBM_PDBQueueInsert_Single 'SDL-K-DriverMakeSortOrder', '', '', @GenProcID


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
