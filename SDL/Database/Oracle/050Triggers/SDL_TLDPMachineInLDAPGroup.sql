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
-- Tabelle LDPMachineInLDAPGroup
-- Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


Create Or Replace Trigger SDL_TILDPMachineInLDAPGroup after Insert On LDPMachineInLDAPGroup for each row
declare

	v_GenProcID 	 QBM_GTypeDefinition.YGuid;
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);

begin

	v_GenProcID := QBM_GCommon2.FClientContextGetGenProcID();




	if :new.XIsInEffect = 1 then
		select x.UID_object, x.uid_subobject, v_GenProcID
				bulk collect into v_DBQueueElements
		  From	   (Select Distinct :new.uid_LDPMachine As uid_object, :new.UID_LDAPGroup as uid_subobject
					  From LDAPGroup
					 Where UID_LDAPGroup = :new.UID_LDAPGroup and IsApplicationGroup = 1
					 ) x;
     
		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-HardwareInLDAPAppGroup', v_DBQueueElements);
	end if;



end SDL_TILDPMachineInLDAPGroup;
go
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle LDPMachineInLDAPGroup
-- / Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

