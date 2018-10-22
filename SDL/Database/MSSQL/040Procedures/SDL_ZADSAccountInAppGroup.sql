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
-- ZusatzProzedur SDL_ZADSAccountInAppGroup
--------------------------------------------------------------------------------  

exec QBM_PProcedureDrop 'SDL_PADSAccountInAppGroup' 
go


---<summary>Handles direct memberships of AD accounts in application groups</summary>
---<param name="UID_ADSAccount">ADS account UID</param>
---<param name="UID_ADSGroup">Application group UID</param>
---<param name="GenProcID" type="varchar(38)">Process ID of the source operation</param>
---<remarks>
--- this procedure controls the BackSync when group memberships in application groups
--- are found. These are not directly entered into ADSAccountInADSGroup but mapped to PersonHasApp
---</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

create procedure SDL_PADSAccountInAppGroup (
														@UID_ADSAccount varchar(38)
														, @UID_ADSGroup varchar(38)
														, @GenProcID varchar(38) 
														)
-- with encryption 
AS
begin
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
     from ADSGroup gg, ADSAccount nt
     where gg.UId_ADSGroup = @UID_ADSGroup and 
           nt.uid_ADSAccount = @UID_ADSAccount



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
--		if 1 = (select count(*) from person where rtrim(isnull(uid_person,'')) > ' ' and rtrim(isnull(uid_person,'')) = @uid_person)
-- war eigentlich Külf, wird grob vereinfacht:
		if 1 = (select count(*) from person where uid_person = @uid_person)
                    and 1 = (select isAppaccount from ADSaccount where uid_ADSaccount =  @UID_ADSAccount )
		  begin
			if not exists (select top 1 1 from personHasApp where uid_application = @uid_application and uid_person = @uid_person)
			  begin
				exec QBM_PGenprocidSetInContext  @GenProcID, 'BackSync', 1 
				insert into personhasapp(uid_person, uid_application, xdateinserted, xdateupdated, xuserinserted, xuserupdated, XObjectKey
										, XOrigin)
						values(@uid_person, @uid_application, GetUTCDate(),     GetUTCDate(),    N'BackSync', N'BackSync', dbo.QBM_FCVElementToObjectKey2('personhasapp', 'uid_person', @uid_person, 'uid_application', @uid_application)
										, dbo.QBM_FGIBitPatternXOrigin('|Direct|', 0))

				select @SQLcmd = '#LDS#Direct assignment to PersonHasApp implemented, user account = {0}  application group = {1}.|' + @UID_ADSAccount + N'|' + @uid_ADSGroup + N'|'
			  end
			 --else
			 --  begin
				--select @SQLcmd = '#LDS#Direct assignment in {2} already exists, account = {0}  application group = {1}.|' + @UID_ADSAccount + N'|' + @uid_ADSGroup + N'|PersonHasApp|'
			 --  end
			-- egal ob personinappschon existierte oder erst eingetragen wurde:
			 exec QBM_PGenprocidSetInContext  @GenProcID, 'BackSync', 1 
			 
 			 update ADSaccountInADSGroup 
				set XOrigin = (XOrigin & dbo.QBM_FGIBitPatternXOrigin('|direct|', 1)) | dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 0)
 				where UID_ADSAccount = @UID_ADSAccount 
 				and UID_ADSGroup = @uid_ADSGroup

		  end
		else
		  begin
			select @SQLcmd = '#LDS#Employee cannot be found, user account = {0}  application group = {1}.|' + @UID_ADSAccount + N'|' + @uid_ADSGroup + N'|'
		  end
	   end
	 else
	   begin
		select @SQLcmd = '#LDS#Application cannot be found, account = {0}  application group = {1}.|' + @UID_ADSAccount + N'|' + @uid_ADSGroup + N'|'
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




exec QBM_PProcedureDrop 'SDL_ZADSAccountInAppGroup' 
go


/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-ADSAccountInApplicationGroup'  -- (730726)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-ADSAccountInApplicationGroup'
		, @Operation = 'ADSACCOUNTINAPPLICATIONGROUP'
		, @ProcedureName = 'SDL_ZADSAccountInAppGroup'
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

create procedure SDL_ZADSAccountInAppGroup (@SlotNumber int)

 
-- with encryption 
AS
begin


declare @uid_Object varchar(38)
declare @uid_SubObject varchar(38)
declare @GenProcID varchar(38)

BEGIN TRY

	DECLARE schritt_SDL_ZADSAccountInAppGroup CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
		select UID_Parameter ,	UID_SubParameter, GenProcID 
		from QBMDBQueueCurrent p
		where p.SlotNumber = @SlotNumber
	
	OPEN schritt_SDL_ZADSAccountInAppGroup
	FETCH NEXT FROM schritt_SDL_ZADSAccountInAppGroup into @uid_Object, @uid_SubObject, @GenProcID
	
	WHILE (@@fetch_status <> -1)
	BEGIN

		exec SDL_PADSAccountInAppGroup @uid_Object, @uid_SubObject, @GenProcID

	     FETCH NEXT FROM schritt_SDL_ZADSAccountInAppGroup INTO @uid_Object, @uid_SubObject, @GenProcID
	END
	close schritt_SDL_ZADSAccountInAppGroup
	deallocate schritt_SDL_ZADSAccountInAppGroup
END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'schritt_SDL_ZADSAccountInAppGroup'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH


ende:
	return

 end
go

