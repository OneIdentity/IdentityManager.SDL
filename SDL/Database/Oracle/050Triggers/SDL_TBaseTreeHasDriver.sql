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
-- Tabelle BaseTreeHasDriver
-- Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



Create Or Replace Trigger SDL_TIBaseTreeHasDriver For Insert On BaseTreeHasDriver
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_DBQueueElements1 QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_DBQueueElements2 QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();

	v_UID_Org_tab QBM_GTypeDefinition.YGuidtab := QBM_GTypeDefinition.YGuidtab();

	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);



--------------------------------------------------------------------------------
-- Before each row
--------------------------------------------------------------------------------
Before each row is
begin

	QER_GBaseTree.PAssignmentCheckValid('SDL-AsgnBT-Driver', :new.UID_Org, :new.XOrigin, v_GenProcID);


	-- wegen IsInactive-Filterung auf Driver
	-- zu �berwachen: Relationid = R/642
	v_exists := 0;

	Begin
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
					  From BaseTree des, Driver elem
					 Where elem.UID_Driver = :new.UID_Driver
					   And des.UID_org = :new.UID_Org
					   And QER_GGetInfo.FGIITShopFlagCombineValid(des.XObjectKey
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
-- /11550

end before each row;

--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is
begin

	-- wenn es nur geerbte sind, m�ssen wir f�r die Kinder nicht noch einmal rechnen
	if bitand(:new.XOrigin, QBM_GGetInfo2.FGIBitPatternXOrigin('|Inherit|', 1)) > 0 then
		v_DBQueueElements1.extend(1);
		v_DBQueueElements1(v_DBQueueElements1.last).Object := :new.uid_org;
		v_DBQueueElements1(v_DBQueueElements1.last).SubObject := 'SDL-K-OrgHasDriver';
		v_DBQueueElements1(v_DBQueueElements1.last).GenProcID := v_GenProcID;
	end if;



	if :new.XIsInEffect = 1 then
		v_UID_Org_tab.extend(1);
		v_UID_Org_tab(v_UID_Org_tab.last) := :new.uid_org;
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


	QBM_GDBQueue.PDBQueueInsert_Bulk('QER-K-AllChildrenOfOrg', v_DBQueueElements1);


	select b.uid_org, null, v_GenProcID
		bulk collect into v_DBQueueElements2
		from basetree b join table(v_UID_Org_tab) vuid on b.uid_org = vuid.column_value
		where nvl(b.ITShopInfo, ' ') = 'BO';


	QBM_GDBQueue.PDBQueueInsert_Bulk('QER-K-OrgAutoChild', v_DBQueueElements2);


		select x.UID_object, null, v_GenProcID
				bulk collect into v_DBQueueElements
		  From	   (Select	hpo.uid_workdesk As uid_object
					   From WorkDeskInBasetree hpo join table(v_UID_Org_tab) vuid on hpo.uid_org = vuid.column_value
					  Where hpo.XOrigin > 0
					Union
					Select hpo.uid_workdesk As uid_object
					  From HelperWorkDeskOrg hpo join table(v_UID_Org_tab) vuid on hpo.uid_org = vuid.column_value
					 ) x;

		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-WorkdeskHasDriver', v_DBQueueElements);


		select x.UID_object, null, v_GenProcID
				bulk collect into v_DBQueueElements
		  From	   (Select hpo.uid_hardware As uid_object
					  From HardwareInBasetree hpo Join hardware h On hpo.uid_hardware = h.uid_hardware
					  join table(v_UID_Org_tab) vuid on hpo.uid_org = vuid.column_value
					 Where hpo.XOrigin > 0
					   And (h.ispc = 1
						 Or  h.isServer = 1)
					Union
					Select hpo.uid_hardware As uid_object
					  From HelperHardwareOrg hpo Join hardware h On hpo.uid_hardware = h.uid_hardware
					  join table(v_UID_Org_tab) vuid on hpo.uid_org = vuid.column_value
					 Where (h.ispc = 1
						 Or  h.isServer = 1)) x;

		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-MACHInEHasDriver', v_DBQueueElements);


	select x.column_value, null, v_GenProcID
			bulk collect into v_DBQueueElements
			from table(v_UID_Org_tab) x;

	QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-BaseTreeHasObject', v_DBQueueElements);


Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
end After statement;



end SDL_TIBaseTreeHasDriver;
go
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle BaseTreeHasDriver
-- / Event: Insert
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------




--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tabelle BaseTreeHasDriver
-- Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------




Create Or Replace Trigger SDL_TUBaseTreeHasDriver For Update On BaseTreeHasDriver
	COMPOUND TRIGGER


--------------------------------------------------------------------------------
-- Declarations
--------------------------------------------------------------------------------

	v_GenProcID 	 QBM_GTypeDefinition.YGuid := QBM_GCommon2.FClientContextGetGenProcID();
	
	

	v_DBQueueElements QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();
	v_DBQueueElements1 QBM_GTypeDefinition.YDBQueueRaw := QBM_GTypeDefinition.YDBQueueRaw();

	v_UID_Org_tab QBM_GTypeDefinition.YGuidtab := QBM_GTypeDefinition.YGuidtab();

	v_exists 		 QBM_GTypeDefinition.YBool;
	v_errmsg		  varchar2(400);



--------------------------------------------------------------------------------
-- After each row
--------------------------------------------------------------------------------
After each row is
begin

	if QER_GConvert.FCVXOriginToInheritInfo(:old.XOrigin) <> QER_GConvert.FCVXOriginToInheritInfo(:new.XOrigin) or
		QBM_GGetInfo2.FGIXOriginChanged_Effect(:old.XOrigin, :new.XOrigin, :old.XIsInEffect, :new.XIsInEffect) = 1 then
			v_DBQueueElements1.extend(1);
			v_DBQueueElements1(v_DBQueueElements1.last).Object := :old.uid_org;
			v_DBQueueElements1(v_DBQueueElements1.last).SubObject := null;
			v_DBQueueElements1(v_DBQueueElements1.last).GenProcID := v_GenProcID;
	end if;



	if (UPDATING('XOrigin') or UPDATING('XIsInEffect')) and QBM_GGetInfo2.FGIXOriginChanged_Effect(:old.XOrigin, :new.XOrigin, :old.XIsInEffect, :new.XIsInEffect) = 1 then
		v_UID_Org_tab.extend(1);
		v_UID_Org_tab(v_UID_Org_tab.last) := :old.uid_org;
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
			  From	   (Select	hpo.uid_workdesk As uid_object
						   From WorkDeskInBasetree hpo join table(v_UID_Org_tab) vuid on hpo.uid_org = vuid.column_value
						  Where hpo.XOrigin > 0
						Union
						Select hpo.uid_workdesk As uid_object
						  From HelperWorkDeskOrg hpo join table(v_UID_Org_tab) vuid on hpo.uid_org = vuid.column_value
						 ) x;

		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-WorkdeskHasDriver', v_DBQueueElements);


		select x.UID_object, null, v_GenProcID
				bulk collect into v_DBQueueElements
			  From	   (Select hpo.uid_hardware As uid_object
						  From HardwareInBasetree hpo Join hardware h On hpo.uid_hardware = h.uid_hardware
						  join table(v_UID_Org_tab) vuid on hpo.uid_org = vuid.column_value
						 Where hpo.XOrigin > 0
						   And (h.ispc = 1
							 Or  h.isServer = 1)
						Union
						Select hpo.uid_hardware As uid_object
						  From HelperHardwareOrg hpo Join hardware h On hpo.uid_hardware = h.uid_hardware
						  join table(v_UID_Org_tab) vuid on hpo.uid_org = vuid.column_value
						 Where (h.ispc = 1
							 Or  h.isServer = 1)) x;

		QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-MACHInEHasDriver', v_DBQueueElements);


	

	select x.column_value, null, v_GenProcID
			bulk collect into v_DBQueueElements
			from table(v_UID_Org_tab) x;

	QBM_GDBQueue.PDBQueueInsert_Bulk('QER-K-ShoppingRack-CheckOrgAutoChild', v_DBQueueElements);

	QBM_GDBQueue.PDBQueueInsert_Bulk('SDL-K-BaseTreeHasObject', v_DBQueueElements1);


	select x.column_value, 'SDL-K-OrgHasDriver', v_GenProcID
			bulk collect into v_DBQueueElements
			from table(v_UID_Org_tab) x;

	QBM_GDBQueue.PDBQueueInsert_Bulk('QER-K-AllChildrenOfOrg', v_DBQueueElements);


Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);
end After statement;



end SDL_TUBaseTreeHasDriver;
go



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- / Tabelle BaseTreeHasDriver
-- / Event: Update
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
