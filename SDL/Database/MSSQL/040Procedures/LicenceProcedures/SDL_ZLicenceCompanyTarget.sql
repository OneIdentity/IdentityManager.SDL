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
-- SDL_ZLicenceCompanyTarget	
----------------------------------------------------------------------------------
	-- errechnet die Target-Werte für das gesamt-Unternehmen
	-- Prozedur hat keine Parameter
	-- Taskname ist LicenceCompanyTarget


exec QBM_PProcedureDrop 'SDL_ZLicenceCompanyTarget'
go

---<summary>Calculates the 'License....' target values for the entire company</summary>
---<param name="dummy">The parameter is unused and has to be an empty string</param>
---<param name="dummy1">The parameter is unused and has to be an empty string</param>
---<param name="GenProcID" type="varchar(38)">Process ID of the source operation</param>
---<remarks></remarks>
---<example>Function exclusively for use in the DBScheduler</example>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-LicenceCompanyTarget'  -- (899990)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-LicenceCompanyTarget'
		, @ProcedureName = 'SDL_ZLicenceCompanyTarget'
		, @IsBulkEnabled = 0
		, @CountParameter = 0
		, @MaxInstance = 1
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate = 'select '' '' '
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = null
		
exec MDK_PDBQueueTaskDependDefine 
		@UID_TaskPredecessor = 'SDL-K-LicenceRECalculate' -- (889990)
		, @UID_TaskFollower = 'SDL-K-LicenceCompanyTarget' -- (899990)
		, @IsPhysicalDependency = 0
	-- delete QBMDBQueueTaskDepend where UID_TaskPredecessor = 'SDL-K-LicenceRECalculate' and UID_TaskFollower = 'SDL-K-LicenceCompanyTarget'
	
*/

create procedure SDL_ZLicenceCompanyTarget 
				( @SlotNumber int
				, @dummy varchar(38)
				, @dummy1 varchar(38)
				, @GenProcIDDummy varchar(38)
				)
as
begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID

declare @InheritePhysicalDependencies bit
declare @Zaehlweise int

-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
declare @GenProcIDForRestore varchar(38)
declare @XUserForRestore nvarchar(64)
declare @OperationLevelForRestore int
declare @GenProcID varchar(38) = newid()
BEGIN TRY

exec @OperationLevelForRestore = QBM_PGenprocidGetFromContext @GenProcIDForRestore output, @XUserForRestore output, @CodeID = @@ProcID

if '1' <> dbo.QBM_FGIConfigparmValue('Software\LicenceManagement')
 begin
	goto ende
 end

select @zaehlweise = dbo.QBM_FCVStringToInt(dbo.QBM_FGIConfigparmValue('Software\LicenceManagement\CountOSLicenceBy'), 0)
if @zaehlweise = 0
 begin
	select @zaehlweise = 1
 end


select @InheritePhysicalDependencies = 0
if dbo.QBM_FGIConfigparmValue('Software\InheritePhysicalDependencies') > ' '
 begin
	select @InheritePhysicalDependencies = 1
 end

--	CountLicMacDirectTarget –  der Sollzustand Zuweisungen an Maschinen laut WorkDeskhas...
-- Berechnung für alles

 exec QBM_PGenprocidSetInContext  @GenProcID, 'DBScheduler', 1
 update Licence set CountLicMacDirectTarget = zz.CountItems
	from Licence join 
   ( select l.uid_licence, isnull(x.CountItems,0) as CountItems
	from licence l left outer join -- left outer, damit auch wirklich alle Lizenzen geliefert werden
	
	( select uid_licence, count(*) as CountItems 
	 from
	 (	-- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
		select h.uid_Hardware, ahl.uid_licence
			from WorkDeskhasapp wha 
					join Hardware h on h.uid_WorkDesk = wha.uid_WorkDesk
							and (h.ispc=1 or h.isServer = 1)
							and wha.XOrigin > 0 and wha.XIsInEffect = 1
					join ( -- physische Vorgänger mitnehmen
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
		select h.uid_Hardware, dhl.uid_licence
			from WorkDeskhasdriver whd 
					join Hardware h on h.uid_WorkDesk = whd.uid_WorkDesk
									and whd.XOrigin > 0 and whd.XIsInEffect = 1
							and (h.ispc=1 or h.isServer = 1)
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
		select h.uid_Hardware, dhl.uid_licence
			from Hardware h join machineHasDriver mhd on h.uid_Hardware = mhd.uid_Hardware
									and (h.ispc=1 or h.isServer = 1)
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
		 union
		--		3) OS auf dem Arbeitsplatz zugewiesen
-- Supportfall RonnyV 2007-01-16 bei Üstra
-- Wunsch: OS des WorkDesk nur dann nehmen, wenn über die Hardware.UID_OS keine Lizenz ermittelbar ist
-- 2008-01-11 Änderung laut Buglist 7869
		select w.uid_WorkDesk, os.uid_licence
			from WorkDesk w join os on w.UID_OS = os.UID_OS
					where @zaehlweise = 1
		union
		--		3a) OS auf dem PC zugewiesen
		select h.uid_Hardware, os.uid_licence
			from Hardware h join os on h.UID_OS = os.UID_OS
						and (h.ispc=1 or h.isServer = 1)
					where @zaehlweise in (2,3) 
		-- \ der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
	) as m 
	group by uid_licence
	) as x on  l.uid_licence = x.uid_licence
    ) as zz on Licence.UID_Licence = zz.uid_licence
 where isnull(CountLicMacDirectTarget,0) <> zz.CountItems


--	CountLicMacIndirectTarget –  der Sollzustand Zuweisungen an Maschinen über StammPC-Beziehungen
exec QBM_PGenprocidSetInContext  @GenProcID, 'DBScheduler', 1
update Licence set CountLicMacIndirectTarget = zz.CountItems
	from Licence join 
	    (  select l.uid_licence, isnull(x.CountItems,0) as CountItems
		from licence l left outer join 
		( select uid_licence, count(*) as CountItems 
		 from
		    (	-- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
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
												and wha.XOrigin > 0 and wha.XIsInEffect = 1
						where w.uid_WorkDesk = wha.uid_WorkDesk
							and su.uid_parent = su1.uid_parent -- wha.uid_application = pha.uid_application
					)
			-- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
		    ) as m 
		group by uid_licence
		) as x on  l.uid_licence = x.uid_licence
	   ) as zz on Licence.uid_licence = zz.uid_licence
  where  isnull(CountLicMacIndirectTarget,0) <> zz.CountItems


--	CountLicUserTarget –  der Sollzustand Zuweisungen an Nutzer über PersonHas...
 exec QBM_PGenprocidSetInContext  @GenProcID, 'DBScheduler', 1
 update Licence set CountLicUserTarget = zz.CountItems
	from Licence join 
	  ( select l.uid_licence, isnull(x.CountItems,0) as CountItems
		from licence l left outer join 
		( select uid_licence, count(*) as CountItems 
		 from
		   (	-- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
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
								and pha.XOrigin > 0 and pha.XIsInEffect = 1
						join apphaslicence ahl on su.uid_parent = ahl.uid_application
			-- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
		    ) as m 
		  group by uid_licence
		) as x on  l.uid_licence = x.uid_licence
	   ) as zz on Licence.uid_licence = zz.uid_licence
  where  isnull(CountLicUserTarget,0) <> zz.CountItems


--	CountLicMacPossTarget – der Sollzustand möglicher Maschinenzuweisungen über Nutzer ohne StammPC, ermittelt über PersonHas
 exec QBM_PGenprocidSetInContext  @GenProcID, 'DBScheduler', 1
 update Licence set CountLicMacPossTarget = zz.CountItems
	from Licence join 
	 ( select l.uid_licence, isnull(x.CountItems,0) as CountItems
		from licence l left outer join 
		( select uid_licence, count(*) as CountItems 
		 from
		  (	-- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
			select distinct pha.uid_person, ahl.uid_licence
			from personhasapp pha join person p on pha.uid_person = p.uid_person
								and isnull(p.uid_WorkDesk, '') = ''  -- kein Stammpc vorhanden
								and pha.XOrigin > 0 and pha.XIsInEffect = 1
--					join application a on pha.uid_application = a.uid_application
					join (-- physische Vorgänger mitnehmen
						select UID_Child, UID_Parent
							 from softwaredependsonsoftware
							where @InheritePhysicalDependencies = 0
						union 
						 select uid_application , uid_application 
							from application
						) as su on su.uid_child = pha.uid_application
								and pha.XIsInEffect = 1
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
		    ) as m 
		  group by uid_licence
		) as x on  l.uid_licence = x.uid_licence
	   ) as zz on Licence.uid_licence = zz.uid_licence
  where  isnull(CountLicMacPossTarget,0) <> zz.CountItems

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

-- Standard-Abspann für Prozeduren, die die GenProciD setzen

ende:
	exec QBM_PGenprocidSetInContext @GenProcIDForRestore, @XUserForRestore, @OperationLevelForRestore
	return

 end
go

