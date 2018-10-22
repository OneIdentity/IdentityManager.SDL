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

--------------------------------------------------------------------------------------
-- View SDL_VLicUseTargetOrg
--------------------------------------------------------------------------------------
-- liefert die Lizenzen und den Verbrauch je Org nach Sollzustand (Personhas..., Workdeskhas...)
--	unter Ber�cksichtigung der Lizenzierungsart

Create Or Replace View SDL_VLicUseTargetOrg As
	Select o.uid_org
		 , o.UID_Licence
		 , Case
			   When NVL(lt.IsPerUser, 0) = 1 Then NVL(o.CountLicUserTarget, 0)
			   When NVL(lt.IsPerCompany, 0) = 1 Then NVL(o.CountLicMacDirectTarget, 0) + NVL(o.CountLicMacIndirectTarget, 0)
			   Else -- Default: Berechnung nach Maschinen
				   NVL(o.CountLicMacDirectTarget, 0) + NVL(o.CountLicMacIndirectTarget, 0) + NVL(o.CountLicMacPossTarget, 0)
		   End
			   As CountUse
	  From basetreeHasLicence o
		   Join Licence l
			   On o.uid_licence = l.uid_licence
		   Left Outer Join LicenceType lt
			   On l.UID_LicenceType = lt.UID_LicenceType

go

