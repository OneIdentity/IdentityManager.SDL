
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






--------------------------------------------------------------------
-- SDL_GDBQueueTasks
-- Package Body
--------------------------------------------------------------------
-- folgende Bereiche sind definiert:

-- SoftwareDistribution
-- Licence
--------------------------------------------------------------------



Create Or Replace Package Body SDL_GDBQueueTasks As




-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- SoftwareDistribution
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------
-- Procedure ZMachinesForDriver
-- stellt für Maschinen, die die Applikation haben	Jobs zum Schreiben der CName ein
-----------------------------------------------------------------------------------------------
Procedure ZMachinesForDriver (v_SlotNumber number
							, v_uid_Driver varchar2
							, v_dummy varchar2
							, v_GenProcID varchar2
							)
as

     -- für die Folgeaufträge
     v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();

Begin
		select mhd.UID_hardware, null, v_GenProcID
				bulk collect into v_DBQueueElements
		  From machinehasdriver mhd
		 Where uid_driver = v_uid_driver;

		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-HardwareUpdateCNAME', v_DBQueueElements);

Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);



end ZMachinesForDriver;
-----------------------------------------------------------------------------------------------
-- / Procedure ZMachinesForDriver
-----------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------
-- Procedure ZMachinesForApplication
-- stellt für Maschinen, die die Applikation haben	Jobs zum Schreiben der CName ein
-----------------------------------------------------------------------------------------------
Procedure ZMachinesForApplication (v_SlotNumber number
								, v_uid_Application varchar2
								, v_dummy varchar2
								, v_GenProcID varchar2
								)
as


     -- für die Folgeaufträge
     v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();

	v_exists	QBM_GTypeDefinition.YBool;
Begin
	Begin
			select x.UID_object, null, v_GenProcID
				bulk collect into v_DBQueueElements
			  From (Select Distinct h.uid_hardware As uid_object
					  From	   hardware h
						   Join
							   workdeskhasapp wha
						   On h.uid_workdesk = wha.uid_workdesk
						  And (h.isPC = 1
							Or	h.isServer = 1)
						  And wha.uid_application = v_uid_application
						  and wha.XOrigin > 0
					) x;

		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-HardwareUpdateCNAME', v_DBQueueElements);

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		If QBM_GGetInfo2.FGIConfigParmValue('TARGETSYSTEM\ADS\HARDWAREINAPPGROUP') is not null Then
			select x.UID_object, null, v_GenProcID
				bulk collect into v_DBQueueElements
				  From (Select Distinct m.uid_ADSMachine As uid_object
						  From hardware h Join workdeskhasapp wha
							   On h.uid_workdesk = wha.uid_workdesk
							   join ADSMachine m on h.uid_hardware = m.uid_hardware
							  where wha.uid_application = v_uid_application
							  and wha.XOrigin > 0
						) x;

			QBM_GDBQueue.PDBQueueInsert_Bulk('ADS-K-ADSMachineInADSGroup', v_DBQueueElements);

		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

end ZMachinesForApplication;
-----------------------------------------------------------------------------------------------
-- / Procedure ZMachinesForApplication
-----------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------
-- Procedure ZLDPAppContainerInsert
-- legt in einem angegebenen LDAPContainer Applikationsgruppen für alle Applikationen an
-- für die noch keine Applikationsgruppe in diesem Container existiert
-- jedoch nur die Applikationen, die Profilapplikationen sind
-----------------------------------------------------------------------------------------------
Procedure ZLDPAppContainerInsert (v_SlotNumber number
								, v_uid_LDAPcontainer varchar2
								, v_dummy varchar2
								, v_GenProcID varchar2
								)
as

	v_uid_application		   QBM_GTypeDefinition.YGuid;
	v_ident_sectionname 	   varchar2(255);
	v_cmd					   varchar2(1024);
	-- IR 2003-03-06 Wegen Buglist 6390
	v_domain				   varchar2(64);
	v_exists				   QBM_GTypeDefinition.YBool;

	Cursor schrittAppContainerInsert Is
		Select uid_application, ident_sectionname
		  From application
		 Where Not Exists
				   (Select 1
					  From LDAPgroup
					 Where uid_LDAPcontainer = v_uid_LDAPcontainer
					   And isapplicationgroup = 1
					   And cn = SDL_GConvert.FCVADSCommonName(application.ident_sectionname))
		   And application.isprofileapplication = 1;

	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();
Begin
	




	-- prüfen, ob das betreffende Objekt noch existiert
	Begin
		Select 1
		  Into v_exists
		  From DUAL
		 Where Exists
				   (Select 1
					  From LDAPContainer
					 Where uid_LDAPContainer = v_uid_LDAPContainer);
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
	End;

	If v_exists = 0 Then
		v_cmd := 'LDAPContainer ' || RTRIM(v_uid_LDAPContainer) || ' not exists, Job LDAPAPPCONTAINERINSERT was killed';
		QBM_GCommon2.PWriteDialogJournal(v_cmd, 'DBScheduler', 'DBScheduler');
	-- Rückkehr ohne Fehler, damit der Job gelöscht wird
	Else
		-- IR 2003-03-06 Wegen Buglist 6390
		Begin
			Select d.ident_Domain
			  Into v_domain
				from LDAPContainer c join ldpdomain d on c.uid_ldpdomain = d.uid_ldpdomain
				where c.uid_LDAPContainer = v_uid_LDAPContainer
			   And ROWNUM = 1;
		Exception
			When NO_DATA_FOUND Then
				Null;
		End;

		Open schrittAppContainerInsert;

		Loop
			Fetch schrittAppContainerInsert
			Into v_uid_application, v_ident_sectionname;

			Exit When schrittAppContainerInsert%Notfound;
			QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);
			-- IR 2003-03-06 Wegen Buglist 6390
			SDL_GSoftwareDistribution.PDistributeAppGroup(v_ident_sectionname, v_domain, v_ident_sectionname);
		End Loop;

		Close schrittAppContainerInsert;
	End If;

	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);

end ZLDPAppContainerInsert;
-----------------------------------------------------------------------------------------------
-- / Procedure ZLDPAppContainerInsert
-----------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------
-- Procedure ZLDPAppContainerDelete
-- löscht alle Applikationsgruppen in einem angegebenen LDAP-Container
-----------------------------------------------------------------------------------------------
Procedure ZLDPAppContainerDelete (v_SlotNumber number
								, v_uid_LDAPcontainer varchar2
								, v_dummy varchar2
								, v_GenProcID varchar2
								)
as

	v_uid_LDAPgroup 		   QBM_GTypeDefinition.YGuid;
	v_where 				   varchar2(2000);
	v_cmd					   varchar2(1024);
	v_exists				   QBM_GTypeDefinition.YBool;
	v_BasisObjectKey		   JobQueue.BasisObjectKey%Type;

	Cursor schrittAppContainerDelete Is
		Select uid_LDAPgroup
		  From LDAPgroup
		 Where uid_LDAPcontainer = v_uid_LDAPcontainer
		   And isApplicationgroup = 1;

     -- für die Folgeaufträge
     v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();

	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();
Begin
	



	-- prüfen, ob das betreffende Objekt noch existiert
	Begin
		Select 1
		  Into v_exists
		  From DUAL
		 Where Exists
				   (Select 1
					  From LDAPContainer
					 Where uid_LDAPContainer = v_uid_LDAPContainer);
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
	End;

	If v_exists = 0 Then
		v_cmd := 'LDAPContainer ' || RTRIM(v_uid_LDAPContainer) || ' not exists, Job LDAPAPPCONTAINERDELETE was killed';
		QBM_GCommon2.PWriteDialogJournal(v_cmd, 'DBScheduler', 'DBScheduler');
	-- Rückkehr ohne Fehler, damit der Job gelöscht wird
	Else
		Open schrittAppContainerDelete;

		Loop
			Fetch schrittAppContainerDelete Into v_uid_LDAPgroup;

			Exit When schrittAppContainerDelete%Notfound;

			-- 13678 für die betroffenen Nutzer Mitgliedschaften neu rechnen
			select x.UID_object, null, v_GenProcID
				bulk collect into v_DBQueueElements
				  From	   (Select uid_LDAPAccount As uid_object
							  From LDAPaccountinLDAPgroup
							 Where uid_LDAPGroup = v_uid_LDAPGroup and XOrigin > 0) x;

				QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-LDAPAccountInLDAPGroup', v_DBQueueElements);


			-- / 13678

			If UPPER(v_GenprocID) = 'SIMULATION' Then
				QBM_GCommon.PClientContextSet('SIMULATION', 'DBScheduler', 1);

				Delete LDAPgroup
				 Where uid_LDAPgroup = v_uid_LDAPgroup;
			Else -- if upper(v_GenprocID) = 'SIMULATION'
				v_where := ' uid_LDAPGroup = ''' || v_uid_LDAPgroup || '''';
				v_BasisObjectKey := QBM_GConvert2.FCVElementToObjectKey('LDAPGroup', 'UID_LDAPGroup', v_uid_LDAPgroup, v_noCaseCheck => 1);
				QBM_GJobQueue.PJobCreate_HODelete('LDAPGROUP'
											, v_where
											, v_Genprocid
											, v_BasisObjectKey	 => v_BasisObjectKey
											 );
			End If;
		End Loop;

		Close schrittAppContainerDelete;
	End If;

	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);

end ZLDPAppContainerDelete;
-----------------------------------------------------------------------------------------------
-- / Procedure ZLDPAppContainerDelete
-----------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------
-- Procedure PLDPAccountInAppGroup
-- Hilfsprozedur
-----------------------------------------------------------------------------------------------
Procedure PLDPAccountInAppGroup (v_UID_LDAPAccount  varchar2
								, v_UID_LDAPGroup	  varchar2
								, v_GenProcID		  varchar2
								)
as

	v_countrows 			   Number;
	v_exists				   QBM_GTypeDefinition.YBool;
	v_isApplicationGroup	   Number;
	v_isAppAccount			   Number;
	v_uid_person			   QBM_GTypeDefinition.YGuid;
	v_cn					   varchar2(64);
	v_uid_application		   QBM_GTypeDefinition.YGuid;
	v_cmd					   varchar2(1024);

	-- für Aufzeichnung
	v_IsSimulationMode		   QBM_GTypeDefinition.YBool;

	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();
Begin
	

	-- Ergänzung Aufzeichnung
	If QBM_GSimulation.Simulation = 1 Then
		v_IsSimulationMode := 1;
	Else
		v_IsSimulationMode := 0;
	End If;

	--/ Ergänzung Aufzeichnung

	Begin
		Select NVL(ag.IsApplicationGroup, 0), a.uid_person, ag.cn
		  Into v_IsApplicationGroup, v_uid_person, v_cn
		  From LDAPGroup ag, LDAPAccount a
		 Where ag.UId_LDAPGroup = v_UID_LDAPGroup
		   And a.uid_LDAPAccount = v_UID_LDAPAccount;
	Exception
		When NO_DATA_FOUND Then
			v_IsApplicationGroup := 0;
	End;

	If v_IsApplicationGroup = 1 Then
		v_cmd := '';

		Select COUNT(*)
		  Into v_countrows
		  From application
		 Where ident_sectionname = v_cn and IsInActive = 0;

		If v_countrows = 1 Then
			Begin
				Select uid_application
				  Into v_uid_application
				  From application
				 Where ident_sectionname = v_cn
				   And ROWNUM = 1;
			Exception
				When NO_DATA_FOUND Then
					Null;
			End;

			Select COUNT(*)
			  Into v_countrows
			  From person
			 Where uid_person Is Not Null
			   And uid_person = v_uid_person;

			Select NVL(isAppaccount, 0)
			  Into v_IsAppAccount
			  From LDAPAccount
			 Where uid_LDAPAccount = v_UID_LDAPAccount;

			If 1 = v_countrows
		   And 1 = v_IsAppAccount Then
				Begin
					Select 1
					  Into v_exists
					  From DUAL
					 Where Exists
							   (Select 1
								  From personHasApp
								 Where uid_application = v_uid_application
								   And uid_person = v_uid_person);
				Exception
					When NO_DATA_FOUND Then
						v_exists := 0;
				End;

				If v_exists = 0 Then
					QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

					-- Ergänzung Aufzeichnung
					If v_IsSimulationMode = 1 Then
						Insert Into Temp_TriggerOperation(Operation
														, BaseObjectType
														, ColumnName
														, ObjectKey
														, OldValue
														 )
							 Values ('I'
								   , 'personhasapp'
								   , null
								   , QBM_GConvert2.FCVElementToObjectKey('PersonHasApp'
													 , 'UID_Person'
													 , v_uid_person
													 , 'UID_Application'
													 , v_uid_application
													 , v_noCaseCheck => 1
													  )
								   , null
									);
					End If;

					--/ Ergänzung Aufzeichnung

					Insert Into personhasapp(uid_person
										   , uid_application
										   , xdateinserted
										   , xdateupdated
										   , xuserinserted
										   , xuserupdated
										   , XObjectKey
										   , XOrigin
											)
						 Values (v_uid_person
							   , v_uid_application
							   , GetUTCDate
							   , GetUTCDate
							   , 'BackSync'
							   , 'BackSync'
							   , QBM_GConvert2.FCVElementToObjectKey('PersonHasApp'
												 , 'UID_Person'
												 , v_uid_person
												 , 'UID_Application'
												 , v_uid_application
												 , v_noCaseCheck => 1
												  )
								, 1
								);

					v_cmd :=	'#LDS#Direct assignment to PersonHasApp implemented, user account = {0} application group = {1}.|'
							 || v_UID_LDAPAccount
							 || '|'
							 || v_uid_LDAPGroup;
				End If;

				-- egal ob personinappschon existierte oder erst eingetragen wurde:
				QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

				-- Ergänzung Aufzeichnung
				If v_IsSimulationMode = 1 Then
					Insert Into Temp_TriggerOperation(Operation
													, BaseObjectType
													, ColumnName
													, ObjectKey
													, OldValue
													 )
						 Values ('D'
							   , 'LDAPAccountinLDAPGroup'
							   , null
							   , QBM_GConvert2.FCVElementToObjectKey('LDAPAccountInLDAPGroup'
												 , 'UID_LDAPAccount'
												 , v_uid_LDAPAccount
												 , 'UID_LDAPGroup'
												 , v_uid_LDAPGroup
												 , v_noCaseCheck => 1
												  )
							   , null
								);
				End If;

				--/ Ergänzung Aufzeichnung
					 update LDAPAccountinLDAPGroup 
						set XOrigin = QBM_GCommon.FBitXOr(bitand(XOrigin, QBM_GGetInfo2.FGIBitPatternXOrigin('|Direct|', 1)), 2)
 						where uid_LDAPAccount = v_UID_LDAPAccount 
 						and uid_LDAPGroup = v_UID_LDAPGroup;
			Else
				v_cmd :=	'#LDS#Employee cannot be found, user account = {0} application group = {1}.|'
						 || v_UID_LDAPAccount
						 || '|'
						 || v_uid_LDAPGroup;
			End If;
		Else
			v_cmd :=	'#LDS#Application cannot be found, account = {0} application group = {1}.|'
					 || v_UID_LDAPAccount
					 || '|'
					 || v_uid_LDAPGroup;
		End If;
	End If;

	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);


end PLDPAccountInAppGroup;
-----------------------------------------------------------------------------------------------
-- / Procedure PLDPAccountInAppGroup
-----------------------------------------------------------------------------------------------






-----------------------------------------------------------------------------------------------
-- Procedure ZLDPAccountInAppGroup
-- diese Task regelt den Backsync, wenn im Namespace Gruppenmitgliedschaften in
-- Applikationsgruppen gefunden werden, so werden diese nicht direkt in LDAPAccountInLDAPGroup
-- eingetragen, sondern auf PersonHasApp abgebildet.
-----------------------------------------------------------------------------------------------
Procedure ZLDPAccountInAppGroup (v_SlotNumber number
								)
as

	v_uid_Object	QBM_GTypeDefinition.YGuid;
	v_uid_SubObject QBM_GTypeDefinition.YGuid;
	v_GenProcID 	QBM_GTypeDefinition.YGuid;

	Cursor c_schritt Is
		Select UID_Parameter, UID_SubParameter, GenProcID From QBMDBQueueCurrent
		where SlotNumber = v_SlotNumber;
Begin
	Open c_schritt;

	Loop
		Fetch c_schritt
		Into v_uid_Object, v_uid_SubObject, v_GenProcID;

		Exit When c_schritt%Notfound;

		PLDPAccountInAppGroup(v_uid_Object, v_uid_SubObject, v_GenProcID);
	End Loop;

	Close c_schritt;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);

end ZLDPAccountInAppGroup;
-----------------------------------------------------------------------------------------------
-- / Procedure ZLDPAccountInAppGroup
-----------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------
-- Procedure ZLDPAccountForApplication
-- neuberechnen der Gruppenmitgliedschaft für alle Accounts, die eine Applikation haben
-- Optional ab einem bestimmten Container abwärts
-----------------------------------------------------------------------------------------------
Procedure ZLDPAccountForApplication (v_SlotNumber number
									, v_uid_Application varchar2
									, v_uid_LDAPcontainer varchar2 -- Muster . Wenn nicht bekannt,  muß % übergeben werden
									, v_GenProcID varchar2
									)
as

	v_tmp					  QBM_GTypeDefinition.YGuid;

     -- für die Folgeaufträge
     v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();


	v_cmd					  varchar2(1024);
	v_exists				  QBM_GTypeDefinition.YBool;
	v_uid_parentLDAPcontainer QBM_GTypeDefinition.YGuid;
Begin
	Begin

		-- prüfen, ob das betreffende Objekt noch existiert
		Begin
			Select 1
			  Into v_exists
			  From DUAL
			 Where Exists
					   (Select 1
						  From Application
						 Where uid_application = v_uid_Application);
		Exception
			When NO_DATA_FOUND Then
				v_exists := 0;
		End;

		If v_exists = 0 Then
			v_cmd := 'Application ' || RTRIM(v_uid_Application) || ' not exists, Job ALLLDAPACCOUNTSFORAPPLICATION was killed';
			QBM_GCommon2.PWriteDialogJournal(v_cmd, 'DBScheduler', 'DBScheduler');
			Return;
			-- Rückkehr ohne Fehler, damit der Job gelöscht wird
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		If v_uid_LDAPcontainer = '%' Then
			-- dann für alle Accounts
			select distinct a.uid_LDAPaccount, null, v_GenProcID
					bulk collect into v_DBQueueElements
				  From	   LDAPAccount a
					   Join
						   personhasapp pha
					   On pha.UID_Application = v_UID_Application
					  And a.uid_person = pha.uid_person
					  where pha.XIsInEffect = 1 and pha.XOrigin > 0;
		Else
			-- es ist ein Container angegeben, dann ab diesem oder dessen Parent
			Begin
				Select uid_parentLDAPcontainer
				  Into v_uid_parentLDAPcontainer
				  From LDAPcontainer
				 Where uid_LDAPcontainer = v_uid_LDAPcontainer;
			Exception
				When NO_DATA_FOUND Then
					Null;
			End;

			If RTRIM(v_uid_parentLDAPcontainer) Is Null Then
				-- kein Parent, dann nur alle die aus seiner Domain (da über ihm Domain-Root)
				select distinct a.uid_LDAPaccount, null, v_GenProcID
					bulk collect into v_DBQueueElements
					  From LDAPAccount a
						   Join personhasapp pha
							   On pha.UID_Application = v_UID_Application
							  And a.uid_person = pha.uid_person
							  and pha.XIsInEffect = 1 and pha.XOrigin > 0
						   Join (Select a.uid_LDAPaccount
								   From LDAPcontainer s, LDAPaccount a, LDAPcontainer ac
								  Where s.uid_LDAPcontainer = v_uid_LDAPcontainer
									And a.uid_LDAPcontainer = ac.uid_LDAPcontainer
									And s.uid_ldpDomain = ac.uid_ldpDomain
									And a.isappaccount = 1) x
							   On x.uid_LDAPaccount = a.uid_LDAPaccount;
			Else
				-- es gibt einen Parentcontainer, dann dessen Kinderlein
				select distinct a.uid_LDAPaccount, null, v_GenProcID
					bulk collect into v_DBQueueElements
					  From LDAPAccount a
						   Join personhasapp pha
							   On pha.UID_Application = v_UID_Application
							  And a.uid_person = pha.uid_person
							  and pha.XIsInEffect = 1 and pha.XOrigin > 0
						   Join (Select a.uid_LDAPaccount
								   From LDAPcontainer s
									  , LDAPcontainer p
									  , LDAPcontainer c
									  , LDAPaccount a
								  Where s.uid_parentLDAPcontainer = p.uid_LDAPcontainer
									And s.uid_LDAPcontainer = v_uid_LDAPcontainer
									And c.canonicalname Like p.canonicalname || '/%'
									And a.uid_LDAPcontainer = c.uid_LDAPcontainer
									And a.isappaccount = 1) x
							   On a.uid_LDAPaccount = x.uid_LDAPaccount;
			End If; -- rtrim(v_uid_parentLDAPcontainer) is null
		End If; -- rtrim(v_uid_LDAPcontainer) is null
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-LDAPAccountInLDAPGroup', v_DBQueueElements);

		-- erst mal wieder aufräumen
		v_DBQueueElements.Delete();
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		--- neu für die LDPMachine
		If v_uid_LDAPcontainer = '%' Then
			-- dann für alle LDPMachine
				select distinct m.uid_LDPMachine, null, v_GenProcID
					bulk collect into v_DBQueueElements
				  From	   Hardware h
					   Join
						   Workdeskhasapp wha
					   On wha.UID_Application = v_UID_Application
					   join LDPMachine m on m.uid_hardware = h.uid_hardware
					  And h.uid_workdesk = wha.uid_workdesk
					  and wha.XIsInEffect = 1 and wha.XOrigin > 0;
		Else
			-- es ist ein Container angegeben, dann ab diesem oder dessen Parent
			Begin
				Select uid_parentLDAPcontainer
				  Into v_uid_parentLDAPcontainer
				  From LDAPcontainer
				 Where uid_LDAPcontainer = v_uid_LDAPcontainer;
			Exception
				When NO_DATA_FOUND Then
					Null;
			End;

			If RTRIM(v_uid_parentLDAPcontainer) Is Null Then
				-- kein Parent, dann nur alle die aus seiner Domain (da über ihm Domain-Root)
				select distinct m.uid_LDPMachine, null, v_GenProcID
					bulk collect into v_DBQueueElements
					  From Hardware h
						   Join Workdeskhasapp wha
							   On UID_Application = v_UID_Application
							  And h.uid_workdesk = wha.uid_workdesk
							  join LDPMachine m on h.uid_hardware = m.uid_hardware
							  and wha.XIsInEffect = 1 and wha.XOrigin > 0
						   -- alle Accounts der Domäne
						   Join (Select m.uid_LDPMachine
								   From LDAPcontainer s, Hardware a, LDAPcontainer ac, LDPMachine m
								  Where s.uid_LDAPcontainer = v_uid_LDAPcontainer
									and m.uid_LDAPContainer = ac.uid_LDAPContainer
									and m.uid_hardware = a.uid_hardware
									 and  s.uid_LDPDomain = ac.uid_LDPDomain
									) x
							   on m.uid_LDPMachine = x.uid_LDPMachine;
			Else
				-- es gibt einen Parentcontainer, dann dessen Kinderlein
				select distinct m.uid_LDPMachine, null, v_GenProcID
					bulk collect into v_DBQueueElements
					  From Hardware h
						   Join Workdeskhasapp wha
							   On wha.UID_Application = v_UID_Application
							  And h.uid_workdesk = wha.uid_workdesk
							  join LDPMachine m on h.uid_hardware = m.uid_Hardware
							  and wha.XIsInEffect = 1 and wha.XOrigin > 0
						   Join (Select m.uid_LDPMachine
								   From LDAPcontainer s
									  , LDAPcontainer p
									  , LDAPcontainer c
									  , Hardware a, LDPMachine m
								  Where s.uid_parentLDAPcontainer = p.uid_LDAPcontainer
									And s.uid_LDAPcontainer = v_uid_LDAPcontainer
									And c.canonicalname Like p.canonicalname || '/%'
									and a.uid_hardware = m.uid_hardware
									and m.uid_LDAPContainer = c.uid_LDAPContainer
									) x
							   On m.uid_LDPMachine = x.uid_LDPMachine;
			End If; -- rtrim(v_uid_parentLDAPcontainer) is null
		End If; -- rtrim(v_uid_LDAPcontainer) is not null
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		QBM_GDBQueue.PDBQueueInsert_Bulk('LDP-K-LDPMachineInLDAPGroup', v_DBQueueElements);

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

end ZLDPAccountForApplication;
-----------------------------------------------------------------------------------------------
-- / Procedure ZLDPAccountForApplication
-----------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------
-- Procedure ZAppContainerInsert
-- legt in einem angegebenen ADSContainer Applikationsgruppen für alle Applikationen an
-- für die noch keine Applikationsgruppe in diesem Container existiert
-- jedoch nur die Applikationen, die Profilapplikationen sind
-----------------------------------------------------------------------------------------------
Procedure ZAppContainerInsert (v_SlotNumber number
								, v_uid_ADScontainer varchar2
								, v_dummy varchar2
								, v_GenProcID varchar2
								)
as

	v_uid_application		   QBM_GTypeDefinition.YGuid;
	v_ident_sectionname 	   varchar2(255);
	v_cmd					   varchar2(1024);
	-- IR 2003-03-06 Wegen Buglist 6390
	v_domain				   varchar2(64);
	v_exists				   QBM_GTypeDefinition.YBool;

	Cursor schrittAppContainerInsert Is
		Select a.uid_application, s.ident_sectionname
		  From application a join SectionName s on a.UID_SectionName = s.UID_SectionName
		 Where Not Exists
				   (Select 1
					  From adsgroup
					 Where uid_adscontainer = v_uid_adscontainer
					   And isapplicationgroup = 1
					   And cn = SDL_GConvert.FCVADSCommonName(s.ident_sectionname))
		   And a.isprofileapplication = 1;

	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();
Begin
	


	-- prüfen, ob das betreffende Objekt noch existiert
	Begin
		Select 1
		  Into v_exists
		  From DUAL
		 Where Exists
				   (Select 1
					  From ADSContainer
					 Where uid_ADSContainer = v_uid_ADSContainer);
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
	End;

	If v_exists = 0 Then
		v_cmd := 'ADSContainer ' || RTRIM(v_uid_ADSContainer) || ' not exists, Job APPCONTAINERINSERT was killed';
		QBM_GCommon2.PWriteDialogJournal(v_cmd, 'DBScheduler', 'DBScheduler');
		-- Rückkehr ohne Fehler, damit der Job gelöscht wird
	Else
		-- IR 2003-03-06 Wegen Buglist 6390
		Begin
			Select d.ident_Domain
			  Into v_domain
			  From AdsContainer c join adsdomain d on c.uid_ADSDomain = d.uid_ADSDomain
			 Where c.uid_ADSContainer = v_uid_ADSContainer
			   And ROWNUM = 1;
		Exception
			When NO_DATA_FOUND Then
				Null;
		End;

		Open schrittAppContainerInsert;

		Loop
			Fetch schrittAppContainerInsert
			Into v_uid_application, v_ident_sectionname;

			Exit When schrittAppContainerInsert%Notfound;
			QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);
			-- IR 2003-03-06 Wegen Buglist 6390
			SDL_GSoftwareDistribution.PDistributeAppGroup(v_ident_sectionname, v_domain, v_ident_sectionname);
		End Loop;

		Close schrittAppContainerInsert;
	End If;

	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);

end ZAppContainerInsert;
-----------------------------------------------------------------------------------------------
-- / Procedure ZAppContainerInsert
-----------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------
-- Procedure ZAppContainerDelete
-- löscht alle Applikationsgruppen in einem angegebenen ADS-Container
-----------------------------------------------------------------------------------------------
Procedure ZAppContainerDelete (v_SlotNumber number
								, v_uid_ADScontainer varchar2
								, v_dummy varchar2
								, v_GenProcID varchar2
								)
as


	v_uid_adsgroup			   QBM_GTypeDefinition.YGuid;
	v_where 				   varchar2(2000);
	v_cmd					   varchar2(1024);
	v_exists				   QBM_GTypeDefinition.YBool;
	v_BasisObjectKey		   JobQueue.BasisObjectKey%Type;

	Cursor schrittAppContainerDelete Is
		Select uid_adsgroup
		  From adsgroup
		 Where uid_adscontainer = v_uid_adscontainer
		   And isApplicationgroup = 1;

     -- für die Folgeaufträge
     v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();


	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();
Begin
	




	Begin
		-- prüfen, ob das betreffende Objekt noch existiert
		Begin
			Select 1
			  Into v_exists
			  From DUAL
			 Where Exists
					   (Select 1
						  From ADSContainer
						 Where uid_ADSContainer = v_uid_ADSContainer);
		Exception
			When NO_DATA_FOUND Then
				v_exists := 0;
		End;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		If v_exists = 0 Then
			v_cmd := 'ADSContainer ' || RTRIM(v_uid_ADSContainer) || ' not exists, Job APPCONTAINERDELETE was killed';
			QBM_GCommon2.PWriteDialogJournal(v_cmd, 'DBScheduler', 'DBScheduler');
			-- Rückkehr ohne Fehler, damit der Job gelöscht wird
		Else
			Open schrittAppContainerDelete;

			Loop
				Fetch schrittAppContainerDelete Into v_uid_adsgroup;

				Exit When schrittAppContainerDelete%Notfound;

				-- 13678 für die betroffenen Nutzer Mitgliedschaften neu rechnen
			select x.UID_object, null, v_GenProcID
				bulk collect into v_DBQueueElements
					  From	   (Select uid_ADSAccount As uid_object
								  From ADSaccountinADSgroup
								 Where uid_ADSGroup = v_uid_ADSGroup and XOrigin > 0) x;

				QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-ADSAccountInADSGroup', v_DBQueueElements);


				-- / 13678

				If UPPER(v_GenprocID) = 'SIMULATION' Then
					QBM_GCommon.PClientContextSet('SIMULATION', 'DBScheduler', 1);

					Delete ADSgroup
					 Where uid_ADSgroup = v_uid_ADSgroup;
				Else -- if upper(v_GenprocID) = 'SIMULATION'
					v_where := ' uid_adsGroup = ''' || v_uid_adsgroup || '''';
					v_BasisObjectKey := QBM_GConvert2.FCVElementToObjectKey('ADSGroup', 'UID_ADSGroup', v_uid_adsgroup, v_noCaseCheck => 1);
					QBM_GJobQueue.PJobCreate_HODelete('ADSGROUP'
												, v_where
												, v_Genprocid
												, v_BasisObjectKey	 => v_BasisObjectKey
												 );
				End If;
			End Loop;

			Close schrittAppContainerDelete;
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);

end ZAppContainerDelete;
-----------------------------------------------------------------------------------------------
-- / Procedure ZAppContainerDelete
-----------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------
-- Procedure ZAllForOneDriver
-- stellt für alle Stellen wo die Treiber eine Rolle spielen könnte eine Neuberechnung ein
-----------------------------------------------------------------------------------------------
Procedure ZAllForOneDriver (v_SlotNumber number
							, v_uid_Driver varchar2
							, v_dummy varchar2
							, v_GenProcID varchar2
							)
as


	v_cmd	 varchar2(2000);
	v_exists QBM_GTypeDefinition.YBool;

     -- für die Folgeaufträge
     v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();


Begin

	begin
		-- prüfen, ob das betreffende Objekt noch existiert
		Begin
			Select 1
			  Into v_exists
			  From DUAL
			 Where Exists
					   (Select 1
						  From Driver
						 Where uid_Driver = v_uid_Driver);
		Exception
			When NO_DATA_FOUND Then
				v_exists := 0;
		End;

		If v_exists = 0 Then
			v_cmd := 'Driver ' || RTRIM(v_uid_Driver) || ' not exists, Job ALLFORONEDRIVER was killed';
			QBM_GCommon2.PWriteDialogJournal(v_cmd, 'DBScheduler', 'DBScheduler');
			Return;
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
			select x.UID_object, null, v_GenProcID
				bulk collect into v_DBQueueElements

			  From (Select co.uid_Org as uid_object
					  From basetreeHasDriver bhr join BaseTreeCollection co on bhr.UID_Org = co.UID_ParentOrg
					 Where bhr.uid_Driver = v_uid_Driver and XOrigin > 0
					 ) x;

		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-OrgHasDriver', v_DBQueueElements);

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
			select x.UID_object, null, v_GenProcID
				bulk collect into v_DBQueueElements

			  From (Select uid_Workdesk As uid_object
					  From WorkdeskHasDriver
					 Where uid_Driver = v_uid_Driver and XOrigin > 0
					) x;

		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-WorkdeskHasDriver', v_DBQueueElements);

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
			select x.UID_object, null, v_GenProcID
				bulk collect into v_DBQueueElements

			  From (Select uid_Hardware As uid_object
					  From MachineHasDriver
					 Where uid_Driver = v_uid_Driver and XOrigin > 0
					) x;

		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-MACHInEHasDriver', v_DBQueueElements);

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

end ZAllForOneDriver;
-----------------------------------------------------------------------------------------------
-- / Procedure ZAllForOneDriver
-----------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------
-- Procedure PADSAccountInAppGroup
-- Hilfsprozedur
-----------------------------------------------------------------------------------------------
Procedure PADSAccountInAppGroup (v_ADSAccount varchar2, v_ADSGroup varchar2, v_GenProcID varchar2
								)
as

	v_countrows 			   Number;
	v_exists				   QBM_GTypeDefinition.YBool;
	v_isApplicationGroup	   Number;
	v_IsAppAccount			   Number;
	v_Ident_Domaingc		   varchar2(64);
	v_Ident_Domainac		   varchar2(64);
	v_SAMAccountName		   varchar2(256);
	v_uid_person			   QBM_GTypeDefinition.YGuid;
	v_cn					   varchar2(64);
	v_uid_application		   QBM_GTypeDefinition.YGuid;
	v_cmd					   varchar2(1024);

	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();
Begin
	

	Begin
		Select NVL(gg.IsApplicationGroup, 0)
			 , nt.uid_person
			 , gg.cn
		  Into v_IsApplicationGroup
			 , v_uid_person
			 , v_cn
		  From ADSGroup gg, ADSAccount nt
		 Where gg.UID_ADSGroup = v_ADSGroup
		   And nt.uid_ADSAccount = v_ADSAccount;
	Exception
		When NO_DATA_FOUND Then
			v_IsApplicationGroup := 0;
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		If v_IsApplicationGroup = 1 Then
			v_cmd := '';

			Select COUNT(*)
			  Into v_countrows
			  From application
			 Where ident_sectionname = v_cn and IsInActive = 0;

			If v_countrows = 1 Then
				Begin
					Select uid_application
					  Into v_uid_application
					  From application
					 Where ident_sectionname = v_cn
					   And ROWNUM = 1;
				Exception
					When NO_DATA_FOUND Then
						Null;
				End;

				Select COUNT(*)
				  Into v_countrows
				  From person
				 Where uid_person Is Not Null
				   And uid_person = v_uid_person;

				Select NVL(isAppaccount, 0)
				  Into v_IsAppAccount
				  From ADSAccount
				 Where uid_ADSAccount = v_ADSAccount;

				If 1 = v_countrows
			   And 1 = v_IsAppAccount Then
					Select COUNT(*)
					  Into v_exists
					  From personHasApp
					 Where uid_application = v_uid_application
					   And uid_person = v_uid_person;

					If v_exists < 1 Then
						QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

						Insert Into personhasapp(uid_person
											   , uid_application
											   , xdateinserted
											   , xdateupdated
											   , xuserinserted
											   , xuserupdated
											   , XObjectKey
											   , XOrigin
												)
							 Values (v_uid_person
								   , v_uid_application
								   , GetUTCDate
								   , GetUTCDate
								   , 'BackSync'
								   , 'BackSync'
								   , QBM_GConvert2.FCVElementToObjectKey('PersonHasApp'
													 , 'UID_Person'
													 , v_uid_person
													 , 'UID_Application'
													 , v_uid_application
													 , v_noCaseCheck => 1
													  )
									, 1
									);

						v_cmd := '#LDS#ADSAccountInADSGroup: Direct assignment to PersonHasApp implemented, ADS Account = {0}  Applicationgroup = {1}.|'
								 || v_ADSAccount
								 || '|'
								 || v_ADSGroup;
					End If;

					-- egal ob personinappschon existierte oder erst eingetragen wurde:
					QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

					 update ADSaccountInADSGroup 
						set XOrigin = QBM_GCommon.FBitXOr(bitand(XOrigin, QBM_GGetInfo2.FGIBitPatternXOrigin('|Direct|', 1)), 2)
 						where UID_ADSAccount = v_ADSAccount 
 						and UID_ADSGroup = v_ADSGroup;
				Else
					v_cmd :=	'#LDS#ADSAccountInADSGroup: employee cannot be found, ADS Account = {0}  Applicationgroup = {1}.|'
							 || v_ADSAccount
							 || '|'
							 || v_ADSGroup;
				End If;
			Else
				v_cmd :=	'#LDS#ADSAccountInADSGroup: Application cannot be found, ADS Account = {0}  Applicationgroup = {1}.|'
						 || v_ADSAccount
						 || '|'
						 || v_ADSGroup;
			End If;

			If RTRIM(v_cmd) Is Not Null Then
				QBM_GCommon2.PWriteDialogJournal(v_cmd, 'DBScheduler', 'DBScheduler', 'W');
			End If;
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);

end PADSAccountInAppGroup;
-----------------------------------------------------------------------------------------------
-- / Procedure PADSAccountInAppGroup
-----------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------
-- Procedure ZADSAccountInAppGroup
-- diese Task regelt den Backsync, wenn im Namespace Gruppenmitgliedschaften in
-- Applikationsgruppen gefunden werden, so werden diese nicht direkt in ADSAccountInADSGroup
-- eingetragen, sondern auf PersonHasApp abgebildet.
-----------------------------------------------------------------------------------------------
Procedure ZADSAccountInAppGroup (v_SlotNumber number
								)
as

	v_uid_Object	QBM_GTypeDefinition.YGuid;
	v_uid_SubObject QBM_GTypeDefinition.YGuid;
	v_GenProcID 	QBM_GTypeDefinition.YGuid;

	Cursor c_schritt Is
		Select UID_Parameter, UID_SubParameter, GenProcID From QBMDBQueueCurrent where SlotNumber = v_SlotNumber;
Begin
	Open c_schritt;

	Loop
		Fetch c_schritt
		Into v_uid_Object, v_uid_SubObject, v_GenProcID;

		Exit When c_schritt%Notfound;

		PADSAccountInAppGroup(v_uid_Object, v_uid_SubObject, v_GenProcID);
	End Loop;

	Close c_schritt;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);

end ZADSAccountInAppGroup;
-----------------------------------------------------------------------------------------------
-- / Procedure ZADSAccountInAppGroup
-----------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------
-- Procedure ZADSAccountForApplication
-- neuberechnen der Gruppenmitgliedschaft für alle Accounts, die eine Applikation haben
-- Optional ab einem bestimmten Container abwärts
-----------------------------------------------------------------------------------------------
Procedure ZADSAccountForApplication (v_SlotNumber number
									, v_uid_Application varchar2
									, v_uid_ADScontainer varchar2 -- Muster . Wenn nicht bekannt,  muß % übergeben werden
									, v_GenProcID varchar2
									)
as

	v_tmp					 QBM_GTypeDefinition.YGuid;
	v_cmd					 varchar2(1024);
	v_exists				 QBM_GTypeDefinition.YBool;
	v_uid_parentadscontainer QBM_GTypeDefinition.YGuid;
	v_sortorder 			 Number;


     -- für die Folgeaufträge
     v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();

Begin
	Begin


		-- prüfen, ob das betreffende Objekt noch existiert
		Begin
			Select 1
			  Into v_exists
			  From DUAL
			 Where Exists
					   (Select 1
						  From Application
						 Where uid_application = v_uid_Application);
		Exception
			When NO_DATA_FOUND Then
				v_exists := 0;
		End;

		If v_exists = 0 Then
			v_cmd := 'Application ' || RTRIM(v_uid_Application) || ' not exists, Job ALLADSACCOUNTSFORAPPLICATION was killed';
			QBM_GCommon2.PWriteDialogJournal(v_cmd, 'DBScheduler', 'DBScheduler');
			Return;
			-- Rückkehr ohne Fehler, damit der Job gelöscht wird
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		If v_uid_adscontainer = '%' Then
			-- dann für alle Accounts
			select a.uid_adsaccount, null, v_GenProcID
				bulk collect into v_DBQueueElements
				  From ADSAccount a Join personhasapp pha
					   On pha.UID_Application = v_UID_Application
					  And a.uid_person = pha.uid_person and pha.XOrigin > 0;
		Else
			-- es ist ein Container angegeben, dann ab diesem oder dessen Parent
			Begin
				Select uid_parentadscontainer
				  Into v_uid_parentadscontainer
				  From adscontainer
				 Where uid_adscontainer = v_uid_adscontainer;
			Exception
				When NO_DATA_FOUND Then
					Null;
			End;

			If RTRIM(v_uid_parentadscontainer) Is Null Then
				-- kein Parent, dann nur alle die aus seiner Domain (da über ihm Domain-Root)
				select a.uid_adsaccount, null, v_GenProcID
					bulk collect into v_DBQueueElements
					  From ADSAccount a Join personhasapp pha
							   On pha.UID_Application = v_UID_Application and pha.XOrigin > 0
							  And a.uid_person = pha.uid_person
						   Join (Select a.uid_adsaccount
								   From adscontainer s, adsaccount a, adscontainer ac
								  Where s.uid_adscontainer = v_uid_adscontainer
									And a.uid_adscontainer = ac.uid_adscontainer
									And s.uid_ADSDomain = ac.uid_ADSDomain
									And a.isappaccount = 1) x
							   On x.uid_adsaccount = a.uid_adsaccount;
			Else
				-- es gibt einen Parentcontainer, dann dessen Kinderlein
				select a.uid_adsaccount, null, v_GenProcID
					bulk collect into v_DBQueueElements
					  From ADSAccount a Join personhasapp pha
							   On pha.UID_Application = v_UID_Application and pha.XOrigin > 0
							  And a.uid_person = pha.uid_person
						   Join (Select a.uid_adsaccount
								   From adscontainer s
									  , adscontainer p
									  , adscontainer c
									  , adsaccount a
								  Where s.uid_parentAdscontainer = p.uid_adscontainer
									And s.uid_adscontainer = v_uid_adscontainer
									And c.canonicalname Like p.canonicalname || '/%'
									And a.uid_adscontainer = c.uid_adscontainer
									And a.isappaccount = 1) x
							   On a.uid_adsaccount = x.uid_adsaccount;
			End If; -- rtrim(v_uid_parentadscontainer) is null
		End If; -- rtrim(v_uid_adscontainer) is null
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin

		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-ADSAccountInADSGroup', v_DBQueueElements);

		-- erst mal wieder aufräumen
		v_DBQueueElements.Delete();
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		--- neu für die Hardware

		If v_uid_adscontainer = '%' Then
			-- dann für alle ADSMachine
			select distinct m.UID_ADSMachine, null, v_GenProcID
					bulk collect into v_DBQueueElements
				  From Hardware h Join Workdeskhasapp wha
					   On wha.UID_Application = v_UID_Application and wha.XOrigin > 0
					  And h.uid_workdesk = wha.uid_workdesk
					  join ADSMachine m on h.uid_hardware = m.uid_hardware;
		Else
			-- es ist ein Container angegeben, dann ab diesem oder dessen Parent
			Begin
				Select uid_parentadscontainer
				  Into v_uid_parentadscontainer
				  From adscontainer
				 Where uid_adscontainer = v_uid_adscontainer;
			Exception
				When NO_DATA_FOUND Then
					Null;
			End;

			If RTRIM(v_uid_parentadscontainer) Is Null Then
				-- kein Parent, dann nur alle die aus seiner Domain (da über ihm Domain-Root)
				select distinct m.uid_ADSMachine, null, v_GenProcID
					bulk collect into v_DBQueueElements
					  From Hardware h
						 , Workdeskhasapp wha, ADSMachine m
						 , -- alle Accounts der Domäne
						  (Select m.uid_ADSMachine
							 From adscontainer s, Hardware a, adscontainer ac, ADSMachine m
							Where s.uid_adscontainer = v_uid_adscontainer
							and a.uid_hardware = m.uid_hardware
							and m.uid_adscontainer = ac.uid_adscontainer
							 and  s.UID_ADSDomain = ac.uid_ADSDomain
							  ) x
					 Where m.uid_ADSMachine = x.uid_ADSMachine
					 and h.uid_hardware = m.uid_hardware
					   And UID_Application = v_UID_Application
					   And h.uid_workdesk = wha.uid_workdesk
					   and wha.XOrigin > 0;
			Else
				-- es gibt einen Parentcontainer, dann dessen Kinderlein
				select distinct m.uid_ADSMachine, null, v_GenProcID
					bulk collect into v_DBQueueElements
					  From Hardware h
						 , Workdeskhasapp wha, ADSMachine m
						 , (Select m.uid_ADSMachine
							  From adscontainer s
								 , adscontainer p
								 , adscontainer c
								 , Hardware a, ADSMachine m
							 Where s.uid_parentAdscontainer = p.uid_adscontainer
							   And s.uid_adscontainer = v_uid_adscontainer
							   And c.canonicalname Like p.canonicalname || '/%'
							   and a.uid_hardware = m.uid_hardware
								and m.uid_adscontainer = c.uid_adscontainer
							   ) x
					 Where m.uid_ADSMachine = x.uid_ADSMachine
					 and h.uid_hardware = m.UID_Hardware
					   And wha.UID_Application = v_UID_Application
					   and wha.XOrigin > 0
					   And h.uid_workdesk = wha.uid_workdesk;
					   
			End If; -- rtrim(v_uid_parentadscontainer) is null
		End If; -- rtrim(v_uid_adscontainer) is not null
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin

		QBM_GDBQueue.PDBQueueInsert_Bulk('ADS-K-ADSMachineInADSGroup', v_DBQueueElements);

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;


end ZADSAccountForApplication;
-----------------------------------------------------------------------------------------------
-- / Procedure ZADSAccountForApplication
-----------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------
-- Procedure ZApplicationMakeSortorder
-----------------------------------------------------------------------------------------------
Procedure ZApplicationMakeSortorder (v_SlotNumber number
									, v_dummy1 varchar2
									, v_dummy2 varchar2
									, v_GenProcIDDummy varchar2
									)
as
	v_GenProcID QBM_GTypeDefinition.YGuid := newid();

	v_startwert 			   Number;
	v_schrittweite			   Number;
	v_whereclause			   varchar2(1000);
	v_ParamVal				   varchar2(16);
	v_reihenfolge			   Number;
	v_uid_application		   QBM_GTypeDefinition.YGuid;
	v_gefunden				   Number;
	v_BasisObjectKey		   JobQueue.BasisObjectKey%Type;

	v_exists				   QBM_GTypeDefinition.YBool;

	Cursor schritt_viAppMakeSortorder Is
		  Select a.uid_application
			From application a
		   Where Not Exists
					 (Select 1
						From ApplicationDependsOnApp ada
					   Where ada.uid_applicationChild = a.uid_application)
		Order By a.uid_application;

	Cursor schritt_viAppMakeSortorder2 Is
		  Select a.uid_application
			From -- bedeutet: CountItems vorgänger, die eine Driver hat ist gleich der CountItems vorgänger, die schon eingetütet sind
				(  Select ada.uid_ApplicationChild As uid_application, COUNT(*) As CountItems
					 From ApplicationDependsOnApp ada
				 Group By ada.uid_Applicationchild
				 Order By ada.uid_Applicationchild) x
				 Join (  Select ada.uid_ApplicationChild As uid_application, COUNT(*) As CountItems
						   From 	ApplicationDependsOnApp ada
								Join
									Temp_CollectionHelper
								On ada.uid_ApplicationParent = Temp_CollectionHelper.uid_org
					   Group By ada.uid_Applicationchild
					   Order By ada.uid_Applicationchild) y
					 On x.uid_application = y.uid_application
					And x.CountItems = y.CountItems
				 Join application a
					 On y.uid_application = a.uid_application
		   Where Not Exists
					 (Select 1
						From Temp_CollectionHelper
					   Where uid_org = a.uid_application)
		Order By a.uid_application;

	Cursor schritt_viAppMakeSortorder3 Is
		  Select a.uid_application, co.XOrigin
			From application a Join Temp_CollectionHelper co On a.uid_application = co.uid_org
--16592
						join dialogColumn c on c.UID_DialogTable = 'APC-T-Application'
											and c.columnname = 'SortOrderForProfile'
											and c.IsDeactivatedByPreProcessor = 0
--/ 16592
		   Where NVL(a.SortorderForProfile, -1) <> co.XOrigin
		Order By a.uid_application;

	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();
Begin
	

	Begin
		-- Falls alle Abhängigkeiten leer sind
		Begin
			v_exists := 0;

			Select 1
			  Into v_exists
			  From DUAL
			 Where Exists (Select 1 From ApplicationDependsOnApp);
		Exception
			When NO_DATA_FOUND Then
				v_exists := 0;
		End;

		If v_exists = 0 Then
			Insert Into Temp_CollectionHelper(uid_org, XOrigin, UID_ParentOrg)
				Select uid_application, v_startwert, '' From Application;

			Goto keineAbhaegigkeit;
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		v_startwert := 10000;
		v_schrittweite := 10;

		-- Algorithmus für neue Ermittlung der Sortorder
		-- alle die bestimmen, die nirgendwo als Child auftauchen, die sind erst mal die Wurzel

		-- Tabelle Temp_CollectionHelper wird nicht benötigt, kann hier also mißbraucht werden
		--delete Temp_CollectionHelper;

		-- eintüten und durchzählen ab 10000 in 10er Schritten
		v_reihenfolge := v_startwert;

		Open schritt_viAppMakeSortorder;

		Loop
			Fetch schritt_viAppMakeSortorder Into v_uid_application;

			Exit When schritt_viAppMakeSortorder%Notfound;

			Insert Into Temp_CollectionHelper(uid_org, XOrigin, uid_parentorg)
				 Values (v_uid_application, v_reihenfolge, '###');

			v_reihenfolge := v_reihenfolge + v_schrittweite;
		End Loop;

		Close schritt_viAppMakeSortorder;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
	   --und jetzt die weiteren ebenen
	   -- alle Knoten, für die ALLE Vorgänger bereits in der tmp-Tabelle sind, die selber aber noch nicht drin sind
	   <<marke>>
		v_gefunden := 0;

		Open schritt_viAppMakeSortorder2;

		Loop
			Fetch schritt_viAppMakeSortorder2 Into v_uid_application;

			Exit When schritt_viAppMakeSortorder2%Notfound;

			Insert Into Temp_CollectionHelper(uid_org, XOrigin, uid_parentorg)
				 Values (v_uid_application, v_reihenfolge, '###');

			v_reihenfolge := v_reihenfolge + v_schrittweite;
			v_gefunden := 1;
		End Loop;

		Close schritt_viAppMakeSortorder2;

		If v_gefunden = 1 Then
			Goto marke;
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

   <<keineAbhaegigkeit>>
	Begin
		--jetzt zeilenweise durch alle die durch, wo die Sortierfolge sich gegenüber dem Eintrag in river geändert hat
		-- für diese einen Job einstellen

		Open schritt_viAppMakeSortorder3;

		Loop
			Fetch schritt_viAppMakeSortorder3
			Into v_uid_application, v_reihenfolge;

			Exit When schritt_viAppMakeSortorder3%Notfound;

			If UPPER(v_GenprocID) = 'SIMULATION' Then
				QBM_GCommon.PClientContextSet('SIMULATION', 'DBScheduler', 1);

				Update application
				   Set SortorderForProfile = TO_NUMBER(v_ParamVal)
				 Where uid_application = v_UID_application;
			Else -- if upper(v_GenprocID) = 'SIMULATION'
				v_whereclause := 'uid_application = ''' || RTRIM(v_uid_application) || '''';
				v_ParamVal := to_char(v_reihenfolge);
				v_BasisObjectKey := QBM_GConvert2.FCVElementToObjectKey('Application', 'UID_Application', v_uid_application, v_noCaseCheck => 1);
				QBM_GJobQueue.PJobCreate_HOUpdate('Application'
										  , v_whereclause
										  , v_GenProcID
										  , v_p1 => 'SortorderForProfile'
										  , v_v1 => v_ParamVal
										  , v_isToFreezeOnError => 0
										  , v_BasisObjectKey   => v_BasisObjectKey
										   );
			End If;
		End Loop;

		Close schritt_viAppMakeSortorder3;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);

end ZApplicationMakeSortorder;
-----------------------------------------------------------------------------------------------
-- / Procedure ZApplicationMakeSortorder
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-- Procedure ZDriverMakeSortorder
-----------------------------------------------------------------------------------------------
Procedure ZDriverMakeSortorder (v_SlotNumber number
									, v_dummy1 varchar2
									, v_dummy2 varchar2
									, v_GenProcIDDummy varchar2
									)
as
	v_GenProcID QBM_GTypeDefinition.YGuid := newid();

	v_startwert 			   Number;
	v_schrittweite			   Number;
	v_whereclause			   varchar2(1000);
	v_ParamVal				   varchar2(16);
	v_reihenfolge			   Number;
	v_uid_Driver			   QBM_GTypeDefinition.YGuid;
	v_gefunden				   Number;
	v_BasisObjectKey		   JobQueue.BasisObjectKey%Type;

	v_exists				   QBM_GTypeDefinition.YBool;

	Cursor schritt_viDriverMakeSortorder Is
		  Select a.uid_Driver
			From Driver a
		   Where Not Exists
					 (Select 1
						From DriverDependsOnDriver ada
					   Where ada.uid_DriverChild = a.uid_Driver)
		Order By a.uid_Driver;

	Cursor schritt_viDriverMakeSortorder2 Is
		  Select a.uid_Driver
			From -- bedeutet: CountItems vorgänger, die eine Driver hat ist gleich der CountItems vorgänger, die schon in Temp_tmp eingetütet sind
				(  Select ada.uid_DriverChild As uid_Driver, COUNT(*) As CountItems
					 From DriverDependsOnDriver ada
				 Group By ada.uid_Driverchild
				 Order By ada.uid_Driverchild) x
				 Join (  Select ada.uid_DriverChild As uid_Driver, COUNT(*) As CountItems
						   From DriverDependsOnDriver ada Join Temp_CollectionHelper On ada.uid_DriverParent = Temp_CollectionHelper.uid_org
					   Group By ada.uid_Driverchild
					   Order By ada.uid_Driverchild) y
					 On x.uid_Driver = y.uid_Driver
					And x.CountItems = y.CountItems
				 Join Driver a
					 On y.uid_Driver = a.uid_Driver
		   Where Not Exists
					 (Select 1
						From Temp_CollectionHelper
					   Where uid_org = a.uid_Driver)
		Order By a.uid_Driver;

	Cursor schritt_viDriverMakeSortorder3 Is
		  Select a.uid_Driver, co.XOrigin
			From Driver a Join Temp_CollectionHelper co On a.uid_Driver = co.uid_org
--16592
						join dialogColumn c on c.UID_DialogTable = 'SDL-T-Driver'
											and c.columnname = 'SortOrderForProfile'
											and c.IsDeactivatedByPreProcessor = 0
--/ 16592
		   Where NVL(a.SortorderForProfile, -1) <> co.XOrigin
		Order By a.uid_Driver;

	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();
Begin
	

	Begin
		-- Falls alle Abhängigkeiten leer sind
		Begin
			v_exists := 0;

			Select 1
			  Into v_exists
			  From DUAL
			 Where Exists (Select 1 From DriverDependsOnDriver);
		Exception
			When NO_DATA_FOUND Then
				v_exists := 0;
		End;

		If v_exists = 0 Then
			Insert Into Temp_CollectionHelper(uid_org, XOrigin, UID_ParentOrg)
				Select uid_driver, v_startwert, '' From Driver;

			Goto keineAbhaegigkeit;
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		v_startwert := 10;
		v_schrittweite := 10;

		-- Algorithmus für neue Ermittlung der Sortorder
		-- alle die bestimmen, die nirgendwo als Child auftauchen, die sind erst mal die Wurzel

		-- Tabelle Temp_CollectionHelper wird nicht benötigt, kann hier also mißbraucht werden
		--delete Temp_CollectionHelper;

		-- eintüten und durchzählen ab 10000 in 10er Schritten
		v_reihenfolge := v_startwert;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		Open schritt_viDriverMakeSortorder;

		Loop
			Fetch schritt_viDriverMakeSortorder Into v_uid_Driver;

			Exit When schritt_viDriverMakeSortorder%Notfound;

			Insert Into Temp_CollectionHelper(uid_org, XOrigin, uid_parentorg)
				 Values (v_uid_Driver, v_reihenfolge, '###');

			v_reihenfolge := v_reihenfolge + v_schrittweite;
		End Loop;

		Close schritt_viDriverMakeSortorder;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	--und jetzt die weiteren ebenen
	-- alle Knoten, für die ALLE Vorgänger bereits in der tmp-Tabelle sind, die selber aber noch nicht drin sind
	Begin
	   <<marke>>
		v_gefunden := 0;

		Open schritt_viDriverMakeSortorder2;

		Loop
			Fetch schritt_viDriverMakeSortorder2 Into v_uid_Driver;

			Exit When schritt_viDriverMakeSortorder2%Notfound;

			Insert Into Temp_CollectionHelper(uid_org, XOrigin, uid_parentorg)
				 Values (v_uid_Driver, v_reihenfolge, '###');

			v_reihenfolge := v_reihenfolge + v_schrittweite;
			v_gefunden := 1;
		End Loop;

		Close schritt_viDriverMakeSortorder2;

		If v_gefunden = 1 Then
			Goto marke;
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

   <<keineAbhaegigkeit>>
	Begin
		--jetzt zeilenweise durch alle die durch, wo die Sortierfolge sich gegenüber dem Eintrag in Ìriver geändert hat
		-- für diese einen Job einstellen

		Open schritt_viDriverMakeSortorder3;

		Loop
			Fetch schritt_viDriverMakeSortorder3
			Into v_uid_Driver, v_reihenfolge;

			Exit When schritt_viDriverMakeSortorder3%Notfound;

			If UPPER(v_GenprocID) = 'SIMULATION' Then
				QBM_GCommon.PClientContextSet('SIMULATION', 'DBScheduler', 1);

				Update driver
				   Set SortorderForProfile = TO_NUMBER(v_ParamVal)
				 Where uid_Driver = v_UID_Driver;
			Else -- if upper(v_GenprocID) = 'SIMULATION'
				v_whereclause := 'uid_Driver = ''' || RTRIM(v_uid_Driver) || '''';
				v_ParamVal := to_char(v_reihenfolge);
				v_BasisObjectKey := QBM_GConvert2.FCVElementToObjectKey('Driver', 'UID_Driver', v_uid_Driver, v_noCaseCheck => 1);
				QBM_GJobQueue.PJobCreate_HOUpdate('Driver'
										  , v_whereclause
										  , v_GenProcID
										  , v_p1 => 'SortorderForProfile'
										  , v_v1 => v_ParamVal
										  , v_isToFreezeOnError => 0
										  , v_BasisObjectKey   => v_BasisObjectKey
										   );			
			End If;
		End Loop;

		Close schritt_viDriverMakeSortorder3;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);

end ZDriverMakeSortorder;
-----------------------------------------------------------------------------------------------
-- / Procedure ZDriverMakeSortorder
-----------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------
-- Procedure PADSMachineInADSAppGroup
-- Hilfsprozedur
-----------------------------------------------------------------------------------------------
Procedure PADSMachineInADSAppGroup (v_UID_ADSMachine varchar2, v_UID_ADSGroup varchar2, v_GenProcID varchar2)
as

	v_countrows 			   Number;
	v_exists				   QBM_GTypeDefinition.YBool;
	v_isApplicationGroup	   Number;
	v_IsAppAccount			   Number;

	v_uid_WorkDesk			   QBM_GTypeDefinition.YGuid;
	v_cn					   varchar2(64);
	v_uid_application		   QBM_GTypeDefinition.YGuid;
	v_cmd					   varchar2(1024);

	-- für Aufzeichnung
	v_IsSimulationMode		   QBM_GTypeDefinition.YBool;

	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();
Begin
	

	-- Ergänzung Aufzeichnung
	If QBM_GSimulation.Simulation = 1 Then
		v_IsSimulationMode := 1;
	Else
		v_IsSimulationMode := 0;
	End If;

	--/ Ergänzung Aufzeichnung

	Begin
		Select NVL(gg.IsApplicationGroup, 0)
			 , nt.uid_WorkDesk
			 , gg.cn
		  Into v_IsApplicationGroup
			 , v_uid_WorkDesk
			 , v_cn
		  From ADSGroup gg, Hardware nt, ADSMachine m
		 Where gg.UId_ADSGroup = v_UID_ADSGroup
           and m.UID_ADSMachine = v_UID_ADSMachine
		   and m.uid_hardware = nt.uid_hardware
		   and rownum = 1;
	Exception
		When NO_DATA_FOUND Then
			v_IsApplicationGroup := 0;
	End;

	If v_IsApplicationGroup = 1 Then
		v_cmd := '';

		Select COUNT(*)
		  Into v_countrows
		  From application
		 Where ident_sectionname = v_cn;

		If v_countrows = 1 Then
			Begin
				Select uid_application
				  Into v_uid_application
				  From application
				 Where ident_sectionname = v_cn
				   And ROWNUM = 1;
			Exception
				When NO_DATA_FOUND Then
					Null;
			End;

			Select COUNT(*)
			  Into v_countrows
			  From WorkDesk
			 Where uid_WorkDesk Is Not Null
			   And uid_WorkDesk = v_uid_WorkDesk;

			-- hier nicht: select nvl(isAppaccount, 0) into v_IsAppAccount from Hardware where rtrim(uid_Hardware) = rtrim(v_UID_Hardware);
			If 1 = v_countrows -- hier nicht: and 1 = v_IsAppAccount
							  Then
				Begin
					Select 1
					  Into v_exists
					  From DUAL
					 Where Exists
							   (Select 1
								  From WorkDeskHasApp
								 Where uid_application = v_uid_application
								   And uid_WorkDesk = v_uid_WorkDesk);
				Exception
					When NO_DATA_FOUND Then
						v_exists := 0;
				End;

				If v_exists = 0 Then
					QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

					-- Ergänzung Aufzeichnung
					If v_IsSimulationMode = 1 Then
						Insert Into Temp_TriggerOperation(Operation
														, BaseObjectType
														, ColumnName
														, ObjectKey
														, OldValue
														 )
							 Values ('I'
								   , 'WorkDeskhasapp'
								   , null
								   , QBM_GConvert2.FCVElementToObjectKey('WorkDeskHasApp'
													 , 'UID_WorkDesk'
													 , v_uid_WorkDesk
													 , 'UID_Application'
													 , v_uid_application
													 , v_noCaseCheck => 1
													  )
								   , null
									);
					End If;

					--/ Ergänzung Aufzeichnung

					Insert Into WorkDeskhasapp(uid_WorkDesk
											 , uid_application
											 , xdateinserted
											 , xdateupdated
											 , xuserinserted
											 , xuserupdated
											 , XObjectKey
											 , XOrigin
											  )
						 Values (v_uid_WorkDesk
							   , v_uid_application
							   , GetUTCDate
							   , GetUTCDate
							   , 'BackSync'
							   , 'BackSync'
							   , QBM_GConvert2.FCVElementToObjectKey('WorkDeskHasApp'
												 , 'UID_WorkDesk'
												 , v_uid_WorkDesk
												 , 'UID_Application'
												 , v_uid_application
												 , v_noCaseCheck => 1
												  )
								, 1
								);

					v_cmd := '#LDS#ADSMachineInADSGroup: Direct assignment applied to WorkdeskHasApp, ADSMachine = {0} Application group = {1}.|'
							 || v_UID_ADSMachine
							 || '|'
							 || v_UID_ADSGroup;
				End If;

				-- egal ob WorkDeskinappschon existierte oder erst eingetragen wurde:
				QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

				-- Ergänzung Aufzeichnung
				If v_IsSimulationMode = 1 Then
					Insert Into Temp_TriggerOperation(Operation
													, BaseObjectType
													, ColumnName
													, ObjectKey
													, OldValue
													 )
						 Values ('D'
							   , 'ADSMachineinADSGroup'
							   , null
							   , QBM_GConvert2.FCVElementToObjectKey('ADSMachineInADSGroup'
												 , 'UID_ADSMachine'
												 , v_uid_ADSMachine
												 , 'UID_ADSGroup'
												 , v_uid_ADSGroup
												 , v_noCaseCheck => 1
												  )
							   , null
								);
				End If;

				--/ Ergänzung Aufzeichnung
					 update ADSMachineinADSGroup 
						set XOrigin = QBM_GCommon.FBitXOr(bitand(XOrigin, QBM_GGetInfo2.FGIBitPatternXOrigin('|Direct|', 1)), 2)
 						where uid_ADSMachine = v_uid_ADSMachine 
 						and UID_ADSGroup = v_uid_ADSGroup;
			Else
				v_cmd :=	'#LDS#ADSMachineInADSGroup: WorkDesk cannot be found, ADSMachine = {0} Application group = {1}.|'
						 || v_UID_ADSMachine
						 || '|'
						 || v_UID_ADSGroup;
			End If;
		Else
			v_cmd :=	'#LDS#ADSMachineInADSGroup: Application cannot be found ADSMachine = {0} Application group = {1}.|'
					 || v_UID_ADSMachine
					 || '|'
					 || v_UID_ADSGroup;
		End If;

		If RTRIM(v_cmd) Is Not Null Then
			QBM_GCommon2.PWriteDialogJournal(v_cmd, 'DBScheduler', 'DBScheduler', 'W');
		End If;
	End If;

	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);

end PADSMachineInADSAppGroup;
-----------------------------------------------------------------------------------------------
-- / Procedure PADSMachineInADSAppGroup
-----------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------
-- Procedure ZADSMachineInADSAppGroup
-----------------------------------------------------------------------------------------------
Procedure ZADSMachineInADSAppGroup (v_SlotNumber number
								)
as

	v_uid_Object	QBM_GTypeDefinition.YGuid;
	v_uid_SubObject QBM_GTypeDefinition.YGuid;
	v_GenProcID 	QBM_GTypeDefinition.YGuid;

	Cursor c_schritt Is
		Select UID_Parameter, UID_SubParameter, GenProcID From QBMDBQueueCurrent where SlotNumber = v_SlotNumber;
Begin
	Open c_schritt;

	Loop
		Fetch c_schritt
		Into v_uid_Object, v_uid_SubObject, v_GenProcID;

		Exit When c_schritt%Notfound;

		PADSMachineInADSAppGroup(v_uid_Object, v_uid_SubObject, v_GenProcID);
	End Loop;

	Close c_schritt;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);

end ZADSMachineInADSAppGroup;
-----------------------------------------------------------------------------------------------
-- / Procedure ZADSMachineInADSAppGroup
-----------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------
-- Procedure PLDPMachineInLDAPAppGroup
-- Hilfsprozedur
-----------------------------------------------------------------------------------------------
Procedure PLDPMachineInLDAPAppGroup (v_UID_LDPMachine varchar2, v_UID_LDAPGroup varchar2, v_GenProcID varchar2)
as

	v_errmsg				   varchar2(255);
	v_countrows 			   Number;
	v_exists				   QBM_GTypeDefinition.YBool;
	v_isApplicationGroup	   Number;
	v_IsAppAccount			   Number;
	v_uid_WorkDesk			   QBM_GTypeDefinition.YGuid;
	v_cn					   varchar2(64);
	v_uid_application		   QBM_GTypeDefinition.YGuid;
	v_cmd					   varchar2(1024);

	-- für Aufzeichnung
	v_IsSimulationMode		   QBM_GTypeDefinition.YBool;

	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();
Begin
	

	-- Ergänzung Aufzeichnung
	If QBM_GSimulation.Simulation = 1 Then
		v_IsSimulationMode := 1;
	Else
		v_IsSimulationMode := 0;
	End If;

	--/ Ergänzung Aufzeichnung

	Begin
		Select NVL(gg.IsApplicationGroup, 0), nt.uid_WorkDesk, gg.cn
		  Into v_IsApplicationGroup, v_uid_WorkDesk, v_cn
		  From LDAPGroup gg, Hardware nt, LDPMachine m
		 Where gg.UId_LDAPGroup = v_UID_LDAPGroup
		   and m.UID_LDPMachine = v_UID_LDPMachine
		   and nt.uid_hardware = m.uid_hardware
		   and rownum = 1;
	Exception
		When NO_DATA_FOUND Then
			v_IsApplicationGroup := 0;
	End;

	If v_IsApplicationGroup = 1 Then
		v_cmd := '';

		Select COUNT(*)
		  Into v_countrows
		  From application
		 Where ident_sectionname = v_cn;

		If v_countrows = 1 Then
			Begin
				Select uid_application
				  Into v_uid_application
				  From application
				 Where ident_sectionname = v_cn
				   And ROWNUM = 1;
			Exception
				When NO_DATA_FOUND Then
					Null;
			End;

			Select COUNT(*)
			  Into v_countrows
			  From WorkDesk
			 Where uid_WorkDesk Is Not Null
			   And uid_WorkDesk = v_uid_WorkDesk;

			If 1 = v_countrows Then
				Begin
					Select 1
					  Into v_exists
					  From DUAL
					 Where Exists
							   (Select 1
								  From WorkDeskHasApp
								 Where uid_application = v_uid_application
								   And uid_WorkDesk = v_uid_WorkDesk);
				Exception
					When NO_DATA_FOUND Then
						v_exists := 0;
				End;

				If v_exists = 0 Then
					QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

					-- Ergänzung Aufzeichnung
					If v_IsSimulationMode = 1 Then
						Insert Into Temp_TriggerOperation(Operation
														, BaseObjectType
														, ColumnName
														, ObjectKey
														, OldValue
														 )
							 Values ('I'
								   , 'WorkDeskhasapp'
								   , null
								   , QBM_GConvert2.FCVElementToObjectKey('WorkDeskHasApp'
													 , 'UID_WorkDesk'
													 , v_uid_WorkDesk
													 , 'UID_Application'
													 , v_uid_application
													 , v_noCaseCheck => 1
													  )
								   , null
									);
					End If;

					--/ Ergänzung Aufzeichnung

					Insert Into WorkDeskhasapp(uid_WorkDesk
											 , uid_application
											 , xdateinserted
											 , xdateupdated
											 , xuserinserted
											 , xuserupdated
											 , XObjectKey
											 , XOrigin
											  )
						 Values (v_uid_WorkDesk
							   , v_uid_application
							   , GetUTCDate
							   , GetUTCDate
							   , 'BackSync'
							   , 'BackSync'
							   , QBM_GConvert2.FCVElementToObjectKey('WorkDeskHasApp'
												 , 'UID_WorkDesk'
												 , v_uid_WorkDesk
												 , 'UID_Application'
												 , v_uid_application
												 , v_noCaseCheck => 1
												  )
								, 1
								);

					v_cmd :=	'#LDS#Direct assignment applied to {2}, account {0} application group = {1}.|'
							 || v_UID_LDPMachine
							 || '|'
							 || v_UID_LDAPGroup
							 || '|WorkdeskHasApp|';
				End If;

				-- egal ob WorkDeskinappschon existierte oder erst eingetragen wurde:
				QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

				-- Ergänzung Aufzeichnung
				If v_IsSimulationMode = 1 Then
					Insert Into Temp_TriggerOperation(Operation
													, BaseObjectType
													, ColumnName
													, ObjectKey
													, OldValue
													 )
						 Values ('D'
							   , 'LDPMachineinLDAPGroup'
							   , null
							   , QBM_GConvert2.FCVElementToObjectKey('LDPMachineInLDAPGroup'
												 , 'UID_LDPMachine'
												 , v_uid_LDPMachine
												 , 'UID_LDAPGroup'
												 , v_uid_LDAPGroup
												 , v_noCaseCheck => 1
												  )
							   , null
								);
				End If;

				--/ Ergänzung Aufzeichnung
					 update LDPMachineinLDAPGroup 
						set XOrigin = QBM_GCommon.FBitXOr(bitand(XOrigin, QBM_GGetInfo2.FGIBitPatternXOrigin('|Direct|', 1)), 2)
 						where uid_LDPMachine = v_uid_LDPMachine 
 						and uid_LDAPGroup = v_uid_LDAPGroup;

			Else
				v_cmd :=	'#LDS#LDPMachineInLDAPGroup: Workdesk cannot be found, LDPMachine = {0} Application group = {1}.|'
						 || v_UID_LDPMachine
						 || '|'
						 || v_UID_LDAPGroup;
			End If;
		Else
			v_cmd :=	'#LDS#LDPMachineInLDAPGroup: Application cannot be found, LDPMachine = {0} Application group = {1}.|'
					 || v_UID_LDPMachine
					 || '|'
					 || v_UID_LDAPGroup;
		End If;

		If RTRIM(v_cmd) Is Not Null Then
			QBM_GCommon2.PWriteDialogJournal(v_cmd, 'DBScheduler', 'DBScheduler', 'W');
		End If;
	End If;

	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);

end PLDPMachineInLDAPAppGroup;
-----------------------------------------------------------------------------------------------
-- / Procedure PLDPMachineInLDAPAppGroup
-----------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------
-- Procedure ZLDPMachineInLDPAppGroup
-----------------------------------------------------------------------------------------------
Procedure ZLDPMachineInLDPAppGroup (v_SlotNumber number
								)
as

	v_uid_Object	QBM_GTypeDefinition.YGuid;
	v_uid_SubObject QBM_GTypeDefinition.YGuid;
	v_GenProcID 	QBM_GTypeDefinition.YGuid;

	Cursor c_schritt Is
		Select UID_Parameter, UID_SubParameter, GenProcID From QBMDBQueueCurrent where SlotNumber = v_SlotNumber;
Begin
	Open c_schritt;

	Loop
		Fetch c_schritt
		Into v_uid_Object, v_uid_SubObject, v_GenProcID;

		Exit When c_schritt%Notfound;

		PLDPMachineInLDAPAppGroup(v_uid_Object, v_uid_SubObject, v_GenProcID);
	End Loop;

	Close c_schritt;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);

end ZLDPMachineInLDPAppGroup;
-----------------------------------------------------------------------------------------------
-- / Procedure ZLDPMachineInLDPAppGroup
-----------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------
-- Procedure ZHardwareUpdateCName
-----------------------------------------------------------------------------------------------
Procedure ZHardwareUpdateCName (v_SlotNumber number
								)
as

	v_whereklausel			   varchar2(255);
	v_cmd					   varchar2(1024);
	v_exists				   QBM_GTypeDefinition.YBool;
	v_uid_hardwareErsatz	   QBM_GTypeDefinition.YGuid;
	v_GenProcID 			   QBM_GTypeDefinition.YGuid;
	v_BasisObjectKey		   JobQueue.BasisObjectKey%Type;

	Cursor schrittHardwareUpdateCNAME Is
		Select uid_parameter, GenProcID From QBMDBQueueCurrent where SlotNumber = v_SlotNumber;

	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();
Begin
	


	begin
		-- prüfen, ob das betreffende Objekt noch existiert
		QBM_GDBQueue.PSlotResetOnMissingItem(v_SlotNumber, 'Hardware', 'UID_Hardware');

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;




	Open schrittHardwareUpdateCNAME;

	Loop
		Fetch schrittHardwareUpdateCNAME
		Into v_uid_hardwareErsatz, v_GenProcID;

		Exit When schrittHardwareUpdateCNAME%Notfound;

		-- wegen Buglist 11085
		QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

		Update hardware
		   Set UpdateCName = 0
		 Where UID_HardWare = v_uid_hardwareErsatz
		   And UpdateCName = 1;

		v_whereklausel := 'uid_hardware = ''' || RTRIM(v_uid_hardwareErsatz) || ''' and isvipc = 1';
		v_BasisObjectKey := QBM_GConvert2.FCVElementToObjectKey('Hardware', 'UID_Hardware', v_uid_hardwareErsatz, v_noCaseCheck => 1);

		-- 16592
		begin
			v_exists := 0;
			select 1 into v_exists from dual where exists
				(select 1 
					from dialogcolumn
					where UID_DialogTable = 'QER-T-Hardware'
					and ColumnName = 'UpdateCNAME'
					and IsDeactivatedByPreProcessor = 0);
			exception
			when no_data_found then
			v_exists := 0;
		end;
		if v_exists = 1 then
				QBM_GJobQueue.PJobCreate_HOUpdate('hardware'
										  , v_whereklausel
										  , v_GenProcID
										  , v_p1 => 'UpdateCNAME'
										  , v_v1 => 'True'
										  , v_BasisObjectKey   => v_BasisObjectKey
										   );	
		end if;
	End Loop;

	Close schrittHardwareUpdateCNAME;

	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);

end ZHardwareUpdateCName;
-----------------------------------------------------------------------------------------------
-- / Procedure ZHardwareUpdateCName
-----------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------
-- Procedure ZMachineHasDriver
-----------------------------------------------------------------------------------------------
Procedure ZMachineHasDriver (v_SlotNumber number
								)
as
	v_MyName varchar2(64) := 'SDL_GDBQueueTasks.ZMachineHasDriver';

	v_exists					   QBM_GTypeDefinition.YBool;
	v_genprocid 				   QBM_GTypeDefinition.YGuid;


	-- zu verarbeitende Daten
	v_BeforeQuantity_tab			   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_AfterDirect_tab			   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_AfterInDirect_tab 		   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	-- Ergebnisse
	v_DeltaDelete_tab		QBM_GTypeDefinition.YBaseForDeltaResult := QBM_GTypeDefinition.YBaseForDeltaResult();
	v_DeltaInsert_tab		QBM_GTypeDefinition.YBaseForDeltaResult := QBM_GTypeDefinition.YBaseForDeltaResult();
	v_DeltaOrigin_tab 		   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_DeltaQuantity_tab			   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	-- für Zwischenergebnisse
	v_Helper_tab				   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	Type t_Parent_tab Is Table Of QBM_GTypeDefinition.YGuid;

	v_Parent_tab				   t_Parent_tab := t_Parent_tab();

	v_InheritePhysicalDependencies Number;

	-- für Aufzeichnung
	v_IsSimulationMode			   QBM_GTypeDefinition.YBool;

	v_RowsToReset				   Number := 0;
	v_UID_Parameter_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_ObjectKey_tab QBM_GTypeDefinition.YObjectKeyTab := QBM_GTypeDefinition.YObjectKeyTab();

Begin
	Begin
		-- Ergänzung Aufzeichnung
		If QBM_GSimulation.Simulation = 1 Then
			v_IsSimulationMode := 1;
		Else
			v_IsSimulationMode := 0;
		End If;

		--/ Ergänzung Aufzeichnung

		v_InheritePhysicalDependencies := 0;

		Begin
			Select 1
			  Into v_exists
			  From DUAL
			 Where QBM_GGetInfo2.FGIConfigParmValue('SOFTWARE\INHERITEPHYSICALDEPENDENCIES') is not null;
		Exception
			When NO_DATA_FOUND Then
				v_exists := 0;
		End;

		If v_exists = 1 Then
			v_InheritePhysicalDependencies := 1;
		End If;


		-- prüfen, ob das betreffende Objekt noch existiert
		QBM_GDBQueue.PSlotResetOnMissingItem(v_SlotNumber, 'Hardware', 'UID_Hardware');

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		-------------------------------------------------------------------------
		-- zurücksetzen, falls noch Job unterwegs ist
		-------------------------------------------------------------------------
		select cu.UID_Parameter, x.XObjectKey
			bulk collect into v_UID_Parameter_tab, v_ObjectKey_tab
			from QBMDBQueueCurrent cu join Hardware x on cu.UID_Parameter = x.UID_Hardware
			where cu.SlotNumber = v_SlotNumber;

		QBM_GDBQueue.PSlotResetWhileJobRunning(v_SlotNumber, v_UID_Parameter_tab, v_ObjectKey_tab, v_MyName, v_RowsToReset);
		-------------------------------------------------------------------------
		-- / zurücksetzen, falls noch Job unterwegs ist
		-------------------------------------------------------------------------

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		Select 1
		  Into v_exists
		  From DUAL
		 Where Exists
				   (Select 1
					  From QBMDBQueueCurrent
					 Where SlotNumber = v_SlotNumber);
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
	End;

	If v_exists = 0 Then
		Return;
	End If;

	Begin
		-- Schappschuss vorher anfertigen und merken
		Select uid_driver as AssignedElement, uid_Hardware as Element, XOrigin As XOrigin, XIsInEffect as XIsInEffect, x.GenProcID
		  Bulk Collect Into v_BeforeQuantity_tab
		  From MachineHasDriver Join QBMDBQueueCurrent x On uid_hardware = x.uid_parameter
		  where SlotNumber = v_SlotNumber;

		-- zusammenstellen aller Drivers die ein Machineobjekt hat
		-- das, was der Machine direkt zugewiesen ist
		Select mhd.uid_Driver as AssignedElement, x.uid_parameter as Element, bitand(mhd.XOrigin, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 1)) as XOrigin, 1 as XIsInEffect, x.GenProcID
		  Bulk Collect Into v_AfterDirect_tab
		  From hardware h
			 , MachineHasDriver mhd
			 , driver d
			 , QBMDBQueueCurrent x
		 Where SlotNumber = v_SlotNumber
		 and mhd.uid_Hardware = x.uid_parameter
		   And h.uid_hardware = x.uid_parameter
		   And mhd.uid_driver = d.uid_driver
		   And ((d.UID_OS = h.UID_OS)
			 Or  (d.UID_OS Is Null
			  And h.UID_OS Is Null))
		   And (h.ispc = 1
			 Or  h.isServer = 1)
		and bitand(mhd.XOrigin, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 1)) > 0;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		  Select x.uid_driver as AssignedElement, x.uid_hardware as Element, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 0) as XOrigin, 1 as XIsInEffect, x.GenProcID
			Bulk Collect Into v_AfterInDirect_tab
			From ( -- das, was die Machine aus dem Arbeitsplatz direkt bekommt
				  Select  h.uid_Hardware, wdw.uid_Driver, xx.GenProcID
					 -- Buglist 10002 ausfiltern
					 -- hier nicht filtern, da das nicht von basetree kommt
					 From Hardware h
						, workdeskhasDriver wdw
						, driver d
						, QBMDBQueueCurrent xx
					Where xx.SlotNumber = v_SlotNumber
					and wdw.XOrigin > 0 and wdw.XIsInEffect = 1
					and h.uid_Hardware = xx.uid_parameter
					-- entfällt nicht wegen 25448, da keine TSBAccountDef
					  And bitand(h.XMarkedForDeletion, QBM_GGetInfo2.FGIBitPatternXMarkedForDel('|Delay|', 0)) = 0
					  And h.uid_workdesk = wdw.uid_workdesk
					  And wdw.uid_driver = d.uid_driver
					  And ((d.UID_OS = h.UID_OS)
						Or	(d.UID_OS Is Null
						 And h.UID_OS Is Null))
					  And (h.ispc = 1
						Or	h.isServer = 1)
				  Union All
				  -- Mangelrüge CK 2005-09-27
				  -- das, was die Machine über esets zu ihrem Arbeitsplatz bekommt
				  Select h.uid_Hardware, d.uid_Driver, xx.GenProcID
					From Hardware h
						 Join QBMDBQueueCurrent xx
							 On h.uid_Hardware = xx.uid_parameter
							 -- entfällt nicht wegen 25448, da keine TSBAccountDef
							And bitand(h.XMarkedForDeletion, QBM_GGetInfo2.FGIBitPatternXMarkedForDel('|Delay|', 0)) = 0
							And (h.ispc = 1
							  Or  h.isServer = 1)

							join table(QBM_GLateBinding.FTCallFTGetObjectKeys('FTGetObjectsOfWorkdesk', h.uid_workdesk)) ehe on 1 = 1

						 Join driver d
							 On ehe.column_value = d.XObjectKey
							And NVL(d.UID_OS, '##') = NVL(h.UID_OS, '##')
					where xx.SlotNumber = v_SlotNumber
				  -- \Mangelrüge CK 2005-09-27
				  Union All
				  -- das , was die Machine ber die Orgs ihres Arbeitsplatzes erbt
				  -- umgebaut wegen Eintrag 10956: View vi_v_PersonInheriteFromOrg kann bei großen Datenmengen unter Oracle nicht verwendet werden
				  Select h.uid_Hardware, ohw.uid_Driver, xx.GenProcID
					From hardware h
						 Join QBMDBQueueCurrent xx
							 On h.uid_Hardware = xx.uid_parameter
							And (h.ispc = 1
							  Or  h.isServer = 1)
							  -- entfällt nicht wegen 25448, da keine TSBAccountDef
							And bitand(h.XMarkedForDeletion, QBM_GGetInfo2.FGIBitPatternXMarkedForDel('|Delay|', 0)) = 0
							And h.IsNoInherite = 0
						 Join workdesk w
							 On h.uid_workdesk = w.uid_workdesk
							And w.IsNoInherite = 0
						 Join WorkDeskInBasetree hwo
							 On h.uid_workdesk = hwo.uid_workdesk and hwo.XOrigin > 0
						 -- Buglist 10002 ausfiltern
						 Join BaseTreeHasDriver ohw
							 On ohw.uid_org = hwo.uid_org and ohw.XOrigin > 0
						 Join basetree b
							 On b.uid_org = hwo.uid_org
							And b.IsNoInheriteToworkdesk = 0
						 Join driver d
							 On ohw.uid_driver = d.uid_driver
							And NVL(d.UID_OS, ' ') = NVL(h.UID_OS, ' ')
						where xx.SlotNumber = v_SlotNumber
				  Union
				  Select h.uid_Hardware, ohw.uid_Driver, xx.GenProcID
					From hardware h
						 Join QBMDBQueueCurrent xx
							 On h.uid_Hardware = xx.uid_parameter
							And (h.ispc = 1
							  Or  h.isServer = 1)
							  -- entfällt nicht wegen 25448, da keine TSBAccountDef
							And bitand(h.XMarkedForDeletion, QBM_GGetInfo2.FGIBitPatternXMarkedForDel('|Delay|', 0)) = 0
							And h.IsNoInherite = 0
						 Join workdesk w
							 On h.uid_workdesk = w.uid_workdesk
							And w.IsNoInherite = 0
						 Join HelperWorkDeskOrg hwo
							 On h.uid_workdesk = hwo.uid_workdesk
						 -- Buglist 10002 ausfiltern
						 Join BaseTreeHasDriver ohw
							 On ohw.uid_org = hwo.uid_org and ohw.XOrigin > 0
						 Join basetree b
							 On b.uid_org = hwo.uid_org
							And b.IsNoInheriteToworkdesk = 0
						 Join driver d
							 On ohw.uid_driver = d.uid_driver
							And NVL(d.UID_OS, ' ') = NVL(h.UID_OS, ' ')
						where xx.SlotNumber = v_SlotNumber
				  Union All
				  -- das , was die Machine ber die Basetree  erbt
				  -- umgebaut wegen Eintrag 10956: View vi_v_PersonInheriteFromOrg kann bei großen Datenmengen unter Oracle nicht verwendet werden

				  Select h.uid_Hardware, ohd.uid_Driver, xx.GenProcID
					From hardware h
						 Join QBMDBQueueCurrent xx
							 On h.uid_hardware = xx.uid_parameter
							And (h.ispc = 1
							  Or  h.isServer = 1)
							  -- entfällt nicht wegen 25448, da keine TSBAccountDef
							And bitand(h.XMarkedForDeletion, QBM_GGetInfo2.FGIBitPatternXMarkedForDel('|Delay|', 0)) = 0
							And h.IsNoInherite = 0
						 Join HardwareInBasetree hho
							 On h.uid_hardware = hho.uid_hardware and hho.XOrigin > 0
						 -- Buglist 10002 ausfiltern
						 Join BaseTreeHasDriver ohd
							 On ohd.uid_org = hho.uid_org and ohd.XOrigin > 0
						 Join basetree b
							 On b.uid_org = hho.uid_org
							And b.IsNoInheriteToHardware = 0
						 Join driver d
							 On ohd.uid_driver = d.uid_driver
							And NVL(d.UID_OS, ' ') = NVL(h.UID_OS, ' ')
					where xx.SlotNumber = v_SlotNumber
				  Union
				  Select h.uid_Hardware, ohd.uid_Driver, xx.GenProcID
					From hardware h
						 Join QBMDBQueueCurrent xx
							 On h.uid_hardware = xx.uid_parameter
							And (h.ispc = 1
							  Or  h.isServer = 1)
							  -- entfällt nicht wegen 25448, da keine TSBAccountDef
							And bitand(h.XMarkedForDeletion, QBM_GGetInfo2.FGIBitPatternXMarkedForDel('|Delay|', 0)) = 0
							And h.IsNoInherite = 0
						 Join HelperHardwareOrg hho
							 On h.uid_hardware = hho.uid_hardware
						 -- Buglist 10002 ausfiltern
						 Join BaseTreeHasDriver ohd
							 On ohd.uid_org = hho.uid_org and ohd.XOrigin > 0
						 Join basetree b
							 On b.uid_org = hho.uid_org
							And b.IsNoInheriteToHardware = 0
						 Join driver d
							 On ohd.uid_driver = d.uid_driver
							And NVL(d.UID_OS, ' ') = NVL(h.UID_OS, ' ')
					where xx.SlotNumber = v_SlotNumber
				  Union All
				  -- das , was die Machine ber den Maschinentyp erbt
				  Select h.uid_Hardware, mthd.uid_Driver, xx.GenProcID
					From hardware h
					   , MachineTypeHasDriver mthd
					   , driver d
					   , QBMDBQueueCurrent xx
				   Where xx.SlotNumber = v_SlotNumber
				   and h.uid_Hardware = xx.uid_parameter
				   -- entfällt nicht wegen 25448, da keine TSBAccountDef
					 And bitand(h.XMarkedForDeletion, QBM_GGetInfo2.FGIBitPatternXMarkedForDel('|Delay|', 0)) = 0
					 And h.UID_MachineType = mthd.UID_MachineType
					 And mthd.uid_driver = d.uid_driver
					 And NVL(d.UID_OS, '##') = NVL(h.UID_OS, '##')
					 And (h.ispc = 1
					   Or  h.isServer = 1)
				  Union All
				  -- das , was die Maschine ber den Hardwaretype erbt
				  -- Buglist 10084
				  Select h.uid_Hardware, htd.uid_Driver, xx.GenProcID
					From QBMDBQueueCurrent xx
						 Join hardware h
							 On h.uid_Hardware = xx.uid_parameter
						 Join HardwareTypeHasDriver htd
							 On h.UID_HardwareType = htd.UID_HardwareType
						 Join Driver d
							 On htd.uid_driver = d.uid_driver
				   Where xx.SlotNumber = v_SlotNumber
				   -- entfällt nicht wegen 25448, da keine TSBAccountDef
				   and bitand(h.XMarkedForDeletion, QBM_GGetInfo2.FGIBitPatternXMarkedForDel('|Delay|', 0)) = 0
					 And NVL(d.UID_OS, '##') = NVL(h.UID_OS, '##')
					 And (h.ispc = 1
					   Or  h.isServer = 1)) x
		Group By x.uid_hardware, x.uid_driver;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		-- IR 2005-07-19
		-- Erweitern um die Einträge aus SoftwareDependsOnSoftware
		If v_InheritePhysicalDependencies = 1 Then
			If v_AfterInDirect_tab.COUNT > 0 Then
				-- die indirekten
				v_Helper_tab := v_AfterInDirect_tab;

				For i In v_Helper_tab.FIRST .. v_Helper_tab.LAST Loop
					Select p.uid_parent
					  Bulk Collect Into v_Parent_tab
					  From SoftwareDependsOnSoftware p Join driver a On a.uid_driver = p.uid_parent
					 Where p.uid_child = v_Helper_tab(i).AssignedElement;

					If v_Parent_tab.COUNT > 0 Then
						For k In v_Parent_tab.FIRST .. v_Parent_tab.LAST Loop
							v_exists := 0;

							For j In v_AfterInDirect_tab.FIRST .. v_AfterInDirect_tab.LAST Loop
								If v_AfterInDirect_tab(j).Element = v_Helper_tab(i).Element
							   And v_AfterInDirect_tab(j).AssignedElement = v_Parent_tab(k) Then
									v_exists := 1;
									Exit;
								End If;
							End Loop;

							If v_exists = 0 Then
								v_AfterInDirect_tab.EXTEND(1);
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).Element := v_Helper_tab(i).Element;
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).AssignedElement := v_Parent_tab(k);
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).XOrigin := 2;
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).XIsInEffect := 1;
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).GenProcID := v_Helper_tab(i).GenProcID;
							End If;
						End Loop;
					End If;
				End Loop;
			End If; -- if v_AfterInDirect_tab.count > 0 then

			If v_AfterDirect_tab.COUNT > 0 Then
				-- die direkten
				v_Helper_tab := v_AfterDirect_tab;

				For i In v_Helper_tab.FIRST .. v_Helper_tab.LAST Loop
					Select p.uid_parent
					  Bulk Collect Into v_Parent_tab
					  From SoftwareDependsOnSoftware p Join driver a On a.uid_driver = p.uid_parent
					 Where p.uid_child = v_Helper_tab(i).AssignedElement;

					If v_Parent_tab.COUNT > 0 Then
						For k In v_Parent_tab.FIRST .. v_Parent_tab.LAST Loop
							v_exists := 0;

							If v_AfterInDirect_tab.COUNT > 0 Then
								For j In v_AfterInDirect_tab.FIRST .. v_AfterInDirect_tab.LAST Loop
									If v_AfterInDirect_tab(j).Element = v_Helper_tab(i).Element
								   And v_AfterInDirect_tab(j).AssignedElement = v_Parent_tab(k) Then
										v_exists := 1;
										Exit;
									End If;
								End Loop;
							End If;

							If v_exists = 0 Then
								v_AfterInDirect_tab.EXTEND(1);
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).Element := v_Helper_tab(i).Element;
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).AssignedElement := v_Parent_tab(k);
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).XOrigin := 2;
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).XIsInEffect := 1;
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).GenProcID := v_Helper_tab(i).GenProcID;
							End If;
						End Loop;
					End If;
				End Loop;
			End If; -- if v_AfterDirect_tab.count > 0 then

			-- Erweitern um die Treiber, die über die Applikationen kommen
			Select p.uid_parent as AssignedElement, xx.uid_parameter as Element, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 0) as XOrigin, 1 as XIsInEffect, xx.GenProcID
			  Bulk Collect Into v_Helper_tab
			  From QBMDBQueueCurrent xx
				 , hardware h
				 , workdeskHasApp wha
				 , SoftwareDependsOnSoftware p
				 , driver a
			 Where xx.SlotNumber = v_SlotNumber
				and xx.uid_parameter = h.uid_hardware
			   And (h.ispc = 1
				 Or  h.isServer = 1)
			   And bitand(h.XMarkedForDeletion, QBM_GGetInfo2.FGIBitPatternXMarkedForDel('|Delay|', 0)) = 0
			   And wha.uid_workdesk = h.uid_workdesk
			    and wha.XIsInEffect = 1
			   And wha.uid_application = p.uid_child
			   -- eigentlich noch join über Application, erledigt sich aber mit bha
			   And a.uid_driver = p.uid_parent;

			QBM_GCalculate.PCollectionUnion(v_AfterInDirect_tab, v_Helper_tab);
		-- \ Erweitern um die Einträge aus SoftwareDependsOnSoftware
		End If; -- v_InheritePhysicalDependencies = 1
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	-----------------------------------------------------------------------
	-- Vergleich der  Mengen vorher und nachher
	-- Veränderungen bestimmen
	-----------------------------------------------------------------------

	Begin
		QBM_GCalculate.PCalculateDelta(v_DeltaQuantity		  => 0
							  , v_DeltaDelete		  => 0
							  , v_DeltaInsert		  => 1
							  , v_DeltaOrigin 	  => 1
							  , v_UseIsInEffect => 1
							  , v_BeforeQuantity_tab	  => v_BeforeQuantity_tab
							  , v_AfterDirect_tab	  => v_AfterDirect_tab
							  , v_AfterInDirect_tab   => v_AfterInDirect_tab
							  , -- Ergebnisse
							   v_DeltaDelete_tab	  => v_DeltaDelete_tab
							  , v_DeltaInsert_tab	  => v_DeltaInsert_tab
							  , v_DeltaOrigin_tab   => v_DeltaOrigin_tab
							  , v_DeltaQuantity_tab	  => v_DeltaQuantity_tab
							   );


	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		If v_DeltaOrigin_tab.COUNT > 0 Then
			QBM_GMNTable.PMNTableOriginUpdate('MachineHasDriver', 'UID_Hardware', 'UID_Driver', v_DeltaOrigin_tab);
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		If v_DeltaInsert_tab.COUNT > 0 Then
			QBM_GMNTable.PMNTableInsert('MachineHasDriver', 'UID_Hardware', 'UID_Driver', v_DeltaInsert_tab
												, v_FKTableNameElement => 'Hardware'
												, v_FKColumnNameElement => 'UID_Hardware'
										);
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;
	

end ZMachineHasDriver;
-----------------------------------------------------------------------------------------------
-- / Procedure ZMachineHasDriver
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-- Procedure ZOrgHasDriver
-----------------------------------------------------------------------------------------------
Procedure ZOrgHasDriver (v_SlotNumber number
								)
as
	v_MyName varchar2(64) := 'SDL_GDBQueueTasks.ZOrgHasDriver';
	v_UID_BasetreeAssignToUse QBM_GTypeDefinition.YGuid := 'SDL-AsgnBT-Driver';

	v_exists					   QBM_GTypeDefinition.YBool;


	-- zu verarbeitende Daten
	v_BeforeQuantity_tab			   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_AfterDirect_tab			   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_AfterInDirect_tab 		   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	-- Ergebnisse
	v_DeltaDelete_tab		QBM_GTypeDefinition.YBaseForDeltaResult := QBM_GTypeDefinition.YBaseForDeltaResult();
	v_DeltaInsert_tab		QBM_GTypeDefinition.YBaseForDeltaResult := QBM_GTypeDefinition.YBaseForDeltaResult();
	v_DeltaOrigin_tab 		   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_DeltaQuantity_tab			   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	-- für Zwischenergebnisse
	v_Helper_tab				   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	Type t_Parent_tab Is Table Of QBM_GTypeDefinition.YGuid;

	v_Parent_tab				   t_Parent_tab := t_Parent_tab();

	v_UID_Orgroot				   QBM_GTypeDefinition.YGuid;
	v_GenProcID 				   QBM_GTypeDefinition.YGuid;

	v_InheritePhysicalDependencies Number;

	-- für Aufzeichnung
	v_IsSimulationMode			   QBM_GTypeDefinition.YBool;

	
	v_RowsToReset				   Number := 0;
	v_UID_Parameter_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_ObjectKey_tab QBM_GTypeDefinition.YObjectKeyTab := QBM_GTypeDefinition.YObjectKeyTab();

Begin
	
	-- Ergänzung Aufzeichnung
	If QBM_GSimulation.Simulation = 1 Then
		v_IsSimulationMode := 1;
	Else
		v_IsSimulationMode := 0;
	End If;

	--/ Ergänzung Aufzeichnung

	v_InheritePhysicalDependencies := 0;

	Begin
		Select 1
		  Into v_exists
		  From DUAL
		 Where QBM_GGetInfo2.FGIConfigParmValue('SOFTWARE\INHERITEPHYSICALDEPENDENCIES') is not null;
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
	End;

	If v_exists = 1 Then
		v_InheritePhysicalDependencies := 1;
	End If;

	begin
		-- prüfen, ob das betreffende Objekt noch existiert
		QBM_GDBQueue.PSlotResetOnMissingItem(v_SlotNumber, 'BaseTree', 'UID_Org');

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	
	begin
		-- 18953
		QER_GCommon.PSlotResetOnInvalidRoot(v_Slotnumber, v_UID_BasetreeAssignToUse);
		-- / 18953
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;	
	

	Begin
		-------------------------------------------------------------------------
		-- zurücksetzen, falls noch Job unterwegs ist
		-------------------------------------------------------------------------
		select cu.UID_Parameter, x.XObjectKey
			bulk collect into v_UID_Parameter_tab, v_ObjectKey_tab
			from QBMDBQueueCurrent cu join Basetree x on cu.UID_Parameter = x.UID_Org
			where cu.SlotNumber = v_SlotNumber;

		QBM_GDBQueue.PSlotResetWhileJobRunning(v_SlotNumber, v_UID_Parameter_tab, v_ObjectKey_tab, v_MyName, v_RowsToReset);
		-------------------------------------------------------------------------
		-- / zurücksetzen, falls noch Job unterwegs ist
		-------------------------------------------------------------------------

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		Select 1
		  Into v_exists
		  From DUAL
		 Where Exists
				   (Select 1
					  From QBMDBQueueCurrent
					 Where SlotNumber = v_SlotNumber);
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
	End;

	If v_exists = 0 Then
		Return;
	End If;

	Begin
		-- Schappschuss vorher anfertigen und merken
		Select uid_driver as AssignedElement, uid_org as Element, XOrigin As XOrigin, null, x.GenProcID
		  Bulk Collect Into v_BeforeQuantity_tab
		  From basetreeHasDriver ohd, QBMDBQueueCurrent x
		 Where ohd.uid_org = x.uid_parameter
		 and SlotNumber = v_SlotNumber;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		-- zusammenstellen aller Treiber, die die Organisation hat
		Select Distinct oha.uid_driver as AssignedElement, oha.uid_org as Element, bitand(oha.XOrigin, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 1)) as XOrigin, null, x.GenProcID
		  Bulk Collect Into v_AfterDirect_tab
		  From basetreehasdriver oha, QBMDBQueueCurrent x
		 Where SlotNumber = v_SlotNumber
		 and oha.uid_org = x.uid_parameter
		 and bitand(oha.XOrigin, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 1)) > 0;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		Select Distinct oha.uid_driver as AssignedElement, x.uid_parameter as Element, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 0) as XOrigin, null, x.GenProcID
		  Bulk Collect Into v_AfterInDirect_tab
		  From QBMDBQueueCurrent x
			   Join BaseTreeCollection oc
				   On oc.uid_org = x.uid_parameter
			   Join BaseTreeHasDriver oha
				   On oha.uid_org = oc.uid_parentorg and oha.XOrigin > 0
		 Where SlotNumber = v_SlotNumber
		 and oc.uid_org <> oc.uid_parentorg
			-- nur das, was die Vorgänger zugewiesen haben, nicht das, was sie selber nur erben
            and bitand(oha.XOrigin, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 1)) > 0
		-- Wegen ESet
		Union
		Select y.uid_Driver, x.uid_parameter, 2, null, x.GenProcID
		  From QBMDBQueueCurrent x

			join table(QBM_GLateBinding.FTCallFTGetObjectKeys('FTGetObjectsOfBasetree', x.uid_Parameter)) ehe on 1 = 1

			   Join Driver y
				   On ehe.column_value = y.XObjectKey
					join BaseTree b on x.uid_Parameter = b.UID_Org
					join OrgRootAssign oa on oa.UID_OrgRoot = b.UID_OrgRoot
					where oa.UID_BaseTreeAssign = v_UID_BasetreeAssignToUse
						and oa.IsAssignmentAllowed = 1
						and oa.IsDirectAssignmentAllowed = 1
						-- 26063 Eset auf BO und PR-Knoten nicht ausmultiplizieren
						and not (b.UID_OrgRoot in ( 'QER-V-ITShopOrg',  'QER-V-ITShopSrc')
									and b.ITShopInfo in ( 'BO', 'PR')
								)
						and SlotNumber = v_SlotNumber;
	-- / Wegen ESet

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	-- IR 2005-07-19
	-- Erweitern um die Einträge aus SoftwareDependsOnSoftware
	If v_InheritePhysicalDependencies = 1 Then
		If v_AfterInDirect_tab.COUNT > 0 Then
			-- die indirekten
			v_Helper_tab := v_AfterInDirect_tab;

			For i In v_Helper_tab.FIRST .. v_Helper_tab.LAST Loop
				Select p.uid_parent
				  Bulk Collect Into v_Parent_tab
				  From SoftwareDependsOnSoftware p Join driver a On a.uid_driver = p.uid_parent
				 Where p.uid_child = v_Helper_tab(i).AssignedElement;

				If v_Parent_tab.COUNT > 0 Then
					For k In v_Parent_tab.FIRST .. v_Parent_tab.LAST Loop
						v_exists := 0;

						For j In v_AfterInDirect_tab.FIRST .. v_AfterInDirect_tab.LAST Loop
							If v_AfterInDirect_tab(j).Element = v_Helper_tab(i).Element
						   And v_AfterInDirect_tab(j).AssignedElement = v_Parent_tab(k) Then
								v_exists := 1;
								Exit;
							End If;
						End Loop;

						If v_exists = 0 Then
							v_AfterInDirect_tab.EXTEND(1);
							v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).Element := v_Helper_tab(i).Element;
							v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).AssignedElement := v_Parent_tab(k);
							v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).XOrigin := 2;
							v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).GenProcID := v_Helper_tab(i).GenProcID;
						End If;
					End Loop;
				End If;
			End Loop;
		End If; -- if v_AfterInDirect_tab.count > 0 then

		If v_AfterDirect_tab.COUNT > 0 Then
			-- die direkten
			v_Helper_tab := v_AfterDirect_tab;

			For i In v_Helper_tab.FIRST .. v_Helper_tab.LAST Loop
				Select p.uid_parent
				  Bulk Collect Into v_Parent_tab
				  From SoftwareDependsOnSoftware p Join driver a On a.uid_driver = p.uid_parent
				 Where p.uid_child = v_Helper_tab(i).AssignedElement;

				If v_Parent_tab.COUNT > 0 Then
					For k In v_Parent_tab.FIRST .. v_Parent_tab.LAST Loop
						v_exists := 0;

						If v_AfterInDirect_tab.COUNT > 0 Then
							For j In v_AfterInDirect_tab.FIRST .. v_AfterInDirect_tab.LAST Loop
								If v_AfterInDirect_tab(j).Element = v_Helper_tab(i).Element
							   And v_AfterInDirect_tab(j).AssignedElement = v_Parent_tab(k) Then
									v_exists := 1;
									Exit;
								End If;
							End Loop;
						End If;

						If v_exists = 0 Then
							v_AfterInDirect_tab.EXTEND(1);
							v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).Element := v_Helper_tab(i).Element;
							v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).AssignedElement := v_Parent_tab(k);
							v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).XOrigin := 2;
							v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).GenProcID := v_Helper_tab(i).GenProcID;
						End If;
					End Loop;
				End If;
			End Loop;
		End If; -- if v_AfterDirect_tab.count > 0 then

		Select Distinct p.uid_parent as AssignedElement, bha.uid_org as Element, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 0) as XOrigin, null, x.GenProcID
		  Bulk Collect Into v_Helper_tab
		  From BasetreeHasApp bha
			   Join QBMDBQueueCurrent x
				   On bha.uid_org = x.uid_parameter and bha.XOrigin > 0
			   Join SoftwareDependsOnSoftware p
				   On bha.uid_application = p.uid_child
			   -- eigentlich noch join über Application, erledigt sich aber mit bha
			   Join driver a
				   On a.uid_driver = p.uid_parent
			where SlotNumber = v_SlotNumber;

		If v_Helper_tab.COUNT > 0 Then
			For i In v_Helper_tab.FIRST .. v_Helper_tab.LAST Loop
				v_exists := 0;

				If v_AfterInDirect_tab.COUNT > 0 Then
					For j In v_AfterInDirect_tab.FIRST .. v_AfterInDirect_tab.LAST Loop
						If v_AfterInDirect_tab(j).Element = v_Helper_tab(i).Element
					   And v_AfterInDirect_tab(j).AssignedElement = v_Helper_tab(i).AssignedElement Then
							v_exists := 1;
							Exit;
						End If;
					End Loop;
				End If;

				If v_exists = 0 Then
					v_AfterInDirect_tab.EXTEND(1);
					v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).Element := v_Helper_tab(i).Element;
					v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).AssignedElement := v_Helper_tab(i).AssignedElement;
					v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).XOrigin := 2;
					v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).GenProcID := v_Helper_tab(i).GenProcID;
				End If;
			End Loop;
		End If; -- if v_Helper_tab.Count > 0 then
	End If;

	-- \ Erweitern um die Einträge aus SoftwareDependsOnSoftware

	-----------------------------------------------------------------------
	-- Vergleich der  Mengen vorher und nachher
	-- Veränderungen bestimmen
	-----------------------------------------------------------------------

	Begin
		QBM_GCalculate.PCalculateDelta(v_DeltaQuantity		  => 0
							  , v_DeltaDelete		  => 0
							  , v_DeltaInsert		  => 1
							  , v_DeltaOrigin 	  => 1
							  , v_UseIsInEffect => 0
							  , v_BeforeQuantity_tab	  => v_BeforeQuantity_tab
							  , v_AfterDirect_tab	  => v_AfterDirect_tab
							  , v_AfterInDirect_tab   => v_AfterInDirect_tab
							  , -- Ergebnisse
							   v_DeltaDelete_tab	  => v_DeltaDelete_tab
							  , v_DeltaInsert_tab	  => v_DeltaInsert_tab
							  , v_DeltaOrigin_tab   => v_DeltaOrigin_tab
							  , v_DeltaQuantity_tab	  => v_DeltaQuantity_tab
							   );


	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;


	Begin
		If v_DeltaOrigin_tab.COUNT > 0 Then
			QBM_GMNTable.PMNTableOriginUpdate('BaseTreeHasDriver', 'UID_Org', 'UID_Driver', v_DeltaOrigin_tab);
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		If v_DeltaInsert_tab.COUNT > 0 Then
			QER_GBaseTree.PMNTableAddViewProperties('BaseTreeHasDriver', v_DeltaInsert_tab);
			QBM_GMNTable.PMNTableInsert('BaseTreeHasDriver', 'UID_Org', 'UID_Driver', v_DeltaInsert_tab, v_TargetIsView => 1
												, v_FKTableNameElement => 'BaseTree'
												, v_FKColumnNameElement => 'UID_Org'
										);
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;


end ZOrgHasDriver;
-----------------------------------------------------------------------------------------------
-- / Procedure ZOrgHasDriver
-----------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------
-- Procedure ZSoftwareDependsPhysical
-----------------------------------------------------------------------------------------------
Procedure ZSoftwareDependsPhysical (v_SlotNumber number
									, v_dummy1 varchar2
									, v_dummy2 varchar2
									, v_GenProcIDDummy varchar2
									)
as

	v_GenProcID QBM_GTypeDefinition.YGuid := newid();

	-- Variablen für den Job
	v_where 				   varchar2(1024);
	v_BasisObjectKey		   JobQueue.BasisObjectKey%Type;

	-- zu verarbeitende Daten
	v_BeforeQuantity_tab		   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_AfterDirect_tab		   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_AfterInDirect_tab 	   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	-- Ergebnisse
	v_DeltaDelete_tab		QBM_GTypeDefinition.YBaseForDeltaResult := QBM_GTypeDefinition.YBaseForDeltaResult();
	v_DeltaInsert_tab		QBM_GTypeDefinition.YBaseForDeltaResult := QBM_GTypeDefinition.YBaseForDeltaResult();
	v_DeltaOrigin_tab 	   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_DeltaQuantity_tab		   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	-- für Zwischenergebnisse
	v_Helper_tab			   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_HelperHelper_tab		   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	-- für Aufzeichnung
	v_IsSimulationMode		   QBM_GTypeDefinition.YBool;

	v_count 				   Number;
	v_exists				   QBM_GTypeDefinition.YBool;

	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();
Begin
	

	-- Ergänzung Aufzeichnung
	If QBM_GSimulation.Simulation = 1 Then
		v_IsSimulationMode := 1;
	Else
		v_IsSimulationMode := 0;
	End If;

	--/ Ergänzung Aufzeichnung

	-- alle die bestimmen, die nirgendwo als Child auftauchen, die sind erst mal die Wurzel

	Begin
		-- Schappschuss vorher anfertigen und merken
		Select UID_Parent As AssignedElement, UID_Child As Element, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 0) as XOrigin, null, v_GenProcID
		  Bulk Collect Into v_BeforeQuantity_tab
		  From softwaredependsonsoftware;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		Select x.UID_Parent As AssignedElement, x.UID_Child As Element, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 0) as XOrigin, null, v_GenProcID
		  Bulk Collect Into v_AfterInDirect_tab
		  From (Select uid_applicationChild As uid_child, uid_applicationParent As uid_parent
				  From applicationdependsonapp
				 Where isphysicaldependent = 1
				Union
				Select uid_DriverChild, uid_DriverParent
				  From driverdependsondriver
				 Where isphysicaldependent = 1
				Union
				Select UID_ApplicationChild, UID_DriverParent From ApplicationDependsonDriver) x;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	-- jetzt zyklisch die überbrückungen auffüllen
	v_count := 0;

	While v_AfterInDirect_tab.COUNT <> v_count Loop
		v_Helper_tab := QBM_GTypeDefinition.YBaseForDelta();
		v_count := v_AfterInDirect_tab.COUNT;

		For i In v_AfterInDirect_tab.FIRST .. v_AfterInDirect_tab.LAST Loop
			For j In v_AfterInDirect_tab.FIRST .. v_AfterInDirect_tab.LAST Loop
				If v_AfterInDirect_tab(i).AssignedElement = v_AfterInDirect_tab(j).Element
			   And i <> j Then
					-- Überbrückung gefunden
					v_Helper_tab.EXTEND(1);
					v_Helper_tab(v_Helper_tab.LAST).Element := v_AfterInDirect_tab(i).Element;
					v_Helper_tab(v_Helper_tab.LAST).AssignedElement := v_AfterInDirect_tab(j).AssignedElement;
					v_Helper_tab(v_Helper_tab.LAST).XOrigin := 2;
					v_Helper_tab(v_Helper_tab.LAST).GenProcID := v_GenProcID;
				End If;
			End Loop;
		End Loop;

		-- jetzt noch einfügen, falls noch nicht vorhanden
		QBM_GCalculate.PCollectionUnion(v_AfterInDirect_tab, v_Helper_tab);
	End Loop;

	-----------------------------------------------------------------------
	-- Vergleich der  Mengen vorher und nachher
	-- Veränderungen bestimmen
	-----------------------------------------------------------------------

	Begin
		QBM_GCalculate.PCalculateDelta(v_DeltaQuantity		  => 1
							  , v_DeltaDelete		  => 1
							  , v_DeltaInsert		  => 1
							  , v_DeltaOrigin 	  => 0
							  , v_UseIsInEffect => 0
							  , v_BeforeQuantity_tab	  => v_BeforeQuantity_tab
							  , v_AfterDirect_tab	  => v_AfterDirect_tab
							  , v_AfterInDirect_tab   => v_AfterInDirect_tab
							  , -- Ergebnisse
							   v_DeltaDelete_tab	  => v_DeltaDelete_tab
							  , v_DeltaInsert_tab	  => v_DeltaInsert_tab
							  , v_DeltaOrigin_tab   => v_DeltaOrigin_tab
							  , v_DeltaQuantity_tab	  => v_DeltaQuantity_tab
							   );


	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	-- jetzt vergleichen
	-- alle die wo Unterschiede sind (nicht mehr da, neu da oder Menge der Vorgänger geändert) , nachberechnungen für Application bzw. Treiber machen
	-- perspektivisch auch die Schreibaufträge für den ViClient (Steuerdatei) einstellen (updatecname)

	Begin
		If v_DeltaDelete_tab.COUNT > 0 Then
			For i In v_DeltaDelete_tab.FIRST .. v_DeltaDelete_tab.LAST Loop
				-- Ergänzung Aufzeichnung
				If v_IsSimulationMode = 1 Then
					Insert Into Temp_TriggerOperation(Operation
													, BaseObjectType
													, ColumnName
													, ObjectKey
													, OldValue
													 )
						 Values ('D'
							   , 'softwaredependsonsoftware'
							   , null
							   , QBM_GConvert2.FCVElementToObjectKey('SoftwareDependsOnSoftware'
												 , 'UID_Child'
												 , v_DeltaDelete_tab(i).Element
												 , 'UID_Parent'
												 , v_DeltaDelete_tab(i).AssignedElement
												 , v_noCaseCheck => 1
												  )
							   , null
								);
				End If;

				--/ Ergänzung Aufzeichnung

				QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

				Delete From softwaredependsonsoftware
					  Where uid_child = v_DeltaDelete_tab(i).Element
						And uid_parent = v_DeltaDelete_tab(i).AssignedElement;
			End Loop;
		End If; -- if v_DeltaDelete_tab.Count > 0 then
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	-- neue aufnehmen
	Begin
		If v_DeltaInsert_tab.COUNT > 0 Then
			For i In v_DeltaInsert_tab.FIRST .. v_DeltaInsert_tab.LAST Loop
				-- Ergänzung Aufzeichnung
				If v_IsSimulationMode = 1 Then
					Insert Into Temp_TriggerOperation(Operation
													, BaseObjectType
													, ColumnName
													, ObjectKey
													, OldValue
													 )
						 Values ('I'
							   , 'softwaredependsonsoftware'
							   , null
							   , QBM_GConvert2.FCVElementToObjectKey('SoftwareDependsOnSoftware'
												 , 'UID_Child'
												 , v_DeltaInsert_tab(i).Element
												 , 'UID_Parent'
												 , v_DeltaInsert_tab(i).AssignedElement
												 , v_noCaseCheck => 1
												  )
							   , null
								);
				End If;

				--/ Ergänzung Aufzeichnung

				QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

				Insert Into softwaredependsonsoftware(uid_child, uid_parent, XObjectKey)
					 Values (v_DeltaInsert_tab(i).Element
						   , v_DeltaInsert_tab(i).AssignedElement
						   , QBM_GConvert2.FCVElementToObjectKey('SoftwareDependsOnSoftware'
											 , 'UID_Child'
											 , v_DeltaInsert_tab(i).Element
											 , 'UID_Parent'
											 , v_DeltaInsert_tab(i).AssignedElement
											 , v_noCaseCheck => 1
											  )
							);
			End Loop;
		End If; -- if v_DeltaDelete_tab.Count > 0 then
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	-- hier kommt die Aktion hin, die für alle Profile eine Methode zum aktualisieren der Vorgängerliste aufruft
	-- Folgejobs für alle einstellen, wo sich die Menge der Vorgänger geändert hat
	Begin
		If v_DeltaQuantity_tab.COUNT > 0 Then
			For i In v_DeltaQuantity_tab.FIRST .. v_DeltaQuantity_tab.LAST Loop
				Begin
					v_exists := 0;

					Select 1
					  Into v_exists
					  From DUAL
					 Where Exists
							   (Select 1
								  From application
								 Where uid_application = v_DeltaQuantity_tab(i).Element);
				Exception
					When NO_DATA_FOUND Then
						v_exists := 0;
				End;

				If v_exists = 1 Then
					v_where := 'uid_application = ''' || RTRIM(v_DeltaQuantity_tab(i).Element) || '''';
					v_BasisObjectKey := QBM_GConvert2.FCVElementToObjectKey('ApplicationProfile', 'UID_Application', v_DeltaQuantity_tab(i).Element, v_noCaseCheck => 1);
					QBM_GJobQueue.PJobCreate_HOFireEvent('ApplicationProfile'
											  , v_where
											  , 'WritePathVII'
											  , v_GenProcID
											  , v_checkForExisting	 => 1
											  , v_BasisObjectKey	 => v_BasisObjectKey
											   );
					QBM_GDBQueue.PDBQueueInsert_Single('APC-K-AllForOneApplication'
										, v_DeltaQuantity_tab(i).Element
										, null
										, v_GenProcID
										 );
				Else
					v_where := 'uid_Driver = ''' || RTRIM(v_DeltaQuantity_tab(i).Element) || '''';
					v_BasisObjectKey := QBM_GConvert2.FCVElementToObjectKey('DriverProfile', 'UID_Driver', v_DeltaQuantity_tab(i).Element, v_noCaseCheck => 1);
					QBM_GJobQueue.PJobCreate_HOFireEvent('DriverProfile'
											  , v_where
											  , 'WritePathVII'
											  , v_GenProcID
											  , v_checkForExisting	 => 1
											  , v_BasisObjectKey	 => v_BasisObjectKey
											   );
					QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-AllForOneDriver'
										, v_DeltaQuantity_tab(i).Element
										, null
										, v_GenProcID
										 );
				End If;
			End Loop;
		End If; -- if v_DeltaQuantity_tab.Count > 0 then
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);

end ZSoftwareDependsPhysical;
-----------------------------------------------------------------------------------------------
-- / Procedure ZSoftwareDependsPhysical
-----------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------
-- Procedure ZSoftwareExclusion
-----------------------------------------------------------------------------------------------
Procedure ZSoftwareExclusion (v_SlotNumber number
									, v_sw1 varchar2
									, v_dummy2 varchar2
									, v_GenProcID varchar2
									)
as

	v_exists QBM_GTypeDefinition.YBool;
	-- Variablen für den Job
	v_uid	 QBM_GTypeDefinition.YGuid;
	v_where  varchar2(1024);
Begin
	-- hier kommt die Aktion hin, die für alle Profile eine Methode zum aktualisieren
	-- der Path.vii aufruft

	Select COUNT(*)
	  Into v_exists
	  From Application
	 Where uid_application = v_SW1;

	If v_exists > 0 Then
		v_where := 'uid_application = ''' || RTRIM(v_SW1) || '''';
		QBM_GJobQueue.PJobCreate_HOFireEvent('ApplicationProfile'
								  , v_where
								  , 'WritePathVII'
								  , v_genprocid
								  , v_checkForExisting	 => 1
								   );
	End If;

	Select COUNT(*)
	  Into v_exists
	  From Driver
	 Where uid_Driver = v_SW1;

	If v_exists > 0 Then
		v_where := 'uid_Driver = ''' || RTRIM(v_SW1) || '''';
		QBM_GJobQueue.PJobCreate_HOFireEvent('DriverProfile'
								  , v_where
								  , 'WritePathVII'
								  , v_genprocid
								  , v_checkForExisting	 => 1
								   );
	End If;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);

end ZSoftwareExclusion;
-----------------------------------------------------------------------------------------------
-- / Procedure ZSoftwareExclusion
-----------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------
-- Procedure ZSoftwareExclusionADD
-----------------------------------------------------------------------------------------------
Procedure ZSoftwareExclusionADD (v_SlotNumber number
									, v_sw1 varchar2
									, v_sw2 varchar2
									, v_GenProcID varchar2
									)
as


	v_exists				   QBM_GTypeDefinition.YBool;

	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();
Begin
	

	-- bestimmen, was wir haben
	Select COUNT(*)
	  Into v_exists
	  From application
	 Where uid_application = v_sw1;

	If v_exists > 0 Then -- dann haben wir App
		QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

		Insert Into ApplicationExcludeApp(UID_Application
										, UID_ApplicationExcluded
										, XDateInserted
										, XDateUpdated
										, XUserInserted
										, XUserUpdated
										, XObjectKey
										 )
			Select v_SW2
				 , v_sw1
				 , GetUTCDate
				 , GetUTCDate
				 , 'DBScheduler'
				 , 'DBScheduler'
				 , QBM_GConvert2.FCVElementToObjectKey('ApplicationExcludeApp'
								   , 'UID_Application'
								   , v_SW2
								   , 'UID_ApplicationExcluded'
								   , v_sw1
								   , v_noCaseCheck => 1
									)
			  From DUAL
			 Where Not Exists
					   (Select 1
						  From ApplicationExcludeApp aa
						 Where aa.uid_application = v_Sw2
						   And aa.UID_ApplicationExcluded = v_sw1);

		If Sql%Rowcount > 0 Then
			QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-SoftwareExclusion'
								, v_sw1
								, null
								, v_GenProcID
								 );
			QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-SoftwareExclusion'
								, v_sw2
								, null
								, v_GenProcID
								 );
		End If;
	End If;

	Select COUNT(*)
	  Into v_exists
	  From Driver
	 Where uid_Driver = v_sw1;

	If v_exists > 0 Then -- dann haben wir Driver
		QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

		Insert Into DriverExcludeDriver(UID_Driver
									  , UID_DriverExcluded
									  , XDateInserted
									  , XDateUpdated
									  , XUserInserted
									  , XUserUpdated
									  , XObjectKey
									   )
			Select v_SW2
				 , v_sw1
				 , GetUTCDate
				 , GetUTCDate
				 , 'DBScheduler'
				 , 'DBScheduler'
				 , QBM_GConvert2.FCVElementToObjectKey('DriverExcludeDriver'
								   , 'UID_Driver'
								   , v_SW2
								   , 'UID_DriverExcluded'
								   , v_SW1
								   , v_noCaseCheck => 1
									)
			  From DUAL
			 Where Not Exists
					   (Select 1
						  From DriverExcludeDriver aa
						 Where aa.uid_Driver = v_Sw2
						   And aa.UID_DriverExcluded = v_sw1);

		If Sql%Rowcount > 0 Then
			QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-SoftwareExclusion'
								, v_sw1
								, null
								, v_GenProcID
								 );
			QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-SoftwareExclusion'
								, v_sw2
								, null
								, v_GenProcID
								 );
		End If;
	End If;

	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);


end ZSoftwareExclusionADD;
-----------------------------------------------------------------------------------------------
-- / Procedure ZSoftwareExclusionADD
-----------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------
-- Procedure ZSoftwareExclusionDEL
-----------------------------------------------------------------------------------------------
Procedure ZSoftwareExclusionDEL (v_SlotNumber number
									, v_sw1 varchar2
									, v_sw2 varchar2
									, v_GenProcID varchar2
									)
as

	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();
Begin
	

	QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

	Delete DriverExcludeDriver
	 Where uid_driver = v_SW1
	   And UID_DriverExcluded = v_SW2;

	Delete DriverExcludeDriver
	 Where uid_driver = v_SW2
	   And UID_DriverExcluded = v_SW1;

	Delete ApplicationExcludeApp
	 Where uid_Application = v_SW1
	   And UID_ApplicationExcluded = v_SW2;

	Delete ApplicationExcludeApp
	 Where uid_Application = v_SW2
	   And UID_ApplicationExcluded = v_SW1;

	QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-SoftwareExclusion'
						, v_sw1
						, null
						, v_GenProcID
						 );
	QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-SoftwareExclusion'
						, v_sw2
						, null
						, v_GenProcID
						 );

	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);


end ZSoftwareExclusionDEL;
-----------------------------------------------------------------------------------------------
-- / Procedure ZSoftwareExclusionDEL
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-- Procedure ZWorkDeskHasDriver
-----------------------------------------------------------------------------------------------
Procedure ZWorkDeskHasDriver (v_SlotNumber number
								)
as
	v_MyName varchar2(64) := 'SDL_GDBQueueTasks.ZWorkDeskHasDriver';

	v_exists					   QBM_GTypeDefinition.YBool;
	v_genprocid 				   QBM_GTypeDefinition.YGuid;

	v_InheritePhysicalDependencies Number;

	-- für Aufzeichnung
	v_IsSimulationMode			   QBM_GTypeDefinition.YBool;

	v_RowsToReset				   Number := 0;
	v_UID_Parameter_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_ObjectKey_tab QBM_GTypeDefinition.YObjectKeyTab := QBM_GTypeDefinition.YObjectKeyTab();

	-- zu verarbeitende Daten
	v_BeforeQuantity_tab			   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_AfterDirect_tab			   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_AfterInDirect_tab 		   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	-- Ergebnisse
	v_DeltaDelete_tab		QBM_GTypeDefinition.YBaseForDeltaResult := QBM_GTypeDefinition.YBaseForDeltaResult();
	v_DeltaInsert_tab		QBM_GTypeDefinition.YBaseForDeltaResult := QBM_GTypeDefinition.YBaseForDeltaResult();
	v_DeltaOrigin_tab 		   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_DeltaQuantity_tab			   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	-- für Zwischenergebnisse
	v_Helper_tab				   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	Type t_Parent_tab Is Table Of QBM_GTypeDefinition.YGuid;

	v_Parent_tab				   t_Parent_tab := t_Parent_tab();

Begin


	-- Ergänzung Aufzeichnung
	If QBM_GSimulation.Simulation = 1 Then
		v_IsSimulationMode := 1;
	Else
		v_IsSimulationMode := 0;
	End If;
	--/ Ergänzung Aufzeichnung

	v_InheritePhysicalDependencies := 0;

	Begin
		Select 1
		  Into v_exists
		  From DUAL
		 Where QBM_GGetInfo2.FGIConfigParmValue('SOFTWARE\INHERITEPHYSICALDEPENDENCIES') is not null;
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
	End;

	If v_exists = 1 Then
		v_InheritePhysicalDependencies := 1;
	End If;


	begin
		-- prüfen, ob das betreffende Objekt noch existiert
		QBM_GDBQueue.PSlotResetOnMissingItem(v_SlotNumber, 'Workdesk', 'UID_Workdesk');

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;


	Begin
		-------------------------------------------------------------------------
		-- zurücksetzen, falls noch Job unterwegs ist
		-------------------------------------------------------------------------
		select cu.UID_Parameter, x.XObjectKey
			bulk collect into v_UID_Parameter_tab, v_ObjectKey_tab
			from QBMDBQueueCurrent cu join Workdesk x on cu.UID_Parameter = x.UID_Workdesk
			where cu.SlotNumber = v_SlotNumber;

		QBM_GDBQueue.PSlotResetWhileJobRunning(v_SlotNumber, v_UID_Parameter_tab, v_ObjectKey_tab, v_MyName, v_RowsToReset);
		-------------------------------------------------------------------------
		-- / zurücksetzen, falls noch Job unterwegs ist
		-------------------------------------------------------------------------
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		Select 1
		  Into v_exists
		  From DUAL
		 Where Exists
				   (Select 1
					  From QBMDBQueueCurrent
					 Where SlotNumber = v_SlotNumber);
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
	End;

	If v_exists = 0 Then
		Return;
	End If;

	Begin
		-- alle bisherigen Driver des Arbeitsplatzes merken
		Select uid_driver As AssignedElement, uid_workdesk As Element, XOrigin As XOrigin, XIsInEffect as XIsInEffect, x.GenProcID
		  Bulk Collect Into v_BeforeQuantity_tab
		  From WorkdeskHasDriver Join QBMDBQueueCurrent x On uid_workdesk = x.uid_parameter
		  where SlotNumber = v_SlotNumber;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	-- zusammenstellen aller Driver, die der Arbeitsplatz hat
	--	  diese können kommen
	--	  aus  WorkdeskHasDriver
	-- über WorkdeskinOrg

	Begin
		Select uid_Driver As AssignedElement, uid_workdesk As Element, bitand(XOrigin, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 1)) as XOrigin, 1 as XIsInEffect, x.GenProcID
		  Bulk Collect Into v_AfterDirect_tab
		  From WorkdeskHasDriver Join QBMDBQueueCurrent x On uid_workdesk = x.uid_parameter
		  where SlotNumber = v_SlotNumber
		  and bitand(XOrigin, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 1)) > 0;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		  Select x.uid_driver As AssignedElement, x.uid_workdesk As Element, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 0) as XOrigin, 1 as XIsInEffect, x.GenProcID
			Bulk Collect Into v_AfterInDirect_tab
			From (Select xx.uid_parameter as uid_workdesk, d.uid_Driver, xx.GenProcID
					From QBMDBQueueCurrent xx
						
						join table(QBM_GLateBinding.FTCallFTGetObjectKeys('FTGetObjectsOfWorkdesk', xx.uid_parameter)) ehe on 1 = 1

						 Join Driver d
							 On ehe.column_value = d.XObjectKey
							where xx.SlotNumber = v_SlotNumber
				  Union All
				  Select hwo.uid_workdesk, oha.uid_Driver, xx.GenProcID
					From QBMDBQueueCurrent xx
						 Join workdesk w
							 On w.uid_workdesk = xx.uid_parameter
							-- Buglist 10002 ausfiltern
							And w.IsNoInherite = 0
						 Join WorkDeskInBasetree hwo
							 On hwo.uid_workdesk = w.uid_workdesk and hwo.XOrigin > 0
						 Join basetree b
							 On b.uid_org = hwo.uid_org
							And b.IsNoInheriteToWorkdesk = 0
						 Join BaseTreeHasDriver oha
							 On hwo.uid_org = oha.uid_org and oha.XOrigin > 0
							 where xx.SlotNumber = v_SlotNumber
				  Union
				  Select hwo.uid_workdesk, oha.uid_Driver, xx.GenProcID
					From QBMDBQueueCurrent xx
						 Join workdesk w
							 On w.uid_workdesk = xx.uid_parameter
							-- Buglist 10002 ausfiltern
							And w.IsNoInherite = 0
						 Join HelperWorkDeskOrg hwo
							 On hwo.uid_workdesk = w.uid_workdesk
						 Join basetree b
							 On b.uid_org = hwo.uid_org
							And b.IsNoInheriteToWorkdesk = 0
						 Join BaseTreeHasDriver oha
							 On hwo.uid_org = oha.uid_org and oha.XOrigin > 0
						where xx.SlotNumber = v_SlotNumber
				) x
		Group By x.uid_workdesk, x.uid_driver, x.GenProcID;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		-- IR 2005-07-19
		-- Erweitern um die Einträge aus SoftwareDependsOnSoftware
		If v_InheritePhysicalDependencies = 1 Then
			If v_AfterInDirect_tab.COUNT > 0 Then
				-- die indirekten
				v_Helper_tab := v_AfterInDirect_tab;

				For i In v_Helper_tab.FIRST .. v_Helper_tab.LAST Loop
					Select p.uid_parent
					  Bulk Collect Into v_Parent_tab
					  From SoftwareDependsOnSoftware p Join driver a On a.uid_driver = p.uid_parent
					 Where p.uid_child = v_Helper_tab(i).AssignedElement;

					If v_Parent_tab.COUNT > 0 Then
						For k In v_Parent_tab.FIRST .. v_Parent_tab.LAST Loop
							v_exists := 0;

							For j In v_AfterInDirect_tab.FIRST .. v_AfterInDirect_tab.LAST Loop
								If v_AfterInDirect_tab(j).Element = v_Helper_tab(i).Element
							   And v_AfterInDirect_tab(j).AssignedElement = v_Parent_tab(k) Then
									v_exists := 1;
									Exit;
								End If;
							End Loop;

							If v_exists = 0 Then
								v_AfterInDirect_tab.EXTEND(1);
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).Element := v_Helper_tab(i).Element;
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).AssignedElement := v_Parent_tab(k);
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).XOrigin := 2;
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).XIsInEffect := 1;
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).GenProcID := v_Helper_tab(i).GenProcID;
							End If;
						End Loop;
					End If;
				End Loop;
			End If; -- if v_AfterInDirect_tab.count > 0 then

			If v_AfterDirect_tab.COUNT > 0 Then
				-- die direkten
				v_Helper_tab := v_AfterDirect_tab;

				For i In v_Helper_tab.FIRST .. v_Helper_tab.LAST Loop
					Select p.uid_parent
					  Bulk Collect Into v_Parent_tab
					  From SoftwareDependsOnSoftware p Join driver a On a.uid_driver = p.uid_parent
					 Where p.uid_child = v_Helper_tab(i).AssignedElement;

					If v_Parent_tab.COUNT > 0 Then
						For k In v_Parent_tab.FIRST .. v_Parent_tab.LAST Loop
							v_exists := 0;

							If v_AfterInDirect_tab.COUNT > 0 Then
								For j In v_AfterInDirect_tab.FIRST .. v_AfterInDirect_tab.LAST Loop
									If v_AfterInDirect_tab(j).Element = v_Helper_tab(i).Element
								   And v_AfterInDirect_tab(j).AssignedElement = v_Parent_tab(k) Then
										v_exists := 1;
										Exit;
									End If;
								End Loop;
							End If;

							If v_exists = 0 Then
								v_AfterInDirect_tab.EXTEND(1);
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).Element := v_Helper_tab(i).Element;
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).AssignedElement := v_Parent_tab(k);
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).XOrigin := 2;
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).XIsInEffect := 1;
								v_AfterInDirect_tab(v_AfterInDirect_tab.LAST).GenProcID := v_Helper_tab(i).GenProcID;
							End If;
						End Loop;
					End If; -- if v_Parent_tab.Count > 0 then
				End Loop;
			End If; -- if v_AfterDirect_tab.count > 0 then

			Select p.uid_parent As AssignedElement, wha.uid_Workdesk As Element, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 0) as XOrigin, 1 as XIsInEffect, x.GenProcID
			  Bulk Collect Into v_Helper_tab
			  From WorkdeskHasApp wha
				   Join QBMDBQueueCurrent x
					   On wha.uid_workdesk = x.uid_parameter
				   Join SoftwareDependsOnSoftware p
					   On wha.uid_application = p.uid_child
				   -- eigentlich noch join über Application, erledigt sich aber mit wha
				   Join driver a
					   On a.uid_driver = p.uid_parent
					where SlotNumber = v_SlotNumber  and wha.XIsInEffect = 1 and wha.XOrigin > 0;

			QBM_GCalculate.PCollectionUnion(v_AfterInDirect_tab, v_Helper_tab);
		End If;
	-- \ Erweitern um die Einträge aus SoftwareDependsOnSoftware

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	-----------------------------------------------------------------------
	-- Vergleich der  Mengen vorher und nachher
	-- Veränderungen bestimmen
	-----------------------------------------------------------------------

	Begin
		QBM_GCalculate.PCalculateDelta(v_DeltaQuantity		  => 0
							  , v_DeltaDelete		  => 0
							  , v_DeltaInsert		  => 1
							  , v_DeltaOrigin 	  => 1
							  , v_UseIsInEffect => 1
							  , v_BeforeQuantity_tab	  => v_BeforeQuantity_tab
							  , v_AfterDirect_tab	  => v_AfterDirect_tab
							  , v_AfterInDirect_tab   => v_AfterInDirect_tab
							  , -- Ergebnisse
							   v_DeltaDelete_tab	  => v_DeltaDelete_tab
							  , v_DeltaInsert_tab	  => v_DeltaInsert_tab
							  , v_DeltaOrigin_tab   => v_DeltaOrigin_tab
							  , v_DeltaQuantity_tab	  => v_DeltaQuantity_tab
							   );


	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		If v_DeltaOrigin_tab.COUNT > 0 Then
			QBM_GMNTable.PMNTableOriginUpdate('WorkDeskHasDriver', 'UID_WorkDesk', 'UID_Driver', v_DeltaOrigin_tab);
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		If v_DeltaInsert_tab.COUNT > 0 Then
			QBM_GMNTable.PMNTableInsert('WorkDeskHasDriver', 'UID_WorkDesk', 'UID_Driver', v_DeltaInsert_tab
												, v_FKTableNameElement => 'WorkDesk'
												, v_FKColumnNameElement => 'UID_WorkDesk'
										);
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;


end ZWorkDeskHasDriver;
-----------------------------------------------------------------------------------------------
-- / Procedure ZWorkDeskHasDriver
-----------------------------------------------------------------------------------------------







-----------------------------------------------------------------------------------------------
-- Procedure ZADSAccountInADSGroup
-----------------------------------------------------------------------------------------------
Procedure ZADSAccountInADSGroup (v_SlotNumber number)
as

	v_MyName varchar2(64) := 'SDL_GDBQueueTasks.ZADSAccountInADSGroup';

	v_cmd					varchar2(1024);
	v_exists				QBM_GTypeDefinition.YBool;
	v_viconsistent			varchar2(1);
	v_genprocid 			QBM_GTypeDefinition.YGuid;
	v_count 				Number;

	-- zu verarbeitende Daten
	v_BeforeQuantity_tab		QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_AfterDirect_tab		QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_AfterInDirect_tab 	QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	-- Ergebnisse
	v_DeltaDelete_tab		QBM_GTypeDefinition.YBaseForDeltaResult := QBM_GTypeDefinition.YBaseForDeltaResult();
	v_DeltaInsert_tab		QBM_GTypeDefinition.YBaseForDeltaResult := QBM_GTypeDefinition.YBaseForDeltaResult();
	v_DeltaOrigin_tab 	QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_DeltaQuantity_tab		QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	-- für Zwischenergebnisse
	v_Helper_tab			QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_DelHelper_tab 		QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();


	-- für Aufzeichnung
	v_IsSimulationMode		QBM_GTypeDefinition.YBool;


	v_RowsToReset			Number := 0;
	v_UID_Parameter_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_ObjectKey_tab QBM_GTypeDefinition.YObjectKeyTab := QBM_GTypeDefinition.YObjectKeyTab();
	v_ObjectKey QBM_GTypeDefinition.YObjectKey;


Begin
	Begin
		-- Ergänzung Aufzeichnung
		If QBM_GSimulation.Simulation = 1 Then
			v_IsSimulationMode := 1;
		Else
			v_IsSimulationMode := 0;
		End If;
		--/ Ergänzung Aufzeichnung


		-- prüfen, ob das betreffende Objekt noch existiert
		QBM_GDBQueue.PSlotResetOnMissingItem(v_SlotNumber, 'ADSAccount', 'UID_ADSAccount');

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		-------------------------------
		-- zurücksetzen,  projection
		-------------------------------
		if DPR_GGetInfo.FGIProjectionRootRunning('ADSDomain') = 1 then
			select cu.UID_Parameter, ro.ObjectKeyRoot
				bulk collect into v_UID_Parameter_tab, v_ObjectKey_tab
				from QBMDBQueueCurrent cu join ADSAccount x on cu.UID_Parameter = x.UID_ADSAccount
								join DPRVElementAndRoot ro on x.XObjectKey = ro.ObjectKeyElement
				where ro.ElementTable = 'ADSAccount'
				 and cu.SlotNumber = v_SlotNumber;

			DPR_GProjection.PSlotResetWhileProjection(v_SlotNumber, v_UID_Parameter_tab, v_ObjectKey_tab, v_MyName, v_RowsToReset);
		end if;
		-------------------------------
		-- / zurücksetzen,  projection
		-------------------------------


		-------------------------------------------------------------------------
		-- zurücksetzen, falls noch Job unterwegs ist
		-------------------------------------------------------------------------
		select cu.UID_Parameter, x.XObjectKey
			bulk collect into v_UID_Parameter_tab, v_ObjectKey_tab
			from QBMDBQueueCurrent cu join ADSAccount x on cu.UID_Parameter = x.UID_ADSAccount
			where cu.SlotNumber = v_SlotNumber;

		QBM_GDBQueue.PSlotResetWhileJobRunning(v_SlotNumber, v_UID_Parameter_tab, v_ObjectKey_tab, v_MyName, v_RowsToReset);
		-------------------------------------------------------------------------
		-- / zurücksetzen, falls noch Job unterwegs ist
		-------------------------------------------------------------------------
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		Begin
			Select 1
			  Into v_exists
			  From DUAL
			 Where Exists
					   (Select 1
						  From QBMDBQueueCurrent
						 Where Slotnumber = v_Slotnumber);
		Exception
			When NO_DATA_FOUND Then
				v_exists := 0;
		End;

		If v_exists = 0 Then
			Return;
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	-------------------------------------------------------------------------
	-- / zurücksetzen, falls noch Job unterwegs ist
	-------------------------------------------------------------------------



	Begin
		-- alle bisherigen Gruppen des ADSAccounts merken
		Select aig.uid_ADSgroup as AssignedElement, aig.uid_ADSaccount as Element, aig.XOrigin As XOrigin, aig.XIsInEffect as XIsInEffect, x.GenProcID
		  Bulk Collect Into v_BeforeQuantity_tab
		  From ADSAccountInADSGroup aig, QBMDBQueueCurrent x, ADSGroup g
		 Where SlotNumber = v_SlotNumber
		 and aig.uid_adsGroup = g.uid_adsgroup
		   and g.IsApplicationGroup = 1
		   And aig.uid_adsaccount = x.uid_parameter
		   And bitand(aig.XMarkedForDeletion, QBM_GGetInfo2.FGIBitPatternXMarkedForDel('|Delay|', 0)) = 0;


	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		Begin
			v_exists := 0;

			Select 1
			  Into v_exists
			  From DUAL
			 Where QBM_GGetInfo2.FGIConfigParmValue('SOFTWARE\APPLICATION') is not null;
		Exception
			When NO_DATA_FOUND Then
				v_exists := 0;
		End;

		If v_exists = 1 Then
			-- 2. Applikationsgruppen
			-- neu 2001-08-28 : im Container laut Prferenzregel
			-- neu 2002-10-25 : Prferenzregel ber view
			Select y.uid_ADSgroup as AssignedElement, y.uid_ADSaccount as Element, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 0) as XOrigin, y.XIsInEffect as XIsInEffect, y.GenProcID
			  Bulk Collect Into v_AfterIndirect_tab
			  From (  Select x.uid_ADSaccount, x.uid_ADSgroup, TSB_GGetInfo.FGIUserInGroupValid ( p.IsInActive, p.IsTemporaryDeactivated, p.XMarkedForDeletion, bh.PFDInheritGroup, bh.PTDInheritGroup, bh.PMDInheritGroup, 0, p.IsSecurityIncident, bh.PSIInheritGroup, x.AccountDisabled, bh.ADAInheritGroup) as  XIsInEffect, x.GenProcID 
						From (Select nt.uid_ADSaccount
								   , gg.uid_ADSgroup
								   , c.UID_ADSDomain
								   , nt.uid_person
								   , nt.AccountDisabled
								, nt.UID_TSBAccountDef, nt.UID_TSBBehavior
								, xx.GenProcID
								From QBMDBQueueCurrent xx
									 Join ADSaccount nt
										 On nt.uid_ADSAccount = xx.uid_parameter
										-- entfällt wegen 25448
										-- And bitand(nt.XMarkedForDeletion, QBM_GGetInfo2.FGIBitPatternXMarkedForDel('|Delay|', 0)) = 0
										And nt.isappaccount = 1
									 Join ADSContainer c
										 On nt.uid_ADSContainer = c.uid_ADSContainer
									 Join personhasapp pha
										 On nt.uid_person = pha.uid_person and pha.XIsInEffect = 1 and pha.XOrigin > 0 
									 Join application a
										 On pha.uid_application = a.uid_application
									 Join ADSgroup gg
										 On a.ident_sectionName = gg.cn
										And gg.isapplicationgroup = 1
									 Join SDL_VADSNearestAppContainer co
										 On gg.uid_ADSContainer = co.uid_Appcontainer
										And co.uid_AccountContainer = nt.uid_adscontainer
							   -- Ergänzung wegen 10313
							   Where xx.SlotNumber = v_SlotNumber
							   and TSB_GGetInfo.FGIGroupAccountMatching(gg.MatchPatternForMembership, nt.MatchPatternForMembership) = 1
							   ) x
							 Join ADSdomain d
								 On x.UID_ADSDomain = d.UID_ADSDomain
							 Left Outer Join person p
								 On x.uid_person = p.uid_person
							 -- 12566
				left outer join TSBBehavior bh on x.UID_TSBBehavior = bh.UID_TSBBehavior
					   -- / 12566
						) y;

		End If; --if exists (select 1 from #DialogConfigparm were fullpath = 'Software\Application')

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;


	Begin
		-------------------------------
		-- zurücksetzen,  projection
		-- hier: wenn die Domäne der Gruppe im Projektor-Lauf ist
		-------------------------------
		if DPR_GGetInfo.FGIProjectionRootRunning('ADSDomain') = 1 then
			v_DelHelper_tab := QBM_GTypeDefinition.YBaseForDelta();
			v_Helper_tab := v_BeforeQuantity_tab;
			QBM_GCalculate.PCollectionUnion(v_Helper_tab, v_AfterDirect_tab);
			QBM_GCalculate.PCollectionUnion(v_Helper_tab, v_AfterInDirect_tab);

			select ro.XObjectKey, h.Element bulk collect into v_ObjectKey_tab, v_UID_Parameter_tab
				from AdsGroup g join ADSDomain ro on g.UID_ADSDomain = ro.UID_ADSDomain
					join table (v_Helper_tab) h on h.AssignedElement = g.uid_adsGroup;
					
			DPR_GProjection.PSlotResetWhileProjection(v_SlotNumber, v_UID_Parameter_tab, v_ObjectKey_tab, v_MyName, v_RowsToReset);

			if v_RowsToReset > 0 then

				select h.AssignedElement, h.Element, 0, 0, null
					bulk collect into v_DelHelper_tab
					from table(v_Helper_tab) h
					where exists (select 1 from QBMDBQueueCurrent c
									where c.UID_Parameter = h.Element
									and c.UID_Task = 'ADS-K-ADSAccountInADSGroup'
									and c.slotnumber = QBM_GDBQueue.FGIDBQueueSlotResetType('Sync')
								);


				QBM_GCalculate.PCollectionMinusElement(v_BeforeQuantity_tab, v_DelHelper_tab);
				QBM_GCalculate.PCollectionMinusElement(v_AfterDirect_tab, v_DelHelper_tab);
				QBM_GCalculate.PCollectionMinusElement(v_AfterInDirect_tab, v_DelHelper_tab);

			end if; -- if v_RowsToReset > 0 then
		end if; -- if v_exists = 1 then
		-------------------------------
		-- / zurücksetzen,  projection
		-------------------------------
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	-----------------------------------------------------------------------
	-- Vergleich der  Mengen vorher und nachher
	-- Veränderungen bestimmen
	-----------------------------------------------------------------------

	Begin
		QBM_GCalculate.PCalculateDelta(v_DeltaQuantity		  => 0
							  , v_DeltaDelete		  => 0
							  , v_DeltaInsert		  => 1
							  , v_DeltaOrigin 	  => 1
							  , v_UseIsInEffect => 1
							  , v_BeforeQuantity_tab	  => v_BeforeQuantity_tab
							  , v_AfterDirect_tab	  => v_AfterDirect_tab
							  , v_AfterInDirect_tab   => v_AfterInDirect_tab
							  , -- Ergebnisse
							   v_DeltaDelete_tab	  => v_DeltaDelete_tab
							  , v_DeltaInsert_tab	  => v_DeltaInsert_tab
							  , v_DeltaOrigin_tab   => v_DeltaOrigin_tab
							  , v_DeltaQuantity_tab	  => v_DeltaQuantity_tab
							   );


	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;


	Begin
		If v_DeltaOrigin_tab.COUNT > 0 Then
			QBM_GMNTable.PMNTableOriginUpdate('ADSAccountInADSGroup', 'UID_ADSAccount', 'UID_ADSGroup', v_DeltaOrigin_tab);
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		If v_DeltaInsert_tab.COUNT > 0 Then
			QBM_GMNTable.PMNTableInsert('ADSAccountInADSGroup', 'UID_ADSAccount', 'UID_ADSGroup', v_DeltaInsert_tab
												, v_FKTableNameElement => 'ADSAccount'
												, v_FKColumnNameElement => 'UID_ADSAccount'
										);
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



end ZADSAccountInADSGroup;
-----------------------------------------------------------------------------------------------
-- / Procedure ZADSAccountInADSGroup
-----------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------
-- Procedure ZLDAPAccountInLDAPGroup
-----------------------------------------------------------------------------------------------
Procedure ZLDAPAccountInLDAPGroup (v_SlotNumber number)
as
	v_MyName varchar2(64) := 'SDL_GDBQueueTasks.ZLDAPAccountInLDAPGroup';

	v_exists				QBM_GTypeDefinition.YBool;
	v_genprocid 			QBM_GTypeDefinition.YGuid;



	-- für Aufzeichnung
	v_IsSimulationMode		QBM_GTypeDefinition.YBool;


	v_RowsToReset			Number := 0;
	v_UID_Parameter_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_ObjectKey_tab QBM_GTypeDefinition.YObjectKeyTab := QBM_GTypeDefinition.YObjectKeyTab();
	v_ObjectKey QBM_GTypeDefinition.YObjectKey;

	v_count 				Number;

	-- zu verarbeitende Daten
	v_BeforeQuantity_tab		QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_AfterDirect_tab		QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_AfterInDirect_tab 	QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	-- Ergebnisse
	v_DeltaDelete_tab		QBM_GTypeDefinition.YBaseForDeltaResult := QBM_GTypeDefinition.YBaseForDeltaResult();
	v_DeltaInsert_tab		QBM_GTypeDefinition.YBaseForDeltaResult := QBM_GTypeDefinition.YBaseForDeltaResult();
	v_DeltaOrigin_tab 	QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_DeltaQuantity_tab		QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	-- für Zwischenergebnisse
	v_Helper_tab			QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_DelHelper_tab 		QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

Begin
	Begin
		-- Ergänzung Aufzeichnung
		If QBM_GSimulation.Simulation = 1 Then
			v_IsSimulationMode := 1;
		Else
			v_IsSimulationMode := 0;
		End If;
		--/ Ergänzung Aufzeichnung

		-- prüfen, ob das betreffende Objekt noch existiert
		QBM_GDBQueue.PSlotResetOnMissingItem(v_SlotNumber, 'LDAPaccount', 'UID_LDAPaccount');

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		-------------------------------
		-- zurücksetzen,  projection
		-------------------------------
		if DPR_GGetInfo.FGIProjectionRootRunning('LDPDomain') = 1 then
			select cu.UID_Parameter, ro.ObjectKeyRoot
				bulk collect into v_UID_Parameter_tab, v_ObjectKey_tab
				from QBMDBQueueCurrent cu join LDAPAccount a on a.UID_LDAPAccount = cu.UID_Parameter
								join DPRVElementAndRoot ro on a.XObjectKey = ro.ObjectKeyElement
				where ro.ElementTable = 'LDAPAccount'
				 and cu.SlotNumber = v_SlotNumber;

			DPR_GProjection.PSlotResetWhileProjection(v_SlotNumber, v_UID_Parameter_tab, v_ObjectKey_tab, v_MyName, v_RowsToReset);
		end if;
		-------------------------------
		-- / zurücksetzen,  projection
		-------------------------------


		-------------------------------------------------------------------------
		-- zurücksetzen, falls noch Job unterwegs ist
		-------------------------------------------------------------------------
		select cu.UID_Parameter, x.XObjectKey
			bulk collect into v_UID_Parameter_tab, v_ObjectKey_tab
			from QBMDBQueueCurrent cu join LDAPAccount x on cu.UID_Parameter = x.UID_LDAPAccount
			where cu.SlotNumber = v_SlotNumber;

		QBM_GDBQueue.PSlotResetWhileJobRunning(v_SlotNumber, v_UID_Parameter_tab, v_ObjectKey_tab, v_MyName, v_RowsToReset);
		-------------------------------------------------------------------------
		-- / zurücksetzen, falls noch Job unterwegs ist
		-------------------------------------------------------------------------

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		Select 1
		  Into v_exists
		  From DUAL
		 Where Exists
				   (Select 1
					  From QBMDBQueueCurrent
					 Where SlotNumber = v_SlotNumber);
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
	End;

	If v_exists = 0 Then
		Return;
	End If;

	Begin
		-- alle bisherigen Gruppen des LDAPAccounts merken
		Select aig.UID_LDAPGroup as AssignedElement, aig.uid_LDAPaccount as Element, aig.XOrigin As XOrigin, aig.XIsInEffect as XIsInEffect, x.GenProcID
		  Bulk Collect Into v_BeforeQuantity_tab
		  From LDAPAccountInLDAPGroup aig
			   Join QBMDBQueueCurrent x
				   On aig.uid_LDAPaccount = x.uid_parameter
			   Join LDAPGroup g
				   On aig.uid_LDAPGroup = g.uid_LDAPgroup
				  and g.IsApplicationGroup = 1
		 Where SlotNumber = v_SlotNumber
		 and bitand(aig.XMarkedForDeletion, QBM_GGetInfo2.FGIBitPatternXMarkedForDel('|Delay|', 0)) = 0;


	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		  -- 2. Applikationsgruppen
		  -- neu 2001-08-28 : im Container laut Prferenzregel
		  -- neu 2002-10-25 : Prferenzregel ber view
		  Select Distinct x.UID_LDAPGroup as AssignedElement, x.uid_LDAPaccount as Element, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 0) as XOrigin
			, TSB_GGetInfo.FGIUserInGroupValid ( p.IsInActive, p.IsTemporaryDeactivated, p.XMarkedForDeletion, bh.PFDInheritGroup, bh.PTDInheritGroup, bh.PMDInheritGroup, 0, p.IsSecurityIncident, bh.PSIInheritGroup, x.AccountDisabled, bh.ADAInheritGroup) 
				as XIsInEffect, x.GenProcID
			Bulk Collect Into v_AfterIndirect_tab
			From (Select nt.uid_LDAPaccount
					   , gg.uid_LDAPgroup
					   , nt.UID_LDPDomain
					   , nt.uid_person
					   , nt.AccountDisabled
						 , nt.UID_TSBAccountDef, nt.UID_TSBBehavior
						 , xx.GenProcID
					From LDAPaccount nt
					   , QBMDBQueueCurrent xx
					   , personhasapp pha
					   , application a
					   , LDAPgroup gg
					   , SDL_VLDPNearestAppContainer co
				   Where xx.SlotNumber = v_SlotNumber
				   and nt.uid_LDAPAccount = xx.uid_parameter
				   and pha.XIsInEffect = 1 and pha.XOrigin > 0
					 -- entfällt wegen 25448
					 -- And bitand(nt.XMarkedForDeletion, QBM_GGetInfo2.FGIBitPatternXMarkedForDel('|Delay|', 0)) = 0
					 And nt.uid_person = pha.uid_person
					 And nt.isappaccount = 1
					 And pha.uid_application = a.uid_application
					 And a.ident_sectionName = gg.cn
					 And gg.isapplicationgroup = 1
					 And gg.uid_LDAPContainer = co.uid_Appcontainer
					 And co.uid_AccountContainer = nt.uid_LDAPcontainer
					) x
				 Join ldpdomain d
					 On x.UID_LDPDomain = d.UID_LDPDomain
				 Left Outer Join person p
					 On x.uid_person = p.uid_person
				 -- 12566
				left outer join TSBBehavior bh on x.UID_TSBBehavior = bh.UID_TSBBehavior;
		   -- / 12566


	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		-------------------------------
		-- zurücksetzen,  projection
		-- hier: wenn die Domäne der Gruppe im Projektor-Lauf ist
		-------------------------------
		if DPR_GGetInfo.FGIProjectionRootRunning('LDPDomain') = 1 then
			v_DelHelper_tab := QBM_GTypeDefinition.YBaseForDelta();
			v_Helper_tab := v_BeforeQuantity_tab;
			QBM_GCalculate.PCollectionUnion(v_Helper_tab, v_AfterDirect_tab);
			QBM_GCalculate.PCollectionUnion(v_Helper_tab, v_AfterInDirect_tab);

			select ro.XObjectKey, h.Element bulk collect into v_ObjectKey_tab, v_UID_Parameter_tab
				from LDAPGroup g join LDPDomain ro on g.UID_LDPDomain = ro.UID_LDPDomain
					join table (v_Helper_tab) h on h.AssignedElement = g.uid_LDAPGroup;

					
			DPR_GProjection.PSlotResetWhileProjection(v_SlotNumber, v_UID_Parameter_tab, v_ObjectKey_tab, v_MyName, v_RowsToReset);

			if v_RowsToReset > 0 then

				select h.AssignedElement, h.Element, 0, 0, null
					bulk collect into v_DelHelper_tab
					from table(v_Helper_tab) h
					where exists (select 1 from QBMDBQueueCurrent c
									where c.UID_Parameter = h.Element
									and c.UID_Task = 'SDL-K-LDAPACCOUNTINLDAPGROUP'
									and c.slotnumber = QBM_GDBQueue.FGIDBQueueSlotResetType('Sync')
								);


				QBM_GCalculate.PCollectionMinusElement(v_BeforeQuantity_tab, v_DelHelper_tab);
				QBM_GCalculate.PCollectionMinusElement(v_AfterDirect_tab, v_DelHelper_tab);
				QBM_GCalculate.PCollectionMinusElement(v_AfterInDirect_tab, v_DelHelper_tab);

			end if; -- if v_RowsToReset > 0 then
		end if; -- if v_exists = 1 then
		-------------------------------
		-- / zurücksetzen,  projection
		-------------------------------
	
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	-----------------------------------------------------------------------
	-- Vergleich der  Mengen vorher und nachher
	-- Veränderungen bestimmen
	-----------------------------------------------------------------------

	Begin
		QBM_GCalculate.PCalculateDelta(v_DeltaQuantity		  => 0
							  , v_DeltaDelete		  => 0
							  , v_DeltaInsert		  => 1
							  , v_DeltaOrigin 	  => 1
							  , v_UseIsInEffect => 1
							  , v_BeforeQuantity_tab	  => v_BeforeQuantity_tab
							  , v_AfterDirect_tab	  => v_AfterDirect_tab
							  , v_AfterInDirect_tab   => v_AfterInDirect_tab
							  , -- Ergebnisse
							   v_DeltaDelete_tab	  => v_DeltaDelete_tab
							  , v_DeltaInsert_tab	  => v_DeltaInsert_tab
							  , v_DeltaOrigin_tab   => v_DeltaOrigin_tab
							  , v_DeltaQuantity_tab	  => v_DeltaQuantity_tab
							   );


	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;


	Begin
		If v_DeltaOrigin_tab.COUNT > 0 Then
			QBM_GMNTable.PMNTableOriginUpdate('LDAPAccountInLDAPGroup', 'UID_LDAPAccount', 'UID_LDAPGroup', v_DeltaOrigin_tab);
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		If v_DeltaInsert_tab.COUNT > 0 Then
			QBM_GMNTable.PMNTableInsert('LDAPAccountInLDAPGroup', 'UID_LDAPAccount', 'UID_LDAPGroup', v_DeltaInsert_tab
												, v_FKTableNameElement => 'LDAPAccount'
												, v_FKColumnNameElement => 'UID_LDAPAccount'
										);
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;
	

end ZLDAPAccountInLDAPGroup;
-----------------------------------------------------------------------------------------------
-- / Procedure ZLDAPAccountInLDAPGroup
-----------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------
-- Procedure ZLDPMachineInLDAPGroup
-----------------------------------------------------------------------------------------------
Procedure ZLDPMachineInLDAPGroup (v_SlotNumber number)
as
	v_MyName varchar2(64) := 'SDL_GDBQueueTasks.ZLDPMachineInLDAPGroup';

	v_exists				QBM_GTypeDefinition.YBool;
	v_genprocid 			QBM_GTypeDefinition.YGuid;



	-- für Aufzeichnung
	v_IsSimulationMode		QBM_GTypeDefinition.YBool;


	v_RowsToReset			Number := 0;
	v_UID_Parameter_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_ObjectKey_tab QBM_GTypeDefinition.YObjectKeyTab := QBM_GTypeDefinition.YObjectKeyTab();
	v_ObjectKey QBM_GTypeDefinition.YObjectKey;

	v_count 				Number;

	-- zu verarbeitende Daten
	v_BeforeQuantity_tab		QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_AfterDirect_tab		QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_AfterInDirect_tab 	QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	-- Ergebnisse
	v_DeltaDelete_tab		QBM_GTypeDefinition.YBaseForDeltaResult := QBM_GTypeDefinition.YBaseForDeltaResult();
	v_DeltaInsert_tab		QBM_GTypeDefinition.YBaseForDeltaResult := QBM_GTypeDefinition.YBaseForDeltaResult();
	v_DeltaOrigin_tab 	QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_DeltaQuantity_tab		QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	-- für Zwischenergebnisse
	v_Helper_tab			QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_DelHelper_tab 		QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

Begin
	Begin
		-- Ergänzung Aufzeichnung
		If QBM_GSimulation.Simulation = 1 Then
			v_IsSimulationMode := 1;
		Else
			v_IsSimulationMode := 0;
		End If;
		--/ Ergänzung Aufzeichnung


		-- prüfen, ob das betreffende Objekt noch existiert
		QBM_GDBQueue.PSlotResetOnMissingItem(v_SlotNumber, 'LDPMachine', 'UID_LDPMachine');

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		-------------------------------
		-- zurücksetzen,  projection
		-------------------------------
		if DPR_GGetInfo.FGIProjectionRootRunning('LDPDomain') = 1 then
			select cu.UID_Parameter, ro.ObjectKeyRoot
				bulk collect into v_UID_Parameter_tab, v_ObjectKey_tab
				from QBMDBQueueCurrent cu join LDPMachine a on a.UID_LDPMachine = cu.UID_Parameter
								join DPRVElementAndRoot ro on a.XObjectKey = ro.ObjectKeyElement
				where ro.ElementTable = 'LDPMachine'
				 and cu.SlotNumber = v_SlotNumber;

			DPR_GProjection.PSlotResetWhileProjection(v_SlotNumber, v_UID_Parameter_tab, v_ObjectKey_tab, v_MyName, v_RowsToReset);
		end if;
		-------------------------------
		-- / zurücksetzen,  projection
		-------------------------------


		-------------------------------------------------------------------------
		-- zurücksetzen, falls noch Job unterwegs ist
		-------------------------------------------------------------------------
		select cu.UID_Parameter, x.XObjectKey
			bulk collect into v_UID_Parameter_tab, v_ObjectKey_tab
			from QBMDBQueueCurrent cu join LDPMachine x on cu.UID_Parameter = x.UID_LDPMachine
			where cu.SlotNumber = v_SlotNumber;

		QBM_GDBQueue.PSlotResetWhileJobRunning(v_SlotNumber, v_UID_Parameter_tab, v_ObjectKey_tab, v_MyName, v_RowsToReset);
		-------------------------------------------------------------------------
		-- / zurücksetzen, falls noch Job unterwegs ist
		-------------------------------------------------------------------------

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		Select 1
		  Into v_exists
		  From DUAL
		 Where Exists
				   (Select 1
					  From QBMDBQueueCurrent
					 Where SlotNumber = v_SlotNumber);
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
	End;

	If v_exists = 0 Then
		Return;
	End If;

	Begin
		-- alle bisherigen Gruppen des LDPMachines merken
		Select aig.UID_LDAPGroup as AssignedElement, aig.UID_LDPMachine as Element, aig.XOrigin As XOrigin, aig.XIsInEffect as XIsInEffect, x.GenProcID
		  Bulk Collect Into v_BeforeQuantity_tab
		  From LDPMachineInLDAPGroup aig, QBMDBQueueCurrent x, LDAPGroup g
		 Where SlotNumber = v_SlotNumber
		 and aig.UID_LDPMachine = x.uid_parameter
		   And aig.uid_ldapgroup = g.uid_ldapgroup
		   and g.IsApplicationGroup = 1
		   And bitand(aig.XMarkedForDeletion, QBM_GGetInfo2.FGIBitPatternXMarkedForDel('|Delay|', 0)) = 0;


	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		-- erst kontrollieren, dann joinen
		Begin
			v_exists := 0;

			Select 1
			  Into v_exists
			  From DUAL
			 Where QBM_GGetInfo2.FGIConfigParmValue('TARGETSYSTEM\LDAP\HARDWAREINAPPGROUP') is not null;
		Exception
			When NO_DATA_FOUND Then
				v_exists := 0;
		End;

		If v_exists = 1 Then
			-- 2. Applikationsgruppen ber workdeskHasApp
			Select Distinct gg.UID_LDAPGroup as AssignedElement, nt.UID_LDPMachine as Element, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 0) as XOrigin, 1 as XIsInEffect, xx.GenProcID
			  Bulk Collect Into v_AfterIndirect_tab
			  From LDPMachine nt
				   Join QBMDBQueueCurrent xx
					   On nt.uid_LDPMachine = xx.uid_parameter
					  -- Buglist 10002 ausfiltern
					  -- entfällt, da nicht über Bastree geerbt wird
					  -- entfällt nicht wegen 25448 da keine TSBAccountDef
					  And bitand(nt.XMarkedForDeletion, QBM_GGetInfo2.FGIBitPatternXMarkedForDel('|Delay|', 0)) = 0
					join hardware h on nt.uid_hardware = h.uid_hardware					  
				   Join WorkdeskHasApp wha
					   On h.UID_Workdesk = wha.UID_Workdesk and wha.XIsInEffect = 1 and wha.XOrigin > 0
				   Join Application a
					   On wha.UID_Application = a.UID_Application
				   Join LDAPGroup gg
					   On a.Ident_SectionName = gg.cn
					  And gg.isApplicationgroup = 1
				   Join SDL_VLDPNearestAppContainer co
					   On gg.UID_LDAPContainer = co.UID_Appcontainer
					  And co.UID_AccountContainer = nt.UID_LDAPcontainer
				where xx.SlotNumber = v_SlotNumber;


		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		-------------------------------
		-- zurücksetzen,  projection
		-- hier: wenn die Domäne der Gruppe im Projektor-Lauf ist
		-------------------------------
		if DPR_GGetInfo.FGIProjectionRootRunning('LDPDomain') = 1 then
			v_DelHelper_tab := QBM_GTypeDefinition.YBaseForDelta();
			v_Helper_tab := v_BeforeQuantity_tab;
			QBM_GCalculate.PCollectionUnion(v_Helper_tab, v_AfterDirect_tab);
			QBM_GCalculate.PCollectionUnion(v_Helper_tab, v_AfterInDirect_tab);

			select ro.XObjectKey, h.Element bulk collect into v_ObjectKey_tab, v_UID_Parameter_tab
				from LDAPGroup g join LDPDomain ro on g.UID_LDPDomain = ro.UID_LDPDomain
					join table (v_Helper_tab) h on h.AssignedElement = g.uid_LDAPGroup;
					
			DPR_GProjection.PSlotResetWhileProjection(v_SlotNumber, v_UID_Parameter_tab, v_ObjectKey_tab, v_MyName, v_RowsToReset);

			if v_RowsToReset > 0 then

				select h.AssignedElement, h.Element, 0, 0, null
					bulk collect into v_DelHelper_tab
					from table(v_Helper_tab) h
					where exists (select 1 from QBMDBQueueCurrent c
									where c.UID_Parameter = h.Element
									and c.UID_Task = 'LDP-K-LDPMachineInLDAPGroup'
									and c.slotnumber = QBM_GDBQueue.FGIDBQueueSlotResetType('Sync')
								);


				QBM_GCalculate.PCollectionMinusElement(v_BeforeQuantity_tab, v_DelHelper_tab);
				QBM_GCalculate.PCollectionMinusElement(v_AfterDirect_tab, v_DelHelper_tab);
				QBM_GCalculate.PCollectionMinusElement(v_AfterInDirect_tab, v_DelHelper_tab);

			end if; -- if v_RowsToReset > 0 then
		end if; -- if v_exists = 1 then
		-------------------------------
		-- / zurücksetzen,  projection
		-------------------------------

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	-----------------------------------------------------------------------
	-- Vergleich der  Mengen vorher und nachher
	-- Veränderungen bestimmen
	-----------------------------------------------------------------------

	Begin
		QBM_GCalculate.PCalculateDelta(v_DeltaQuantity		  => 0
							  , v_DeltaDelete		  => 0
							  , v_DeltaInsert		  => 1
							  , v_DeltaOrigin 	  => 1
							  , v_UseIsInEffect => 1
							  , v_BeforeQuantity_tab	  => v_BeforeQuantity_tab
							  , v_AfterDirect_tab	  => v_AfterDirect_tab
							  , v_AfterInDirect_tab   => v_AfterInDirect_tab
							  , -- Ergebnisse
							   v_DeltaDelete_tab	  => v_DeltaDelete_tab
							  , v_DeltaInsert_tab	  => v_DeltaInsert_tab
							  , v_DeltaOrigin_tab   => v_DeltaOrigin_tab
							  , v_DeltaQuantity_tab	  => v_DeltaQuantity_tab
							   );


	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;


	Begin
		If v_DeltaOrigin_tab.COUNT > 0 Then
			QBM_GMNTable.PMNTableOriginUpdate('LDPMachineInLDAPGroup', 'UID_LDPMachine', 'UID_LDAPGroup', v_DeltaOrigin_tab);
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		If v_DeltaInsert_tab.COUNT > 0 Then
			QBM_GMNTable.PMNTableInsert('LDPMachineInLDAPGroup', 'UID_LDPMachine', 'UID_LDAPGroup', v_DeltaInsert_tab
												, v_FKTableNameElement => 'LDPMachine'
												, v_FKColumnNameElement => 'UID_LDPMachine'
										);
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

end ZLDPMachineInLDAPGroup;
-----------------------------------------------------------------------------------------------
-- / Procedure ZLDPMachineInLDAPGroup
-----------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------
-- Procedure ZADSMachineInADSGroup
-----------------------------------------------------------------------------------------------
Procedure ZADSMachineInADSGroup (v_SlotNumber number)
as
	v_MyName varchar2(64) := 'SDL_GDBQueueTasks.ZADSMachineInADSGroup';


	v_exists				QBM_GTypeDefinition.YBool;
	v_genprocid 			QBM_GTypeDefinition.YGuid;
	v_count 				Number;


	-- zu verarbeitende Daten
	v_BeforeQuantity_tab		QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_AfterDirect_tab		QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_AfterInDirect_tab 	QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	-- Ergebnisse
	v_DeltaDelete_tab		QBM_GTypeDefinition.YBaseForDeltaResult := QBM_GTypeDefinition.YBaseForDeltaResult();
	v_DeltaInsert_tab		QBM_GTypeDefinition.YBaseForDeltaResult := QBM_GTypeDefinition.YBaseForDeltaResult();
	v_DeltaOrigin_tab 	QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_DeltaQuantity_tab		QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	-- für Zwischenergebnisse
	v_Helper_tab			QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_DelHelper_tab 		QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();


	-- für Aufzeichnung
	v_IsSimulationMode		QBM_GTypeDefinition.YBool;


	v_RowsToReset			Number := 0;
	v_UID_Parameter_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_ObjectKey_tab QBM_GTypeDefinition.YObjectKeyTab := QBM_GTypeDefinition.YObjectKeyTab();

Begin
	Begin
		-- Ergänzung Aufzeichnung
		If QBM_GSimulation.Simulation = 1 Then
			v_IsSimulationMode := 1;
		Else
			v_IsSimulationMode := 0;
		End If;
		--/ Ergänzung Aufzeichnung

		-- prüfen, ob das betreffende Objekt noch existiert
		QBM_GDBQueue.PSlotResetOnMissingItem(v_SlotNumber, 'ADSMachine', 'UID_ADSMachine');

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		-------------------------------
		-- zurücksetzen,  projection
		-------------------------------
		if DPR_GGetInfo.FGIProjectionRootRunning('ADSDomain') = 1 then
			select cu.UID_Parameter, ro.ObjectKeyRoot
				bulk collect into v_UID_Parameter_tab, v_ObjectKey_tab
				from QBMDBQueueCurrent cu join ADSMachine a on a.UID_ADSMachine = cu.UID_Parameter
								join DPRVElementAndRoot ro on a.XObjectKey = ro.ObjectKeyElement
				where ro.ElementTable = 'ADSMachine'
				 and cu.SlotNumber = v_SlotNumber;

			DPR_GProjection.PSlotResetWhileProjection(v_SlotNumber, v_UID_Parameter_tab, v_ObjectKey_tab, v_MyName, v_RowsToReset);
		end if;
		-------------------------------
		-- / zurücksetzen,  projection
		-------------------------------

		-------------------------------------------------------------------------
		-- zurücksetzen, falls noch Job unterwegs ist
		-------------------------------------------------------------------------
		select cu.UID_Parameter, x.XObjectKey
			bulk collect into v_UID_Parameter_tab, v_ObjectKey_tab
			from QBMDBQueueCurrent cu join ADSMachine x on cu.UID_Parameter = x.UID_ADSMachine
			where cu.SlotNumber = v_SlotNumber;

		QBM_GDBQueue.PSlotResetWhileJobRunning(v_SlotNumber, v_UID_Parameter_tab, v_ObjectKey_tab, v_MyName, v_RowsToReset);
		-------------------------------------------------------------------------
		-- / zurücksetzen, falls noch Job unterwegs ist
		-------------------------------------------------------------------------

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		Select 1
		  Into v_exists
		  From DUAL
		 Where Exists
				   (Select 1
					  From QBMDBQueueCurrent
					 Where SlotNumber = v_SlotNumber);
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
	End;

	If v_exists = 0 Then
		Return;
	End If;





	Begin
		-- alle bisherigen Gruppen der ADSMachine merken
		Select hia.uid_ADSgroup as AssignedElement, hia.UID_ADSMachine as Element, hia.XOrigin As XOrigin, hia.XIsInEffect as XIsInEffect, x.GenProcID
		  Bulk Collect Into v_BeforeQuantity_tab
		  From ADSMachineInADSGroup hia, QBMDBQueueCurrent x, ADSGroup g
		 Where SlotNumber = v_SlotNumber
		 and hia.UID_ADSMachine = x.uid_parameter
		   And hia.uid_adsGroup = g.uid_adsgroup
		   and g.IsApplicationGroup = 1
		   And bitand(hia.XMarkedForDeletion, QBM_GGetInfo2.FGIBitPatternXMarkedForDel('|Delay|', 0)) = 0;


	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;


	Begin
		-- erst kontrollieren, dann joinen
		Begin
			v_exists := 0;

			Select 1
			  Into v_exists
			  From DUAL
			 Where QBM_GGetInfo2.FGIConfigParmValue('TARGETSYSTEM\ADS\HARDWAREINAPPGROUP') is not null;
		Exception
			When NO_DATA_FOUND Then
				v_exists := 0;
		End;

		If v_exists = 1 Then
			-- 2. Applikationsgruppen ber workdeskHasApp
			Select Distinct gg.UID_ADSGroup as AssignedElement, nt.UID_ADSMachine as Element, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 0) as XOrigin, 1 as XIsInEffect, xx.GenProcID
			  Bulk Collect Into v_AfterIndirect_tab
			  From ADSMachine nt
				   Join QBMDBQueueCurrent xx
					   On nt.uid_ADSMachine = xx.uid_parameter
					  -- Buglist 10002 ausfiltern
					  -- entfällt, da nicht über Bastree geerbt wird
					  -- entfällt nicht wegen 25448, da keine TSBAccountDef
					  And bitand(nt.XMarkedForDeletion, QBM_GGetInfo2.FGIBitPatternXMarkedForDel('|Delay|', 0)) = 0
					join hardware h on nt.uid_hardware = h.uid_hardware					  
				   Join WorkdeskHasApp wha
					   On h.UID_Workdesk = wha.UID_Workdesk and wha.XIsInEffect = 1 and wha.XOrigin > 0
				   Join Application a
					   On wha.UID_Application = a.UID_Application
				   Join ADSGroup gg
					   On a.Ident_SectionName = gg.cn
					  And gg.isApplicationgroup = 1
				   Join SDL_VADSNearestAppContainer co
					   On gg.UID_ADSContainer = co.UID_Appcontainer
					  And co.UID_AccountContainer = nt.UID_ADScontainer
				where xx.SlotNumber = v_SlotNumber;


		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;





	-----------------------------------------------------------------------
	-- Vergleich der  Mengen vorher und nachher
	-- Veränderungen bestimmen
	-----------------------------------------------------------------------

	Begin
		QBM_GCalculate.PCalculateDelta(v_DeltaQuantity		  => 0
							  , v_DeltaDelete		  => 0
							  , v_DeltaInsert		  => 1
							  , v_DeltaOrigin 	  => 1
							  , v_UseIsInEffect => 1
							  , v_BeforeQuantity_tab	  => v_BeforeQuantity_tab
							  , v_AfterDirect_tab	  => v_AfterDirect_tab
							  , v_AfterInDirect_tab   => v_AfterInDirect_tab
							  , -- Ergebnisse
							   v_DeltaDelete_tab	  => v_DeltaDelete_tab
							  , v_DeltaInsert_tab	  => v_DeltaInsert_tab
							  , v_DeltaOrigin_tab   => v_DeltaOrigin_tab
							  , v_DeltaQuantity_tab	  => v_DeltaQuantity_tab
							   );


	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;


	Begin
		If v_DeltaOrigin_tab.COUNT > 0 Then
			QBM_GMNTable.PMNTableOriginUpdate('ADSMachineInADSGroup', 'UID_ADSMachine', 'UID_ADSgroup', v_DeltaOrigin_tab);
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		If v_DeltaInsert_tab.COUNT > 0 Then
			QBM_GMNTable.PMNTableInsert('ADSMachineInADSGroup', 'UID_ADSMachine', 'UID_ADSgroup', v_DeltaInsert_tab
												, v_FKTableNameElement => 'ADSMachine'
												, v_FKColumnNameElement => 'UID_ADSMachine'
										);
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;


end ZADSMachineInADSGroup;
-----------------------------------------------------------------------------------------------
-- / Procedure ZADSMachineInADSGroup
-----------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- / SoftwareDistribution
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- Licence
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------
-- Procedure ZLicenceCompanyTarget
-----------------------------------------------------------------------------------------------
Procedure ZLicenceCompanyTarget (v_SlotNumber number
									, v_dummy1 varchar2
									, v_dummy2 varchar2
									, v_GenProcIDDummy varchar2
									)
as



	v_Count_tab QBM_GTypeDefinition.YNumberTab := QBM_GTypeDefinition.YNumberTab();
	v_uid_licence_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_Limit number := 500;

	v_GenProcID QBM_GTypeDefinition.YGuid := newid();

	v_InheritePhysicalDependencies Number := 0;
	v_exists					   QBM_GTypeDefinition.YBool;
	v_Zaehlweise				   Number;

	Cursor LicenceCompanyTarget1 Is
		Select Licence.uid_licence, zz.CountItems
		  From	   Licence
			   Join
				   (Select l.uid_licence, NVL(x.CountItems, 0) As CountItems
					  From	   licence l
						   Left Outer Join -- left outer, damit auch wirklich alle Lizenzen geliefert werden
							   (  Select uid_licence, COUNT(*) As CountItems
									From ( -- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
										  Select  h.uid_hardware, ahl.uid_licence
											 From workdeskhasapp wha
												  Join hardware h
													  On h.uid_workdesk = wha.uid_workdesk
													 And (h.ispc = 1
													   Or  h.isServer = 1)
													and wha.XIsInEffect = 1 and wha.XOrigin > 0
												  Join ( -- physische Vorgänger mitnehmen
														Select	UID_Child, UID_Parent
														   From softwaredependsonsoftware
														  Where v_InheritePhysicalDependencies = 0
														Union
														Select uid_application, uid_application From application) su
													  On su.uid_child = wha.uid_application
												  Join apphaslicence ahl
													  On su.uid_parent = ahl.uid_application
										  Union
										  --  2) Treiber an Arbeitsplätze zugewiesen
										  Select h.uid_hardware, dhl.uid_licence
											From workdeskhasdriver whd
												 Join hardware h
													 On h.uid_workdesk = whd.uid_workdesk
													And (h.ispc = 1
													  Or  h.isServer = 1)
													  and whd.XIsInEffect = 1 and whd.XOrigin > 0
												 Join ( -- physische Vorgänger mitnehmen
													   Select  UID_Child, UID_Parent
														  From softwaredependsonsoftware
														 Where v_InheritePhysicalDependencies = 0
													   Union
													   Select uid_driver, uid_driver From driver) su
													 On su.uid_child = whd.uid_driver
												 Join driverhaslicence dhl
													 On su.uid_parent = dhl.uid_driver
										  Union
										  --  2a) Treiber an Maschinen zugewiesen
										  Select h.uid_hardware, dhl.uid_licence
											From hardware h
												 Join machineHasDriver mhd
													 On h.uid_hardware = mhd.uid_hardware
													And (h.ispc = 1
													  Or  h.isServer = 1)
													and mhd.XIsInEffect = 1 and mhd.XOrigin > 0
												 Join ( -- physische Vorgänger mitnehmen
													   Select  UID_Child, UID_Parent
														  From softwaredependsonsoftware
														 Where v_InheritePhysicalDependencies = 0
													   Union
													   Select uid_driver, uid_driver From driver) su
													 On su.uid_child = mhd.uid_driver
												 Join driverhaslicence dhl
													 On su.uid_parent = dhl.uid_driver
										  Union
										  --  3) OS auf dem Arbeitsplatz zugewiesen
										  -- Supportfall RonnyV 2007-01-16 bei Üstra
										  -- Wunsch: OS des Workdesk nur dann nehmen, wenn über die Hardware.UID_OS keine Lizenz ermittelbar ist
										  -- 2008-01-11 Änderung laut Buglist 7869
										  Select w.uid_workdesk, os.uid_licence
											From workdesk w Join os On w.UID_OS = os.UID_OS
										   Where v_Zaehlweise = 1
										  Union
										  --  3a) OS auf dem PC zugewiesen
										  Select h.uid_hardware, os.uid_licence
											From	 hardware h
												 Join
													 os
												 On h.UID_OS = os.UID_OS
												And (h.ispc = 1
												  Or  h.isServer = 1)
										   Where v_Zaehlweise = 2
											  Or  v_Zaehlweise = 3 -- \ der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
																  ) m
								Group By uid_licence) x
						   On l.uid_licence = x.uid_licence) zz
			   On Licence.UID_Licence = zz.uid_licence;

	Cursor LicenceCompanyTarget2 Is
		Select Licence.uid_licence, zz.CountItems
		  From	   Licence
			   Join
				   (Select l.uid_licence, NVL(x.CountItems, 0) As CountItems
					  From	   licence l
						   Left Outer Join
							   (  Select uid_licence, COUNT(*) As CountItems
									From ( -- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
										  Select  Distinct w.uid_workdesk, ahl.uid_licence
											 From person p
												  Join workdesk w
													  On p.uid_workdesk = w.uid_workdesk
												  Join personhasapp pha
													  On p.uid_person = pha.uid_person
													and pha.XIsInEffect = 1 and pha.XOrigin > 0
												  Join ( -- physische Vorgänger mitnehmen
														Select	UID_Child, UID_Parent
														   From softwaredependsonsoftware
														  Where v_InheritePhysicalDependencies = 0
														Union
														Select uid_application, uid_application From application) su
													  On su.uid_child = pha.uid_application
												  Join apphaslicence ahl
													  On su.uid_parent = ahl.uid_application
											Where Not Exists
													  (Select 1
														 From	  workdeskhasapp wha
															  Join
																  ( -- physische Vorgänger mitnehmen
																   Select  UID_Child, UID_Parent
																	  From softwaredependsonsoftware
																	 Where v_InheritePhysicalDependencies = 0
																   Union
																   Select uid_application, uid_application From application) su1
															  On su1.uid_child = wha.uid_application
															  and wha.XIsInEffect = 1 and wha.XOrigin > 0
														Where w.uid_workdesk = wha.uid_workdesk
														  And su.uid_parent = su1.uid_parent -- wha.uid_application = pha.uid_application
																							) -- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
																							 ) m
								Group By uid_licence) x
						   On l.uid_licence = x.uid_licence) zz
			   On Licence.uid_licence = zz.uid_licence;

	Cursor LicenceCompanyTarget3 Is
		Select Licence.uid_licence, zz.CountItems
		  From	   Licence
			   Join
				   (Select l.uid_licence, NVL(x.CountItems, 0) As CountItems
					  From	   licence l
						   Left Outer Join
							   (  Select uid_licence, COUNT(*) As CountItems
									From ( -- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
										  Select  Distinct pha.uid_person, ahl.uid_licence
											 From personhasapp pha
												  --   join application a on pha.uid_application = a.uid_application
												  Join ( -- physische Vorgänger mitnehmen
														Select	UID_Child, UID_Parent
														   From softwaredependsonsoftware
														  Where v_InheritePhysicalDependencies = 0
														Union
														Select uid_application, uid_application From application) su
													  On su.uid_child = pha.uid_application
													  and pha.XIsInEffect = 1 and pha.XOrigin > 0
												  Join apphaslicence ahl
													  On su.uid_parent = ahl.uid_application -- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
																							) m
								Group By uid_licence) x
						   On l.uid_licence = x.uid_licence) zz
			   On Licence.uid_licence = zz.uid_licence;

	Cursor LicenceCompanyTarget4 Is
		Select Licence.uid_licence, zz.CountItems
		  From	   Licence
			   Join
				   (Select l.uid_licence, NVL(x.CountItems, 0) As CountItems
					  From	   licence l
						   Left Outer Join
							   (  Select uid_licence, COUNT(*) As CountItems
									From ( -- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
										  Select  Distinct pha.uid_person, ahl.uid_licence
											 From personhasapp pha
												  Join person p
													  On pha.uid_person = p.uid_person
													 And p.uid_workdesk Is Null -- kein Stammpc vorhanden
													 and pha.XIsInEffect = 1 and pha.XOrigin > 0
												  --  join application a on pha.uid_application = a.uid_application
												  Join ( -- physische Vorgänger mitnehmen
														Select	UID_Child, UID_Parent
														   From softwaredependsonsoftware
														  Where v_InheritePhysicalDependencies = 0
														Union
														Select uid_application, uid_application From application) su
													  On su.uid_child = pha.uid_application
												  --  join apphaslicence ahl on su.uid_parent = ahl.uid_application
												  -- Einwand CK 2005-10-06 hier können auch Treiber nachgezogen werden
												  Join (Select uid_application, uid_licence From apphaslicence
														Union
														Select uid_driver, uid_licence From driverhaslicence) ahl
													  On su.uid_parent = ahl.uid_application -- \ Einwand CK 2005-10-06 hier können auch Treiber nachgezogen werden
																							-- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
										 ) m
								Group By uid_licence) x
						   On l.uid_licence = x.uid_licence) zz
			   On Licence.uid_licence = zz.uid_licence;

	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();

Begin
	
	if QBM_GGetInfo2.FGIConfigParmValue('Software\LicenceManagement') <> '1' then
		goto ende;
	end if;

	v_Zaehlweise := 0;

	Begin
		v_Zaehlweise := TO_NUMBER('0' || QBM_GGetInfo2.FGIConfigParmValue('Software\LicenceManagement\CountOSLicenceBy'));

		If v_Zaehlweise = 0 Then
			v_Zaehlweise := 1;
		End If;
	End;

	Begin
		Select 1
		  Into v_exists
		  From DUAL
		 Where QBM_GGetInfo2.FGIConfigParmValue('SOFTWARE\INHERITEPHYSICALDEPENDENCIES') is not null;
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	If v_exists = 1 Then
		v_InheritePhysicalDependencies := 1;
	End If;

	Begin
		-- CountLicMacDirectTarget - der Sollzustand Zuweisungen an Maschinen laut Workdeskhas...
		-- Berechnung für alles
		Open LicenceCompanyTarget1;
		Loop
			Fetch LicenceCompanyTarget1 bulk collect Into v_uid_licence_tab, v_Count_tab limit v_limit;

			QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
			Update Licence
			   Set CountLicMacDirectTarget = v_Count_tab(i)
			 Where uid_licence = v_uid_licence_tab(i)
			   And NVL(CountLicMacDirectTarget, 0) <> v_Count_tab(i);

			Exit When LicenceCompanyTarget1%Notfound;

		End Loop;
		Close LicenceCompanyTarget1;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		-- CountLicMacIndirectTarget -	der Sollzustand Zuweisungen an Maschinen über StammPC-Beziehungen
		Open LicenceCompanyTarget2;
		Loop
			Fetch LicenceCompanyTarget2 bulk collect Into v_uid_licence_tab, v_Count_tab limit v_limit;

			QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
			Update Licence
			   Set CountLicMacIndirectTarget = v_Count_tab(i)
			 Where uid_licence = v_uid_licence_tab(i)
			   And NVL(CountLicMacIndirectTarget, 0) <> v_Count_tab(i);

			Exit When LicenceCompanyTarget2%Notfound;
		End Loop;
		Close LicenceCompanyTarget2;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		-- CountLicUserTarget -  der Sollzustand Zuweisungen an Nutzer über PersonHas...
		Open LicenceCompanyTarget3;
		Loop
			Fetch LicenceCompanyTarget3 bulk collect Into v_uid_licence_tab, v_Count_tab limit v_limit;

			QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
			Update Licence
			   Set CountLicUserTarget = v_Count_tab(i)
			 Where uid_licence = v_uid_licence_tab(i)
			   And NVL(CountLicUserTarget, 0) <> v_Count_tab(i);

			Exit When LicenceCompanyTarget3%Notfound;

		End Loop;
		Close LicenceCompanyTarget3;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		-- CountLicMacPossTarget - der Sollzustand möglicher Maschinenzuweisungen über Nutzer ohne StammPC, ermittelt über PersonHas
		Open LicenceCompanyTarget4;
		Loop
			Fetch LicenceCompanyTarget4 bulk collect Into v_uid_licence_tab, v_Count_tab limit v_limit;

			QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
			Update Licence
			   Set CountLicMacPossTarget = v_Count_tab(i)
			 Where uid_licence = v_uid_licence_tab(i)
			   And NVL(CountLicMacPossTarget, 0) <> v_Count_tab(i);


			Exit When LicenceCompanyTarget4%Notfound;

		End Loop;
		Close LicenceCompanyTarget4;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

<<ende>>

	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);

end ZLicenceCompanyTarget;
-----------------------------------------------------------------------------------------------
-- / Procedure ZLicenceCompanyTarget
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-- Procedure ZLicenceCompanyActual
-----------------------------------------------------------------------------------------------
Procedure ZLicenceCompanyActual (v_SlotNumber number
									, v_dummy1 varchar2
									, v_dummy2 varchar2
									, v_GenProcID varchar2
									)
as


	v_Anzahl_tab QBM_GTypeDefinition.YNumberTab := QBM_GTypeDefinition.YNumberTab();
	v_uid_licence_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_Limit number := 500;

	Cursor LicenceCompanyActual1 Is
		Select Licence.uid_licence, zz.Anzahl
		  From	   Licence
			   Join
				   (Select l.uid_licence, NVL(x.anzahl, 0) As Anzahl
					  From	   licence l
						   Left Outer Join -- left outer, damit auch wirklich alle Lizenzen geliefert werden
							   (  Select uid_licence, COUNT(*) As Anzahl
									From ( -- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
										  Select  mai.uid_Hardware, ahl.uid_licence
											 From	  MachineAppsInfo mai
												  Join
													  apphaslicence ahl
												  On mai.uid_application = ahl.uid_application
												 And mai.AppsNotDriver = 1
												 And mai.CurrentlyActive = 1
										  Union
										  --  2) Treiber an Maschinen zugewiesen
										  Select mai.uid_Hardware, dhl.uid_licence
											From	 MachineAppsInfo mai
												 Join
													 driverhaslicence dhl
												 On mai.uid_driver = dhl.uid_driver
												And NVL(mai.AppsNotDriver, 0) = 0
												And mai.CurrentlyActive = 1
										  Union
										  --  3) OS auf dem Arbeitsplatz zugewiesen
										  Select h.uid_hardware, os.uid_licence
											From hardware h Join os On h.UID_OS = os.UID_OS -- \ der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
																							   ) m
								Group By uid_licence) x
						   On l.uid_licence = x.uid_licence) zz
			   On Licence.UID_Licence = zz.uid_licence;

	Cursor LicenceCompanyActual2 Is
		Select Licence.uid_licence, zz.Anzahl
		  From	   Licence
			   Join
				   (Select l.uid_licence, NVL(x.anzahl, 0) As Anzahl
					  From	   licence l
						   Left Outer Join
							   (  Select uid_licence, COUNT(*) As Anzahl
									From ( -- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
										  Select  Distinct r.uid_hardware, ahl.uid_licence
											 From	  (Select ai.UID_ADSAccount As uid_account
															, ai.UID_Application
															, a.UID_HardwareDefaultMachine As uid_hardware
															, a.uid_person
														 From	  adsaccountappsinfo ai
															  Join
																  ADSAccount a
															  On ai.uid_ADSAccount = a.uid_ADSAccount
															 And ai.CurrentlyActive = 1
													) r
												  Join
													  apphaslicence ahl
												  On r.uid_application = ahl.uid_application
												 -- StammPC muß da sein
												 And r.uid_hardware Is Not Null
											Where Not Exists
													  (Select 1
														 From MachineAppsInfo mai
														Where mai.uid_hardware = r.uid_hardware
														  And r.uid_application = mai.uid_application
														  And mai.CurrentlyActive = 1) -- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
																					  ) m
								Group By uid_licence) x
						   On l.uid_licence = x.uid_licence) zz
			   On Licence.uid_licence = zz.uid_licence;

	Cursor LicenceCompanyActual3 Is
		Select Licence.uid_licence, zz.Anzahl
		  From	   Licence
			   Join
				   (Select l.uid_licence, NVL(x.anzahl, 0) As Anzahl
					  From	   licence l
						   Left Outer Join
							   (  Select uid_licence, COUNT(*) As Anzahl
									From ( -- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
										  Select  Distinct r.uid_Account, ahl.uid_licence
											 From	  (Select ai.UID_ADSAccount As uid_account
															, ai.UID_Application
															, a.UID_HardwareDefaultMachine As uid_hardware
															, a.uid_person
														 From	  adsaccountappsinfo ai
															  Join
																  ADSAccount a
															  On ai.uid_ADSAccount = a.uid_ADSAccount
															 And ai.CurrentlyActive = 1
													) r
												  Join
													  apphaslicence ahl
												  On r.uid_application = ahl.uid_application -- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
																							) m
								Group By uid_licence) x
						   On l.uid_licence = x.uid_licence) zz
			   On Licence.uid_licence = zz.uid_licence;

	Cursor LicenceCompanyActual4 Is
		Select Licence.uid_licence, zz.Anzahl
		  From	   Licence
			   Join
				   (Select l.uid_licence, NVL(x.anzahl, 0) As Anzahl
					  From	   licence l
						   Left Outer Join
							   (  Select uid_licence, COUNT(*) As Anzahl
									From ( -- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
										  Select  Distinct r.uid_account, ahl.uid_licence
											 From	  (Select ai.UID_ADSAccount As uid_account
															, ai.UID_Application
															, a.UID_HardwareDefaultMachine As uid_hardware
															, a.uid_person
														 From	  adsaccountappsinfo ai
															  Join
																  ADSAccount a
															  On ai.uid_ADSAccount = a.uid_ADSAccount
															 And ai.CurrentlyActive = 1
															 And a.UID_HardwareDefaultMachine Is Null
														) r
												  Join
													  apphaslicence ahl
												  On r.uid_application = ahl.uid_application -- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
																							) m
								Group By uid_licence) x
						   On l.uid_licence = x.uid_licence) zz
			   On Licence.uid_licence = zz.uid_licence;



	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();


begin

	if QBM_GGetInfo2.FGIConfigParmValue('Software\LicenceManagement') <> '1' then
		goto ende;
	end if;


	Begin
		-- CountLicMacDirectActual - der Sollzustand Zuweisungen an Maschinen laut machineappsinfo
		-- Berechnung für alles
		Open LicenceCompanyActual1;
		Loop
			Fetch LicenceCompanyActual1 bulk collect
			Into v_uid_licence_tab, v_Anzahl_tab limit v_limit;

			QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
			Update Licence
			   Set CountLicMacDirectActual = v_Anzahl_tab(i)
			 Where uid_licence = v_uid_licence_tab(i)
			   And NVL(CountLicMacDirectActual, 0) <> v_Anzahl_tab(i);

			Exit When LicenceCompanyActual1%Notfound;
		End Loop;
		Close LicenceCompanyActual1;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		-- CountLicMacIndirectActual -	der Istzustand Zuweisungen an Maschinen über StammPC-Beziehungen, xxxAccountAppsInfo und MachineAppsInfo
		Open LicenceCompanyActual2;
		Loop
			Fetch LicenceCompanyActual2 bulk collect
			Into v_uid_licence_tab, v_Anzahl_tab limit v_limit;

			QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
			Update Licence
			   Set CountLicMacIndirectActual = v_Anzahl_tab(i)
			 Where uid_licence = v_uid_licence_tab(i)
			   And NVL(CountLicMacIndirectActual, 0) <> v_Anzahl_tab(i);

			Exit When LicenceCompanyActual2%Notfound;
		End Loop;
		Close LicenceCompanyActual2;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;


	Begin
		-- CountLicUserActual -  der Istzustand Zuweisungen an Nutzer über xxxAccountAppsInfo
		Open LicenceCompanyActual3;
		Loop
			Fetch LicenceCompanyActual3 bulk collect
			Into v_uid_licence_tab, v_Anzahl_tab limit v_limit;

			QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
			Update Licence
			   Set CountLicUserActual = v_Anzahl_tab(i)
			 Where uid_licence = v_uid_licence_tab(i)
			   And NVL(CountLicUserActual, 0) <> v_Anzahl_tab(i);

			Exit When LicenceCompanyActual3%Notfound;
		End Loop;
		Close LicenceCompanyActual3;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		-- CountLicMacPossActual - der istzustand möglicher Maschinenzuweisungen über Nutzer ohne StammPC, ermittelt über xxxAccountAppsInfo
		Open LicenceCompanyActual4;
		Loop
			Fetch LicenceCompanyActual4 bulk collect
			Into v_uid_licence_tab, v_Anzahl_tab limit v_limit;

			QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
			Update Licence
			   Set CountLicMacPossActual = v_Anzahl_tab(i)
			 Where uid_licence = v_uid_licence_tab(i)
			   And NVL(CountLicMacPossActual, 0) <> v_Anzahl_tab(i);

			Exit When LicenceCompanyActual4%Notfound;
		End Loop;
		Close LicenceCompanyActual4;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;




<<ende>>

	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);

end ZLicenceCompanyActual;
-----------------------------------------------------------------------------------------------
-- / Procedure ZLicenceCompanyActual
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-- Procedure ZLicenceCompanyReal
-----------------------------------------------------------------------------------------------
Procedure ZLicenceCompanyReal (v_SlotNumber number
									, v_dummy1 varchar2
									, v_dummy2 varchar2
									, v_GenProcID varchar2
									)
as

	v_Anzahl_tab QBM_GTypeDefinition.YNumberTab := QBM_GTypeDefinition.YNumberTab();
	v_uid_licence_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_Limit number := 500;


	Cursor LicenceCompanyReal1 Is
		Select Licence.uid_licence, zz.Anzahl
		  From	   Licence
			   Join
				   (Select l.uid_licence, NVL(x.anzahl, 0) As Anzahl
					  From	   licence l
						   Left Outer Join -- left outer, damit auch wirklich alle Lizenzen geliefert werden
							   (  Select uid_licence, COUNT(*) As Anzahl
									From ( -- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
										  Select  mai.uid_Hardware, ahl.uid_licence
											 From	  MachineAppsConfig mai
												  Join
													  apphaslicence ahl
												  On mai.uid_application = ahl.uid_application
												 And mai.AppsNotDriver = 1
												 And mai.CurrentlyActive = 1
										  Union
										  --  2) Treiber an Maschinen zugewiesen
										  Select mai.uid_Hardware, dhl.uid_licence
											From	 MachineAppsConfig mai
												 Join
													 driverhaslicence dhl
												 On mai.uid_driver = dhl.uid_driver
												And NVL(mai.AppsNotDriver, 0) = 0
												And mai.CurrentlyActive = 1 -- OS muß auch als Treiber erkannt werden, zumindest war Softwareinventory mal so gedacht
																		   -- \ der eigentliche Kern der Bestimmungÿ der gruppiert werden muß, um auf die Lizenzen zu kommen
										 ) m
								Group By uid_licence) x
						   On l.uid_licence = x.uid_licence) zz
			   On Licence.UID_Licence = zz.uid_licence;


	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();


begin

	if QBM_GGetInfo2.FGIConfigParmValue('Software\LicenceManagement') <> '1' then
		goto ende;
	end if;

	begin
		Open LicenceCompanyReal1;
		Loop
			Fetch LicenceCompanyReal1 bulk collect Into v_uid_licence_tab, v_Anzahl_tab limit v_limit;

			QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);
			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
				Update Licence
				   Set CountLicMacReal = v_Anzahl_tab(i)
				 Where uid_licence = v_uid_licence_tab(i)
				   And NVL(CountLicMacReal, 0) <> v_Anzahl_tab(i);

			Exit When LicenceCompanyReal1%Notfound;
		End Loop;
		Close LicenceCompanyReal1;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;


<<ende>>

	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);

end ZLicenceCompanyReal;
-----------------------------------------------------------------------------------------------
-- / Procedure ZLicenceCompanyReal
-----------------------------------------------------------------------------------------------






-----------------------------------------------------------------------------------------------
-- Procedure ZLicenceOrgTarget
-----------------------------------------------------------------------------------------------
Procedure ZLicenceOrgTarget (v_SlotNumber number)
as



	v_Count_tab QBM_GTypeDefinition.YNumberTab := QBM_GTypeDefinition.YNumberTab();
	v_uid_licence_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_uid_org_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_Limit number := 500;


	v_primary					   Number;
	v_secondary 				   Number;
	v_InheritePhysicalDependencies Number;
	v_exists					   QBM_GTypeDefinition.YBool;
	v_Zaehlweise				   Number;

	Cursor LicenceOrgTarget1 Is
		Select basetreehaslicence.uid_licence, basetreehaslicence.uid_org, zz.CountItems
		  From	   basetreeHasLicence
			   Join
				   (  Select yy.uid_org, m.uid_licence, COUNT(*) As CountItems
						From	 ( -- die Arbeitsplätze und ihre Lizenzen bestimmen
								   -- Achtung, Workdesk hier im Unterschied zu viLicenceCompanyTarget gleich mit rausführen, nochmal join über haware mit uid_workdesk zum nächsten Block (yy) ist der absoluter Performan_'0killer
								   Select h.uid_hardware, ahl.uid_licence, wha.uid_workdesk
									 From workdeskhasapp wha
										  Join hardware h
											  On h.uid_workdesk = wha.uid_workdesk
											 And (h.ispc = 1
											   Or  h.isServer = 1)
											and wha.XIsInEffect = 1 and wha.XOrigin > 0
										  Join ( -- physische Vorgänger mitnehmen
												Select	UID_Child, UID_Parent
												   From softwaredependsonsoftware
												  Where v_InheritePhysicalDependencies = 0
												Union
												Select uid_application, uid_application From application) su
											  On su.uid_child = wha.uid_application
										  Join apphaslicence ahl
											  On su.uid_parent = ahl.uid_application
								  Union
								  --  2) Treiber an Arbeitsplätze zugewiesen
								  Select h.uid_hardware, dhl.uid_licence, h.uid_workdesk
									From workdeskhasdriver whd
										 Join hardware h
											 On h.uid_workdesk = whd.uid_workdesk
											And (h.ispc = 1
											  Or  h.isServer = 1)
											  and whd.XIsInEffect = 1 and whd.XOrigin > 0
										 Join ( -- physische Vorgänger mitnehmen
											   Select  UID_Child, UID_Parent
												  From softwaredependsonsoftware
												 Where v_InheritePhysicalDependencies = 0
											   Union
											   Select uid_driver, uid_driver From driver) su
											 On su.uid_child = whd.uid_driver
										 Join driverhaslicence dhl
											 On su.uid_parent = dhl.uid_driver
								  Union
								  --  2a) Treiber an Maschinen zugewiesen
								  Select h.uid_hardware, dhl.uid_licence, h.uid_workdesk
									From hardware h
										 Join machineHasDriver mhd
											 On h.uid_hardware = mhd.uid_hardware
											And (h.ispc = 1
											  Or  h.isServer = 1)
											and mhd.XIsInEffect = 1 and mhd.XOrigin > 0
										 Join ( -- physische Vorgänger mitnehmen
											   Select  UID_Child, UID_Parent
												  From softwaredependsonsoftware
												 Where v_InheritePhysicalDependencies = 0
											   Union
											   Select uid_driver, uid_driver From driver) su
											 On su.uid_child = mhd.uid_driver
										 Join driverhaslicence dhl
											 On su.uid_parent = dhl.uid_driver) m
							 Join
								 -- die Arbeitsplätze zur Menge der Orgs bestimmen
								 (Select p.uid_parameter As uid_org, ww.uid_workdesk
									From	 QBMDBQueueCurrent p
										 Join
											 (Select Distinct v.uid_org, wio.uid_workdesk As uid_workdesk
												From SDL_VLicenceNodeSubnode v Join workdeskinbasetree wio On v.uid_suborg = wio.uid_org
											   Where v_secondary = 1 and wio.XOrigin > 0
											  Union All
											  Select Distinct v.uid_org, w.uid_workdesk
												From SDL_VLicenceNodeSubnode v Join helperworkdeskorg w On v.uid_suborg = w.uid_org
											   Where v_primary = 1) ww
										 On p.uid_parameter = ww.uid_org where SlotNumber = v_SlotNumber) yy
							 On m.uid_workdesk = yy.uid_workdesk
					Group By yy.uid_org, m.uid_licence) zz
			   On basetreeHasLicence.uid_org = zz.uid_org
			  And basetreeHasLicence.uid_licence = zz.uid_licence;

	-- die Sonderlocke für die Betriebssysteme
	-- Buglist 7869
	Cursor LicenceOrgTarget1a Is
		Select basetreeHasLicence.uid_licence, basetreeHasLicence.uid_org, zz.CountItems
		  From	   basetreeHasLicence
			   Join
				   (  Select yy.uid_org, yy.uid_licence, COUNT(*) As CountItems
						From (Select v.uid_org, os.uid_licence
								From SDL_VLicenceNodeSubnode v
									 Join QBMDBQueueCurrent p
										 On v.uid_org = p.uid_parameter
									 Join workdeskinbasetree wio
										 On v.uid_suborg = wio.uid_org
										And v.IsAssignmentAllowedWorkdesk = 1 and wio.XOrigin > 0
									 Join workdesk w
										 On wio.uid_workdesk = w.uid_workdesk
									 Join os
										 On w.UID_OS = os.UID_OS
							   Where v_secondary = 1 and SlotNumber = v_SlotNumber
							  Union All
							  Select v.uid_org, os.uid_licence
								From SDL_VLicenceNodeSubnode v
									 Join QBMDBQueueCurrent p
										 On v.uid_org = p.uid_parameter
									 Join helperworkdeskorg hwo
										 On v.uid_suborg = hwo.uid_org
									 Join workdesk w
										 On hwo.uid_workdesk = w.uid_workdesk
									 Join os
										 On w.UID_OS = os.UID_OS
							   Where v_primary = 1 and SlotNumber = v_SlotNumber) yy
					Group By yy.uid_org, yy.uid_licence) zz
			   On basetreeHasLicence.uid_org = zz.uid_org
			  And basetreeHasLicence.uid_licence = zz.uid_licence;

	Cursor LicenceOrgTarget1b Is
		Select basetreeHasLicence.uid_licence, basetreeHasLicence.uid_org, zz.CountItems
		  From	   basetreeHasLicence
			   Join
				   (  Select yy.uid_org, yy.uid_licence, COUNT(*) As CountItems
						From (Select v.uid_org, os.uid_licence
								From SDL_VLicenceNodeSubnode v
									 Join QBMDBQueueCurrent p
										 On v.uid_org = p.uid_parameter
									 Join workdeskinbasetree wio
										 On v.uid_suborg = wio.uid_org
										And v.IsAssignmentAllowedWorkdesk = 1 and wio.XOrigin > 0
									 Join hardware h
										 On h.uid_workdesk = wio.uid_workdesk
									 Join os
										 On h.UID_OS = os.UID_OS
							   Where v_secondary = 1 and SlotNumber = v_SlotNumber
							  Union All
							  Select v.uid_org, os.uid_licence
								From SDL_VLicenceNodeSubnode v
									 Join QBMDBQueueCurrent p
										 On v.uid_org = p.uid_parameter
									 Join helperworkdeskorg w
										 On v.uid_suborg = w.uid_org
									 Join hardware h
										 On h.uid_workdesk = w.uid_workdesk
									 Join os
										 On h.UID_OS = os.UID_OS
							   Where v_primary = 1 and SlotNumber = v_SlotNumber) yy
					Group By yy.uid_org, yy.uid_licence) zz
			   On basetreeHasLicence.uid_org = zz.uid_org
			  And basetreeHasLicence.uid_licence = zz.uid_licence;

	Cursor LicenceOrgTarget1c Is
		Select basetreeHasLicence.uid_licence, basetreeHasLicence.uid_org, zz.CountItems
		  From	   basetreeHasLicence
			   Join
				   (  Select yy.uid_org, yy.uid_licence, COUNT(*) As CountItems
						From (Select v.uid_org, os.uid_licence
								From SDL_VLicenceNodeSubnode v
									 Join QBMDBQueueCurrent p
										 On v.uid_org = p.uid_parameter
									 Join HardwareInbasetree hio
										 On v.uid_suborg = hio.uid_org
										And v.IsAssignmentAllowedHardware = 1 and hio.XOrigin > 0
									 Join hardware h
										 On h.uid_hardware = hio.uid_hardware
									 Join os
										 On h.UID_OS = os.UID_OS
							   Where v_secondary = 1 and SlotNumber = v_SlotNumber
							  Union All
							  Select v.uid_org, os.uid_licence
								From SDL_VLicenceNodeSubnode v
									 Join QBMDBQueueCurrent p
										 On v.uid_org = p.uid_parameter
									 Join helperhardwareorg hho
										 On v.uid_suborg = hho.uid_org
									 Join hardware h
										 On hho.uid_hardware = h.uid_hardware
									 Join os
										 On h.UID_OS = os.UID_OS
							   Where v_primary = 1 and SlotNumber = v_SlotNumber) yy
					Group By yy.uid_org, yy.uid_licence) zz
			   On basetreeHasLicence.uid_org = zz.uid_org
			  And basetreeHasLicence.uid_licence = zz.uid_licence;

	--/ die Sonderlocke für die Betriebssysteme
	--/ Buglist 7869

	Cursor LicenceOrgTarget2 Is
		Select basetreehaslicence.uid_licence, basetreehaslicence.uid_org, zz.CountItems
		  From	   basetreeHasLicence
			   Join
				   (  Select yy.uid_org, m.uid_licence, COUNT(*) As CountItems
						From	 ( -- die Arbeitsplätze und ihre Lizenzen bestimmen
								   -- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
								   Select Distinct w.uid_workdesk, ahl.uid_licence
									 From person p
										  Join workdesk w
											  On p.uid_workdesk = w.uid_workdesk
										  Join personhasapp pha
											  On p.uid_person = pha.uid_person
										  Join ( -- physische Vorgänger mitnehmen
												Select	UID_Child, UID_Parent
												   From softwaredependsonsoftware
												  Where v_InheritePhysicalDependencies = 0
												Union
												Select uid_application, uid_application From application) su
											  On su.uid_child = pha.uid_application
											  and pha.XIsInEffect = 1 and pha.XOrigin > 0
										  Join apphaslicence ahl
											  On su.uid_parent = ahl.uid_application
									Where Not Exists
											  (Select 1
												 From	  workdeskhasapp wha
													  Join
														  ( -- physische Vorgänger mitnehmen
														   Select  UID_Child, UID_Parent
															  From softwaredependsonsoftware
															 Where v_InheritePhysicalDependencies = 0
														   Union
														   Select uid_application, uid_application From application) su1
													  On su1.uid_child = wha.uid_application
													  and wha.XIsInEffect = 1 and wha.XOrigin > 0
												Where w.uid_workdesk = wha.uid_workdesk
												  And su.uid_parent = su1.uid_parent -- wha.uid_application = pha.uid_application
																					) -- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
																					 ) m
							 Join
								 -- die Arbeitsplätze zur Menge der Orgs bestimmen
								 (Select p.uid_parameter As uid_org, ww.uid_workdesk
									From	 QBMDBQueueCurrent p
										 Join
											 (Select Distinct v.uid_org, wio.uid_workdesk As uid_workdesk
												From SDL_VLicenceNodeSubnode v Join workdeskinbasetree wio On v.uid_suborg = wio.uid_org
											   Where v_secondary = 1 and wio.XOrigin > 0
											  Union All
											  Select Distinct v.uid_org, w.uid_workdesk
												From SDL_VLicenceNodeSubnode v Join helperworkdeskorg w On v.uid_suborg = w.uid_org
											   Where v_primary = 1) ww
										 On p.uid_parameter = ww.uid_org where SlotNumber = v_SlotNumber) yy
							 On m.uid_workdesk = yy.uid_workdesk
					Group By yy.uid_org, m.uid_licence) zz
			   On basetreeHasLicence.uid_org = zz.uid_org
			  And basetreeHasLicence.uid_licence = zz.uid_licence;

	Cursor LicenceOrgTarget3 Is
		Select basetreehaslicence.uid_licence, basetreehaslicence.uid_org, zz.CountItems
		  From	   basetreeHasLicence
			   Join
				   (  Select yy.uid_org, m.uid_licence, COUNT(*) As CountItems
						From	 ( -- die Personen und ihre Lizenzen bestimmen
								   -- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
								   Select Distinct pha.uid_person, ahl.uid_licence
									 From personhasapp pha
										  --   join application a on pha.uid_application = a.uid_application
										  Join ( -- physische Vorgänger mitnehmen
												Select	UID_Child, UID_Parent
												   From softwaredependsonsoftware
												  Where v_InheritePhysicalDependencies = 0
												Union
												Select uid_application, uid_application From application) su
											  On su.uid_child = pha.uid_application
											  and pha.XIsInEffect = 1 and pha.XOrigin > 0
										  Join apphaslicence ahl
											  On su.uid_parent = ahl.uid_application -- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
																					) m
							 Join
								 -- die Personen zur Menge der Orgs bestimmen
								 (Select p.uid_parameter As uid_org, ww.uid_Person
									From	 QBMDBQueueCurrent p
										 Join
											 (Select Distinct v.uid_org, wio.uid_person As uid_Person
												From SDL_VLicenceNodeSubnode v Join Personinbasetree wio On v.uid_suborg = wio.uid_org
											   Where v_secondary = 1 and wio.XOrigin > 0
											  Union All
											  Select Distinct v.uid_org, w.uid_Person
												From SDL_VLicenceNodeSubnode v Join HelperPersonOrg w On v.uid_suborg = w.uid_org
											   Where v_primary = 1) ww
										 On p.uid_parameter = ww.uid_org where SlotNumber = v_SlotNumber) yy
							 On m.uid_Person = yy.uid_Person
					Group By yy.uid_org, m.uid_licence) zz
			   On basetreeHasLicence.uid_org = zz.uid_org
			  And basetreeHasLicence.uid_licence = zz.uid_licence;

	Cursor LicenceOrgTarget4 Is
		Select basetreehaslicence.uid_licence, basetreehaslicence.uid_org, zz.CountItems
		  From	   basetreeHasLicence
			   Join
				   (  Select yy.uid_org, m.uid_licence, COUNT(*) As CountItems
						From	 ( -- die Personen und ihre Lizenzen bestimmen
								   -- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
								   Select Distinct pha.uid_person, ahl.uid_licence
									 From personhasapp pha
										  Join person p
											  On pha.uid_person = p.uid_person
											 And p.uid_workdesk Is Null -- kein Stammpc vorhanden
										  Join ( -- physische Vorgänger mitnehmen
												Select	UID_Child, UID_Parent
												   From softwaredependsonsoftware
												  Where v_InheritePhysicalDependencies = 0
												Union
												Select uid_application, uid_application From application) su
											  On su.uid_child = pha.uid_application
											  and pha.XIsInEffect = 1 and pha.XOrigin > 0
										  --  join apphaslicence ahl on su.uid_parent = ahl.uid_application
										  -- Einwand CK 2005-10-06 hier können auch Treiber nachgezogen werden
										  Join (Select uid_application, uid_licence From apphaslicence
												Union
												Select uid_driver, uid_licence From driverhaslicence) ahl
											  On su.uid_parent = ahl.uid_application -- \ Einwand CK 2005-10-06 hier können auch Treiber nachgezogen werden
																					-- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
								 ) m
							 Join
								 -- die Personen zur Menge der Orgs bestimmen
								 (Select p.uid_parameter As uid_org, ww.uid_Person
									From	 QBMDBQueueCurrent p
										 Join
											 (Select Distinct v.uid_org, wio.uid_person As uid_Person
												From	 SDL_VLicenceNodeSubnode v
													 Join
														 Personinbasetree wio
													 On v.uid_suborg = wio.uid_org
													And v_secondary = 1 and wio.XOrigin > 0
											  Union All
											  Select Distinct v.uid_org, w.uid_Person
												From	 SDL_VLicenceNodeSubnode v
													 Join
														 HelperPersonOrg w
													 On v.uid_suborg = w.uid_org
													And v_primary = 1) ww
										 On p.uid_parameter = ww.uid_org where SlotNumber = v_SlotNumber) yy
							 On m.uid_Person = yy.uid_Person
					Group By yy.uid_org, m.uid_licence) zz
			   On basetreeHasLicence.uid_org = zz.uid_org
			  And basetreeHasLicence.uid_licence = zz.uid_licence;
Begin
	-- die Werte schon mal vorher holen, um sie nicht im Join jedesmal zu ziehen und zu vergleichen
	v_Zaehlweise := 0;
	v_primary := 0;
	v_secondary := 0;
	v_InheritePhysicalDependencies := 0;

	Begin
		v_Zaehlweise := TO_NUMBER('0' || QBM_GGetInfo2.FGIConfigParmValue('Software\LicenceManagement\CountOSLicenceBy'));

		If v_Zaehlweise = 0 Then
			v_Zaehlweise := 1;
		End If;
	End;

	Begin
		Select 1
		  Into v_primary
		  From dual
		 Where QBM_GGetInfo2.FGIConfigParmValue('SOFTWARE\LICENCEMANAGEMENT\LICENCEFORSUBTREE\PRIMARYASSIGNMENT') is not null;
	Exception
		When NO_DATA_FOUND Then
			v_primary := 0;
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		Select 1
		  Into v_secondary
		  From dual
		 Where QBM_GGetInfo2.FGIConfigParmValue('SOFTWARE\LICENCEMANAGEMENT\LICENCEFORSUBTREE\SECONDARYASSIGNMENT') is not null;
	Exception
		When NO_DATA_FOUND Then
			v_secondary := 0;
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		Select 1
		  Into v_exists
		  From DUAL
		 Where QBM_GGetInfo2.FGIConfigParmValue('SOFTWARE\INHERITEPHYSICALDEPENDENCIES') is not null;
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	If v_exists = 1 Then
		v_InheritePhysicalDependencies := 1;
	End If;

	Begin
		-- Berechnung für eine Menge Orgknoten
		-- Voraussetzung schaffen: fehlende BasetreeHasLicence bauen
		SDL_GDBQueueTasks.PLicenceOrg_Basics (v_SlotNumber);
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		-- Werte müssen geliefert werden für alle Orgknoten und alle Lizenzen
		-- da das nicht der Fall ist, wird vorher auf 0 zurücksgesetzt
		Update basetreeHasLicence
		   Set CountLicMacDirectTarget = 0
		 Where NVL(CountLicMacDirectTarget, 0) <> 0
		   And Exists
				   (Select 1
					  From QBMDBQueueCurrent p
					 Where SlotNumber = v_SlotNumber
					 and p.uid_parameter = basetreeHasLicence.uid_org);
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		Open LicenceOrgTarget1;
		Loop
			Fetch LicenceOrgTarget1 bulk collect
			Into v_uid_licence_tab, v_uid_org_tab, v_Count_tab limit v_limit;

			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
			Update basetreeHasLicence
			   Set CountLicMacDirectTarget = v_Count_tab(i)
			 Where uid_licence = v_uid_licence_tab(i)
			   And uid_org = v_uid_org_tab(i);

			Exit When LicenceOrgTarget1%Notfound;

		End Loop;
		Close LicenceOrgTarget1;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	-- die Sonderlocke für die Betriebssysteme
	-- Buglist 7869
	If v_Zaehlweise = 1 Then
		Begin
			Open LicenceOrgTarget1a;
			Loop
				Fetch LicenceOrgTarget1a bulk collect
				Into v_uid_licence_tab, v_uid_org_tab, v_Count_tab limit v_limit;

				forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
				Update basetreeHasLicence
				   Set CountLicMacDirectTarget = CountLicMacDirectTarget + v_Count_tab(i)
				 Where uid_licence = v_uid_licence_tab(i)
				   And uid_org = v_uid_org_tab(i);

				Exit When LicenceOrgTarget1a%Notfound;


			End Loop;
			Close LicenceOrgTarget1a;
		Exception
			When Others Then
				raise_application_error(-20100, 'DatabaseException', True);
		End;
	End If;

	If v_Zaehlweise = 2 Then
		Begin
			Open LicenceOrgTarget1b;
			Loop
				Fetch LicenceOrgTarget1b bulk collect
				Into v_uid_licence_tab, v_uid_org_tab, v_Count_tab limit v_limit;

				forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
				Update basetreeHasLicence
				   Set CountLicMacDirectTarget = CountLicMacDirectTarget + v_Count_tab(i)
				 Where uid_licence = v_uid_licence_tab(i)
				   And uid_org = v_uid_org_tab(i);

				Exit When LicenceOrgTarget1b%Notfound;

			End Loop;
			Close LicenceOrgTarget1b;
		Exception
			When Others Then
				raise_application_error(-20100, 'DatabaseException', True);
		End;
	End If;

	If v_Zaehlweise = 3 Then
		Begin
			Open LicenceOrgTarget1c;
			Loop
				Fetch LicenceOrgTarget1c bulk collect
				Into v_uid_licence_tab, v_uid_org_tab, v_Count_tab limit v_limit;

				forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
				Update basetreeHasLicence
				   Set CountLicMacDirectTarget = CountLicMacDirectTarget + v_Count_tab(i)
				 Where uid_licence = v_uid_licence_tab(i)
				   And uid_org = v_uid_org_tab(i);

				Exit When LicenceOrgTarget1c%Notfound;

			End Loop;
			Close LicenceOrgTarget1c;
		Exception
			When Others Then
				raise_application_error(-20100, 'DatabaseException', True);
		End;
	End If;

	--/ die Sonderlocke für die Betriebssysteme
	--/ Buglist 7869

	Begin
		-- für eine Menge Orgs
		Update basetreeHasLicence
		   Set CountLicMacIndirectTarget = 0
		 Where NVL(CountLicMacIndirectTarget, 0) <> 0
		   And Exists
				   (Select 1
					  From QBMDBQueueCurrent p
					 Where SlotNumber = v_SlotNumber
					 and p.uid_parameter = basetreeHasLicence.uid_org);
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		Open LicenceOrgTarget2;
		Loop
			Fetch LicenceOrgTarget2 bulk collect
			Into v_uid_licence_tab, v_uid_org_tab, v_Count_tab limit v_limit;

			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
			Update basetreeHasLicence
			   Set CountLicMacIndirectTarget = v_Count_tab(i)
			 Where uid_licence = v_uid_licence_tab(i)
			   And uid_org = v_uid_org_tab(i);

			Exit When LicenceOrgTarget2%Notfound;


		End Loop;
		Close LicenceOrgTarget2;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		-- für eine Menge Orgs
		Update basetreeHasLicence
		   Set CountLicUserTarget = 0
		 Where NVL(CountLicUserTarget, 0) <> 0
		   And Exists
				   (Select 1
					  From QBMDBQueueCurrent p
					 Where SlotNumber = v_SlotNumber
					 and p.uid_parameter = basetreeHasLicence.uid_org);
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		Open LicenceOrgTarget3;
		Loop
			Fetch LicenceOrgTarget3 bulk collect
			Into v_uid_licence_tab, v_uid_org_tab, v_Count_tab limit v_limit;

			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
			Update basetreeHasLicence
			   Set CountLicUserTarget = v_Count_tab(i)
			 Where uid_licence = v_uid_licence_tab(i)
			   And uid_org = v_uid_org_tab(i);

			Exit When LicenceOrgTarget3%Notfound;


		End Loop;
		Close LicenceOrgTarget3;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		-- für eine Menge Orgs
		Update basetreeHasLicence
		   Set CountLicMacPossTarget = 0
		 Where NVL(CountLicMacPossTarget, 0) <> 0
		   And Exists
				   (Select 1
					  From QBMDBQueueCurrent p
					 Where SlotNumber = v_SlotNumber
					 and p.uid_parameter = basetreeHasLicence.uid_org);
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		Open LicenceOrgTarget4;
		Loop
			Fetch LicenceOrgTarget4 bulk collect
			Into v_uid_licence_tab, v_uid_org_tab, v_Count_tab limit v_limit;

			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
			Update basetreeHasLicence
			   Set CountLicMacPossTarget = v_Count_tab(i)
			 Where uid_licence = v_uid_licence_tab(i)
			   And uid_org = v_uid_org_tab(i);

			Exit When LicenceOrgTarget4%Notfound;

		End Loop;
		Close LicenceOrgTarget4;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

end ZLicenceOrgTarget;
-----------------------------------------------------------------------------------------------
-- / Procedure ZLicenceOrgTarget
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-- Procedure ZLicenceOrgActual
-----------------------------------------------------------------------------------------------
Procedure ZLicenceOrgActual (v_SlotNumber number)
as

	v_Anzahl_tab QBM_GTypeDefinition.YNumberTab := QBM_GTypeDefinition.YNumberTab();
	v_uid_org_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_uid_licence_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_Limit number := 500;


	v_primary	  Number;
	v_secondary   Number;
	v_Zaehlweise  Number;


	Cursor LicenceOrgActual1 Is
		Select basetreehaslicence.uid_licence, basetreehaslicence.uid_org, zz.Anzahl
		  From	   basetreeHasLicence
			   Join
				   (  Select yy.uid_org, m.uid_licence, COUNT(*) As anzahl
						From ( -- die Arbeitsplätze und ihre Lizenzen bestimmen
							   -- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
							   Select mai.uid_Hardware, ahl.uid_licence
								 From	  MachineAppsInfo mai
									  Join
										  apphaslicence ahl
									  On mai.uid_application = ahl.uid_application
									 And mai.AppsNotDriver = 1
									 And mai.CurrentlyActive = 1
							  Union
							  --  2) Treiber an Maschinen zugewiesen
							  Select mai.uid_Hardware, dhl.uid_licence
								From	 MachineAppsInfo mai
									 Join
										 driverhaslicence dhl
									 On mai.uid_driver = dhl.uid_driver
									And NVL(mai.AppsNotDriver, 0) = 0
									And mai.CurrentlyActive = 1) m
							 Join hardware h
								 On m.uid_hardware = h.uid_hardware
							 Join -- die Arbeitsplätze zur Menge der Orgs bestimmen
								 (Select p.uid_parameter As uid_org, ww.uid_workdesk
									From	 QBMDBQueueCurrent p
										 Join
											 (Select Distinct v.uid_org, wio.uid_workdesk As uid_workdesk
												From SDL_VLicenceNodeSubnode v Join workdeskinbasetree wio On v.uid_suborg = wio.uid_org
											   Where v_secondary = 1
											  Union All
											  Select Distinct v.uid_org, w.uid_workdesk
												From SDL_VLicenceNodeSubnode v Join helperworkdeskorg w On v.uid_suborg = w.uid_org
											   Where v_primary = 1) ww
										 On p.uid_parameter = ww.uid_org and p.Slotnumber = v_Slotnumber
										) yy
								 On h.uid_workdesk = yy.uid_workdesk
					Group By yy.uid_org, m.uid_licence) zz
			   On basetreeHasLicence.uid_org = zz.uid_org
			  And basetreeHasLicence.uid_licence = zz.uid_licence;

	-- die Sonderlocke für die Betriebssysteme
	-- Buglist 7869
	Cursor LicenceOrgActual1a Is
		Select basetreeHasLicence.uid_licence, basetreeHasLicence.uid_org, zz.anzahl
		  From	   basetreeHasLicence
			   Join
				   (  Select yy.uid_org, m.uid_licence, COUNT(*) As anzahl
						From ( --  3) OS auf dem Arbeitsplatz zugewiesen
							  Select  h.uid_hardware, os.uid_licence
								 From hardware h Join os On h.UID_OS = os.UID_OS -- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
																					) m
							 Join hardware h
								 On m.uid_hardware = h.uid_hardware
							 Join -- die Arbeitsplätze zur Menge der Orgs bestimmen
								 (Select Distinct v.uid_org, wio.uid_workdesk As uid_workdesk
									From SDL_VLicenceNodeSubnode v
										 Join QBMDBQueueCurrent p
											 On v.uid_org = p.uid_parameter and p.Slotnumber = v_Slotnumber
										 Join workdeskinbasetree wio
											 On v.uid_suborg = wio.uid_org
											And v.IsAssignmentAllowedWorkDesk = 1
								   Where v_secondary = 1
								  Union All
								  Select Distinct v.uid_org, w.uid_workdesk
									From SDL_VLicenceNodeSubnode v
										 Join QBMDBQueueCurrent p
											 On v.uid_org = p.uid_parameter and p.Slotnumber = v_Slotnumber
										 Join helperworkdeskorg w
											 On v.uid_suborg = w.uid_org
								   Where v_primary = 1) yy
								 On h.uid_workdesk = yy.uid_workdesk
					Group By yy.uid_org, m.uid_licence) zz
			   On basetreeHasLicence.uid_org = zz.uid_org
			  And basetreeHasLicence.uid_licence = zz.uid_licence;

	Cursor LicenceOrgActual1c Is
		Select basetreeHasLicence.uid_licence, basetreeHasLicence.uid_org, zz.anzahl
		  From	   basetreeHasLicence
			   Join
				   (  Select yy.uid_org, m.uid_licence, COUNT(*) As anzahl
						From	 (Select h.uid_hardware, os.uid_licence
									From hardware h Join os On h.UID_OS = os.UID_OS -- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
																					   ) m
							 Join
								 -- die Hardware zur Menge der Orgs bestimmen
								 (Select Distinct v.uid_org, hio.uid_hardware
									From SDL_VLicenceNodeSubnode v
										 Join QBMDBQueueCurrent p
											 On v.uid_org = p.uid_parameter and p.Slotnumber = v_Slotnumber
										 Join hardwareinbasetree hio
											 On v.uid_suborg = hio.uid_org
											And v.IsAssignmentAllowedHardware = 1
								   Where v_secondary = 1
								  Union All
								  Select Distinct v.uid_org, h.uid_hardware
									From SDL_VLicenceNodeSubnode v
										 Join QBMDBQueueCurrent p
											 On v.uid_org = p.uid_parameter and p.Slotnumber = v_Slotnumber
										 Join helperhardwareorg h
											 On v.uid_suborg = h.uid_org
								   Where v_primary = 1) yy
							 On m.uid_hardware = yy.uid_hardware
					Group By yy.uid_org, m.uid_licence) zz
			   On basetreeHasLicence.uid_org = zz.uid_org
			  And basetreeHasLicence.uid_licence = zz.uid_licence;

	-- /die Sonderlocke für die Betriebssysteme
	-- /Buglist 7869

	Cursor LicenceOrgActual2 Is
		Select basetreehaslicence.uid_licence, basetreehaslicence.uid_org, zz.Anzahl
		  From	   basetreeHasLicence
			   Join
				   (  Select yy.uid_org, m.uid_licence, COUNT(*) As anzahl
						From ( -- die Arbeitsplätze und ihre Lizenzen bestimmen
							   -- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
							   Select Distinct r.uid_hardware, ahl.uid_licence
								 From	  (Select ai.UID_ADSAccount As uid_account
												, ai.UID_Application
												, a.UID_HardwareDefaultMachine As uid_hardware
												, a.uid_person
											 From	  adsaccountappsinfo ai
												  Join
													  ADSAccount a
												  On ai.uid_ADSAccount = a.uid_ADSAccount
												 And ai.CurrentlyActive = 1
										) r
									  Join
										  apphaslicence ahl
									  On r.uid_application = ahl.uid_application
									 -- StammPC muß da sein
									 And r.uid_hardware Is Not Null
								Where Not Exists
										  (Select 1
											 From MachineAppsInfo mai
											Where mai.uid_hardware = r.uid_hardware
											  And r.uid_application = mai.uid_application
											  And mai.CurrentlyActive = 1) -- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
																		  ) m
							 Join hardware h
								 On m.uid_hardware = h.uid_hardware
							 Join -- die Arbeitsplätze zur Menge der Orgs bestimmen
								 (Select p.uid_parameter As uid_org, ww.uid_workdesk
									From	 QBMDBQueueCurrent p
										 Join
											 (Select Distinct v.uid_org, wio.uid_workdesk As uid_workdesk
												From SDL_VLicenceNodeSubnode v Join workdeskinbasetree wio On v.uid_suborg = wio.uid_org
											   Where v_secondary = 1
											  Union All
											  Select Distinct v.uid_org, w.uid_workdesk
												From SDL_VLicenceNodeSubnode v Join helperworkdeskorg w On v.uid_suborg = w.uid_org
											   Where v_primary = 1) ww
										 On p.uid_parameter = ww.uid_org and p.Slotnumber = v_Slotnumber
									) yy
								 On h.uid_workdesk = yy.uid_workdesk
					Group By yy.uid_org, m.uid_licence) zz
			   On basetreeHasLicence.uid_org = zz.uid_org
			  And basetreeHasLicence.uid_licence = zz.uid_licence;

	Cursor LicenceOrgActual3 Is
		Select basetreehaslicence.uid_licence, basetreehaslicence.uid_org, zz.Anzahl
		  From	   basetreeHasLicence
			   Join
				   (  Select yy.uid_org, m.uid_licence, COUNT(*) As anzahl
						From	 ( -- die Personen und ihre Lizenzen bestimmen
								   -- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
								   Select Distinct r.uid_Account, ahl.uid_licence, r.uid_person
									 From	  (Select ai.UID_ADSAccount As uid_account
													, ai.UID_Application
													, a.UID_HardwareDefaultMachine As uid_hardware
													, a.uid_person
												 From	  adsaccountappsinfo ai
													  Join
														  ADSAccount a
													  On ai.uid_ADSAccount = a.uid_ADSAccount
													 And ai.CurrentlyActive = 1
											) r
										  Join
											  apphaslicence ahl
										  On r.uid_application = ahl.uid_application -- StammPC ist hier egal
																					--and isnull(r.uid_hardware,'') <> ''
																					-- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
								 ) m
							 Join
								 -- die Personen zur Menge der Orgs bestimmen
								 (Select p.uid_parameter As uid_org, ww.uid_Person
									From	 QBMDBQueueCurrent p
										 Join
											 (Select Distinct v.uid_org, wio.uid_person As uid_Person
												From SDL_VLicenceNodeSubnode v Join Personinbasetree wio On v.uid_suborg = wio.uid_org
											   Where v_secondary = 1
											  Union All
											  Select Distinct v.uid_org, w.uid_Person
												From SDL_VLicenceNodeSubnode v Join HelperPersonOrg w On v.uid_suborg = w.uid_org
											   Where v_primary = 1) ww
										 On p.uid_parameter = ww.uid_org and p.Slotnumber = v_Slotnumber
										) yy
							 On m.uid_Person = yy.uid_Person
					Group By yy.uid_org, m.uid_licence) zz
			   On basetreeHasLicence.uid_org = zz.uid_org
			  And basetreeHasLicence.uid_licence = zz.uid_licence;

	Cursor LicenceOrgActual4 Is
		Select basetreehaslicence.uid_licence, basetreehaslicence.uid_org, zz.Anzahl
		  From	   basetreeHasLicence
			   Join
				   (  Select yy.uid_org, m.uid_licence, COUNT(*) As anzahl
						From	 ( -- die Personen und ihre Lizenzen bestimmen
								   -- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
								   Select Distinct r.uid_account, ahl.uid_licence, r.uid_person
									 From	  (Select ai.UID_ADSAccount As uid_account
													, ai.UID_Application
													, a.UID_HardwareDefaultMachine As uid_hardware
													, a.uid_person
												 From	  adsaccountappsinfo ai
													  Join
														  ADSAccount a
													  On ai.uid_ADSAccount = a.uid_ADSAccount
													 And ai.CurrentlyActive = 1
													 And a.UID_HardwareDefaultMachine Is Null
											) r
										  Join
											  apphaslicence ahl
										  On r.uid_application = ahl.uid_application -- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
																					) m
							 Join
								 -- die Personen zur Menge der Orgs bestimmen
								 (Select p.uid_parameter As uid_org, ww.uid_Person
									From	 QBMDBQueueCurrent p
										 Join
											 (Select Distinct v.uid_org, wio.uid_person As uid_Person
												From	 SDL_VLicenceNodeSubnode v
													 Join
														 Personinbasetree wio
													 On v.uid_suborg = wio.uid_org
													And v_secondary = 1
											  Union All
											  Select Distinct v.uid_org, w.uid_Person
												From	 SDL_VLicenceNodeSubnode v
													 Join
														 helperPersonOrg w
													 On v.uid_suborg = w.uid_org
													And v_primary = 1) ww
										 On p.uid_parameter = ww.uid_org and p.Slotnumber = v_Slotnumber
								) yy
							 On m.uid_Person = yy.uid_Person
					Group By yy.uid_org, m.uid_licence) zz
			   On basetreeHasLicence.uid_org = zz.uid_org
			  And basetreeHasLicence.uid_licence = zz.uid_licence;


begin


	-- die Werte schon mal vorher holen, um sie nicht im Join jedesmal zu ziehen und zu vergleichen
	v_primary := 0;
	v_secondary := 0;
	v_Zaehlweise := 0;

	Begin
		-- Berechnung für eine Menge Orgknoten
		-- Voraussetzung schaffen: fehlende BasetreeHasLicence bauen
		SDL_GDBQueueTasks.PLicenceOrg_Basics (v_SlotNumber);
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		v_Zaehlweise := QBM_GConvert.FStringToInt(QBM_GGetInfo2.FGIConfigParmValue('Software\LicenceManagement\CountOSLicenceBy'), 0);

		If v_Zaehlweise = 0 Then
			v_Zaehlweise := 1;
		End If;
	End;

	Begin
		Select 1
		  Into v_primary
		  From dual
		 Where QBM_GGetInfo2.FGIConfigParmValue('Software\LicenceManagement\LicenceForSubTree\PrimaryAssignment') is not null;
	Exception
		When NO_DATA_FOUND Then
			v_primary := 0;
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		Select 1
		  Into v_secondary
		  From dual
		 Where QBM_GGetInfo2.FGIConfigParmValue('Software\LicenceManagement\LicenceForSubTree\SecondaryAssignment') is not null;
	Exception
		When NO_DATA_FOUND Then
			v_secondary := 0;
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		-- Werte müssen geliefert werden für alle Orgknoten und alle Lizenzen
		-- da das nicht der Fall ist, wird vorher auf 0 zurücksgeset¼t
		Update basetreeHasLicence
		   Set CountLicMacDirectActual = 0
		 Where NVL(CountLicMacDirectActual, 0) <> 0
		   And Exists
				   (Select 1
					  From QBMDBQueueCurrent p
					 Where p.uid_parameter = basetreeHasLicence.uid_org
					 and p.SlotNumber = v_SlotNumber
					 );
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	

	Begin
		-- Lizenzen Ohne Betriebssystem
		Open LicenceOrgActual1;
		Loop
			Fetch LicenceOrgActual1 bulk collect
			Into v_uid_licence_tab, v_uid_org_tab, v_Anzahl_tab limit v_limit;

			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
			Update basetreeHasLicence
			   Set CountLicMacDirectActual = v_Anzahl_tab(i)
			 Where uid_licence = v_uid_licence_tab(i)
			   And uid_org = v_uid_org_tab(i);

			Exit When LicenceOrgActual1%Notfound;
		End Loop;
		Close LicenceOrgActual1;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;




	-- die Sonderlocke für die Betriebssysteme
	If v_Zaehlweise = 1
	Or	v_Zaehlweise = 2 Then -- Workdeskzuordnungen sammeln
		Begin
			Open LicenceOrgActual1a;
			Loop
				Fetch LicenceOrgActual1a bulk collect
				Into v_uid_licence_tab, v_uid_org_tab, v_Anzahl_tab limit v_limit;

				forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
				Update basetreeHasLicence
				   Set CountLicMacDirectActual = CountLicMacDirectActual + v_Anzahl_tab(i)
				 Where uid_licence = v_uid_licence_tab(i)
				   And uid_org = v_uid_org_tab(i);

				Exit When LicenceOrgActual1a%Notfound;
			End Loop;
			Close LicenceOrgActual1a;
		Exception
			When Others Then
				raise_application_error(-20100, 'DatabaseException', True);
		End;
	End If;



	If v_Zaehlweise = 3 Then -- Hardwarezuordnungen sammeln
		Begin
			Open LicenceOrgActual1c;
			Loop
				Fetch LicenceOrgActual1c bulk collect
				Into v_uid_licence_tab, v_uid_org_tab, v_Anzahl_tab limit v_limit;

				forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
				Update basetreeHasLicence
				   Set CountLicMacDirectActual = CountLicMacDirectActual + v_Anzahl_tab(i)
				 Where uid_licence = v_uid_licence_tab(i)
				   And uid_org = v_uid_org_tab(i);

				Exit When LicenceOrgActual1c%Notfound;
			End Loop;
			Close LicenceOrgActual1c;
		Exception
			When Others Then
				raise_application_error(-20100, 'DatabaseException', True);
		End;
	End If;

	--/ die Sonderlocke für die Betriebssysteme


	Begin
		-- für eine Menge Orgs
		Update basetreeHasLicence
		   Set CountLicMacIndirectActual = 0
		 Where NVL(CountLicMacIndirectActual, 0) <> 0
		   And Exists
				   (Select 1
					  From QBMDBQueueCurrent p
					 Where p.uid_parameter = basetreeHasLicence.uid_org
						and p.Slotnumber = v_Slotnumber
					 );
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		Open LicenceOrgActual2;
		Loop
			Fetch LicenceOrgActual2 bulk collect
			Into v_uid_licence_tab, v_uid_org_tab, v_Anzahl_tab limit v_limit;

			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
			Update basetreeHasLicence
			   Set CountLicMacIndirectActual = v_Anzahl_tab(i)
			 Where uid_licence = v_uid_licence_tab(i)
			   And uid_org = v_uid_org_tab(i);

			Exit When LicenceOrgActual2%Notfound;
		End Loop;
		Close LicenceOrgActual2;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		-- für eine Menge Orgs
		Update basetreeHasLicence
		   Set CountLicUserActual = 0
		 Where NVL(CountLicUserActual, 0) <> 0
		   And Exists
				   (Select 1
					  From QBMDBQueueCurrent p
					 Where p.uid_parameter = basetreeHasLicence.uid_org
						and p.Slotnumber = v_Slotnumber
					);
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		Open LicenceOrgActual3;
		Loop
			Fetch LicenceOrgActual3 bulk collect
			Into v_uid_licence_tab, v_uid_org_tab, v_Anzahl_tab limit v_limit;

			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
			Update basetreeHasLicence
			   Set CountLicUserActual = v_Anzahl_tab(i)
			 Where uid_licence = v_uid_licence_tab(i)
			   And uid_org = v_uid_org_tab(i);

			Exit When LicenceOrgActual3%Notfound;
		End Loop;
		Close LicenceOrgActual3;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		-- für eine Menge Orgs
		Update basetreeHasLicence
		   Set CountLicMacPossActual = 0
		 Where NVL(CountLicMacPossActual, 0) <> 0
		   And Exists
				   (Select 1
					  From QBMDBQueueCurrent p
					 Where p.uid_parameter = basetreeHasLicence.uid_org
						and p.Slotnumber = v_Slotnumber
					 );
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		Open LicenceOrgActual4;
		Loop
			Fetch LicenceOrgActual4 bulk collect
			Into v_uid_licence_tab, v_uid_org_tab, v_Anzahl_tab limit v_limit;

			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
			Update basetreeHasLicence
			   Set CountLicMacPossActual = v_Anzahl_tab(i)
			 Where uid_licence = v_uid_licence_tab(i)
			   And uid_org = v_uid_org_tab(i);

			Exit When LicenceOrgActual4%Notfound;
		End Loop;
		Close LicenceOrgActual4;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



end ZLicenceOrgActual;
-----------------------------------------------------------------------------------------------
-- / Procedure ZLicenceOrgActual
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-- Procedure ZLicenceOrgReal
-----------------------------------------------------------------------------------------------
Procedure ZLicenceOrgReal (v_SlotNumber number)
as

	v_Anzahl_tab QBM_GTypeDefinition.YNumberTab := QBM_GTypeDefinition.YNumberTab();
	v_uid_org_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_uid_licence_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_Limit number := 500;


	Cursor LicenceOrgReal1 Is
		Select basetreehaslicence.uid_licence, basetreehaslicence.uid_org, zz.Anzahl
		  From	   basetreeHasLicence
			   Join
				   (  Select yy.uid_org, m.uid_licence, COUNT(*) As anzahl
						From ( -- die Arbeitsplätze und ihre Lizenzen bestimmen
							   -- der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
							   Select mai.uid_Hardware, ahl.uid_licence
								 From	  MachineAppsConfig mai
									  Join
										  apphaslicence ahl
									  On mai.uid_application = ahl.uid_application
									 And mai.AppsNotDriver = 1
									 And mai.CurrentlyActive = 1
							  Union
							  --  2) Treiber an Maschinen zugewiesen
							  Select mai.uid_Hardware, dhl.uid_licence
								From	 MachineAppsConfig mai
									 Join
										 driverhaslicence dhl
									 On mai.uid_driver = dhl.uid_driver
									And NVL(mai.AppsNotDriver, 0) = 0
									And mai.CurrentlyActive = 1 -- OS muß auch als Treiber erkannt werden, zumindest war Softwareinventory mal so gedacht
															   -- \der eigentliche Kern der Bestimmung, der gruppiert werden muß, um auf die Lizenzen zu kommen
							 ) m
							 Join hardware h
								 On m.uid_hardware = h.uid_hardware
							 Join -- die Arbeitsplätze zur Menge der Orgs bestimmen
								 (Select p.uid_parameter As uid_org, ww.uid_workdesk
									From	 QBMDBQueueCurrent p
										 Join
											 (Select Distinct v.uid_org, wio.uid_workdesk As uid_workdesk
												From SDL_VLicenceNodeSubnode v Join workdeskinbasetree wio On v.uid_suborg = wio.uid_org
											   Where QBM_GGetInfo2.FGIConfigParmValue('Software\LicenceManagement\LicenceForSubTree\SecondaryAssignment') is not null
											  Union All
											  Select Distinct v.uid_org, w.uid_workdesk
												From SDL_VLicenceNodeSubnode v Join helperworkdeskorg w On v.uid_suborg = w.uid_org
											   Where QBM_GGetInfo2.FGIConfigParmValue('Software\LicenceManagement\LicenceForSubTree\PrimaryAssignment') is not null
											   ) ww
										 On p.uid_parameter = ww.uid_org and p.slotnumber = v_Slotnumber
									) yy
								 On h.uid_workdesk = yy.uid_workdesk
					Group By yy.uid_org, m.uid_licence) zz
			   On basetreeHasLicence.uid_org = zz.uid_org
			  And basetreeHasLicence.uid_licence = zz.uid_licence;


begin

	Begin
		-- Berechnung für eine Menge Orgknoten
		-- Voraussetzung schaffen: fehlende BasetreeHasLicence bauen
		SDL_GDBQueueTasks.PLicenceOrg_Basics (v_SlotNumber);
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;


	Begin
		-- Werte müssen geliefert werden für alle Orgknoten und alle Lizenzen
		-- da das nicht der Fall ist, wird vorher auf 0 zurücksgesetzt
		Update basetreeHasLicence
		   Set CountLicMacReal = 0
		 Where NVL(CountLicMacReal, 0) <> 0
		   And Exists
				   (Select 1
					  From QBMDBQueueCurrent p
					 Where p.uid_parameter = basetreeHasLicence.uid_org
						and p.slotnumber = v_Slotnumber
					);
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;


	Begin
		Open LicenceOrgReal1;
		Loop
			Fetch LicenceOrgReal1 bulk collect
			Into v_uid_licence_tab, v_uid_org_tab, v_Anzahl_tab limit v_limit;

			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
			Update basetreeHasLicence
			   Set CountLicMacReal = v_Anzahl_tab(i)
			 Where uid_licence = v_uid_licence_tab(i)
			   And uid_org = v_uid_org_tab(i);

			Exit When LicenceOrgReal1%Notfound;
		End Loop;
		Close LicenceOrgReal1;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



end ZLicenceOrgReal;
-----------------------------------------------------------------------------------------------
-- / Procedure ZLicenceOrgReal
-----------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------
-- Procedure PLicenceOrg_Basics
-----------------------------------------------------------------------------------------------
Procedure PLicenceOrg_Basics (v_SlotNumber number)
as

	v_uid_licence			   Licence.UID_Licence%Type;
	v_uid_org				   BaseTree.UID_Org%Type;
	v_GenProcID 			   QBM_GTypeDefinition.YGuid;
	v_validfrom 			   Licence.ValidFrom%Type;
	v_validto				   Licence.ValidTo%Type;
	v_uid_orgroot			   BaseTree.UID_OrgRoot%Type;

	Cursor schritt_basetreehaslicence Is
		Select l.uid_licence
			 , p.uid_parameter
			 , p.GenProcid
			 , l.validfrom
			 , l.validto
			 , b.uid_orgroot
		  From QBMDBQueueCurrent p
			   Cross Join licence l
			   Join basetree b
				   On p.uid_parameter = b.uid_org
			   Join -- wegen Buglist 9266
				   (Select b.uid_org --, b.uid_orgRoot
					  From basetree b Join orgroot r On b.uid_orgRoot = r.uid_orgroot
					 Where Exists
							   (Select 1
								  From dialogtable t
								 Where UPPER(t.TableName) = UPPER(QER_GGetInfo.FGIOrgRootName(b.uid_orgroot)) || 'HASLICENCE'
								   And t.TableType = 'V')) vbt
				   On b.uid_org = vbt.uid_org
		 Where SlotNumber = v_SlotNumber
		 and Not Exists
				   (Select 1
					  From basetreehaslicence bhl
					 Where bhl.uid_org = p.uid_parameter
					   And bhl.uid_licence = l.uid_licence);

	Cursor schritt_basetreehaslicence2 Is
		Select basetreehaslicence.uid_org
		  From basetreehaslicence Join basetree b On basetreehaslicence.uid_org = b.uid_org
		 Where NVL(b.isLicencenode, 0) = 0 -- kein Lizenzknoten
		   And b.uid_parentorg Is Not Null -- und auch kein Wurzelknoten
		   And (NVL(CountLicMacDirectTarget, 0) <> 0
			 Or  NVL(basetreehaslicence.CountLicMacIndirectTarget, 0) <> 0
			 Or  NVL(basetreehaslicence.CountLicUserTarget, 0) <> 0
			 Or  NVL(basetreehaslicence.CountLicMacPossTarget, 0) <> 0
			 Or  NVL(basetreehaslicence.CountLicMacDirectActual, 0) <> 0
			 Or  NVL(basetreehaslicence.CountLicMacIndirectActual, 0) <> 0
			 Or  NVL(basetreehaslicence.CountLicUserActual, 0) <> 0
			 Or  NVL(basetreehaslicence.CountLicMacPossActual, 0) <> 0
			 Or  NVL(basetreehaslicence.CountLicMacReal, 0) <> 0);

	v_uid_org_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_Limit number := 500;



	v_TableName 			   varchar2(64);
	v_BasisObjectKey		   QBM_GTypeDefinition.YObjectKey;
	v_WhereClause			   varchar2(2000);

	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();
Begin
	

	Begin
		Open schritt_basetreehaslicence;

		Loop
			Fetch schritt_basetreehaslicence
			Into v_uid_licence, v_uid_org, v_genprocid, v_validfrom, v_validto, v_uid_orgroot;

			Exit When schritt_basetreehaslicence%Notfound;

			QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

			v_TableName := QER_GGetInfo.FGIOrgRootName(v_uid_orgroot) || 'HasLicence';
			v_BasisObjectKey := QBM_GConvert2.FCVElementToObjectKey(v_TableName
												, 'UID_Licence'
												, v_UID_Licence
												, 'UID_' || QER_GGetInfo.FGIOrgRootName(v_uid_orgroot)
												, v_UID_Org
												, v_noCaseCheck => 1
												 );

			-- wegen 10425 CountLimit mit -1 besetzen
			Insert Into basetreehaslicence(UID_Licence
										 , UID_Org
										 , CountLimit
										 , XDateInserted
										 , XDateUpdated
										 , XUserInserted
										 , XUserUpdated
										 , CountLicMacDirectTarget
										 , CountLicMacIndirectTarget
										 , CountLicUserTarget
										 , CountLicMacPossTarget
										 , CountLicMacDirectActual
										 , CountLicMacIndirectActual
										 , CountLicUserActual
										 , CountLicMacPossActual
										 , CountLicMacReal
										 , validfrom
										 , validto
										 , XObjectKey
										  )
				 Values (v_UID_Licence
					   , v_UID_Org
					   , -1
					   , GetUTCDate
					   , GetUTCDate
					   , 'DBScheduler'
					   , 'DBScheduler'
					   , 0
					   , 0
					   , 0
					   , 0
					   , 0
					   , 0
					   , 0
					   , 0
					   , 0
					   , v_validfrom
					   , v_validto
					   , v_BasisObjectKey
						);

			-- wegen 11702 Templateverarbeitung anschieben
			v_WhereClause := 'XObjectKey = ''' || v_BasisObjectKey || '''';
			QBM_GJobQueue.PJobCreate_HOTemplate_B(v_TableName
										, v_WhereClause
										, v_Columns => '*'
										, v_GenProcID => v_GenProcID
										, v_SingleTransaction => 0
										, v_priority		   => 10
										, v_Retries 		   => 2
										, v_BasisObjectKey	   => v_BasisObjectKey
										, v_CheckForExisting   => 1
										 );
		-- / 11702

		End Loop;

		Close schritt_basetreehaslicence;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		-- alle nicht(mehr) zu füllenden Lizenzknoten Meßergebnisse löschen, sofern welche da sind
		Open schritt_basetreehaslicence2;
		Loop
			Fetch schritt_basetreehaslicence2 bulk collect Into v_uid_org_tab limit v_limit;

			forall i in v_uid_org_tab.first..v_uid_org_tab.last
			Update basetreehaslicence
			   Set CountLicMacDirectTarget = 0
				 , CountLicMacIndirectTarget = 0
				 , CountLicUserTarget = 0
				 , CountLicMacPossTarget = 0
				 , CountLicMacDirectActual = 0
				 , CountLicMacIndirectActual = 0
				 , CountLicUserActual = 0
				 , CountLicMacPossActual = 0
				 , CountLicMacReal = 0
			 Where uid_org = v_uid_org_tab(i);

			Exit When schritt_basetreehaslicence2%Notfound;


		End Loop;
		Close schritt_basetreehaslicence2;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);

end PLicenceOrg_Basics;
-----------------------------------------------------------------------------------------------
-- / Procedure PLicenceOrg_Basics
-----------------------------------------------------------------------------------------------






-----------------------------------------------------------------------------------------------
-- Procedure ZLicenceRecalculate
-----------------------------------------------------------------------------------------------
Procedure ZLicenceRecalculate (v_SlotNumber number
									, v_dummy1 varchar2
									, v_dummy2 varchar2
									, v_GenProcIDDummy varchar2
									)
as
	v_GenProcID QBM_GTypeDefinition.YGuid := newid();
Begin

	QBM_GDBQueue.PDBQueueInsert_Single('QBM-K-CommonReCalculate', 'SDL-K-LicenceCompanyTarget', null, v_GenProcID);
	QBM_GDBQueue.PDBQueueInsert_Single('QBM-K-CommonReCalculate', 'SDL-K-LicenceOrgTarget', null, v_GenProcID);
	QBM_GDBQueue.PDBQueueInsert_Single('QBM-K-CommonReCalculate', 'SDL-K-LicenceCompanyActual', null, v_GenProcID);
	QBM_GDBQueue.PDBQueueInsert_Single('QBM-K-CommonReCalculate', 'SDL-K-LicenceOrgActual', null, v_GenProcID);
	QBM_GDBQueue.PDBQueueInsert_Single('QBM-K-CommonReCalculate', 'SDL-K-LicenceCompanyReal', null, v_GenProcID);
	QBM_GDBQueue.PDBQueueInsert_Single('QBM-K-CommonReCalculate', 'SDL-K-LicenceOrgReal', null, v_GenProcID);




Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);


end ZLicenceRecalculate;
-----------------------------------------------------------------------------------------------
-- / Procedure ZLicenceRecalculate
-----------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------
-- Procedure ZLicenceSubstitute
-----------------------------------------------------------------------------------------------
Procedure ZLicenceSubstitute (v_SlotNumber number
									, v_dummy1 varchar2
									, v_dummy2 varchar2
									, v_GenProcIDDummy varchar2
									)
as

	
	v_sortorder_tab QBM_GTypeDefinition.YNumberTab := QBM_GTypeDefinition.YNumberTab();
	v_uid_licence_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_uid_licencesubstitute_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_uid_grouproot_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_Limit number := 500;
	
	v_GenProcID QBM_GTypeDefinition.YGuid := newid();

	v_treffer				   Number := 0;

	Cursor LicenceSubstitute1 Is
		Select licenceSubstituteTotal.uid_licence, v.uid_grouproot
		  From licenceSubstituteTotal, licenceSubstituteTotal v --Vorgänger
		 Where v.uid_licenceSubstitute = licenceSubstituteTotal.uid_licence
		   And licenceSubstituteTotal.uid_GroupRoot <> v.uid_grouproot;

	Cursor LicenceSubstitute2 Is
		Select licenceSubstituteTotal.uid_licence
			 , licenceSubstituteTotal.uid_licencesubstitute
			 , licenceSubstituteTotal.uid_grouproot
			 , a.GruppenGroesse * b.maxweg + licenceSubstituteTotal.countSteps
		  From licenceSubstituteTotal
			   Join (  Select MAX(CountItems) As GruppenGroesse, uid_groupRoot
						 From (  Select uid_groupRoot, uid_licence, COUNT(*) As CountItems
								   From licenceSubstituteTotal
							   Group By uid_groupRoot, uid_licence) x
					 Group By uid_grouproot) a
				   On licenceSubstituteTotal.uid_groupRoot = a.uid_grouproot
			   Join (  Select uid_groupRoot, uid_licenceSubstitute As uid_licenceWeg, MAX(countSteps) As MaxWeg
						 From licenceSubstituteTotal
					 Group By uid_groupRoot, uid_licenceSubstitute) b
				   On licenceSubstituteTotal.uid_groupRoot = b.uid_groupRoot
				  And licenceSubstituteTotal.uid_licence = b.uid_licenceWeg;

	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();
Begin
	

	Begin
		QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

		Delete licenceSubstituteTotal;

		-- erst mal die rekursive Schlinge in Total
		QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

		Insert Into licenceSubstituteTotal(UID_Licence
										 , UID_LicenceSubstitute
										 , UID_GroupRoot
										 , CountSteps
										 , XObjectKey
										  )
			Select uid_licence
				 , uid_licence
				 , uid_licence
				 , 0
				 , QBM_GConvert2.FCVElementToObjectKey('LicenceSubstituteTotal'
								   , 'UID_Licence'
								   , uid_licence
								   , 'UID_LicenceSubstitute'
								   , uid_licence
								   , v_noCaseCheck => 1
									)
			  From licence;

		-- wenn wir initial alle Lizenzen einfüllen, haben wir das auch für die Auswertung leichter
		-- alle vorgegebenen direkten Kanten
		QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

		Insert Into licenceSubstituteTotal(UID_Licence
										 , UID_LicenceSubstitute
										 , UID_GroupRoot
										 , CountSteps
										 , XObjectKey
										  )
			Select ls.uid_licence
				 , ls.uid_licenceSubstitute
				 , ls.uid_licence
				 , 1
				 , -- gruppe nehmen wir erst mal den Vorgänger an
				  QBM_GConvert2.FCVElementToObjectKey('LicenceSubstituteTotal'
								  , 'UID_Licence'
								  , ls.uid_licence
								  , 'UID_LicenceSubstitute'
								  , ls.uid_licenceSubstitute
								  , v_noCaseCheck => 1
								   )
			  From licenceSubstitute ls
			 Where Not Exists
					   (Select 1
						  From licencesubstituteTotal t
						 Where ls.uid_licence = t.uid_licence
						   And ls.uid_licenceSubstitute = t.uid_licenceSubstitute);
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
	   -- errechnen aller Transitiven Überbrückungen
	   <<marke>>
		QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

		Insert Into licenceSubstituteTotal(UID_Licence
										 , UID_LicenceSubstitute
										 , UID_GroupRoot
										 , CountSteps
										 , XObjectKey
										  )
			Select Distinct c.uid_licence
						  , p.uid_licenceSubstitute
						  , c.uid_licence
						  , c.CountSteps + p.CountSteps
						  , -- gruppe nehmen wir erst mal den Vorgänger an
						   QBM_GConvert2.FCVElementToObjectKey('LicenceSubstituteTotal'
										   , 'UID_Licence'
										   , c.uid_licence
										   , 'UID_LicenceSubstitute'
										   , p.uid_licenceSubstitute
										   , v_noCaseCheck => 1
											)
			  From licenceSubstituteTotal c Join licenceSubstituteTotal p On c.uid_licenceSubstitute = p.uid_licence
			 Where Not Exists
					   (Select 1
						  From licencesubstituteTotal t
						 Where c.uid_licence = t.uid_licence
						   And p.uid_licenceSubstitute = t.uid_licenceSubstitute);

		If Sql%Rowcount > 0 Then
			Goto marke;
		End If;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
	   --uid_GroupRoot korrigieren auf die Wurzel vons janze
	   <<marke2>>
		v_treffer := 0;

		Open LicenceSubstitute1;
		Loop
			Fetch LicenceSubstitute1 bulk collect
			Into v_uid_licence_tab, v_uid_grouproot_tab limit v_limit;

			QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
			Update licenceSubstituteTotal lst
			   Set lst.UID_GroupRoot = v_uid_grouproot_tab(i)
			 Where lst.uid_licence = v_uid_licence_tab(i)
			   And lst.uid_GroupRoot <> v_uid_grouproot_tab(i)
			   -- wegen Buglist 10310
			   -- jedoch nur die, wo der Vorgänger eindeutig wird, also GENAU ein neuer Wert für die GroupRoot ermittelt werden kann
			   And Exists
					   (Select 1
						  From (  Select t.uid_licence As Licence, t.uid_licenceSubstitute As substitute, COUNT(*) As CountNeue
									From licenceSubstituteTotal t, licenceSubstituteTotal v --Vorgänger
								   Where v.uid_licenceSubstitute = t.uid_licence
									 And t.uid_GroupRoot <> v.uid_grouproot
								Group By t.uid_licence, t.uid_licenceSubstitute
								  Having COUNT(*) = 1) x
						 Where x.Licence = lst.uid_licence
						   And x.substitute = lst.uid_licenceSubstitute);

			if v_uid_licence_tab.Count > 0 then
				for i in v_uid_licence_tab.first..v_uid_licence_tab.last loop
					v_treffer := v_treffer + Sql%Bulk_Rowcount(i);
				end loop;
			end if;

			Exit When LicenceSubstitute1%Notfound;

		End Loop;
		Close LicenceSubstitute1;

		If v_treffer > 0 Then
			Goto marke2;
		End If;

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		-- maximale Gruppengröße bestimmen als Multiplikator für Ermittlung der Sortierfolge
		-- maximale Weglänge bis Wurzel, sofern als Nachfolger eingetragen

		Open LicenceSubstitute2;
		Loop
			Fetch LicenceSubstitute2 bulk collect
			Into v_uid_licence_tab, v_uid_licencesubstitute_tab, v_uid_grouproot_tab, v_Sortorder_tab limit v_limit;

			QBM_GCommon.PClientContextSet(v_GenProcID, 'DBScheduler', 1);

			forall i in v_uid_licence_tab.first..v_uid_licence_tab.last
			Update licenceSubstituteTotal
			   Set Sortorder = v_Sortorder_tab(i)
			 Where uid_licence = v_uid_licence_tab(i)
			   And uid_licencesubstitute = v_uid_licencesubstitute_tab(i)
			   And uid_GroupRoot = v_uid_grouproot_tab(i);

			Exit When LicenceSubstitute2%Notfound;


		End Loop;
		Close LicenceSubstitute2;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);

end ZLicenceSubstitute;
-----------------------------------------------------------------------------------------------
-- / Procedure ZLicenceSubstitute
-----------------------------------------------------------------------------------------------






-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- / Licence
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------






-----------------------------------------------------------------------------------------------
-- Procedure ZBaseTreeHasObject
-----------------------------------------------------------------------------------------------
Procedure ZBaseTreeHasObject (v_SlotNumber number)
as


	v_IsSimulationMode		   QBM_GTypeDefinition.YBool;
	v_exists				   QBM_GTypeDefinition.YBool;
	v_uid_org				   QBM_GTypeDefinition.YGuid;
	v_UID_BasetreeHasObject    QBM_GTypeDefinition.YGuid;
	v_genprocid 			   QBM_GTypeDefinition.YGuid;

	-- zu verarbeitende Daten
	v_BeforeQuantity_tab		   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_AfterDirect_tab		   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_AfterInDirect_tab 	   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	-- Ergebnisse
	v_DeltaDelete_tab		QBM_GTypeDefinition.YBaseForDeltaResult := QBM_GTypeDefinition.YBaseForDeltaResult();
	v_DeltaInsert_tab		QBM_GTypeDefinition.YBaseForDeltaResult := QBM_GTypeDefinition.YBaseForDeltaResult();
	v_DeltaOrigin_tab 	   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();
	v_DeltaQuantity_tab		   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	-- für Zwischenergebnisse
	v_Helper_tab			   QBM_GTypeDefinition.YBaseForDelta := QBM_GTypeDefinition.YBaseForDelta();

	Type v_uid_rec Is Record(UID_Org QBM_GTypeDefinition.YGuid, Genprocid QBM_GTypeDefinition.YGuid);
	Type v_uid_tab Is Table Of v_uid_rec;
	v_uid_orgs				   v_uid_tab := v_uid_tab();

	-- Standard-Vorspann für Prozeduren, die die GenProciD setzen
	v_GenProcIDForRestore	   QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUserForRestore		   QBM_GTypeDefinition.YXUser := QBM_GCommon2.FClientContextGetXUser();
	v_OperationLevelForRestore Number := QBM_GCommon2.FClientContextGetOpLevel();
Begin
	

	-- Ergänzung Aufzeichnung
	If QBM_GSimulation.Simulation = 1 Then
		v_IsSimulationMode := 1;
	Else
		v_IsSimulationMode := 0;
	End If;
	--/ Ergänzung Aufzeichnung

	begin
		-- prüfen, ob das betreffende Objekt noch existiert
		QBM_GDBQueue.PSlotResetOnMissingItem(v_SlotNumber, 'BaseTree', 'UID_Org');

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	
	

	Begin
		-- alle bisherigen Zuordnungen des Basetree merken
		Select bho.ObjectKey as AssignedElement, bho.uid_org As Element, bho.InheritInfo As XOrigin, null, x.GenProcID
		  Bulk Collect Into v_BeforeQuantity_tab
		  From BasetreeHasObject bho Join QBMDBQueueCurrent x On bho.uid_Org = x.uid_parameter
		  where x.SlotNumber = v_SlotNumber
		  and (bho.ObjectKey like '<Key><T>Driver</T>%'
				);
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	Begin
		Select a.XObjectKey as AssignedElement, a.uid_org As Element, a.XOrigin As XOrigin, null, a.GenProcID

			Bulk Collect Into v_AfterInDirect_tab
			From (
					
				--BaseTreeHasDriver
				Select y.UID_Org, z.XObjectKey, QER_GConvert.FCVXOriginToInheritInfo(y.XOrigin) as XOrigin, x.GenProcID
					From BaseTreeHasDriver y
						Join QBMDBQueueCurrent x
							On y.UID_Org = x.uid_parameter
						Join Driver z
							On z.uid_Driver = y.uid_Driver
					where SlotNumber = v_SlotNumber
					and y.XOrigin > 0
				) a;
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;




	-----------------------------------------------------------------------
	-- Vergleich der  Mengen vorher und nachher
	-- Veränderungen bestimmen
	-----------------------------------------------------------------------
	Begin
		QBM_GCalculate.PCalculateDelta(v_DeltaQuantity 		 => 1
								 , v_DeltaDelete		 => 1
								 , v_DeltaInsert		 => 1
								 , v_DeltaOrigin		 => 1
							  , v_UseIsInEffect => 0
								 , v_BeforeQuantity_tab	 => v_BeforeQuantity_tab
								 , v_AfterDirect_tab	 => v_AfterDirect_tab
								 , v_AfterInDirect_tab	 => v_AfterInDirect_tab
								 , -- Ergebnisse
								  v_DeltaDelete_tab 	 => v_DeltaDelete_tab
								 , v_DeltaInsert_tab	 => v_DeltaInsert_tab
								 , v_DeltaOrigin_tab	 => v_DeltaOrigin_tab
								 , v_DeltaQuantity_tab 	 => v_DeltaQuantity_tab
								  );


	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;

	Begin
		QER_GCommon.PBaseTreeHasObjectPostProc(v_DeltaOrigin_tab, v_DeltaDelete_tab, v_DeltaInsert_tab);
	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;



	-- Standard-Abspann für Prozeduren, die die GenProciD setzen
	QBM_GCommon.PClientContextSet(v_GenProcIDForRestore, v_XUserForRestore, v_OperationLevelForRestore);

end ZBaseTreeHasObject;
-----------------------------------------------------------------------------------------------
-- / Procedure ZBaseTreeHasObject
-----------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------
-- Procedure ZAllForOneWorkdesk
-----------------------------------------------------------------------------------------------
Procedure ZAllForOneWorkdesk (v_SlotNumber number)
as
	v_exists	QBM_GTypeDefinition.YBool;

     -- für die Folgeaufträge
     v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();

Begin


	Begin
			select x.UID_object, null, x.GenProcID
				bulk collect into v_DBQueueElements
			  From (Select Distinct h.uid_hardware As uid_object, p.GenProcID
					  From QBMDBQueueCurrent p Join hardware h On p.uid_parameter = h.uid_workdesk
					 Where SlotNumber = v_SlotNumber
					 and (h.ispc = 1
						 Or  h.isServer = 1)) x;

		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-HardwareUpdateCNAME', v_DBQueueElements);

	Exception
		When Others Then
			raise_application_error(-20100, 'DatabaseException', True);
	End;




end ZAllForOneWorkdesk;
-----------------------------------------------------------------------------------------------
-- / Procedure ZAllForOneWorkdesk
-----------------------------------------------------------------------------------------------



end SDL_GDBQueueTasks;
go

