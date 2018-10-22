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
   --  Hilfsprozedur SDL_ZLDPAccountForApplication
   --------------------------------------------------------------------------------  

----------------------------------------------------------------------------------------
-- neuberechnen der Gruppenmitgliedschaft fr alle Accounts, die eine Applikation haben
--     Optional ab einem bestimmten Container abwrts
----------------------------------------------------------------------------------------

-- Prozedur ist nicht Bulk-Enabled


-- exec SDL_ZLDPAccountForApplication 'cf3fabd8-cc00-4089-9429-c7539481f8f8'

exec QBM_PProcedureDrop 'SDL_ZLDPAccountForApplication'
go


---<summary>Recalculation of group membership for all accounts that have an application</summary>
---<param name="uid_Application">Application UID to examine</param>
---<param name="uid_LDAPContainer">Optional: serach under this container</param>
---<param name="GenProcID" type="varchar(38)">Process ID of the source operation</param>
---<remarks>
--- Recalculation task LDAPAccountInLDAPGroup is set for all accounts found 
---</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-AllLDAPAccountsForApplication'  -- (730734)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-AllLDAPAccountsForApplication'
		, @Operation = 'ALLLDAPACCOUNTSFORAPPLICATION'
		, @ProcedureName = 'SDL_ZLDPAccountForApplication'
		, @IsBulkEnabled = 0
		, @CountParameter = 2
		, @MaxInstance = 1000
		, @IsNoGenProcIDCheck = 0
		, @UID_TaskAutomatedPredecessor = null
		, @UID_TaskAutomatedFollower = null
		, @QueryForRecalculate = 'select	uid_application, ''%''	from	application	where	''1''	=	dbo.QBM_FGIConfigparmValue(''Software\Application'')'
															  
		, @IsUnusedInSimulation = 0
		, @IsWithoutTransaction = 0
		, @UID_TaskParent = null
		
*/

create procedure SDL_ZLDPAccountForApplication (@SlotNumber int
												, @uid_Application varchar(38) 
												, @uid_LDAPContainer varchar(38) -- Muster . Wenn nicht bekannt,  muß % übergeben werden
												, @GenProcID varchar(38)
												) 
 
-- with encryption 
as
 begin
   declare @tmp varchar(38)

declare @SQLcmd nvarchar(1024)

declare @DBQueueElements QBM_YDBQueueRaw 
declare @DebugLevel char(1) = 'W'

BEGIN TRY

  if not exists (select top 1 1 from Application where uid_application = isnull(@uid_Application,''))
	begin
	  select @SQLcmd = N'Application ' + rtrim(@uid_Application) + ' not exists, Job ALLLDAPACCOUNTSFORAPPLICATION was killed'
	  exec QBM_PJournal @SQLcmd, @@procid, 'D', @DebugLevel
	  goto ende
		-- Rckkehr ohne Fehler, damit der Job gelscht wird
	end


  

  if @uid_LDAPContainer = '%'
    begin
       -- dann fr alle Accounts

		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
		from  (
			select distinct a.uid_LDAPAccount as uid
			from LDAPAccount a join personhasapp pha on pha.UID_Application = @UID_Application 
									and pha.XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
									and a.uid_person = pha.uid_person
									and a.isappaccount = 1
			) as x
										
    end
  else
   begin
      -- es ist ein Container angegeben, dann ab diesem oder dessen Parent   
	 if '' = (select isnull(uid_parentLDAPContainer,'') from LDAPContainer where uid_LDAPContainer = @uid_LDAPContainer)
	  begin
	      -- kein Parent, dann nur alle die aus seiner Domain (da ber ihm Domain-Root)
		--print N'-- kein parent'

			insert into @DBQueueElements (object, subobject, genprocid)
			select x.uid, null, @GenProcID
			from  (
			    select distinct a.uid_LDAPAccount as uid
				from LDAPAccount a join personhasapp pha on pha.UID_Application = @UID_Application 
										and a.uid_person = pha.uid_person
										and a.isappaccount = 1
										and pha.XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
					join (select a.uid_LDAPAccount
						   from LDAPContainer s,  LDAPAccount a, LDAPContainer ac
						where s.uid_LDAPContainer = @uid_LDAPContainer
							and a.uid_LDAPContainer = ac.uid_LDAPContainer
						 	and  s.uid_ldpDomain = ac.uid_ldpDomain
					 		and a.isappAccount = 1
						)as x on x.uid_LDAPAccount = a.uid_LDAPAccount
				 ) as x

	  end
	 else
	  begin
	       -- es gibt einen ParentContainer, dann dessen Kinderlein
		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
		from  (
		    select distinct a.uid_LDAPAccount  as uid
			from LDAPAccount a join personhasapp pha on pha.UID_Application = @UID_Application 
								and a.uid_person = pha.uid_person
								and a.isappaccount = 1
								and pha.XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
					join 
					(select a.uid_LDAPAccount
						from LDAPContainer s, LDAPContainer p, LDAPContainer c, LDAPAccount a
						  where s.uid_parentLDAPContainer = p.uid_LDAPContainer
							and s.uid_LDAPContainer = @uid_LDAPContainer
							and c.canonicalname like p.canonicalname + N'/%'
							and a.uid_LDAPContainer = c.uid_LDAPContainer
						and a.isappAccount = 1
					) as x on a.uid_LDAPAccount = x.uid_LDAPAccount
			 ) as x


	  end
   end


exec QBM_PDBQueueInsert_Bulk 'SDL-K-LDAPAccountInLDAPGroup', @DBQueueElements  


-- erst mal wieder aufrumen
delete @DBQueueElements

--- neu fr die LDPMachine 
  if @uid_LDAPContainer = '%'
    begin
       -- dann fr alle LDPMachine
		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
		from  (
		    select distinct m.uid_LDPMachine as uid
				from Hardware h join WorkDeskhasapp wha on wha.UID_Application = @UID_Application 
														and h.uid_WorkDesk = wha.uid_WorkDesk
														and wha.XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
								join LDPMachine m on m.uid_Hardware = h.uid_Hardware
			 ) as x

    end
  else
   begin
      -- es ist ein Container angegeben, dann ab diesem oder dessen Parent   
	 if '' = (select isnull(uid_parentLDAPContainer,'') from LDAPContainer where uid_LDAPContainer = @uid_LDAPContainer)
	  begin
	      -- kein Parent, dann nur alle die aus seiner Domain (da ber ihm Domain-Root)
		--print N'-- kein parent'

			insert into @DBQueueElements (object, subobject, genprocid)
			select x.uid, null, @GenProcID
			from  (
			    select distinct m.uid_LDPMachine as uid
				from Hardware h join WorkDeskhasapp wha on UID_Application = @UID_Application 
														and h.uid_WorkDesk = wha.uid_WorkDesk
														and wha.XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
								join LDPMachine m on h.uid_Hardware = m.uid_Hardware
		-- alle Accounts der Domne
				join (select m.uid_LDPMachine
					   from LDAPContainer s,  Hardware a, LDAPContainer ac, LDPMachine m
						where s.uid_LDAPContainer = @uid_LDAPContainer
						and m.uid_LDAPContainer = ac.uid_LDAPContainer
						and m.uid_Hardware = a.uid_Hardware
						 and  s.uid_LDPDomain = ac.uid_LDPDomain
					) as x on m.uid_LDPMachine = x.uid_LDPMachine
				) as x


	  end
	 else
	  begin
	       -- es gibt einen ParentContainer, dann dessen Kinderlein
	
		--print N'--Parent gefunden'
		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
		from  (
		    select distinct m.uid_LDPMachine as uid
			from Hardware h join WorkDeskhasapp wha on wha.UID_Application = @UID_Application 
													and h.uid_WorkDesk = wha.uid_WorkDesk
													and wha.XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
							join LDPMachine m on h.uid_Hardware = m.uid_Hardware
				join 	(select m.uid_LDPMachine
					from LDAPContainer s, LDAPContainer p, LDAPContainer c, Hardware a, LDPMachine m
					  where s.uid_parentLDAPContainer = p.uid_LDAPContainer
						and s.uid_LDAPContainer = @uid_LDAPContainer
						and c.canonicalname like p.canonicalname + N'/%'
						and a.uid_Hardware = m.uid_Hardware
						and m.uid_LDAPContainer = c.uid_LDAPContainer
					) as x on m.uid_LDPMachine = x.uid_LDPMachine
				) as x

	  end
   end


 exec QBM_PDBQueueInsert_Bulk 'LDP-K-LDPMachineInLDAPGroup', @DBQueueElements 


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
	return
 end
go
