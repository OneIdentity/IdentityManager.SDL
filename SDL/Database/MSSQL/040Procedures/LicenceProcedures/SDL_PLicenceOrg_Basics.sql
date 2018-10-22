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


----------------------------------------------------------------------------------
-- SDL_PLicenceOrg_Basics	
----------------------------------------------------------------------------------
	-- prepares data structures for partial tree calculation 
	-- Is not own task
	-- Prozedur hat als Parameter die uid_org, für deren teilbaum die Berechnung stattfinden soll

-- die nötigen Lizenzknoten erst mal anlegen


exec QBM_PProcedureDrop 'SDL_PLicenceOrg_Basics'
go

---<summary>	
---	-- prepares data structures for partial tree calculation 
---	-- Is not own task
---</summary>
---<remarks>Org UIDs are passed in the auxiliary table QBMDBQueueCurrent</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

create procedure SDL_PLicenceOrg_Basics (@SlotNumber int)
	as
begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID

declare @uid_licence varchar(38)
declare @uid_org varchar(38)
declare @uid_orgroot varchar(38)
declare @GenProcID varchar(38)

declare @validfrom datetime
declare @validto datetime

declare @TableName  nvarchar(64)
declare @BasisObjectKey varchar(138)
declare @WhereClause nvarchar(2000)

-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
declare @GenProcIDForRestore varchar(38)
declare @XUserForRestore nvarchar(64)
declare @OperationLevelForRestore int
declare @AdditionalObjectKeysAffected_CSU QBM_YParameterList -- compiler shut up

BEGIN TRY

exec @OperationLevelForRestore = QBM_PGenprocidGetFromContext @GenProcIDForRestore output, @XUserForRestore output, @CodeID = @@ProcID



DECLARE schritt_BaseTreehaslicence CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR 
	select  l.uid_licence, p.uid_parameter, p.GenProcid, l.validfrom, l.validto, b.uid_orgroot
	from QBMDBQueueCurrent p cross join licence l 
	-- wegen Buglist 8903
		join BaseTree b on b.uid_org = p.uid_parameter
		join 		
-- wegen Buglist 9266		
			( select b.uid_org --, b.uid_orgRoot
						from BaseTree b join orgroot r on b.uid_orgRoot = r.uid_orgroot 
						where exists (select top 1 1 from dialogtable t
										where t.TableName = dbo.QER_FGIOrgRootName(b.uid_orgroot) + 'HasLicence'
										and t.TableType = 'V'
									)
			) as vbt on b.uid_org = vbt.uid_org

	-- /wegen Buglist 8903
	where Not exists (select top 1 1 from BaseTreehaslicence bhl where bhl.uid_org = p.uid_parameter
								and bhl.uid_licence = l.uid_licence
			)
	 and p.SlotNumber = @SlotNumber

	
	OPEN schritt_BaseTreehaslicence
	FETCH NEXT FROM schritt_BaseTreehaslicence into @uid_licence, @uid_org, @genprocid
						, @validfrom, @validto, @uid_orgroot
	WHILE (@@fetch_status <> -1)
	BEGIN
		exec QBM_PGenprocidSetInContext  @GenProcID, 'DBScheduler', 1
		select @TableName  = dbo.QER_FGIOrgRootName(@uid_orgroot) + 'Haslicence'
		select @BasisObjectKey = dbo.QBM_FCVElementToObjectKey2(@TableName , 'UID_Licence', @UID_Licence, 'UID_' + dbo.QER_FGIOrgRootName(@uid_orgroot), @UID_Org)

		insert into BaseTreehaslicence(UID_Licence, UID_Org , CountLimit,  XDateInserted, XDateUpdated , XUserInserted, XUserUpdated , CountLicMacDirectTarget, CountLicMacIndirectTarget, CountLicUserTarget, CountLicMacPossTarget, CountLicMacDirectActual, CountLicMacIndirectActual, CountLicUserActual, CountLicMacPossActual, CountLicMacReal,
					validfrom, validto, XObjectKey )
-- geändert CountLimit auf -1 wegen 10425
			select @UID_Licence, @UID_Org , -1,  GetUTCDate(), GetUTCDate() , 'DBScheduler', 'DBScheduler' , 0, 0, 0, 0, 0, 0, 0, 0, 0 
					, @validfrom, @validto, @BasisObjectKey
-- wegen 11702 Templateverarbeitung anschieben
			 select @WhereClause = N'XObjectKey = ''' + @BasisObjectKey + N''''

		exec QBM_PJobCreate_HOTemplate_B  @TableName, @whereclause, @Columns = '*' , @GenProcID = @GenProcID
					, @SingleTransaction = 0
					, @priority = 10
					, @Retries =  2
					, @BasisObjectKey = @BasisObjectKey
					, @CheckForExisting = 1
					, @AdditionalObjectKeysAffected = @AdditionalObjectKeysAffected_CSU
-- / 11702

	     FETCH NEXT FROM schritt_BaseTreehaslicence INTO @uid_licence, @uid_org, @genprocid
						, @validfrom, @validto, @uid_orgroot
	END
	close schritt_BaseTreehaslicence
	deallocate schritt_BaseTreehaslicence


-- alle nicht(mehr) zu füllenden Lizenzknoten Meßergebnisse löschen, sofern welche da sind
update BaseTreehaslicence set CountLicMacDirectTarget = 0,
				CountLicMacIndirectTarget = 0,
				CountLicUserTarget = 0,
				CountLicMacPossTarget = 0,
				CountLicMacDirectActual = 0,
				CountLicMacIndirectActual = 0,
				CountLicUserActual = 0,
				CountLicMacPossActual = 0,
				CountLicMacReal = 0
	from BaseTreehaslicence join BaseTree b on BaseTreehaslicence.uid_org = b.uid_org
						and isnull(b.isLicencenode,0) = 0	-- kein Lizenzknoten
						and b.uid_parentorg > ' ' -- und auch kein Wurzelknoten
	where isnull(CountLicMacDirectTarget,0) <> 0
	     or isnull(CountLicMacIndirectTarget,0) <> 0
	     or isnull(CountLicUserTarget,0) <> 0
	     or isnull(CountLicMacPossTarget,0) <> 0
	     or isnull(CountLicMacDirectActual,0) <> 0
	     or isnull(CountLicMacIndirectActual,0) <> 0
	     or isnull(CountLicUserActual,0) <> 0
	     or isnull(CountLicMacPossActual,0) <> 0
	     or isnull(CountLicMacReal,0) <> 0

END TRY
BEGIN CATCH
	declare @ErrorMessage nvarchar(4000)
    declare @ErrorSeverity int
    declare @ErrorState int

	select @ErrorSeverity = dbo.QBM_FGIErrorSeverity()
    select @ErrorState = 1
    select @ErrorMessage = dbo.QBM_FGIErrorMessage()

    exec QBM_PCursorDrop 'schritt_BaseTreehaslicence'  
	exec QBM_PRollbackIfAllowed @GenProcID

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)  WITH NOWAIT
END CATCH
	                                	        	
-- Standard-Abspann für Prozeduren, die die GenProciD setzen

ende:
	exec QBM_PGenprocidSetInContext @GenProcIDForRestore, @XUserForRestore, @OperationLevelForRestore
	return

 end
go

