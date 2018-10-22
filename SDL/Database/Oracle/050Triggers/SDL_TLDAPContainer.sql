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
-- Tabelle LDAPContainer
-- Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Create Or Replace Trigger SDL_TILDAPContainer
	After Insert
	On LDAPcontainer
	For Each Row
Declare
	v_GenProcID 	 QBM_GTypeDefinition.YGuid;
	
	
Begin
	v_GenProcID := QBM_GCommon2.FClientContextGetGenProcID();

	If NVL(:new.isAppcontainer, 0) = 1 Then
		QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-LDAPAppContainerInsert'
							, :new.uid_LDAPcontainer
							, null
							, v_GenProcID
						, v_noCheckForExisting => 1
							 );
	End If;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
End SDL_TILDAPContainer;
go


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle LDAPContainer
-- / Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tabelle LDAPContainer
-- Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


Create Or Replace Trigger SDL_TULDAPContainer
	After Update
	On LDAPcontainer
	For Each Row
Declare
	v_GenProcID 	 QBM_GTypeDefinition.YGuid;
	
	
Begin
	v_GenProcID := QBM_GCommon2.FClientContextGetGenProcID();

	If updating('isappcontainer') and NVL(:old.isappcontainer, 0) <> NVL(:new.isappContainer, 0) Then
		If NVL(:new.isAppcontainer, 0) = 1 Then
			QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-LDAPAppContainerInsert'
								, :new.uid_LDAPcontainer
								, null
								, v_GenProcID
								 );
		Else
			QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-LDAPAppContainerDelete'
								, :new.uid_LDAPcontainer
								, null
								, v_GenProcID
								 );
		End If;
	End If;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
End SDL_TULDAPContainer;
go

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle LDAPContainer
-- / Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
