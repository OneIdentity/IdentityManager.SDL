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






-----------------------------------------------------------------------------------------------
-- SDL_GLateBindingImpl
-- Package Body
-----------------------------------------------------------------------------------------------


Create Or Replace Package Body SDL_GLateBindingImpl As


-----------------------------------------------------------------------------------------------
-- Procedure PHardwareAction
-- fügt den Auftrag 'SDL-K-HardwareUpdateCNAME' in die DBQueue
-----------------------------------------------------------------------------------------------
Procedure PHardwareAction(v_Slotnumber number)
as
	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();

begin

	Select cu.UID_Parameter, cu.UID_SubParameter, cu.GenProcID
		bulk collect into v_DBQueueElements
		From QBMDBQueueCurrent cu
		where cu.SlotNumber = v_SlotNumber;

	QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-HardwareUpdateCNAME', v_DBQueueElements);


Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);

end PHardwareAction;
-----------------------------------------------------------------------------------------------
-- / Procedure PHardwareAction
-----------------------------------------------------------------------------------------------




end SDL_GLateBindingImpl;
go

