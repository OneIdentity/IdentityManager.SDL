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
-- Prozedur SDL_ZApplicationMakeSortorder
---------------------------------------------------------------------------

exec QBM_PProcedureDrop 'SDL_ZApplicationMakeSortorder'
go


-- exec SDL_ZApplicationMakeSortorder

---<summary>Finds the SortOrderForProfile in application</summary>
---<param name="dummy1">The parameter is unused and has to be an empty string</param>
---<param name="dummy2">The parameter is unused and has to be an empty string</param>
---<param name="GenProcID" type="varchar(38)">Process ID of the source operation</param>
---<remarks>
--- This procedure queues jobs in the Jobqueue to update the value.
--- No direct update takes place meaning templates can reference profiles if necessary
--- The procedure does not have parameters because the calculation is always applied to all elements in the set
---</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-ApplicationMakeSortOrder'  -- (810630)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-ApplicationMakeSortOrder'
		, @Operation = 'APPLICATIONMAKESORTORDER'
		, @ProcedureName = 'SDL_ZApplicationMakeSortorder'
		, @IsBulkEnabled = 0
		, @CountParameter = 0
		, @MaxInstance = 1
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate = 'select	''''		where	''1''	=	dbo.QBM_FGIConfigparmValue(''Software\Application'')'
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = null
		
*/

create procedure SDL_ZApplicationMakeSortorder ( @SlotNumber int
											, @dummy1 varchar(38)
											, @dummy2 varchar(38)
											, @GenProcIDDummy varchar(38)
											)
as
 begin

declare @startwert int
select @startwert = 10000

declare @schrittweite int
select @schrittweite = 10

declare @whereclause nvarchar(1000)
declare @ParamVal nvarchar(16)
declare @BasisObjectKey varchar(138)

-- Algorithmus für neue Ermittlung der Sortorder
-- alle die bestimmen, die nirgendwo als Child auftauchen, die sind erst mal die Wurzel

-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
declare @GenProcIDForRestore varchar(38)
declare @XUserForRestore nvarchar(64)
declare @OperationLevelForRestore int
declare @AdditionalObjectKeysAffected_CSU QBM_YParameterList -- compiler shut up
declare @GenProcID varchar(38) = newid()
BEGIN TRY

exec @OperationLevelForRestore = QBM_PGenprocidGetFromContext @GenProcIDForRestore output, @XUserForRestore output, @CodeID = @@ProcID

-- eintüten und durchzählen ab 10000 in 10er Schritten
declare @reihenfolge int
select @reihenfolge = @startwert

declare @uid_application varchar(38)
declare @gefunden bit

truncate table #QBMDeltaHelper

-- Falls alle Abhängigkeiten leer sind
if not exists (select top 1 1 from ApplicationDependsOnApp)
 begin
	insert into #QBMDeltaHelper (Element, XOrigin, AssignedElement)
			select uid_application, @startwert, ''
			from Application

	goto keineAbhaegigkeit
 end

DECLARE schritt_SDL_ZApplicationMakeSortorder CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
	select a.uid_application
		from application a
		where Not exists (select top 1 1 from ApplicationDependsOnApp ada 
					where ada.uid_applicationChild = a.uid_application
				)
	order by a.uid_application
	
  OPEN schritt_SDL_ZApplicationMakeSortorder
  FETCH NEXT FROM schritt_SDL_ZApplicationMakeSortorder into @uid_application
  WHILE (@@fetch_status <> -1)
  BEGIN
	insert into #QBMDeltaHelper (Element, XOrigin, AssignedElement)
			select @uid_application, @reihenfolge, ''

	select @reihenfolge = @reihenfolge + @schrittweite

     FETCH NEXT FROM schritt_SDL_ZApplicationMakeSortorder INTO @uid_application
  END
  close schritt_SDL_ZApplicationMakeSortorder
  deallocate schritt_SDL_ZApplicationMakeSortorder




--und jetzt die weiteren ebenen
-- alle Knoten, für die ALLE Vorgänger bereits in der tmp-Tabelle sind, die selber aber noch nicht drin sind

marke:
select @gefunden = 0
--insert into #tst (uid, nummer)
DECLARE schritt_SDL_ZApplicationMakeSortorder2 CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
  select a.uid_application
	from application a 
	where Not exists (select top 1 1 from #QBMDeltaHelper where Element = a.uid_application)
		and exists (select top 1 1 from 
			-- bedeutet: CountItems vorgänger, die eine Applikation hat ist gleich der CountItems vorgänger, die schon in #tst eingetütet sind

			(select ada.uid_applicationChild as uid_application, count(*) as CountItems
				from ApplicationDependsOnApp ada 
					where ada.uid_applicationChild = a.uid_application
			group by ada.uid_applicationchild 
			) as x join 
			
			( select ada.uid_applicationChild as uid_application, count(*) as CountItems
				from ApplicationDependsOnApp ada join #QBMDeltaHelper on ada.uid_applicationParent = #QBMDeltaHelper.Element
					where ada.uid_applicationChild = a.uid_application
			group by ada.uid_applicationchild 
			) as y on x.uid_application = y.uid_application
				and x.CountItems = y.CountItems
			where x.uid_application = a.uid_application
		)
	order by a.uid_application	
  OPEN schritt_SDL_ZApplicationMakeSortorder2
  FETCH NEXT FROM schritt_SDL_ZApplicationMakeSortorder2 into @uid_application
  WHILE (@@fetch_status <> -1)
  BEGIN
	insert into #QBMDeltaHelper (Element, XOrigin, AssignedElement)
			select @uid_application, @reihenfolge, ''

	select @reihenfolge = @reihenfolge + @schrittweite
	select @gefunden = 1

     FETCH NEXT FROM schritt_SDL_ZApplicationMakeSortorder2 INTO @uid_application
  END
  close schritt_SDL_ZApplicationMakeSortorder2
  deallocate schritt_SDL_ZApplicationMakeSortorder2

 if @gefunden = 1
   begin
	goto marke
   end

--jetzt zeilenweise durch alle die durch, wo die Sortierfolge sich gegenüber dem Eintrag in Application geändert hat
-- für diese ein job einstellen
keineAbhaegigkeit:

DECLARE schritt_SDL_ZApplicationMakeSortorder3 CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
 select a.uid_application, co.XOrigin
	from application a join #QBMDeltaHelper co on a.uid_application = co.Element
							and isnull(a.SortorderForProfile,-1) <> co.XOrigin
--16592
						join dialogColumn c on c.UID_DialogTable = 'APC-T-Application'
											and c.columnname = 'SortorderForProfile'
											and c.IsDeactivatedByPreProcessor = 0
--/ 16592
	order by a.uid_application
	
  OPEN schritt_SDL_ZApplicationMakeSortorder3
  FETCH NEXT FROM schritt_SDL_ZApplicationMakeSortorder3 into @uid_application, @reihenfolge
  WHILE (@@fetch_status <> -1)
  BEGIN

		if @GenprocID = 'SIMULATION'
		 begin
				exec QBM_PGenprocidSetInContext  'SIMULATION', N'DBScheduler', 1 
				UPDATE Application set SortorderForProfile = @ParamVal
						where uid_application = @uid_application
		 end
		else -- if @GenprocID = N'SIMULATION'
		 begin
			select @whereclause = N'uid_application = ''' + rtrim(@uid_application) + N''''
			select @ParamVal = convert(nvarchar(16), @reihenfolge)
			select @BasisObjectKey = dbo.QBM_FCVElementToObjectKey1('Application', 'uid_application', @uid_application)

			exec QBM_PJobCreate_HOUpdate 'Application', @whereclause, @GenProcID
							, @ObjectKeysAffected = @AdditionalObjectKeysAffected_CSU
							, @p1 = 'SortorderForProfile', @v1 = @ParamVal  
							, @isToFreezeOnError  = 0
							, @BasisObjectKey = @BasisObjectKey

		 end -- else if @GenprocID = N'SIMULATION'

     FETCH NEXT FROM schritt_SDL_ZApplicationMakeSortorder3 INTO @uid_application, @reihenfolge
  END
  close schritt_SDL_ZApplicationMakeSortorder3
  deallocate schritt_SDL_ZApplicationMakeSortorder3

END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'schritt_SDL_ZApplicationMakeSortorder'  
    exec QBM_PCursorDrop 'schritt_SDL_ZApplicationMakeSortorder2'
    exec QBM_PCursorDrop 'schritt_SDL_ZApplicationMakeSortorder3'
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	
-- Standard-Abspann für Prozeduren, die die GenProciD setzen

ende:
	exec QBM_PGenprocidSetInContext @GenProcIDForRestore, @XUserForRestore, @OperationLevelForRestore
	return

 end
go

