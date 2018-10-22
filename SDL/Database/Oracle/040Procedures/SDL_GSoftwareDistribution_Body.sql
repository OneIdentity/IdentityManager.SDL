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






-----------------------------------------------------------------------------------------------
-- SDL_GSoftwareDistribution
-- Package Body
-----------------------------------------------------------------------------------------------


Create Or Replace Package Body SDL_GSoftwareDistribution As





-----------------------------------------------------------------------------------------------
-- Procedure PDistributeAppGroup
-----------------------------------------------------------------------------------------------
Procedure PDistributeAppGroup (v_Groupname varchar2
								, v_domain varchar2
								, v_descript varchar2 := null
								)
as

	-- diese Prozedur wird sowohl aus dem DBScheduler als auch aus Jobs gerufen, daher wird Genprocid aus Context genommen
	v_uidC				QBM_GTypeDefinition.YGuid;
	v_UID_Domain				QBM_GTypeDefinition.YGuid;
	v_displayname		varchar2(255);
	v_configparm		varchar2(255);
	v_uid				QBM_GTypeDefinition.YGuid;
	v_where 			varchar2(255);
	v_SAMAccount		varchar2(255);
	v_tmp				varchar2(255);
	v_zaehl 			Number;
	v_DistinguishedName varchar2(1000);

	v_exists			QBM_GTypeDefinition.YBool;
	v_GenProcID 		QBM_GTypeDefinition.YGuid;
	v_BasisObjectKey	JobQueue.BasisObjectKey%Type;


	v_NumberOfTA		Number := 0; -- Variable für die CountItems der offenen Transaktionen

	v_isADSContainer1	Number := 0;

	Cursor adscontainer1 Is
		Select c1.uid_adscontainer, c1.UID_ADSDomain
		  From adscontainer c1
		 Where c1.isappcontainer = 1
		   -- nicht auf Container, sondern auf Gruppe vergleichen:
		   And Not Exists
				   (Select 1
					  From adsgroup c2
					 Where c2.uid_adscontainer = c1.uid_adsContainer
					   And c2.cn = SDL_GConvert.FCVADSCommonName(v_groupname));

	Cursor adscontainer2 Is
		-- 2007-03-15 not in - Vermeidung
		Select c.uid_adscontainer, d.UID_ADSDomain
		  From adscontainer c join ADSDomain d on c.UID_ADSDomain = d.UID_ADSDomain
		 Where c.isappcontainer = 1
		   And d.Ident_Domain = v_domain
		   And Not Exists
				   (Select 1
					  From adsgroup g
					 Where g.cn = SDL_GConvert.FCVADSCommonName(v_groupname)
					   And g.uid_adscontainer = c.uid_adscontainer);

	v_isLDAPContainer1	Number := 0;

	Cursor ldapcontainer1 Is
		Select c1.uid_ldapcontainer, c1.UID_LDPDomain
		  From ldapcontainer c1
		 Where c1.isappcontainer = 1
		   -- nicht auf Container, sondern auf Gruppe vergleichen:
		   And Not Exists
				   (Select 1
					  From ldapgroup c2
					 Where c2.uid_ldapcontainer = c1.uid_ldapContainer
					   And c2.cn = SDL_GConvert.FCVADSCommonName(v_groupname));

	Cursor ldapcontainer2 Is
		--2007-03-15 not in -Vermeidung
		Select c.uid_ldapcontainer, d.UID_LDPDomain
		  From ldapcontainer c join LDPDomain d on c.UID_LDPDomain = d.UID_LDPDomain
		 Where c.isappcontainer = 1
		   And d.Ident_Domain = v_domain
		   And Not Exists
				   (Select 1
					  From LDAPgroup g
					 Where g.cn = SDL_GConvert.FCVADSCommonName(v_groupname)
					   And g.uid_LDAPcontainer = c.uid_LDAPcontainer);

	v_XDate 			QBM_GTypeDefinition.YXDate := getUTCDate();
	v_XUser 			QBM_GTypeDefinition.YXUser;
Begin

	v_GenProcID := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUser := QBM_GCommon2.FClientContextGetXUser();



	-- Namespace ADS
	v_configparm := QBM_GGetInfo2.FGIConfigParmValue('TargetSystem\ADS');

	If v_configparm = '1' Then
		-- create appsgroup in all domains?
		v_configparm := QBM_GGetInfo2.FGIConfigParmValue('Software\Application\Group\CreateEverywhere');

		If v_configparm = '1' Then
			-- distribute group to all application container in all domains
			v_isADSContainer1 := 1;
			Open adscontainer1;
		Else
			-- distribute group to all application container in this domain
			v_isADSContainer1 := 0;
			Open adscontainer2;
		End If;


		Loop
			If v_IsADSContainer1 = 1 Then
				Fetch adscontainer1 Into v_uidC, v_UID_Domain;
				Exit When adscontainer1%Notfound;
			Else
				Fetch adscontainer2 Into v_uidC, v_UID_Domain;
				Exit When adscontainer2%Notfound;
			End If;

			-- get unique SAMAccountName in domain
			v_tmp := v_groupname;
			v_zaehl := 0;

			Select COUNT(*)
			  Into v_exists
			  From ADSGroup
			 Where UID_ADSContainer In (Select UID_ADSContainer
										  From ADSContainer
										 Where UID_ADSDomain = (Select UID_ADSDomain
																 From ADSContainer
																Where UID_ADSContainer = v_uidC))
			   And SAMAccountName = v_tmp;

			While v_exists > 0 Loop
				v_zaehl := v_zaehl + 1;
				v_tmp := v_groupname || '_' || to_char(v_zaehl);

				Select COUNT(*)
				  Into v_exists
				  From ADSGroup
				 Where UID_ADSContainer In (Select UID_ADSContainer
											  From ADSContainer
											 Where UID_ADSDomain = (Select UID_ADSDomain
																	 From ADSContainer
																	Where UID_ADSContainer = v_uidC))
				   And SAMAccountName = v_tmp;
			End Loop;

			v_SAMAccount := v_tmp;
			v_uid := newid();

			-- wegen Buglist 4341:
			Begin
				Select 'CN=' || v_groupname || ',' || DistinguishedName
				  Into v_DistinguishedName
				  From adscontainer
				 Where uid_adscontainer = v_uidC;
			Exception
				When NO_DATA_FOUND Then
					Null;
			End;

			Insert Into ADSGroup(canonicalname
							   , UID_ADSGroup
							   , UID_ADSContainer
							   , cn
							   , DistinguishedName
							   , Description
							   , SAMAccountName
							   , IsGlobal
							   , IsSecurity
							   , IsApplicationGroup
							   , XObjectKey
							   , xuserinserted
							   , XUserupdated
							   , Xdateinserted
							   , xdateupdated
							   -- 14807
							   , Displayname
							   , UID_ADSDomain
							   , ObjectClass
								, StructuralObjectClass
								)
				Select SDL_GConvert.FCVDNToCanonical(v_DistinguishedName)
					 , v_uid
					 , v_uidC
					 , SDL_GConvert.FCVADSCommonName(v_groupname)
					 , SDL_GConvert.FCVADSDistinguishedName(v_DistinguishedName)
					 , TO_CLOB(v_descript)
					 , v_SAMAccount
					 , 1
					 , 1
					 , 1
					 , QBM_GConvert2.FCVElementToObjectKey('ADSGroup', 'UID_ADSGroup', v_uid, v_noCaseCheck => 1)
					 , v_XUser
					 , v_XUser
					 , v_Xdate
					 , v_Xdate
					 , v_groupname
					 , v_UID_Domain
					 , 'GROUP'
					, 'GROUP'
				  From DUAL
				 -- Buglist 13584 Vermeidung von doppelten bei Parallelaufruf
				 Where Not Exists
						   (Select 1
							  From ADSGroup
							 Where UID_ADSContainer = v_uidC
							   And cn = SDL_GConvert.FCVADSCommonName(v_groupname)
							   And DistinguishedName = SDL_GConvert.FCVADSDistinguishedName(v_DistinguishedName));

			If Sql%Rowcount > 0 Then
				v_where := 'UID_ADSGroup=''' || v_uid || '''';
				v_BasisObjectKey := QBM_GConvert2.FCVElementToObjectKey('ADSGroup', 'UID_ADSgroup', v_uid, v_noCaseCheck => 1);
				QBM_GJobQueue.PJobCreate_HOFireEvent('ADSGROUP'
											, v_where
											, 'INSERT', v_GenProcID
											, v_checkForExisting => 1
											, v_BasisObjectKey	 => v_BasisObjectKey
											 );
			End If;
		End Loop;

		If v_IsADSContainer1 = 1 Then
			Close adscontainer1;
		Else
			Close adscontainer2;
		End If;
	End If;

	-- Namespace LDAP
	v_configparm := QBM_GGetInfo2.FGIConfigParmValue('TargetSystem\LDAP');

	If v_configparm = '1' Then
		-- create appsgroup in all domains?
		v_configparm := QBM_GGetInfo2.FGIConfigParmValue('Software\Application\Group\CreateEverywhere');

		If v_configparm = '1' Then
			-- distribute group to all application container in all domains
			v_isLDAPContainer1 := 1;

			Open ldapcontainer1;
		Else
			-- distribute group to all application container in this domain
			v_isLDAPContainer1 := 0;

			Open ldapcontainer2;
		End If;

		Loop
			If v_IsLDAPContainer1 = 1 Then
				Fetch ldapcontainer1 Into v_uidC, v_UID_Domain;

				Exit When ldapcontainer1%Notfound;
			Else
				Fetch ldapcontainer2 Into v_uidC, v_UID_Domain;

				Exit When ldapcontainer2%Notfound;
			End If;

			v_uid := newid();

			Begin
				Select 'CN=' || v_groupname || ',' || DistinguishedName
				  Into v_DistinguishedName
				  From ldapcontainer
				 Where uid_ldapcontainer = v_uidC;
			Exception
				When NO_DATA_FOUND Then
					Null;
			End;

			Insert Into LDAPGroup(UID_LDAPGroup
								, UID_LDAPContainer
								, cn
								, DistinguishedName
								, Description
								, IsApplicationGroup
								, Objectclass
								, XObjectKey
								, xuserinserted
								, XUserupdated
								, Xdateinserted
								, xdateupdated
							   -- 14807
							   , Displayname
							   , UID_LDPDomain
								 )
				Select v_uid
					 , v_uidC
					 , SDL_GConvert.FCVADSCommonName(v_groupname)
					 , SDL_GConvert.FCVADSDistinguishedName(v_DistinguishedName)
					 , TO_CLOB(v_descript)
					 , 1
					 , 'GroupOfNames'
					 , QBM_GConvert2.FCVElementToObjectKey('LDAPGroup', 'UID_LDAPGroup', v_uid, v_noCaseCheck => 1)
					 , v_XUser
					 , v_XUser
					 , v_Xdate
					 , v_Xdate
					 , v_groupname
					 , v_UID_Domain
				  From DUAL
				 -- Buglist 13584 Vermeidung von doppelten bei Parallelaufruf
				 Where Not Exists
						   (Select 1
							  From LDAPGroup
							 Where UID_LDAPContainer = v_uidC
							   And cn = SDL_GConvert.FCVADSCommonName(v_groupname)
							   And DistinguishedName = SDL_GConvert.FCVADSDistinguishedName(v_DistinguishedName));

			If Sql%Rowcount > 0 Then
				v_where := 'UID_LDAPGroup=''' || v_uid || '''';
				v_BasisObjectKey := QBM_GConvert2.FCVElementToObjectKey('LDAPGroup', 'UID_LDAPGroup', v_uid, v_noCaseCheck => 1);
				QBM_GJobQueue.PJobCreate_HOFireEvent('LDAPGROUP'
											, v_where
											, 'INSERT', v_GenProcID
											, v_checkForExisting => 1
											, v_BasisObjectKey	 => v_BasisObjectKey
											 );
			End If;
		End Loop;

		If v_IsLDAPContainer1 = 1 Then
			Close ldapcontainer1;
		Else
			Close ldapcontainer2;
		End If;
	End If;

	Commit;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);


End PDistributeAppGroup;
-----------------------------------------------------------------------------------------------
-- / Procedure PDistributeAppGroup
-----------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------
-- Procedure PRepairAppServerGotXX
-- auffüllen der AppserverGot xx  - Tabellen, mit allen Zuordnungen, die der FDS hat,
-- die in den darunterliegenden Servern jedoch nicht vorhanden sind.
-----------------------------------------------------------------------------------------------
Procedure PRepairAppServerGotXX (v_ident_domain varchar2 := null -- wenn angegeben, wird nur für diese Domäne Reparatur ausgeführt
								, v_type varchar2 := null -- wenn angegeben, wird nur für den Type die Reparatur ausgeführt
															-- zulässig sind APP, DRV und MAC
								)
as


	v_intern_domain 		varchar2(64);
	v_uid_applicationserver QBM_GTypeDefinition.YGuid;
	v_intern_type			varchar2(64);

	Cursor schrittRepairAppServerGotXX Is
		Select uid_applicationserver
		  From applicationserver
		 Where uid_parentapplicationserver Is Null
		   And UPPER(Ident_Domain) Like UPPER(v_intern_domain);
-- Variable für die CountItems der offenen Transaktionen

Begin
	If RTRIM(v_ident_Domain) Is Null Then
		v_intern_domain := '%';
	Else
		v_intern_domain := v_ident_domain;
	End If;

	If RTRIM(v_type) Is Null Then
		v_intern_type := 'APP DRV MAC';
	Else
		v_intern_type := v_type;
	End If;

	-- bestimme alle fds
	-- Aufräumen von Profilinformationen, zu denen es die Profile nicht (mehr) gibt
	If UPPER(v_intern_type) Like '%APP%' Then
		Delete appservergotappprofile
		 Where uid_profile Not In (Select uid_profile From applicationprofile)
		   And uid_profile In (Select uid_profile
								 From applicationprofile
								Where UPPER(Ident_DomainRD) Like UPPER(v_intern_domain));
	End If;

	If UPPER(v_intern_type) Like '%DRV%' Then
		Delete appservergotdriverprofile
		 Where uid_profile Not In (Select uid_profile From driverprofile)
		   And uid_profile In (Select uid_profile
								 From driverprofile
								Where UPPER(Ident_DomainRD) Like UPPER(v_intern_domain));
	End If;

	If UPPER(v_intern_type) Like '%MAC%' Then
		Delete appservergotmactypeinfo
		 Where UID_MachineType Not In (Select UID_MachineType From machinetype)
		   And UID_MachineType In (Select UID_MachineType
									 From machinetype
									Where UPPER(Ident_DomainMachineType) Like UPPER(v_intern_domain));
	End If;

	-- Aufräumen von Profilinformationen, zu denen es die Applikationsserver nicht (mehr) gibt
	If UPPER(v_intern_type) Like '%APP%' Then
		Delete appservergotappprofile
		 Where UID_ApplicationServer Not In (Select UID_ApplicationServer From Applicationserver)
		   And uid_profile In (Select uid_profile
								 From applicationprofile
								Where UPPER(Ident_DomainRD) Like UPPER(v_intern_domain));
	End If;

	If UPPER(v_intern_type) Like '%DRV%' Then
		Delete appservergotdriverprofile
		 Where UID_ApplicationServer Not In (Select UID_ApplicationServer From Applicationserver)
		   And uid_profile In (Select uid_profile
								 From driverprofile
								Where UPPER(Ident_DomainRD) Like UPPER(v_intern_domain));
	End If;

	If UPPER(v_intern_type) Like '%MAC%' Then
		Delete appservergotmactypeinfo
		 Where UID_ApplicationServer Not In (Select UID_ApplicationServer From Applicationserver)
		   And UID_MachineType In (Select UID_MachineType
									 From machinetype
									Where UPPER(Ident_DomainMachineType) Like UPPER(v_intern_domain));
	End If;

	-- alle FDS bestimmen und einzeln verarbeiten
	Open schrittRepairAppServerGotXX;

	Loop
		Fetch schrittRepairAppServerGotXX Into v_uid_applicationserver;

		Exit When schrittRepairAppServerGotXX%Notfound;

		Delete temp_childserver;

		-- je FDS alle darunter hängenden Applikationsserver einsammeln
		Insert Into Temp_ChildServer(uid_childserver)
				Select uid_applicationserver
				  From applicationserver
			Connect By Prior uid_applicationserver = uid_parentapplicationserver
			Start With uid_applicationserver = v_uid_applicationserver;

		-- alle darunterhängenden Applikationsserver sollten eingesammelt sein

		If UPPER(v_intern_type) Like '%APP%' Then
			-- print ' die aufzufüllenden Applikationen'
			Insert Into appservergotappprofile(UID_ApplicationServer
											 , UID_Profile
											 , XDateInserted
											 , XDateUpdated
											 , XUserInserted
											 , XUserUpdated
											 , ChgNumber
											 , -- IsReady,
											  ProfileStateProduction
											 , ProfileStateShadow
											 , XObjectKey
											  )
				Select c.uid_childserver
					 , g.uid_profile
					 , GetUTCDate
					 , GetUTCDate
					 , 'RepairAppServer'
					 , 'RepairAppServer'
					 , 0
					 , -- 1,
					  'READY'
					 , 'EMPTY'
					 , QBM_GConvert2.FCVElementToObjectKey('AppServerGotAppProfile'
									   , 'UID_ApplicationServer'
									   , c.uid_childserver
									   , 'UID_Profile'
									   , g.uid_profile
									   , v_noCaseCheck => 1
										)
				  From temp_childserver c, appservergotappprofile g
				 Where g.uid_applicationserver = v_uid_applicationserver
				   And Not Exists
						   (Select 1
							  From appservergotappprofile a
							 Where c.uid_childserver = a.uid_applicationserver
							   And g.uid_profile = a.uid_profile)
				   And Exists
						   (Select 1
							  From applicationprofile z
							 Where z.uid_profile = g.uid_profile
							   And NVL(chgnumber, 0) > 0);
		End If;

		If UPPER(v_intern_type) Like '%DRV%' Then
			-- print ' die aufzufüllenden Treiber'
			Insert Into appservergotdriverprofile(UID_ApplicationServer
												, UID_Profile
												, XDateInserted
												, XDateUpdated
												, XUserInserted
												, XUserUpdated
												, ChgNumber
												, -- IsReady,
												 ProfileStateProduction
												, ProfileStateShadow
												, XObjectKey
												 )
				Select c.uid_childserver
					 , g.uid_profile
					 , GetUTCDate
					 , GetUTCDate
					 , 'RepairAppServer'
					 , 'RepairAppServer'
					 , 0
					 , -- 1,
					  'READY'
					 , 'EMPTY'
					 , QBM_GConvert2.FCVElementToObjectKey('AppServerGotDriverProfile'
									   , 'UID_ApplicationServer'
									   , c.uid_childserver
									   , 'UID_Profile'
									   , g.uid_profile
									   , v_noCaseCheck => 1
										)
				  From temp_childserver c, appservergotdriverprofile g
				 Where g.uid_applicationserver = v_uid_applicationserver
				   And Not Exists
						   (Select 1
							  From appservergotdriverprofile a
							 Where c.uid_childserver = a.uid_applicationserver
							   And g.uid_profile = a.uid_profile)
				   And Exists
						   (Select 1
							  From driverprofile z
							 Where z.uid_profile = g.uid_profile
							   And NVL(chgnumber, 0) > 0);
		End If;

		If UPPER(v_intern_type) Like '%MAC%' Then
			-- print ' die aufzufüllenden Maschinentypen'
			Insert Into appservergotmactypeinfo(UID_ApplicationServer
											  , UID_MachineType
											  , XDateInserted
											  , XDateUpdated
											  , XUserInserted
											  , XUserUpdated
											  , ChgNumber
											  , -- IsReady,
											   ProfileStateProduction
											  , ProfileStateShadow
											  , XObjectKey
											   )
				Select c.uid_childserver
					 , g.UID_MachineType
					 , GetUTCDate
					 , GetUTCDate
					 , 'RepairAppServer'
					 , 'RepairAppServer'
					 , 0
					 , -- 1,
					  'READY'
					 , 'EMPTY'
					 , QBM_GConvert2.FCVElementToObjectKey('AppServerGotMactypeInfo'
									   , 'UID_ApplicationServer'
									   , c.uid_childserver
									   , 'UID_MachineType'
									   , g.UID_MachineType
									   , v_noCaseCheck => 1
										)
				  From temp_childserver c, appservergotmactypeinfo g
				 Where g.uid_applicationserver = v_uid_applicationserver
				   And Not Exists
						   (Select 1
							  From appservergotmactypeinfo a
							 Where c.uid_childserver = a.uid_applicationserver
							   And g.UID_MachineType = a.UID_MachineType)
				   And Exists
						   (Select 1
							  From machinetype z
							 Where z.uid_machinetype = g.uid_machinetype
							   And NVL(chgnumber, 0) > 0);
		End If;
	End Loop;

	Close schrittRepairAppServerGotXX;

	Commit;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);

End PRepairAppServerGotXX;
-----------------------------------------------------------------------------------------------
-- / Procedure PRepairAppServerGotXX
-----------------------------------------------------------------------------------------------






-----------------------------------------------------------------------------------------------
-- Procedure PInsertInAppServerGotMac
-----------------------------------------------------------------------------------------------
Procedure PInsertInAppServerGotMac (v_uid_appserver			 varchar2
									, v_uid_machinetype		 varchar2
									, v_chgnumber				 Number
									, v_ProfileStateProduction  varchar2
									, v_ProfileStateShadow 	 varchar2
									)
as

	v_exists QBM_GTypeDefinition.YBool;
Begin
	Begin
		v_exists := 0;

		Select 1
		  Into v_exists
		  From DUAL
		 Where Exists
				   (Select 1
					  From AppServerGotMactypeInfo
					 Where UID_ApplicationServer = v_uid_appserver
					   And uid_MachineType = v_uid_machinetype);
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
	End;

	If v_exists = 0 Then
		Insert Into AppServerGotMacTypeInfo(UID_ApplicationServer
										  , UID_MachineType
										  , ChgNumber
										  , ProfileStateProduction
										  , ProfileStateShadow
										  , XDateInserted
										  , XDateUpdated
										  , XUserInserted
										  , XUserUpdated
										  , XObjectKey
										   )
			 Values (v_uid_appserver
				   , v_uid_machinetype
				   , v_chgnumber
				   , v_ProfileStateProduction
				   , v_ProfileStateShadow
				   , GetUTCDate
				   , GetUTCDate
				   , 'ProfileCopy'
				   , 'ProfileCopy'
				   , QBM_GConvert2.FCVElementToObjectKey('AppServerGotMactypeInfo'
									 , 'UID_ApplicationServer'
									 , v_uid_appserver
									 , 'UID_MachineType'
									 , v_uid_machinetype
									 , v_noCaseCheck => 1
									  )
					);
	Else
		Update AppServerGotMacTypeInfo
		   Set chgnumber = v_chgnumber
			 , ProfileStateProduction = v_ProfileStateProduction
			 , ProfileStateShadow = v_ProfileStateShadow
			 , xdateupdated = GetUTCDate
			 , XuserUpdated = 'ProfileCopy'
		 Where UID_ApplicationServer = v_uid_appserver
		   And UID_MachineType = v_uid_machinetype;
	End If;

	Commit;

Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);

End PInsertInAppServerGotMac;
-----------------------------------------------------------------------------------------------
-- / Procedure PInsertInAppServerGotMac
-----------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------
-- Procedure PInsertInAppServerGotDrv
-- in abhängigkeit der existenz, eintrag/update eines profiles für einen appserver in appservergotdriverprofile
-----------------------------------------------------------------------------------------------
Procedure PInsertInAppServerGotDrv (v_uid_appserver			 varchar2
									, v_Profile		 varchar2
									, v_chgnumber				 Number
									, v_ProfileStateProduction  varchar2
									, v_ProfileStateShadow 	 varchar2
									)
as


	v_exists QBM_GTypeDefinition.YBool;
Begin
	Begin
		v_exists := 0;

		Select 1
		  Into v_exists
		  From DUAL
		 Where Exists
				   (Select 1
					  From AppServerGotDriverProfile
					 Where UID_ApplicationServer = v_uid_appserver
					   And UID_Profile = v_Profile);
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
	End;

	If v_exists = 0 Then
		Insert Into AppServerGotDriverProfile(UID_ApplicationServer
											, UID_Profile
											, ChgNumber
											, ProfileStateProduction
											, ProfileStateShadow
											, XDateInserted
											, XDateUpdated
											, XUserInserted
											, XUserUpdated
											, XObjectKey
											 )
			 Values (v_uid_appserver
				   , v_Profile
				   , v_chgnumber
				   , v_ProfileStateProduction
				   , v_ProfileStateShadow
				   , GetUTCDate
				   , GetUTCDate
				   , 'ProfileCopy'
				   , 'ProfileCopy'
				   , QBM_GConvert2.FCVElementToObjectKey('AppServerGotDriverProfile'
									 , 'UID_ApplicationServer'
									 , v_uid_appserver
									 , 'UID_Profile'
									 , v_Profile
									 , v_noCaseCheck => 1
									  )
					);
	Else
		Update AppServerGotDriverProfile
		   Set chgnumber = v_chgnumber
			 , ProfileStateProduction = v_ProfileStateProduction
			 , ProfileStateShadow = v_ProfileStateShadow
			 , xdateupdated = GetUTCDate
			 , XuserUpdated = 'ProfileCopy'
		 Where UID_ApplicationServer = v_uid_appserver
		   And UID_Profile = v_Profile;
	End If;

	Commit;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);


End PInsertInAppServerGotDrv;
-----------------------------------------------------------------------------------------------
-- / Procedure PInsertInAppServerGotDrv
-----------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------
-- Procedure PInsertInAppServerGotApp
-- in abhängigkeit der existenz, eintrag/update eines profiles für einen appserver in appservergotappprofile
-----------------------------------------------------------------------------------------------
Procedure PInsertInAppServerGotApp (v_uid_appserver			 varchar2
									, v_Profile		 varchar2
									, v_chgnumber				 Number
									, v_ProfileStateProduction  varchar2
									, v_ProfileStateShadow 	 varchar2
									)
as

	v_exists QBM_GTypeDefinition.YBool;
Begin
	Begin
		v_exists := 0;

		Select 1
		  Into v_exists
		  From DUAL
		 Where Exists
				   (Select 1
					  From AppServerGotAppProfile
					 Where UID_ApplicationServer = v_uid_appserver
					   And UID_Profile = v_Profile);
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
	End;

	If v_exists = 0 Then
		Insert Into AppServerGotAppProfile(UID_ApplicationServer
										 , UID_Profile
										 , ChgNumber
										 , ProfileStateProduction
										 , ProfileStateShadow
										 , XDateInserted
										 , XDateUpdated
										 , XUserInserted
										 , XUserUpdated
										 , XObjectKey
										  )
			 Values (v_uid_appserver
				   , v_Profile
				   , v_chgnumber
				   , v_ProfileStateProduction
				   , v_ProfileStateShadow
				   , GetUTCDate
				   , GetUTCDate
				   , 'ProfileCopy'
				   , 'ProfileCopy'
				   , QBM_GConvert2.FCVElementToObjectKey('AppServerGotAppProfile'
									 , 'UID_ApplicationServer'
									 , v_uid_appserver
									 , 'UID_Profile'
									 , v_Profile
									 , v_noCaseCheck => 1
									  )
					);
	Else
		Update AppServerGotAppProfile
		   Set chgnumber = v_chgnumber
			 , ProfileStateProduction = v_ProfileStateProduction
			 , ProfileStateShadow = v_ProfileStateShadow
			 , xdateupdated = GetUTCDate
			 , XuserUpdated = 'ProfileCopy'
		 Where UID_ApplicationServer = v_uid_appserver
		   And UID_Profile = v_Profile;
	End If;

	Commit;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);



End PInsertInAppServerGotApp;
-----------------------------------------------------------------------------------------------
-- / Procedure PInsertInAppServerGotApp
-----------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------
-- Procedure PFillPAS
-----------------------------------------------------------------------------------------------
Procedure PFillPAS (v_appserver varchar2)
as

	v_txt			  varchar2(255);
	v_server		  varchar2(85);
	v_apps			  varchar2(85);
	v_drv			  varchar2(85);
	v_uid_mactype	  QBM_GTypeDefinition.YGuid;
	v_chg			  Number;
	v_count 		  Number;

	v_where 		  varchar2(255);
	v_exists		  QBM_GTypeDefinition.YBool;
	v_GenProcID 	  QBM_GTypeDefinition.YGuid;
	v_BasisObjectKey  JobQueue.BasisObjectKey%Type;

	Cursor schritt1 Is
		Select UID_Profile, chgnumber
		  From appservergotappprofile
		 Where uid_applicationserver = v_server;

	Cursor schritt2 Is
		Select UID_Profile, chgnumber
		  From appservergotdriverprofile
		 Where uid_applicationserver = v_server;

	Cursor schritt3 Is
		Select uid_MachineType, chgnumber
		  From appservergotmactypeinfo
		 Where uid_applicationserver = v_server;

	v_XUser 		  QBM_GTypeDefinition.YXUser;
Begin

	v_GenProcID := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUser := QBM_GCommon2.FClientContextGetXUser();



	-- den Parent_AppsServer selektieren
	Begin
		Select UID_ParentApplicationServer
		  Into v_server
		  From applicationserver
		 Where UID_ApplicationServer = v_appserver;
	Exception
		When NO_DATA_FOUND Then
			v_server := Null;
	End;

	-- alle Applikationen dieses ParentServers selektieren
	Open schritt1;

	Loop
		Fetch schritt1
		Into v_apps, v_chg;

		Exit When schritt1%Notfound;

		Begin
			Select 1
			  Into v_exists
			  From DUAL
			 Where Exists
					   (Select 1
						  From AppServerGotAppProfile
						 Where UID_ApplicationServer = RTRIM(v_appserver)
						   And UID_Profile = RTRIM(v_apps));
		Exception
			When NO_DATA_FOUND Then
				v_exists := 0;
		End;

		If v_exists = 0 Then
			Insert Into AppServerGotAppProfile(UID_ApplicationServer
											 , UID_Profile
											 , ChgNumber
											 , ProfileStateProduction
											 , XDateInserted
											 , XDateUpdated
											 , XUserInserted
											 , XUserUpdated
											 , XObjectKey
											  )
				 Values (RTRIM(v_appserver)
					   , RTRIM(v_apps)
					   , v_chg
					   , 'EMPTY'
					   , GetUTCDate
					   , GetUTCDate
					   , 'sa'
					   , 'sa'
					   , QBM_GConvert2.FCVElementToObjectKey('AppServerGotAppProfile'
										 , 'UID_ApplicationServer'
										 , v_appserver
										 , 'UID_Profile'
										 , v_apps
										 , v_noCaseCheck => 1
										  )
						);

			v_where := 'UID_ApplicationServer = ''' || RTRIM(v_appserver) || ''' and UID_Profile = ''' || RTRIM(v_apps) || ''' ';
			v_BasisObjectKey := QBM_GConvert2.FCVElementToObjectKey('AppServerGotAppProfile'
												, 'UID_ApplicationServer'
												, v_appserver
												, 'UID_Profile'
												, v_apps
												, v_noCaseCheck => 1
												 );
			QBM_GJobQueue.PJobCreate_HOFireEvent('AppServerGotAppProfile'
										, v_where
										, 'Copy2PAS'
										, v_GenProcID
										, v_BasisObjectKey	 => v_BasisObjectKey
										 );
		End If;
	End Loop;

	Close schritt1;

	-- alle Driver dieses ParentServers selektieren
	Open schritt2;

	Loop
		Fetch schritt2
		Into v_drv, v_chg;

		Exit When schritt2%Notfound;

		Begin
			Select 1
			  Into v_exists
			  From DUAL
			 Where Exists
					   (Select 1
						  From AppServerGotDriverProfile
						 Where UID_ApplicationServer = RTRIM(v_appserver)
						   And UID_Profile = RTRIM(v_drv));
		Exception
			When NO_DATA_FOUND Then
				v_exists := 0;
		End;

		If v_exists = 0 Then
			Insert Into AppServerGotDriverProfile(UID_ApplicationServer
												, UID_Profile
												, ChgNumber
												, ProfileStateProduction
												, XDateInserted
												, XDateUpdated
												, XUserInserted
												, XUserUpdated
												, XObjectKey
												 )
				 Values (RTRIM(v_appserver)
					   , RTRIM(v_drv)
					   , v_chg
					   , 'EMPTY'
					   , GetUTCDate
					   , GetUTCDate
					   , 'sa'
					   , 'sa'
					   , QBM_GConvert2.FCVElementToObjectKey('AppServerGotDriverProfile'
										 , 'UID_ApplicationServer'
										 , v_appserver
										 , 'UID_Profile'
										 , v_drv
										 , v_noCaseCheck => 1
										  )
						);

			v_where := 'UID_ApplicationServer = ''' || RTRIM(v_appserver) || ''' and UID_Profile = ''' || RTRIM(v_drv) || ''' ';
			v_BasisObjectKey := QBM_GConvert2.FCVElementToObjectKey('AppServerGotDriverProfile'
												, 'UID_ApplicationServer'
												, v_appserver
												, 'UID_Profile'
												, v_drv
												, v_noCaseCheck => 1
												 );
			QBM_GJobQueue.PJobCreate_HOFireEvent('AppServerGotDriverProfile'
										, v_where
										, 'Copy2PAS'
										, v_GenProcID
										, v_BasisObjectKey	 => v_BasisObjectKey
										 );
		End If;
	End Loop;

	Close schritt2;

	-- alle Mactypes dieses ParentServers selektieren
	Open schritt3;

	Loop
		Fetch schritt3
		Into v_uid_mactype, v_chg;

		Exit When schritt3%Notfound;

		Begin
			Select 1
			  Into v_exists
			  From DUAL
			 Where Exists
					   (Select 1
						  From AppServerGotMacTypeInfo
						 Where UID_ApplicationServer = RTRIM(v_appserver)
						   And UID_MachineType = RTRIM(v_uid_mactype));
		Exception
			When NO_DATA_FOUND Then
				v_exists := 0;
		End;

		If v_exists = 0 Then
			Insert Into AppServerGotMacTypeInfo(UID_ApplicationServer
											  , UID_MachineType
											  , ChgNumber
											  , ProfileStateProduction
											  , XDateInserted
											  , XDateUpdated
											  , XUserInserted
											  , XUserUpdated
											  , XObjectKey
											   )
				 Values (RTRIM(v_appserver)
					   , RTRIM(v_uid_mactype)
					   , (v_chg * (-1))
					   , 'EMPTY'
					   , --v_chg * (-1) für MakeFullCopy
						GetUTCDate
					   , GetUTCDate
					   , 'sa'
					   , 'sa'
					   , QBM_GConvert2.FCVElementToObjectKey('AppServerGotMactypeInfo'
										 , 'UID_ApplicationServer'
										 , v_appserver
										 , 'UID_MachineType'
										 , v_uid_mactype
										 , v_noCaseCheck => 1
										  )
						);

			v_where := 'UID_ApplicationServer = ''' || RTRIM(v_appserver) || ''' and UID_MachineType = ''' || RTRIM(v_uid_mactype) || ''' ';
			v_BasisObjectKey := QBM_GConvert2.FCVElementToObjectKey('AppServerGotMactypeInfo'
												, 'UID_ApplicationServer'
												, v_appserver
												, 'UID_MachineType'
												, v_uid_mactype
												, v_noCaseCheck => 1
												 );
			QBM_GJobQueue.PJobCreate_HOFireEvent('AppServerGotMacTypeInfo'
										, v_where
										, 'Copy2PAS'
										, v_GenProcID
										, v_BasisObjectKey	 => v_BasisObjectKey
										 );
		End If;
	End Loop;

	Close schritt3;

	Commit;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);


End PFillPAS;
-----------------------------------------------------------------------------------------------
-- / Procedure PFillPAS
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-- Procedure PDeleteDrvProfileForAllChild
-- generiert Löschaufträge für alle untergeordneten AppServer für Job in AppServerGotDriverProfile
-----------------------------------------------------------------------------------------------
Procedure PDeleteDrvProfileForAllChild (v_uid_appserver varchar2
										, v_Profile varchar2
										)
as

	v_serv			 QBM_GTypeDefinition.YGuid;
	v_txt			 varchar2(1024);

	Cursor schrittweise Is
		Select UID_ApplicationServer
		  From ApplicationServer
		 Where UID_ParentApplicationServer = v_uid_appserver;

	v_GenProcID 	 QBM_GTypeDefinition.YGuid;
	v_BasisObjectKey JobQueue.BasisObjectKey%Type;

	v_XUser 		 QBM_GTypeDefinition.YXUser ;
Begin

	v_GenProcID := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUser := QBM_GCommon2.FClientContextGetXUser();

	Open schrittweise;

	Loop
		Fetch schrittweise Into v_serv;

		Exit When schrittweise%Notfound;
		v_txt := 'UID_ApplicationServer=''' || v_serv || ''' and UID_Profile=''' || v_Profile || '''';
		v_BasisObjectKey := QBM_GConvert2.FCVElementToObjectKey('AppServerGotDriverProfile'
											, 'UID_ApplicationServer'
											, v_serv
											, 'UID_Profile'
											, v_Profile
											, v_noCaseCheck => 1
											 );
		QBM_GJobQueue.PJobCreate_HODelete('AppServerGotDriverProfile'
									, v_txt
									, v_GenProcID
									, v_BasisObjectKey	 => v_BasisObjectKey
									 );
	End Loop;

	Close schrittweise;

	Commit;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);


End PDeleteDrvProfileForAllChild;
-----------------------------------------------------------------------------------------------
-- / Procedure PDeleteDrvProfileForAllChild
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-- Procedure PDeleteAppProfileForAllChild
-- generiert Löschaufträge für alle untergeordneten AppServer für Job in AppServerGotAppProfile
-----------------------------------------------------------------------------------------------
Procedure PDeleteAppProfileForAllChild (v_uid_appserver varchar2
										, v_Profile varchar2
										)
as


	Cursor schrittweise Is
		Select UID_ApplicationServer
		  From ApplicationServer
		 Where UID_ParentApplicationServer = v_uid_appserver;

	--for read only
	v_serv			 QBM_GTypeDefinition.YGuid;
	v_txt			 varchar2(1024);
	v_GenProcID 	 QBM_GTypeDefinition.YGuid;
	v_BasisObjectKey JobQueue.BasisObjectKey%Type;

	v_XUser 		 QBM_GTypeDefinition.YXUser ;
Begin

	v_GenProcID := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUser := QBM_GCommon2.FClientContextGetXUser();

	Open schrittweise;

	Loop
		Fetch schrittweise Into v_serv;

		Exit When schrittweise%Notfound;
		v_txt := 'UID_ApplicationServer=''' || v_serv || ''' and UID_Profile=''' || v_Profile || '''';
		v_BasisObjectKey := QBM_GConvert2.FCVElementToObjectKey('AppServerGotAppProfile'
											, 'UID_ApplicationServer'
											, v_serv
											, 'UID_Profile'
											, v_Profile
											, v_noCaseCheck => 1
											 );
		QBM_GJobQueue.PJobCreate_HODelete('AppServerGotAppProfile'
									, v_txt
									, v_GenProcID
									, v_BasisObjectKey	 => v_BasisObjectKey
									 );
	End Loop;

	Close schrittweise;

	Commit;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);


End PDeleteAppProfileForAllChild;
-----------------------------------------------------------------------------------------------
-- / Procedure PDeleteAppProfileForAllChild
-----------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------
-- Procedure PStammPC
-----------------------------------------------------------------------------------------------
Procedure PStammPC (v_uid_workdesk varchar2)
as

	v_uid_adsaccount QBM_GTypeDefinition.YGuid;
	v_uid_hardware	 QBM_GTypeDefinition.YGuid;
	v_cmd			 Varchar2(1024);
	v_GenProcID 	 QBM_GTypeDefinition.YGuid;


	Cursor adsaccounts Is
		Select uid_adsaccount
		  From person a join adsaccount b on a.uid_person = b.uid_person
--16592
						join dialogColumn c on c.UID_DialogTable = 'ADS-T-ADSAccount'
											and c.columnname = 'UID_HardwareDefaultMachine'
											and c.IsDeactivatedByPreProcessor = 0
--/ 16592		 
		Where a.uid_workdesk = v_uid_workdesk
		   And RTRIM(a.uid_workdesk) Is Not Null;

	v_XUser 		 QBM_GTypeDefinition.YXUser ;
Begin

	v_GenProcID := QBM_GCommon2.FClientContextGetGenProcID();
	v_XUser := QBM_GCommon2.FClientContextGetXUser();

	-- den pc an diesem workdesk selektieren
	Begin
		Select uid_hardware
		  Into v_uid_hardware
		  From hardware
		 Where uid_workdesk = v_uid_workdesk
		   And ispc = 1
		   And isvipc = 1;
	Exception
		When NO_DATA_FOUND Then
			v_uid_hardware := Null;
	End;


	Open adsaccounts;

	Loop
		Fetch adsaccounts Into v_uid_adsaccount;

		Exit When adsaccounts%Notfound;

		QBM_GJobQueue.PJobCreate_HOUpdate('ADSAccount'
									, 'uid_adsaccount=''' || v_uid_adsaccount || ''''
									, v_GenProcID
									, v_p1 => 'uid_hardwaredefaultmachine'
									, v_v1 => v_uid_hardware
									, v_isToFreezeOnError => 1
									 );
	End Loop;

	Close adsaccounts;

	Commit;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);

End PStammPC;
-----------------------------------------------------------------------------------------------
-- / Procedure PStammPC
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-- Procedure PPersonHasAppCreate
-----------------------------------------------------------------------------------------------
Procedure PPersonHasAppCreate
as

	v_uid_ADSaccount  QBM_GTypeDefinition.YGuid;
	v_uid_LDAPAccount QBM_GTypeDefinition.YGuid;

	v_uid_person	  QBM_GTypeDefinition.YGuid;
	v_uid_ADSgroup	  QBM_GTypeDefinition.YGuid;
	v_uid_LDAPgroup   QBM_GTypeDefinition.YGuid;

	v_uid_application QBM_GTypeDefinition.YGuid;
	v_hstr			  varchar2(1023);
	v_exists		  QBM_GTypeDefinition.YBool;

	Cursor adsaccounts Is
		Select a.uid_adsaccount, d.uid_person, c.uid_adsgroup, e.uid_application
		  From adsaccountinadsgroup a
			 , adsaccount b
			 , adsgroup c
			 , person d
			 , application e
		 Where d.uid_person = b.uid_person
		   And a.uid_adsaccount = b.uid_adsaccount
		   And a.uid_adsgroup = c.uid_adsgroup
		   And LOWER(e.ident_sectionname) = LOWER(c.cn)
		   And c.isapplicationgroup = 1 and a.XOrigin > 0 and a.XIsInEffect = 1;

	Cursor ldapaccounts Is
		Select a.uid_ldapaccount, d.uid_person, c.uid_ldapgroup, e.uid_application
		  From ldapaccountinldapgroup a
			 , ldapaccount b
			 , ldapgroup c
			 , person d
			 , application e
		 Where d.uid_person = b.uid_person
		   And a.uid_ldapaccount = b.uid_ldapaccount
		   And a.uid_ldapgroup = c.uid_ldapgroup
		   And LOWER(e.ident_sectionname) = LOWER(c.cn)
		   And c.isapplicationgroup = 1 and a.XOrigin > 0 and a.XIsInEffect = 1;
Begin


	Open adsaccounts;

	Loop
		Fetch adsaccounts
		Into v_uid_adsaccount, v_uid_person, v_uid_adsgroup, v_uid_application;

		Exit When adsaccounts%Notfound;

		Select COUNT(*)
		  Into v_exists
		  From personhasapp
		 Where uid_person = v_uid_person
		   And uid_application = v_uid_application;

		If v_exists < 1 Then
			Insert Into personhasapp(uid_person, uid_application, XObjectKey, XOrigin)
				 Values (v_uid_person
					   , v_uid_application
					   , QBM_GConvert2.FCVElementToObjectKey('PersonHasApp'
										 , 'UID_Person'
										 , v_uid_person
										 , 'UID_Application'
										 , v_uid_application
										 , v_noCaseCheck => 1
										  )
						, 1
						);
		End If;

		update adsaccountinadsgroup set XOrigin = bitand(XOrigin, 65534)
			  Where uid_adsaccount = v_uid_adsaccount
				And uid_adsgroup = v_uid_adsgroup;
	End Loop;

	Close adsaccounts;

	Open ldapaccounts;

	Loop
		Fetch ldapaccounts
		Into v_uid_ldapaccount, v_uid_person, v_uid_ldapgroup, v_uid_application;

		Exit When ldapaccounts%Notfound;

		Select COUNT(*)
		  Into v_exists
		  From personhasapp
		 Where uid_person = v_uid_person
		   And uid_application = v_uid_application;

		If v_exists < 1 Then
			Insert Into personhasapp(uid_person, uid_application, XObjectKey, XOrigin)
				 Values (v_uid_person
					   , v_uid_application
					   , QBM_GConvert2.FCVElementToObjectKey('PersonHasApp'
										 , 'UID_Person'
										 , v_uid_person
										 , 'UID_Application'
										 , v_uid_application
										 , v_noCaseCheck => 1
										  )
						, 1
						);
		End If;

		update ldapaccountinldapgroup set XOrigin = bitand(XOrigin, 65534)
			  Where uid_ldapaccount = v_uid_ldapaccount
				And uid_ldapgroup = v_uid_ldapgroup;
	End Loop;

	Close ldapaccounts;

	Commit;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);

End PPersonHasAppCreate;
-----------------------------------------------------------------------------------------------
-- / Procedure PPersonHasAppCreate
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-- Procedure PFillOSInstType
-----------------------------------------------------------------------------------------------
Procedure PFillOSInstType
as

Begin

insert into osinsttype ( UID_InstallationType,UID_OS, XObjectKey
						, Ident_InstType, Ident_OS
						, UID_OsInstType)
select x.UID_InstallationType, x.UID_OS, QBM_GConvert2.FCVElementToObjectKey('OsInstType', 'UID_OsInstType', x.UID_OsInstType, v_noCaseCheck => 1)
			, x.Ident_InstType, x.Ident_OS
			, x.UID_OsInstType
 from
	(
		select o.UID_OS, o.Ident_OS, i.UID_InstallationType, i.Ident_InstType, NEWID() as UID_OsInstType
			from os o cross join  installationtype i
		where Not exists (select 1 
							from OsInstType oi
							where oi.UID_InstallationType = i.UID_InstallationType
							 and oi.UID_OS = o.UID_OS
						)
	) x;


	delete from osinsttype 
		where UID_OS not in (select UID_OS from os);

	delete from osinsttype
		where UID_InstallationType not in (select UID_InstallationType from Installationtype);

	Commit;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);

End PFillOSInstType;
-----------------------------------------------------------------------------------------------
-- / Procedure PFillOSInstType
-----------------------------------------------------------------------------------------------



end SDL_GSoftwareDistribution;
go

