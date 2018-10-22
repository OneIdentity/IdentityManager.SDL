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
-- SDL_ZLicenceOrgTarget	
----------------------------------------------------------------------------------
	-- errechnet die Target-Werte für einen Teilbaum (IsLicenceNode = 1)
	-- Prozedur hat als Parameter die uid_org, für deren teilbaum die Berechnung stattfinden soll
	-- Taskname ist LicenceOrgTarget
exec QBM_PProcedureDrop 'SDL_ZLicenceOrgTarget'
go

---<summary>Calculates the target values for a partial tree</summary>
---<remarks>The org UID (partial tree roots) are passed in the auxiliary table QBMDBQueueCurrent</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-LicenceOrgTarget'  -- (899990)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-LicenceOrgTarget'
		, @ProcedureName = 'SDL_ZLicenceOrgTarget'
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
					where t.TableName = dbo.QER_FGIOrgRootName(b.uid_orgroot) + ''HasLicence'' 
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
		, @UID_TaskFollower = 'SDL-K-LicenceOrgTarget' -- (899990)
		, @IsPhysicalDependency = 0
	-- delete QBMDBQueueTaskDepend where UID_TaskPredecessor = 'SDL-K-LicenceRECalculate' and UID_TaskFollower = 'SDL-K-LicenceOrgTarget'
	
*/

create procedure SDL_ZLicenceOrgTarget (@SlotNumber int)
	as 
begin
-- Berechnung für eine Menge Orgknoten
-- exec QBM_PProcedureNestLevelCheck @@ProcID

  -- Voraussetzung schaffen: fehlende BaseTreeHasLicence bauen
	exec SDL_PLicenceOrg_Basics @SlotNumber


-- die Werte schon mal vorher holen, um sie nicht im Join jedesmal zu ziehen und zu vergleichen
declare @primary bit
declare @secondary bit

declare @Zaehlweise int

declare @V_LicenceNode_Subnode table 
		( uid_org varchar(38) collate database_default,
		  uid_subOrg varchar(38) collate database_default,
		  AssignWorkDesk bit,
		  AssignHardware bit,
		  AssignPerson bit
			
		)

BEGIN TRY



select @zaehlweise = dbo.QBM_FCVStringToInt(dbo.QBM_FGIConfigparmValue('Software\LicenceManagement\CountOSLicenceBy'), 0)
if @zaehlweise = 0
 begin
	select @zaehlweise = 1
 end


-- Vormaterialisieren der View SDL_VLicenceNodeSubnode für die Menge der angegebenen Knoten in QBMDBQueueCurrent
-- durch ausmultiplizieren mit QBMDBQueueCurrent
insert into @V_LicenceNode_Subnode (uid_org, uid_subOrg, AssignWorkDesk, AssignHardware, AssignPerson)
	select v.uid_org, v.uid_suborg, v.IsAssignmentAllowedWorkDesk, v.IsAssignmentAllowedHardware, v.IsAssignmentAllowedPerson
		from QBMDBQueueCurrent p join SDL_VLicenceNodeSubnode v on p.uid_parameter = v.uid_org
		where p.SlotNumber = @SlotNumber


select @primary = 0
select @secondary = 0
select @primary = dbo.QBM_FCVStringToInt(dbo.QBM_FGIConfigparmValue('Software\LicenceManagement\LicenceForSubTree\PrimaryAssignment'), 0)
select @secondary = dbo.QBM_FCVStringToInt(dbo.QBM_FGIConfigparmValue('Software\LicenceManagement\LicenceForSubTree\SecondaryAssignment'), 0)


declare @InheritePhysicalDependencies bit
select @InheritePhysicalDependencies = 0
if dbo.QBM_FGIConfigparmValue('Software\InheritePhysicalDependencies') > ' '
 begin
	select @InheritePhysicalDependencies = 1
 end


   	-- Werte müssen geliefert werden für alle Orgknoten und alle Lizenzen
	-- da das nicht der Fall ist, wird vorher auf 0 zurücksgesetzt
 update BaseTreeHasLicence set CountLicMacDirectTarget = 0 
	where isnull(CountLicMacDirectTarget ,0) <> 0
	and exists (select top 1 1 
					from QBMDBQueueCurrent p 
					where p.uid_parameter = BaseTreeHasLicence.uid_org
					 and p.SlotNumber = @SlotNumber
				)


  update BaseTreeHasLicence set CountLicMacDirectTarget = zz.CountItems
	from BaseTreeHasLicence join 
	( select yy.uid_org, m.uid_licence, count(*) as CountItems
	    from 
	 (	-- die Arbeitsplätze und ihre Lizenzen bestimmen
		-- Achtung, WorkDesk hier im Unterschied zu SDL_ZLicenceCompanyTarget gleich mit rausführen, nochmal join über haware mit uid_WorkDesk zum nächsten Block (yy) ist der absoluter Performancekiller
		select h.uid_Hardware, ahl.uid_licence, wha.uid_WorkDesk
			from WorkDeskhasapp wha 
					join Hardware h on h.uid_WorkDesk = wha.uid_WorkDesk
							and (h.ispc=1 or h.isServer = 1)
							and wha.XIsInEffect = 1
							and wha.XOrigin > 0 and wha.XIsInEffect = 1
					join (-- physische Vorgänger mitnehmen
						select UID_Child, UID_Parent
							 from softwaredependsonsoftware
							where @InheritePhysicalDependencies = 0
						union 
						 select uid_application , uid_application 
							from application
						) as su on su.uid_child = wha.uid_application
					join apphaslicence ahl on su.uid_parent = ahl.uid_application
		 union
		--		2) Treiber an Arbeitsplätze zugewiesen
		select h.uid_Hardware, dhl.uid_licence, h.uid_WorkDesk
			from WorkDeskhasdriver whd 
					join Hardware h on h.uid_WorkDesk = whd.uid_WorkDesk
							and (h.ispc=1 or h.isServer = 1)
							and whd.XIsInEffect = 1
							and whd.XOrigin > 0 and whd.XIsInEffect = 1
					join (-- physische Vorgänger mitnehmen
						select UID_Child, UID_Parent
							 from softwaredependsonsoftware
							where @InheritePhysicalDependencies = 0
						union 
						 select uid_driver, uid_driver
							from driver
						) as su on su.uid_child = whd.uid_driver
					join driverhaslicence dhl on su.uid_parent = dhl.uid_driver
		 union
		--		2a) Treiber an Maschinen zugewiesen
		select h.uid_Hardware, dhl.uid_licence, h.uid_WorkDesk
			from Hardware h join machineHasDriver mhd on h.uid_Hardware = mhd.uid_Hardware
									and (h.ispc=1 or h.isServer = 1)
									and mhd.XIsInEffect = 1
									and mhd.XOrigin > 0 and mhd.XIsInEffect = 1
					join (-- physische Vorgänger mitnehmen
						select UID_Child, UID_Parent
							 from softwaredependsonsoftware
							where @InheritePhysicalDependencies = 0
						union 
						 select uid_driver, uid_driver
							from driver
						) as su on su.uid_child = mhd.uid_driver
					join driverhaslicence dhl on su.uid_parent = dhl.uid_driver
--		 u n i o n
--		3) OS auf dem Arbeitsplatz zugewiesen
-- komm nachher separat
	) as m join 
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
			from @V_LicenceNode_Subnode v join helperWorkDeskorg w on  v.uid_suborg = w.uid_org
			where @primary = 1
		) as ww 
	) as yy on m.uid_WorkDesk = yy.uid_WorkDesk
	group by yy.uid_org, m.uid_licence

   ) as zz on BaseTreeHasLicence.uid_org = zz.uid_org 
		and BaseTreeHasLicence.uid_licence = zz.uid_licence





-- die Sonderlocke für die Betriebssysteme
-- Buglist 7869
if @zaehlweise = 1 
 begin
  update BaseTreeHasLicence set CountLicMacDirectTarget = BaseTreeHasLicence.CountLicMacDirectTarget + zz.CountItems
	from BaseTreeHasLicence join 
	( select yy.uid_org, yy.uid_licence, count(*) as CountItems
	    from 
				( select  v.uid_org, os.uid_licence
					from @V_LicenceNode_Subnode v 
													join WorkDeskinBaseTree wio on v.uid_suborg = wio.uid_org
																				and v.AssignWorkDesk = 1
																				and wio.XOrigin > 0
													join WorkDesk w on wio.uid_WorkDesk = w.uid_WorkDesk
													join os on w.UID_OS = os.UID_OS
					where @secondary = 1
				union all -- wichtig, weil sonst mehrfache wegfallen
				 select  v.uid_org, os.uid_licence
					from @V_LicenceNode_Subnode v 
												join helperWorkDeskorg hwo on  v.uid_suborg = hwo.uid_org
												join WorkDesk w on hwo.uid_WorkDesk = w.uid_WorkDesk
												join os on w.UID_OS = os.UID_OS
					where @primary = 1
				) as yy

	group by yy.uid_org, yy.uid_licence

   ) as zz on BaseTreeHasLicence.uid_org = zz.uid_org 
		and BaseTreeHasLicence.uid_licence = zz.uid_licence
 end -- if @zaehlweise = 1 

if @zaehlweise = 2 
 begin
  update BaseTreeHasLicence set CountLicMacDirectTarget = BaseTreeHasLicence.CountLicMacDirectTarget + zz.CountItems
	from BaseTreeHasLicence join 
	( select yy.uid_org, yy.uid_licence, count(*) as CountItems
	    from 
				( 
				 select  v.uid_org, os.uid_licence
					from @V_LicenceNode_Subnode v 
													join WorkDeskinBaseTree wio on v.uid_suborg = wio.uid_org
																				and v.AssignWorkDesk = 1
																				and wio.XOrigin > 0
													join Hardware h on h.uid_WorkDesk = wio.uid_WorkDesk
													join os on h.UID_OS = os.UID_OS
					where @secondary = 1
				union all -- wichtig, weil sonst mehrfache wegfallen
				 select  v.uid_org, os.uid_licence
					from @V_LicenceNode_Subnode v 
												 join helperWorkDeskorg w on  v.uid_suborg = w.uid_org
												join Hardware h on h.uid_WorkDesk = w.uid_WorkDesk
												join os on h.UID_OS = os.UID_OS
					where @primary = 1
				) as yy

	group by yy.uid_org, yy.uid_licence

   ) as zz on BaseTreeHasLicence.uid_org = zz.uid_org 
		and BaseTreeHasLicence.uid_licence = zz.uid_licence

 end -- if @zaehlweise = 2 

if @zaehlweise = 3
 begin
  update BaseTreeHasLicence set CountLicMacDirectTarget = BaseTreeHasLicence.CountLicMacDirectTarget + zz.CountItems
	from BaseTreeHasLicence join 
	( select yy.uid_org, yy.uid_licence, count(*) as CountItems
	    from 
				( 
				 select  v.uid_org, os.uid_licence
					from @V_LicenceNode_Subnode v 
												 join HardwareInBaseTree hio on v.uid_suborg = hio.uid_org
																			and hio.XOrigin > 0
																			and v.AssignHardware = 1
												join Hardware h on h.uid_Hardware = hio.uid_Hardware
												join os on h.UID_OS = os.UID_OS
					where @secondary = 1
				union all -- wichtig, weil sonst mehrfache wegfallen
				 select  v.uid_org, os.uid_licence
					from @V_LicenceNode_Subnode v 
												 join helperHardwareorg hho on  v.uid_suborg = hho.uid_org
												join Hardware h on hho.uid_Hardware = h.uid_Hardware
												join os on h.UID_OS = os.UID_OS
					where @primary = 1
				) as yy

	group by yy.uid_org, yy.uid_licence

   ) as zz on BaseTreeHasLicence.uid_org = zz.uid_org 
		and BaseTreeHasLicence.uid_licence = zz.uid_licence

 end -- if @zaehlweise = 3


-- / Buglist 7869






-- für eine Menge Orgs

 update BaseTreeHasLicence set CountLicMacIndirectTarget = 0 
	where isnull(CountLicMacIndirectTarget ,0) <> 0
	and exists (select top 1 1 
					from QBMDBQueueCurrent p 
					where p.uid_parameter = BaseTreeHasLicence.uid_org
					 and p.SlotNumber = @SlotNumber
				)


  update BaseTreeHasLicence set CountLicMacIndirectTarget = zz.CountItems
	from BaseTreeHasLicence join 
	( select yy.uid_org, m.uid_licence, count(*) as CountItems
	    from 
	 (	-- die Arbeitsplätze und ihre Lizenzen bestimmen
		-- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
			select distinct w.uid_WorkDesk, ahl.uid_licence
			from person p join WorkDesk w on p.uid_WorkDesk = w.uid_WorkDesk
					join personhasapp pha on p.uid_person = pha.uid_person
										and pha.XOrigin > 0 and pha.XIsInEffect = 1
					join (-- physische Vorgänger mitnehmen
						select UID_Child, UID_Parent
							 from softwaredependsonsoftware
							where @InheritePhysicalDependencies = 0
						union 
						 select uid_application , uid_application 
							from application
						) as su on su.uid_child = pha.uid_application
					join apphaslicence ahl on su.uid_parent = ahl.uid_application
			where not exists ( select top 1 1 from  WorkDeskhasapp wha 
								join (-- physische Vorgänger mitnehmen
									select UID_Child, UID_Parent
										 from softwaredependsonsoftware
										where @InheritePhysicalDependencies = 0
									union 
									 select uid_application , uid_application 
										from application
									) as su1 on su1.uid_child = wha.uid_application
											and wha.XIsInEffect = 1
											and wha.XOrigin > 0 and wha.XIsInEffect = 1
						where w.uid_WorkDesk = wha.uid_WorkDesk
							and su.uid_parent = su1.uid_parent -- wha.uid_application = pha.uid_application
					)
			-- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
	) as m join 
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
			from @V_LicenceNode_Subnode v join helperWorkDeskorg w on  v.uid_suborg = w.uid_org
			where @primary = 1
		) as ww 
	) as yy on m.uid_WorkDesk = yy.uid_WorkDesk
	group by yy.uid_org, m.uid_licence

   ) as zz on BaseTreeHasLicence.uid_org = zz.uid_org 
		and BaseTreeHasLicence.uid_licence = zz.uid_licence



-- für eine Menge Orgs
 update BaseTreeHasLicence set CountLicUserTarget = 0 
	where isnull(CountLicUserTarget ,0) <> 0
	and exists (select top 1 1 
					from QBMDBQueueCurrent p 
					where p.uid_parameter = BaseTreeHasLicence.uid_org
					 and p.SlotNumber = @SlotNumber
				)


  update BaseTreeHasLicence set CountLicUserTarget = zz.CountItems
	from BaseTreeHasLicence join 
	( select yy.uid_org, m.uid_licence, count(*) as CountItems
	    from 
	 (	-- die Personen und ihre Lizenzen bestimmen
			-- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
			select distinct pha.uid_person, ahl.uid_licence
				from personhasapp pha 
--						join application a on pha.uid_application = a.uid_application
						join (-- physische Vorgänger mitnehmen
							select UID_Child, UID_Parent
								 from softwaredependsonsoftware
								where @InheritePhysicalDependencies = 0
							union 
							 select uid_application , uid_application 
								from application
							) as su on su.uid_child = pha.uid_application
									and pha.XIsInEffect = 1
									and pha.XOrigin > 0 and pha.XIsInEffect = 1
						join apphaslicence ahl on su.uid_parent = ahl.uid_application
			-- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
	) as m join 
	-- die Personen zur Menge der Orgs bestimmen
	(select ww.uid_org , ww.uid_Person
	   from 
		( select distinct v.uid_org, wio.uid_person as uid_Person
			from @V_LicenceNode_Subnode v join PersoninBaseTree wio on v.uid_suborg = wio.uid_org
																	and v.AssignPerson = 1
																	and wio.XOrigin > 0
			where @secondary = 1
		union all -- wichtig, weil sonst mehrfache wegfallen
		 select distinct v.uid_org, w.uid_Person
			from @V_LicenceNode_Subnode v join helperPersonorg w on  v.uid_suborg = w.uid_org
			where @primary = 1
		) as ww 
	) as yy on m.uid_Person = yy.uid_Person
	group by yy.uid_org, m.uid_licence

   ) as zz on BaseTreeHasLicence.uid_org = zz.uid_org 
		and BaseTreeHasLicence.uid_licence = zz.uid_licence



-- für eine Menge Orgs
 update BaseTreeHasLicence set CountLicMacPossTarget = 0 
	where isnull(CountLicMacPossTarget ,0) <> 0
	and exists (select top 1 1 
					from QBMDBQueueCurrent p 
					where p.uid_parameter = BaseTreeHasLicence.uid_org
					 and p.SlotNumber = @SlotNumber
				)

  update BaseTreeHasLicence set CountLicMacPossTarget = zz.CountItems
	from BaseTreeHasLicence join 
	( select yy.uid_org, m.uid_licence, count(*) as CountItems
	    from 
	 (	-- die Personen und ihre Lizenzen bestimmen
			-- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
			select distinct pha.uid_person, ahl.uid_licence
			from personhasapp pha join person p on pha.uid_person = p.uid_person
												and pha.XIsInEffect = 1
												and pha.XOrigin > 0 and pha.XIsInEffect = 1
								and isnull(p.uid_WorkDesk, '') = ''  -- kein Stammpc vorhanden
							join (-- physische Vorgänger mitnehmen
								select UID_Child, UID_Parent
									 from softwaredependsonsoftware
									where @InheritePhysicalDependencies = 0
								union 
								 select uid_application , uid_application 
									from application
								) as su on su.uid_child = pha.uid_application
--					join apphaslicence ahl on su.uid_parent = ahl.uid_application
--	Einwand CK 2005-10-06 hier können auch Treiber nachgezogen werden
					join (select uid_application, uid_licence
							from apphaslicence
						 union
						 select uid_driver, uid_licence
							from driverhaslicence
						) as ahl on su.uid_parent = ahl.uid_application 
--	\ Einwand CK 2005-10-06 hier können auch Treiber nachgezogen werden
			-- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
	) as m join 
	-- die Personen zur Menge der Orgs bestimmen
	(select ww.uid_org , ww.uid_Person
	   from 
		( select distinct v.uid_org, wio.uid_person as uid_Person
			from @V_LicenceNode_Subnode v join PersoninBaseTree wio on v.uid_suborg = wio.uid_org
																	and v.AssignPerson = 1
																	and wio.XOrigin > 0
											and  @secondary = 1
		union all -- wichtig, weil sonst mehrfache wegfallen
		 select distinct v.uid_org, w.uid_Person
			from @V_LicenceNode_Subnode v join helperPersonorg w on v.uid_suborg = w.uid_org
									and @primary = 1
		) as ww 
	) as yy on m.uid_Person = yy.uid_Person
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


