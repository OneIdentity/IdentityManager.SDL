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
   --  ZusatzProzedur SDL_ZWorkDeskHasDriver
   --------------------------------------------------------------------------------  

exec QBM_PProcedureDrop 'SDL_ZWorkDeskHasDriver' 
go


---<summary>Fills and corrects the table WorkDeskHasDriver</summary>
---<remarks>WorkDesk UIDs are passed in the auxiliary table QBMDBQueueCurrent </remarks>
---<example>Function exclusively for use in the DBScheduler</example>

---<seealso cref="QBM_PCursorDrop" type="Procedure">Procedure QBM_PCursorDrop</seealso>
---<seealso cref="QBM_FCVElementToObjectKey1" type="Function">Function QBM_FCVElementToObjectKey1</seealso>
---<seealso cref="QBM_FGIIsSimulationMode" type="Function">Function QBM_FGIIsSimulationMode</seealso>
---<seealso cref="QBM_FGIErrorMessage" type="Function">Function QBM_FGIErrorMessage</seealso>
/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-WorkdeskHasDriver'  -- (730782)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-WorkdeskHasDriver'
		, @Operation = 'WorkDeskHASDRIVER'
		, @ProcedureName = 'SDL_ZWorkDeskHasDriver'
		, @IsBulkEnabled = 1
		, @CountParameter = 1
		, @MaxInstance = 1000
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate = 'select	uid_WorkDesk	from	WorkDesk	where	''1''	=	dbo.QBM_FGIConfigparmValue(''Software\Driver'')'
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = 'QER-K-AllForOneWorkdesk'
		
*/


create procedure SDL_ZWorkDeskHasDriver (@SlotNumber int)
 
-- with encryption 
AS
begin
-- Ergänzung Aufzeichnung
  declare  @IsSimulationMode bit
  select @IsSimulationMode = dbo.QBM_FGIIsSimulationMode() 
-- / Ergänzung Aufzeichnung

declare @Sourcedata QBM_YDataForDelta
		, @CountDeltaQantity int 
		, @CountDeltaOrigin int 

declare @GenProcID varchar(38)
declare @uid_WorkDesk varchar(38)
declare @uid_driver varchar(38)
declare @vii int
declare @ItemObjectKey varchar(138)

declare @InheritePhysicalDependencies bit
select @InheritePhysicalDependencies = 0

declare @RowsToReset int -- CountItems mit -1 zurückzu setzender Jobs



declare @MyName nvarchar(64) = object_name(@@procid)

BEGIN TRY


select @RowsToReset = 0

if dbo.QBM_FGIConfigparmValue('Software\InheritePhysicalDependencies') > ' '
 begin
	select @InheritePhysicalDependencies = 1
 end

	exec QBM_PSlotResetOnMissingItem  @SlotNumber, 'WorkDesk', 'uid_WorkDesk'


-------------------------------------------------------------------------
-- zurücksetzen, falls noch job unterwegs ist
-------------------------------------------------------------------------

--20039
declare @ObjectKeysToCheck QBM_YParameterList
delete @ObjectKeysToCheck

insert into @ObjectKeysToCheck(Parameter1, Parameter2)
select  cu.UID_Parameter, x.XObjectKey
	from QBMDBQueueCurrent cu join WorkDesk x on cu.UID_Parameter = x.UID_WorkDesk
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

-- alle bisherigen Driver des Arbeitsplatzes merken 

insert into @SourceData(
						IsUpcommingContent, XOriginAfter
						, Element, AssignedElement, XOriginBefore
						, XIsInEffectBefore, XIsInEffectAfter
						)

	select 0, 0
			, uid_WorkDesk, uid_Driver, XOrigin 
			, whd.XIsInEffect, 0
		from WorkDeskHasDriver whd join QBMDBQueueCurrent x  on uid_WorkDesk = x.uid_parameter
															and x.SlotNumber = @SlotNumber


-- zusammenstellen aller Driver, die der Arbeitsplatz hat
--     diese knnen kommen 
--        aus  WorkDeskHasDriver
--	ber WorkDeskInBaseTree 
insert into @SourceData(
						IsUpcommingContent, XOriginBefore, XOriginAfter
						, Element, AssignedElement
						, XIsInEffectBefore, XIsInEffectAfter
						)
	select 1, 0,  whd.XOrigin & dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 1)
			, uid_WorkDesk, uid_Driver 
			, 0,1
        from WorkDeskHasDriver whd join QBMDBQueueCurrent x on uid_WorkDesk = x.uid_parameter
														and x.SlotNumber = @SlotNumber

insert into @SourceData(
						IsUpcommingContent, XOriginBefore
						, Element, AssignedElement, XOriginAfter
						, XIsInEffectBefore, XIsInEffectAfter
						)

	select 1, 0
			, x.uid_WorkDesk, x.uid_driver,dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 0)
			, 0, 1
	from (

  select wha.uid_WorkDesk, d.uid_Driver
   from WorkDeskhasEset wha join  QBMDBQueueCurrent x on wha.uid_WorkDesk = x.uid_parameter 
															and x.SlotNumber = @SlotNumber
															and wha.XOrigin > 0 and wha.XIsInEffect = 1
				join EsetHasEntitlement ehe on wha.uid_ESet = ehe.uid_ESet
											and ehe.XOrigin > 0 and ehe.XIsInEffect = 1
											and  exists(
															select top 1 1
																from QBMModuleDef md
																where md.UID_ModuleDef = 'RMS-Moduledefinition'
														)
				join Driver d on ehe.Entitlement = d.XObjectKey
   union all 
  select ph.uid_WorkDesk, oha.uid_Driver 
    from 
-- Ersatzblock für v i _ v_ WorkDeskInheriteFromOrg
				(
					select  hpo.uid_WorkDesk , hpo.uid_org 
							from QBMDBQueueCurrent p join helperWorkDeskorg hpo on p.uid_parameter = hpo.uid_WorkDesk 
																				and p.SlotNumber = @SlotNumber
					union 
					select  pio.uid_WorkDesk , pio.uid_org 
							from QBMDBQueueCurrent p join WorkDeskinBaseTree pio on p.uid_parameter = pio.uid_WorkDesk 
																				and p.SlotNumber = @SlotNumber
																				and pio.XOrigin > 0
														join BaseTree ba on pio.UID_Org = ba.UID_Org
														left outer join DynamicGroup dg on dg.ObjectKeyBaseTree = ba.XObjectKey 
					) as ph   
-- / Ersatzblock für v i _ v_ WorkDeskInheriteFromOrg

	join WorkDesk w on w.uid_WorkDesk = ph.uid_WorkDesk
-- wegen Buglist 10002 ausfiltern
													and w.IsNoInherite = 0
								join BaseTree b on b.uid_org = ph.uid_org
												and b.IsNoInheriteToWorkDesk = 0
		join BaseTreeHasDriver oha on ph.uid_org = oha.uid_org 
								and oha.XOrigin > 0

 ) as x
-- group by x.uid_WorkDesk, x.uid_driver

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
			, uid_org, uid_parentorg, dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 0) 
			, 0, 1
			from 
	 (	select c.Element as uid_org , p.uid_parent as uid_parentorg
-- anzupassen für 13021
			from @Sourcedata c join SoftwareDependsOnSoftware p on c.AssignedElement = p.uid_child
							join driver a on a.uid_driver = p.uid_parent
			where c.IsUpcommingContent = 1

		union
		select wha.uid_WorkDesk as uid_org , p.uid_parent as uid_parentorg
			from WorkDeskHasApp wha join QBMDBQueueCurrent x on wha.uid_WorkDesk = x.uid_parameter
																and x.SlotNumber = @SlotNumber
																and wha.XOrigin > 0 and wha.XIsInEffect = 1
							join SoftwareDependsOnSoftware p on wha.uid_application = p.uid_child
							-- eigentlich noch join über Application, erledigt sich aber mit wha
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


------------------------------------------------------------------------------------------
--  Feststellen, ob sich die Menge an Driveren gendert hat
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
	exec QBM_PMNTableOriginUpdate 'WorkDeskHasDriver', 'uid_WorkDesk', 'uid_driver'
 end


if @CountDeltaQantity > 0 
 begin
	exec QBM_PMNTableInsert 'WorkDeskHasDriver', 'uid_WorkDesk', 'uid_driver', @TargetIsView = 0
																			, @FKTableNameElement = 'WorkDesk'
																			, @FKColumnNameElement = 'uid_WorkDesk'
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
