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
-- Tabelle MachineTypeHasDriver
-- Event: Delete
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Create Or Replace Trigger SDL_TDMachineTypeHasDriver For Delete On MachineTypeHasDriver
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);

	v_UID_MachineType_tab	 QBM_GTypeDefinition.YGuidTab := QBM_GTypeDefinition.YGuidTab();
	v_uid_hardware	  QBM_GTypeDefinition.YGuid;
	v_UID_Machinetype QBM_GTypeDefinition.YGuid;





--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is
begin

	v_UID_MachineType_tab.extend(1);
	v_UID_MachineType_tab(v_UID_MachineType_tab.last) := :old.UID_MachineType;


end after each row;

--------------------------------------------------------------------------------
-- After Statement
--------------------------------------------------------------------------------
After Statement is

	Cursor c_schritt Is
		Select uid_hardware
		  From hardware
		 Where hardware.UID_MachineType = v_UID_Machinetype
		   And (hardware.isPC = 1
			 Or  hardware.IsServer = 1);

begin

	if v_UID_MachineType_tab.Count > 0 then
		For i In v_UID_MachineType_tab.first..v_UID_MachineType_tab.last Loop
			v_UID_Machinetype := v_UID_MachineType_tab(i);

			Open c_schritt;
			Loop
				Fetch c_schritt Into v_uid_hardware;
				Exit When c_schritt%Notfound;
				QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-MACHInEHasDriver'
									, v_uid_hardware
									, null
									, v_GenProcID
									 );
			End Loop;
			Close c_schritt;
		End Loop;
	end if;


	v_UID_MachineType_tab.Delete();

end After statement;

end SDL_TDMachineTypeHasDriver;
go
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle MachineTypeHasDriver
-- / Event: Delete
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------





--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tabelle MachineTypeHasDriver
-- Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


Create Or Replace Trigger SDL_TIMachineTypeHasDriver For Insert On MachineTypeHasDriver
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);

	v_uid_Hardware	 QBM_GTypeDefinition.YGuid;
	


--------------------------------------------------------------------------------
-- Before each row
--------------------------------------------------------------------------------
Before each row is
begin

	-- wegen IsInactive-Filterung auf Driver
	-- zu �berwachen: Relationid = R/640
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

	-- wegen IsInactive-Filterung auf MachineType
	-- zu �berwachen: Relationid = R/641
	Begin
		v_exists := 0;

		Select 1
		  Into v_exists
		  From DUAL
		 Where Exists
				   (Select 1
					  From machinetype
					 Where uid_machinetype = :new.uid_machinetype
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
													 ) = 0
					);
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

	Cursor c_schritt Is
		Select uid_hardware
		  From hardware
		 Where UID_MachineType = :new.UID_MachineType
		   And (isPC = 1
			 Or  IsServer = 1);

begin

	Open c_schritt;
	Loop
		Fetch c_schritt Into v_uid_hardware;
		Exit When c_schritt%Notfound;
		QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-MACHInEHasDriver'
							, v_uid_hardware
							, null
							, v_GenProcID
							 );
	End Loop;
	Close c_schritt;



end after each row;


end SDL_TIMachineTypeHasDriver;
go
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle MachineTypeHasDriver
-- / Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



