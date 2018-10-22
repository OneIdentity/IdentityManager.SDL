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
   --  ZusatzProzedur SDL_ZADSMachineInADSGroup
   --------------------------------------------------------------------------------  

exec QBM_PProcedureDrop 'SDL_ZADSMachineInADSGroup' 
go


---<summary>Fills and corrects the table ADSMachineInADSGroup</summary>
---<remarks>ADSMachine UIDs are passed in the auxiliary table QBMDBQueueCurrent</remarks>
---<example>Function exclusively for use in the DBScheduler</example>
---<seealso cref="ADS_FGIUserInGroupValid" type="Function">Function ADS_FGIUserInGroupValid</seealso>
---<seealso cref="QBM_PCursorDrop" type="Procedure">Procedure QBM_PCursorDrop</seealso>
---<seealso cref="QBM_FCVElementToObjectKey1" type="Function">Function QBM_FCVElementToObjectKey1</seealso>
---<seealso cref="QBM_FGIConfigparmValue" type="Function">Function QBM_FGIConfigparmValue</seealso>
---<seealso cref="QBM_FGIIsSimulationMode" type="Function">Function QBM_FGIIsSimulationMode</seealso>
---<seealso cref="QBM_FGIErrorMessage" type="Function">Function QBM_FGIErrorMessage</seealso>
---<seealso cref="QBM_PRollbackIfAllowed" type="Procedure">Procedure QBM_PRollbackIfAllowed</seealso>
---<seealso cref="QBM_FGITableCountAll" type="Function">Function QBM_FGITableCountAll</seealso>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-ADSMachineInADSGroup'  -- (730728)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-ADSMachineInADSGroup'
		, @Operation = 'SDL-KADSMachineInADSGroup'
		, @ProcedureName = 'SDL_ZADSMachineInADSGroup'
		, @IsBulkEnabled = 1
		, @CountParameter = 1
		, @MaxInstance = 1000
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate =  null 
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = 'ADS-K-ADSMachineInADSGroup'
		
*/


create procedure SDL_ZADSMachineInADSGroup (@SlotNumber int)
 
-- with encryption 
AS
begin
-- Ergänzung Aufzeichnung
  declare  @IsSimulationMode bit
  select @IsSimulationMode = dbo.QBM_FGIIsSimulationMode() 
-- / Ergänzung Aufzeichnung

declare @nta varchar(38)
declare @gg varchar(38)

declare @Sourcedata QBM_YDataForDelta
		, @CountDeltaQantity int 
		, @CountDeltaOrigin int 
declare @GenProcID varchar(38)






declare @ItemObjectKey varchar(138)
declare @RowsToReset int -- CountItems mit -1 zurückzu setzender Jobs

declare @MyName nvarchar(64) = object_name(@@procid)
declare @ObjectKeysToCheck QBM_YParameterList

BEGIN TRY



select @RowsToReset = 0

	exec QBM_PSlotResetOnMissingItem  @SlotNumber, 'ADSMachine', 'uid_ADSMachine'

-------------------------------
-- zurücksetzen,  projection
-------------------------------
if 1 = dbo.DPR_FGIProjectionRootRunning ('ADSDomain')
 begin
	 delete @ObjectKeysToCheck

	 insert into @ObjectKeysToCheck(Parameter1, Parameter2)
	 select  cu.UID_Parameter, ro.ObjectKeyRoot
		from QBMDBQueueCurrent cu join ADSMachine a on a.UID_ADSMachine = cu.UID_Parameter
								join ADS_VElementAndRoot ro on a.XObjectKey = ro.ObjectKeyElement
		-- bei mssql reduziert sich das dadurch auf genau 1 Seek (nur die eine Teilquery aus der View):
		where ro.ElementTable = 'ADSMachine'
		 and cu.SlotNumber = @SlotNumber

	 exec @RowsToReset = DPR_PSlotResetWhileProjection @SlotNumber, 	@ObjectKeysToCheck, @MyName
 end
-------------------------------------------------------------------------
-- zurücksetzen, falls noch job unterwegs ist
-------------------------------------------------------------------------

--20039

delete @ObjectKeysToCheck

insert into @ObjectKeysToCheck(Parameter1, Parameter2)
select  cu.UID_Parameter, x.XObjectKey
	from QBMDBQueueCurrent cu join ADSMachine x on cu.UID_Parameter = x.UID_ADSMachine
	where cu.SlotNumber = @SlotNumber

exec QBM_PSlotResetWhileJobRunning @SlotNumber, @@PROCID, 	@ObjectKeysToCheck

if 0 = (select COUNT(*) 
			from QBMDBQueueCurrent p
			where p.SlotNumber = @SlotNumber
		)
 begin
	goto ende
 end

-------------------------------------------------------------------------
-- / zurücksetzen, falls noch job unterwegs ist
-------------------------------------------------------------------------

-- alle bisherigen Gruppen des ADSMachines merken 

insert into @SourceData(
						IsUpcommingContent, XOriginAfter
						, Element, AssignedElement, XOriginBefore
						, XIsInEffectBefore, XIsInEffectAfter
						)

	select 0, 0
			, hia.UID_ADSMachine, hia.UID_ADSGroup, hia.XOrigin 
			, hia.XIsInEffect, 0
	from QBMDBQueueCurrent x join ADSMachineInADSGroup hia on hia.UID_ADSMachine = x.uid_parameter
															and x.SlotNumber = @SlotNumber
								join ADSGroup g on hia.uid_adsGroup = g.uid_adsgroup
-- 20588
--												and g.I s D y n a m i c G r o u p = 0 
												and g.IsApplicationGroup = 1

    where hia.XMarkedForDeletion & dbo.QBM_FGIBitPatternXMarkedForDel('|Delay|', 0) = 0


-- zusammenstellen aller Globalen Gruppen, die die ADSMachine hat
--     diese knnen kommen 
--        aus  ADSMachineInADSGroup

-- @@bauer noch Diskussionsbedarf
--        ber WorkDeskHasApp  (wenn die Hardware ein appaccount ist und es die Applikationsgruppe in der gleichen Domne gibt)
--        ber WorkDeskInBaseTree und  B a s e T r e e H a s A D S Gr  o u p (wenn die Hardware ein ADSaccount istund die Gruppe in der selben Domne liegt)
--        ber HardwareInBaseTree und  B a s e T r e e H a s A D S G r o u p  (wenn die Hardware ein ADSaccount istund die Gruppe in der selben Domne liegt)



 -- erst kontrollieren, dann joinen
 -- @@bauer Diskussionsbedarf
 if dbo.QBM_FGIConfigparmValue('TargetSystem\ADS\HardwareInAppGroup') > ' '
   begin
	insert into @SourceData(
						IsUpcommingContent, XOriginBefore
						, Element, AssignedElement, XOriginAfter
						, XIsInEffectBefore, XIsInEffectAfter
						)

	select 1, 0
			, nt.UID_ADSMachine, gg.UID_ADSGroup 
						, dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 0) as XOrigin 
			, 0 ,1 
-- wegenBuglist 10002 ausfiltern 
	     from ADSMachine nt join QBMDBQueueCurrent x on nt.uid_ADSMachine = x.uid_parameter
													and x.SlotNumber = @SlotNumber
								-- entfällt nicht wegen 25448, da keine TSBAccountDef
								and nt.XMarkedForDeletion & dbo.QBM_FGIBitPatternXMarkedForDel('|Delay|', 0) = 0
			join Hardware h on nt.uid_Hardware = h.uid_Hardware
-- hier nicht, da nicht von BaseTree geerbt
			join  WorkDeskHasApp wha on h.UID_WorkDesk = wha.UID_WorkDesk 
								and wha.XOrigin > 0 and wha.XIsInEffect = 1
			join  Application a on wha.UID_Application = a.UID_Application 
			join ADSGroup gg  on a.Ident_SectionName = gg.cn 
							and gg.IsApplicationGroup = 1 
-- 20588
--							and gg.I s D y n a m i c G r o u p = 0
			join SDL_VADSNearestAppContainer co on gg.UID_ADSContainer = co.UID_Appcontainer and co.UID_AccountContainer = nt.UID_adscontainer
--		group by nt.UID_ADSMachine, gg.UID_ADSGroup 
   end


-----------------------------------------------------------------------------------------------
--  Feststellen, ob sich die Menge an GlobalenGruppen gendert hat
--   (durch Vergleich der  Mengen vorher und nachher )  
exec QBM_PDBQueueCalculateDelta @SourceData,
								 @DeltaQuantity = 0,
							@DeltaDelete = 0,
							@DeltaInsert = 1,
							@DeltaOrigin = 1, 
							@CountDeltaQantity = @CountDeltaQantity output , @CountDeltaOrigin = @CountDeltaOrigin output
							, @UseIsInEffect = 1
							, @SlotNumber = @SlotNumber 


if @CountDeltaOrigin > 0 
 begin
	exec QBM_PMNTableOriginUpdate 'ADSMachineInADSGroup', 'uid_ADSMachine', 'uid_ADSgroup'
 end


if @CountDeltaQantity > 0 
 begin
	exec QBM_PMNTableInsert 'ADSMachineInADSGroup', 'uid_ADSMachine', 'uid_ADSgroup', @TargetIsView = 0
																			, @FKTableNameElement = 'ADSMachine'
																			, @FKColumnNameElement = 'uid_ADSMachine'
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

end
go
