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


-- 27460
if not exists (select top 1 1
				from sys.tables t
				where t.name = 'MachineAppsInfo'
			 )
 begin

	Create Table MachineAppsInfo (
		UID_MachineAppsInfo	varchar(38) NOT NULL,
		UID_Driver	varchar(38) NULL,
		UID_Application	varchar(38) NULL,
		UID_Hardware	varchar(38) NULL,
		AppsNotDriver	bit	default 0 NULL ,
		CurrentlyActive	bit	default 0 NULL ,
		InstallDate	datetime NULL,
		DeInstallDate	datetime NULL,
		DisplayName	nvarchar(255) NULL,
		Revision	int	default 0 NULL ,
		UID_OS varchar(38),
		UID_InstallationType varchar(38),
		XTouched	nchar(1) NULL,
		XObjectKey	varchar(138) NOT NULL,
		XMarkedForDeletion	int	default 0 NULL  
		Primary Key (UID_MachineAppsInfo)
 		)
 end
go


