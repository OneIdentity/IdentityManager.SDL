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
   --  ZusatzProzedur SDL_ZLdapAccountInLDAPGroup
   --------------------------------------------------------------------------------  

exec QBM_PProcedureDrop 'SDL_ZLdapAccountInLDAPGroup' 
go


---<summary>Fills and corrects the table LDAPAccountInLDAPGroup</summary>
---<remarks>LDAP UIDs are passed in the auxiliary table QBMDBQueueCurrent</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

---<seealso cref="QBM_PCursorDrop" type="Procedure">Procedure QBM_PCursorDrop</seealso>
---<seealso cref="QBM_FCVElementToObjectKey1" type="Function">Function QBM_FCVElementToObjectKey1</seealso>
---<seealso cref="QBM_FGIIsSimulationMode" type="Function">Function QBM_FGIIsSimulationMode</seealso>
---<seealso cref="QBM_FGIErrorMessage" type="Function">Function QBM_FGIErrorMessage</seealso>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-LDAPAccountInLDAPGroup'  -- (730758)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-LDAPAccountInLDAPGroup'
		, @Operation = 'SDL-K-LDAPAccountInLDAPGroup'
		, @ProcedureName = 'SDL_ZLdapAccountInLDAPGroup'
		, @IsBulkEnabled = 1
		, @CountParameter = 1
		, @MaxInstance = 1000
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate =  null 
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = 'LDP-K-LDAPAccountInLDAPGroup'
		
*/
create procedure SDL_ZLdapAccountInLDAPGroup (@SlotNumber int) 

-- with encryption 
AS
begin
-- Ergänzung Aufzeichnung
  declare  @IsSimulationMode bit
  select @IsSimulationMode = dbo.QBM_FGIIsSimulationMode() 
-- / Ergänzung Aufzeichnung

declare @nta varchar(38)
declare @gg varchar(38)
declare @Sourcedata QBM_YDataForDelta
		, @CountDeltaQantity int 
		, @CountDeltaOrigin int 
declare @viii int
declare @GenProcID varchar(38)






-- prüfen, ob das betreffende Objekt noch existiert

declare @ItemObjectKey varchar(138)
declare @RowsToReset int -- CountItems mit -1 zurückzu setzender Jobs




declare @MyName nvarchar(64) = object_name(@@procid)

declare @ObjectKeysToCheck QBM_YParameterList

BEGIN TRY



select @RowsToReset = 0

	exec QBM_PSlotResetOnMissingItem  @SlotNumber, 'LDAPAccount', 'UID_LDAPAccount'

-------------------------------
-- zurücksetzen,  projection
-------------------------------
if 1 = dbo.DPR_FGIProjectionRootRunning ('LDPDomain')
 begin
	 delete @ObjectKeysToCheck

	 insert into @ObjectKeysToCheck(Parameter1, Parameter2)
	 select  cu.UID_Parameter, ro.ObjectKeyRoot
		from QBMDBQueueCurrent cu join LDAPAccount a on a.UID_LDAPAccount = cu.UID_Parameter
								join LDP_VElementAndRoot ro on a.XObjectKey = ro.ObjectKeyElement
		-- bei mssql reduziert sich das dadurch auf genau 1 Seek (nur die eine Teilquery aus der View):
		where ro.ElementTable = 'LDAPAccount'
		 and cu.SlotNumber = @SlotNumber

	 exec @RowsToReset = DPR_PSlotResetWhileProjection @SlotNumber, 	@ObjectKeysToCheck, @MyName
 end
-------------------------------------------------------------------------
-- zurücksetzen, falls noch job unterwegs ist
-------------------------------------------------------------------------

--20039
delete @ObjectKeysToCheck

insert into @ObjectKeysToCheck(Parameter1, Parameter2)
select  cu.UID_Parameter, x.XObjectKey
	from QBMDBQueueCurrent cu join LDAPAccount x on cu.UID_Parameter = x.UID_LDAPAccount
	where cu.SlotNumber = @SlotNumber

exec QBM_PSlotResetWhileJobRunning @SlotNumber, @@PROCID, 	@ObjectKeysToCheck

if 0 = (select COUNT(*) 
			from QBMDBQueueCurrent p
			where p.SlotNumber = @SlotNumber
		)
 begin
	goto ende
 end

-------------------------------------------------------------------------
-- / zurücksetzen, falls noch job unterwegs ist
-------------------------------------------------------------------------





-- alle bisherigen Gruppen des LDAPAccounts merken 

insert into @SourceData(
						IsUpcommingContent, XOriginAfter
						, Element, AssignedElement, XOriginBefore
						, XIsInEffectBefore, XIsInEffectAfter
						)

	select 0, 0
			, aig.UID_LDAPAccount, aig.UID_LDAPGroup, aig.XOrigin 
			, aig.XIsInEffect , 0
	from LDAPAccountInLDAPGroup aig join QBMDBQueueCurrent x on UID_LDAPAccount = x.UID_parameter
																and x.SlotNumber = @SlotNumber
									join LDAPGroup g on aig.uid_LDAPGroup = g.uid_LDAPgroup
													and g.IsDynamicGroup = 0 
													and g.IsApplicationGroup = 1
    where aig.XMarkedForDeletion & dbo.QBM_FGIBitPatternXMarkedForDel('|Delay|', 0) = 0


-- zusammenstellen aller Globalen Gruppen, die der Account hat
--     diese können kommen 
--        aus  LDAPAccountInLDAPGroup
--        ber PersonHasApp  (wenn der LDAPAccount ein appaccount ist und es die Applikationsgruppe in der gleichen Domne gibt)
--        ber PersonInBaseTree und  BaseTreeHasLDAPGroup (wenn der LDAPAccount ein Gruppenaccount istund die Gruppe in der selben Domne liegt)

insert into @SourceData(
						IsUpcommingContent, XOriginBefore
						, Element, AssignedElement, XOriginAfter
						, XIsInEffectBefore, XIsInEffectAfter
						)

	select 1, 0
			, x.UID_LDAPAccount, x.UID_LDAPGroup, dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 0)
			, 0, dbo.TSB_FGIUserInGroupValid ( p.IsInActive, p.IsTemporaryDeactivated, p.XMarkedForDeletion, bh.PFDInheritGroup, bh.PTDInheritGroup, bh.PMDInheritGroup, 0, p.IsSecurityIncident, bh.PSIInheritGroup, x.AccountDisabled, bh.ADAInheritGroup) 
     from (
	   select nt.UID_LDAPAccount, gg.UID_LDAPGroup, nt.UID_LDPDomain , nt.UID_person
				, nt.AccountDisabled
				, nt.UID_TSBAccountDef
				, nt.UID_TSBBehavior
	             --- ,nt.cn,  gg.cn, gg.samaccountname    -- nur für bersicht in Testphase
	     from LDAPAccount nt join QBMDBQueueCurrent x on nt.UID_LDAPAccount = x.UID_parameter 
													and X.SlotNumber = @SlotNumber
													-- entfällt wegen 25448
													--and nt.XMarkedForDeletion & dbo.QBM_FGIBitPatternXMarkedForDel('|Delay|', 0) = 0
-- LDPDomain jetzt direkt am Objekt
--				join LDAPContainer c on nt.UID_LDAPContainer = c.UID_LDAPContainer
				join personhasapp pha on nt.UID_person = pha.UID_person 
								and pha.XOrigin > 0 and pha.XIsInEffect = 1
								and nt.isappaccount = 1 
				join  application a on pha.UID_application = a.UID_application 
				join LDAPGroup gg  on a.Ident_SectionName = gg.cn 
									and gg.IsApplicationGroup = 1 
									and gg.IsDynamicGroup = 0 
				join SDL_VLDPNearestAppContainer co on gg.UID_LDAPContainer = co.UID_Appcontainer 
								and co.UID_AccountContainer = nt.UID_LDAPContainer

	) as x join LDPDomain d on x.UID_LDPDomain = d.UID_LDPDomain
		left outer join person p on x.UID_person = p.UID_person
-- 12566
			left outer join TSBBehavior bh on x.UID_TSBBehavior = bh.UID_TSBBehavior
-- / 12566
--	group by x.UID_LDAPAccount, x.UID_LDAPGroup


-- hier: Domäne der Gruppe ist im Projektor-Lauf

-------------------------------
-- zurücksetzen,  projection
-------------------------------
if 1 = dbo.DPR_FGIProjectionRootRunning ('LDPDomain')
 begin
	 delete @ObjectKeysToCheck

	 insert into @ObjectKeysToCheck(Parameter1, Parameter2)
	 select  cu.UID_Parameter, ro.ObjectKeyRoot
		from QBMDBQueueCurrent cu join @Sourcedata sd on cu.UID_Parameter = sd.Element
								join LDAPGroup g on sd.AssignedElement = g.UID_LDAPGroup
								join LDP_VElementAndRoot ro on g.XObjectKey = ro.ObjectKeyElement
		-- bei mssql reduziert sich das dadurch auf genau 1 Seek (nur die eine Teilquery aus der View):
		where ro.ElementTable = 'LDAPGroup'
		 and cu.SlotNumber = @SlotNumber

	 exec @RowsToReset = DPR_PSlotResetWhileProjection @SlotNumber, 	@ObjectKeysToCheck, @MyName

		if @RowsToReset > 0
		 begin
			delete @Sourcedata
				from @Sourcedata s join QBMDBQueueCurrent c on s.Element = c.UID_Parameter
				where c.SlotNumber = dbo.QBM_FGIDBQueueSlotResetType('Sync')
					and c.UID_Task = 'SDL-K-LDAPAccountInLDAPGroup'
		 end
 end 
-----------------------------------------------------------------------------------------------
--  Feststellen, ob sich die Menge an GlobalenGruppen gendert hat
--   (durch Vergleich der  Mengen vorher und nachher )  

exec QBM_PDBQueueCalculateDelta @SourceData,
								 @DeltaQuantity = 0,
							@DeltaDelete = 0,
							@DeltaInsert = 1,
							@DeltaOrigin = 1, 
							@CountDeltaQantity = @CountDeltaQantity output , @CountDeltaOrigin = @CountDeltaOrigin output
							, @UseIsInEffect = 1
							, @SlotNumber = @SlotNumber 


if @CountDeltaOrigin > 0 
 begin
	exec QBM_PMNTableOriginUpdate 'LDAPAccountInLDAPGroup', 'UID_LDAPAccount', 'UID_LDAPGroup'
 end


if @CountDeltaQantity > 0 
 begin
	exec QBM_PMNTableInsert 'LDAPAccountInLDAPGroup', 'UID_LDAPAccount', 'UID_LDAPGroup',  @TargetIsView = 0
																			, @FKTableNameElement = 'LDAPAccount'
																			, @FKColumnNameElement = 'UID_LDAPAccount'
-- wegen Beschleunigung CompareAndXXX zurücksetzen der ModifyTimeStamp in der LDAPGroup
-- update LDAPGroup 
--		set ModifyTimeStamp = ''
--	where exists ( select top 1 1 from -- durch u n i o n kann distinct entfallen
--					 (	select AssignedElement as uid_LDAPGroup
--								from #QBMDeltaInsert 
--						u n i o n 
--						select AssignedElement
--								from #QBMDeltaOrigin 
--								where XOrigin = 0
--					 ) as x 
--					where x.uid_LDAPGroup = LDAPGroup.uid_LDAPGroup
--				)
--		and ModifyTimeStamp > ' '

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
	                                	        	

ende:

end
go



