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
-- SDL_ZLicenceOrgActual	
----------------------------------------------------------------------------------
	-- errechnet die Actual-Werte für einen Teilbaum (IsLicenceNode = 1)
	-- Prozedur hat als Parameter die uid_org, für deren teilbaum die Berechnung stattfinden soll
	-- Taskname ist LicenceOrgActual


exec QBM_PProcedureDrop 'SDL_ZLicenceOrgActual'
go

---<summary>Calculates the actual values for a partial tree</summary>
---<remarks>The org UID (partial tree roots) are passed in the auxiliary table QBMDBQueueCurrent</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-LicenceOrgActual'  -- (889990)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-LicenceOrgActual'
		, @ProcedureName = 'SDL_ZLicenceOrgActual'
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
		
*/

create procedure SDL_ZLicenceOrgActual (@SlotNumber int)
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


   	-- Werte müssen geliefert werden für alle Orgknoten und alle Lizenzen
	-- da das nicht der Fall ist, wird vorher auf 0 zurücksgesetzt
 update BaseTreeHasLicence set CountLicMacDirectActual = 0 
	where isnull(CountLicMacDirectActual ,0) <> 0
	and exists (select top 1 1 
					from QBMDBQueueCurrent p 
					where p.uid_parameter = BaseTreeHasLicence.uid_org
					and p.SlotNumber = @SlotNumber
				)


-- Lizenzen Ohne Betriebssystem
  update BaseTreeHasLicence set CountLicMacDirectActual = zz.CountItems
	from BaseTreeHasLicence join 
	( select yy.uid_org, m.uid_licence, count(*) as CountItems
	    from 
	 (	-- die Arbeitsplätze und ihre Lizenzen bestimmen
		-- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
		select mai.uid_Hardware, ahl.uid_licence
			from MachineAppsInfo mai 
					join apphaslicence ahl on mai.uid_application = ahl.uid_application
								and mai.AppsNotDriver = 1
								and mai.CurrentlyActive = 1
		 union
		--		2) Treiber an Maschinen zugewiesen
		select mai.uid_Hardware, dhl.uid_licence
			from MachineAppsInfo mai 
					join driverhaslicence dhl on mai.uid_driver = dhl.uid_driver
								and isnull(mai.AppsNotDriver,0) = 0
								and mai.CurrentlyActive = 1
		-- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
	) as m join Hardware h on m.uid_Hardware = h.uid_Hardware
		join
	-- die Arbeitsplätze zur Menge der Orgs bestimmen
		( select distinct v.uid_org, wio.uid_WorkDesk as uid_WorkDesk
			from @V_LicenceNode_Subnode v join WorkDeskinBaseTree wio on v.uid_suborg = wio.uid_org
																	and v.AssignWorkDesk = 1
																	and wio.XOrigin > 0
			where @secondary = 1
		union all -- wichtig, weil sonst mehrfache wegfallen
		 select distinct v.uid_org, w.uid_WorkDesk
			from @V_LicenceNode_Subnode v join helperWorkDeskorg w on v.uid_suborg = w.uid_org
			where @primary = 1
	) as yy on h.uid_WorkDesk = yy.uid_WorkDesk
	group by yy.uid_org, m.uid_licence

   ) as zz on BaseTreeHasLicence.uid_org = zz.uid_org 
		and BaseTreeHasLicence.uid_licence = zz.uid_licence

-- Sonderlocke Betriebssysteme
if @zaehlweise in (1,2) -- WorkDeskzuordnungen sammeln
 begin
  update BaseTreeHasLicence set CountLicMacDirectActual = CountLicMacDirectActual + zz.CountItems
	from BaseTreeHasLicence join 
	( select yy.uid_org, m.uid_licence, count(*) as CountItems
	    from 
	 (	
		--		3) OS auf dem Arbeitsplatz zugewiesen
		select h.uid_Hardware, os.uid_licence
			from Hardware h join os on h.UID_OS = os.UID_OS
		-- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
	) as m join Hardware h on m.uid_Hardware = h.uid_Hardware
		join
	-- die Arbeitsplätze zur Menge der Orgs bestimmen
		( select distinct v.uid_org, wio.uid_WorkDesk as uid_WorkDesk
			from @V_LicenceNode_Subnode v join WorkDeskinBaseTree wio on v.uid_suborg = wio.uid_org
																	and v.AssignWorkDesk = 1
																	and wio.XOrigin > 0
			where @secondary = 1
		union all -- wichtig, weil sonst mehrfache wegfallen
		 select distinct v.uid_org, w.uid_WorkDesk
			from @V_LicenceNode_Subnode v join helperWorkDeskorg w on v.uid_suborg = w.uid_org
			where @primary = 1
	) as yy on h.uid_WorkDesk = yy.uid_WorkDesk
	group by yy.uid_org, m.uid_licence

   ) as zz on BaseTreeHasLicence.uid_org = zz.uid_org 
		and BaseTreeHasLicence.uid_licence = zz.uid_licence
 end -- if @zaehlweise in (1,2) -- WorkDeskzuordnungen sammeln

if @zaehlweise = 3 -- Hardwarezuordnungen sammeln
 begin
  update BaseTreeHasLicence set CountLicMacDirectActual = zz.CountItems
	from BaseTreeHasLicence join 
	( select yy.uid_org, m.uid_licence, count(*) as CountItems
	    from 
	 (	
		select h.uid_Hardware, os.uid_licence
			from Hardware h join os on h.UID_OS = os.UID_OS
		-- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
	) as m 
		join
	-- die Hardware zur Menge der Orgs bestimmen
		( 
		select distinct v.uid_org, hio.uid_Hardware
			from @V_LicenceNode_Subnode v join HardwareinBaseTree hio on v.uid_suborg = hio.uid_org
																		and hio.XOrigin > 0
																		and v.AssignHardware = 1
			where @secondary = 1
		union all -- wichtig, weil sonst mehrfache wegfallen
		 select distinct v.uid_org, h.uid_Hardware
			from @V_LicenceNode_Subnode v join helperHardwareorg h on v.uid_suborg = h.uid_org
			where @primary = 1
	) as yy on m.uid_Hardware = yy.uid_Hardware
	group by yy.uid_org, m.uid_licence

   ) as zz on BaseTreeHasLicence.uid_org = zz.uid_org 
		and BaseTreeHasLicence.uid_licence = zz.uid_licence

 end -- if @zaehlweise = 3 -- Hardwarezuordnungen sammeln






-- für eine Menge Orgs

 update BaseTreeHasLicence set CountLicMacIndirectActual = 0 
	where isnull(CountLicMacIndirectActual ,0) <> 0
	and exists (select top 1 1 
					from QBMDBQueueCurrent p 
					where p.uid_parameter = BaseTreeHasLicence.uid_org
					and p.SlotNumber = @SlotNumber
				)


  update BaseTreeHasLicence set CountLicMacIndirectActual = zz.CountItems
	from BaseTreeHasLicence join 
	( select yy.uid_org, m.uid_licence, count(*) as CountItems
	    from 
	 (	-- die Arbeitsplätze und ihre Lizenzen bestimmen
		-- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
			select distinct r.uid_Hardware, ahl.uid_licence
			  from
			(
			select ai.UID_ADSAccount as uid_account, ai.UID_Application , a.UID_HardwareDefaultMachine as uid_Hardware, a.uid_person
				from adsaccountappsinfo ai join ADSAccount a on ai.uid_ADSAccount = a.uid_ADSAccount
										and ai.CurrentlyActive = 1
			) as r join apphaslicence ahl on r.uid_application = ahl.uid_application
						-- StammPC muß da sein
						and r.uid_Hardware > ' '
			where not exists ( select top 1 1 from  MachineAppsInfo mai 
						where mai.uid_Hardware = r.uid_Hardware
							and r.uid_application = mai.uid_application
							and mai.CurrentlyActive = 1
					)
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



-- für eine Menge Orgs
 update BaseTreeHasLicence set CountLicUserActual = 0 
	where isnull(CountLicUserActual ,0) <> 0
	and exists (select top 1 1 
					from QBMDBQueueCurrent p 
					where p.uid_parameter = BaseTreeHasLicence.uid_org
					 and p.SlotNumber = @SlotNumber
				)


  update BaseTreeHasLicence set CountLicUserActual = zz.CountItems
	from BaseTreeHasLicence join 
	( select yy.uid_org, m.uid_licence, count(*) as CountItems
	    from 
	 (	-- die Personen und ihre Lizenzen bestimmen
			-- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
			select distinct r.uid_Account, ahl.uid_licence, r.uid_person
			  from
			(
			select ai.UID_ADSAccount as uid_account, ai.UID_Application , a.UID_HardwareDefaultMachine as uid_Hardware, a.uid_person
				from adsaccountappsinfo ai join ADSAccount a on ai.uid_ADSAccount = a.uid_ADSAccount
										and ai.CurrentlyActive = 1
			) as r join apphaslicence ahl on r.uid_application = ahl.uid_application
						-- StammPC ist hier egal
						--and isnull(r.uid_Hardware, '') <> ''
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
			from @V_LicenceNode_Subnode v join helperPersonOrg w on v.uid_suborg = w.uid_org
			where @primary = 1
		) as ww 
	) as yy on m.uid_Person = yy.uid_Person
	group by yy.uid_org, m.uid_licence

   ) as zz on BaseTreeHasLicence.uid_org = zz.uid_org 
		and BaseTreeHasLicence.uid_licence = zz.uid_licence



-- für eine Menge Orgs
 update BaseTreeHasLicence set CountLicMacPossActual = 0 
	where isnull(CountLicMacPossActual ,0) <> 0
	and exists (select top 1 1 
					from QBMDBQueueCurrent p 
					where p.uid_parameter = BaseTreeHasLicence.uid_org
					 and p.SlotNumber = @SlotNumber
				)

  update BaseTreeHasLicence set CountLicMacPossActual = zz.CountItems
	from BaseTreeHasLicence join 
	( select yy.uid_org, m.uid_licence, count(*) as CountItems
	    from 
	 (	-- die Personen und ihre Lizenzen bestimmen
			-- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
			select distinct r.uid_account, ahl.uid_licence, r.uid_person
			from 
			(
			select ai.UID_ADSAccount as uid_account, ai.UID_Application , a.UID_HardwareDefaultMachine as uid_Hardware, a.uid_person
				from adsaccountappsinfo ai join ADSAccount a on ai.uid_ADSAccount = a.uid_ADSAccount
										and ai.CurrentlyActive = 1
										and isnull(a.UID_HardwareDefaultMachine, '') = ''
			) as r join apphaslicence ahl on r.uid_application = ahl.uid_application
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


