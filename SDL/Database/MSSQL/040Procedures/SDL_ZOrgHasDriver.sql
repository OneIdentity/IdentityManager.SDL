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
   --  ZusatzProzedur SDL_ZOrgHasDriver
   --------------------------------------------------------------------------------  

exec QBM_PProcedureDrop 'SDL_ZOrgHasDriver' 
go


---<summary>Fills and corrects the table BaseTreeHasDriver</summary>
---<remarks>Org UIDs are passed in the auxiliary table QBMDBQueueCurrentr</remarks>
---<example>Function exclusively for use in the DBScheduler</example>
---<seealso cref="QER_FGIOrgRootName" type="Function">Function QER_FGIOrgRootName</seealso>

---<seealso cref="QBM_PCursorDrop" type="Procedure">Procedure QBM_PCursorDrop</seealso>
---<seealso cref="QBM_FCVElementToObjectKey1" type="Function">Function QBM_FCVElementToObjectKey1</seealso>
---<seealso cref="QBM_FGIIsSimulationMode" type="Function">Function QBM_FGIIsSimulationMode</seealso>
---<seealso cref="QBM_FGIErrorMessage" type="Function">Function QBM_FGIErrorMessage</seealso>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-OrgHasDriver'  -- (790690)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-OrgHasDriver'
		, @Operation = 'ORGHASDRIVER'
		, @ProcedureName = 'SDL_ZOrgHasDriver'
		, @IsBulkEnabled = 1
		, @CountParameter = 1
		, @MaxInstance = 1000
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate = 'select	uid_org	from	basetree	where	''1''	=	dbo.QBM_FGIConfigparmValue(N''Software\Driver'')	and	uid_orgroot	not	in	(N''VITShopOrg'',	N''VITShopSrc'')'
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = 'QER-K-AllForOneOrg'
		
exec MDK_PDBQueueTaskDependDefine 
		@UID_TaskPredecessor = 'RMS-K-OrgHasESet' -- (700458)
		, @UID_TaskFollower = 'SDL-K-OrgHasDriver' -- (790690)
		, @IsPhysicalDependency = 0
	-- delete QBMDBQueueTaskDepend where UID_TaskPredecessor = 'RMS-K-OrgHasESet' and UID_TaskFollower = 'SDL-K-OrgHasDriver'
	
exec MDK_PDBQueueTaskDependDefine 
		@UID_TaskPredecessor = 'SDL-K-AllForOneDriver' -- (780682)
		, @UID_TaskFollower = 'SDL-K-OrgHasDriver' -- (790690)
		, @IsPhysicalDependency = 0
	-- delete QBMDBQueueTaskDepend where UID_TaskPredecessor = 'SDL-K-AllForOneDriver' and UID_TaskFollower = 'SDL-K-OrgHasDriver'
	
exec MDK_PDBQueueTaskDependDefine 
		@UID_TaskPredecessor = 'SDL-K-SoftwareDependsPhysical' -- (770650)
		, @UID_TaskFollower = 'SDL-K-OrgHasDriver' -- (790690)
		, @IsPhysicalDependency = 0
	-- delete QBMDBQueueTaskDepend where UID_TaskPredecessor = 'SDL-K-SoftwareDependsPhysical' and UID_TaskFollower = 'SDL-K-OrgHasDriver'
	
*/

create procedure SDL_ZOrgHasDriver (@SlotNumber int)
 
-- with encryption 
AS
begin
-- Ergänzung Aufzeichnung
  declare  @IsSimulationMode bit
  select @IsSimulationMode = dbo.QBM_FGIIsSimulationMode() 
-- / Ergänzung Aufzeichnung
declare @uid_Driver varchar(38)
declare @uid_org varchar(38)
declare @GenProcID varchar(38)
declare @vii int
declare @InheritePhysicalDependencies bit


declare @RowsToReset int -- CountItems mit -1 zurückzu setzender Jobs
declare @Sourcedata QBM_YDataForDelta
		, @CountDeltaQantity int 
		, @CountDeltaOrigin int 


-- u s e  M a s t e r 7 0SDL
declare @UID_BasetreeAssignToUse varchar(38) = 'SDL-AsgnBT-Driver' 


declare @MyName nvarchar(64) = object_name(@@procid)

BEGIN TRY


select @RowsToReset = 0

select @InheritePhysicalDependencies = 0
if dbo.QBM_FGIConfigparmValue('Software\InheritePhysicalDependencies')  > ' '
 begin
	select @InheritePhysicalDependencies = 1
 end


	exec QBM_PSlotResetOnMissingItem @SlotNumber, 'BaseTree', 'UID_Org'

	exec QER_PSlotResetOnInvalidRoot  @SlotNumber, @UID_BasetreeAssignToUse

--
-------------------------------------------------------------------------
-- zurücksetzen, falls noch job unterwegs ist
-------------------------------------------------------------------------

--20039
declare @ObjectKeysToCheck QBM_YParameterList
delete @ObjectKeysToCheck

insert into @ObjectKeysToCheck(Parameter1, Parameter2)
select  cu.UID_Parameter, x.XObjectKey
	from QBMDBQueueCurrent cu join BaseTree x on cu.UID_Parameter = x.UID_Org
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
						)

	select 0, 0
			, uid_org, uid_driver, XOrigin
	from BaseTreeHasDriver join QBMDBQueueCurrent x on uid_org =x.uid_parameter
														and x.SlotNumber = @SlotNumber


-- zusammenstellen aller Treiber, die die Organisation hat 
insert into @SourceData(
						IsUpcommingContent, XOriginBefore, XOriginAfter
						, Element, AssignedElement
						)
	select 1, 0,  oha.XOrigin & dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 1)
			, oha.uid_org, oha.uid_driver
     from BaseTreeHasDriver oha join QBMDBQueueCurrent x on oha.uid_org = x.uid_parameter
														and x.SlotNumber = @SlotNumber
--														and oha.XIsInEffect = 1 , doch ich kann ja (wieder) aktiv werden
	where oha.XOrigin & dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 1) > 0

insert into @SourceData(
						IsUpcommingContent, XOriginBefore
						, Element, AssignedElement, XOriginAfter
						)

	select 1, 0
			, x.uid_parameter, oha.uid_driver, dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 0)
     from QBMDBQueueCurrent x join BaseTreeCollection oc on oc.uid_org = x.uid_parameter
														and x.SlotNumber = @SlotNumber
									join BaseTreeHasDriver oha on oha.uid_org = oc.uid_parentorg
																and oha.XOrigin > 0
      where oc.uid_org <> oc.uid_parentorg
		-- nur das, was die Vorgänger zugewiesen haben, nicht das, was sie selber nur erben
            and oha.XOrigin & dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 1) > 0

if exists(
			select top 1 1
				from QBMModuleDef md
				where md.UID_ModuleDef = 'RMS-Moduledefinition'
		)
 begin
	insert into @SourceData(
							IsUpcommingContent, XOriginBefore
							, Element, AssignedElement, XOriginAfter
							)

		select 1, 0
				, x.uid_parameter, y.uid_Driver, dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 0)   -- über ESet gekommene Treiber
		 from QBMDBQueueCurrent x join BaseTreeHasEset bhe on x.uid_Parameter = bhe.uid_org
															and x.SlotNumber = @SlotNumber
															and bhe.XOrigin > 0
										join ESetHasEntitlement ehe on bhe.uid_ESet = ehe.uid_ESet
																	and ehe.XOrigin > 0 and ehe.XIsInEffect = 1
										join Driver y on ehe.entitlement = y.XObjectKey
										join BaseTree b on bhe.UID_Org = b.UID_Org
 														-- 26063 Eset auf BO und PR-Knoten nicht ausmultiplizieren
														and not (b.UID_OrgRoot in ( 'QER-V-ITShopOrg',  'QER-V-ITShopSrc')
																	and b.ITShopInfo in ( 'BO', 'PR')
																)
										join OrgRootAssign oa on oa.UID_OrgRoot = b.UID_OrgRoot
															and oa.UID_BaseTreeAssign = @UID_BasetreeAssignToUse
															and oa.IsAssignmentAllowed = 1
															and oa.IsDirectAssignmentAllowed = 1
 end
-- / Wegen ESet

-- IR 2005-07-19
-- Erweitern um die Einträge aus SoftwareDependsOnSoftware
if @InheritePhysicalDependencies = 1
 begin
 insert into @SourceData(
						IsUpcommingContent, XOriginBefore
						, Element, AssignedElement, XOriginAfter
						)

	select 1, 0
			, uid_org, uid_parentorg , dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 0)
		from 
	 (	select c.Element as uid_org , p.uid_parent as uid_parentorg
-- anzupassen für 13021
			from @Sourcedata c join SoftwareDependsOnSoftware p on c.AssignedElement = p.uid_child
							join driver a on a.uid_driver = p.uid_parent
			where c.IsUpcommingContent = 1
-- Erweitern um die Treiber, die über die Applikationen kommen
		union
		select bha.uid_org as uid_org , p.uid_parent as uid_parentorg
			from BaseTreeHasApp bha join QBMDBQueueCurrent x on bha.uid_org = x.uid_parameter
																	and x.SlotNumber = @SlotNumber
																	and bha.XOrigin > 0
							join SoftwareDependsOnSoftware p on bha.uid_application = p.uid_child
							-- eigentlich noch join über Application, erledigt sich aber mit bha
							join driver a on a.uid_driver = p.uid_parent
	 ) as x

/*
	where Not exists (select top 1 1 from fällt aus
				where z.uid_org = x.uid_org
				  and z.uid_parentorg = x.uid_parentorg
			)
*/

 end -- if @InheritePhysicalDependencies = 1
-- \ Erweitern um die Einträge aus SoftwareDependsOnSoftware


-----------------------------------------------------------------------------------
--  Feststellen der orgs, fr die die Treiber jetzt anders sind
--   (durch Vergleich der  Mengen vorher und nachher )  

exec QBM_PDBQueueCalculateDelta @SourceData,
								 @DeltaQuantity = 0,
							@DeltaDelete = 0,
							@DeltaInsert = 1,
							@DeltaOrigin = 1, 
							@CountDeltaQantity = @CountDeltaQantity output , @CountDeltaOrigin = @CountDeltaOrigin output
							, @UseIsInEffect = 0
							, @SlotNumber = @SlotNumber 

if @CountDeltaOrigin > 0 
 begin
	exec QBM_PMNTableOriginUpdate 'BaseTreeHasDriver', 'uid_Org', 'uid_Driver'
 end

if @CountDeltaQantity > 0 
 begin
	exec QER_PMNTableAddViewProperties 'BaseTreeHasDriver'
	exec QBM_PMNTableInsert 'BaseTreeHasDriver', 'uid_Org', 'uid_Driver', @TargetIsView = 1
																			, @FKTableNameElement = 'BaseTree'
																			, @FKColumnNameElement = 'UID_Org'
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
