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
-- View SDL_VADSNearestAppContainer
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

exec QBM_PViewDrop 'SDL_VADSNearestAppContainer'
go


-- Aufrufbeispiele: 
--	select * from SDL_VADSNearestAppContainer order by 1

-- 	select * from SDL_VADSNearestAppContainer where uid_accountContainer = 'fd2c3486-94a2-11d6-b1e4-00508b8f0145'

-- 	select n.regel, left(a.canonicalname,70) as Account, c.canonicalname as Applikation from
--		adscontainer a join    SDL_VADSNearestAppContainer n on a.uid_adscontainer = n.uid_accountContainer
--				join adscontainer c on n.uid_appcontainer = c.uid_adscontainer
--	  order by account



-- select CanonicalName from adscontainer where canonicalname like 'dhw2k01.testlab.dd%' order by canonicalname

-- Verwendung erfolgt ausschließlich innerhalb alter VI-App-Profil Handling, deshalb:
---<istoignore/>

create view SDL_VADSNearestAppContainer 
-- with encryption
  as

 select uid_AccountContainer, rtrim(right(max(sort1), 38)) as uid_AppContainer , substring(max(sort1), 2,1) as Regel from 
 (
 select  x.uid_adscontainer as uid_AccountContainer, N'E1' + convert(nchar(1000), isnull(c.canonicalname,N'') )+ convert(nchar(255), isnull(c.cn,N'') )+ convert(nchar(38), c.uid_adscontainer) as sort1 
	from adscontainer c, adscontainer x
	where c.uid_adscontainer = x.uid_adscontainer 
	and c.isappcontainer = 1
  union all
  select /* , n.uid_adscontainer*/  x.uid_adscontainer, N'D2' + convert(nchar(1000), isnull(n.canonicalname,N'') )+ convert(nchar(255),  isnull(n.cn,N'') )+ convert(nchar(38), n.uid_adscontainer)
	from adscontainer c, adscontainer x, adscontainer n
	where c.uid_adscontainer = x.uid_adscontainer 
		and isnull(c.uid_parentadscontainer,'') = isnull(n.uid_parentadscontainer,'')    -- wegen dem leeren vorgnger
	-- wenn kein Parent, dann zustzlich aufpassen, da es die selbe domäne ist
		and c.UID_ADSDomain = n.UID_ADSDomain
		and c.uid_adscontainer <> n.uid_adscontainer
		and n.isappcontainer = 1
 union all
  select  /* v.uid_adscontainer ,*/  x.uid_adscontainer, N'C3'  + convert(nchar(1000), isnull(v.canonicalname,N'') )+ convert(nchar(255), isnull(v.cn,N'')  ) + convert(nchar(38), v.uid_adscontainer )
	from adscontainer c, adscontainer x, adscontainer v
	where c.uid_adscontainer = x.uid_adscontainer 
		and c.canonicalname like v.canonicalname + N'/%'
		and c.UID_ADSDomain = v.UID_ADSDomain
		and v.isappcontainer = 1
 union all
  select  /* n.uid_adscontainer , */  x.uid_adscontainer, N'B4' + convert(nchar(1000), isnull(v.canonicalname,N'')  ) + convert(nchar(1000), isnull(n.canonicalname,N'') ) + convert(nchar(38), n.uid_adscontainer)
     -- v.canonicalname  is wichtig, damit erstmal nach Hauptpfad der dichteste und dann dessen parallele kommen
	from adscontainer c, adscontainer x, adscontainer v, adscontainer n
	where c.uid_adscontainer = x.uid_adscontainer 
		and c.canonicalname like v.canonicalname + N'/%'
		and c.UID_ADSDomain = v.UID_ADSDomain
		and isnull(v.uid_parentadscontainer,'') = isnull(n.uid_parentadscontainer,'')   -- wegen dem leeren vorgnger
      -- wenn kein Parent, dann zustzlich aufpassen, da es die selbe domäne ist
		and c.UID_ADSDomain = n.UID_ADSDomain
		and v.uid_adscontainer <> n.uid_adscontainer
		and n.isappcontainer = 1
 union all
-- ein beliebiger
  select  /* v.uid_adscontainer ,*/  u.uid_adscontainer, N'A5'  + convert(nchar(1000), isnull(v.canonicalname,N'') )+ convert(nchar(255), isnull(v.cn,N'')  ) + convert(nchar(38), v.uid_adscontainer )
	from adscontainer v, adscontainer u
	where v.isappcontainer = 1
		and u.UID_ADSDomain = v.UID_ADSDomain

 ) as x
 group by uid_AccountContainer

go


