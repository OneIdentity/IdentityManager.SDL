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
   --  Hilfsprozedur SDL_ZAllForOneWorkDesk
   --------------------------------------------------------------------------------  

   -- stellt für einen WorkDesk alle Jobs zur Neuberechnung ein
exec QBM_PProcedureDrop 'SDL_ZAllForOneWorkDesk'
go

---<summary>Queues all processes for a WorkDesk in the DBQueue for recalculation</summary>
---<remarks>WorkDesk UIDs are passed in the auxiliary table QBMDBQueueCurrent </remarks>
---<example>Function exclusively for use in the DBScheduler</example>
---<seealso cref="QBM_FGIErrorMessage" type="Function">Function QBM_FGIErrorMessage</seealso>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-AllForOneWorkdesk'  -- (770624)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-AllForOneWorkdesk'
		, @Operation = 'SDL-K-AllForOneWorkdesk'
		, @ProcedureName = 'SDL_ZAllForOneWorkDesk'
		, @IsBulkEnabled = 1
		, @CountParameter = 1
		, @MaxInstance = 1000
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate =  null 
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = 'QER-K-AllForOneWorkdesk'
		
*/


create procedure SDL_ZAllForOneWorkDesk (@SlotNumber int)
 
-- with encryption 
as
 begin
 --  declare @operation nvarchar(64)
 --declare @SortOrder int

declare @DBQueueElements QBM_YDBQueueRaw 

BEGIN TRY



	delete @DBQueueElements
	
	insert into @DBQueueElements (object, subobject, genprocid)
	select x.uid, null, x.GenProcID
--			select newid(), @operation, x.uid, null,  @SortOrder, x.GenProcID
		from 
		    ( select distinct h.uid_Hardware as uid, GenProcID
				from QBMDBQueueCurrent x join Hardware h on x.uid_parameter = h.uid_WorkDesk
														and x.SlotNumber = @SlotNumber
										and (h.ispc=1 or h.isServer = 1)
		    )	as x

	exec QBM_PDBQueueInsert_Bulk 'SDL-K-HardwareUpdateCNAME', @DBQueueElements 




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







