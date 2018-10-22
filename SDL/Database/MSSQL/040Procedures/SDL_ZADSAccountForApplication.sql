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
   --  Hilfsprozedur SDL_ZADSAccountForApplication
   --------------------------------------------------------------------------------  

----------------------------------------------------------------------------------------
-- neuberechnen der Gruppenmitgliedschaft fr alle Accounts, die eine Applikation haben
--     Optional ab einem bestimmten Container abwrts
----------------------------------------------------------------------------------------

-- Prozedur ist nicht Bulk-Enabled

-- exec SDL_ZADSAccountForApplication 'cf3fabd8-cc00-4089-9429-c7539481f8f8'

exec QBM_PProcedureDrop 'SDL_ZADSAccountForApplication'
go


---<summary>Recalculation of group membership for all accounts that have an application</summary>
---<param name="uid_Application">Application UID to examine</param>
---<param name="uid_adscontainer">Optional: serach under this container</param>
---<param name="GenProcID" type="varchar(38)">Process ID of the source operation</param>
---<remarks>
--- Recalculation task ADSAccountInADSGroup is set for all accounts found 
---</remarks>
---<example>Function exclusively for use in the DBScheduler</example>

/*
 -- exec MDK_PDBQueueTaskDefText 'SDL-K-AllADSAccountsForApplication'  -- (730730)
	
exec MDK_PDBQueueTaskDefine 
		@UID_Task = 'SDL-K-AllADSAccountsForApplication'
		, @Operation = 'ALLADSACCOUNTSFORAPPLICATION'
		, @ProcedureName = 'SDL_ZADSAccountForApplication'
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

create procedure SDL_ZADSAccountForApplication (@SlotNumber int
												, @uid_Application varchar(38) 
												, @uid_adscontainer varchar(38)-- Muster . Wenn nicht bekannt,  muß % übergeben werden
												, @GenProcID varchar(38)
												) 
 
-- with encryption 
as
 begin
--   declare @tmp varchar(38)

declare @SQLcmd nvarchar(1024)

-- in MSSQL wird das z.Z. noch aus dem Trigger direkt aufgerufen, 
--	declare @ParameterWorkLight table (uid_parameter varchar(38)collate database_default )
-- wir nehmen hier @ParameterWorkLight, da ohne U I D _ D i a l o g D B Q u e u e u.ä

declare @DBQueueElements QBM_YDBQueueRaw 
declare @DebugLevel char(1) = 'W'

BEGIN TRY

-- prfen, ob das betreffende Objekt noch existiert
  if not exists (select top 1 1 from Application where uid_application = isnull(@uid_Application,''))
	begin
	  select @SQLcmd = N'Application ' + rtrim(@uid_Application) + ' not exists, Job ALLADSACCOUNTSFORAPPLICATION was killed'
	  exec QBM_PJournal @SQLcmd, @@procid, 'D', @DebugLevel
	  goto ende
		-- Rckkehr ohne Fehler, damit der Job gelscht wird
	end


  

  if @uid_adscontainer = '%'
    begin
       -- dann fr alle Accounts
		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
		 from 
		 (
			select distinct a.uid_adsaccount as uid
				from ADSAccount a join personhasapp pha on pha.UID_Application = @UID_Application 
														and pha.XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
										and a.uid_person = pha.uid_person
		) as x										
    end
  else
   begin
      -- es ist ein Container angegeben, dann ab diesem oder dessen Parent   
	 if '' = (select isnull(uid_parentadscontainer,'') from adscontainer where uid_adscontainer = @uid_adscontainer)
	  begin
	      -- kein Parent, dann nur alle die aus seiner Domain (da ber ihm Domain-Root)
		--print N'-- kein parent'

			insert into @DBQueueElements (object, subobject, genprocid)
			select x.uid, null, @GenProcID
			 from 
			 (
			    select distinct a.uid_adsaccount as uid
				from ADSAccount a join personhasapp pha on pha.UID_Application = @UID_Application 
										and pha.XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
										and a.uid_person = pha.uid_person
					join (select a.uid_adsaccount
						   from adscontainer s,  adsaccount a, adscontainer ac
						where s.uid_adscontainer = @uid_adscontainer
							and a.uid_adscontainer = ac.uid_adscontainer
						 	and  s.uid_ADSDomain = ac.uid_ADSDomain
					 		and a.isappaccount = 1
						)as x on x.uid_adsaccount = a.uid_adsaccount
			 ) as x

	  end
	 else
	  begin
	       -- es gibt einen Parentcontainer, dann dessen Kinderlein
--	  select canonicalname from adscontainer where uid_adscontainer = (select uid_parentadscontainer from adscontainer where uid_adscontainer = @uid_adscontainer)
	
		--print N'--Parent gefunden'

		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
		 from 
		 (
		    select distinct a.uid_adsaccount  as uid
			from ADSAccount a join personhasapp pha on pha.UID_Application = @UID_Application 
													and pha.XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
								and a.uid_person = pha.uid_person
					join 
					(select a.uid_adsaccount
						from adscontainer s, adscontainer p, adscontainer c, adsaccount a
						  where s.uid_parentAdscontainer = p.uid_adscontainer
							and s.uid_adscontainer = @uid_adscontainer
							and c.canonicalname like p.canonicalname + N'/%'
							and a.uid_adscontainer = c.uid_adscontainer
						and a.isappaccount = 1
					) as x on a.uid_adsaccount = x.uid_adsaccount
			) as x


	  end
   end



exec QBM_PDBQueueInsert_Bulk 'SDL-K-ADSAccountInADSGroup', @DBQueueElements 



-- erst mal wieder aufrumen
delete @DBQueueElements

--- neu fr die Hardware 
  if @uid_adscontainer  = '%'
    begin
       -- dann fr alle ADSMachine
		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
		 from 
		 (
		    select distinct m.uid_ADSMachine as uid
				from Hardware h join WorkDeskhasapp wha on wha.UID_Application = @UID_Application 
														and wha.XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
									and h.uid_WorkDesk = wha.uid_WorkDesk
								join ADSMachine m on h.uid_Hardware = m.uid_Hardware
		 ) as x

    end
  else
   begin
      -- es ist ein Container angegeben, dann ab diesem oder dessen Parent   
	 if '' = (select isnull(uid_parentadscontainer,'') from adscontainer where uid_adscontainer = @uid_adscontainer)
	  begin
	      -- kein Parent, dann nur alle die aus seiner Domain (da ber ihm Domain-Root)
		--print N'-- kein parent'

			insert into @DBQueueElements (object, subobject, genprocid)
			select x.uid, null, @GenProcID
			 from 
			 (
			    select distinct m.uid_ADSMachine as uid
				from Hardware h join WorkDeskhasapp wha on UID_Application = @UID_Application 
														and wha.XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
									and h.uid_WorkDesk = wha.uid_WorkDesk
								join ADSMachine m on h.uid_Hardware = m.uid_Hardware

		-- alle Accounts der Domne
				join (select m.uid_ADSMachine
					   from adscontainer s,  Hardware a, adscontainer ac, ADSMachine m
						where s.uid_adscontainer = @uid_adscontainer
						and a.uid_Hardware = m.uid_Hardware
						and m.uid_adscontainer = ac.uid_adscontainer
						 and  s.UID_ADSDomain = ac.uid_ADSDomain
					) as x on m.uid_ADSMachine = x.uid_ADSMachine
				) as x


	  end
	 else
	  begin
	       -- es gibt einen Parentcontainer, dann dessen Kinderlein
	
		--print N'--Parent gefunden'
		insert into @DBQueueElements (object, subobject, genprocid)
		select x.uid, null, @GenProcID
		 from 
		 (
	    select distinct m.uid_ADSMachine as uid
			from Hardware h join WorkDeskhasapp wha on wha.UID_Application = @UID_Application 
													and wha.XOrigin > 0 -- ohne XIsInEffect-Test, könnte ja jederzeit wieder angehen
								and h.uid_WorkDesk = wha.uid_WorkDesk
							join ADSMachine m on h.uid_Hardware = m.UID_Hardware
				join 	(select m.uid_ADSMachine
					from adscontainer s, adscontainer p, adscontainer c, Hardware a, ADSMachine m
					  where s.uid_parentAdscontainer = p.uid_adscontainer
						and s.uid_adscontainer = @uid_adscontainer
						and c.canonicalname like p.canonicalname + N'/%'
						and a.uid_Hardware = m.uid_Hardware
						and m.uid_adscontainer = c.uid_adscontainer
					) as x on m.uid_ADSMachine = x.uid_ADSMachine
			) as x

	  end
   end


 exec QBM_PDBQueueInsert_Bulk 'ADS-K-ADSMachineInADSGroup', @DBQueueElements 


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





