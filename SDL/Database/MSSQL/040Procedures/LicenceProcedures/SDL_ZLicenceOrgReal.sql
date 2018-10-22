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


----------------------------------------------------------------------------------
-- SDL_ZLicenceOrgReal	
----------------------------------------------------------------------------------
	-- errechnet die Actual-Werte für einen Teilbaum (IsLicenceNode = 1)
	-- Prozedur hat als Parameter die uid_org, für deren teilbaum die Berechnung stattfinden soll
	-- Taskname ist LicenceOrgReal

exec QBM_PProcedureDrop 'SDL_ZLicenceOrgReal'
go

---<summary>Calculates the actual values for a partial tree</summary>
---<remarks>The org UID (partial tree roots) are passed in the auxiliary table QBMDBQueueCurrent</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-LicenceOrgReal'  -- (899990)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-LicenceOrgReal'
		, @ProcedureName = 'SDL_ZLicenceOrgReal'
		, @IsBulkEnabled = 1
		, @CountParameter = 1
		, @MaxInstance = 1000
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate = '


	select b.uid_org  
	from BaseTree b join orgroot r on b.uid_orgRoot = r.uid_orgroot 
	where exists (select top 1 1 
					from dialogtable t 
					where t.tablename = dbo.QER_FGIOrgRootName(b.uid_orgroot) + ''HasLicence'' 
						and t.TableType = ''V'' 
				)
		 and (uid_parentorg is null 
				or islicencenode = 1
			)
		 and  ''1'' = dbo.QBM_FGIConfigparmValue(''Software\LicenceManagement'') 
'
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = null
		
exec MDK_PDBQueueTaskDependDefine 
		@UID_TaskPredecessor = 'SDL-K-LicenceRECalculate' -- (889990)
		, @UID_TaskFollower = 'SDL-K-LicenceOrgReal' -- (899990)
		, @IsPhysicalDependency = 0
	-- delete QBMDBQueueTaskDepend where UID_TaskPredecessor = 'SDL-K-LicenceRECalculate' and UID_TaskFollower = 'SDL-K-LicenceOrgReal'
	
*/



create procedure SDL_ZLicenceOrgReal (@SlotNumber int)
	as 
begin
-- Berechnung für eine Menge Orgknoten
-- exec QBM_PProcedureNestLevelCheck @@ProcID

  -- Voraussetzung schaffen: fehlende BaseTreeHasLicence bauen
-- die Werte schon mal vorher holen, um sie nicht im Join jedesmal zu ziehen und zu vergleichen
declare @primary bit
declare @secondary bit

declare @V_LicenceNode_Subnode table 
		( uid_org varchar(38) collate database_default,
		  uid_subOrg varchar(38) collate database_default,
		  AssignWorkDesk bit,
		  AssignHardware bit,
		  AssignPerson bit
		)

BEGIN TRY



select @primary = 0
select @secondary = 0
select @primary = dbo.QBM_FCVStringToInt(dbo.QBM_FGIConfigparmValue('Software\LicenceManagement\LicenceForSubTree\PrimaryAssignment'), 0)
select @secondary = dbo.QBM_FCVStringToInt(dbo.QBM_FGIConfigparmValue('Software\LicenceManagement\LicenceForSubTree\SecondaryAssignment'), 0)

-- Vormaterialisieren der View SDL_VLicenceNodeSubnode für die Menge der angegebenen Knoten in QBMDBQueueCurrent
-- durch ausmultiplizieren mit QBMDBQueueCurrent
insert into @V_LicenceNode_Subnode (uid_org, uid_subOrg, AssignWorkDesk, AssignHardware, AssignPerson)
	select v.uid_org, v.uid_suborg, v.IsAssignmentAllowedWorkDesk, v.IsAssignmentAllowedHardware, v.IsAssignmentAllowedPerson
		from QBMDBQueueCurrent p join SDL_VLicenceNodeSubnode v on p.uid_parameter = v.uid_org
		where p.SlotNumber = @SlotNumber



	exec SDL_PLicenceOrg_Basics @SlotNumber


   	-- Werte müssen geliefert werden für alle Orgknoten und alle Lizenzen
	-- da das nicht der Fall ist, wird vorher auf 0 zurücksgesetzt
 update BaseTreeHasLicence set CountLicMacReal = 0 
	where isnull(CountLicMacReal ,0) <> 0
	and exists (select top 1 1 
					from QBMDBQueueCurrent p 
					where p.uid_parameter = BaseTreeHasLicence.uid_org
					and p.SlotNumber = @SlotNumber
				)


  update BaseTreeHasLicence set CountLicMacReal = zz.CountItems
	from BaseTreeHasLicence join 
	( select yy.uid_org, m.uid_licence, count(*) as CountItems
	    from 
	 (	-- die Arbeitsplätze und ihre Lizenzen bestimmen
		-- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
		select mai.uid_Hardware, ahl.uid_licence
			from MachineAppsConfig mai 
					join apphaslicence ahl on mai.uid_application = ahl.uid_application
								and mai.AppsNotDriver = 1
								and mai.CurrentlyActive = 1
		 union
		--		2) Treiber an Maschinen zugewiesen
		select mai.uid_Hardware, dhl.uid_licence
			from MachineAppsConfig mai 
					join driverhaslicence dhl on mai.uid_driver = dhl.uid_driver
								and isnull(mai.AppsNotDriver,0) = 0
								and mai.CurrentlyActive = 1
		-- OS muß auch als Treiber erkannt werden, zumindest war Softwareinventory mal so gedacht

		-- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
	) as m join Hardware h on m.uid_Hardware = h.uid_Hardware
		join 
	-- die Arbeitsplätze zur Menge der Orgs bestimmen
	(select ww.uid_org , ww.uid_WorkDesk
	   from 
		( select distinct v.uid_org, wio.uid_WorkDesk as uid_WorkDesk
			from @V_LicenceNode_Subnode v join WorkDeskinBaseTree wio on v.uid_suborg = wio.uid_org
																	and v.AssignWorkDesk = 1
																	and wio.XOrigin > 0
			where @secondary = 1
		union all -- wichtig, weil sonst mehrfache wegfallen
		 select distinct v.uid_org, w.uid_WorkDesk
			from @V_LicenceNode_Subnode v join helperWorkDeskorg w on v.uid_suborg = w.uid_org
			where @primary = 1
		) as ww 
	) as yy on h.uid_WorkDesk = yy.uid_WorkDesk
	group by yy.uid_org, m.uid_licence

   ) as zz on BaseTreeHasLicence.uid_org = zz.uid_org 
		and BaseTreeHasLicence.uid_licence = zz.uid_licence

END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

	exec QBM_PRollbackIfAllowed 

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	


end
go
