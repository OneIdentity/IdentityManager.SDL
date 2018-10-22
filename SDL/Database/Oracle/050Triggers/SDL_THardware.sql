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
-- Tabelle Hardware
-- Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Create Or Replace Trigger SDL_TIHardware For Insert On Hardware
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);


--------------------------------------------------------------------------------
-- Before each row
--------------------------------------------------------------------------------
Before each row is
begin




	-- wegen IsInactive-Filterung auf UID_MachineType
	-- zu �berwachen: Relationid = R/368
	Begin
		v_exists := 0;

		Select 1
		  Into v_exists
		  From DUAL
		 Where Exists
				   (Select 1
					  From MachineType
					 Where UID_MachineType = :new.UID_MachineType
					   And NVL(isInActive, 0) = 1);
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
	End;

	If v_exists = 1 Then
		v_errmsg := '#LDS#Assignment cannot take place, because the machine type is disabled.|';
		raise_application_error(-20101, v_errmsg, True);
	End If;

end before each row;

--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is
begin




	if '1' = QBM_GGetInfo2.FGIConfigParmValue('Software\Driver') then
		QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-MACHInEHasDriver', :new.uid_hardware, null, v_GenProcID);
	end if;


end after each row;




end SDL_TIHardware;
go
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle Hardware
-- / Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------




--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tabelle Hardware
-- Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Create Or Replace Trigger SDL_TUHardware For Update On Hardware
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);




--------------------------------------------------------------------------------
-- Before each row
--------------------------------------------------------------------------------
Before each row is
begin


	If UPDATING('UID_MachineType') Then
		-- wegen IsInactive-Filterung auf UID_MachineType
		-- zu �berwachen: Relationid = R/368
		Begin
			v_exists := 0;

			Select 1
			  Into v_exists
			  From DUAL
			 Where Exists
					   (Select 1
						  From MachineType
						 Where UID_MachineType = :new.UID_MachineType
						   And NVL(isInActive, 0) = 1);
		Exception
			When NO_DATA_FOUND Then
				v_exists := 0;
		End;

		If v_exists = 1 Then
			v_errmsg := '#LDS#Assignment cannot take place, because the machine type is disabled.|';
			raise_application_error(-20101, v_errmsg, True);
		End If;
	End If;

	-- wenn os-Wechsel und noch direkte Treiber, dann abschmettern
	If UPDATING('UID_OS')
   And RTRIM(:new.UID_OS) Is Not Null Then
		Begin
			v_exists := 0;

			Select 1
			  Into v_exists
			  From DUAL
			 Where Exists
					   (Select 1
						  From machinehasdriver
						 Where uid_hardware = :new.uid_hardware and XOrigin > 0
						 );
		Exception
			When NO_DATA_FOUND Then
				v_exists := 0;
		End;

		If v_exists = 1 Then
			v_errmsg := '#LDS#Cannot change operating system of device, because assignments of drivers already exist.|';
			raise_application_error(-20101, v_errmsg, True);
		End If;
	End If;


end before each row;

--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is

begin

	

	If (NVL(:new.ispc, 0) = 1
	 Or  NVL(:new.isserver, 0) = 1)
   And (UPDATING('UID_WorkDesk')
	 Or  UPDATING('IsPC')
	 Or  UPDATING('IsServer')
	 Or  UPDATING('UID_OS')
	 Or  UPDATING('UID_MachineType')
	 Or  UPDATING('UID_HardwareType'))
	Or	(UPDATING('IsPC')) Then


		If '1' = QBM_GGetInfo2.FGIConfigParmValue('Software\Driver') Then
			QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-MACHInEHasDriver'
								, :new.uid_hardware
								, null
								, v_GenProcID
								 );
		End If;


	End If;



end after each row;



end SDL_TUHardware;
go
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle Hardware
-- / Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------










