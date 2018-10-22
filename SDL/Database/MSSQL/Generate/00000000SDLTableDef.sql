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
if not exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'AccProduct' )
 begin
	raiserror('#LDS#Dependent Table {0} not exists|AccProduct|', 18, 1) with nowait
 end
go
if not exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ADSAccount' )
 begin
	raiserror('#LDS#Dependent Table {0} not exists|ADSAccount|', 18, 1) with nowait
 end
go
alter table ADSAccount add 	IsAppAccount	bit	default 0 NULL 
go
alter table ADSAccount add 	Ident_DomainRD	nvarchar(32) NULL
go
alter table ADSAccount add 	UID_HardwareDefaultMachine	varchar(38) NULL
go
alter table ADSAccount add 	UID_SDLDomainRD	varchar(38) NULL
go
Create Table ADSAccountAppsInfo (
	UID_ADSAccountAppsInfo	varchar(38) NOT NULL,
	CurrentlyActive	bit	default 0 NULL ,
	InstallDate	datetime NULL,
	DeInstallDate	datetime NULL,
	DisplayName	nvarchar(255) NULL,
	Revision	int	default 0 NULL ,
	DeinstallByUser	bit	default 0 NULL ,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL ,
	UID_OS	varchar(38) NULL,
	UID_ADSAccount	varchar(38) NULL,
	UID_Application	varchar(38) NULL,
	UID_InstallationType	varchar(38) NULL 
	Primary Key (UID_ADSAccountAppsInfo)
 	)
go
if not exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ADSDomain' )
 begin
	raiserror('#LDS#Dependent Table {0} not exists|ADSDomain|', 18, 1) with nowait
 end
go
Create Table AppHasLicence (
	XUserUpdated	nvarchar(64) NULL,
	XUserInserted	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL ,
	UID_Licence	varchar(38) NOT NULL,
	XDateUpdated	datetime NULL,
	UID_Application	varchar(38) NOT NULL,
	XDateInserted	datetime NULL 
	Primary Key (UID_Licence, UID_Application)
 	)
go
if not exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'Application' )
 begin
	raiserror('#LDS#Dependent Table {0} not exists|Application|', 18, 1) with nowait
 end
go
alter table Application add 	UID_ApplicationType	varchar(38) NULL
go
alter table Application add 	Ident_SectionName	nvarchar(64) NULL
go
alter table Application add 	Ident_Language	nvarchar(32) NULL
go
alter table Application add 	LicenceState	nvarchar(255) NULL
go
alter table Application add 	LicenceClerk	nvarchar(64) NULL
go
alter table Application add 	LicencePrice	int	default 0 NULL 
go
alter table Application add 	IsProfileApplication	bit	default 0 NULL 
go
alter table Application add 	SortOrderForProfile	int	default 0 NULL 
go
alter table Application add 	UID_SectionName	varchar(38) NULL
go
Create Table ApplicationDependsOnDriver (
	UID_ApplicationChild	varchar(38) NOT NULL,
	UID_DriverParent	varchar(38) NOT NULL,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_ApplicationChild, UID_DriverParent)
 	)
go
Create Table ApplicationExcludeDriver (
	UID_Driver	varchar(38) NOT NULL,
	UID_Application	varchar(38) NOT NULL,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_Driver, UID_Application)
 	)
go
Create Table ApplicationProfile (
	ChgCL	int	default 0 NULL ,
	UID_Application	varchar(38) NOT NULL,
	DisplayName	nvarchar(255) NULL,
	UpdatePathVII	bit	default 0 NULL ,
	UpdateProfileVII	bit	default 0 NULL ,
	XUserInserted	nvarchar(64) NULL,
	ProfileType	nchar(3) NULL,
	XUserUpdated	nvarchar(64) NULL,
	Ident_DomainRDOwner	nvarchar(32) NULL,
	XDateUpdated	datetime NULL,
	XMarkedForDeletion	int	default 0 NULL ,
	XObjectKey	varchar(138) NOT NULL,
	UID_InstallationType	varchar(38) NOT NULL,
	UID_SDLDomainRD	varchar(38) NOT NULL,
	PackagePath	nvarchar(max) NULL,
	HashValueFDS	int	default 0 NULL ,
	HashValueTAS	int	default 0 NULL ,
	RemoveHKeyCurrentUser	bit	default 0 NULL ,
	XTouched	nchar(1) NULL,
	CachingBehavior	nvarchar(64) NULL,
	UID_SDLDomainRDOwner	varchar(38) NOT NULL,
	Description	nvarchar(max) NULL,
	Ident_InstType	nvarchar(64) NULL,
	ChgNumber	int	default 0 NOT NULL ,
	SubPath	nvarchar(max) NULL,
	OrderNumber	float	default 0 NULL ,
	UID_Profile	varchar(38) NOT NULL,
	Ident_OS	nvarchar(32) NULL,
	UID_OS	varchar(38) NOT NULL,
	Ident_DomainRD	nvarchar(32) NULL,
	XDateInserted	datetime NULL,
	ProfileDate	datetime NULL,
	ProfileCreator	nvarchar(32) NULL,
	ProfileModifier	nvarchar(32) NULL,
	ProfileModDate	datetime NULL,
	ServerDrive	nchar(2) NULL,
	OSMode	nvarchar(17) NOT NULL,
	DefDriveTarget	nchar(2) NULL,
	ClientStepCounter	int	default 0 NULL ,
	MemoryUsage	nvarchar(max) NULL,
	ChgTest	int	default 0 NOT NULL  
	Primary Key (UID_Profile)
 	)
go
Create Table ApplicationServer (
	UID_ApplicationServer	varchar(38) NOT NULL,
	UID_Server	varchar(38) NOT NULL,
	UID_SDLDomain	varchar(38) NULL,
	UID_ParentApplicationServer	varchar(38) NULL,
	Ident_Domain	nvarchar(32) NOT NULL,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	IsCentralLibrary	bit	default 0 NULL ,
	Ident_ApplicationServer	nvarchar(64) NULL,
	FullPath	nvarchar(255) NULL,
	UID_ApplicationServerRedirect	varchar(38) NULL,
	UseShadowFolder	bit	default 0 NULL ,
	OnLineLimit	int	default 0 NULL ,
	UseAlwaysLimit	bit	default 0 NULL ,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_ApplicationServer)
 	)
go
Create Table ApplicationType (
	UID_ApplicationType	varchar(38) NOT NULL,
	Ident_ApplicationType	nvarchar(64) NULL,
	Description	nvarchar(max) NULL,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_ApplicationType)
 	)
go
Create Table AppServerGotAppProfile (
	UID_ApplicationServer	varchar(38) NOT NULL,
	UID_Profile	varchar(38) NOT NULL,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	ChgNumber	int	default 0 NULL ,
	ProfileStateProduction	nvarchar(16) NULL,
	ProfileStateShadow	nvarchar(16) NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_ApplicationServer, UID_Profile)
 	)
go
Create Table AppServerGotDriverProfile (
	UID_ApplicationServer	varchar(38) NOT NULL,
	UID_Profile	varchar(38) NOT NULL,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	ChgNumber	int	default 0 NULL ,
	ProfileStateProduction	nvarchar(16) NULL,
	ProfileStateShadow	nvarchar(16) NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_ApplicationServer, UID_Profile)
 	)
go
Create Table AppServerGotMactypeInfo (
	UID_MachineType	varchar(38) NOT NULL,
	UID_ApplicationServer	varchar(38) NOT NULL,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	ChgNumber	int	default 0 NULL ,
	ProfileStateProduction	nvarchar(16) NULL,
	ProfileStateShadow	nvarchar(16) NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_MachineType, UID_ApplicationServer)
 	)
go
if not exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'BaseTree' )
 begin
	raiserror('#LDS#Dependent Table {0} not exists|BaseTree|', 18, 1) with nowait
 end
go
alter table BaseTree add 	IsLicenceNode	bit	default 0 NULL 
go
Create Table BaseTreeHasDriver (
	UID_Org	varchar(38) NOT NULL,
	UID_Driver	varchar(38) NOT NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL ,
	XOrigin	int	default 0 NULL ,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	XIsInEffect	bit	default 0 NULL  
	Primary Key (UID_Org, UID_Driver)
 	)
go
Create Table BaseTreeHasLicence (
	CountLicMacIndirectActual	int	default 0 NULL ,
	CountLicUserActual	int	default 0 NULL ,
	CountLicMacDirectActual	int	default 0 NULL ,
	CountLicMacPossTarget	int	default 0 NULL ,
	CountLicUserTarget	int	default 0 NULL ,
	ValidTo	datetime NULL,
	XObjectKey	varchar(138) NOT NULL,
	CountLicMacPossActual	int	default 0 NULL ,
	ValidFrom	datetime NULL,
	CountLicMacReal	int	default 0 NULL ,
	XMarkedForDeletion	int	default 0 NULL ,
	CountLimit	int	default 0 NULL ,
	XDateInserted	datetime NULL,
	UID_Licence	varchar(38) NOT NULL,
	UID_Org	varchar(38) NOT NULL,
	CountLicMacIndirectTarget	int	default 0 NULL ,
	XTouched	nchar(1) NULL,
	CountLicMacDirectTarget	int	default 0 NULL ,
	XDateUpdated	datetime NULL,
	XUserUpdated	nvarchar(64) NULL,
	XUserInserted	nvarchar(64) NULL 
	Primary Key (UID_Licence, UID_Org)
 	)
go
Create Table BaseTreeHasLicencePurchase (
	UID_Org	varchar(38) NOT NULL,
	UID_LicencePurchase	varchar(38) NOT NULL,
	CountLicence	int	default 0 NULL ,
	IsInActive	bit	default 0 NULL ,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_Org, UID_LicencePurchase)
 	)
go
Create Table BaseTreeRelatedToBasetree (
	UID_Org	varchar(38) NOT NULL,
	UID_OrgRelated	varchar(38) NOT NULL,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_Org, UID_OrgRelated)
 	)
go
Create Table ClientLog (
	UID_ClientLog	varchar(38) NOT NULL,
	UID_LDAPAccount	varchar(38) NULL,
	UID_ADSAccount	varchar(38) NULL,
	UID_Hardware	varchar(38) NULL,
	UserNamespace	nvarchar(3) NULL,
	InstallDate	datetime NULL,
	LogContent	nvarchar(max) NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_ClientLog)
 	)
go
Create Table Driver (
	UID_Driver	varchar(38) NOT NULL,
	UID_OS	varchar(38) NOT NULL,
	UID_ApplicationType	varchar(38) NULL,
	Ident_SectionName	nvarchar(64) NULL,
	Ident_OS	nvarchar(32) NULL,
	Ident_Language	nvarchar(32) NOT NULL,
	Version	nvarchar(32) NOT NULL,
	Ident_Driver	nvarchar(128) NOT NULL,
	DriverURL	nvarchar(max) NULL,
	Description	nvarchar(max) NULL,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	NameFull	nvarchar(255) NULL,
	SomeComments	nvarchar(max) NULL,
	LicenceState	nvarchar(max) NULL,
	LicenceClerk	nvarchar(64) NULL,
	LicencePrice	int	default 0 NULL ,
	CustomProperty01	nvarchar(64) NULL,
	CustomProperty02	nvarchar(64) NULL,
	CustomProperty03	nvarchar(64) NULL,
	CustomProperty04	nvarchar(64) NULL,
	CustomProperty05	nvarchar(64) NULL,
	CustomProperty06	nvarchar(64) NULL,
	CustomProperty07	nvarchar(64) NULL,
	CustomProperty08	nvarchar(64) NULL,
	CustomProperty09	nvarchar(64) NULL,
	CustomProperty10	nvarchar(64) NULL,
	IsProfileApplication	bit	default 0 NULL ,
	XTouched	nchar(1) NULL,
	SupportedOperatingSystems	nvarchar(max) NULL,
	AppUpdateCycle	nvarchar(64) NULL,
	AppStatusIndicator	nvarchar(64) NULL,
	AppInstallationMode	nvarchar(64) NULL,
	AppAccessType	nvarchar(64) NULL,
	AppPermitType	nvarchar(64) NULL,
	DocumentationURL	nvarchar(max) NULL,
	InternalProductName	nvarchar(64) NULL,
	DateStatusIndicatorChanged	datetime NULL,
	DateFirstInstall	datetime NULL,
	SortOrderForProfile	int	default 0 NULL ,
	UID_AccProduct	varchar(38) NULL,
	IsInActive	bit	default 0 NULL ,
	XObjectKey	varchar(138) NOT NULL,
	IsForITShop	bit	default 0 NULL ,
	IsITShopOnly	bit	default 0 NULL ,
	XMarkedForDeletion	int	default 0 NULL ,
	UID_DialogCulture	varchar(38) NULL,
	UID_SectionName	varchar(38) NULL 
	Primary Key (UID_Driver)
 	)
go
Create Table DriverCanUsedByRD (
	UID_Profile	varchar(38) NOT NULL,
	UID_SDLDomainAllowed	varchar(38) NOT NULL,
	Ident_DomainAllowed	nvarchar(32) NOT NULL,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_Profile, UID_SDLDomainAllowed)
 	)
go
Create Table DriverDependsOnDriver (
	UID_DriverChild	varchar(38) NOT NULL,
	UID_DriverParent	varchar(38) NOT NULL,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	IsPhysicalDependent	bit	default 0 NULL ,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_DriverChild, UID_DriverParent)
 	)
go
Create Table DriverExcludeDriver (
	UID_DriverExcluded	varchar(38) NOT NULL,
	UID_Driver	varchar(38) NOT NULL,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_DriverExcluded, UID_Driver)
 	)
go
Create Table DriverHasLicence (
	XUserUpdated	nvarchar(64) NULL,
	XUserInserted	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL ,
	UID_Licence	varchar(38) NOT NULL,
	XDateUpdated	datetime NULL,
	UID_Driver	varchar(38) NOT NULL,
	XDateInserted	datetime NULL 
	Primary Key (UID_Licence, UID_Driver)
 	)
go
Create Table DriverProfile (
	UID_Profile	varchar(38) NOT NULL,
	Ident_DomainRD	nvarchar(32) NULL,
	ChgNumber	int	default 0 NOT NULL ,
	OrderNumber	float	default 0 NULL ,
	DefDriveTarget	nchar(2) NULL,
	OSMode	nvarchar(17) NOT NULL,
	MemoryUsage	nvarchar(max) NULL,
	ChgTest	int	default 0 NOT NULL ,
	SubPath	nvarchar(max) NULL,
	ClientStepCounter	int	default 0 NULL ,
	ProfileCreator	nvarchar(64) NULL,
	ProfileDate	datetime NULL,
	ProfileModifier	nvarchar(64) NULL,
	ProfileModDate	datetime NULL,
	Description	nvarchar(max) NULL,
	Ident_DomainRDOwner	nvarchar(32) NULL,
	UID_Driver	varchar(38) NOT NULL,
	DisplayName	nvarchar(255) NULL,
	ChgCL	int	default 0 NULL ,
	UpdatePathVII	bit	default 0 NULL ,
	UpdateProfileVII	bit	default 0 NULL ,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	ProfileType	nchar(3) NULL,
	PackagePath	nvarchar(max) NULL,
	HashValueTAS	int	default 0 NULL ,
	HashValueFDS	int	default 0 NULL ,
	XTouched	nchar(1) NULL,
	CachingBehavior	nvarchar(64) NULL,
	RemoveHKeyCurrentUser	bit	default 0 NULL ,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL ,
	UID_SDLDomainRD	varchar(38) NOT NULL,
	UID_SDLDomainRDOwner	varchar(38) NOT NULL 
	Primary Key (UID_Profile)
 	)
go
if not exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'FirmPartner' )
 begin
	raiserror('#LDS#Dependent Table {0} not exists|FirmPartner|', 18, 1) with nowait
 end
go
if not exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'Hardware' )
 begin
	raiserror('#LDS#Dependent Table {0} not exists|Hardware|', 18, 1) with nowait
 end
go
alter table Hardware add 	UID_MachineType	varchar(38) NULL
go
alter table Hardware add 	IsVIPC	bit	default 0 NULL 
go
alter table Hardware add 	Ident_DomainRD	nvarchar(32) NULL
go
alter table Hardware add 	UID_SDLDomainRD	varchar(38) NULL
go
alter table Hardware add 	UpdateCNAME	bit	default 0 NULL 
go
alter table Hardware add 	UID_InstallationType	varchar(38) NULL
go
alter table Hardware add 	UID_OS	varchar(38) NULL
go
alter table Hardware add 	HomeServerOfDefaultUser	nvarchar(max) NULL
go
alter table Hardware add 	DefaultUserContext	nvarchar(max) NULL
go
alter table Hardware add 	DefaultWorkGroup	nvarchar(16) NULL
go
alter table Hardware add 	UpdateUDF	bit	default 0 NULL 
go
alter table Hardware add 	UpdateMac2Name	bit	default 0 NULL 
go
alter table Hardware add 	DisplayBitsPerPel	int	default 0 NULL 
go
alter table Hardware add 	DisplayVRefresh	int	default 0 NULL 
go
alter table Hardware add 	DisplayXResolution	int	default 0 NULL 
go
alter table Hardware add 	DisplayYResolution	int	default 0 NULL 
go
if not exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'HardwareType' )
 begin
	raiserror('#LDS#Dependent Table {0} not exists|HardwareType|', 18, 1) with nowait
 end
go
alter table HardwareType add 	IsViClientPCDependent	bit	default 0 NULL 
go
Create Table HardwareTypeHasDriver (
	UID_HardwareType	varchar(38) NOT NULL,
	UID_Driver	varchar(38) NOT NULL,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_HardwareType, UID_Driver)
 	)
go
Create Table InstallationType (
	UID_InstallationType	varchar(38) NOT NULL,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL ,
	Ident_InstType	nvarchar(64) NOT NULL 
	Primary Key (UID_InstallationType)
 	)
go
if not exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'LDAPAccount' )
 begin
	raiserror('#LDS#Dependent Table {0} not exists|LDAPAccount|', 18, 1) with nowait
 end
go
alter table LDAPAccount add 	IsAppAccount	bit	default 0 NULL 
go
Create Table Licence (
	UID_Licence	varchar(38) NOT NULL,
	UID_OS	varchar(38) NULL,
	Ident_OS	nvarchar(32) NULL,
	UID_FirmPartner	varchar(38) NULL,
	UID_ApplicationType	varchar(38) NULL,
	Ident_Language	nvarchar(32) NULL,
	Ident_LicenceType	nvarchar(64) NULL,
	Ident_Licence	nvarchar(64) NULL,
	CountLimit	int	default 0 NULL ,
	Version	nvarchar(32) NULL,
	IsInActive	bit	default 0 NULL ,
	ValidFrom	datetime NULL,
	ValidTo	datetime NULL,
	Description	nvarchar(max) NULL,
	CustomProperty01	nvarchar(64) NULL,
	CustomProperty02	nvarchar(64) NULL,
	CustomProperty03	nvarchar(64) NULL,
	CustomProperty04	nvarchar(64) NULL,
	CustomProperty05	nvarchar(64) NULL,
	CustomProperty06	nvarchar(64) NULL,
	CustomProperty07	nvarchar(64) NULL,
	CustomProperty08	nvarchar(64) NULL,
	CustomProperty09	nvarchar(64) NULL,
	CustomProperty10	nvarchar(64) NULL,
	ArticleCode	nvarchar(64) NULL,
	ArticleCodeManufacturer	nvarchar(64) NULL,
	OrderUnit	nvarchar(32) NULL,
	OrderQuantityMin	int	default 0 NULL ,
	LastOfferDate	datetime NULL,
	LastOfferPrice	int	default 0 NULL ,
	LastDeliverDate	datetime NULL,
	LastDeliverPrice	int	default 0 NULL ,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	CountLicMacDirectTarget	int	default 0 NULL ,
	CountLicMacIndirectTarget	int	default 0 NULL ,
	CountLicUserTarget	int	default 0 NULL ,
	CountLicMacPossTarget	int	default 0 NULL ,
	CountLicMacDirectActual	int	default 0 NULL ,
	CountLicMacIndirectActual	int	default 0 NULL ,
	CountLicUserActual	int	default 0 NULL ,
	CountLicMacPossActual	int	default 0 NULL ,
	CountLicMacReal	int	default 0 NULL ,
	LicenceNameManufacturer	nvarchar(max) NULL,
	LicenceProductType	nvarchar(64) NULL,
	LicenceStatusIndicator	nvarchar(64) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL ,
	UID_DialogCulture	varchar(38) NULL,
	UID_LicenceType	varchar(38) NULL 
	Primary Key (UID_Licence)
 	)
go
Create Table LicencePurchase (
	CustomProperty06	nvarchar(64) NULL,
	CustomProperty05	nvarchar(64) NULL,
	CustomProperty04	nvarchar(64) NULL,
	CustomProperty07	nvarchar(64) NULL,
	CustomProperty08	nvarchar(64) NULL,
	CustomProperty09	nvarchar(64) NULL,
	GuarantyMonths	int	default 0 NULL ,
	BuyDate	datetime NULL,
	CustomProperty03	nvarchar(64) NULL,
	CustomProperty02	nvarchar(64) NULL,
	GuarantyMonthsAdditional	int	default 0 NULL ,
	CustomProperty01	nvarchar(64) NULL,
	EndOfUse	datetime NULL,
	SerialNumber	nvarchar(max) NULL,
	OrderNumber	nvarchar(64) NULL,
	ArticleCodeManufacturer	nvarchar(64) NULL,
	XMarkedForDeletion	int	default 0 NULL ,
	LicencePurchaseType	nvarchar(20) NULL,
	XObjectKey	varchar(138) NOT NULL,
	CustomProperty10	nvarchar(64) NULL,
	XDateInserted	datetime NULL,
	XUserUpdated	nvarchar(64) NULL,
	ArticleCodeDealer	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	UID_LicenceType	varchar(38) NULL,
	AssetReceiptNumber	nvarchar(64) NULL,
	AssetValueNew	int	default 0 NULL ,
	AssetDeActivate	datetime NULL,
	AssetAmortizationMonth	int	default 0 NULL ,
	DeliveryDate	datetime NULL,
	AssetNumber	nvarchar(64) NULL,
	CountLicence	int	default 0 NULL ,
	Ident_LicenceType	nvarchar(64) NULL,
	UID_LicencePurchase	varchar(38) NOT NULL,
	AssetActivate	datetime NULL,
	UID_Licence	varchar(38) NULL,
	UID_OrgOwner	varchar(38) NULL,
	UID_FirmPartnerVendor	varchar(38) NULL,
	GuarantyNumber	nvarchar(64) NULL,
	IsLeasingAsset	bit	default 0 NULL ,
	AssetDeliveryRemarks	nvarchar(32) NULL,
	AssetInventoryText	nvarchar(32) NULL,
	Guaranty	datetime NULL,
	DeliveryNumber	nvarchar(64) NULL,
	Currency	nvarchar(32) NULL,
	CountLicenceRemaining	int	default 0 NULL ,
	AssetIdent	nvarchar(64) NULL,
	IsInActive	bit	default 0 NULL ,
	AssetInventory	datetime NULL,
	AssetOwnership	bit	default 0 NULL ,
	RentCharge	int	default 0 NULL ,
	AssetValueCurrent	int	default 0 NULL  
	Primary Key (UID_LicencePurchase)
 	)
go
Create Table LicenceSubstitute (
	XUserUpdated	nvarchar(64) NULL,
	XUserInserted	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL ,
	UID_Licence	varchar(38) NOT NULL,
	XDateUpdated	datetime NULL,
	UID_LicenceSubstitute	varchar(38) NOT NULL,
	XDateInserted	datetime NULL 
	Primary Key (UID_Licence, UID_LicenceSubstitute)
 	)
go
Create Table LicenceSubstituteTotal (
	UID_GroupRoot	varchar(38) NULL,
	UID_Licence	varchar(38) NOT NULL,
	UID_LicenceSubstitute	varchar(38) NOT NULL,
	CountSteps	int	default 0 NULL ,
	SortOrder	int	default 0 NULL ,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_Licence, UID_LicenceSubstitute)
 	)
go
Create Table LicenceType (
	UID_LicenceType	varchar(38) NOT NULL,
	Ident_LicenceType	nvarchar(64) NOT NULL,
	Description	nvarchar(max) NULL,
	IsPerCompany	bit	default 0 NULL ,
	IsPerUser	bit	default 0 NULL ,
	IsPerMachine	bit	default 0 NULL ,
	IsPerProcessor	bit	default 0 NULL ,
	CustomProperty01	nvarchar(64) NULL,
	CustomProperty02	nvarchar(64) NULL,
	CustomProperty03	nvarchar(64) NULL,
	CustomProperty04	nvarchar(64) NULL,
	CustomProperty05	nvarchar(64) NULL,
	CustomProperty06	nvarchar(64) NULL,
	CustomProperty07	nvarchar(64) NULL,
	CustomProperty08	nvarchar(64) NULL,
	CustomProperty09	nvarchar(64) NULL,
	CustomProperty10	nvarchar(64) NULL,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	IsConcurrentUse	bit	default 0 NULL ,
	IsForFree	bit	default 0 NULL ,
	IsToPayOnce	bit	default 0 NULL ,
	IsToPayRecent	bit	default 0 NULL ,
	IsLocalityBased	bit	default 0 NULL ,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_LicenceType)
 	)
go
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
go
Create Table MachineAppsInfo (
	UID_MachineAppsInfo	varchar(38) NOT NULL,
	UID_Driver	varchar(38) NULL,
	UID_Application	varchar(38) NULL,
	UID_Hardware	varchar(38) NULL,
	UID_OS	varchar(38) NULL,
	AppsNotDriver	bit	default 0 NULL ,
	UID_InstallationType	varchar(38) NULL,
	CurrentlyActive	bit	default 0 NULL ,
	InstallDate	datetime NULL,
	DeInstallDate	datetime NULL,
	DisplayName	nvarchar(255) NULL,
	Revision	int	default 0 NULL ,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_MachineAppsInfo)
 	)
go
Create Table MachineHasDriver (
	UID_Hardware	varchar(38) NOT NULL,
	UID_Driver	varchar(38) NOT NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL ,
	XOrigin	int	default 0 NULL ,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	XIsInEffect	bit	default 0 NULL  
	Primary Key (UID_Hardware, UID_Driver)
 	)
go
Create Table MachineType (
	UID_MachineType	varchar(38) NOT NULL,
	UID_SDLDomain	varchar(38) NULL,
	Ident_DomainMachineType	nvarchar(32) NOT NULL,
	Ident_MachineType	nvarchar(64) NOT NULL,
	GraphicCard	nvarchar(64) NULL,
	RemoteBoot	bit	default 0 NULL ,
	BootImageWin	nchar(8) NULL,
	ChgNumber	int	default 0 NULL ,
	Netcard	nvarchar(64) NULL,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	MakeFullcopy	bit	default 0 NULL ,
	XTouched	nchar(1) NULL,
	IsInActive	bit	default 0 NULL ,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_MachineType)
 	)
go
Create Table MachineTypeHasDriver (
	UID_MachineType	varchar(38) NOT NULL,
	UID_Driver	varchar(38) NOT NULL,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_MachineType, UID_Driver)
 	)
go
if not exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'OS' )
 begin
	raiserror('#LDS#Dependent Table {0} not exists|OS|', 18, 1) with nowait
 end
go
alter table OS add 	UID_Licence	varchar(38) NULL
go
Create Table OsInstType (
	XUserUpdated	nvarchar(64) NULL,
	XUserInserted	nvarchar(64) NULL,
	XDateUpdated	datetime NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL ,
	UID_OS	varchar(38) NOT NULL,
	UID_OsInstType	varchar(38) NOT NULL,
	XDateInserted	datetime NULL,
	Ident_InstType	nvarchar(64) NULL,
	UID_InstallationType	varchar(38) NOT NULL,
	Ident_OS	nvarchar(32) NULL 
	Primary Key (UID_OsInstType)
 	)
go
if not exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'Person' )
 begin
	raiserror('#LDS#Dependent Table {0} not exists|Person|', 18, 1) with nowait
 end
go
alter table Person add 	IsTASUser	bit	default 0 NULL 
go
Create Table ProfileCanUsedAlso (
	XUserUpdated	nvarchar(64) NULL,
	XUserInserted	nvarchar(64) NULL,
	XDateUpdated	datetime NULL,
	XMarkedForDeletion	int	default 0 NULL ,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	UID_InstallationType	varchar(38) NULL,
	UID_OsInstType	varchar(38) NOT NULL,
	UID_Profile	varchar(38) NOT NULL,
	XDateInserted	datetime NULL,
	Ident_InstTypeAlso	nvarchar(64) NOT NULL,
	UID_OS	varchar(38) NULL,
	Ident_OSAlso	nvarchar(32) NOT NULL 
	Primary Key (UID_OsInstType, UID_Profile)
 	)
go
Create Table ProfileCanUsedByRD (
	UID_Profile	varchar(38) NOT NULL,
	UID_SDLDomainAllowed	varchar(38) NOT NULL,
	Ident_DomainAllowed	nvarchar(32) NOT NULL,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_Profile, UID_SDLDomainAllowed)
 	)
go
if not exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'QBMCulture' )
 begin
	raiserror('#LDS#Dependent Table {0} not exists|QBMCulture|', 18, 1) with nowait
 end
go
if not exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'QBMServer' )
 begin
	raiserror('#LDS#Dependent Table {0} not exists|QBMServer|', 18, 1) with nowait
 end
go
alter table QBMServer add 	BasePathForShares	nvarchar(max) NULL
go
Create Table SDLDomain (
	UID_SDLDomain	varchar(38) NOT NULL,
	UID_AERoleOwner	varchar(38) NULL,
	UID_ADSDomain	varchar(38) NULL,
	UID_ServerTAS	varchar(38) NULL,
	Ident_Domain	nvarchar(32) NOT NULL,
	IsMaster	bit	default 0 NULL ,
	ShareOnServers	nvarchar(32) NULL,
	Description	nvarchar(max) NULL,
	ServerPartShareOnServers	nvarchar(64) NULL,
	ClientPartPathOnServers	nvarchar(32) NULL,
	ClientPartApps	nvarchar(32) NULL,
	ClientPartDriver	nvarchar(32) NULL,
	ClientPartMacType	nvarchar(32) NULL,
	DefaultAppsDrive	nchar(2) NULL,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	ClientDrive	nchar(2) NULL,
	ShareOnTAS	nvarchar(32) NULL,
	NetlogonOnTAS	nvarchar(32) NULL,
	ServerPartShareOnTas	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	DomainGroupName	nvarchar(128) NULL,
	XObjectKey	varchar(138) NOT NULL,
	DisplayName	nvarchar(128) NULL,
	XMarkedForDeletion	int	default 0 NULL ,
	UID_SDLDomainParent	varchar(38) NULL 
	Primary Key (UID_SDLDomain)
 	)
go
Create Table SectionName (
	UID_SectionName	varchar(38) NOT NULL,
	Ident_SectionName	nvarchar(64) NOT NULL,
	Description	nvarchar(max) NULL,
	AppsNotDriver	bit	default 0 NULL ,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_SectionName)
 	)
go
Create Table SoftwareDependsOnSoftware (
	UID_Child	varchar(38) NOT NULL,
	UID_Parent	varchar(38) NOT NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL  
	Primary Key (UID_Child, UID_Parent)
 	)
go
if not exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'WorkDesk' )
 begin
	raiserror('#LDS#Dependent Table {0} not exists|WorkDesk|', 18, 1) with nowait
 end
go
alter table WorkDesk add 	DisableVIClient	bit	default 0 NULL 
go
alter table WorkDesk add 	IsViClientPCDependent	bit	default 0 NULL 
go
Create Table WorkDeskHasDriver (
	UID_WorkDesk	varchar(38) NOT NULL,
	UID_Driver	varchar(38) NOT NULL,
	XTouched	nchar(1) NULL,
	XObjectKey	varchar(138) NOT NULL,
	XMarkedForDeletion	int	default 0 NULL ,
	XOrigin	int	default 0 NULL ,
	XDateInserted	datetime NULL,
	XDateUpdated	datetime NULL,
	XUserInserted	nvarchar(64) NULL,
	XUserUpdated	nvarchar(64) NULL,
	XIsInEffect	bit	default 0 NULL  
	Primary Key (UID_WorkDesk, UID_Driver)
 	)
go
