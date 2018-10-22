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






--------------------------------------------------------------------
-- SDL_GConvert
-- PACKAGE Body
--------------------------------------------------------------------


Create Or Replace Package Body SDL_GConvert As




-----------------------------------------------------------------------------------------------
-- Function FCVADSDistinguishedName
-----------------------------------------------------------------------------------------------
Function FCVADSDistinguishedName (v_inStr varchar2)
return varchar2
as

	v_work varchar2(2000);
	v_in   varchar2(1024);
	v_i    Number;
	v_z    varchar2(10);
Begin
	v_work := '';
	v_i := 1;
	v_in := RTRIM(v_instr);

	While v_i <= LENGTH(v_in) Loop
		v_z := SUBSTR(v_in, v_i, 1);

		If INSTR(v_z, '<>\/+#;"') > 0 Then
			v_z := '\' || v_z;
		End If;

		v_work := v_work || v_z;
		v_i := v_i + 1;
	End Loop;

	Return v_work;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);



end FCVADSDistinguishedName;
-----------------------------------------------------------------------------------------------
-- / Function FCVADSDistinguishedName
-----------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------
-- Function FCVADSCommonName
-----------------------------------------------------------------------------------------------
Function FCVADSCommonName (v_inStr varchar2)
	return varchar2
as

	v_work varchar2(2000);
	v_in   varchar2(1024);
	v_i    Number;
	v_z    varchar2(10);
Begin
	v_work := '';
	v_i := 1;
	v_in := RTRIM(v_instr);

	While v_i <= LENGTH(v_in) Loop
		v_z := SUBSTR(v_in, v_i, 1);

		If INSTR(v_z, '<>\/+#;"=,') > 0 Then
			v_z := '\' || v_z;
		End If;

		v_work := v_work || v_z;
		v_i := v_i + 1;
	End Loop;

	Return v_work;
Exception
	When Others Then
		raise_application_error(-20100, 'DatabaseException', True);

end FCVADSCommonName;
-----------------------------------------------------------------------------------------------
-- / Function FCVADSCommonName
-----------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------
-- Function FCVDNToCanonical
-- bilden eines canonicalName aus einem Distinguishedname
-- es kann optional die Domain noch hinten drangehängt werden und mit nchr(6) getrennt werden
-- das braucht man bei einfachen Fullnames in NDO
-----------------------------------------------------------------------------------------------

Function FCVDNToCanonical(v_DistinguishedNameIn varchar2)
	Return varchar2 As
	v_curr_Elem 		varchar2(1000); -- momentan verarbeitetes Element aus Tabelle
	v_curr_ElemPlain	varchar2(1000); -- momentan verarbeitetes Element aus Tabelle ohne führendes DC= o.ä.

	v__pos				Number;
	v_CanonicalName 	varchar2(1000); -- das Ergebnis

	Type t__dndetails Is Table Of varchar2(1000);
	v__dndetails		t__dndetails;

	v_posi				Number;
	v_len				Number;
	v_Anteil			varchar2(1000); -- für die Zerlegung in die Tabelle, hängende Leerezichen müssen dranbleiben

	v__addon			varchar2(1000);

	v_DistinguishedName varchar2(1000);
	v_DomainPart		varchar2(64); -- Domainanteil bei NDO

Begin
	v__dndetails := t__dndetails();

	-- um den Streß mit den hängenden Leerzeichen zu vermeiden:
	v_DistinguishedName := REPLACE(v_DistinguishedNameIn, ' ', CHR(7));

	-- und hier die Sonderlocke für NDO
	If INSTR(v_DistinguishedName, '%/ou=%') > 0
	Or	INSTR(v_DistinguishedName, '%/o=%') > 0
	Or	INSTR(v_DistinguishedName, '%/c=%') > 0 Then
		-- dann haben wir einen Fullname von NDO an der Backe
		v_DistinguishedName := REPLACE(v_DistinguishedName, '/ou=', ',ou=');
		v_DistinguishedName := REPLACE(v_DistinguishedName, '/o=', ',o=');
		v_DistinguishedName := REPLACE(v_DistinguishedName, '/c=', ',c=');
	End If;

	-- nochmal Sonderlocke NDO
	If INSTR(v_DistinguishedName, CHR(6)) > 0 Then -- dann hat jemand die Domain mitgegeben
		v_DomainPart := SUBSTR(v_DistinguishedName, INSTR(v_DistinguishedName, CHR(6)) + 1, 64);
		v_DistinguishedName := SUBSTR(v_DistinguishedName, 1, INSTR(v_DistinguishedName, CHR(6)) - 1);
	Else
		v_DomainPart := Null;
	End If;

	v_curr_Elem := '';
	v__pos := 0;
	v_CanonicalName := '';

	v_len := len(v_DistinguishedName);
	v_posi := 1;
	v_Anteil := '';

	While v_posi <= v_len Loop
		If SUBSTR(v_DistinguishedName, v_posi, 1) = ',' Then
			v__dndetails.EXTEND(1);
			v__dndetails(v__dndetails.LAST) := RTRIM(LTRIM(v_anteil));
			v_anteil := '';
		Else
			v_Anteil := v_Anteil || SUBSTR(v_DistinguishedName, v_posi, 1);
		End If;

		v_posi := v_posi + 1;
	End Loop; -- while v_posi <= v_len

	-- wenn sich noch was angesammelt hat
	If len(v_anteil) > 0 Then
		v__dndetails.EXTEND(1);
		v__dndetails(v__dndetails.LAST) := RTRIM(LTRIM(v_anteil));
	End If;

	v__addon := '';

	-- nochmal Sonderlocke NDO
	If v__dndetails.COUNT = 1
   And v_Domainpart Is Not Null Then
		v_canonicalName := LTRIM(RTRIM(v_Domainpart)) || '/' || LTRIM(RTRIM(v_anteil));
		Goto ende;
	End If;

	-- von hinten nach vorn
	--	 for (int i = _dndetails.GetUpperBound(0); i >= 0; i--)

	For v_i In Reverse v__dndetails.FIRST .. v__dndetails.LAST Loop
		v_curr_Elem := v__dndetails(v_i);

		v__pos := INSTR(v_curr_Elem, '=');

		If (v__pos > 1) Then
			If SUBSTR(v_curr_Elem, v__pos - 1, 1) = '\' Then
				v__pos := 0;
			End If;
		End If;

		-- Elemnt bereinigen, um Sonderzeichenhack machen zu können
		If v__pos > 0 Then
			v_curr_ElemPlain := RTRIM(LTRIM(SUBSTR(v_curr_Elem, v__pos + 1, 1000)));
		Else
			v_curr_ElemPlain := RTRIM(LTRIM(v_curr_Elem));
		End If;

		If (v__pos > 0) Then
			If (SUBSTR(v_curr_Elem, 1, 3) = 'DC=') Then
				-- Domänenanteil
				v_curr_ElemPlain := UPPER(v_curr_ElemPlain);

				If len(v_CanonicalName) > 0 Then
					v_CanonicalName := v_curr_ElemPlain || '.' || v_CanonicalName;
				Else
					v_CanonicalName := v_curr_ElemPlain || v_CanonicalName;
				End If;
			Else -- if (left(v_curr_Elem, 3) = 'DC=')
				If len(v_CanonicalName) > 0 Then
					v_CanonicalName := v_CanonicalName || '/';
				End If;

				v_CanonicalName := v_CanonicalName || v_curr_ElemPlain || v__addon;

				v__addon := Null;
			End If;
		Else --if (_pos > 0)
			-- jedoch nur wenn überhaupt mehrere Elemente da waren
			If v__dndetails.COUNT > 1 Then
				v__addon := ',' || v_curr_ElemPlain || v__addon;
			Else
				v__addon := v_curr_ElemPlain || v__addon;
			End If;
		End If; -- else if (_pos > 0)
	End Loop;

	If (len(v__addon) > 0) Then
		v_CanonicalName := v_CanonicalName || v__addon; -- Der Rest vom Gemerkten
	End If;

	-- hier wäre jetzt die Möglichkeit noch Sonderzeichen und Maskierungen zu flöhen
	v_CanonicalName := REPLACE(v_CanonicalName, '\<', '<');
	v_CanonicalName := REPLACE(v_CanonicalName, '\>', '>');
	v_CanonicalName := REPLACE(v_CanonicalName, '\+', '+');
	v_CanonicalName := REPLACE(v_CanonicalName, '\,', ',');
	v_CanonicalName := REPLACE(v_CanonicalName, '\=', '=');
	v_CanonicalName := REPLACE(v_CanonicalName, '\#', '#');
	v_CanonicalName := REPLACE(v_CanonicalName, '\"', '"');
	v_CanonicalName := REPLACE(v_CanonicalName, '\;', ';');

	v_CanonicalName := REPLACE(v_CanonicalName, '\\', '\');

   -- / hier wäre jetzt die Möglichkeit noch Sonderzeichen und Maskierungen zu flöhen

   <<ende>>
	v_CanonicalName := REPLACE(v_CanonicalName, CHR(7), ' ');

	Return v_CanonicalName;

End FCVDNToCanonical;
-----------------------------------------------------------------------------------------------
-- / Function FCVDNToCanonical
-----------------------------------------------------------------------------------------------




end SDL_GConvert;
go

