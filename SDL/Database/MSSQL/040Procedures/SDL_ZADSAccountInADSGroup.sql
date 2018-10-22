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
   --  ZusatzProzedur SDL_ZADSAccountInADSGroup
   --------------------------------------------------------------------------------  

exec QBM_PProcedureDrop 'SDL_ZADSAccountInADSGroup' 
go


---<summary>Fills and corrects the table ADSAccountInADSGroup</summary>
---<remarks>Die UID der ADSAccounts werden in der Hilfstabelle QBMDBQueueCurrent übergeben</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

---<seealso cref="QBM_PCursorDrop" type="Procedure">Procedure QBM_PCursorDrop</seealso>
---<seealso cref="QBM_FCVElementToObjectKey1" type="Function">Function QBM_FCVElementToObjectKey1</seealso>
---<seealso cref="QBM_FGIIsSimulationMode" type="Function">Function QBM_FGIIsSimulationMode</seealso>
---<seealso cref="QBM_FGIErrorMessage" type="Function">Function QBM_FGIErrorMessage</seealso>


/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-ADSAccountInADSGroup'  -- (730724)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-ADSAccountInADSGroup'
		, @Operation = 'SDL-K-ADSAccountInADSGroup'
		, @ProcedureName = 'SDL_ZADSAccountInADSGroup'
		, @IsBulkEnabled = 1
		, @CountParameter = 1
		, @MaxInstance = 1000
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate =  null 
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = 'ADS-K-ADSAccountInADSGroup'
		
*/

create procedure SDL_ZADSAccountInADSGroup (@SlotNumber int)
 
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



declare @RowsToReset int -- CountItems mit -1 zurückzu setzender Jobs

-- declare @GroupOld varchar(38)
declare @MembersIdentifier nvarchar(400)
-- / für das MembersToAdd/Del - Verfahren


-- 16059
declare @MyName nvarchar(64) = object_name(@@procid)
declare @ObjectKeysToCheck QBM_YParameterList

BEGIN TRY



select @RowsToReset = 0

	exec QBM_PSlotResetOnMissingItem  @SlotNumber, 'ADSAccount', 'uid_ADSAccount'

-------------------------------
-- zurücksetzen,  projection
-------------------------------
if 1 = dbo.DPR_FGIProjectionRootRunning ('ADSDomain')
 begin
	 delete @ObjectKeysToCheck

	 insert into @ObjectKeysToCheck(Parameter1, Parameter2)
	 select  cu.UID_Parameter, ro.ObjectKeyRoot
		from QBMDBQueueCurrent cu join AdsAccount a on a.UID_ADSAccount = cu.UID_Parameter
								join ADS_VElementAndRoot ro on a.XObjectKey = ro.ObjectKeyElement
		-- bei mssql reduziert sich das dadurch auf genau 1 Seek (nur die eine Teilquery aus der View):
		where ro.ElementTable = 'AdsAccount'
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
	from QBMDBQueueCurrent cu join ADSAccount x on cu.UID_Parameter = x.UID_ADSAccount
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


-- alle bisherigen Gruppen des ADSAccounts merken 

insert into @SourceData(
						IsUpcommingContent, XOriginAfter
						, Element, AssignedElement, XOriginBefore
						, XIsInEffectBefore, XIsInEffectAfter
						)

	select 0, 0
			, aig.uid_ADSaccount, aig.uid_ADSgroup, aig.XOrigin 
			, aig.XIsInEffect, 0
	from ADSAccountInADSGroup aig join QBMDBQueueCurrent x on uid_adsaccount = x.uid_parameter
																and x.SlotNumber = @SlotNumber
										join ADSGroup g on aig.uid_adsGroup = g.uid_adsgroup
-- 20588
--														and g.I s D y n a m i c G r o u p = 0 
														and g.IsApplicationGroup = 1
    where aig.XMarkedForDeletion & dbo.QBM_FGIBitPatternXMarkedForDel('|Delay|', 0) = 0


 --- # statt der vorhergehenden Zeilen if-Konstruktion
  -- configparm ist 0 , alles bleibt wie bisher
 -- oder Configparm steht auf 1 dann machen wir 
	-- alle nicht-Applikationsgruppen
	-- u n i o n
	-- alle Master-Applikationsgruppen der Subapplikationsgruppen
	-- und die Master-Applikationsgruppe selber auch
 -- gg.cn like a.Ident_SectionName + @irgendeinsuffix   and

	
-- Fallunterscheidung
-- unter der Annahme, daß  DomainGroup , App-Group und normale Gruppen untereinander disjunkte mengen sind
-- normale Gruppen immer zu machen

insert into @SourceData(
						IsUpcommingContent, XOriginBefore
						, Element, AssignedElement, XOriginAfter
						, XIsInEffectBefore, XIsInEffectAfter
						)

	select 1, 0
			, uid_ADSaccount, uid_ADSgroup,  dbo.QBM_FGIBitPatternXOrigin('|Inherit|', 0)
			, 0, y.XIsInEffect 
  from (
   select x.uid_ADSaccount, x.uid_ADSgroup, dbo.TSB_FGIUserInGroupValid ( p.IsInActive, p.IsTemporaryDeactivated, p.XMarkedForDeletion, bh.PFDInheritGroup, bh.PTDInheritGroup, bh.PMDInheritGroup, 0, p.IsSecurityIncident, bh.PSIInheritGroup, x.AccountDisabled, bh.ADAInheritGroup) as  XIsInEffect 
     from (
		-- 2. Applikationsgruppen 
		-- neu 2001-08-28 : im Container laut Prferenzregel
		-- neu 2002-10-25 : Prferenzregel ber view
		   select nt.uid_ADSaccount, gg.uid_ADSgroup, c.UID_ADSDomain , nt.uid_person
					, nt.AccountDisabled
					, nt.UID_TSBAccountDef
					, nt.UID_TSBBehavior
					 --- ,nt.cn,  gg.cn, gg.samaccountname    -- nur für bersicht in Testphase
			 from QBMDBQueueCurrent x  join ADSaccount nt on nt.uid_ADSAccount = x.uid_parameter 
														and x.SlotNumber = @SlotNumber
														-- entfällt wegen 25448
														--and nt.XMarkedForDeletion & dbo.QBM_FGIBitPatternXMarkedForDel('|Delay|', 0) = 0
														and nt.isappaccount = 1 
					join ADSContainer c on nt.uid_ADSContainer = c.uid_ADSContainer
					join personhasapp pha on nt.uid_person = pha.uid_person 
											and pha.XOrigin > 0 and pha.XIsInEffect = 1
					join  application a on pha.uid_application = a.uid_application 
					join ADSgroup gg  on a.Ident_SectionName = gg.cn 
									and gg.IsApplicationGroup = 1 
-- 20588
--									and gg.I s D y n a m i c G r o u p = 0 
					join SDL_VADSNearestAppContainer co on gg.uid_ADSContainer = co.uid_Appcontainer 
									and co.uid_AccountContainer = nt.uid_adscontainer
-- wegen Buglist 10313
		where  dbo.TSB_FGIGroupAccountMatching( gg.MatchPatternForMembership, nt.MatchPatternForMembership) = 1
			and dbo.QBM_FGIConfigparmValue('Software\Application') > ' '


	) as x join ADSDomain d on x.UID_ADSDomain = d.UID_ADSDomain
		left outer join person p on x.uid_person = p.uid_person
-- 12566
			left outer join TSBBehavior bh on x.UID_TSBBehavior = bh.UID_TSBBehavior
-- / 12566
--	group by x.uid_ADSaccount, x.uid_ADSgroup
	) as y
-- hier: wenn die Gruppen-Domäne im Projektor-Lauf ist
-------------------------------
-- zurücksetzen,  projection
-------------------------------
if 1 = dbo.DPR_FGIProjectionRootRunning ('ADSDomain')
 begin
	 delete @ObjectKeysToCheck

	 insert into @ObjectKeysToCheck(Parameter1, Parameter2)
	 select  cu.UID_Parameter, ro.ObjectKeyRoot
		from QBMDBQueueCurrent cu join @Sourcedata sd on cu.UID_Parameter = sd.Element
										join AdsGroup g on sd.AssignedElement = g.uid_adsGroup
								join ADS_VElementAndRoot ro on g.XObjectKey = ro.ObjectKeyElement
		-- bei mssql reduziert sich das dadurch auf genau 1 Seek (nur die eine Teilquery aus der View):
		where ro.ElementTable = 'AdsGroup'
		 and cu.SlotNumber = @SlotNumber

	 exec @RowsToReset = DPR_PSlotResetWhileProjection @SlotNumber, 	@ObjectKeysToCheck, @MyName

		 if @RowsToReset > 0
		  begin
			delete @Sourcedata
				from @Sourcedata s join QBMDBQueueCurrent c on s.Element = c.UID_Parameter
				where c.SlotNumber = dbo.QBM_FGIDBQueueSlotResetType('Sync')
					and c.UID_Task = 'ADS-K-ADSAccountInADSGroup'

		  end	-- if @@rowcount > 0
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
	exec QBM_PMNTableOriginUpdate 'ADSAccountInADSGroup', 'UID_ADSAccount', 'UID_ADSGroup'
 end


if @CountDeltaQantity > 0 
 begin
	exec QBM_PMNTableInsert 'ADSAccountInADSGroup', 'UID_ADSAccount', 'UID_ADSGroup', @TargetIsView = 0
																			, @FKTableNameElement = 'ADSAccount'
																			, @FKColumnNameElement = 'UID_ADSAccount'
 end


--if @CountDeltaQantity > 0 
-- begin
 
---- wegen Beschleunigung CompareAndXXX zurücksetzen der USN in der ADSGroup
-- update ADSGroup 
--		set O b j e c t U S N = ''
--	where uid_ADSGroup in (select UID_ADSGroup
--							from @AffectedGroups
--						)
--		and O b j e c t U S N > ' '
-- end

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



