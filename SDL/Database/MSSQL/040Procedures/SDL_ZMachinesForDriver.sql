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
   --  Hilfsprozedur SDL_ZMachinesForDriver
   --------------------------------------------------------------------------------  

   -- stellt fr Maschinen, die die Applikation haben  Jobs zum Schreiben der CName ein
-- Prozedur umgestellt auf DB-Scheduler-Aufruf

exec QBM_PProcedureDrop 'SDL_ZMachinesForDriver'
go

-- exec SDL_ZMachinesForDriver N'0e64feb2-2a94-11d6-8174-003005268945'

---<summary>Recalculates driver assignments for all machine accounts with a driver</summary>
---<param name="uid_Driver">UID of driver to be tested</param>
---<param name="GenProcID" type="varchar(38)">Process ID of the source operation</param>
---<remarks>
--- Recalculation task, HardwareUpdateCName, is queued for all accounts found
---</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-AllMachinesForDriver'  -- (730738)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-AllMachinesForDriver'
		, @Operation = 'ALLMACHINESFORDRIVER'
		, @ProcedureName = 'SDL_ZMachinesForDriver'
		, @IsBulkEnabled = 0
		, @CountParameter = 1
		, @MaxInstance = 1000
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate = 'select	uid_driver	from	driver	where	''1''	=	dbo.QBM_FGIConfigparmValue(''Software\Driver'')'
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = null
		
*/

create procedure SDL_ZMachinesForDriver (@SlotNumber int
					, @uid_Driver varchar(38), 
					@dummy varchar(38), -- wird tatsächlich nicht gebraucht
					@GenProcID varchar(38) ) 
 
-- with encryption 
as
 begin
--   declare @tmp varchar(38)
   declare @operation nvarchar(64)
   -- Einfgen in DianlogDBQueue 

  declare @SortOrder int

declare @DBQueueElements QBM_YDBQueueRaw 

BEGIN TRY


		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
		from ( select mhd.uid_Hardware as uid
				from machinehasdriver mhd 
				where uid_driver = @uid_driver
			) as x

		exec QBM_PDBQueueInsert_Bulk 'SDL-K-HardwareUpdateCNAME', @DBQueueElements 


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


