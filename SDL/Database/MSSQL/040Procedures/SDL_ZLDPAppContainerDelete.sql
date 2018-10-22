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



exec QBM_PProcedureDrop 'SDL_ZLDPAppContainerDelete'
go

-- loescht alle Applikationsgruppen in einem angegebenen LDAP-Container

---<summary>Deletes all application groups in an given LDAP container</summary>
---<param name="uid_LDAPcontainer">UID of container to be handled</param>
---<param name="SubObject">Parameter stays empty</param>
---<param name="GenProcID" type="varchar(38)">Process ID of the source operation</param>
---<remarks></remarks>
---<example>Function exclusively for use in the DBScheduler</example>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-LDAPAppContainerDelete'  -- (730760)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-LDAPAppContainerDelete'
		, @Operation = 'LDAPAPPCONTAINERDELETE'
		, @ProcedureName = 'SDL_ZLDPAppContainerDelete'
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
create procedure SDL_ZLDPAppContainerDelete ( @SlotNumber int
											, @uid_LDAPcontainer varchar(38)
											, @SubObject varchar(38)
											, @GenProcID varchar(38)
											) 
 
-- with encryption 
as
 begin
  declare @uid_LDAPgroup varchar(38)
  declare @where nvarchar(1024)

declare @SQLcmd nvarchar(1024)
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
  if not exists (select top 1 1 from LDAPContainer where uid_LDAPContainer = isnull(@uid_LDAPContainer,''))
	begin
	  select @SQLcmd = N'LDAPContainer ' + rtrim(@uid_LDAPContainer) + ' not exists, Job LDAPAPPCONTAINERDELETE was killed'
	  exec QBM_PJournal  @SQLcmd, @@procid, 'D', @DebugLevel
	  goto ende
		-- Rckkehr ohne Fehler, damit der Job gelscht wird
	end



  DECLARE schrittAppContainerDelete CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
   select rtrim(uid_LDAPgroup) from LDAPgroup where uid_LDAPcontainer = @uid_LDAPcontainer and IsApplicationGroup = 1
   
  OPEN schrittAppContainerDelete
	
  FETCH NEXT FROM schrittAppContainerDelete into @uid_LDAPgroup

  WHILE (@@fetch_status <> -1)
  BEGIN

-- 13678 für die betroffenen Nutzer Mitgliedschaften neu rechnen
	delete  @DBQueueElements 
	
	insert into @DBQueueElements (object, subobject, genprocid)
	select x.uid, null, @GenProcID
    from ( select uid_LDAPAccount as uid
			from LDAPaccountinLDAPgroup
			where uid_LDAPGroup = @uid_LDAPGroup
			and XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
		) as x 
	
	exec QBM_PDBQueueInsert_Bulk 'SDL-K-LDAPAccountInLDAPGroup', @DBQueueElements 
-- / 13678 

	if @GenprocID = 'SIMULATION'
		begin
			exec QBM_PGenprocidSetInContext  'SIMULATION', 'DBScheduler', 1 
			delete LDAPgroup where uid_LDAPgroup = @uid_LDAPgroup
		end
	else -- if @GenprocID = 'SIMULATION'
		begin
--	delete LDAPgroup where uid_LDAPgroup = @uid_LDAPgroup
		select @where = ' uid_LDAPGroup = ''' + @uid_LDAPgroup + N''''	
		select @BasisObjectKey = dbo.QBM_FCVElementToObjectKey1('LDAPGROUP', 'uid_LDAPGroup', @uid_LDAPgroup)

		exec QBM_PJobCreate_HODelete 'LDAPGROUP', @where, @GenProcID
									, @ObjectKeysAffected = @AdditionalObjectKeysAffected_CSU
									, @BasisObjectKey = @BasisObjectKey

 -- testweise
--	delete LDAPgroup where uid_LDAPgroup = @uid_LDAPgroup
		end -- else if @GenprocID = N'SIMULATION'

     FETCH NEXT FROM schrittAppContainerDelete into @uid_LDAPgroup

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

