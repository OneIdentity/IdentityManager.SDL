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
   --  ZusatzProzedur SDL_ZSoftwareExclusionDEL
   --------------------------------------------------------------------------------  

exec QBM_PProcedureDrop 'SDL_ZSoftwareExclusionDEL' 
go

-- This procedure is exclusively used in the DBScheduler
---<istoignore/>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-SoftwareExclusionDel'  -- (730780)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-SoftwareExclusionDel'
		, @Operation = 'SOFTWAREEXCLUSIONDEL'
		, @ProcedureName = 'SDL_ZSoftwareExclusionDEL'
		, @IsBulkEnabled = 0
		, @CountParameter = 2
		, @MaxInstance = 1000
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate =  null 
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = null
		
*/
create procedure SDL_ZSoftwareExclusionDEL ( @SlotNumber int
											, @SW1 varchar(38) -- Software1 (kann sein App oder Driver)
											, @SW2 varchar(38) -- Software2 (kann sein App oder Driver, aber genau das selbe wie 1)
											, @GenProcID varchar(38)
											)


 
-- with encryption 
AS
begin

declare @CountItems int,
        @tri varchar(38)
declare @SQLcmd nvarchar(1024)




-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
declare @GenProcIDForRestore varchar(38)
declare @XUserForRestore nvarchar(64)
declare @OperationLevelForRestore int

BEGIN TRY

exec @OperationLevelForRestore = QBM_PGenprocidGetFromContext @GenProcIDForRestore output, @XUserForRestore output, @CodeID = @@ProcID


	exec QBM_PGenprocidSetInContext  @GenProcID, 'DBScheduler', 1

	delete DriverExcludeDriver
		where uid_driver = @SW1
			and UID_DriverExcluded = @SW2

	delete DriverExcludeDriver
		where uid_driver = @SW2
			and UID_DriverExcluded = @SW1

	delete ApplicationExcludeApp
		where uid_Application = @SW1
			and UID_ApplicationExcluded = @SW2

	delete ApplicationExcludeApp
		where uid_Application = @SW2
			and UID_ApplicationExcluded = @SW1

	exec QBM_PDBQueueInsert_Single 'SDL-K-SoftwareExclusion', @sw1, '', @GenProcID
	exec QBM_PDBQueueInsert_Single 'SDL-K-SoftwareExclusion', @sw2, '', @GenProcID


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

