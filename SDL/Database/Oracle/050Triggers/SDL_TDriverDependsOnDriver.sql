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
-- Tabelle DriverDependsOnDriver
-- Event: Delete
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Create Or Replace Trigger SDL_TDDriverDependsOnDriver
	After Delete
	On DriverDependsOnDriver
	For Each Row
Declare
	v_GenProcID 	 QBM_GTypeDefinition.YGuid;
	
	
Begin
	v_GenProcID := QBM_GCommon2.FClientContextGetGenProcID();

	QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-DriverMakeSortOrder'
						, null
						, null
						, v_GenProcID
						 );

	If :old.IsPhysicaldependent = 1 Then
		QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-SoftwareDependsPhysical'
							, null
							, null
							, v_GenProcID
							 );
	End If;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
End SDL_TDDriverDependsOnDriver;
go


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle DriverDependsOnDriver
-- / Event: Delete
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tabelle DriverDependsOnDriver
-- Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


Create Or Replace Trigger SDL_TIDriverDependsOnDriver For Insert On DriverDependsOnDriver
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

	-- wegen IsInactive-Filterung auf Driver
	-- zu �berwachen: Relationid = R/1276
	Begin
		v_exists := 0;

		Select 1
		  Into v_exists
		  From DUAL
		 Where Exists
				   (Select 1
					  From Driver
					 Where uid_Driver = :new.uid_DriverParent
					   And NVL(isInactive, 0) = 1);
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
	End;

	If v_exists = 1 Then
		v_errmsg := '#LDS#Assignment cannot take place, because the object to be assigned is disabled.|';
		raise_application_error(-20103, v_errmsg, True);
	End If;

	-- wegen IsInactive-Filterung auf Driver
	-- zu �berwachen: Relationid = R/1277
	Begin
		v_exists := 0;

		Select 1
		  Into v_exists
		  From DUAL
		 Where Exists
				   (Select 1
					  From Driver
					 Where uid_Driver = :new.uid_DriverChild
					   And NVL(isInactive, 0) = 1);
	Exception
		When NO_DATA_FOUND Then
			v_exists := 0;
	End;

	If v_exists = 1 Then
		v_errmsg := '#LDS#Assignment cannot take place, because the object to be assigned is disabled.|';
		raise_application_error(-20103, v_errmsg, True);
	End If;

end before each row;

--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is
begin

	QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-DriverMakeSortOrder'
						, null
						, null
						, v_GenProcID
						 );

	If :new.IsPhysicaldependent = 1 Then
		QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-SoftwareDependsPhysical'
							, null
							, null
							, v_GenProcID
							 );
	End If;

end after each row;


end SDL_TIDriverDependsOnDriver;
go
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle DriverDependsOnDriver
-- / Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------





--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tabelle DriverDependsOnDriver
-- Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Create Or Replace Trigger SDL_TUDriverDependsOnDriver
	After Update
	On DriverDependsOnDriver
	For Each Row
Declare
	v_GenProcID 	 QBM_GTypeDefinition.YGuid;
	
	
Begin
	v_GenProcID := QBM_GCommon2.FClientContextGetGenProcID();

	If NVL(:new.IsPhysicaldependent, 0) <> NVL(:old.IsPhysicaldependent, 0) Then
		QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-SoftwareDependsPhysical'
							, null
							, null
							, v_GenProcID
							 );
	End If;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
End SDL_TUDriverDependsOnDriver;
go


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle DriverDependsOnDriver
-- / Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
