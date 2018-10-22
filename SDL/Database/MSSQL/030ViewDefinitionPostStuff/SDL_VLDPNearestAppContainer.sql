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





-------------------------------------------------------------------------------------------------
-- View SDL_VLDPNearestAppContainer
-------------------------------------------------------------------------------------------------


--bestimmen des nächstliegenden Applikationscontainers
-- Präferenzregeln: 
-- 1. der eigene Container
-- 2. ein parallel zum eigenen Container liegender Container
   -- 2.a falls auf dem Baum-Niveau mehrere Parallel-Container : von diesen der nach canonicalname alphabetisch letzte
-- 3. ein Vorgänger-Container in Richtung Root, 
   -- 3.a falls mehrere, dann derjenige mit dem längsten Pfad, also der krzesten relativen Entfernung zum Account-Container
-- 4. ein parallel zu einem Vorgänger-Container liegender Container
   -- 4.a von diesen derjenige mit dem längsten Pfad, also der kürzesten relativen Entfernung zum Account-Container
  -- 4.a.1 falls auf dem Baum-Niveau mehrere Parallel-Container :von diesen der nach canonicalname alphabetisch letzte
-- 5. ein beliebiger als Applikationscontainer gekennzeichneter
  --5.a falls mehrere, dann derjenige mit dem längsten Pfad


exec QBM_PViewDrop 'SDL_VLDPNearestAppContainer'
go


-- Aufrufbeispiele: 
--	select * from SDL_VLDPNearestAppContainer




-- Verwendung erfolgt ausschließlich innerhalb alter VI-App-Profil Handling, deshalb:
---<istoignore/>

create view SDL_VLDPNearestAppContainer 
-- with encryption
  as

 select uid_AccountContainer, rtrim(right(max(sort1), 38)) as uid_AppContainer , substring(max(sort1), 2,1) as Regel from 
 (
 select  x.uid_LDAPcontainer as uid_AccountContainer, N'E1' + convert(nchar(1000), isnull(c.CanonicalName, N'') )+ convert(nchar(400), isnull(c.cn,N'') )+ convert(nchar(38), c.uid_LDAPcontainer) as sort1 
	from LDAPcontainer c, LDAPcontainer x
	where c.uid_LDAPcontainer = x.uid_LDAPcontainer 
	and c.isappcontainer = 1
  union all
  select x.uid_LDAPcontainer, N'D2' + convert(nchar(1000), isnull(c.CanonicalName, N'') )+ convert(nchar(400),  isnull(n.cn,N'') )+convert(nchar(38), n.uid_LDAPcontainer)
	from LDAPcontainer c, LDAPcontainer x, LDAPcontainer n
	where c.uid_LDAPcontainer = x.uid_LDAPcontainer 
		and isnull(c.uid_parentLDAPcontainer,'') = isnull(n.uid_parentLDAPcontainer,'')    -- wegen dem leeren vorgnger
	-- wenn kein Parent, dann zustzlich aufpassen, da es die selbe domäne ist
		and c.UID_LDPDomain  = n.UID_LDPDomain
		and c.uid_LDAPcontainer <> n.uid_LDAPcontainer
		and n.isappcontainer = 1
 union all
  select    x.uid_LDAPcontainer, N'C3'  + convert(nchar(1000), isnull(c.CanonicalName, N'') )+ convert(nchar(400), isnull(v.cn,N'')  ) + convert(nchar(38), v.uid_LDAPcontainer )
	from LDAPcontainer c, LDAPcontainer x, LDAPcontainer v
	where c.uid_LDAPcontainer = x.uid_LDAPcontainer 
		and c.CanonicalName like v.CanonicalName + N'/%'
		and c.UID_LDPDomain = v.UID_LDPDomain
		and v.isappcontainer = 1
 union all
  select   x.uid_LDAPcontainer, N'B4' + convert(nchar(1000), isnull(v.CanonicalName, N'')  ) + convert(nchar(1000), isnull(n.CanonicalName, N'') ) + convert(nchar(38), n.uid_LDAPcontainer)
     -- v.canonicalname  is wichtig, damit erstmal nach Hauptpfad der dichteste und dann dessen parallele kommen
	from LDAPcontainer c, LDAPcontainer x, LDAPcontainer v, LDAPcontainer n
	where c.uid_LDAPcontainer = x.uid_LDAPcontainer 
		and c.CanonicalName like v.CanonicalName + N'/%'
		and c.UID_LDPDomain = v.UID_LDPDomain
		and isnull(v.uid_parentLDAPcontainer,'') = isnull(n.uid_parentLDAPcontainer,'')   -- wegen dem leeren vorgnger
      -- wenn kein Parent, dann zustzlich aufpassen, da es die selbe domäne ist
		and c.UID_LDPDomain = n.UID_LDPDomain
		and v.uid_LDAPcontainer <> n.uid_LDAPcontainer
		and n.isappcontainer = 1
 union all
-- ein beliebige	
  select    u.uid_LDAPcontainer, N'A5'  + convert(nchar(1000), isnull(v.CanonicalName, N'') )+ convert(nchar(400), isnull(v.cn,N'')  ) + convert(nchar(38), v.uid_LDAPcontainer )
	from LDAPcontainer v, LDAPContainer u
	where v.isappcontainer = 1
		and u.UID_LDPDomain = v.UID_LDPDomain
 ) as x
 group by uid_AccountContainer

go


