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



exec QBM_PProcedureDrop 'SDL_ZAppContainerDelete'
go

-- loescht alle Applikationsgruppen in einem angegebenen ADS-Container

---<summary>Deletes all application groups in a given AD container</summary>
---<param name="uid_adscontainer">UID of container to handle</param>
---<param name="SubObject">Parameter stays empty</param>
---<param name="GenProcID" type="varchar(38)">Process ID of the source operation</param>
---<remarks></remarks>
---<example>Function exclusively for use in the DBScheduler</example>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-AppContainerDelete'  -- (730742)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-AppContainerDelete'
		, @Operation = 'APPCONTAINERDELETE'
		, @ProcedureName = 'SDL_ZAppContainerDelete'
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
		
*/

create procedure SDL_ZAppContainerDelete ( @SlotNumber int
										, @uid_adscontainer varchar(38)
										, @SubObject varchar(38)
										, @GenProcID varchar(38)
										) 
 
-- with encryption 
as
 begin
  declare @uid_adsgroup varchar(38)
  declare @where nvarchar(max)

declare @MsgTxt nvarchar(1024)
declare @BasisObjectKey varchar(138)

-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
declare @GenProcIDForRestore varchar(38)
declare @XUserForRestore nvarchar(64)
declare @OperationLevelForRestore int

declare @DBQueueElements QBM_YDBQueueRaw 
declare @DebugLevel char(1) = 'W'
declare @AdditionalObjectKeysAffected_CSU QBM_YParameterList -- compiler shut up
BEGIN TRY

exec @OperationLevelForRestore = QBM_PGenprocidGetFromContext @GenProcIDForRestore output, @XUserForRestore output, @CodeID = @@ProcID


-- prfen, ob das betreffende Objekt noch existiert
  if not exists (select top 1 1 from ADSContainer where uid_ADSContainer = isnull(@uid_ADSContainer,''))
	begin
	  select @MsgTxt = N'ADSContainer ' + rtrim(@uid_ADSContainer) + ' not exists, Job APPCONTAINERDELETE was killed'
	  exec QBM_PJournal @MsgTxt, @@procid, 'D', @DebugLevel
	  goto ende
		-- Rckkehr ohne Fehler, damit der Job gelscht wird
	end



  DECLARE schrittAppContainerDelete CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
   select rtrim(uid_adsgroup) from adsgroup where uid_adscontainer = @uid_adscontainer and IsApplicationGroup = 1
   
  OPEN schrittAppContainerDelete
	
  FETCH NEXT FROM schrittAppContainerDelete into @uid_adsgroup

  WHILE (@@fetch_status <> -1)
  BEGIN

-- 13678 für die betroffenen Nutzer Mitgliedschaften neu rechnen
	delete @DBQueueElements
	
	insert into @DBQueueElements (object, subobject, genprocid)
	select x.uid, null, @GenProcID
    from ( select uid_ADSAccount as uid
			from adsaccountinADSgroup
			where uid_ADSGroup = @uid_ADSGroup
			and XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
		) as x 
	
	exec QBM_PDBQueueInsert_Bulk 'SDL-K-ADSAccountInADSGroup', @DBQueueElements 
-- / 13678 

--	delete adsgroup where uid_adsgroup = @uid_adsgroup
	if @GenprocID = 'SIMULATION'
		begin
			exec QBM_PGenprocidSetInContext  'SIMULATION', N'DBScheduler', 1 
			delete adsgroup where uid_adsgroup = @uid_adsgroup
		end
	else -- if @GenprocID = N'SIMULATION'
		begin

			select @where = ' uid_adsGroup = ''' + @uid_adsgroup + N''''	
			select @BasisObjectKey = dbo.QBM_FCVElementToObjectKey1('ADSGROUP', 'uid_adsGroup', @uid_adsgroup)

			exec QBM_PJobCreate_HODelete 'ADSGROUP', @where, @GenProcID
				, @ObjectKeysAffected = @AdditionalObjectKeysAffected_CSU
				, @BasisObjectKey = @BasisObjectKey
		end -- else if @GenprocID = N'SIMULATION'

 -- testweise
--	delete adsgroup where uid_adsgroup = @uid_adsgroup

     FETCH NEXT FROM schrittAppContainerDelete into @uid_adsgroup

  END

  close schrittAppContainerDelete
  deallocate schrittAppContainerDelete

END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'schrittAppContainerDelete'  
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	
-- Standard-Abspann für Prozeduren, die die GenProciD setzen

ende:
	exec QBM_PGenprocidSetInContext @GenProcIDForRestore, @XUserForRestore, @OperationLevelForRestore
	return

 end
go

