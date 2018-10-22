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
   --  ZusatzProzedur SDL_ZMachineHasDriver
   --------------------------------------------------------------------------------  

exec QBM_PProcedureDrop 'SDL_ZMachineHasDriver' 
go


---<summary>Fills and corrects the table MachineHasDriver</summary>
---<remarks>Hardware UIDs are passed in the auxiliary table QBMDBQueueCurrent</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

---<seealso cref="QBM_PCursorDrop" type="Procedure">Procedure QBM_PCursorDrop</seealso>
---<seealso cref="QBM_FCVElementToObjectKey1" type="Function">Function QBM_FCVElementToObjectKey1</seealso>
---<seealso cref="QBM_FGIIsSimulationMode" type="Function">Function QBM_FGIIsSimulationMode</seealso>
---<seealso cref="QBM_FGIErrorMessage" type="Function">Function QBM_FGIErrorMessage</seealso>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-MACHInEHasDriver'  -- (730770)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-MACHInEHasDriver'
		, @Operation = 'MACHINEHASDRIVER'
		, @ProcedureName = 'SDL_ZMachineHasDriver'
		, @IsBulkEnabled = 1
		, @CountParameter = 1
		, @MaxInstance = 1000
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate = 'select	uid_Hardware	from	Hardware	where	(ispc=1	or	isServer	=	1)'
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = QER-K-AllForOneHardware'
		
*/

create procedure SDL_ZMachineHasDriver (@SlotNumber int)
 
-- with encryption 
AS
begin
-- Ergänzung Aufzeichnung
  declare  @IsSimulationMode bit
  select @IsSimulationMode = dbo.QBM_FGIIsSimulationMode() 
-- / Ergänzung Aufzeichnung

--declare @CountItems int
        --declare @tri varchar(38)
        --declare @whereklausel nvarchar(255)


----declare @os nvarchar(32)

declare @Sourcedata QBM_YDataForDelta
		, @CountDeltaQantity int 
		, @CountDeltaOrigin int 

declare @uid_driver varchar(38)
declare @GenProcID varchar(38)

declare @uid_HardwareErsatz varchar(38)
declare @vii int

declare @ItemObjectKey varchar(138)
declare @RowsToReset int -- CountItems mit -1 zurückzu setzender Jobs




declare @MyName nvarchar(64) = object_name(@@procid)

BEGIN TRY



select @RowsToReset = 0

declare @InheritePhysicalDependencies bit
select @InheritePhysicalDependencies = 0
if dbo.QBM_FGIConfigparmValue('Software\InheritePhysicalDependencies')  > ' '
 begin
	select @InheritePhysicalDependencies = 1
 end


	exec QBM_PSlotResetOnMissingItem  @SlotNumber, 'Hardware', 'uid_Hardware'

-------------------------------------------------------------------------
-- zurücksetzen, falls noch job unterwegs ist
-------------------------------------------------------------------------

--20039
declare @ObjectKeysToCheck QBM_YParameterList
delete @ObjectKeysToCheck

insert into @ObjectKeysToCheck(Parameter1, Parameter2)
select  cu.UID_Parameter, x.XObjectKey
	from QBMDBQueueCurrent cu join Hardware x on cu.UID_Parameter = x.UID_Hardware
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


-- Schappschuss vorher anfertigen und merken 

insert into @SourceData(
						IsUpcommingContent, XOriginAfter
						, Element, AssignedElement, XOriginBefore
						, XIsInEffectBefore, XIsInEffectAfter
						)

	select 0, 0
			, uid_Hardware, uid_Driver, mhd.XOrigin 
			, mhd.XIsInEffect, 0
	from MachineHasDriver mhd join QBMDBQueueCurrent x on uid_Hardware =x.uid_parameter
														and x.SlotNumber = @SlotNumber


-- zusammenstellen aller Drivers die ein Machineobjekt hat 
	-- das, was der Machine direkt zugewiesen ist
insert into @SourceData(
						IsUpcommingContent, XOriginBefore, XOriginAfter
						, Element, AssignedElement
						, XIsInEffectBefore, XIsInEffectAfter
						)
	select 1, 0,  mhd.XOrigin & dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 1)
			, x.uid_parameter, mhd.uid_Driver 
			, 0, 1
	from  Hardware h, MachineHasDriver mhd, driver d, QBMDBQueueCurrent x
	    where mhd.uid_Hardware = x.uid_parameter 
		and x.SlotNumber = @SlotNumber
		and h.uid_Hardware = x.uid_parameter
		  and mhd.uid_driver = d.uid_driver 
		  and rtrim(isnull(d.UID_OS,'')) = rtrim(isnull(h.UID_OS,''))     
		  and (h.ispc = 1 or h.isServer = 1)

insert into @SourceData(
						IsUpcommingContent, XOriginBefore
						, Element, AssignedElement, XOriginAfter
						, XIsInEffectBefore, XIsInEffectAfter
						)

	select 1, 0
			, x.uid_Hardware, x.uid_driver, dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 0)
			, 0, 1
   from (
	select h.uid_Hardware , wdw.uid_Driver
-- wegen Buglist 10002 ausfiltern 
	   from QBMDBQueueCurrent x join Hardware h on h.uid_Hardware = x.uid_parameter 
												and x.SlotNumber = @SlotNumber
-- hier nicht filtern, da das nicht von BaseTree kommt
--													and h.IsNoInherite = 0
									join WorkDeskhasDriver wdw on h.uid_WorkDesk = wdw.uid_WorkDesk 
															and wdw.XOrigin > 0 and wdw.XIsInEffect = 1
									join driver d on wdw.uid_driver = d.uid_driver 
-- entfällt nicht wegen wegen 25448, da keine TSBAccountDef
	    where h.XMarkedForDeletion & dbo.QBM_FGIBitPatternXMarkedForDel('|Delay|', 0) = 0
		  and rtrim(isnull(d.UID_OS,'')) = rtrim(isnull(h.UID_OS,''))     
		  and (h.ispc = 1 or h.isServer = 1)
	 union all
-- Mangelrüge CK 2005-09-27
	-- das, was die Machine über ESet zu ihrem Arbeitsplatz bekommt
	select h.uid_Hardware , d.uid_Driver
	   from Hardware h join QBMDBQueueCurrent x on h.uid_Hardware = x.uid_parameter 
													and x.SlotNumber = @SlotNumber
													-- entfällt nicht wegen 25448, da keine TSBAccountDef
													and h.XMarkedForDeletion & dbo.QBM_FGIBitPatternXMarkedForDel('|Delay|', 0) = 0
													and (h.ispc = 1 or h.isServer = 1)
			join WorkDeskHasEset  wha on h.uid_WorkDesk = wha.uid_WorkDesk
									and wha.XOrigin > 0 and wha.XIsInEffect = 1
			join ESetHasEntitlement ehe on wha.uid_Eset = ehe.uid_Eset
										and ehe.XOrigin > 0 and ehe.XIsInEffect = 1
										and  exists(
														select top 1 1
															from QBMModuleDef md
															where md.UID_ModuleDef = 'RMS-Moduledefinition'
													)
			join driver d on ehe.Entitlement = d.XObjectKey 
						and rtrim(isnull(d.UID_OS,'')) = rtrim(isnull(h.UID_OS,''))     
-- \Mangelrüge CK 2005-09-27
	 union all
	-- das , was die Machine ber die Orgs ihres Arbeitsplatzes erbt
	select h.uid_Hardware , ohw.uid_Driver 
	    from Hardware h join QBMDBQueueCurrent x on h.uid_Hardware = x.uid_parameter 
							and x.SlotNumber = @SlotNumber
							and (h.ispc = 1 or h.isServer = 1)
							-- entfällt wegen nicht wegen 25448, da keine TSBAccountDef
							and h.XMarkedForDeletion & dbo.QBM_FGIBitPatternXMarkedForDel('|Delay|', 0) = 0
							and h.IsNoInherite = 0
			join WorkDesk w on h.uid_WorkDesk = w.uid_WorkDesk
							and w.IsNoInherite = 0
			join 
-- Ersatzblock für v i _ v_ WorkDeskInheriteFromOrg
				(
					select  hpo.uid_WorkDesk , hpo.uid_org 
							from helperWorkDeskorg hpo 
					union 
					select  pio.uid_WorkDesk , pio.uid_org 
							from WorkDeskinBaseTree pio 
							where pio.XOrigin > 0
														--join BaseTree ba on pio.UID_Org = ba.UID_Org
														--left outer join DynamicGroup dg on dg.ObjectKeyBaseTree = ba.XObjectKey 
					) as hwo   
-- / Ersatzblock für v i _ v_ WorkDeskInheriteFromOrg
						 on h.uid_WorkDesk = hwo.uid_WorkDesk
-- wegen Buglist 10002 ausfiltern 
			join BaseTreeHasDriver ohw on ohw.uid_org = hwo.uid_org
										and ohw.XOrigin > 0
			join BaseTree b on b.uid_org = hwo.uid_org 
							and b.IsNoInheriteToWorkDesk = 0
			join driver d on ohw.uid_driver = d.uid_driver 
					and rtrim(isnull(d.UID_OS,'')) = rtrim(isnull(h.UID_OS,''))

	 union all
	-- das , was die Machine ber die BaseTree  erbt
	select h.uid_Hardware , ohd.uid_Driver 
	    from 
-- Ersatzblock für v i _ v_ HardwareInheriteFromOrg
				(
					select  hpo.uid_Hardware , hpo.uid_org 
							from QBMDBQueueCurrent p join helperHardwareorg hpo on p.uid_parameter = hpo.uid_Hardware 
																				and p.SlotNumber = @SlotNumber
					union 
					select  pio.uid_Hardware , pio.uid_org 
							from QBMDBQueueCurrent p join HardwareinBaseTree pio on p.uid_parameter = pio.uid_Hardware 
																				and pio.XOrigin > 0
																				and p.SlotNumber = @SlotNumber
														--join BaseTree ba on pio.UID_Org = ba.UID_Org
														--left outer join DynamicGroup dg on dg.ObjectKeyBaseTree = ba.XObjectKey 
					) as hho  
-- / Ersatzblock für v i _ v_ HardwareInheriteFromOrg
				join Hardware h on h.uid_Hardware = hho.uid_Hardware
							and (h.ispc = 1 or h.isServer = 1)
							-- entfällt nicht wegen 25448, da keine TSBAccountDef
							and h.XMarkedForDeletion & dbo.QBM_FGIBitPatternXMarkedForDel('|Delay|', 0) = 0
							and h.IsNoInherite = 0
-- wegen Buglist 10002 ausfiltern 
			join BaseTreeHasDriver ohd on ohd.uid_org = hho.uid_org
									and ohd.XOrigin > 0
			join BaseTree b on b.uid_org = hho.uid_org
							and b.IsNoInheriteToHardware = 0
			join driver d on ohd.uid_driver = d.uid_driver 
					and rtrim(isnull(d.UID_OS,'')) = rtrim(isnull(h.UID_OS,''))     


	 union all
	-- das , was die Machine ber den Maschinentyp erbt
	
	select h.uid_Hardware , mthd.uid_Driver
	    from Hardware h,  MachineTypeHasDriver mthd , driver d, QBMDBQueueCurrent x
	      where h.uid_Hardware = x.uid_parameter 
		  and x.SlotNumber = @SlotNumber
		-- entfällt nicht wegen 25448, da keine TSBAccountDef
		and h.XMarkedForDeletion & dbo.QBM_FGIBitPatternXMarkedForDel('|Delay|', 0) = 0
		and h.UID_MachineType = mthd.UID_MachineType 
		and mthd.uid_driver = d.uid_driver 
		and rtrim(isnull(d.UID_OS,'')) = rtrim(isnull(h.UID_OS,''))     
		and (h.ispc = 1 or h.isServer = 1)
	 union all
-- das , was die Maschine ber den Hardwaretype erbt
-- Buglist	10084
	select h.uid_Hardware , htd.uid_Driver 
	    from QBMDBQueueCurrent x join  Hardware h on h.uid_Hardware = x.uid_parameter 
												and x.SlotNumber = @SlotNumber
								join HardwareTypeHasDriver htd on h.UID_HardwareType = htd.UID_HardwareType 
								join Driver d on htd.uid_driver = d.uid_driver 
		-- entfällt nicht wegen 25448, da keine TSBAccountDef
	     where h.XMarkedForDeletion & dbo.QBM_FGIBitPatternXMarkedForDel('|Delay|', 0) = 0
			and rtrim(isnull(d.UID_OS,'')) = rtrim(isnull(h.UID_OS,''))     
			and (h.ispc = 1 or h.isServer = 1)
	) as x
-- group by x.uid_Hardware, x.uid_driver


-- IR 2005-07-19
-- Erweitern um die Einträge aus SoftwareDependsOnSoftware
if @InheritePhysicalDependencies = 1
 begin
 insert into @SourceData(
						IsUpcommingContent, XOriginBefore
						, Element, AssignedElement, XOriginAfter
						, XIsInEffectBefore, XIsInEffectAfter
						)

	select 1, 0
			, x.uid_org, x.uid_parentorg , dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 0) 
			, 0, 1
	from 
	 (	select c.Element as uid_org , p.uid_parent as uid_parentorg
-- anzupassen für 13021
			from @SourceData c join SoftwareDependsOnSoftware p on c.AssignedElement = p.uid_child
							join driver a on a.uid_driver = p.uid_parent
			where c.IsUpcommingContent = 1

-- Erweitern um die Treiber, die über die Applikationen kommen
		union
		select x.uid_parameter as uid_org , p.uid_parent as uid_parentorg
			from QBMDBQueueCurrent x join Hardware h on x.uid_parameter = h.uid_Hardware
										and x.SlotNumber = @SlotNumber
									  and (h.ispc = 1 or h.isServer = 1)
									-- entfällt nicht wegen 25448, da keine TSBAccountDef
									and h.XMarkedForDeletion & dbo.QBM_FGIBitPatternXMarkedForDel('|Delay|', 0) = 0
							join WorkDeskHasApp wha on wha.uid_WorkDesk = h.uid_WorkDesk
													and wha.XOrigin > 0 and wha.XIsInEffect = 1
							join SoftwareDependsOnSoftware p on wha.uid_application = p.uid_child
							-- eigentlich noch join über Application, erledigt sich aber mit bha
							join driver a on a.uid_driver = p.uid_parent
	 ) as x
/*
	where Not exists (select top 1 1 from Dialog H l p C ollAfterInd z
				where z.uid_org = x.uid_org
				  and z.uid_parentorg = x.uid_parentorg
			)
*/

 end -- if @InheritePhysicalDependencies = 1
-- \ Erweitern um die Einträge aus SoftwareDependsOnSoftware

----------------------------------------------------------------------------------------
--  Feststellen, ob die Mengen der Drivers  jetzt anders sind
--   (durch Vergleich der  Mengen vorher und nachher )  

exec QBM_PDBQueueCalculateDelta @SourceData,
								 @DeltaQuantity = 0,
							@DeltaDelete = 0,
							@DeltaInsert = 1,
							@DeltaOrigin = 1, 
							@CountDeltaQantity = @CountDeltaQantity output , @CountDeltaOrigin = @CountDeltaOrigin output
							, @UseIsInEffect = 1
							, @SlotNumber = @SlotNumber 


-- nderung des Verhaltens: wenn wir in einer Raptor-Umgebung arbeiten, werden MachineHasDriver Insert und delete
-- nicht mehr direkt sondern über job ausgefhrt. Das Einstellen der Weiterberechnung wird dann 
-- auch über job eingestellt (prio kleiner als MachineHasDriver-Jobs) da die Weiterberechnung erst erfolgen kann, wenn die 
-- Zuordnungen MachineHasDriver in der Datenbank richtig gestellt worden sind.

if @CountDeltaOrigin > 0 
 begin
	exec QBM_PMNTableOriginUpdate 'MachineHasDriver', 'uid_Hardware', 'uid_driver'
 end


if @CountDeltaQantity > 0 
 begin
	exec QBM_PMNTableInsert 'MachineHasDriver', 'uid_Hardware', 'uid_driver', @TargetIsView = 0
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
