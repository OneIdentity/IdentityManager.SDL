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


-- einstellen der Recalc-Einträge für Lizenzberechnung
-- Especially required due to config parm switchingn

exec QBM_PProcedureDrop 'SDL_ZLicenceRecalculate'
go

---<summary>Queues all recalculation entries for calculating licenses</summary>
---<param name="dummy">The parameter is unused and has to be an empty string</param>
---<param name="dummy1">The parameter is unused and has to be an empty string</param>
---<param name="GenProcID" type="varchar(38)">Process ID of the source operation</param>
---<remarks>
---Especially required due to config parm switching
---</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-LicenceRECalculate'  -- (810626)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-LicenceRECalculate'
		, @Operation = 'LICENCERECALCULATE'
		, @ProcedureName = 'SDL_ZLicenceRecalculate'
		, @IsBulkEnabled = 0
		, @CountParameter = 0
		, @MaxInstance = 1
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate =  'select '' '' '
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = null
		
exec MDK_PDBQueueTaskDependDefine 
		@UID_TaskPredecessor = 'SDL-K-LicenceRECalculate' -- (810626)
		, @UID_TaskFollower = 'SDL-K-LicenceCompanyTarget' -- (810626)
		, @IsPhysicalDependency = 0
	-- delete QBMDBQueueTaskDepend where UID_TaskPredecessor = 'SDL-K-LicenceRECalculate' and UID_TaskFollower = 'SDL-K-LicenceCompanyTarget'
	
exec MDK_PDBQueueTaskDependDefine 
		@UID_TaskPredecessor = 'SDL-K-LicenceRECalculate' -- (810626)
		, @UID_TaskFollower = 'SDL-K-LicenceOrgTarget' -- (810626)
		, @IsPhysicalDependency = 0
	-- delete QBMDBQueueTaskDepend where UID_TaskPredecessor = 'SDL-K-LicenceRECalculate' and UID_TaskFollower = 'SDL-K-LicenceOrgTarget'
	
*/

create procedure SDL_ZLicenceRecalculate 				
				( @SlotNumber int
				, @dummy varchar(38)
				, @dummy1 varchar(38) 
				, @GenProcIDDummy varchar(38) 
				)
as
 begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID
declare @GenProcID varchar(38) = newid()
BEGIN TRY

   exec QBM_PDBQueueInsert_Single 'QBM-K-CommonReCalculate', 'SDL-K-LicenceCompanyTarget', '', @GenProcID
   exec QBM_PDBQueueInsert_Single 'QBM-K-CommonReCalculate', 'SDL-K-LicenceOrgTarget', '', @GenProcID	
   exec QBM_PDBQueueInsert_Single 'QBM-K-CommonReCalculate', 'SDL-K-LicenceCompanyActual', '', @GenProcID
   exec QBM_PDBQueueInsert_Single 'QBM-K-CommonReCalculate', 'SDL-K-LicenceOrgActual', '', @GenProcID
   exec QBM_PDBQueueInsert_Single 'QBM-K-CommonReCalculate', 'SDL-K-LicenceCompanyReal', '', @GenProcID
   exec QBM_PDBQueueInsert_Single 'QBM-K-CommonReCalculate', 'SDL-K-LicenceOrgReal', '', @GenProcID

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

