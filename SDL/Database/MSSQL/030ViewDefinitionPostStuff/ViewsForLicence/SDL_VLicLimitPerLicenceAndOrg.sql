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


-- Maximale CountItems verfügbarer Lizenzen (= eigene + Ersatzlizenzen), basis ist CountLimit
-- gerechnet wird für die Anzahlen einer einzelnen Org

exec QBM_PViewDrop 'SDL_VLicLimitPerLicenceAndOrg'
go

-- select * from SDL_VLicLimitPerLicenceAndOrg order by uid_licence


---<istoignore/>

create view SDL_VLicLimitPerLicenceAndOrg as

 select bhl.uid_org, st.UID_Licence, st.UID_GroupRoot , sum(isnull(bhl.CountLimit,0)) as CountLimit
		from licencesubstitutetotal st join  BaseTreeHasLicence bhl on st.uid_licenceSubstitute = bhl.uid_licence 
   group by bhl.uid_org, st.uid_licence, st.UID_GroupRoot
go


