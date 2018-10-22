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
-- Tabelle MachineHasDriver
-- Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


Create Or Replace Trigger SDL_TIMachineHasDriver For Insert On MachineHasDriver
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);

	v_macOS    varchar2(32);
	v_DriverOS varchar2(32);
	

--------------------------------------------------------------------------------
-- Before each row
--------------------------------------------------------------------------------
Before each row is
begin

	Begin
		Select h.UID_OS, d.UID_OS
		  Into v_macOS, v_DriverOS
		  From hardware h, driver d
		 Where :new.uid_hardware = h.uid_hardware
		   And :new.uid_driver = d.uid_driver
		   And ROWNUM = 1;
	Exception
		When NO_DATA_FOUND Then
			v_macOS := Null;
			v_DriverOS := Null;
	End;

	-- wenn die Betriebssysteme von Maschine und Treiber nicht zusammenpassen: abschmettern
	If NVL(v_macOS, '##') <> NVL(v_DriverOS, '##') Then
		v_errmsg := '#LDS#Cannot set driver assignment, because operating systems of machine and driver differ.|';
		raise_application_error(-20101, v_errmsg, True);
	End If;

	-- wegen IsInactive-Filterung auf Driver
	-- zu �berwachen: Relationid = R/207
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
		QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-MACHInEHasDriver' , :new.uid_Hardware , null , v_GenProcID);
	end if;

	if :new.XIsInEffect = 1 then
		QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-HardwareUpdateCNAME' , :new.uid_Hardware , null , v_GenProcID);
	end if;



end after each row;


end SDL_TIMachineHasDriver;
go
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle MachineHasDriver
-- / Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------






--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tabelle MachineHasDriver
-- Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


Create Or Replace Trigger SDL_TUMachineHasDriver
	After Update
	On MachineHasDriver
	For Each Row
Declare

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();

	v_GenProcID 	 QBM_GTypeDefinition.YGuid;
	
	
Begin
	v_GenProcID := QBM_GCommon2.FClientContextGetGenProcID();


	if UPDATING('XOrigin') then
		if QBM_GGetInfo2.FGIXOriginChanged_Except2(:old.XOrigin, :new.XOrigin ) = 1 then -- wenn sich eines der Bits au�er 0x02 �ndert, Nachberechnung
			QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-MACHInEHasDriver' , :new.uid_Hardware , null , v_GenProcID);
		end if;
	end if;


	if (UPDATING('XIsInEffect') or UPDATING('XOrigin'))and QBM_GGetInfo2.FGIXOriginChanged_Effect(:old.XOrigin, :new.XOrigin, :old.XIsInEffect, :new.XIsInEffect) = 1 then
		

		QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-HardwareUpdateCNAME' , :new.uid_Hardware , null , v_GenProcID);

	end if;


Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
End SDL_TUMachineHasDriver;
go

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle MachineHasDriver
-- / Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
