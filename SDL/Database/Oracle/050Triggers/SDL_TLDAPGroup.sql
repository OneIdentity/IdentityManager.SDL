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
--------------------------------------------------------------------------------
-- Tabelle LDAPGroup
-- Event: Delete
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Create Or Replace Trigger SDL_TDLDAPGroup For Delete On LDAPGroup
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;

	v_cn_tab QBM_GTypeDefinition.YIdentLongTab := QBM_GTypeDefinition.YIdentLongTab();
	v_UID_LDAPContainer_tab	 QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();




--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is

Begin
	-- wenn es sich um eine Applikationsgruppe handelte, dann ..
	If NVL(:old.IsApplicationGroup, 0) = 1 Then
		v_cn_tab.extend(1);
		v_cn_tab(v_cn_tab.last) := :old.cn;
		v_UID_LDAPContainer_tab.extend(1);
		v_UID_LDAPContainer_tab(v_UID_LDAPContainer_tab.last) := :old.UID_LDAPContainer;
	End If;


end after each row;

--------------------------------------------------------------------------------
-- After Statement
--------------------------------------------------------------------------------
After Statement is
	v_uid_application  QBM_GTypeDefinition.YGuid;
begin

	if v_cn_tab.Count > 0 then
		For i In v_cn_tab.first..v_cn_tab.last Loop


			-- Bestimmen der Applikation, die zu dieser Gruppe geh�rt
			Begin
				Select uid_application
				  Into v_uid_application
				  From application
				 Where ident_sectionname = v_cn_tab(i) and rownum = 1;
			Exception
				When NO_DATA_FOUND Then
					v_uid_application := Null;
			End;

			If RTRIM(v_uid_application) Is Not Null Then
				Begin
					QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-AllLDAPAccountsForApplication'
										, v_uid_application
										, v_UID_LDAPContainer_tab(i)
										, v_GenProcID
										 );
				Exception
					When Others Then
						raise_application_error(-20100, SQLERRM);
				End;
			End If;
		End Loop;
	end if;


	v_cn_tab.Delete();
	v_UID_LDAPContainer_tab.Delete();


end After statement;

end SDL_TDLDAPGroup;
go
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle LDAPGroup
-- / Event: Delete
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------





--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tabelle LDAPGroup
-- Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


Create Or Replace Trigger SDL_TILDAPGroup For Insert On LDAPGroup
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);

	v_uid_application QBM_GTypeDefinition.YGuid;
	


--------------------------------------------------------------------------------
-- Before each row
--------------------------------------------------------------------------------
Before each row is
begin

	-- wenn die neue Gruppe eine Applikationsgruppe sein soll ..
	If NVL(:new.IsApplicationGroup, 0) = 1 Then
		-- pr�fen der Sektion zu dieser Gruppe
		Begin
			v_exists := 0;

			Select 1
			  Into v_exists
			  From DUAL
			 Where Exists
					   (Select 1
						  From sectionname
						 Where ident_sectionname = :new.cn);
		Exception
			When NO_DATA_FOUND Then
				v_exists := 0;
		End;

		If v_exists = 0 Then
			v_errmsg := '#LDS#Cannot insert {0}, because SectionName does not exist.|LDAPGroup|';
			raise_application_error(-20101, v_errmsg, True);
		End If;
	End If;

end before each row;

--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is
begin

	-- wenn die neue Gruppe eine Applikationsgruppe sein soll ..
	If NVL(:new.IsApplicationGroup, 0) = 1 Then
		-- Bestimmen der Applikation, die zu dieser Gruppe geh�rt
		Begin
			Select uid_application
			  Into v_uid_application
			  From application
			 Where ident_sectionname = :new.cn;
		Exception
			When NO_DATA_FOUND Then
				v_uid_application := Null;
		-- die fehlerbehandlung erst mal rausgenommen, da die Applikation u.U. noch nicht angelegt
		-- dann k�nnen eigentlich auch noch keine Nutzer drin sein
		End;

		-- Jobs f�r alle betroffenen Accounts einstellen
		If RTRIM(v_uid_application) Is Not Null Then
			QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-AllLDAPAccountsForApplication'
								, v_uid_application
								, :new.uid_LDAPcontainer
								, v_GenProcID
								 );
		End If;
	End If;


end after each row;


end SDL_TILDAPGroup;
go
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle LDAPGroup
-- / Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------




--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tabelle LDAPGroup
-- Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


Create Or Replace Trigger SDL_TULDAPGroup For Update On LDAPGroup
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);

	v_uid_application QBM_GTypeDefinition.YGuid;

	v_cn_tab QBM_GTypeDefinition.YIdentLongTab := QBM_GTypeDefinition.YIdentLongTab();
	v_UID_LDAPContainer_tab	 QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_UID_LDAPContainer_old_tab QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	


--------------------------------------------------------------------------------
-- Before each row
--------------------------------------------------------------------------------
Before each row is
begin



	-- update des cn verbieten
	If :old.cn <> :new.cn Then
		-- Bestimmen der Applikation, die zu dieser Gruppe geh�rt
		Begin
			Select uid_application
			  Into v_uid_application
			  From application
			 Where ident_sectionname = :new.cn;
		Exception
			When NO_DATA_FOUND Then
				v_uid_application := Null;
		End;

		If RTRIM(v_uid_application) Is Not Null Then
			v_errmsg := '#LDS#Cannot save LDAPGroup because cn has been changed.|';
			raise_application_error(-20101, v_errmsg, True);
		End If;
	End If;

	-- wenn die Kennung als Applikationsgruppe wechselt
	If NVL(:new.IsApplicationGroup, 0) <> NVL(:old.IsApplicationGroup, 0) Then
		-- erster Fall : Gruppe soll Applikationsgruppe werden
		If NVL(:new.IsApplicationGroup, 0) = 1 Then
			-- pr�fen der Sektion zu dieser Gruppe
			Begin
				v_exists := 0;

				Select 1
				  Into v_exists
				  From DUAL
				 Where Exists
						   (Select 1
							  From sectionname
							 Where ident_sectionname = :new.cn);
			Exception
				When NO_DATA_FOUND Then
					v_exists := 0;
			End;

			If v_exists = 0 Then
				v_errmsg := '#LDS#Cannot change LDAPGroup, because the associated application does not exist.|';
				raise_application_error(-20101, v_errmsg, True);
			End If;
		End If;

		-- zweiter Fall : Gruppe war Applikationsgruppe
		If NVL(:old.IsApplicationGroup, 0) = 1 Then
			-- pr�fen, ob es die Applikation dazu gibt
			-- Bestimmen der Applikation, die zu dieser Gruppe geh�rt
			Begin
				Select uid_application
				  Into v_uid_application
				  From application
				 Where ident_sectionname = :new.cn;
			Exception
				When NO_DATA_FOUND Then
					v_uid_application := Null;
			End;

			If RTRIM(v_uid_application) Is Not Null Then
				v_errmsg := '#LDS#Cannot save LDAPGroup, because assigned application already exists.|';
				raise_application_error(-20101, v_errmsg, True);
			End If;
		End If;
	End If; -- :new.IsApplicationGroup <> :old.IsApplicationGroup



end before each row;

--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is

begin



	-- wenn die Kennung als Applikationsgruppe wechselt und es ein AppsGruppe wird
	If (NVL(:new.IsApplicationGroup, 0) <> NVL(:old.IsApplicationGroup, 0))
   And (NVL(:new.IsApplicationGroup, 0) = 1) Then

		v_UID_LDAPContainer_tab.extend(1);
		v_UID_LDAPContainer_tab(v_UID_LDAPContainer_tab.last) := :new.UID_LDAPContainer;

		v_UID_LDAPContainer_old_tab.extend(1);
		v_UID_LDAPContainer_old_tab(v_UID_LDAPContainer_old_tab.last) := :old.UID_LDAPContainer;

		v_cn_tab.extend(1);
		v_cn_tab(v_cn_tab.last) := :new.cn;

	End If;

end after each row;


--------------------------------------------------------------------------------
-- After Statement
--------------------------------------------------------------------------------
After Statement is
begin


	if v_cn_tab.Count > 0 then
		For i In v_cn_tab.first..v_cn_tab.last Loop

			-- pr�fen, ob es die Applikation dazu gibt
			-- Bestimmen der Applikation, die zu dieser Gruppe geh�rt
			Begin
				Select uid_application
				  Into v_uid_application
				  From application
				 Where ident_sectionname = v_cn_tab(i);
			Exception
				When NO_DATA_FOUND Then
					v_uid_application := Null;
			-- die fehlerbehandlung erst mal rausgenommen, da die Applikation u.U. noch nicht angelegt
			-- dann k�nnen eigentlich auch noch keine Nutzer drin sein
			End;

			-- Jobs f�r alle betroffenen Accounts einstellen
			If RTRIM(v_uid_application) Is Not Null Then
				If RTRIM(v_uid_LDAPcontainer_tab(i)) <> RTRIM(v_uid_LDAPcontainer_old_tab(i)) Then
					QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-AllLDAPAccountsForApplication'
										, v_uid_application
										, v_UID_LDAPContainer_tab(i)
										, v_GenProcID
										 );
					QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-AllLDAPAccountsForApplication'
										, v_uid_application
										, v_UID_LDAPContainer_old_tab(i)
										, v_GenProcID
										 );
				Else
					QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-AllLDAPAccountsForApplication'
										, v_uid_application
										, v_UID_LDAPContainer_tab(i)
										, v_GenProcID
										 );
				End If;
			End If;
		End Loop;
	end if;

	v_UID_LDAPContainer_tab.Delete();
	v_UID_LDAPContainer_old_tab.Delete();
	v_cn_tab.Delete();


end After statement;


end SDL_TULDAPGroup;
go
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle LDAPGroup
-- / Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------






