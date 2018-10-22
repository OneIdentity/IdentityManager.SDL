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
-- SDL_GTempTableDef
-- Package Body
-----------------------------------------------------------------------------------------------


Create Or Replace Package Body SDL_GTempTableDef As


-----------------------------------------------------------------------------------------------
-- Procedure PCreateTempTable
-- anlegen eienr temporären Tabelle, evt. vorhandene vorher löschen
-----------------------------------------------------------------------------------------------
Procedure PCreateTempTable (v_TableName varchar2)
as
	v_exists QBM_GTypeDefinition.YBool;
begin



	---------------------------------------------------------------------------------------------------------
	-- Arbeitstabellen für Prozedur SDL_GSoftwareDistribution.PRepairAppServerGotXX
	---------------------------------------------------------------------------------------------------------
    if upper(v_TableName) = 'TEMP_CHILDSERVER' then
		Begin
			Select 1
			  Into v_exists
			  From DUAL
			 Where Exists
					   (Select 1
						  From user_tables
						 Where UPPER(table_name) = 'TEMP_CHILDSERVER'
						   And temporary = 'Y');
		Exception
			When NO_DATA_FOUND Then
				v_exists := 0;
		End;

		If v_exists = 1 Then
			-- nix zu tun
			Execute Immediate 'DROP TABLE TEMP_CHILDSERVER';
		End If;

		Execute Immediate 'CREATE GLOBAL TEMPORARY TABLE TEMP_ChildServer 
										(UID_ChildServer varchar2(38)) ON COMMIT PRESERVE ROWS';
	end if;



Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);


end PCreateTempTable;
-----------------------------------------------------------------------------------------------
-- / Procedure PCreateTempTable
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-- Procedure PCreateTempTable
-- anlegen der temporären Tabellen des Moduls SDL, evt. vorhandene vorher löschen
-----------------------------------------------------------------------------------------------
Procedure PCreateTempTable
as

begin

	PCreateTempTable('TEMP_CHILDSERVER');



Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);


end PCreateTempTable;
-----------------------------------------------------------------------------------------------
-- / Procedure PCreateTempTable
-----------------------------------------------------------------------------------------------







End SDL_GTempTableDef;
go
