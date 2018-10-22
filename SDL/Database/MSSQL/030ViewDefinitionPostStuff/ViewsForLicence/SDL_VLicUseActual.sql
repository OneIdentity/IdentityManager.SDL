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
-- View SDL_VLicUseActual
--------------------------------------------------------------------------------------
-- liefert den Verbrauch je Lizenz nach IstZustand laut ClientInstall-Feedback
--	unter Berücksichtigung der Lizenzierungsart 

exec QBM_PViewDrop 'SDL_VLicUseActual'
go

-- select * from SDL_VLicUseActual

---<istoignore/>

create view SDL_VLicUseActual as
select l.UID_Licence, 
            case
            when isnull(lt.IsPerUser, 0) = 1 then
                        isnull(l.CountLicUserActual, 0)
            when isnull(lt.IsPerCompany, 0) = 1 then
                        isnull(l.CountLicMacDirectActual, 0) + isnull(l.CountLicMacIndirectActual, 0)
            else
                        -- Default: Berechnung nach Maschinen
                        isnull(l.CountLicMacDirectActual, 0) + isnull(l.CountLicMacIndirectActual, 0) + isnull(l.CountLicMacPossActual, 0)
            end
            as CountUse
from Licence l left outer join LicenceType lt on l.UID_LicenceType = lt.UID_LicenceType
go

 
