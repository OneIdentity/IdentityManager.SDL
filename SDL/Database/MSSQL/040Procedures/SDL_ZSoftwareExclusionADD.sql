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
   --  ZusatzProzedur SDL_ZSoftwareExclusionADD
   --------------------------------------------------------------------------------  

exec QBM_PProcedureDrop 'SDL_ZSoftwareExclusionADD' 
go

-- This procedure is exclusively used in the DBScheduler
---<istoignore/>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-SoftwareExclusionAdd'  -- (730778)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-SoftwareExclusionAdd'
		, @Operation = 'SOFTWAREEXCLUSIONADD'
		, @ProcedureName = 'SDL_ZSoftwareExclusionADD'
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
create procedure SDL_ZSoftwareExclusionADD (	@SlotNumber int
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


-- bestimmen, was wir haben
if exists (select top 1 1 from application where uid_application = @sw1)
 begin -- dann haben wir App
	exec QBM_PGenprocidSetInContext  @GenProcID, N'DBScheduler', 1
	insert into ApplicationExcludeApp 
		( UID_Application, UID_ApplicationExcluded, XDateInserted, XDateUpdated, XUserInserted, XUserUpdated, XObjectKey)
	select
		@SW2, @sw1, GetUTCDate(), GetUTCDate(), 'DBScheduler', 'DBScheduler', dbo.QBM_FCVElementToObjectKey2('ApplicationExcludeApp', 'UID_Application', @SW2, 'UID_ApplicationExcluded', @sw1)
		where Not exists (select top 1 1 from ApplicationExcludeApp aa
									where aa.uid_application = @Sw2
									and aa.UID_ApplicationExcluded = @sw1
						)

	if @@rowcount > 0
	 begin
		exec QBM_PDBQueueInsert_Single 'SDL-K-SoftwareExclusion', @sw1, '', @GenProcID
		exec QBM_PDBQueueInsert_Single 'SDL-K-SoftwareExclusion', @sw2, '', @GenProcID
	 end

 end


if exists (select top 1 1 from Driver where uid_driver = @sw1)
 begin -- dann haben wir App
	exec QBM_PGenprocidSetInContext  @GenProcID, 'DBScheduler', 1
	insert into DriverExcludeDriver 
		( UID_Driver, UID_DriverExcluded, XDateInserted, XDateUpdated, XUserInserted, XUserUpdated, XObjectKey)
	select
		@SW2, @sw1, GetUTCDate(), GetUTCDate(), 'DBScheduler', 'DBScheduler', dbo.QBM_FCVElementToObjectKey2('DriverExcludeDriver', 'UID_Driver', @SW2, 'UID_DriverExcluded', @SW1)
		where Not exists (select top 1 1 from DriverExcludeDriver aa
									where aa.uid_Driver = @Sw2
									and aa.UID_DriverExcluded = @sw1
						)

	if @@rowcount > 0
	 begin
		exec QBM_PDBQueueInsert_Single 'SDL-K-SoftwareExclusion', @sw1, '', @GenProcID
		exec QBM_PDBQueueInsert_Single 'SDL-K-SoftwareExclusion', @sw2, '', @GenProcID
	 end

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
	                                	        	
-- Standard-Abspann für Prozeduren, die die GenProciD setzen

ende:
	exec QBM_PGenprocidSetInContext @GenProcIDForRestore, @XUserForRestore, @OperationLevelForRestore
	return

 end
go

