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
-- Tabelle SDLDomain
-- Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Create Or Replace Trigger SDL_TUSDLDomain For Update On SDLDomain
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);

	v_Ident_Domain_tab	 QBM_GTypeDefinition.YIdentLongTab := QBM_GTypeDefinition.YIdentLongTab();




--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is
begin

	If updating('DomainGroupName') Then

		v_Ident_Domain_tab.extend(1);
		v_Ident_Domain_tab(v_Ident_Domain_tab.last) := :new.Ident_Domain;

	End If;




end after each row;

--------------------------------------------------------------------------------
-- After Statement
--------------------------------------------------------------------------------
After Statement is
begin

	if v_Ident_Domain_tab.Count > 0 then

		For i In v_Ident_Domain_tab.first..v_Ident_Domain_tab.last Loop


			select x.UID_object, null, v_GenProcID
					bulk collect into v_DBQueueElements
				  From (Select a.uid_adsaccount As uid_object
						  From SDLDomain t Join adsaccount a On a.ident_domainrd = t.ident_domain
						 Where t.ident_domain = v_Ident_Domain_tab(i)) x;

				QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-ADSAccountInADSGroup', v_DBQueueElements);

		End Loop;
	end if;


	v_Ident_Domain_tab.Delete();

end After statement;

end SDL_TUSDLDomain;
go
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle SDLDomain
-- / Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



