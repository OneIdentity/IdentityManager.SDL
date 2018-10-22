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
-- Tabelle ADSMachineInADSGroup
-- Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



Create Or Replace Trigger SDL_TIADSMachineInADSGroup For Insert On ADSMachineInADSGroup
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------
	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	v_EnvironmentFlags number := QBM_GCommon2.FClientContextGetEnvFlags();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;

	v_errmsg varchar2(400);

	v_NewValues_tab QBM_GTypeDefinition.YMNGuids := QBM_GTypeDefinition.YMNGuids();


--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is
begin

	if :new.XIsInEffect = 1 then
			v_NewValues_tab.extend(1);
			v_NewValues_tab(v_NewValues_tab.last).MGuid := :new.uid_ADSMachine;
			v_NewValues_tab(v_NewValues_tab.last).NGuid := :new.UID_ADSGroup;
	end if;

	Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);


end after each row;




--------------------------------------------------------------------------------
-- After Statement
--------------------------------------------------------------------------------
After Statement is
begin


		select x.UID_object, x.uid_subobject, v_GenProcID
				bulk collect into v_DBQueueElements
		  From	   (Select Distinct n.MGuid As uid_object, n.NGuid as uid_subobject
					  From ADSGroup g join table(v_NewValues_tab) n on g.UID_ADSGroup = n.NGuid
					  where g.IsApplicationGroup = 1
					 ) x;
     
		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-ADSMachineInADSAppGroup', v_DBQueueElements);


Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
end After statement;



end SDL_TIADSMachineInADSGroup;
go

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle ADSMachineInADSGroup
-- / Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


