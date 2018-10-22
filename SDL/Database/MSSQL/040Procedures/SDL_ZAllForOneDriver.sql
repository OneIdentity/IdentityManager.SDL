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
   --  Hilfsprozedur SDL_ZAllForOneDriver
   --------------------------------------------------------------------------------  

   -- stellt für alle Stellen wo die Treiber eine Rolle spielen könnte eine Neuberechnung ein


exec QBM_PProcedureDrop 'SDL_ZAllForOneDriver'
go

---<summary>Sets up recalculation tasks in the DBQueue for a given driver</summary>
---<param name="uid_Driver">UID des Treibers, dessen Zuweisungen zu untersuchen sind</param>
---<param name="dummy">The parameter is unused and has to be an empty string</param>
---<param name="GenProcID" type="varchar(38)">Process ID of the source operation</param>
---<remarks>
--- Following operations are queued
--- - OrgHasDriver
--- - WorkDeskHasDriver
--- - MachineHasDriver
--- for all nodes that are currently assigned or have inhertited the driver
---</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-AllForOneDriver'  -- (740806)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-AllForOneDriver'
		, @Operation = 'ALLFORONEDRIVER'
		, @ProcedureName = 'SDL_ZAllForOneDriver'
		, @IsBulkEnabled = 0
		, @CountParameter = 1
		, @MaxInstance = 1000
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate = 'select	uid_driver	from	Driver'
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = null
		
exec MDK_PDBQueueTaskDependDefine 
		@UID_TaskPredecessor = 'SDL-K-SoftwareDependsPhysical' -- (730776)
		, @UID_TaskFollower = 'SDL-K-AllForOneDriver' -- (740806)
		, @IsPhysicalDependency = 0
	-- delete QBMDBQueueTaskDepend where UID_TaskPredecessor = 'SDL-K-SoftwareDependsPhysical' and UID_TaskFollower = 'SDL-K-AllForOneDriver'
	
*/

create procedure SDL_ZAllForOneDriver (@SlotNumber int
									, @uid_Driver varchar(38)
									, @dummy varchar(38)
									, @GenProcID varchar(38)
									) 

-- with encryption 
as
 begin

declare @MsgTxt nvarchar(1024)
declare @DBQueueElements QBM_YDBQueueRaw 
declare @DebugLevel char(1) = 'W'

BEGIN TRY

-- prüfen, ob das betreffende Objekt noch existiert
  if not exists (select top 1 1 from Driver where uid_Driver = isnull(@uid_Driver,''))
	begin
	  select @MsgTxt = N'Driver ' + rtrim(@uid_Driver) + ' not exists, Job ALLFORONEDRIVER was killed'
	  exec QBM_PJournal @MsgTxt, @@procid, 'D', @DebugLevel
	  return
		-- Rckkehr ohne Fehler, damit der Job gelscht wird
	end



	-- delete @DBQueueElements

	insert into @DBQueueElements (object, subobject, genprocid)
	select x.uid, null, @GenProcID
		from 
		    ( select co.UID_Org as uid
				from BaseTreeHasDriver  bhr join BaseTreeCollection co on bhr.UID_Org = co.UID_ParentOrg
				where bhr.UID_Driver = @uid_Driver
				and XOrigin > 0

		    )	as x 

		exec QBM_PDBQueueInsert_Bulk 'SDL-K-OrgHasDriver', @DBQueueElements 


	delete @DBQueueElements 
	
	insert into @DBQueueElements (object, subobject, genprocid)
	select x.uid, null, @GenProcID
		from 
		    ( select uid_WorkDesk  as uid
				from WorkDeskHasDriver
				where uid_Driver = @uid_Driver
				and XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen

		    )	as x 
	
	exec QBM_PDBQueueInsert_Bulk 'SDL-K-WorkdeskHasDriver', @DBQueueElements 


	delete @DBQueueElements 
	
	insert into @DBQueueElements (object, subobject, genprocid)
	select x.uid, null, @GenProcID
		from 
		    ( select uid_Hardware  as uid
				from MachineHasDriver
				where uid_Driver = @uid_Driver
				and XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen

		    )	as x 
	
	exec QBM_PDBQueueInsert_Bulk 'SDL-K-MACHInEHasDriver', @DBQueueElements 
	

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



