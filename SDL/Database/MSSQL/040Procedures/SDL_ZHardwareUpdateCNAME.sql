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
   --  ZusatzProzedur SDL_ZHardwareUpdateCNAME
   --------------------------------------------------------------------------------  

exec QBM_PProcedureDrop 'SDL_ZHardwareUpdateCNAME' 
go


-- veranlaßt via job das Schreiben einer neuen CNAME.VII

-- This procedure is exclusively used in the DBScheduler
---<istoignore/>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-HardwareUpdateCNAME'  -- (740808)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-HardwareUpdateCNAME'
		, @Operation = 'HardwareUPDATECNAME'
		, @ProcedureName = 'SDL_ZHardwareUpdateCNAME'
		, @IsBulkEnabled = 1
		, @CountParameter = 1
		, @MaxInstance = 1000
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate = 'select	uid_Hardware	from	Hardware	where	(ispc=1	or	isServer	=	1)'
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = null
		
exec MDK_PDBQueueTaskDependDefine 
		@UID_TaskPredecessor = 'SDL-K-AllMachinesForApplication' -- (730736)
		, @UID_TaskFollower = 'SDL-K-HardwareUpdateCNAME' -- (740808)
		, @IsPhysicalDependency = 0
	-- delete QBMDBQueueTaskDepend where UID_TaskPredecessor = 'SDL-K-AllMachinesForApplication' and UID_TaskFollower = 'SDL-K-HardwareUpdateCNAME'
	
exec MDK_PDBQueueTaskDependDefine 
		@UID_TaskPredecessor = 'SDL-K-AllMachinesForDriver' -- (730738)
		, @UID_TaskFollower = 'SDL-K-HardwareUpdateCNAME' -- (740808)
		, @IsPhysicalDependency = 0
	-- delete QBMDBQueueTaskDepend where UID_TaskPredecessor = 'SDL-K-AllMachinesForDriver' and UID_TaskFollower = 'SDL-K-HardwareUpdateCNAME'
	
*/

create procedure SDL_ZHardwareUpdateCNAME (@SlotNumber int)
-- with encryption 
AS
begin
 declare @whereklausel nvarchar(255)
declare @SQLcmd nvarchar(1024)
declare @uid_HardwareErsatz varchar(38)
declare @GenProcID varchar(38)
declare @BasisObjectKey varchar(138)

-- prfen, ob das betreffende Objekt noch existiert

-- prfen, ob das betreffende Objekt noch existiert
-- prfen, ob das Hardware-Objekt nicht gelscht ist
-- wegen Buglist 7351

-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
declare @GenProcIDForRestore varchar(38)
declare @XUserForRestore nvarchar(64)
declare @OperationLevelForRestore int
declare @AdditionalObjectKeysAffected_CSU QBM_YParameterList -- compiler shut up
BEGIN TRY

exec @OperationLevelForRestore = QBM_PGenprocidGetFromContext @GenProcIDForRestore output, @XUserForRestore output, @CodeID = @@ProcID



-- prüfen ob das betroffene Objekt noch existiert, nötigenfalls Operation löschen
	update QBMDBQueueCurrent
			set Slotnumber = 0
			from QBMDBQueueCurrent cu join dbo.QBM_FTDBQueueEntriesForSlot(@SlotNumber) cul on cu.UID_DialogDBQueue = cul.UID_DialogDBQueue	
				left outer join Hardware on uid_parameter = uid_Hardware  
					where ( uid_Hardware is null
								or XMarkedForDeletion & dbo.QBM_FGIBitPatternXMarkedForDel('|Delay|', 0) > 0
						)



 -- Ergnzung and isvipc=1
 -- wegen Buglist 5004
   declare schrittweiseHardwareUpdateCname CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
	select uid_parameter, GenprocID  
		from QBMDBQueueCurrent p
		where p.SlotNumber = @SlotNumber
        
	OPEN schrittweiseHardwareUpdateCname
	FETCH NEXT FROM schrittweiseHardwareUpdateCname into @uid_HardwareErsatz, @GenProcID
	WHILE (@@fetch_status <> -1)
	BEGIN

-- wegen Buglist 11085
		exec QBM_PGenprocidSetInContext  @GenProcID, 'DBScheduler', 1
		update Hardware set UpdateCName = 0
				where UID_Hardware = @uid_HardwareErsatz
					and UpdateCName = 1

	     select @whereklausel =  N'uid_Hardware = '''+rtrim(@uid_HardwareErsatz)+N''' and isvipc=1 '     
	     select @BasisObjectKey = dbo.QBM_FCVElementToObjectKey1('Hardware', 'uid_Hardware', @uid_HardwareErsatz)
		--16592
		if exists (select top 1 1 
					from dialogcolumn
					where UID_DialogTable = 'QER-T-Hardware'
						and ColumnName = 'UpdateCName'
						and IsDeactivatedByPreProcessor = 0
					)
		 begin

			exec QBM_PJobCreate_HOUpdate 'Hardware', @whereklausel, @GenProcID
							, @ObjectKeysAffected = @AdditionalObjectKeysAffected_CSU
							, @p1 = 'UpdateCName', @v1 = 'True'  
							, @isToFreezeOnError  = 0
							, @BasisObjectKey = @BasisObjectKey

		 end
		-- / 16592


	     FETCH NEXT FROM schrittweiseHardwareUpdateCname INTO @uid_HardwareErsatz, @GenProcID
	END
        close schrittweiseHardwareUpdateCname
	deallocate schrittweiseHardwareUpdateCname


END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'schrittweiseHardwareUpdateCname'  
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	
-- Standard-Abspann für Prozeduren, die die GenProciD setzen

ende:
	exec QBM_PGenprocidSetInContext @GenProcIDForRestore, @XUserForRestore, @OperationLevelForRestore
	return

 end
go

