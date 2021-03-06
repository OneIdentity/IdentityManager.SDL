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



----------------------------------------------------------------------------------------------
-- Prozeduren für Anlegen und Löschen von Applikationsgruppen 
-------------------------------------------------------------------------------------------------


exec QBM_PProcedureDrop 'SDL_ZLDPAppContainerInsert'
go

-- legt in einem angegebenen LDAPContainer Applikationsgruppen für alle Applikationen an 
-- für die noch keine Applikationsgruppe in diesem Container existiert
-- jedoch nur die Applikationen, die Profilapplikationen sind

---<summary>Adds an application container in the LDAP</summary>
---<param name="uid_LDAPcontainer">UID of container to which the groups are added</param>
---<param name="SubObject">Parameter stays empty</param>
---<param name="GenProcID" type="varchar(38)">Process ID of the source operation</param>
---<remarks>
--- Adds application groups in a given LDAP container for all applications  
--- that do not have an applicaiton group in this container
--- This is only applications that are profile applications
---</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-LDAPAppContainerInsert'  -- (730762)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-LDAPAppContainerInsert'
		, @Operation = 'LDAPAPPCONTAINERINSERT'
		, @ProcedureName = 'SDL_ZLDPAppContainerInsert'
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
create procedure SDL_ZLDPAppContainerInsert ( @SlotNumber int
											, @uid_LDAPcontainer varchar(38)
											, @SubObject varchar(38)
											, @GenProcID varchar(38)
											) 
 
-- with encryption 
as
 begin


  DECLARE @uid_application varchar(38)
  declare @Ident_SectionName nvarchar(255)

declare @SQLcmd nvarchar(1024)

-- IR 2003-03-06 Wegen Buglist 6390
declare @domain nvarchar(64)

-- prfen, ob das betreffende Objekt noch existiert
-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
declare @GenProcIDForRestore varchar(38)
declare @XUserForRestore nvarchar(64)
declare @OperationLevelForRestore int
declare @DebugLevel char(1) = 'W'

BEGIN TRY

exec @OperationLevelForRestore = QBM_PGenprocidGetFromContext @GenProcIDForRestore output, @XUserForRestore output, @CodeID = @@ProcID


  if not exists (select top 1 1 from LDAPContainer where uid_LDAPContainer = isnull(@uid_LDAPContainer,''))
	begin
	  select @SQLcmd = N'LDAPContainer ' + rtrim(@uid_LDAPContainer) + ' not exists, Job LDAPAPPCONTAINERINSERT was killed'
	  exec QBM_PJournal @SQLcmd, @@procid, 'D', @DebugLevel
	  goto ende
		-- Rckkehr ohne Fehler, damit der Job gelscht wird
	end

-- IR 2003-03-06 Wegen Buglist 6390
	select  top 1  @domain = d.ident_Domain 
		from LDAPContainer c join ldpdomain d on c.uid_ldpdomain = d.uid_ldpdomain
			where uid_LDAPContainer = @uid_LDAPContainer

  DECLARE schrittAppContainerInsert CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
   select uid_application, Ident_SectionName 
		from application 
		where Not exists (select top 1 1 from LDAPgroup 
								where uid_LDAPcontainer = @uid_LDAPcontainer 
								and IsApplicationGroup = 1 
								and cn = dbo.SDL_FCVADSCommonName(application.Ident_SectionName)
						)
		and application.isprofileapplication = 1
   
  OPEN schrittAppContainerInsert
	
  FETCH NEXT FROM schrittAppContainerInsert into @uid_application, @Ident_SectionName

  WHILE (@@fetch_status <> -1)
  BEGIN

-- IR 2003-03-06 Wegen Buglist 6390
 --Diese Prozedur braucht die GenProcID in der Umgebung, da sie auch aus Jobs gerufen wird
	-- context setzen
	exec QBM_PGenprocidSetInContext  @GenProcID, 'DBScheduler', 1 

	exec SDL_PDistributeAppgroup  @Ident_SectionName , @domain, @Ident_SectionName

     FETCH NEXT FROM schrittAppContainerInsert into @uid_application, @Ident_SectionName

  END

  close schrittAppContainerInsert
  deallocate schrittAppContainerInsert

END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'schrittAppContainerInsert'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	
-- Standard-Abspann für Prozeduren, die die GenProciD setzen

ende:
	exec QBM_PGenprocidSetInContext @GenProcIDForRestore, @XUserForRestore, @OperationLevelForRestore
	return

 end
go

