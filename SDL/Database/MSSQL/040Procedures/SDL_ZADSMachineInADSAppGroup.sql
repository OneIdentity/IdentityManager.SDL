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
-- ZusatzProzedur SDL_ZADSMachineInADSAppGroup
--------------------------------------------------------------------------------  

exec QBM_PProcedureDrop 'SDL_PADSMachineInAppGroup' 
go


---<summary>Handles direct memberships of AD machine accounts in application groups</summary>
---<param name="UID_ADSMachine">ADSMachine account UID</param>
---<param name="UID_ADSGroup">Application group UID</param>
---<param name="GenProcID" type="varchar(38)">Process ID of the source operation</param>
---<remarks>
--- this procedure controls the BackSync when application groups in namespace group memberships
--- are found. These are not directly entered into ADSMachineInADSGroup but mapped to WorkDeskHasApp
---</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

create procedure SDL_PADSMachineInAppGroup (
														 @UID_ADSMachine varchar(38),
														 @UID_ADSGroup varchar(38)
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
     from ADSGroup gg, Hardware nt, ADSMachine m
     where gg.UId_ADSGroup = @UID_ADSGroup 
           and m.UID_ADSMachine = @UID_ADSMachine
		   and m.uid_Hardware = nt.uid_Hardware



      if @IsApplicationGroup = 1 
       begin
	 select @SQLcmd = ''
	 if 1= (select count(*) from Application where rtrim(Ident_SectionName) = @cn)
	   begin
		select  top 1  @UID_Application = UID_Application from Application where rtrim(Ident_SectionName) = @cn
		if 1 = (select count(*) from WorkDesk where rtrim(isnull(UID_WorkDesk,'')) <> '' and rtrim(isnull(UID_WorkDesk,'')) = @UID_WorkDesk)
--                    and 1 = (select isAppaccount from Hardware where UID_Hardware =  @UID_Hardware )
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

				select @SQLcmd = '#LDS#ADSMachineInADSGroup: Direct assignment applied to WorkDeskHasApp, ADSMachine = {0} Application group = {1}.|' + @UID_ADSMachine + N'|' + @UID_ADSGroup + N'|'
			  end
			 --else
			 --  begin
				--select @SQLcmd = '# L D S # Direct assignment in {2} already exists, account = {0}  application group = {1}.|' + @UID_ADSMachine + N'|' + @UID_ADSGroup + N'|WorkDeskHasApp|'
			 --  end
			-- egal ob WorkDeskinappschon existierte oder erst eingetragen wurde:
			 exec QBM_PGenprocidSetInContext  @GenProcID, 'BackSync', 1 
				-- Ergänzung Aufzeichnung
					if @IsSimulationMode = 1
					 begin
						insert into #TriggerOperation (operation, BaseObjectType, ColumnName, Objectkey, OldValue) 
										select 'D', 'ADSMachineInADSGroup', '', 
												dbo.QBM_FCVElementToObjectKey2('ADSMachineInADSGroup', 'UID_ADSMachine', @UID_ADSMachine, 'UID_ADSGroup', @UID_ADSGroup) , ''
					 end
				-- / Ergänzung Aufzeichnung
				
 			 update ADSMachineInADSGroup 
 					set XOrigin = (XOrigin & dbo.QBM_FGIBitPatternXOrigin('|direct|', 1)) | dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 0)
 			 where UID_ADSMachine = @UID_ADSMachine 
 				and UID_ADSGroup = @UID_ADSGroup

		  end
		else
		  begin
			select @SQLcmd = '#LDS#ADSMachineInADSGroup: WorkDesk cannot be found, ADSMachine = {0} Application group = {1}.|' + @UID_ADSMachine + N'|' + @UID_ADSGroup + N'|'
		  end
	   end
	 else
	   begin
		select @SQLcmd = '#LDS#Application cannot be found, account = {0}  application group = {1}.|' + @UID_ADSMachine + N'|' + @UID_ADSGroup + N'|'
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



exec QBM_PProcedureDrop 'SDL_ZADSMachineInADSAppGroup' 
go

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-ADSMachineInADSAppGroup'  -- (770618)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-ADSMachineInADSAppGroup'
		, @Operation = 'SDL-K-ADSMachineInADSAppGroup'
		, @ProcedureName = 'SDL_ZADSMachineInADSAppGroup'
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

create procedure SDL_ZADSMachineInADSAppGroup (@SlotNumber int)

 
-- with encryption 
AS
begin


declare @uid_Object varchar(38)
declare @uid_SubObject varchar(38)
declare @GenProcID varchar(38)

BEGIN TRY

	DECLARE schritt_SDL_ZADSMachineInADSAppGroup CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
		select UID_Parameter ,	UID_SubParameter, GenProcID 
		from QBMDBQueueCurrent p
		where p.SlotNumber = @SlotNumber
	
	OPEN schritt_SDL_ZADSMachineInADSAppGroup
	FETCH NEXT FROM schritt_SDL_ZADSMachineInADSAppGroup into @uid_Object, @uid_SubObject, @GenProcID
	
	WHILE (@@fetch_status <> -1)
	BEGIN

		exec SDL_PADSMachineInAppGroup @uid_Object, @uid_SubObject, @GenProcID

	     FETCH NEXT FROM schritt_SDL_ZADSMachineInADSAppGroup INTO @uid_Object, @uid_SubObject, @GenProcID
	END
	close schritt_SDL_ZADSMachineInADSAppGroup
	deallocate schritt_SDL_ZADSMachineInADSAppGroup
END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'schritt_SDL_ZADSMachineInADSAppGroup'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
-- Standard-Abspann für Prozeduren, die die GenProciD setzen

ende:
	return

 end
go

