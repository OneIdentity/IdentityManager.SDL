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
   -- ZusatzProzedur SDL_ZLDPAccountInAppGroup
   -- diese Prozudur regelt den Backsync, wenn im Namespace Gruppenmitgliedschaften in
   -- Applikationsgruppen gefunden werden, so werden diese nicht direkt in LDAPAccountInLDAPGroup
   -- eingetragen, sondern auf PersonHasApp abgebildet.
   --------------------------------------------------------------------------------  

exec QBM_PProcedureDrop 'SDL_PLDPAccountInAppGroup' 
go


-- This procedure is exclusively used in the DBScheduler
---<istoignore/>

create procedure SDL_PLDPAccountInAppGroup (
														 @UID_LDAPAccount varchar(38),
														 @UID_LDAPGroup varchar(38)
														 , @GenProcID varchar(38)
														 )
-- with encryption 
AS
begin
-- Ergänzung Aufzeichnung
  declare  @IsSimulationMode bit
  select @IsSimulationMode = dbo.QBM_FGIIsSimulationMode() 
-- / Ergänzung Aufzeichnung

  declare  @IsApplicationGroup bit
  declare @cn nvarchar(64)  
  declare @uid_person varchar(38)
  declare @uid_application varchar(38)
  declare @SQLcmd nvarchar(1024)


-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
declare @GenProcIDForRestore varchar(38)
declare @XUserForRestore nvarchar(64)
declare @OperationLevelForRestore int
declare @DebugLevel char(1) = 'W'

BEGIN TRY

exec @OperationLevelForRestore = QBM_PGenprocidGetFromContext @GenProcIDForRestore output, @XUserForRestore output, @CodeID = @@ProcID


  select @IsApplicationGroup = isnull(gg.IsApplicationGroup,0), 
			@cn = rtrim(isnull(gg.cn,N'')), 
			@uid_person = rtrim(isnull(nt.uid_person,''))
     from LDAPGroup gg, LDAPAccount nt
     where gg.UId_LDAPGroup = @UID_LDAPGroup and 
           nt.uid_LDAPAccount = @UID_LDAPAccount



      if @IsApplicationGroup = 1 
       begin
	 select @SQLcmd = ''
	 if 1= (select count(*) 
				from application a
				where rtrim(a.Ident_SectionName) = @cn
				and a.IsInActive = 0
			)
	   begin
		select  top 1  @uid_application = uid_application from application where rtrim(Ident_SectionName) = @cn
-- nochmal schlecht kopiert
--		if 1 = (select count(*) from person where rtrim(isnull(uid_person,'')) > ' ' and rtrim(isnull(uid_person,'')) = @uid_person)
		if 1 = (select count(*) from person where uid_person = @uid_person)
                    and 1 = (select isAppaccount from LDAPAccount where uid_LDAPAccount =  @UID_LDAPAccount )
		  begin
			if not exists (select top 1 1 from personHasApp where uid_application = @uid_application and uid_person = @uid_person)
			  begin
				exec QBM_PGenprocidSetInContext  @GenProcID, 'BackSync', 1 
				-- Ergänzung Aufzeichnung
					if @IsSimulationMode = 1
					 begin
						insert into #TriggerOperation (operation, BaseObjectType, ColumnName, Objectkey, OldValue) 
										select 'I', 'personhasapp', '', 
													dbo.QBM_FCVElementToObjectKey2('personhasapp', 'uid_person', @uid_person, 'uid_application', @uid_application) , ''
					 end
				-- / Ergänzung Aufzeichnung
				insert into personhasapp(uid_person, uid_application, xdateinserted, xdateupdated, xuserinserted, xuserupdated, XObjectKey
										, XOrigin)
						values(@uid_person, @uid_application, GetUTCDate(),     GetUTCDate(),    'BackSync', 'BackSync', dbo.QBM_FCVElementToObjectKey2('personhasapp', 'uid_person', @uid_person, 'uid_application', @uid_application)
										, dbo.QBM_FGIBitPatternXOrigin('|Direct|', 0))

				select @SQLcmd = '#LDS#Direct assignment to PersonHasApp implemented, user account = {0}  application group = {1}.|' + @UID_LDAPAccount + N'|' + @uid_LDAPGroup + N'|'
			  end
			 --else
			 --  begin
				--select @SQLcmd = '# L D S # Direct assignment in {2} already exists, account = {0}  application group = {1}.|' + @UID_LDAPAccount + N'|' + @uid_LDAPGroup + N'|PersonHasApp|'
			 --  end
			-- egal ob personinappschon existierte oder erst eingetragen wurde:
			 exec QBM_PGenprocidSetInContext  @GenProcID, 'BackSync', 1 
				-- Ergänzung Aufzeichnung
					if @IsSimulationMode = 1
					 begin
						insert into #TriggerOperation (operation, BaseObjectType, ColumnName, Objectkey, OldValue) 
										select 'D', 'LDAPAccountInLDAPGroup', '', 
												dbo.QBM_FCVElementToObjectKey2('LDAPAccountInLDAPGroup', 'uid_LDAPAccount', @uid_LDAPAccount, 'uid_LDAPGroup', @uid_LDAPGroup) , ''
					 end
				-- / Ergänzung Aufzeichnung
				
 			 update LDAPAccountInLDAPGroup 
 					set XOrigin = (XOrigin & dbo.QBM_FGIBitPatternXOrigin('|direct|', 1)) | dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 0)
 			 where uid_LDAPAccount = @UID_LDAPAccount 
 				and uid_LDAPGroup = @uid_LDAPGroup

		  end
		else
		  begin
			select @SQLcmd = '#LDS#Employee cannot be found, user account = {0}  application group = {1}.|' + @UID_LDAPAccount + N'|' + @uid_LDAPGroup + N'|'
		  end
	   end
	 else
	   begin
		select @SQLcmd = '#LDS#Application cannot be found, account = {0}  application group = {1}.|' + @UID_LDAPAccount + N'|' + @uid_LDAPGroup + N'|'
	   end
			
	if @SQLcmd <> ''
	  begin
		exec QBM_PJournal @SQLcmd, @@procid, 'W', @DebugLevel
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



exec QBM_PProcedureDrop 'SDL_ZLDPAccountInAppGroup' 
go

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-LDAPAccountInApplicationGroup'  -- (730756)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-LDAPAccountInApplicationGroup'
		, @Operation = 'LDAPACCOUNTINAPPLICATIONGROUP'
		, @ProcedureName = 'SDL_ZLDPAccountInAppGroup'
		, @IsBulkEnabled = 1
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
create procedure SDL_ZLDPAccountInAppGroup  (@SlotNumber int)

 
-- with encryption 
AS
begin


declare @uid_Object varchar(38)
declare @uid_SubObject varchar(38)
declare @GenProcID varchar(38)

BEGIN TRY

	DECLARE schritt_SDL_ZLDPAccountInAppGroup CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
		select UID_Parameter ,	UID_SubParameter, GenProcID 
		from QBMDBQueueCurrent p
		where p.SlotNumber = @SlotNumber
	
	OPEN schritt_SDL_ZLDPAccountInAppGroup
	FETCH NEXT FROM schritt_SDL_ZLDPAccountInAppGroup into @uid_Object, @uid_SubObject, @GenProcID
	
	WHILE (@@fetch_status <> -1)
	BEGIN

		exec SDL_PLDPAccountInAppGroup @uid_Object, @uid_SubObject, @GenProcID

	     FETCH NEXT FROM schritt_SDL_ZLDPAccountInAppGroup INTO @uid_Object, @uid_SubObject, @GenProcID
	END
	close schritt_SDL_ZLDPAccountInAppGroup
	deallocate schritt_SDL_ZLDPAccountInAppGroup
END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'schritt_SDL_ZLDPAccountInAppGroup'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH

ende:
	return

 end
go

