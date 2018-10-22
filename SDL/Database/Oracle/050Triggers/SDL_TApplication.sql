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
-- Tabelle Application
-- Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


Create Or Replace Trigger SDL_TUApplication For Update On Application
	COMPOUND TRIGGER

--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);



--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is
begin

	If updating('Ident_Sectionname') or updating('IsPersonOnly') or updating('IsWorkdeskOnly') Then
			v_DBQueueElements.extend(1);
			v_DBQueueElements(v_DBQueueElements.last).Object := :new.UID_Application;
			v_DBQueueElements(v_DBQueueElements.last).SubObject := '%';
			v_DBQueueElements(v_DBQueueElements.last).GenProcID := v_GenProcID;
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

	QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-AllADSAccountsForApplication', v_DBQueueElements);

	QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-AllLDAPAccountsForApplication', v_DBQueueElements);

	QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-AllMachinesForApplication', v_DBQueueElements);


Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
end After statement;

end SDL_TUApplication;
go


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle Application
-- / Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------





--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tabelle Application
-- Event: Delete
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



Create Or Replace Trigger SDL_TDApplication For Delete On Application
	COMPOUND TRIGGER

--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);




--------------------------------------------------------------------------------
-- After Statement
--------------------------------------------------------------------------------
After Statement is
begin

	QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-SoftwareDependsPhysical'
						, null
						, null
						, v_GenProcID
						 );
	QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-ApplicationMakeSortOrder'
						, null
						, null
						, v_GenProcID
						 );


Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
end After statement;

end SDL_TDApplication;
go



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle Application
-- / Event: Delete
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------







--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tabelle Application
-- Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------




Create Or Replace Trigger SDL_TIApplication For Insert On Application
	COMPOUND TRIGGER

--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);




--------------------------------------------------------------------------------
-- After Statement
--------------------------------------------------------------------------------
After Statement is
begin

	QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-ApplicationMakeSortOrder'
						, null
						, null
						, v_GenProcID
						 );


Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
end After statement;

end SDL_TIApplication;
go



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle Application
-- / Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
