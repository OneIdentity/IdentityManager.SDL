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



---------------------------------------------------------------------------
-- Prozedur SDL_ZSoftwareDependsPhysical
---------------------------------------------------------------------------

--Taskname wird SoftwareDependsPhysical

-- ist DBSchedulerTask
-- Ermittelt die Einträge in SoftwareDependsOnSoftware
-- Prozedur hat keine Parameter, da immer für die gesamte Hülle durchgerechnet werden muß
exec QBM_PProcedureDrop 'SDL_ZSoftwareDependsPhysical'
go


-- exec SDL_ZSoftwareDependsPhysical
-- delete from softwaredependsonsoftware
-- select * from softwaredependsonsoftware

-- This procedure is exclusively used in the DBScheduler
---<istoignore/>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-SoftwareDependsPhysical'  -- (810622)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-SoftwareDependsPhysical'
		, @Operation = 'SOFTWAREDEPENDSPHYSICAL'
		, @ProcedureName = 'SDL_ZSoftwareDependsPhysical'
		, @IsBulkEnabled = 0
		, @CountParameter = 0
		, @MaxInstance = 1
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate = 'select	'''''
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = null
		
exec MDK_PDBQueueTaskDependDefine 
		@UID_TaskPredecessor = 'SDL-K-SoftwareDependsPhysical' -- (810622)
		, @UID_TaskFollower = 'SDL-K-AllForOneDriver' -- (810622)
		, @IsPhysicalDependency = 0
	-- delete QBMDBQueueTaskDepend where UID_TaskPredecessor = 'SDL-K-SoftwareDependsPhysical' and UID_TaskFollower = 'SDL-K-AllForOneDriver'
	
exec MDK_PDBQueueTaskDependDefine 
		@UID_TaskPredecessor = 'SDL-K-SoftwareDependsPhysical' -- (810622)
		, @UID_TaskFollower = 'SDL-K-OrgHasDriver' -- (810622)
		, @IsPhysicalDependency = 0
	-- delete QBMDBQueueTaskDepend where UID_TaskPredecessor = 'SDL-K-SoftwareDependsPhysical' and UID_TaskFollower = 'SDL-K-OrgHasDriver'
	
*/

create procedure SDL_ZSoftwareDependsPhysical (@SlotNumber int
							,@dummy1 varchar(38),  -- Parameterset nur wegen Aufrufbarkeit
						@dummy2 varchar(38),
						@GenProcIDDummy varchar(38)
					    )
			as
 begin

-- Ergänzung Aufzeichnung
  declare  @IsSimulationMode bit
  select @IsSimulationMode = dbo.QBM_FGIIsSimulationMode() 
-- / Ergänzung Aufzeichnung

declare @Sourcedata QBM_YDataForDelta
		, @CountDeltaQantity int 
		, @CountDeltaOrigin int 


-- Variablen für job
declare @uid varchar(38)
declare @where nvarchar(1024)
declare @BasisObjectKey varchar(138)


-- alle die bestimmen, die nirgendwo als Child auftauchen, die sind erst mal die Wurzel

-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
declare @GenProcIDForRestore varchar(38)
declare @XUserForRestore nvarchar(64)
declare @OperationLevelForRestore int
declare @lauf int

declare @DBQueueElements QBM_YDBQueueRaw 
declare @AdditionalObjectKeysAffected_CSU QBM_YParameterList -- compiler shut up
declare @GenProcID varchar(38) = newid()
BEGIN TRY

exec @OperationLevelForRestore = QBM_PGenprocidGetFromContext @GenProcIDForRestore output, @XUserForRestore output, @CodeID = @@ProcID


--
--
--

-- Schappschuss vorher anfertigen und merken 

insert into @SourceData(
						IsUpcommingContent, XOriginAfter
						, Element, AssignedElement, XOriginBefore
						)

	select 0, 0
			, UID_Child , UID_Parent , 2                            
	from softwaredependsonsoftware
  


	truncate table #QBMDeltaHelper

	insert into #QBMDeltaHelper(Element, AssignedElement)
	select  uid_applicationChild, uid_applicationParent 
	from applicationdependsonapp
	where isphysicaldependent = 1
 union
	select uid_DriverChild, uid_DriverParent 
	from driverdependsondriver
	where isphysicaldependent = 1
 union
	select UID_ApplicationChild, UID_DriverParent
	from ApplicationDependsonDriver

	

 -- jetzt zyklisch die überbrückungen auffüllen

select @Lauf = 1
while @lauf > 0
 begin
 
insert into #QBMDeltaHelper(Element, AssignedElement)
	select distinct  t1.Element, t2.AssignedElement
-- anzupassen für 13021
		from #QBMDeltaHelper t1 join #QBMDeltaHelper t2 on t1.AssignedElement = t2.Element /* child */
-- anzupassen für 13021
		where Not exists (select top 1 1 from #QBMDeltaHelper tv where tv.Element = t1.Element
									and tv.AssignedElement = t2.AssignedElement
				)

	select @lauf = @@rowcount 
  end



insert into @SourceData(
						IsUpcommingContent, XOriginAfter
						, Element, AssignedElement, XOriginBefore
						)

	select 1, 2
			, Element, AssignedElement, 0
	from #QBMDeltaHelper
	
exec QBM_PDBQueueCalculateDelta @SourceData,
								 @DeltaQuantity = 1,
							@DeltaDelete = 1,
							@DeltaInsert = 1,
							@DeltaOrigin = 0, 
							@CountDeltaQantity = @CountDeltaQantity output , @CountDeltaOrigin = @CountDeltaOrigin output
							, @UseIsInEffect = 0
							, @SlotNumber = @SlotNumber 


-- jetzt vergleichen 
-- alle die wo Unterschiede sind (nicht mehr da, neu da oder Menge der Vorgänger geändert) , nachberechnungen für Application bzw. Treiber machen
-- perspektivisch auch die Schreibaufträge für den ViClient (Steuerdatei) einstellen (updatecname)

if @CountDeltaQantity = 0 
 begin
	goto ende
 end


-- überzählige löschen
		-- Ergänzung Aufzeichnung
			if @IsSimulationMode = 1
			 begin
				insert into #TriggerOperation (operation, BaseObjectType, ColumnName, Objectkey, OldValue) 
								select 'D', 'softwaredependsonsoftware', '', 
												dbo.QBM_FCVElementToObjectKey2('softwaredependsonsoftware', 'uid_child', uid_child, 'uid_parent', uid_parent) , ''
								from softwaredependsonsoftware
										where exists (select top 1 1 from #QBMDeltaDelete cdd
												where cdd.Element = softwaredependsonsoftware.uid_child
												and cdd.AssignedElement = softwaredependsonsoftware.uid_parent
											     )
			 end
		-- / Ergänzung Aufzeichnung
		exec QBM_PGenprocidSetInContext  @GenProcID, 'DBScheduler', 1

	   delete from softwaredependsonsoftware
		where exists (select top 1 1 from #QBMDeltaDelete cdd
				where cdd.Element = softwaredependsonsoftware.uid_child
				and cdd.AssignedElement = softwaredependsonsoftware.uid_parent
			     )


-- neue aufnehmen
	-- Ergänzung Aufzeichnung
		if @IsSimulationMode = 1
		 begin
			insert into #TriggerOperation (operation, BaseObjectType, ColumnName, Objectkey, OldValue) 
							select 'I', 'softwaredependsonsoftware', '', 
										dbo.QBM_FCVElementToObjectKey2('softwaredependsonsoftware', 'uid_child', Element, 'uid_parent', AssignedElement) , ''
							from #QBMDeltaInsert
		 end
	-- / Ergänzung Aufzeichnung
	exec QBM_PGenprocidSetInContext  @GenProcID, 'DBScheduler', 1

  insert into softwaredependsonsoftware (uid_child, uid_parent, XObjectKey)
   select Element, AssignedElement, dbo.QBM_FCVElementToObjectKey2('softwaredependsonsoftware', 'uid_child', Element, 'uid_parent', AssignedElement)
	from #QBMDeltaInsert

-- hier kommt die Aktion hin, die für alle Profile eine Methode zum aktualisieren
-- der Vorgängerliste aufruft

	DECLARE schritt_softwareDepends_app CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
		select x.uid from 
			( select  d.Element as uid
				from #QBMDeltaQuantity  d 
			) as x join application a on x.uid = a.uid_application -- um die Treiber wegzufiltern
	
	OPEN schritt_softwareDepends_app
	FETCH NEXT FROM schritt_softwareDepends_app into @uid
	WHILE (@@fetch_status <> -1)
	BEGIN
		select @where = N'uid_application = ''' + rtrim(@uid) + N''''
		select @BasisObjectKey = dbo.QBM_FCVElementToObjectKey1('ApplicationProfile', 'uid_application', @uid)

		exec QBM_PJobCreate_HOFireEvent 'ApplicationProfile', @where , 'WritePathVII', @GenProcID
							, @ObjectKeysAffected = @AdditionalObjectKeysAffected_CSU
							, @checkForExisting = 1
							, @BasisObjectKey = @BasisObjectKey

	     FETCH NEXT FROM schritt_softwareDepends_app INTO @uid
	END
	close schritt_softwareDepends_app
	deallocate schritt_softwareDepends_app


	DECLARE schritt_softwareDepends_drv CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
		select x.uid from 
			( select  d.Element as uid
				from #QBMDeltaQuantity  d 
			) as x join Driver a on x.uid = a.uid_Driver -- um die Applikationen wegzufiltern
	
	OPEN schritt_softwareDepends_drv
	FETCH NEXT FROM schritt_softwareDepends_drv into @uid
	WHILE (@@fetch_status <> -1)
	BEGIN
		select @where = N'uid_Driver = ''' + rtrim(@uid) + N''''
		select @BasisObjectKey = dbo.QBM_FCVElementToObjectKey1('DriverProfile', 'uid_Driver', @uid)

		exec QBM_PJobCreate_HOFireEvent 'DriverProfile', @where , 'WritePathVII', @GenProcID
							, @ObjectKeysAffected = @AdditionalObjectKeysAffected_CSU
							, @checkForExisting = 1
							, @BasisObjectKey = @BasisObjectKey
	     FETCH NEXT FROM schritt_softwareDepends_drv INTO @uid
	END
	close schritt_softwareDepends_drv
	deallocate schritt_softwareDepends_drv

-- Folgejobs für alle einstellen, wo sich die Menge der Vorgänger geändert hat

		delete @DBQueueElements 
		
		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
			from ( select  d.Element as uid
				from #QBMDeltaQuantity  d 
			) as x join application a on x.uid = a.uid_application -- um die Treiber wegzufiltern

		exec QBM_PDBQueueInsert_Bulk 'APC-K-AllForOneApplication', @DBQueueElements 



		delete @DBQueueElements 
		
		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
			from ( select  d.Element as uid
				from #QBMDeltaQuantity  d 
			) as x join driver a on x.uid = a.uid_driver -- um die Applikationen wegzufiltern

		exec QBM_PDBQueueInsert_Bulk 'SDL-K-AllForOneDriver', @DBQueueElements

END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'schritt_softwareDepends_app'
    exec QBM_PCursorDrop 'schritt_softwareDepends_drv'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	
-- Standard-Abspann für Prozeduren, die die GenProciD setzen

ende:
	exec QBM_PGenprocidSetInContext @GenProcIDForRestore, @XUserForRestore, @OperationLevelForRestore
	return

 end
go

