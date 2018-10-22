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
-- SDL_ZLicenceCompanyActual	
----------------------------------------------------------------------------------
	-- errechnet die Actual-Werte für das gesamt-Unternehmen
	-- Prozedur hat keine Parameter
	-- Taskname ist LicenceCompanyActual


exec QBM_PProcedureDrop 'SDL_ZLicenceCompanyActual'
go


---<summary>Calculates the 'License....' actual values for the entire company</summary>
---<param name="dummy">The parameter is unused and has to be an empty string</param>
---<param name="dummy1">The parameter is unused and has to be an empty string</param>
---<param name="GenProcID" type="varchar(38)">Process ID of the source operation</param>
---<remarks></remarks>
---<example>Function exclusively for use in the DBScheduler</example>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-LicenceCompanyActual'  -- (889990)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-LicenceCompanyActual'
		, @ProcedureName = 'SDL_ZLicenceCompanyActual'
		, @IsBulkEnabled = 0
		, @CountParameter = 0
		, @MaxInstance = 1
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate = 'select '' ''  '
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = null
		
*/

create procedure   SDL_ZLicenceCompanyActual 
				( @SlotNumber int
				, @dummy varchar(38) 
				, @dummy1 varchar(38) 
				, @GenProcID varchar(38)
				)
as
begin
--	CountLicMacDirectActual –  der Sollzustand Zuweisungen an Maschinen laut machineappsinfo
-- Berechnung für alles
-- exec QBM_PProcedureNestLevelCheck @@ProcID

-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
declare @GenProcIDForRestore varchar(38)
declare @XUserForRestore nvarchar(64)
declare @OperationLevelForRestore int

BEGIN TRY

exec @OperationLevelForRestore = QBM_PGenprocidGetFromContext @GenProcIDForRestore output, @XUserForRestore output

if '1' <> dbo.QBM_FGIConfigparmValue('Software\LicenceManagement')
 begin
	goto ende
 end

 exec QBM_PGenprocidSetInContext  @GenProcID, 'DBScheduler', 1
 update Licence set CountLicMacDirectActual = zz.CountItems
	from Licence join 
   ( select l.uid_licence, isnull(x.CountItems,0) as CountItems
	from licence l left outer join -- left outer, damit auch wirklich alle Lizenzen geliefert werden
	
	( select uid_licence, count(*) as CountItems 
	 from
	 (	-- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
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
		 union
		--		3) OS auf dem Arbeitsplatz zugewiesen
		select h.uid_Hardware, os.uid_licence
			from Hardware h join os on h.UID_OS = os.UID_OS
		-- \ der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
	) as m 
	group by uid_licence
	) as x on  l.uid_licence = x.uid_licence
    ) as zz on Licence.UID_Licence = zz.uid_licence
 where isnull(CountLicMacDirectActual,0) <> zz.CountItems



--	CountLicMacIndirectActual –  der Istzustand Zuweisungen an Maschinen über StammPC-Beziehungen, xxxAccountAppsInfo und MachineAppsInfo
exec QBM_PGenprocidSetInContext  @GenProcID, 'DBScheduler', 1
update Licence set CountLicMacIndirectActual = zz.CountItems
	from Licence join 
	    (  select l.uid_licence, isnull(x.CountItems,0) as CountItems
		from licence l left outer join 
		( select uid_licence, count(*) as CountItems 
		 from
		    (	-- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
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
		    ) as m 
		group by uid_licence
		) as x on  l.uid_licence = x.uid_licence
	   ) as zz on Licence.uid_licence = zz.uid_licence
  where  isnull(CountLicMacIndirectActual,0) <> zz.CountItems



--	CountLicUserActual –  der Istzustand Zuweisungen an Nutzer über xxxAccountAppsInfo
 exec QBM_PGenprocidSetInContext  @GenProcID, 'DBScheduler', 1
 update Licence set CountLicUserActual = zz.CountItems
	from Licence join 
	  ( select l.uid_licence, isnull(x.CountItems,0) as CountItems
		from licence l left outer join 
		( select uid_licence, count(*) as CountItems 
		 from
		   (	-- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
			select distinct r.uid_Account, ahl.uid_licence
			  from
			(
			select ai.UID_ADSAccount as uid_account, ai.UID_Application , a.UID_HardwareDefaultMachine as uid_Hardware, a.uid_person
				from adsaccountappsinfo ai join ADSAccount a on ai.uid_ADSAccount = a.uid_ADSAccount
										and ai.CurrentlyActive = 1
			) as r join apphaslicence ahl on r.uid_application = ahl.uid_application
						-- StammPC ist hier egal
						--and isnull(r.uid_Hardware, '') <> ''
			-- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
		    ) as m 
		  group by uid_licence
		) as x on  l.uid_licence = x.uid_licence
	   ) as zz on Licence.uid_licence = zz.uid_licence
  where  isnull(CountLicUserActual,0) <> zz.CountItems




--	CountLicMacPossActual – der istzustand möglicher Maschinenzuweisungen über Nutzer ohne StammPC, ermittelt über xxxAccountAppsInfo
 exec QBM_PGenprocidSetInContext  @GenProcID, 'DBScheduler', 1
 update Licence set CountLicMacPossActual = zz.CountItems
	from Licence join 
	 ( select l.uid_licence, isnull(x.CountItems,0) as CountItems
		from licence l left outer join 
		( select uid_licence, count(*) as CountItems 
		 from
		  (	-- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
			select distinct r.uid_account, ahl.uid_licence
			from 
			(
			select ai.UID_ADSAccount as uid_account, ai.UID_Application , a.UID_HardwareDefaultMachine as uid_Hardware, a.uid_person
				from adsaccountappsinfo ai join ADSAccount a on ai.uid_ADSAccount = a.uid_ADSAccount
										and ai.CurrentlyActive = 1
										and isnull(a.UID_HardwareDefaultMachine, '') = ''
			) as r join apphaslicence ahl on r.uid_application = ahl.uid_application
			-- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
		    ) as m 
		  group by uid_licence
		) as x on  l.uid_licence = x.uid_licence
	   ) as zz on Licence.uid_licence = zz.uid_licence
  where  isnull(CountLicMacPossActual,0) <> zz.CountItems

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
