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
-- ZusatzProzedur 
--------------------------------------------------------------------------------  

exec QBM_PProcedureDrop 'SDL_PLDPMachineInLDPAppGroup' 
go


---<summary>Handles direct memberships of LDAP machine accounts in application groups</summary>
---<param name="UID_LDPMachine">LDPMachine account UID</param>
---<param name="UID_LDAPGroup">Application group UID</param>
---<param name="GenProcID" type="varchar(38)">Process ID of the source operation</param>
---<remarks>
--- this procedure controls the BackSync when application groups in namespace group memberships
--- are found. These are not directly entered into LDPMachineInLDAPGroup but mapped to WorkDeskHasApp
---</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

create procedure SDL_PLDPMachineInLDPAppGroup (
													 @UID_LDPMachine varchar(38),
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
  declare @uid_WorkDesk varchar(38)
  declare @uid_application varchar(38)
  declare @SQLcmd nvarchar(1024)


-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
declare @GenProcIDForRestore varchar(38)
declare @XUserForRestore nvarchar(64)
declare @OperationLevelForRestore int
declare @DebugLevel char(1) = 'W'

BEGIN TRY

exec @OperationLevelForRestore = QBM_PGenprocidGetFromContext @GenProcIDForRestore output, @XUserForRestore output, @CodeID = @@ProcID


  select top 1 @IsApplicationGroup = isnull(gg.IsApplicationGroup,0), 
			@cn = rtrim(isnull(gg.cn,N'')), 
			@uid_WorkDesk = rtrim(isnull(nt.uid_WorkDesk,''))
     from LDAPGroup gg, Hardware nt, LDPMachine m
     where gg.UId_LDAPGroup = @UID_LDAPGroup
           and m.UID_LDPMachine = @UID_LDPMachine
		   and nt.uid_Hardware = m.uid_Hardware



      if @IsApplicationGroup = 1 
       begin
	 select @SQLcmd = ''
	 if 1= (select count(*) from Application where rtrim(Ident_SectionName) = @cn)
	   begin
		select  top 1  @UID_Application = UID_Application from Application where rtrim(Ident_SectionName) = @cn
-- war zu umständlich, wird grob vereinfacht, war wohl schlecht kopier
--		if 1 = (select count(*) from WorkDesk where rtrim(isnull(UID_WorkDesk,'')) > ' ' and rtrim(isnull(UID_WorkDesk,'')) = @UID_WorkDesk)
		if 1 = (select count(*) from WorkDesk where UID_WorkDesk = @UID_WorkDesk)
--                    and 1 = (select isAppaccount from LDPMachine where UID_LDPMachine =  @UID_LDPMachine )
		  begin
			if not exists (select top 1 1 from WorkDeskHasApp where UID_Application = @UID_Application and UID_WorkDesk = @UID_WorkDesk)
			  begin
				exec QBM_PGenprocidSetInContext  @GenProcID, 'BackSync', 1 
				-- Ergänzung Aufzeichnung
					if @IsSimulationMode = 1
					 begin
						insert into #TriggerOperation (operation, BaseObjectType, ColumnName, Objectkey, OldValue) 
										select 'I', 'WorkDeskhasapp', '', 
													dbo.QBM_FCVElementToObjectKey2('WorkDeskhasapp', 'UID_WorkDesk', @UID_WorkDesk, 'UID_Application', @UID_Application) , ''
					 end
				-- / Ergänzung Aufzeichnung
				insert into WorkDeskhasapp(UID_WorkDesk, UID_Application, xdateinserted, xdateupdated, xuserinserted, xuserupdated, XObjectKey
											, XOrigin)
						values(@UID_WorkDesk, @UID_Application, GetUTCDate(),     GetUTCDate(),    'BackSync', 'BackSync', dbo.QBM_FCVElementToObjectKey2('WorkDeskhasapp', 'UID_WorkDesk', @UID_WorkDesk, 'UID_Application', @UID_Application)
											, dbo.QBM_FGIBitPatternXOrigin('|Direct|', 0))

				select @SQLcmd = '#LDS#LDPMachineInLDAPGroup: Direct assignment applied to WorkDeskHasApp, LDPMachine {0} Application group = {1}.|' + @UID_LDPMachine + N'|' + @UID_LDAPGroup + N'|'
			  end
			 --else
			 --  begin
				--select @SQLcmd = '# L D S # Direct assignment in {2} already exists, account = {0}  application group = {1}.|' + @UID_LDPMachine + N'|' + @UID_LDAPGroup + N'|WorkDeskHasApp|'
			 --  end
			-- egal ob WorkDeskinappschon existierte oder erst eingetragen wurde:
			 exec QBM_PGenprocidSetInContext  @GenProcID, 'BackSync', 1 
				-- Ergänzung Aufzeichnung
					if @IsSimulationMode = 1
					 begin
						insert into #TriggerOperation (operation, BaseObjectType, ColumnName, Objectkey, OldValue) 
										select 'D', 'LDPMachineInLDAPGroup', '', 
												dbo.QBM_FCVElementToObjectKey2('LDPMachineInLDAPGroup', 'UID_LDPMachine', @UID_LDPMachine, 'UID_LDAPGroup', @UID_LDAPGroup) , ''
					 end
				-- / Ergänzung Aufzeichnung
 			 update LDPMachineInLDAPGroup 
 					set XOrigin = (XOrigin & dbo.QBM_FGIBitPatternXOrigin('|direct|', 1)) | dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 0)
 				where UID_LDPMachine = @UID_LDPMachine 
 				and UID_LDAPGroup = @UID_LDAPGroup

		  end
		else
		  begin
			select @SQLcmd = '#LDS#LDPMachineInLDAPGroup: WorkDesk cannot be found, LDPMachine = {0} Application group = {1}.|' + @UID_LDPMachine + N'|' + @UID_LDAPGroup + N'|'
		  end
	   end
	 else
	   begin
		select @SQLcmd = '#LDS#Application cannot be found, account = {0}  application group = {1}.|' + @UID_LDPMachine + N'|' + @UID_LDAPGroup + N'|'
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


exec QBM_PProcedureDrop 'SDL_ZLDPMachineInLDPAppGroup' 
go

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-LDPMachineInLDAPAppGroup'  -- (770654)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-LDPMachineInLDAPAppGroup'
		, @Operation = 'SDL-K-LDPMachineInLDAPAppGroup'
		, @ProcedureName = 'SDL_ZLDPMachineInLDPAppGroup'
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

create procedure SDL_ZLDPMachineInLDPAppGroup (@Slotnumber int)

 
-- with encryption 
AS
begin


declare @uid_Object varchar(38)
declare @uid_SubObject varchar(38)
declare @GenProcID varchar(38)

BEGIN TRY

	DECLARE schritt_SDL_ZLDPMachineInLDPAppGroup CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
		select UID_Parameter ,	UID_SubParameter, GenProcID 
		from QBMDBQueueCurrent p
		where p.SlotNumber = @SlotNumber
	
	OPEN schritt_SDL_ZLDPMachineInLDPAppGroup
	FETCH NEXT FROM schritt_SDL_ZLDPMachineInLDPAppGroup into @uid_Object, @uid_SubObject, @GenProcID
	
	WHILE (@@fetch_status <> -1)
	BEGIN

		exec SDL_PLDPMachineInLDPAppGroup @uid_Object, @uid_SubObject, @GenProcID

	     FETCH NEXT FROM schritt_SDL_ZLDPMachineInLDPAppGroup INTO @uid_Object, @uid_SubObject, @GenProcID
	END
	close schritt_SDL_ZLDPMachineInLDPAppGroup
	deallocate schritt_SDL_ZLDPMachineInLDPAppGroup
END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'schritt_SDL_ZLDPMachineLDPAppGroup'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH

ende:
	return

 end
go

