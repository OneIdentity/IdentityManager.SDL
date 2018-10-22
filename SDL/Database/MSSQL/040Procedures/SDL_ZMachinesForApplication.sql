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
   --  Hilfsprozedur SDL_ZMachinesForApplication
   --------------------------------------------------------------------------------  

   -- stellt fr Maschinen, die die Applikation haben  Jobs zum Schreiben der CName ein

-- IR 2005-03-15 ist auf DB-Scheduler-prozedur umgesetzt, wurde bisher aus Trigger gerufen
--	damit kann Configparmtest jetzt auch über temp-Tabelle gehen

exec QBM_PProcedureDrop 'SDL_ZMachinesForApplication'
go

---<summary>Recalculation of group membership for all workstation accounts that have an application</summary>
---<param name="uid_Application">Application UID to examine</param>
---<param name="GenProcID" type="varchar(38)">Process ID of the source operation</param>
---<remarks>
--- Recalculation task MachineHasApp is set for all accounts found 
---</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-AllMachinesForApplication'  -- (730736)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-AllMachinesForApplication'
		, @Operation = 'ALLMACHINESFORAPPLICATION'
		, @ProcedureName = 'SDL_ZMachinesForApplication'
		, @IsBulkEnabled = 0
		, @CountParameter = 1
		, @MaxInstance = 1000
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate = 'select	uid_application	from	application	where	''1''	=	dbo.QBM_FGIConfigparmValue(''Software\Application'')'
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = null
		
*/

create procedure SDL_ZMachinesForApplication (@SlotNumber int
											, @uid_Application varchar(38)
											, @dummy varchar(38) -- wird tatsächlich nicht verwendet
											, @GenProcID varchar(38)
											) 
 
-- with encryption 
as
 begin
   declare @tmp varchar(38)

declare @DBQueueElements QBM_YDBQueueRaw 

BEGIN TRY


				insert into @DBQueueElements (object, subobject, genprocid)
				select x.uid, null, @GenProcID
--				select newid(), @operation, x.uid_Hardware, null, @SortOrder, @GenProcID
				    from (select distinct h.uid_Hardware  as uid
						from Hardware h join  WorkDeskhasapp wha on h.uid_WorkDesk = wha.uid_WorkDesk
								and (h.isPC=1  or h.isServer = 1)
								and wha.uid_application = @uid_application
								and wha.XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
					) as x
				
				exec QBM_PDBQueueInsert_Bulk 'SDL-K-HardwareUpdateCNAME', @DBQueueElements 




 if dbo.QBM_FGIConfigparmValue('TargetSystem\ADS\HardwareInAppGroup') > ' '
  begin

				delete @DBQueueElements 
				
				insert into @DBQueueElements (object, subobject, genprocid)
				select x.uid, null, @GenProcID
				    from (   select distinct m.uid_ADSMachine as uid
						from Hardware h join WorkDeskhasapp wha on h.uid_WorkDesk = wha.uid_WorkDesk
										join ADSMachine m on h.uid_Hardware = m.uid_Hardware
										and wha.uid_application = @uid_application
										and wha.XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
					) as x
				
				exec QBM_PDBQueueInsert_Bulk 'ADS-K-ADSMachineInADSGroup', @DBQueueElements 

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
	                                	        	
end
go
