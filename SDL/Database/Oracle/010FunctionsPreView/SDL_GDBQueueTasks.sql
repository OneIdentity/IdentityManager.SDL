
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
-- PACKAGE SPEC
-- SDL_GDBQueueTasks
--------------------------------------------------------------------
-- folgende Bereiche sind definiert:

-- SoftwareDistribution
-- Licence
--------------------------------------------------------------------


Create Or Replace Package SDL_GDBQueueTasks As



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
								);
	-----------------------------------------------------------------------------------------------




	-----------------------------------------------------------------------------------------------
	-- Procedure ZMachinesForApplication
	-- stellt für Maschinen, die die Applikation haben	Jobs zum Schreiben der CName ein
	-----------------------------------------------------------------------------------------------
	Procedure ZMachinesForApplication (v_SlotNumber number
									, v_uid_Application varchar2
									, v_dummy varchar2
									, v_GenProcID varchar2
									);
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
									);
	-----------------------------------------------------------------------------------------------



	-----------------------------------------------------------------------------------------------
	-- Procedure ZLDPAppContainerDelete
	-- löscht alle Applikationsgruppen in einem angegebenen LDAP-Container
	-----------------------------------------------------------------------------------------------
	Procedure ZLDPAppContainerDelete (v_SlotNumber number
									, v_uid_LDAPcontainer varchar2
									, v_dummy varchar2
									, v_GenProcID varchar2
									);
	-----------------------------------------------------------------------------------------------




	-----------------------------------------------------------------------------------------------
	-- Procedure ZLDPAccountInAppGroup
	-- diese Task regelt den Backsync, wenn im Namespace Gruppenmitgliedschaften in
	-- Applikationsgruppen gefunden werden, so werden diese nicht direkt in LDAPAccountInLDAPGroup
	-- eingetragen, sondern auf PersonHasApp abgebildet.
	-----------------------------------------------------------------------------------------------
	Procedure ZLDPAccountInAppGroup (v_SlotNumber number
									);
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
										);
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
									);
	-----------------------------------------------------------------------------------------------



	-----------------------------------------------------------------------------------------------
	-- Procedure ZAppContainerDelete
	-- löscht alle Applikationsgruppen in einem angegebenen ADS-Container
	-----------------------------------------------------------------------------------------------
	Procedure ZAppContainerDelete (v_SlotNumber number
									, v_uid_ADScontainer varchar2
									, v_dummy varchar2
									, v_GenProcID varchar2
									);
	-----------------------------------------------------------------------------------------------


	-----------------------------------------------------------------------------------------------
	-- Procedure ZAllForOneDriver
	-- stellt für alle Stellen wo die Treiber eine Rolle spielen könnte eine Neuberechnung ein
	-----------------------------------------------------------------------------------------------
	Procedure ZAllForOneDriver (v_SlotNumber number
								, v_uid_Driver varchar2
								, v_dummy varchar2
								, v_GenProcID varchar2
								);
	-----------------------------------------------------------------------------------------------



	-----------------------------------------------------------------------------------------------
	-- Procedure ZADSAccountInAppGroup
	-- diese Task regelt den Backsync, wenn im Namespace Gruppenmitgliedschaften in
	-- Applikationsgruppen gefunden werden, so werden diese nicht direkt in ADSAccountInADSGroup
	-- eingetragen, sondern auf PersonHasApp abgebildet.
	-----------------------------------------------------------------------------------------------
	Procedure ZADSAccountInAppGroup (v_SlotNumber number
									);
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
										);
	-----------------------------------------------------------------------------------------------



	-----------------------------------------------------------------------------------------------
	-- Procedure ZApplicationMakeSortorder
	-----------------------------------------------------------------------------------------------
	Procedure ZApplicationMakeSortorder (v_SlotNumber number
										, v_dummy1 varchar2
										, v_dummy2 varchar2
										, v_GenProcIDDummy varchar2
										);
	-----------------------------------------------------------------------------------------------


	-----------------------------------------------------------------------------------------------
	-- Procedure ZDriverMakeSortorder
	-----------------------------------------------------------------------------------------------
	Procedure ZDriverMakeSortorder (v_SlotNumber number
										, v_dummy1 varchar2
										, v_dummy2 varchar2
										, v_GenProcIDDummy varchar2
										);
	-----------------------------------------------------------------------------------------------



	-----------------------------------------------------------------------------------------------
	-- Procedure ZADSMachineInADSAppGroup
	-----------------------------------------------------------------------------------------------
	Procedure ZADSMachineInADSAppGroup (v_SlotNumber number
									);
	-----------------------------------------------------------------------------------------------


	-----------------------------------------------------------------------------------------------
	-- Procedure ZLDPMachineInLDPAppGroup
	-----------------------------------------------------------------------------------------------
	Procedure ZLDPMachineInLDPAppGroup (v_SlotNumber number
										);
	-----------------------------------------------------------------------------------------------


	-----------------------------------------------------------------------------------------------
	-- Procedure ZHardwareUpdateCName
	-----------------------------------------------------------------------------------------------
	Procedure ZHardwareUpdateCName (v_SlotNumber number
									);
	-----------------------------------------------------------------------------------------------


	-----------------------------------------------------------------------------------------------
	-- Procedure ZMachineHasDriver
	-----------------------------------------------------------------------------------------------
	Procedure ZMachineHasDriver (v_SlotNumber number
									);
	-----------------------------------------------------------------------------------------------

	-----------------------------------------------------------------------------------------------
	-- Procedure ZOrgHasDriver
	-----------------------------------------------------------------------------------------------
	Procedure ZOrgHasDriver (v_SlotNumber number
									);
	-----------------------------------------------------------------------------------------------




	-----------------------------------------------------------------------------------------------
	-- Procedure ZSoftwareDependsPhysical
	-----------------------------------------------------------------------------------------------
	Procedure ZSoftwareDependsPhysical (v_SlotNumber number
										, v_dummy1 varchar2
										, v_dummy2 varchar2
										, v_GenProcIDDummy varchar2
										);
	-----------------------------------------------------------------------------------------------



	-----------------------------------------------------------------------------------------------
	-- Procedure ZSoftwareExclusion
	-----------------------------------------------------------------------------------------------
	Procedure ZSoftwareExclusion (v_SlotNumber number
										, v_sw1 varchar2
										, v_dummy2 varchar2
										, v_GenProcID varchar2
										);
	-----------------------------------------------------------------------------------------------



	-----------------------------------------------------------------------------------------------
	-- Procedure ZSoftwareExclusionADD
	-----------------------------------------------------------------------------------------------
	Procedure ZSoftwareExclusionADD (v_SlotNumber number
										, v_sw1 varchar2
										, v_sw2 varchar2
										, v_GenProcID varchar2
										);
	-----------------------------------------------------------------------------------------------


	-----------------------------------------------------------------------------------------------
	-- Procedure ZSoftwareExclusionDEL
	-----------------------------------------------------------------------------------------------
	Procedure ZSoftwareExclusionDEL (v_SlotNumber number
										, v_sw1 varchar2
										, v_sw2 varchar2
										, v_GenProcID varchar2
										);
	-----------------------------------------------------------------------------------------------



	-----------------------------------------------------------------------------------------------
	-- Procedure ZWorkDeskHasDriver
	-----------------------------------------------------------------------------------------------
	Procedure ZWorkDeskHasDriver (v_SlotNumber number
									);
	-----------------------------------------------------------------------------------------------




	-----------------------------------------------------------------------------------------------
	-- Procedure ZADSAccountInADSGroup
	-----------------------------------------------------------------------------------------------
	Procedure ZADSAccountInADSGroup (v_SlotNumber number);
	-----------------------------------------------------------------------------------------------


	-----------------------------------------------------------------------------------------------
	-- Procedure ZLDAPAccountInLDAPGroup
	-----------------------------------------------------------------------------------------------
	Procedure ZLDAPAccountInLDAPGroup (v_SlotNumber number);
	-----------------------------------------------------------------------------------------------



	-----------------------------------------------------------------------------------------------
	-- Procedure ZLDPMachineInLDAPGroup
	-----------------------------------------------------------------------------------------------
	Procedure ZLDPMachineInLDAPGroup (v_SlotNumber number);
	-----------------------------------------------------------------------------------------------


	-----------------------------------------------------------------------------------------------
	-- Procedure ZADSMachineInADSGroup 
	-----------------------------------------------------------------------------------------------
	Procedure ZADSMachineInADSGroup (v_SlotNumber number);
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
										);
	-----------------------------------------------------------------------------------------------

	-----------------------------------------------------------------------------------------------
	-- Procedure ZLicenceCompanyActual
	-----------------------------------------------------------------------------------------------
	Procedure ZLicenceCompanyActual (v_SlotNumber number
										, v_dummy1 varchar2
										, v_dummy2 varchar2
										, v_GenProcID varchar2
										);
	-----------------------------------------------------------------------------------------------

	-----------------------------------------------------------------------------------------------
	-- Procedure ZLicenceCompanyReal
	-----------------------------------------------------------------------------------------------
	Procedure ZLicenceCompanyReal (v_SlotNumber number
										, v_dummy1 varchar2
										, v_dummy2 varchar2
										, v_GenProcID varchar2
										);
	-----------------------------------------------------------------------------------------------




	-----------------------------------------------------------------------------------------------
	-- Procedure ZLicenceOrgTarget
	-----------------------------------------------------------------------------------------------
	Procedure ZLicenceOrgTarget (v_SlotNumber number);
	-----------------------------------------------------------------------------------------------


	-----------------------------------------------------------------------------------------------
	-- Procedure ZLicenceOrgActual
	-----------------------------------------------------------------------------------------------
	Procedure ZLicenceOrgActual (v_SlotNumber number);
	-----------------------------------------------------------------------------------------------


	-----------------------------------------------------------------------------------------------
	-- Procedure ZLicenceOrgReal
	-----------------------------------------------------------------------------------------------
	Procedure ZLicenceOrgReal (v_SlotNumber number);
	-----------------------------------------------------------------------------------------------




	-----------------------------------------------------------------------------------------------
	-- Procedure PLicenceOrg_Basics
	-----------------------------------------------------------------------------------------------
	Procedure PLicenceOrg_Basics (v_SlotNumber number);
	-----------------------------------------------------------------------------------------------




	-----------------------------------------------------------------------------------------------
	-- Procedure ZLicenceRecalculate
	-----------------------------------------------------------------------------------------------
	Procedure ZLicenceRecalculate (v_SlotNumber number
										, v_dummy1 varchar2
										, v_dummy2 varchar2
										, v_GenProcIDDummy varchar2
										);
	-----------------------------------------------------------------------------------------------


	-----------------------------------------------------------------------------------------------
	-- Procedure ZLicenceSubstitute
	-----------------------------------------------------------------------------------------------
	Procedure ZLicenceSubstitute (v_SlotNumber number
										, v_dummy1 varchar2
										, v_dummy2 varchar2
										, v_GenProcIDDummy varchar2
										);
	-----------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- / Licence
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------





	-----------------------------------------------------------------------------------------------
	-- Procedure ZBaseTreeHasObject
	-----------------------------------------------------------------------------------------------
	Procedure ZBaseTreeHasObject (v_SlotNumber number);
	-----------------------------------------------------------------------------------------------


	-----------------------------------------------------------------------------------------------
	-- Procedure ZAllForOneWorkdesk
	-----------------------------------------------------------------------------------------------
	Procedure ZAllForOneWorkdesk (v_SlotNumber number);
	-----------------------------------------------------------------------------------------------



end SDL_GDBQueueTasks;
go

