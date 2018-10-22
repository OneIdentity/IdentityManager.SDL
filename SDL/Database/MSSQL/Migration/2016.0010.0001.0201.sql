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



exec QBM_PIndexDrop 'ApplicationProfile', '%'
go

exec QBM_PConstraintFKDrop 'ApplicationProfile', '%', '%'
go


update ApplicationProfile
	set UID_SDLDomainRD = d.UID_SDLDomain
	from ApplicationProfile x join SDLDomain d on x.Ident_DomainRD = d.Ident_Domain
	where isnull(x.UID_SDLDomainRD, '') <> isnull(d.UID_SDLDomain, '')
go


alter table ApplicationProfile
	alter column UID_SDLDomainRD	varchar(38) NOT NULL
go

update ApplicationProfile
	set UID_SDLDomainRDOwner = d.UID_SDLDomain
	-- select x.UID_SDLDomainRD, x.UID_SDLDomainRDOwner, x.Ident_DomainRD, x.Ident_DomainRDOwner
	from ApplicationProfile x join SDLDomain d on x.Ident_DomainRDOwner = d.Ident_Domain
	where isnull(x.UID_SDLDomainRDOwner, '') <> isnull(d.UID_SDLDomain, '')
go

-- was das letzte update nicht erwischt hat, gibt es die Domain nicht mehr
update ApplicationProfile 
	set UID_SDLDomainRDOwner = UID_SDLDomainRD
		, Ident_DomainRDOwner = Ident_DomainRD
	where UID_SDLDomainRDOwner is null
go

alter table ApplicationProfile
	alter column UID_SDLDomainRDOwner	varchar(38) NOT NULL
go




alter table ApplicationProfile
	alter column Ident_DomainRD nvarchar(32) null
go
alter table ApplicationProfile
	alter column Ident_DomainRDOwner nvarchar(32) null
go


------------------


exec QBM_PIndexDrop 'DriverProfile', '%'
go

exec QBM_PConstraintFKDrop 'DriverProfile', '%', '%'
go


update DriverProfile
	set UID_SDLDomainRD = d.UID_SDLDomain
	from DriverProfile x join SDLDomain d on x.Ident_DomainRD = d.Ident_Domain
	where isnull(x.UID_SDLDomainRD, '') <> isnull(d.UID_SDLDomain, '')
go


--	delete DriverProfile where UID_SDLDomainRD is null

alter table DriverProfile
	alter column UID_SDLDomainRD	varchar(38) NOT NULL
go

update DriverProfile
	set UID_SDLDomainRDOwner = d.UID_SDLDomain
	-- select x.UID_SDLDomainRD, x.UID_SDLDomainRDOwner, x.Ident_DomainRD, x.Ident_DomainRDOwner
	from DriverProfile x join SDLDomain d on x.Ident_DomainRDOwner = d.Ident_Domain
	where isnull(x.UID_SDLDomainRDOwner, '') <> isnull(d.UID_SDLDomain, '')
go

-- was das letzte update nicht erwischt hat, gibt es die Domain nicht mehr
update DriverProfile 
	set UID_SDLDomainRDOwner = UID_SDLDomainRD
		, Ident_DomainRDOwner = Ident_DomainRD
	where UID_SDLDomainRDOwner is null
go

alter table DriverProfile
	alter column UID_SDLDomainRDOwner	varchar(38) NOT NULL
go


alter table DriverProfile
	alter column Ident_DomainRD nvarchar(32) null
go
alter table DriverProfile
	alter column Ident_DomainRDOwner nvarchar(32) null
go


-- 28434
if not exists (select top 1 1
				from sys.tables t
				where t.name = 'MachineAppsConfig'
			)
 begin
	Create Table MachineAppsConfig (
		UID_MachineAppsConfig	varchar(38) NOT NULL,
		CurrentlyActive	bit	default 0 NULL ,
		AppsNotDriver	bit	default 0 NULL ,
		XObjectKey	varchar(138) NOT NULL,
		XTouched	nchar(1) NULL,
		UID_Driver	varchar(38) NULL,
		DisplayName	nvarchar(255) NULL,
		DeInstallDate	datetime NULL,
		UID_Application	varchar(38) NULL,
		InstallDate	datetime NULL,
		UID_Hardware	varchar(38) NULL,
		XMarkedForDeletion	int	default 0 NULL  
		Primary Key (UID_MachineAppsConfig)
 		)
 end
go

if not exists (select top 1 1
					from DialogTable t
					where t.TableName = 'MachineAppsConfig'
			)
 begin
	insert into DialogTable (UID_DialogTable, TableName, XObjectKey)
		select 'SDL-T-MachineAppsConfig', 'MachineAppsConfig', dbo.QBM_FCVElementToObjectKey1('DialogTable', '', 'SDL-T-MachineAppsConfig')
 end
go

update DialogTable set TableType = 'T' where TableName = 'MachineAppsConfig'
go


exec QBM_PProcedureDrop 'tmp_c'
go

create procedure tmp_c (@UID_DialogColumn varchar(38)
						, @columnname varchar(30)
					)
	as
begin

if not exists (select top 1 1
					from DialogColumn c
						where c.UID_DialogTable = 'SDL-T-MachineAppsConfig'
						and c.UID_DialogColumn = @UID_DialogColumn
				)
 begin
	insert into DialogColumn (UID_DialogColumn, UID_DialogTable, ColumnName, XObjectKey)
		select @UID_DialogColumn, 'SDL-T-MachineAppsConfig', @columnname, dbo.QBM_FCVElementToObjectKey1('DialogColumn', '', @UID_DialogColumn)
 end

end
go

exec tmp_c 'SDL-1394EFAF91A648DC85352EB47B6A84C4',  'UID_MachineAppsConfig'
go
exec tmp_c 'SDL-33B048B8B8AD41ECAF15A60FE76764B0',  'CurrentlyActive'
go
exec tmp_c 'SDL-4C1BF170C5524CEBAA9D93BDE0497F01',  'AppsNotDriver'
go
exec tmp_c 'SDL-6912152270FB4AB8A128AB22FDF9FF86',  'XObjectKey'
go
exec tmp_c 'SDL-78D6E234AEEE4FE0ADA108FD51411CB6',  'XTouched'
go
exec tmp_c 'SDL-848994B56A4B4867AD6AB1950476E47B',  'UID_Driver'
go
exec tmp_c 'SDL-990F1E44850F4C41A35B3C4F080BE841',  'DisplayName'
go
exec tmp_c 'SDL-BC6A6D41BEF24676A3F5A981659DFF6E',  'DeInstallDate'
go
exec tmp_c 'SDL-D4B08BE39CE1474D8AE827A647A3ACA9',  'UID_Application'
go
exec tmp_c 'SDL-DC2E0262BF3540B1AE77C0002EAA87B4',  'InstallDate'
go
exec tmp_c 'SDL-F42D10A9448449D9B2766385F5088006',  'UID_Hardware'
go

exec QBM_PProcedureDrop 'tmp_c'
go
