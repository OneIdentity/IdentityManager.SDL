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
-- Tabelle ADSGroup
-- Event: Delete
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Create Or Replace Trigger SDL_TDADSGroup For Delete On ADSGroup
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;

	v_OldValues_tab QBM_GTypeDefinition.YMNObjectKeys := QBM_GTypeDefinition.YMNObjectKeys();
	-- M: cn, N: UID_ADSContainer
	-- sind zwar keine Objectkeys, passen aber




--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is
Begin
	-- wenn es sich um eine Applikationsgruppe handelte, dann ..
	If NVL(:old.IsApplicationGroup, 0) = 1 Then
			v_OldValues_tab.extend(1);
			v_OldValues_tab(v_OldValues_tab.last).MObjectKey := :old.cn;
			v_OldValues_tab(v_OldValues_tab.last).NObjectKey := :old.UID_ADSContainer;
	End If;


end after each row;

--------------------------------------------------------------------------------
-- After Statement
--------------------------------------------------------------------------------
After Statement is
begin

	select a.uid_application, n.NObjectKey, v_GenProcID
		bulk collect into v_DBQueueElements
		From Application a join table(v_OldValues_tab) n on a.ident_sectionname = n.MObjectKey
		where a.uid_application is not null;	

	QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-AllADSAccountsForApplication', v_DBQueueElements);


end After statement;

end SDL_TDADSGroup;
go
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle ADSGroup
-- / Event: Delete
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------





--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tabelle ADSGroup
-- Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Create Or Replace Trigger SDL_TIADSGroup For Insert On ADSGroup
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);

	v_NewValues_tab QBM_GTypeDefinition.YMNObjectKeys := QBM_GTypeDefinition.YMNObjectKeys();
	-- M: cn, N: UID_ADSContainer
	-- sind zwar keine Objectkeys, passen aber



--------------------------------------------------------------------------------
-- Before each row
--------------------------------------------------------------------------------
Before each row is
Begin
	-- wenn die neue Gruppe eine Applikationsgruppe sein soll ..
	If NVL(:new.IsApplicationGroup, 0) = 1 Then
		-- pr�fen der Sektion zu dieser Gruppe
		Select COUNT(*)
		  Into v_exists
		  From sectionname
		 Where ident_sectionname = :new.cn;

		If v_exists < 1 Then
			v_errmsg := '#LDS#Cannot insert Active Directory group, because SectionName does not exist.|';
			raise_application_error(-20101, v_errmsg, True);
		End If;
	End If;

Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
end before each row;

--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is
begin

	-- wenn die neue Gruppe eine Applikationsgruppe sein soll ..
	If NVL(:new.IsApplicationGroup, 0) = 1 Then
			v_NewValues_tab.extend(1);
			v_NewValues_tab(v_NewValues_tab.last).MObjectKey := :new.cn;
			v_NewValues_tab(v_NewValues_tab.last).NObjectKey := :new.UID_ADSContainer;
	End If;



end after each row;


--------------------------------------------------------------------------------
-- After Statement
--------------------------------------------------------------------------------
After Statement is
begin

	select a.uid_application, n.NObjectKey, v_GenProcID
		bulk collect into v_DBQueueElements
		From Application a join table(v_NewValues_tab) n on a.ident_sectionname = n.MObjectKey
		where a.uid_application is not null;	

	QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-AllADSAccountsForApplication', v_DBQueueElements);


end After statement;


end SDL_TIADSGroup;
go
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle ADSGroup
-- / Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------







--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tabelle ADSGroup
-- Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Create Or Replace Trigger SDL_TUADSGroup For Update On ADSGroup
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);

	v_uid_application QBM_GTypeDefinition.YGuid;

	v_NewValues_tab QBM_GTypeDefinition.YMNObjectKeys := QBM_GTypeDefinition.YMNObjectKeys();
	-- M: cn, N: UID_ADSContainer
	-- sind zwar keine Objectkeys, passen aber


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
			 Where ident_sectionname = :new.cn and rownum = 1;
		Exception
			When NO_DATA_FOUND Then
				v_uid_application := Null;
		End;

		If RTRIM(v_uid_application) Is Not Null Then
			v_errmsg := '#LDS#Cannot save Active Directory group, because CN has changed.|';
			raise_application_error(-20103, v_errmsg, True);
		End If;
	End If;

	-- wenn die Kennung als Applikationsgruppe wechselt
	If NVL(:new.IsApplicationGroup, 0) <> NVL(:old.IsApplicationGroup, 0) Then
		-- erster Fall : Gruppe soll Applikationsgruppe werden
		If NVL(:new.IsApplicationGroup, 0) = 1 Then
			-- pr�fen, ob es die Applikation dazu gibt
			-- Bestimmen der Applikation, die zu dieser Gruppe geh�rt
			Begin
				Select uid_application
				  Into v_uid_application
				  From application
				 Where ident_sectionname = :new.cn and rownum = 1;
			Exception
				When NO_DATA_FOUND Then
					v_uid_application := Null;
			End;

			If RTRIM(v_uid_application) Is Null Then
				v_errmsg := '#LDS#Cannot modify Active Directory group, because the associated application does not exist.|';
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
				 Where ident_sectionname = :new.cn and rownum = 1;
			Exception
				When NO_DATA_FOUND Then
					v_uid_application := Null;
			End;

			If RTRIM(v_uid_application) Is Not Null Then
				v_errmsg := '#LDS#Cannot save Active Directory group, because there is still an associated application.|';
				raise_application_error(-20101, v_errmsg, True);
			End If;
		End If;
	End If; -- :new.IsApplicationGroup <> :old.IsApplicationGroup


Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
end before each row;

--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is
Begin



	-- wenn die Kennung als Applikationsgruppe wechselt und es ein AppsGruppe wird
	If (NVL(:new.IsApplicationGroup, 0) <> NVL(:old.IsApplicationGroup, 0)) And (NVL(:new.IsApplicationGroup, 0) = 1) Then

		v_NewValues_tab.extend(1);
		v_NewValues_tab(v_NewValues_tab.last).MObjectKey := :new.cn;
		v_NewValues_tab(v_NewValues_tab.last).NObjectKey := :new.UID_ADSContainer;

		if :new.UID_ADSContainer <> :old.UID_ADSContainer then
			v_NewValues_tab.extend(1);
			v_NewValues_tab(v_NewValues_tab.last).MObjectKey := :new.cn;
			v_NewValues_tab(v_NewValues_tab.last).NObjectKey := :old.UID_ADSContainer;
		end if;

	End If;



end after each row;



--------------------------------------------------------------------------------
-- After Statement
--------------------------------------------------------------------------------
After Statement is
begin

	select a.uid_application, n.NObjectKey, v_GenProcID
		bulk collect into v_DBQueueElements
		From Application a join table(v_NewValues_tab) n on a.ident_sectionname = n.MObjectKey
		where a.uid_application is not null;	

	QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-AllADSAccountsForApplication', v_DBQueueElements);


end After statement;


end SDL_TUADSGroup;
go
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle ADSGroup
-- / Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


