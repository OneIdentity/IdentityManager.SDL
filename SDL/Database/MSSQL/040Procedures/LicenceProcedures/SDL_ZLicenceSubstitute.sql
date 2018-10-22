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


--------------------------------------------------------
--  SDL_ZLicenceSubstitute
------------------------------------------------------

-- errechnen von LicenceSubstituteTotal

-- Procedure starts without parameters. Always runs through the entire table

-- Achtung, hinten hängt noch ein ganzer Sack testmaterial dran

exec QBM_PProcedureDrop 'SDL_ZLicenceSubstitute'
go

-- exec SDL_ZLicenceSubstitute ''

---<summary>Calculates LicenceSubstituteTotal</summary>
---<param name="dummy">The parameter is unused and has to be an empty string</param>
---<param name="dummy1">The parameter is unused and has to be an empty string</param>
---<param name="GenProcID" type="varchar(38)">Process ID of the source operation</param>
---<remarks>
---Procedure starts without parameters. Always runs through the entire table
---</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-LicenceSubSTITUTE'  -- (810624)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-LicenceSubSTITUTE'
		, @Operation = 'LICENCESUBSTITUTE'
		, @ProcedureName = 'SDL_ZLicenceSubstitute'
		, @IsBulkEnabled = 0
		, @CountParameter = 0
		, @MaxInstance = 1
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate = 'select	''''		where		''1''	=	dbo.QBM_FGIConfigparmValue(''Software\LicenceManagement'')'
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = null
		
*/

create procedure SDL_ZLicenceSubstitute 
				( @SlotNumber int
				, @dummy varchar(38) 
				, @dummy1 varchar(38) 
				, @GenProcIDDummy varchar(38) 
				)
as
 begin
-- exec QBM_PProcedureNestLevelCheck @@ProcID



-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
declare @GenProcIDForRestore varchar(38)
declare @XUserForRestore nvarchar(64)
declare @OperationLevelForRestore int
declare @GenProcID varchar(38) = newid()
BEGIN TRY

exec @OperationLevelForRestore = QBM_PGenprocidGetFromContext @GenProcIDForRestore output, @XUserForRestore output, @CodeID = @@ProcID

--print '1'

exec QBM_PGenprocidSetInContext  @GenProcID, 'DBScheduler', 1
delete licenceSubstituteTotal
-- erst mal die rekursive Schlinge in Total
exec QBM_PGenprocidSetInContext  @GenProcID, 'DBScheduler', 1
insert into licenceSubstituteTotal(UID_Licence  , UID_LicenceSubstitute , UID_GroupRoot, CountSteps, XObjectKey) 
	select uid_licence, uid_licence, uid_licence, 0
							, dbo.QBM_FCVElementToObjectKey2('licenceSubstituteTotal', 'UID_Licence', uid_licence, 'UID_LicenceSubstitute', uid_licence)
	from licence
-- wenn wir initial alle Lizenzen einfüllen, haben wir das auch für die Auswertung leichter
--print '2'

-- alle vorgegebenen direkten Kanten 
exec QBM_PGenprocidSetInContext  @GenProcID, 'DBScheduler', 1
insert into licenceSubstituteTotal(UID_Licence  , UID_LicenceSubstitute , UID_GroupRoot, CountSteps, XObjectKey)
	select ls.uid_licence, ls.uid_licenceSubstitute, ls.uid_licence, 1  -- gruppe nehmen wir erst mal den Vorgänger an
							, dbo.QBM_FCVElementToObjectKey2('licenceSubstituteTotal', 'UID_Licence', ls.uid_licence, 'UID_LicenceSubstitute', ls.uid_licenceSubstitute)
	from licenceSubstitute ls
	where Not exists (select top 1 1 from licencesubstituteTotal t where ls.uid_licence = t.uid_licence
								and ls.uid_licenceSubstitute = t.uid_licenceSubstitute
			)


-- errechnen aller Transitiven Überbrückungen
--print '3'

marke:
--print '4, an der marke'
insert into licenceSubstituteTotal(UID_Licence  , UID_LicenceSubstitute , UID_GroupRoot, CountSteps, XObjectKey)
	select distinct c.uid_licence, p.uid_licenceSubstitute, c.uid_licence, c.CountSteps + p.CountSteps  -- gruppe nehmen wir erst mal den Vorgänger an
							, dbo.QBM_FCVElementToObjectKey2('licenceSubstituteTotal', 'UID_Licence', c.uid_licence, 'UID_LicenceSubstitute', p.uid_licenceSubstitute)
	from licenceSubstituteTotal c join licenceSubstituteTotal p on c.uid_licenceSubstitute = p.uid_licence 
	where Not exists (select top 1 1 from licencesubstituteTotal t where c.uid_licence = t.uid_licence
								and p.uid_licenceSubstitute = t.uid_licenceSubstitute
			)

if @@rowcount > 0 goto marke

--uid_GroupRoot korrigieren auf die Wurzel von 's janze
marke2:

--print '5, an der marke2'
/*
select licenceSubstituteTotal.uid_licence as Licence, licenceSubstituteTotal.uid_licenceSubstitute as substitute,
licenceSubstituteTotal.UID_GroupRoot as alterWertRoot,  v.uid_grouproot as neuerWertRoot
	from licenceSubstituteTotal , licenceSubstituteTotal v --Vorgänger
	where v.uid_licenceSubstitute = licenceSubstituteTotal.uid_licence
		and licenceSubstituteTotal.uid_GroupRoot <> v.uid_grouproot
-- jedoch nur die, wo der Vorgänger eindeutig wird, also GENAU ein neuer Wert für die GroupRoot ermittelt werden kann
		and exists (select top 1 1 from 
						(select t.uid_licence as Licence, t.uid_licenceSubstitute as substitute,
									/*t.UID_GroupRoot as alterWertRoot,   v.uid_grouproot as neuerWertRoot, */ count(*) as CountNew
							from licenceSubstituteTotal t , licenceSubstituteTotal v --Vorgänger
								where v.uid_licenceSubstitute = t.uid_licence
									and t.uid_GroupRoot <> v.uid_grouproot
								group by t.uid_licence, t.uid_licenceSubstitute
								having count(*) = 1
						) as x where x.Licence = licenceSubstituteTotal.uid_licence
								and x.substitute = licenceSubstituteTotal.uid_licenceSubstitute
					)

*/

update licenceSubstituteTotal set UID_GroupRoot = v.uid_grouproot
	from licenceSubstituteTotal , licenceSubstituteTotal v --Vorgänger
	where v.uid_licenceSubstitute = licenceSubstituteTotal.uid_licence
		and licenceSubstituteTotal.uid_GroupRoot <> v.uid_grouproot
-- wegen Buglist 10310
-- jedoch nur die, wo der Vorgänger eindeutig wird, also GENAU ein neuer Wert für die GroupRoot ermittelt werden kann
		and exists (select top 1 1 from 
						(select t.uid_licence as Licence, t.uid_licenceSubstitute as substitute,
									/*t.UID_GroupRoot as alterWertRoot,   v.uid_grouproot as neuerWertRoot, */ count(*) as CountItemsNew
							from licenceSubstituteTotal t , licenceSubstituteTotal v --Vorgänger
								where v.uid_licenceSubstitute = t.uid_licence
									and t.uid_GroupRoot <> v.uid_grouproot
								group by t.uid_licence, t.uid_licenceSubstitute
								having count(*) = 1
						) as x where x.Licence = licenceSubstituteTotal.uid_licence
								and x.substitute = licenceSubstituteTotal.uid_licenceSubstitute
					)

if @@rowcount > 0 goto marke2

--print '6'

 -- maximale Gruppengröße bestimmen als Multiplikator für Ermittlung der Sortierfolge

  -- maximale Weglänge bis Wurzel, sofern als Nachfolger eingetragen

update licenceSubstituteTotal set Sortorder = a.GruppenGroesse * b.maxweg + licenceSubstituteTotal.countSteps
	from licenceSubstituteTotal join 
			 ( select max(CountItems) as GruppenGroesse , uid_groupRoot
			   from (	
				 select uid_groupRoot, uid_licence, count(*) as CountItems
				from licenceSubstituteTotal
				group by uid_groupRoot, uid_licence
				) as x
				group by uid_grouproot
			) as a on licenceSubstituteTotal.uid_groupRoot = a.uid_grouproot
			join
			  (
				select uid_groupRoot, uid_licenceSubstitute as uid_licenceWeg, max(countSteps) as MaxWeg
				from licenceSubstituteTotal
				group by uid_groupRoot, uid_licenceSubstitute
			) as b on licenceSubstituteTotal.uid_groupRoot = b.uid_groupRoot 
				and licenceSubstituteTotal.uid_licence = b.uid_licenceWeg
--	where isnull(Sortorder,0) <> a.GruppenGroesse * b.maxweg + licenceSubstituteTotal.countSteps

--print '7'

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

