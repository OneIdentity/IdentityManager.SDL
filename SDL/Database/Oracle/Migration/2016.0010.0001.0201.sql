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

--


begin
	QBM_GSchema.PIndexDrop('ApplicationProfile', '%');
end;
go


begin
	QBM_GSchema.PConstraintFKDrop('ApplicationProfile', '%', '%');
end;
go





update ApplicationProfile x
	set x.UID_SDLDomainRD = (select d.UID_SDLDomain
								from SDLDomain d where x.Ident_DomainRD = d.Ident_Domain
								and nvl(x.UID_SDLDomainRD, ' ') <> nvl(d.UID_SDLDomain, ' ')
								and rownum = 1
							)
				where exists (select 1
								from SDLDomain d where x.Ident_DomainRD = d.Ident_Domain
								and nvl(x.UID_SDLDomainRD, ' ') <> nvl(d.UID_SDLDomain, ' ')
							)
go



begin
	QBM_GSchema.PColumnChangeNullCons('ApplicationProfile', 'UID_SDLDomainRD', 0);
end;
go



update ApplicationProfile x
	set x.UID_SDLDomainRDOwner = (select d.UID_SDLDomain
								from SDLDomain d where x.Ident_DomainRDOwner = d.Ident_Domain
								and nvl(x.Ident_DomainRDOwner, ' ') <> nvl(d.UID_SDLDomain, ' ')
								and rownum = 1
							)
				where exists (select 1
								from SDLDomain d where x.Ident_DomainRDOwner = d.Ident_Domain
								and nvl(x.Ident_DomainRDOwner, ' ') <> nvl(d.UID_SDLDomain, ' ')
							)
go



-- was das letzte update nicht erwischt hat, gibt es die Domain nicht mehr
update ApplicationProfile 
	set UID_SDLDomainRDOwner = UID_SDLDomainRD
		, Ident_DomainRDOwner = Ident_DomainRD
	where UID_SDLDomainRDOwner is null
go



begin
	QBM_GSchema.PColumnChangeNullCons('ApplicationProfile', 'UID_SDLDomainRDOwner', 0);
end;
go



begin
	QBM_GSchema.PColumnChangeNullCons('ApplicationProfile', 'Ident_DomainRD', 1);
	QBM_GSchema.PColumnChangeNullCons('ApplicationProfile', 'Ident_DomainRDOwner', 1);
end;
go




------------------


begin
	QBM_GSchema.PIndexDrop('DriverProfile', '%');
end;
go


begin
	QBM_GSchema.PConstraintFKDrop('DriverProfile', '%', '%');
end;
go




update DriverProfile x
	set x.UID_SDLDomainRD = (select d.UID_SDLDomain
								from SDLDomain d where x.Ident_DomainRD = d.Ident_Domain
								and nvl(x.UID_SDLDomainRD, ' ') <> nvl(d.UID_SDLDomain, ' ')
								and rownum = 1
							)
				where exists (select 1
								from SDLDomain d where x.Ident_DomainRD = d.Ident_Domain
								and nvl(x.UID_SDLDomainRD, ' ') <> nvl(d.UID_SDLDomain, ' ')
							)
go



begin
	QBM_GSchema.PColumnChangeNullCons('DriverProfile', 'UID_SDLDomainRD', 0);
end;
go




update DriverProfile x
	set x.UID_SDLDomainRDOwner = (select d.UID_SDLDomain
								from SDLDomain d where x.Ident_DomainRDOwner = d.Ident_Domain
								and nvl(x.Ident_DomainRDOwner, ' ') <> nvl(d.UID_SDLDomain, ' ')
								and rownum = 1
							)
				where exists (select 1
								from SDLDomain d where x.Ident_DomainRDOwner = d.Ident_Domain
								and nvl(x.Ident_DomainRDOwner, ' ') <> nvl(d.UID_SDLDomain, ' ')
							)
go



-- was das letzte update nicht erwischt hat, gibt es die Domain nicht mehr
update DriverProfile 
	set UID_SDLDomainRDOwner = UID_SDLDomainRD
		, Ident_DomainRDOwner = Ident_DomainRD
	where UID_SDLDomainRDOwner is null
go


begin
	QBM_GSchema.PColumnChangeNullCons('DriverProfile', 'UID_SDLDomainRDOwner', 0);
end;
go



begin
	QBM_GSchema.PColumnChangeNullCons('DriverProfile', 'Ident_DomainRD', 1);
	QBM_GSchema.PColumnChangeNullCons('DriverProfile', 'Ident_DomainRDOwner', 1);
end;
go





-- 28434
begin
	QBM_GSchema.PTableAdd('MachineAppsConfig', 'Create Table MachineAppsConfig (
	UID_MachineAppsConfig	Varchar2(38 ) NOT NULL,
	CurrentlyActive	Number(1,0 ) default 0 ,
	AppsNotDriver	Number(1,0 ) default 0 ,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XTouched	Varchar2(1 ) NULL,
	UID_Driver	Varchar2(38 ) NULL,
	DisplayName	Varchar2(255 ) NULL,
	DeInstallDate	Date NULL ,
	UID_Application	Varchar2(38 ) NULL,
	InstallDate	Date NULL ,
	UID_Hardware	Varchar2(38 ) NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_MachineAppsConfig)
 	)  ');
end;
go


insert into DialogTable (UID_DialogTable, TableName, XObjectKey)
	select 'SDL-T-MachineAppsConfig', 'MachineAppsConfig', QBM_GConvert2.FCVElementToObjectKey('DialogTable', '', 'SDL-T-MachineAppsConfig')
	from dual where not exists (select 1 from DialogTable where uid_dialogtable = 'SDL-T-MachineAppsConfig')
go

update DialogTable set TableType = 'T' where TableName = 'MachineAppsConfig'
go



create or replace procedure tmp_c (v_UID_DialogColumn varchar2
									, v_columnname varchar2
								)
	as
begin

insert into DialogColumn (UID_DialogColumn, UID_DialogTable, ColumnName, XObjectKey)
	select v_UID_DialogColumn, 'SDL-T-MachineAppsConfig', v_columnname, QBM_GConvert2.FCVElementToObjectKey('DialogColumn', '', v_UID_DialogColumn)
	from dual where not exists
						(select 1 from Dialogcolumn where uid_dialogtable = 'SDL-T-MachineAppsConfig'
								and columnname = v_columnname
						);

end tmp_c;
go

begin
	tmp_c ('SDL-1394EFAF91A648DC85352EB47B6A84C4',  'UID_MachineAppsConfig');
	tmp_c ('SDL-33B048B8B8AD41ECAF15A60FE76764B0',  'CurrentlyActive');
	tmp_c ('SDL-4C1BF170C5524CEBAA9D93BDE0497F01',  'AppsNotDriver');
	tmp_c ('SDL-6912152270FB4AB8A128AB22FDF9FF86',  'XObjectKey');
	tmp_c ('SDL-78D6E234AEEE4FE0ADA108FD51411CB6',  'XTouched');
	tmp_c ('SDL-848994B56A4B4867AD6AB1950476E47B',  'UID_Driver');
	tmp_c ('SDL-990F1E44850F4C41A35B3C4F080BE841',  'DisplayName');
	tmp_c ('SDL-BC6A6D41BEF24676A3F5A981659DFF6E',  'DeInstallDate');
	tmp_c ('SDL-D4B08BE39CE1474D8AE827A647A3ACA9',  'UID_Application');
	tmp_c ('SDL-DC2E0262BF3540B1AE77C0002EAA87B4',  'InstallDate');
	tmp_c ('SDL-F42D10A9448449D9B2766385F5088006',  'UID_Hardware');
end;
go


begin
	QBM_GSchema.PProcedureDrop('tmp_c');
end;
go


