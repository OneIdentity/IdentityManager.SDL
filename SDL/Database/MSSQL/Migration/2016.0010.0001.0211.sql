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

--
-- ONE IDENTITY LLC. PROPRIETARY INFORMATION
--
-- This software is confidential.  One Identity, LLC. or one of its affiliates or
-- subsidiaries, has supplied this software to you under terms of a
-- license agreement, nondisclosure agreement or both.
--
-- You may not copy, disclose, or use this software except in accordance with
-- those terms.
--
--
-- Copyright 2017 One Identity LLC.
-- ALL RIGHTS RESERVED.
--
-- ONE IDENTITY LLC. MAKES NO REPRESENTATIONS OR
-- WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE,
-- EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
-- TO THE IMPLIED WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE, OR
-- NON-INFRINGEMENT.  ONE IDENTITY LLC. SHALL NOT BE
-- LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE
-- AS A RESULT OF USING, MODIFYING OR DISTRIBUTING
-- THIS SOFTWARE OR ITS DERIVATIVES.
--

if not exists (select 1 
				from DialogConfigParm p
				where p.UID_ConfigParm = 'SDL-620A0EF0564A46B3894795928A8E467E'
			)
 begin
	insert into DialogConfigParm(UID_ConfigParm, FullPath , ConfigParm, UID_ParentConfigparm, Value,  XObjectKey, Enabled)
			select 'SDL-620A0EF0564A46B3894795928A8E467E', 'Software\Inventory', 'Inventory', 'APC-48674bf05dc04866bd78a6501acd9ee7'  /* parentuid */, '1' /*value */
			, '<Key><T>DialogConfigParm</T><P>SDL-620A0EF0564A46B3894795928A8E467E</P></Key>', 1
 
 
	insert into DialogConfigParmOption (UID_DialogConfigParmOption, UID_ConfigParm, OptionValue, XObjectKey)
	select 'SDL-1393AD545BB5489D9F36A9832F18A0D4', 'SDL-620A0EF0564A46B3894795928A8E467E',  '1'
		, '<Key><T>DialogConfigParmOption</T><P>SDL-1393AD545BB5489D9F36A9832F18A0D4</P></Key>'

 end
go
if not exists (select 1 
				from DialogConfigParm p
				where p.UID_ConfigParm = 'SDL-50A1A8F1160E4EC6A7C7E30C81CD3804'
			)
 begin
	insert into DialogConfigParm(UID_ConfigParm, FullPath , ConfigParm, UID_ParentConfigparm, Value,  XObjectKey, Enabled)
			select 'SDL-50A1A8F1160E4EC6A7C7E30C81CD3804', 'Software\Inventory\MaxAge', 'MaxAge', 'SDL-620A0EF0564A46B3894795928A8E467E', '1'
			, '<Key><T>DialogConfigParm</T><P>SDL-50A1A8F1160E4EC6A7C7E30C81CD3804</P></Key>', 1

	insert into DialogConfigParmOption (UID_DialogConfigParmOption, UID_ConfigParm, OptionValue, XObjectKey)
	select 'SDL-c135a67fd0d548aab6cdbc857ec16e9b', 'SDL-50A1A8F1160E4EC6A7C7E30C81CD3804', '1'
		, '<Key><T>DialogConfigParmOption</T><P>SDL-c135a67fd0d548aab6cdbc857ec16e9b</P></Key>'

 end
go
if not exists (select 1 
				from DialogConfigParm p
				where p.UID_ConfigParm = 'SDL-39EEF6D7B5614101A507BCD72FFCB051'
			)
 begin
	insert into DialogConfigParm(UID_ConfigParm, FullPath , ConfigParm, UID_ParentConfigparm, Value,  XObjectKey, Enabled)
			select 'SDL-39EEF6D7B5614101A507BCD72FFCB051', 'Software\Inventory\MaxAge\ClientLog', 'ClientLog',  'SDL-50A1A8F1160E4EC6A7C7E30C81CD3804', '2'
			, '<Key><T>DialogConfigParm</T><P>SDL-39EEF6D7B5614101A507BCD72FFCB051</P></Key>', 1 
 end
go
if not exists (select 1 
				from DialogConfigParm p
				where p.UID_ConfigParm = 'SDL-01B981DFBD454718883459115B6C1308'
			)
 begin
	insert into DialogConfigParm(UID_ConfigParm, FullPath , ConfigParm, UID_ParentConfigparm, Value,  XObjectKey, Enabled)
			select 'SDL-01B981DFBD454718883459115B6C1308', 'Software\Inventory\MaxAge\Machine', 'Machine', 	'SDL-50A1A8F1160E4EC6A7C7E30C81CD3804', '65535'
			, '<Key><T>DialogConfigParm</T><P>SDL-01B981DFBD454718883459115B6C1308</P></Key>', 1
 end
go
if not exists (select 1 
				from DialogConfigParm p
				where p.UID_ConfigParm = 'SDL-ED2E4C58F4EA41778EB2B762B24FAD9B'
			)
 begin
	insert into DialogConfigParm(UID_ConfigParm, FullPath , ConfigParm, UID_ParentConfigparm, Value,  XObjectKey, Enabled)
			select 'SDL-ED2E4C58F4EA41778EB2B762B24FAD9B', 'Software\Inventory\MaxAge\User', 'User', 'SDL-50A1A8F1160E4EC6A7C7E30C81CD3804', '65535'
			, '<Key><T>DialogConfigParm</T><P>SDL-ED2E4C58F4EA41778EB2B762B24FAD9B</P></Key>', 1
 end
go






