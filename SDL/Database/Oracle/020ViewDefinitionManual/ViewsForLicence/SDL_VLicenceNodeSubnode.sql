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

-- F�r die Org-Aktualisierung Lizenzen
-- gib mir Org (root oder Lizenzknoten ) und dazu alle Kinderknoten, die mit aufzusummieren sind, geht nur f�r TD
--		dieser (start-) knoten hat ein bestimmtes Treelevel
-- zugeh�rige Knoten sind alle die, die den Lizenzknoten in BasetreeCollection als Parent haben
--	die keinen Parent haben (mit Treelevel > Start) , au�er dem eigentlichen Startknoten
-- in der Abbildung ist die rekursive Schlinge (also der Lizenzknoten selber mit enthalten)

Create Or Replace View SDL_VLicenceNodeSubnode As
	Select l.uid_org, c.uid_org As uid_SubOrg, aw.IsAssignmentAllowed as IsAssignmentAllowedWorkdesk
										, ah.IsAssignmentAllowed as IsAssignmentAllowedHardware
										, ap.IsAssignmentAllowed as IsAssignmentAllowedPerson
	  From basetree l -- der lizenzknoten oder die root
		   Join orgroot r On l.uid_orgroot = r.uid_orgroot And r.istopdown = 1

		join OrgRootAssign aw on aw.uid_orgroot = r.UID_OrgRoot
							and aw.UID_BasetreeAssign = 'QER-AsgnBT-Workdesk'
		join OrgRootAssign ah on aw.uid_orgroot = r.UID_OrgRoot
							and aw.UID_BasetreeAssign = 'QER-AsgnBT-Hardware'
		join OrgRootAssign ap on aw.uid_orgroot = r.UID_OrgRoot
							and aw.UID_BasetreeAssign = 'QER-AsgnBT-Person'

		   Join basetreecollection oc On l.uid_org = oc.uid_parentorg
			  And (RTRIM(l.uid_parentorg) Is Null
					Or	l.islicenceNode = 1
				)
		   Join basetree c On oc.uid_org = c.uid_org
	 Where Not Exists
			   (Select 1
				  From basetreecollection oc2 Join basetree p2 On oc2.uid_parentorg = p2.uid_org
				 Where p2.treelevel > l.treelevel
				   And p2.isLicencenode = 1
				   And oc2.uid_org = c.uid_org)

go

