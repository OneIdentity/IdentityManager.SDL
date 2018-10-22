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
-- Tabelle WorkDeskHasApp
-- Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



Create Or Replace Trigger SDL_TIWorkDeskHasApp For Insert On WorkDeskHasApp
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();

	v_UID_tab QBM_GTypeDefinition.YGuidtab := QBM_GTypeDefinition.YGuidtab();

	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);


--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is
begin

	if :new.XIsInEffect = 1 then
		v_UID_tab.extend(1);
		v_UID_tab(v_UID_tab.last) := :new.uid_workdesk;
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

		select x.UID_object, null, v_GenProcID
				bulk collect into v_DBQueueElements
		  From	   (Select Distinct h.uid_hardware As uid_object
					  From hardware h join table(v_UID_tab) vuid on h.uid_WorkDesk = vuid.column_value
					 Where (h.ispc = 1 or h.isServer = 1)
					 ) x;

     
		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-HardwareUpdateCNAME', v_DBQueueElements);



Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
end After statement;




end SDL_TIWorkDeskHasApp;
go


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle WorkDeskHasApp
-- / Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------




--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tabelle WorkDeskHasApp
-- Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------




Create Or Replace Trigger SDL_TUWorkDeskHasApp For Update On WorkDeskHasApp
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();

	v_UID_tab QBM_GTypeDefinition.YGuidtab := QBM_GTypeDefinition.YGuidtab();

	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);


--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is
begin

	if (UPDATING('XIsInEffect') or UPDATING('XOrigin'))and QBM_GGetInfo2.FGIXOriginChanged_Effect(:old.XOrigin, :new.XOrigin, :old.XIsInEffect, :new.XIsInEffect) = 1 then
		v_UID_tab.extend(1);
		v_UID_tab(v_UID_tab.last) := :new.uid_workdesk;
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

		select x.UID_object, null, v_GenProcID
				bulk collect into v_DBQueueElements
		  From	   (Select Distinct h.uid_hardware As uid_object
					  From hardware h join table(v_UID_tab) vuid on h.uid_WorkDesk = vuid.column_value
					 Where (h.ispc = 1 or h.isServer = 1)
					 ) x;

     
		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-HardwareUpdateCNAME', v_DBQueueElements);



Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
end After statement;




end SDL_TUWorkDeskHasApp;
go


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle WorkDeskHasApp
-- / Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

