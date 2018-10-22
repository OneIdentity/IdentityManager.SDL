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
-- Tabelle Driver
-- Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Create Or Replace Trigger SDL_TUDriver For Update On Driver
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);



	v_itshop_uid QBM_GTypeDefinition.YGuidtab := QBM_GTypeDefinition.YGuidtab();
	v_itshop_xobj QBM_GTypeDefinition.YobjectKeytab := QBM_GTypeDefinition.YobjectKeytab();

	v_whereclauseOrg	varchar2(8000);
	v_whereclauseMuster varchar2(8000) := ' UID_ITShopOrg in ( select uid_orgPR 
															from QER_VPWOProductNodesSlim
															where objectkeyOrdered = ''v_objectkeyordered''
																and nvl(uid_accproduct,'' '') <> ''v_uid_accproduct''
													)
												';


--------------------------------------------------------------------------------
-- Before each row
--------------------------------------------------------------------------------
Before each row is
begin

	-- wegen Buglist 7645:
	If RTRIM(:old.UID_OS) <> RTRIM(:new.UID_OS) Then
		Select COUNT(*)
		  Into v_exists
		  From machinehasdriver
		 Where uid_driver = :new.uid_driver;

		If v_exists > 0 Then
			raise_application_error(-20101, 'Cannot change operating system because the driver is still assigned to machines.', True);
		End If;
	End If;

	---------------------------------------------------------------------------
	-- Tests bei Ver�nderung der ITShopFlags (IsForITShop, IsITShopOnly)
	---------------------------------------------------------------------------

	If UPDATING('isForITShop')
	Or	UPDATING('isITShopOnly') Then
		-- Test 0/1
		If :new.IsForITShop = 0
	   And :new.IsITShopOnly = 1 Then
			v_errmsg := '#LDS#Invalid flag combination for IsForITShop and IsITShopOnly.|';
			raise_application_error(-20101, v_errmsg, True);
		End If;

		-- Test 0/0
		-- unzul�ssig, wenn es Zuweisungen des Elementes zu basetree ITShopOrg gibt
		If :new.IsForITShop = 0
	   And :new.IsITShopOnly = 0 Then
			Begin
				v_exists := 0;

				Select 1
				  Into v_exists
				  From DUAL
				 Where Exists
						   (Select 1
							  From BasetreehasDriver bha Join basetree b On bha.uid_org = b.uid_Org
							 Where bha.uid_Driver = :new.uid_Driver and bha.XOrigin > 0
							   and b.XObjectKey like '<Key><T>ITShop___</T>%'
							 );
			Exception
				When NO_DATA_FOUND Then
					v_exists := 0;
			End;

			If v_exists = 1 Then
				v_errmsg := '#LDS#Changes cannot take place, because assignments still exist within IT Shop structures.|';
				raise_application_error(-20101, v_errmsg, True);
			End If;
		End If;

		-- test 1/1
		If :new.IsForITShop = 1
	   And :new.IsITShopOnly = 1 Then
			-- nur dann machen wir uns die M�he, weiter zu suchen
			-- unzul�ssig, wenn es Zuweisungen zu Basetree <> ITShop gibt
			Begin
				v_exists := 0;

				Select 1
				  Into v_exists
				  From DUAL
				 Where Exists
						   (Select 1
							  From BasetreehasDriver bha Join basetree b On bha.uid_org = b.uid_Org
							 Where bha.uid_Driver = :new.uid_Driver and bha.XOrigin > 0
							   and b.XObjectKey not like '<Key><T>ITShop___</T>%'
							 );
			Exception
				When NO_DATA_FOUND Then
					v_exists := 0;
			End;

			If v_exists = 1 Then
				v_errmsg := '#LDS#Changes cannot take place, because assignments still exist outside IT Shop structures.|';
				raise_application_error(-20101, v_errmsg, True);
			End If;

			-- unzul�ssig, wenn es Zuweisungen zu Person, Workdesk, ... gibt
			Begin
				v_exists := 0;

				Select 1
				  Into v_exists
				  From DUAL
				 Where Exists
						   (Select 1
							  From MachineHasDriver zuw
							 Where zuw.uid_Driver = :new.uid_Driver and zuw.XOrigin > 0
							 )
					Or	Exists
							(Select 1
							   From WorkDeskHasDriver zuw
							  Where zuw.uid_Driver = :new.uid_Driver and zuw.XOrigin > 0
							  );
			Exception
				When NO_DATA_FOUND Then
					v_exists := 0;
			End;

			If v_exists = 1 Then
				v_errmsg := '#LDS#Changes cannot take place because direct assignments still exist.|';
				raise_application_error(-20101, v_errmsg, True);
			End If;

			-- unzul�ssig bei EsetHasEntitlement als Entitlement auftretend und die UID_Eset hat 0/0
			Begin
				v_exists := 0;

				Select 1
				  Into v_exists
				  From DUAL
				 Where Exists
						   (Select 1
							  From ESetHasEntitlement ehe Join ESet e On ehe.uid_ESet = e.uid_Eset
							 Where ehe.Entitlement = :new.XObjectKey and ehe.XOrigin > 0
							   And e.IsITShopOnly = 0);
			Exception
				When NO_DATA_FOUND Then
					v_exists := 0;
			End;

			If v_exists = 1 Then
				v_errmsg := '#LDS#Changes cannot take place, because assignments to system roles still exist that may not be used exclusively in IT Shop.|';
				raise_application_error(-20101, v_errmsg, True);
			End If;
		End If; -- if :new.IsForITShop = 1 and :new.IsITShopOnly = 1 then
	End If; -- if UPDATING('isForITShop') or UPDATING ('isITShopOnly') then
---------------------------------------------------------------------------
-- / Tests bei Ver�nderung der ITShopFlags (IsForITShop, IsITShopOnly)
---------------------------------------------------------------------------

end before each row;

--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is
begin

	If (:new.Ident_SectionName <> :old.Ident_SectionName)
	Or	(:new.Ident_SectionName Is Null
	 And :old.Ident_SectionName Is Not Null)
	Or	(:new.Ident_SectionName Is Not Null
	 And :old.Ident_SectionName Is Null) Then
		QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-AllMachinesForDriver'
							, :new.UID_Driver
							, null
							, v_GenProcID
							 );
	End If;

	If NVL(:old.UID_Accproduct, ' ') <> NVL(:new.UID_AccProduct, ' ') And :old.UID_AccProduct Is Not Null Then

		v_itshop_uid.extend(1);
		v_itshop_uid(v_itshop_uid.last) := :new.uid_accproduct;
	
		v_itshop_xobj.extend(1);
		v_itshop_xobj(v_itshop_xobj.last) := :new.XObjectKey;

	End If;

end after each row;



--------------------------------------------------------------------------------
-- After Statement
--------------------------------------------------------------------------------
After Statement is
begin

	if v_itshop_uid.count > 0 then
		
		begin
			v_exists := 0;
			select 1 into v_exists from dual where exists
				(select 1 
					from dialogcolumn
					where UID_DialogTable = 'QER-T-ITShopOrg'
					and ColumnName = 'UID_AccProduct'
					and IsDeactivatedByPreProcessor = 0);
			exception
			when no_data_found then
			v_exists := 0;
		end;

		if v_exists = 1 then
			for i in v_itshop_uid.first..v_itshop_uid.last loop

				v_whereclauseOrg := v_whereclauseMuster;
				v_whereclauseOrg := REPLACE(v_whereclauseOrg, 'v_objectkeyordered', v_itshop_xobj(i));
				v_whereclauseOrg := REPLACE(v_whereclauseOrg, 'v_uid_accproduct', v_itshop_uid(i));
				QBM_GJobQueue.PJobCreate_HOUpdate_B('ITShopOrg'
													, v_whereclauseOrg
													, v_GenProcID
													, v_p1 => 'UID_AccProduct'
													, v_v1 => v_itshop_uid(i)
													);
			end loop;
		end if;
	end if;

end After statement;



end SDL_TUDriver;
go
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle Driver
-- / Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------








--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tabelle Driver
-- Event: Delete
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


Create Or Replace Trigger SDL_TDDriver For Delete On Driver
	COMPOUND TRIGGER

--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	



--------------------------------------------------------------------------------
-- Before Statement
--------------------------------------------------------------------------------
Before Statement is

begin


	QBM_GSemaphor.PTriggerSemaphorSet('DriverIsDeleting');

Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
end before statement;



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


	QBM_GSemaphor.PTriggerSemaphorReSet('DriverIsDeleting');

Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
end After statement;

end SDL_TDDriver;
go
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle Driver
-- / Event: Delete
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

	





--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tabelle Driver
-- Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Create Or Replace Trigger SDL_TIDriver
	After Insert
	On Driver
Declare
	v_GenProcID 	 QBM_GTypeDefinition.YGuid;
	
	
Begin
	v_GenProcID := QBM_GCommon2.FClientContextGetGenProcID();

	QBM_GDBQueue.PDBQueueInsert_Single('SDL-K-DriverMakeSortOrder'
						, null
						, null
						, v_GenProcID
						 );
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
End SDL_TIDriver;
go

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle Driver
-- / Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
