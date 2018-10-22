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
-- Tabelle WorkDeskHasDriver
-- Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


Create Or Replace Trigger SDL_TIWorkDeskHasDriver For Insert On WorkDeskHasDriver
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);

	v_UID_tab QBM_GTypeDefinition.YGuidtab := QBM_GTypeDefinition.YGuidtab();
	


--------------------------------------------------------------------------------
-- Before each row
--------------------------------------------------------------------------------
Before each row is
begin

	-- wegen IsInactive-Filterung auf Driver
	-- zu �berwachen: Relationid = R/644
	Begin
		v_exists := 0;

		Select 1
		  Into v_exists
		  From DUAL
		 Where Exists
				   (Select 1
					  From driver
					 Where uid_driver = :new.uid_driver
					   And NVL(isInactive, 0) = 1);
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
	End;

	If v_exists = 1 Then
		v_errmsg := '#LDS#Assignment cannot take place, because the object to be assigned is disabled.|';
		raise_application_error(-20103, v_errmsg, True);
	End If;

	-- 11550
	Begin
		v_exists := 0;

		Select 1
		  Into v_exists
		  From DUAL
		 Where Exists
				   (Select 1
					  From Driver elem
					 Where elem.UID_Driver = :new.UID_Driver
					   And QER_GGetInfo.FGIITShopFlagCombineValid(:new.XObjectKey
													, Null
													, Null
													, elem.XObjectKey
													, elem.IsForITShop
													, elem.IsITShopOnly
													 ) = 0)
					and bitand(:new.XOrigin, QBM_GGetInfo2.FGIBitPatternXOrigin('|Direct|', 0)) = 1;
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
	End;

	If v_exists = 1 Then
		v_errmsg := '#LDS#Assignment is not permitted due to the combination of IT Shop flags.|';
		raise_application_error(-20101, v_errmsg, True);
	End If;

end before each row;

--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is
begin

	if bitand(:new.XOrigin, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 1)) > 0 then
		v_DBQueueElements.extend(1);
		v_DBQueueElements(v_DBQueueElements.last).Object := :new.uid_workdesk;
		v_DBQueueElements(v_DBQueueElements.last).SubObject := null;
		v_DBQueueElements(v_DBQueueElements.last).GenProcID := v_GenProcID;
	end if;


	if :new.XIsInEffect = 1 then
		v_UID_tab.extend(1);
		v_UID_tab(v_UID_tab.last) := :new.uid_workdesk;
	end if;

end after each row;



--------------------------------------------------------------------------------
-- After Statement
--------------------------------------------------------------------------------
After Statement is
begin

		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-WorkdeskHasDriver', v_DBQueueElements);


		select x.UID_object, null, v_GenProcID
				bulk collect into v_DBQueueElements
		  From	   (Select Distinct h.uid_hardware As uid_object
					  From hardware h join table(v_UID_tab) vuid on h.uid_WorkDesk = vuid.column_value
					 Where (h.ispc = 1 or h.isServer = 1)
					 ) x;

     
		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-MACHInEHasDriver', v_DBQueueElements);



Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
end After statement;




end SDL_TIWorkDeskHasDriver;
go
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle WorkDeskHasDriver
-- / Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tabelle WorkDeskHasDriver
-- Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



Create Or Replace Trigger SDL_TUWorkDeskHasDriver For Update On WorkDeskHasDriver
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);

	v_UID_tab QBM_GTypeDefinition.YGuidtab := QBM_GTypeDefinition.YGuidtab();
	

--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is
begin

	if UPDATING('XOrigin') then
		if QBM_GGetInfo2.FGIXOriginChanged_Except2(:old.XOrigin, :new.XOrigin ) = 1 then
			v_DBQueueElements.extend(1);
			v_DBQueueElements(v_DBQueueElements.last).Object := :new.uid_workdesk;
			v_DBQueueElements(v_DBQueueElements.last).SubObject := null;
			v_DBQueueElements(v_DBQueueElements.last).GenProcID := v_GenProcID;
		end if;
	end if;


	if (UPDATING('XIsInEffect') or UPDATING('XOrigin'))and QBM_GGetInfo2.FGIXOriginChanged_Effect(:old.XOrigin, :new.XOrigin, :old.XIsInEffect, :new.XIsInEffect) = 1 then
		v_UID_tab.extend(1);
		v_UID_tab(v_UID_tab.last) := :new.uid_workdesk;
	end if;

end after each row;



--------------------------------------------------------------------------------
-- After Statement
--------------------------------------------------------------------------------
After Statement is
begin

		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-WorkdeskHasDriver', v_DBQueueElements);


		select x.UID_object, null, v_GenProcID
				bulk collect into v_DBQueueElements
		  From	   (Select Distinct h.uid_hardware As uid_object
					  From hardware h join table(v_UID_tab) vuid on h.uid_WorkDesk = vuid.column_value
					 Where (h.ispc = 1 or h.isServer = 1)
					 ) x;

     
		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-MACHInEHasDriver', v_DBQueueElements);



Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
end After statement;




end SDL_TUWorkDeskHasDriver;
go




--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle WorkDeskHasDriver
-- / Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
