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

-------------------------------------------------------------------------------
-- View SDL_VADSNearestAppContainer
-------------------------------------------------------------------------------

--bestimmen des n�chstliegenden Applikationscontainers
-- Pr�ferenzregeln:
-- 1. der eigene Container
-- 2. ein parallel zum eigenen Container liegender Container
   -- 2.a falls auf dem Baum-Niveau mehrere Parallel-Container : von diesen der nach canonicalname alphabetisch letzte
-- 3. ein Vorg�nger-Container in richtung Root,
   -- 3.a falls mehrere, dann derjenige mit dem l�ngsten Pfad, also der k�rzesten relativen Entfernung zum Account-Container
-- 4. ein parallel zu einem Vorg�nger-Container liegender Container
   -- 4.a von diesen derjenige mit dem l�ngsten Pfad, also der k�rzesten relativen Entfernung zum Account-Container
  -- 4.a.1 falls auf dem Baum-Niveau mehrere Parallel-Container :von diesen der nach canonicalname alphabetisch letzte
-- 5. ein beliebiger als Applikationscontainer gekennzeichneter
  --5.a falls mehrere, dann derjenige mit dem l�ngsten Pfad

Create Or Replace View SDL_VADSNearestAppContainer As
	  Select uid_AccountContainer
		   , RTRIM(SUBSTR(MAX(sort1), (len(MAX(sort1)) - 37), 38)) As uid_AppContainer
		   , SUBSTR(MAX(sort1), 2, 1) As Regel
		From (Select x.uid_adscontainer As uid_AccountContainer
				   , 'E1' || RPAD(c.canonicalname, 1000, ' ') || RPAD(c.cn, 255, ' ') || RPAD(c.uid_adscontainer, 38, ' ') As sort1
				From adscontainer c, adscontainer x
			   Where c.uid_adscontainer = x.uid_adscontainer
				 And c.isappcontainer = 1
			  Union All
			  Select x.uid_adscontainer
				   , 'D2' || RPAD(n.canonicalname, 1000, ' ') || RPAD(n.cn, 255, ' ') || RPAD(n.uid_adscontainer, 38, ' ')
				From adscontainer c, adscontainer x, adscontainer n
			   Where c.uid_adscontainer = x.uid_adscontainer
				 And (RTRIM(c.uid_parentadscontainer) = RTRIM(n.uid_parentadscontainer)
				   Or  (RTRIM(c.uid_parentadscontainer) Is Null
					And RTRIM(n.uid_parentadscontainer) Is Null)) -- wegen dem leeren vorg�nger
				 -- wenn kein Parent, dann zus�tzlich aufpassen, da� es die selbe Domain ist
				 And c.UID_ADSDomain = n.UID_ADSDomain
				 And c.uid_adscontainer <> n.uid_adscontainer
				 And n.isappcontainer = 1
			  Union All
			  Select x.uid_adscontainer
				   , 'C3' || RPAD(v.canonicalname, 1000, ' ') || RPAD(v.cn, 255, ' ') || RPAD(v.uid_adscontainer, 38, ' ')
				From adscontainer c, adscontainer x, adscontainer v
			   Where c.uid_adscontainer = x.uid_adscontainer
				 And c.canonicalname Like v.canonicalname || '/%'
				 And c.UID_ADSDomain = v.UID_ADSDomain
				 And v.isappcontainer = 1
			  Union All
			  Select x.uid_adscontainer
				   , 'B4' || RPAD(v.canonicalname, 1000, ' ') || RPAD(n.canonicalname, 1000, ' ') || RPAD(n.uid_adscontainer, 38, ' ')
				-- v.canonicalname is wichtig, damit erstmal nach Hauptpfad der dichteste und dann dessen parallele kommen
				From adscontainer c
				   , adscontainer x
				   , adscontainer v
				   , adscontainer n
			   Where c.uid_adscontainer = x.uid_adscontainer
				 And c.canonicalname Like v.canonicalname || '/%'
				 And c.UID_ADSDomain = v.UID_ADSDomain
				 And (RTRIM(v.uid_parentadscontainer) = RTRIM(n.uid_parentadscontainer)
				   Or  (RTRIM(v.uid_parentadscontainer) Is Null
					And RTRIM(n.uid_parentadscontainer) Is Null)) -- wegen dem leeren vorg�nger
				 -- wenn kein Parent, dann zus�tzlich aufpassen, da� es die selbe Domain ist
				 And c.UID_ADSDomain = n.UID_ADSDomain
				 And v.uid_adscontainer <> n.uid_adscontainer
				 And n.isappcontainer = 1
			  Union All
			  -- ein beliebige
			  Select u.uid_ADScontainer
				   , 'A5' || RPAD(v.canonicalname, 1000, ' ') || RPAD(v.cn, 255, ' ') || RPAD(v.uid_ADScontainer, 38, ' ')
				From ADScontainer v, ADSContainer u
			   Where v.isappcontainer = 1
				 And u.UID_ADSDomain = v.UID_ADSDomain) y
	Group By uid_AccountContainer

go



Begin
	QBM_GSchema.PSourcesCheckValid('SDL_VADSNearestAppContainer');
End;
go