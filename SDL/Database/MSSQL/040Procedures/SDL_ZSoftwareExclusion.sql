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



---------------------------------------------------------------------------
-- Prozedur SDL_ZSoftwareExclusion
---------------------------------------------------------------------------

--Taskname wird softwareExclusion

-- ist DBSchedulerTask
exec QBM_PProcedureDrop 'SDL_ZSoftwareExclusion'
go


-- This procedure is exclusively used in the DBScheduler
---<istoignore/>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-SoftwareExclusion'  -- (740822)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-SoftwareExclusion'
		, @Operation = 'SOFTWAREEXCLUSION'
		, @ProcedureName = 'SDL_ZSoftwareExclusion'
		, @IsBulkEnabled = 0
		, @CountParameter = 1
		, @MaxInstance = 1000
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate =  null 
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = null
		
exec MDK_PDBQueueTaskDependDefine 
		@UID_TaskPredecessor = 'SDL-K-SoftwareExclusionAdd' -- (730778)
		, @UID_TaskFollower = 'SDL-K-SoftwareExclusion' -- (740822)
		, @IsPhysicalDependency = 0
	-- delete QBMDBQueueTaskDepend where UID_TaskPredecessor = 'SDL-K-SoftwareExclusionAdd' and UID_TaskFollower = 'SDL-K-SoftwareExclusion'
	
exec MDK_PDBQueueTaskDependDefine 
		@UID_TaskPredecessor = 'SDL-K-SoftwareExclusionDel' -- (730780)
		, @UID_TaskFollower = 'SDL-K-SoftwareExclusion' -- (740822)
		, @IsPhysicalDependency = 0
	-- delete QBMDBQueueTaskDepend where UID_TaskPredecessor = 'SDL-K-SoftwareExclusionDel' and UID_TaskFollower = 'SDL-K-SoftwareExclusion'
	
*/
create procedure SDL_ZSoftwareExclusion ( @SlotNumber int
										, @SW1 varchar(38)  -- uid_Application oder uid_Driver
										, @dummy2 varchar(38)
										, @GenProcID varchar(38)
					    )
			as
 begin



-- Variablen für job
declare @uid varchar(38)
declare @where nvarchar(1024)



-- hier kommt die Aktion hin, die für alle Profile eine Methode zum aktualisieren
-- der Path.vii aufruft
declare @AdditionalObjectKeysAffected_CSU QBM_YParameterList -- compiler shut up
BEGIN TRY

if exists (select top 1 1 from Application where uid_application = @SW1)
 begin
		select @where = N'uid_application = ''' + rtrim(@SW1) + N''''

		exec QBM_PJobCreate_HOFireEvent 'ApplicationProfile', @where , 'WritePathVII', @GenProcID
							, @ObjectKeysAffected = @AdditionalObjectKeysAffected_CSU
							, @checkForExisting = 1
 end

if exists (select top 1 1 from Driver where uid_Driver = @SW1)
 begin
		select @where = N'uid_Driver = ''' + rtrim(@SW1) + N''''
		--exec Q B M _ P J o b Q u e ue  I n s e r t H O   N ' F I R E G E N E V E N T', N'DriverProfile', @where, N'EventName', N'WritePathVII', 
		--						@Procid = @genprocid, @checkForExisting = 1

		exec QBM_PJobCreate_HOFireEvent 'DriverProfile', @where , 'WritePathVII', @GenProcID
							, @ObjectKeysAffected = @AdditionalObjectKeysAffected_CSU
							, @checkForExisting = 1
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
	                                	        	

ende:
  return

end
go


