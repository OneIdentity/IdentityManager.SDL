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
--------------------------------------------------------------------


Create Or Replace Package SDL_GSoftwareDistribution As





	-----------------------------------------------------------------------------------------------
	-- Procedure PDistributeAppGroup
	-----------------------------------------------------------------------------------------------
	Procedure PDistributeAppGroup (v_Groupname varchar2
									, v_domain varchar2
									, v_descript varchar2 := null
									);
	-----------------------------------------------------------------------------------------------
	


	-----------------------------------------------------------------------------------------------
	-- Procedure PRepairAppServerGotXX
	-- auffüllen der AppserverGot xx  - Tabellen, mit allen Zuordnungen, die der FDS hat,
	-- die in den darunterliegenden Servern jedoch nicht vorhanden sind.
	-----------------------------------------------------------------------------------------------
	Procedure PRepairAppServerGotXX (v_ident_domain varchar2 := null -- wenn angegeben, wird nur für diese Domäne Reparatur ausgeführt
									, v_type varchar2 := null -- wenn angegeben, wird nur für den Type die Reparatur ausgeführt
															 -- zulässig sind APP, DRV und MAC
									);
	-----------------------------------------------------------------------------------------------
	



	-----------------------------------------------------------------------------------------------
	-- Procedure PInsertInAppServerGotMac
	-----------------------------------------------------------------------------------------------
	Procedure PInsertInAppServerGotMac (v_uid_appserver			 varchar2
										, v_uid_machinetype		 varchar2
										, v_chgnumber				 Number
										, v_ProfileStateProduction  varchar2
										, v_ProfileStateShadow 	 varchar2
										);
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
										);
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
										);
	-----------------------------------------------------------------------------------------------




	-----------------------------------------------------------------------------------------------
	-- Procedure PFillPAS
	-----------------------------------------------------------------------------------------------
	Procedure PFillPAS (v_appserver varchar2);
	-----------------------------------------------------------------------------------------------




	-----------------------------------------------------------------------------------------------
	-- Procedure PDeleteDrvProfileForAllChild
	-- generiert Löschaufträge für alle untergeordneten AppServer für Job in AppServerGotDriverProfile
	-----------------------------------------------------------------------------------------------
	Procedure PDeleteDrvProfileForAllChild (v_uid_appserver varchar2
											, v_Profile varchar2
											);
	-----------------------------------------------------------------------------------------------



	-----------------------------------------------------------------------------------------------
	-- Procedure PDeleteAppProfileForAllChild
	-- generiert Löschaufträge für alle untergeordneten AppServer für Job in AppServerGotAppProfile
	-----------------------------------------------------------------------------------------------
	Procedure PDeleteAppProfileForAllChild (v_uid_appserver varchar2
											, v_Profile varchar2
											);
	-----------------------------------------------------------------------------------------------


	-----------------------------------------------------------------------------------------------
	-- Procedure PStammPC
	-----------------------------------------------------------------------------------------------
	Procedure PStammPC (v_uid_workdesk varchar2);
	-----------------------------------------------------------------------------------------------


	-----------------------------------------------------------------------------------------------
	-- Procedure PPersonHasAppCreate
	-----------------------------------------------------------------------------------------------
	Procedure PPersonHasAppCreate;
	-----------------------------------------------------------------------------------------------


	-----------------------------------------------------------------------------------------------
	-- Procedure PFillOSInstType
	-----------------------------------------------------------------------------------------------
	Procedure PFillOSInstType;
	-----------------------------------------------------------------------------------------------




end SDL_GSoftwareDistribution;
go

