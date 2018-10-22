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


-- Für die Org-Aktualisierung Lizenzen
-- gib mir Org (root oder Lizenzknoten ) und dazu alle Kinderknoten, die mit aufzusummieren sind, geht nur für TD
--		dieser (start-) knoten hat ein bestimmtes Treelevel
-- zugehörige Knoten sind alle die, die den Lizenzknoten in BaseTreeCollection als Parent haben
--  die keinen Parent haben (mit Treelevel > Start) , außer dem eigentlichen Startknoten
-- in der Abbildung ist die rekursive Schlinge (also der Lizenzknoten selber mit enthalten)

exec QBM_PViewDrop 'SDL_VLicenceNodeSubnode'
go

-- select * from SDL_VLicenceNodeSubnode order by len(uid_org), uid_org, uid_suborg

---<istoignore/>

create view SDL_VLicenceNodeSubnode as

select l.uid_org,  c.uid_org as uid_SubOrg, aw.IsAssignmentAllowed as IsAssignmentAllowedWorkDesk
										, ah.IsAssignmentAllowed as IsAssignmentAllowedHardware
										, ap.IsAssignmentAllowed as IsAssignmentAllowedPerson
	from BaseTree l -- der lizenzknoten oder die root
		join orgroot r on l.uid_orgroot = r.uid_orgroot
				and r.istopdown = 1
		join OrgRootAssign aw on aw.uid_orgroot = r.UID_OrgRoot
							and aw.UID_BaseTreeAssign = 'QER-AsgnBT-WorkDesk'
		join OrgRootAssign ah on aw.uid_orgroot = r.UID_OrgRoot
							and aw.UID_BaseTreeAssign = 'QER-AsgnBT-Hardware'
		join OrgRootAssign ap on aw.uid_orgroot = r.UID_OrgRoot
							and aw.UID_BaseTreeAssign = 'QER-AsgnBT-Person'
		join BaseTreecollection oc on l.uid_org = oc.uid_parentorg
					and (isnull(l.uid_parentorg,'') = '' or l.islicenceNode = 1)
		join BaseTree c on oc.uid_org = c.uid_org

	where --isnull(c.islicencenode,0) = 0 and
		not exists (select top 1 1 from BaseTreecollection oc2 join BaseTree p2 on oc2.uid_parentorg = p2.uid_org
					where p2.treelevel > l.treelevel
						and p2.isLicencenode = 1
						and oc2.uid_org = c.uid_org
--						and p2.uid_org <> c.uid_org
				)
go



