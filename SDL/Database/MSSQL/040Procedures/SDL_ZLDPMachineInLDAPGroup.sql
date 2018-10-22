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
   --  ZusatzProzedur SDL_ZLDPMachineInLDAPGroup
   --------------------------------------------------------------------------------  

exec QBM_PProcedureDrop 'SDL_ZLDPMachineInLDAPGroup' 
go


---<summary>Fills and corrects the table LDPMachineInLDAPGroup</summary>
---<remarks>LDPMachine UIDs are passed in the auxiliary table QBMDBQueueCurrent</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

---<seealso cref="QBM_PCursorDrop" type="Procedure">Procedure QBM_PCursorDrop</seealso>
---<seealso cref="QBM_FCVElementToObjectKey1" type="Function">Function QBM_FCVElementToObjectKey1</seealso>
---<seealso cref="QBM_FGIIsSimulationMode" type="Function">Function QBM_FGIIsSimulationMode</seealso>
---<seealso cref="QBM_FGIErrorMessage" type="Function">Function QBM_FGIErrorMessage</seealso>
/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-LDPMachineInLDAPGroup'  -- (730764)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-LDPMachineInLDAPGroup'
		, @Operation = 'SDL-KLDPMachineInLDAPGroup'
		, @ProcedureName = 'SDL_ZLDPMachineInLDAPGroup'
		, @IsBulkEnabled = 1
		, @CountParameter = 1
		, @MaxInstance = 1000
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate =  null 
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = 'LDP-K-LDPMachineInLDAPGroup'
		
*/

create procedure SDL_ZLDPMachineInLDAPGroup (@SlotNumber int)
 
-- with encryption 
AS
begin
-- Ergänzung Aufzeichnung
  declare  @IsSimulationMode bit
  select @IsSimulationMode = dbo.QBM_FGIIsSimulationMode() 
-- / Ergänzung Aufzeichnung

declare @nta varchar(38)
declare @gg varchar(38)
        --declare @strS nvarchar(1023)
      

declare @Sourcedata QBM_YDataForDelta
		, @CountDeltaQantity int 
		, @CountDeltaOrigin int 
declare @viii int

declare @GenProcID varchar(38)






-- prüfen, ob das betreffende Objekt noch existiert

declare @ItemObjectKey varchar(138)

declare @RowsToReset int -- CountItems mit -1 zurückzu setzender Jobs




declare @MyName nvarchar(64) = object_name(@@procid)
declare @ObjectKeysToCheck QBM_YParameterList
BEGIN TRY


select @RowsToReset = 0

-- prüfen ob das betroffene Objekt noch existiert, nötigenfalls Operation löschen
	-- Uebergangsloesung, kann man mal umbauen auf QBM_PExecuteSQLWithRetry
	update QBMDBQueueCurrent
			set Slotnumber = 0
			from QBMDBQueueCurrent cu join dbo.QBM_FTDBQueueEntriesForSlot(@SlotNumber) cul on cu.UID_DialogDBQueue = cul.UID_DialogDBQueue	
						left outer join LDPMachine on uid_parameter = uid_LDPMachine  
					where (uid_LDPMachine is null
								or XMarkedForDeletion & dbo.QBM_FGIBitPatternXMarkedForDel('|Delay|', 0) > 0
						)


-------------------------------
-- zurücksetzen,  projection
-------------------------------
if 1 = dbo.DPR_FGIProjectionRootRunning ('LDPDomain')
 begin
	 delete @ObjectKeysToCheck

	 insert into @ObjectKeysToCheck(Parameter1, Parameter2)
	 select  cu.UID_Parameter, ro.ObjectKeyRoot
		from QBMDBQueueCurrent cu join LDPMachine a on a.UID_LDPMachine = cu.UID_Parameter
								join LDP_VElementAndRoot ro on a.XObjectKey = ro.ObjectKeyElement
		-- bei mssql reduziert sich das dadurch auf genau 1 Seek (nur die eine Teilquery aus der View):
		where ro.ElementTable = 'LDPMachine'
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
	from QBMDBQueueCurrent cu join LDPMachine x on cu.UID_Parameter = x.UID_LDPMachine
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


-- alle bisherigen Gruppen des LDPMachines merken 

insert into @SourceData(
						IsUpcommingContent, XOriginAfter
						, Element, AssignedElement, XOriginBefore
						, XIsInEffectBefore, XIsInEffectAfter
						)

	select 0, 0
			, aig.UID_LDPMachine, aig.UID_LDAPGroup, aig.XOrigin 
			, aig.XIsInEffect, 0
	from QBMDBQueueCurrent x join LDPMachineInLDAPGroup aig on aig.UID_LDPMachine = x.uid_parameter
															and x.SlotNumber = @SlotNumber
															and aig.XOrigin > 0 -- ohne XIsInEffect-Test
									join LDAPGroup g on aig.uid_LDAPGroup = g.uid_LDAPgroup
													and g.IsDynamicGroup = 0 
													and g.IsApplicationGroup = 1
    where aig.XMarkedForDeletion & dbo.QBM_FGIBitPatternXMarkedForDel('|Delay|', 0) = 0



-- zusammenstellen aller Globalen Gruppen, die die LDPMachine hat
--     diese knnen kommen 
--        aus  LDPMachineInLDAPGroup
--        über WorkDeskHasApp  (wenn die LDPMachine ein appaccount ist und es die Applikationsgruppe in der gleichen Domäne gibt)
--        über WorkDeskInBaseTree und  BaseTreeHasLDAPGroup (wenn die Hardware ein LDAPaccount ist und die Gruppe in der selben Domäne liegt)
--        über HardwareInBaseTree und  BaseTreeHasLDAPGroup (wenn die Hardware ein LDAPaccount ist und die Gruppe in der selben Domäne liegt)

 -- erst kontrollieren, dann joinen
 if dbo.QBM_FGIConfigparmValue('TargetSystem\LDAP\HardwareInAppGroup') > ' '
   begin
	insert into @SourceData(
						IsUpcommingContent, XOriginBefore
						, Element, AssignedElement, XOriginAfter
						, XIsInEffectBefore, XIsInEffectAfter
						)

	select 1, 0
			, nt.UID_LDPMachine, gg.UID_LDAPGroup
						, dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 0) as XOrigin 
			, 0, 1
	     from LDPMachine nt join QBMDBQueueCurrent x on nt.uid_LDPMachine = x.uid_parameter
												and x.SlotNumber = @SlotNumber
-- wegen Buglist 10002 ausfiltern 
								-- entfällt nicht wegen 25448, da keine TSBAccountDef
								and nt.XMarkedForDeletion & dbo.QBM_FGIBitPatternXMarkedForDel('|Delay|', 0) = 0
							join Hardware h on nt.uid_Hardware = h.uid_Hardware
-- entfällt, da hier nicht von BaseTree geerbt wird
--								and nt.IsNoInherite = 0
			join  WorkDeskHasApp wha on h.UID_WorkDesk = wha.UID_WorkDesk 
									and wha.XOrigin > 0 and wha.XIsInEffect = 1
			join  Application a on wha.UID_Application = a.UID_Application 
			join LDAPGroup gg  on a.Ident_SectionName = gg.cn 
								and gg.IsApplicationGroup = 1 
								and gg.IsDynamicGroup = 0 
			join SDL_VLDPNearestAppContainer co on gg.UID_LDAPContainer = co.UID_Appcontainer and co.UID_AccountContainer = nt.UID_LDAPcontainer
--		group by nt.UID_LDPMachine, gg.UID_LDAPGroup
   end


-- hier: Domäne der Gruppe im Projektor-Lauf

-------------------------------
-- zurücksetzen,  projection
-------------------------------
if 1 = dbo.DPR_FGIProjectionRootRunning ('LDPDomain')
 begin
	 delete @ObjectKeysToCheck

	 insert into @ObjectKeysToCheck(Parameter1, Parameter2)
	 select  cu.UID_Parameter, ro.ObjectKeyRoot
		from QBMDBQueueCurrent cu join @Sourcedata sd on cu.UID_Parameter = sd.Element
								join LDAPGroup g on sd.AssignedElement= g.uid_LDAPGroup
								join LDP_VElementAndRoot ro on g.XObjectKey = ro.ObjectKeyElement
		-- bei mssql reduziert sich das dadurch auf genau 1 Seek (nur die eine Teilquery aus der View):
		where ro.ElementTable = 'LDAPGroup'
		 and cu.SlotNumber = @SlotNumber

	 exec @RowsToReset = DPR_PSlotResetWhileProjection @SlotNumber, 	@ObjectKeysToCheck, @MyName


	 if @RowsToReset > 0
	  begin
		delete @Sourcedata
			from @Sourcedata s join QBMDBQueueCurrent c on s.Element = c.UID_Parameter
			where c.SlotNumber = dbo.QBM_FGIDBQueueSlotResetType('Sync')
				and c.UID_Task = 'LDP-K-LDPMachineInLDAPGroup'
	  end
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
	exec QBM_PMNTableOriginUpdate 'LDPMachineInLDAPGroup', 'uid_LDPMachine', 'uid_LDAPGroup'
 end


if @CountDeltaQantity > 0 
 begin
	exec QBM_PMNTableInsert 'LDPMachineInLDAPGroup', 'uid_LDPMachine', 'uid_LDAPGroup', @TargetIsView = 0
																			, @FKTableNameElement = 'LDPMachine'
																			, @FKColumnNameElement = 'uid_LDPMachine'
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
