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




-- Maximum der Lizenzlimits innerhalb einer Gruppe(= eigene + Ersatzlizenzen), basis ist CountLimit
-- gerechnet wird für die Anzahlen einer einzelnen Org

exec QBM_PViewDrop 'SDL_VLicLimitPerGroupAndOrg'
go

-- select * from SDL_VLicLimitPerGroupAndOrg order by uid_GroupRoot


---<istoignore/>

create view SDL_VLicLimitPerGroupAndOrg as

 select uid_org, UID_GroupRoot, max(CountLimit) as MaxLimit
	from SDL_VLicLimitPerLicenceAndOrg
	group by uid_org, UID_GroupRoot
go


