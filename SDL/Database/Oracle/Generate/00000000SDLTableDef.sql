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
 
declare
      v_exists number;
begin
	begin
		v_exists := 0;
		select 1 into v_exists  from dual where exists
				( select 1 from User_Objects where Object_name = upper('AccProduct') and Object_Type in ('TABLE', 'VIEW'));
		exception
			when no_data_found then
				raise_application_error(-20100, '#LDS#Dependent Table {0} not exists|AccProduct|', true);
	end;
end;
go
	
 
declare
      v_exists number;
begin
	begin
		v_exists := 0;
		select 1 into v_exists  from dual where exists
				( select 1 from User_Objects where Object_name = upper('ADSAccount') and Object_Type in ('TABLE', 'VIEW'));
		exception
			when no_data_found then
				raise_application_error(-20100, '#LDS#Dependent Table {0} not exists|ADSAccount|', true);
	end;
end;
go
	
alter table ADSAccount add 	IsAppAccount	Number(1,0 ) default 0 
go
 
 
alter table ADSAccount add 	Ident_DomainRD	Varchar2(32 ) NULL
go
 
 
alter table ADSAccount add 	UID_HardwareDefaultMachine	Varchar2(38 ) NULL
go
 
 
alter table ADSAccount add 	UID_SDLDomainRD	Varchar2(38 ) NULL
go
 
 
Create Table ADSAccountAppsInfo (
	UID_ADSAccountAppsInfo	Varchar2(38 ) NOT NULL,
	CurrentlyActive	Number(1,0 ) default 0 ,
	InstallDate	Date NULL ,
	DeInstallDate	Date NULL ,
	DisplayName	Varchar2(255 ) NULL,
	Revision	Number(14,0) default 0 NULL ,
	DeinstallByUser	Number(1,0 ) default 0 ,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL ,
	UID_OS	Varchar2(38 ) NULL,
	UID_ADSAccount	Varchar2(38 ) NULL,
	UID_Application	Varchar2(38 ) NULL,
	UID_InstallationType	Varchar2(38 ) NULL 
	, Primary Key (UID_ADSAccountAppsInfo)
 	)   
go
 
declare
      v_exists number;
begin
	begin
		v_exists := 0;
		select 1 into v_exists  from dual where exists
				( select 1 from User_Objects where Object_name = upper('ADSDomain') and Object_Type in ('TABLE', 'VIEW'));
		exception
			when no_data_found then
				raise_application_error(-20100, '#LDS#Dependent Table {0} not exists|ADSDomain|', true);
	end;
end;
go
	
Create Table AppHasLicence (
	XUserUpdated	Varchar2(64 ) NULL,
	XUserInserted	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL ,
	UID_Licence	Varchar2(38 ) NOT NULL,
	XDateUpdated	Date NULL ,
	UID_Application	Varchar2(38 ) NOT NULL,
	XDateInserted	Date NULL  
	, Primary Key (UID_Licence, UID_Application)
 	)   
go
 
declare
      v_exists number;
begin
	begin
		v_exists := 0;
		select 1 into v_exists  from dual where exists
				( select 1 from User_Objects where Object_name = upper('Application') and Object_Type in ('TABLE', 'VIEW'));
		exception
			when no_data_found then
				raise_application_error(-20100, '#LDS#Dependent Table {0} not exists|Application|', true);
	end;
end;
go
	
alter table Application add 	UID_ApplicationType	Varchar2(38 ) NULL
go
 
 
alter table Application add 	Ident_SectionName	Varchar2(64 ) NULL
go
 
 
alter table Application add 	Ident_Language	Varchar2(32 ) NULL
go
 
 
alter table Application add 	LicenceState	Varchar2(255 ) NULL
go
 
 
alter table Application add 	LicenceClerk	Varchar2(64 ) NULL
go
 
 
alter table Application add 	LicencePrice	Number(14,0) default 0 NULL 
go
 
 
alter table Application add 	IsProfileApplication	Number(1,0 ) default 0 
go
 
 
alter table Application add 	SortOrderForProfile	Number(14,0) default 0 NULL 
go
 
 
alter table Application add 	UID_SectionName	Varchar2(38 ) NULL
go
 
 
Create Table ApplicationDependsOnDriver (
	UID_ApplicationChild	Varchar2(38 ) NOT NULL,
	UID_DriverParent	Varchar2(38 ) NOT NULL,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_ApplicationChild, UID_DriverParent)
 	)   
go
Create Table ApplicationExcludeDriver (
	UID_Driver	Varchar2(38 ) NOT NULL,
	UID_Application	Varchar2(38 ) NOT NULL,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_Driver, UID_Application)
 	)   
go
Create Table ApplicationProfile (
	ChgCL	Number(14,0) default 0 NULL ,
	UID_Application	Varchar2(38 ) NOT NULL,
	DisplayName	Varchar2(255 ) NULL,
	UpdatePathVII	Number(1,0 ) default 0 ,
	UpdateProfileVII	Number(1,0 ) default 0 ,
	XUserInserted	Varchar2(64 ) NULL,
	ProfileType	Varchar2(3 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	Ident_DomainRDOwner	Varchar2(32 ) NULL,
	XDateUpdated	Date NULL ,
	XMarkedForDeletion	Number(14,0) default 0 NULL ,
	XObjectKey	Varchar2(138 ) NOT NULL,
	UID_InstallationType	Varchar2(38 ) NOT NULL,
	UID_SDLDomainRD	Varchar2(38 ) NOT NULL,
	PackagePath	CLOB,
	HashValueFDS	Number(14,0) default 0 NULL ,
	HashValueTAS	Number(14,0) default 0 NULL ,
	RemoveHKeyCurrentUser	Number(1,0 ) default 0 ,
	XTouched	Varchar2(1 ) NULL,
	CachingBehavior	Varchar2(64 ) NULL,
	UID_SDLDomainRDOwner	Varchar2(38 ) NOT NULL,
	Description	CLOB,
	Ident_InstType	Varchar2(64 ) NULL,
	ChgNumber	Number(14,0) default 0 NOT NULL ,
	SubPath	CLOB,
	OrderNumber	Number (38,16)  default 0 NULL,
	UID_Profile	Varchar2(38 ) NOT NULL,
	Ident_OS	Varchar2(32 ) NULL,
	UID_OS	Varchar2(38 ) NOT NULL,
	Ident_DomainRD	Varchar2(32 ) NULL,
	XDateInserted	Date NULL ,
	ProfileDate	Date NULL ,
	ProfileCreator	Varchar2(32 ) NULL,
	ProfileModifier	Varchar2(32 ) NULL,
	ProfileModDate	Date NULL ,
	ServerDrive	Varchar2(2 ) NULL,
	OSMode	Varchar2(17 ) NOT NULL,
	DefDriveTarget	Varchar2(2 ) NULL,
	ClientStepCounter	Number(14,0) default 0 NULL ,
	MemoryUsage	CLOB,
	ChgTest	Number(14,0) default 0 NOT NULL  
	, Primary Key (UID_Profile)
 	)   
go
Create Table ApplicationServer (
	UID_ApplicationServer	Varchar2(38 ) NOT NULL,
	UID_Server	Varchar2(38 ) NOT NULL,
	UID_SDLDomain	Varchar2(38 ) NULL,
	UID_ParentApplicationServer	Varchar2(38 ) NULL,
	Ident_Domain	Varchar2(32 ) NOT NULL,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	IsCentralLibrary	Number(1,0 ) default 0 ,
	Ident_ApplicationServer	Varchar2(64 ) NULL,
	FullPath	Varchar2(255 ) NULL,
	UID_ApplicationServerRedirect	Varchar2(38 ) NULL,
	UseShadowFolder	Number(1,0 ) default 0 ,
	OnLineLimit	Number(14,0) default 0 NULL ,
	UseAlwaysLimit	Number(1,0 ) default 0 ,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_ApplicationServer)
 	)   
go
Create Table ApplicationType (
	UID_ApplicationType	Varchar2(38 ) NOT NULL,
	Ident_ApplicationType	Varchar2(64 ) NULL,
	Description	CLOB,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_ApplicationType)
 	)   
go
Create Table AppServerGotAppProfile (
	UID_ApplicationServer	Varchar2(38 ) NOT NULL,
	UID_Profile	Varchar2(38 ) NOT NULL,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	ChgNumber	Number(14,0) default 0 NULL ,
	ProfileStateProduction	Varchar2(16 ) NULL,
	ProfileStateShadow	Varchar2(16 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_ApplicationServer, UID_Profile)
 	)   
go
Create Table AppServerGotDriverProfile (
	UID_ApplicationServer	Varchar2(38 ) NOT NULL,
	UID_Profile	Varchar2(38 ) NOT NULL,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	ChgNumber	Number(14,0) default 0 NULL ,
	ProfileStateProduction	Varchar2(16 ) NULL,
	ProfileStateShadow	Varchar2(16 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_ApplicationServer, UID_Profile)
 	)   
go
Create Table AppServerGotMactypeInfo (
	UID_MachineType	Varchar2(38 ) NOT NULL,
	UID_ApplicationServer	Varchar2(38 ) NOT NULL,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	ChgNumber	Number(14,0) default 0 NULL ,
	ProfileStateProduction	Varchar2(16 ) NULL,
	ProfileStateShadow	Varchar2(16 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_MachineType, UID_ApplicationServer)
 	)   
go
 
declare
      v_exists number;
begin
	begin
		v_exists := 0;
		select 1 into v_exists  from dual where exists
				( select 1 from User_Objects where Object_name = upper('BaseTree') and Object_Type in ('TABLE', 'VIEW'));
		exception
			when no_data_found then
				raise_application_error(-20100, '#LDS#Dependent Table {0} not exists|BaseTree|', true);
	end;
end;
go
	
alter table BaseTree add 	IsLicenceNode	Number(1,0 ) default 0 
go
 
 
Create Table BaseTreeHasDriver (
	UID_Org	Varchar2(38 ) NOT NULL,
	UID_Driver	Varchar2(38 ) NOT NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL ,
	XOrigin	Number(14,0) default 0 NULL ,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	XIsInEffect	Number(1,0 ) default 0  
	, Primary Key (UID_Org, UID_Driver)
 	)   
go
Create Table BaseTreeHasLicence (
	CountLicMacIndirectActual	Number(14,0) default 0 NULL ,
	CountLicUserActual	Number(14,0) default 0 NULL ,
	CountLicMacDirectActual	Number(14,0) default 0 NULL ,
	CountLicMacPossTarget	Number(14,0) default 0 NULL ,
	CountLicUserTarget	Number(14,0) default 0 NULL ,
	ValidTo	Date NULL ,
	XObjectKey	Varchar2(138 ) NOT NULL,
	CountLicMacPossActual	Number(14,0) default 0 NULL ,
	ValidFrom	Date NULL ,
	CountLicMacReal	Number(14,0) default 0 NULL ,
	XMarkedForDeletion	Number(14,0) default 0 NULL ,
	CountLimit	Number(14,0) default 0 NULL ,
	XDateInserted	Date NULL ,
	UID_Licence	Varchar2(38 ) NOT NULL,
	UID_Org	Varchar2(38 ) NOT NULL,
	CountLicMacIndirectTarget	Number(14,0) default 0 NULL ,
	XTouched	Varchar2(1 ) NULL,
	CountLicMacDirectTarget	Number(14,0) default 0 NULL ,
	XDateUpdated	Date NULL ,
	XUserUpdated	Varchar2(64 ) NULL,
	XUserInserted	Varchar2(64 ) NULL 
	, Primary Key (UID_Licence, UID_Org)
 	)   
go
Create Table BaseTreeHasLicencePurchase (
	UID_Org	Varchar2(38 ) NOT NULL,
	UID_LicencePurchase	Varchar2(38 ) NOT NULL,
	CountLicence	Number(14,0) default 0 NULL ,
	IsInActive	Number(1,0 ) default 0 ,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_Org, UID_LicencePurchase)
 	)   
go
Create Table BaseTreeRelatedToBasetree (
	UID_Org	Varchar2(38 ) NOT NULL,
	UID_OrgRelated	Varchar2(38 ) NOT NULL,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_Org, UID_OrgRelated)
 	)   
go
Create Table ClientLog (
	UID_ClientLog	Varchar2(38 ) NOT NULL,
	UID_LDAPAccount	Varchar2(38 ) NULL,
	UID_ADSAccount	Varchar2(38 ) NULL,
	UID_Hardware	Varchar2(38 ) NULL,
	UserNamespace	Varchar2(3 ) NULL,
	InstallDate	Date NULL ,
	LogContent	CLOB,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_ClientLog)
 	)   
go
Create Table Driver (
	UID_Driver	Varchar2(38 ) NOT NULL,
	UID_OS	Varchar2(38 ) NOT NULL,
	UID_ApplicationType	Varchar2(38 ) NULL,
	Ident_SectionName	Varchar2(64 ) NULL,
	Ident_OS	Varchar2(32 ) NULL,
	Ident_Language	Varchar2(32 ) NOT NULL,
	Version	Varchar2(32 ) NOT NULL,
	Ident_Driver	Varchar2(128 ) NOT NULL,
	DriverURL	CLOB,
	Description	CLOB,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	NameFull	Varchar2(255 ) NULL,
	SomeComments	CLOB,
	LicenceState	CLOB,
	LicenceClerk	Varchar2(64 ) NULL,
	LicencePrice	Number(14,0) default 0 NULL ,
	CustomProperty01	Varchar2(64 ) NULL,
	CustomProperty02	Varchar2(64 ) NULL,
	CustomProperty03	Varchar2(64 ) NULL,
	CustomProperty04	Varchar2(64 ) NULL,
	CustomProperty05	Varchar2(64 ) NULL,
	CustomProperty06	Varchar2(64 ) NULL,
	CustomProperty07	Varchar2(64 ) NULL,
	CustomProperty08	Varchar2(64 ) NULL,
	CustomProperty09	Varchar2(64 ) NULL,
	CustomProperty10	Varchar2(64 ) NULL,
	IsProfileApplication	Number(1,0 ) default 0 ,
	XTouched	Varchar2(1 ) NULL,
	SupportedOperatingSystems	CLOB,
	AppUpdateCycle	Varchar2(64 ) NULL,
	AppStatusIndicator	Varchar2(64 ) NULL,
	AppInstallationMode	Varchar2(64 ) NULL,
	AppAccessType	Varchar2(64 ) NULL,
	AppPermitType	Varchar2(64 ) NULL,
	DocumentationURL	CLOB,
	InternalProductName	Varchar2(64 ) NULL,
	DateStatusIndicatorChanged	Date NULL ,
	DateFirstInstall	Date NULL ,
	SortOrderForProfile	Number(14,0) default 0 NULL ,
	UID_AccProduct	Varchar2(38 ) NULL,
	IsInActive	Number(1,0 ) default 0 ,
	XObjectKey	Varchar2(138 ) NOT NULL,
	IsForITShop	Number(1,0 ) default 0 ,
	IsITShopOnly	Number(1,0 ) default 0 ,
	XMarkedForDeletion	Number(14,0) default 0 NULL ,
	UID_DialogCulture	Varchar2(38 ) NULL,
	UID_SectionName	Varchar2(38 ) NULL 
	, Primary Key (UID_Driver)
 	)   
go
Create Table DriverCanUsedByRD (
	UID_Profile	Varchar2(38 ) NOT NULL,
	UID_SDLDomainAllowed	Varchar2(38 ) NOT NULL,
	Ident_DomainAllowed	Varchar2(32 ) NOT NULL,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_Profile, UID_SDLDomainAllowed)
 	)   
go
Create Table DriverDependsOnDriver (
	UID_DriverChild	Varchar2(38 ) NOT NULL,
	UID_DriverParent	Varchar2(38 ) NOT NULL,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	IsPhysicalDependent	Number(1,0 ) default 0 ,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_DriverChild, UID_DriverParent)
 	)   
go
Create Table DriverExcludeDriver (
	UID_DriverExcluded	Varchar2(38 ) NOT NULL,
	UID_Driver	Varchar2(38 ) NOT NULL,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_DriverExcluded, UID_Driver)
 	)   
go
Create Table DriverHasLicence (
	XUserUpdated	Varchar2(64 ) NULL,
	XUserInserted	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL ,
	UID_Licence	Varchar2(38 ) NOT NULL,
	XDateUpdated	Date NULL ,
	UID_Driver	Varchar2(38 ) NOT NULL,
	XDateInserted	Date NULL  
	, Primary Key (UID_Licence, UID_Driver)
 	)   
go
Create Table DriverProfile (
	UID_Profile	Varchar2(38 ) NOT NULL,
	Ident_DomainRD	Varchar2(32 ) NULL,
	ChgNumber	Number(14,0) default 0 NOT NULL ,
	OrderNumber	Number (38,16)  default 0 NULL,
	DefDriveTarget	Varchar2(2 ) NULL,
	OSMode	Varchar2(17 ) NOT NULL,
	MemoryUsage	CLOB,
	ChgTest	Number(14,0) default 0 NOT NULL ,
	SubPath	CLOB,
	ClientStepCounter	Number(14,0) default 0 NULL ,
	ProfileCreator	Varchar2(64 ) NULL,
	ProfileDate	Date NULL ,
	ProfileModifier	Varchar2(64 ) NULL,
	ProfileModDate	Date NULL ,
	Description	CLOB,
	Ident_DomainRDOwner	Varchar2(32 ) NULL,
	UID_Driver	Varchar2(38 ) NOT NULL,
	DisplayName	Varchar2(255 ) NULL,
	ChgCL	Number(14,0) default 0 NULL ,
	UpdatePathVII	Number(1,0 ) default 0 ,
	UpdateProfileVII	Number(1,0 ) default 0 ,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	ProfileType	Varchar2(3 ) NULL,
	PackagePath	CLOB,
	HashValueTAS	Number(14,0) default 0 NULL ,
	HashValueFDS	Number(14,0) default 0 NULL ,
	XTouched	Varchar2(1 ) NULL,
	CachingBehavior	Varchar2(64 ) NULL,
	RemoveHKeyCurrentUser	Number(1,0 ) default 0 ,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL ,
	UID_SDLDomainRD	Varchar2(38 ) NOT NULL,
	UID_SDLDomainRDOwner	Varchar2(38 ) NOT NULL 
	, Primary Key (UID_Profile)
 	)   
go
 
declare
      v_exists number;
begin
	begin
		v_exists := 0;
		select 1 into v_exists  from dual where exists
				( select 1 from User_Objects where Object_name = upper('FirmPartner') and Object_Type in ('TABLE', 'VIEW'));
		exception
			when no_data_found then
				raise_application_error(-20100, '#LDS#Dependent Table {0} not exists|FirmPartner|', true);
	end;
end;
go
	
 
declare
      v_exists number;
begin
	begin
		v_exists := 0;
		select 1 into v_exists  from dual where exists
				( select 1 from User_Objects where Object_name = upper('Hardware') and Object_Type in ('TABLE', 'VIEW'));
		exception
			when no_data_found then
				raise_application_error(-20100, '#LDS#Dependent Table {0} not exists|Hardware|', true);
	end;
end;
go
	
alter table Hardware add 	UID_MachineType	Varchar2(38 ) NULL
go
 
 
alter table Hardware add 	IsVIPC	Number(1,0 ) default 0 
go
 
 
alter table Hardware add 	Ident_DomainRD	Varchar2(32 ) NULL
go
 
 
alter table Hardware add 	UID_SDLDomainRD	Varchar2(38 ) NULL
go
 
 
alter table Hardware add 	UpdateCNAME	Number(1,0 ) default 0 
go
 
 
alter table Hardware add 	UID_InstallationType	Varchar2(38 ) NULL
go
 
 
alter table Hardware add 	UID_OS	Varchar2(38 ) NULL
go
 
 
alter table Hardware add 	HomeServerOfDefaultUser	CLOB
go
 
 
alter table Hardware add 	DefaultUserContext	CLOB
go
 
 
alter table Hardware add 	DefaultWorkGroup	Varchar2(16 ) NULL
go
 
 
alter table Hardware add 	UpdateUDF	Number(1,0 ) default 0 
go
 
 
alter table Hardware add 	UpdateMac2Name	Number(1,0 ) default 0 
go
 
 
alter table Hardware add 	DisplayBitsPerPel	Number(14,0) default 0 NULL 
go
 
 
alter table Hardware add 	DisplayVRefresh	Number(14,0) default 0 NULL 
go
 
 
alter table Hardware add 	DisplayXResolution	Number(14,0) default 0 NULL 
go
 
 
alter table Hardware add 	DisplayYResolution	Number(14,0) default 0 NULL 
go
 
 
 
declare
      v_exists number;
begin
	begin
		v_exists := 0;
		select 1 into v_exists  from dual where exists
				( select 1 from User_Objects where Object_name = upper('HardwareType') and Object_Type in ('TABLE', 'VIEW'));
		exception
			when no_data_found then
				raise_application_error(-20100, '#LDS#Dependent Table {0} not exists|HardwareType|', true);
	end;
end;
go
	
alter table HardwareType add 	IsViClientPCDependent	Number(1,0 ) default 0 
go
 
 
Create Table HardwareTypeHasDriver (
	UID_HardwareType	Varchar2(38 ) NOT NULL,
	UID_Driver	Varchar2(38 ) NOT NULL,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_HardwareType, UID_Driver)
 	)   
go
Create Table InstallationType (
	UID_InstallationType	Varchar2(38 ) NOT NULL,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL ,
	Ident_InstType	Varchar2(64 ) NOT NULL 
	, Primary Key (UID_InstallationType)
 	)   
go
 
declare
      v_exists number;
begin
	begin
		v_exists := 0;
		select 1 into v_exists  from dual where exists
				( select 1 from User_Objects where Object_name = upper('LDAPAccount') and Object_Type in ('TABLE', 'VIEW'));
		exception
			when no_data_found then
				raise_application_error(-20100, '#LDS#Dependent Table {0} not exists|LDAPAccount|', true);
	end;
end;
go
	
alter table LDAPAccount add 	IsAppAccount	Number(1,0 ) default 0 
go
 
 
Create Table Licence (
	UID_Licence	Varchar2(38 ) NOT NULL,
	UID_OS	Varchar2(38 ) NULL,
	Ident_OS	Varchar2(32 ) NULL,
	UID_FirmPartner	Varchar2(38 ) NULL,
	UID_ApplicationType	Varchar2(38 ) NULL,
	Ident_Language	Varchar2(32 ) NULL,
	Ident_LicenceType	Varchar2(64 ) NULL,
	Ident_Licence	Varchar2(64 ) NULL,
	CountLimit	Number(14,0) default 0 NULL ,
	Version	Varchar2(32 ) NULL,
	IsInActive	Number(1,0 ) default 0 ,
	ValidFrom	Date NULL ,
	ValidTo	Date NULL ,
	Description	CLOB,
	CustomProperty01	Varchar2(64 ) NULL,
	CustomProperty02	Varchar2(64 ) NULL,
	CustomProperty03	Varchar2(64 ) NULL,
	CustomProperty04	Varchar2(64 ) NULL,
	CustomProperty05	Varchar2(64 ) NULL,
	CustomProperty06	Varchar2(64 ) NULL,
	CustomProperty07	Varchar2(64 ) NULL,
	CustomProperty08	Varchar2(64 ) NULL,
	CustomProperty09	Varchar2(64 ) NULL,
	CustomProperty10	Varchar2(64 ) NULL,
	ArticleCode	Varchar2(64 ) NULL,
	ArticleCodeManufacturer	Varchar2(64 ) NULL,
	OrderUnit	Varchar2(32 ) NULL,
	OrderQuantityMin	Number(14,0) default 0 NULL ,
	LastOfferDate	Date NULL ,
	LastOfferPrice	Number(14,0) default 0 NULL ,
	LastDeliverDate	Date NULL ,
	LastDeliverPrice	Number(14,0) default 0 NULL ,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	CountLicMacDirectTarget	Number(14,0) default 0 NULL ,
	CountLicMacIndirectTarget	Number(14,0) default 0 NULL ,
	CountLicUserTarget	Number(14,0) default 0 NULL ,
	CountLicMacPossTarget	Number(14,0) default 0 NULL ,
	CountLicMacDirectActual	Number(14,0) default 0 NULL ,
	CountLicMacIndirectActual	Number(14,0) default 0 NULL ,
	CountLicUserActual	Number(14,0) default 0 NULL ,
	CountLicMacPossActual	Number(14,0) default 0 NULL ,
	CountLicMacReal	Number(14,0) default 0 NULL ,
	LicenceNameManufacturer	CLOB,
	LicenceProductType	Varchar2(64 ) NULL,
	LicenceStatusIndicator	Varchar2(64 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL ,
	UID_DialogCulture	Varchar2(38 ) NULL,
	UID_LicenceType	Varchar2(38 ) NULL 
	, Primary Key (UID_Licence)
 	)   
go
Create Table LicencePurchase (
	CustomProperty06	Varchar2(64 ) NULL,
	CustomProperty05	Varchar2(64 ) NULL,
	CustomProperty04	Varchar2(64 ) NULL,
	CustomProperty07	Varchar2(64 ) NULL,
	CustomProperty08	Varchar2(64 ) NULL,
	CustomProperty09	Varchar2(64 ) NULL,
	GuarantyMonths	Number(14,0) default 0 NULL ,
	BuyDate	Date NULL ,
	CustomProperty03	Varchar2(64 ) NULL,
	CustomProperty02	Varchar2(64 ) NULL,
	GuarantyMonthsAdditional	Number(14,0) default 0 NULL ,
	CustomProperty01	Varchar2(64 ) NULL,
	EndOfUse	Date NULL ,
	SerialNumber	CLOB,
	OrderNumber	Varchar2(64 ) NULL,
	ArticleCodeManufacturer	Varchar2(64 ) NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL ,
	LicencePurchaseType	Varchar2(20 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	CustomProperty10	Varchar2(64 ) NULL,
	XDateInserted	Date NULL ,
	XUserUpdated	Varchar2(64 ) NULL,
	ArticleCodeDealer	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	UID_LicenceType	Varchar2(38 ) NULL,
	AssetReceiptNumber	Varchar2(64 ) NULL,
	AssetValueNew	Number(14,0) default 0 NULL ,
	AssetDeActivate	Date NULL ,
	AssetAmortizationMonth	Number(14,0) default 0 NULL ,
	DeliveryDate	Date NULL ,
	AssetNumber	Varchar2(64 ) NULL,
	CountLicence	Number(14,0) default 0 NULL ,
	Ident_LicenceType	Varchar2(64 ) NULL,
	UID_LicencePurchase	Varchar2(38 ) NOT NULL,
	AssetActivate	Date NULL ,
	UID_Licence	Varchar2(38 ) NULL,
	UID_OrgOwner	Varchar2(38 ) NULL,
	UID_FirmPartnerVendor	Varchar2(38 ) NULL,
	GuarantyNumber	Varchar2(64 ) NULL,
	IsLeasingAsset	Number(1,0 ) default 0 ,
	AssetDeliveryRemarks	Varchar2(32 ) NULL,
	AssetInventoryText	Varchar2(32 ) NULL,
	Guaranty	Date NULL ,
	DeliveryNumber	Varchar2(64 ) NULL,
	Currency	Varchar2(32 ) NULL,
	CountLicenceRemaining	Number(14,0) default 0 NULL ,
	AssetIdent	Varchar2(64 ) NULL,
	IsInActive	Number(1,0 ) default 0 ,
	AssetInventory	Date NULL ,
	AssetOwnership	Number(1,0 ) default 0 ,
	RentCharge	Number(14,0) default 0 NULL ,
	AssetValueCurrent	Number(14,0) default 0 NULL  
	, Primary Key (UID_LicencePurchase)
 	)   
go
Create Table LicenceSubstitute (
	XUserUpdated	Varchar2(64 ) NULL,
	XUserInserted	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL ,
	UID_Licence	Varchar2(38 ) NOT NULL,
	XDateUpdated	Date NULL ,
	UID_LicenceSubstitute	Varchar2(38 ) NOT NULL,
	XDateInserted	Date NULL  
	, Primary Key (UID_Licence, UID_LicenceSubstitute)
 	)   
go
Create Table LicenceSubstituteTotal (
	UID_GroupRoot	Varchar2(38 ) NULL,
	UID_Licence	Varchar2(38 ) NOT NULL,
	UID_LicenceSubstitute	Varchar2(38 ) NOT NULL,
	CountSteps	Number(14,0) default 0 NULL ,
	SortOrder	Number(14,0) default 0 NULL ,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_Licence, UID_LicenceSubstitute)
 	)   
go
Create Table LicenceType (
	UID_LicenceType	Varchar2(38 ) NOT NULL,
	Ident_LicenceType	Varchar2(64 ) NOT NULL,
	Description	CLOB,
	IsPerCompany	Number(1,0 ) default 0 ,
	IsPerUser	Number(1,0 ) default 0 ,
	IsPerMachine	Number(1,0 ) default 0 ,
	IsPerProcessor	Number(1,0 ) default 0 ,
	CustomProperty01	Varchar2(64 ) NULL,
	CustomProperty02	Varchar2(64 ) NULL,
	CustomProperty03	Varchar2(64 ) NULL,
	CustomProperty04	Varchar2(64 ) NULL,
	CustomProperty05	Varchar2(64 ) NULL,
	CustomProperty06	Varchar2(64 ) NULL,
	CustomProperty07	Varchar2(64 ) NULL,
	CustomProperty08	Varchar2(64 ) NULL,
	CustomProperty09	Varchar2(64 ) NULL,
	CustomProperty10	Varchar2(64 ) NULL,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	IsConcurrentUse	Number(1,0 ) default 0 ,
	IsForFree	Number(1,0 ) default 0 ,
	IsToPayOnce	Number(1,0 ) default 0 ,
	IsToPayRecent	Number(1,0 ) default 0 ,
	IsLocalityBased	Number(1,0 ) default 0 ,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_LicenceType)
 	)   
go
Create Table MachineAppsConfig (
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
 	)   
go
Create Table MachineAppsInfo (
	UID_MachineAppsInfo	Varchar2(38 ) NOT NULL,
	UID_Driver	Varchar2(38 ) NULL,
	UID_Application	Varchar2(38 ) NULL,
	UID_Hardware	Varchar2(38 ) NULL,
	UID_OS	Varchar2(38 ) NULL,
	AppsNotDriver	Number(1,0 ) default 0 ,
	UID_InstallationType	Varchar2(38 ) NULL,
	CurrentlyActive	Number(1,0 ) default 0 ,
	InstallDate	Date NULL ,
	DeInstallDate	Date NULL ,
	DisplayName	Varchar2(255 ) NULL,
	Revision	Number(14,0) default 0 NULL ,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_MachineAppsInfo)
 	)   
go
Create Table MachineHasDriver (
	UID_Hardware	Varchar2(38 ) NOT NULL,
	UID_Driver	Varchar2(38 ) NOT NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL ,
	XOrigin	Number(14,0) default 0 NULL ,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	XIsInEffect	Number(1,0 ) default 0  
	, Primary Key (UID_Hardware, UID_Driver)
 	)   
go
Create Table MachineType (
	UID_MachineType	Varchar2(38 ) NOT NULL,
	UID_SDLDomain	Varchar2(38 ) NULL,
	Ident_DomainMachineType	Varchar2(32 ) NOT NULL,
	Ident_MachineType	Varchar2(64 ) NOT NULL,
	GraphicCard	Varchar2(64 ) NULL,
	RemoteBoot	Number(1,0 ) default 0 ,
	BootImageWin	Varchar2(8 ) NULL,
	ChgNumber	Number(14,0) default 0 NULL ,
	Netcard	Varchar2(64 ) NULL,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	MakeFullcopy	Number(1,0 ) default 0 ,
	XTouched	Varchar2(1 ) NULL,
	IsInActive	Number(1,0 ) default 0 ,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_MachineType)
 	)   
go
Create Table MachineTypeHasDriver (
	UID_MachineType	Varchar2(38 ) NOT NULL,
	UID_Driver	Varchar2(38 ) NOT NULL,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_MachineType, UID_Driver)
 	)   
go
 
declare
      v_exists number;
begin
	begin
		v_exists := 0;
		select 1 into v_exists  from dual where exists
				( select 1 from User_Objects where Object_name = upper('OS') and Object_Type in ('TABLE', 'VIEW'));
		exception
			when no_data_found then
				raise_application_error(-20100, '#LDS#Dependent Table {0} not exists|OS|', true);
	end;
end;
go
	
alter table OS add 	UID_Licence	Varchar2(38 ) NULL
go
 
 
Create Table OsInstType (
	XUserUpdated	Varchar2(64 ) NULL,
	XUserInserted	Varchar2(64 ) NULL,
	XDateUpdated	Date NULL ,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL ,
	UID_OS	Varchar2(38 ) NOT NULL,
	UID_OsInstType	Varchar2(38 ) NOT NULL,
	XDateInserted	Date NULL ,
	Ident_InstType	Varchar2(64 ) NULL,
	UID_InstallationType	Varchar2(38 ) NOT NULL,
	Ident_OS	Varchar2(32 ) NULL 
	, Primary Key (UID_OsInstType)
 	)   
go
 
declare
      v_exists number;
begin
	begin
		v_exists := 0;
		select 1 into v_exists  from dual where exists
				( select 1 from User_Objects where Object_name = upper('Person') and Object_Type in ('TABLE', 'VIEW'));
		exception
			when no_data_found then
				raise_application_error(-20100, '#LDS#Dependent Table {0} not exists|Person|', true);
	end;
end;
go
	
alter table Person add 	IsTASUser	Number(1,0 ) default 0 
go
 
 
Create Table ProfileCanUsedAlso (
	XUserUpdated	Varchar2(64 ) NULL,
	XUserInserted	Varchar2(64 ) NULL,
	XDateUpdated	Date NULL ,
	XMarkedForDeletion	Number(14,0) default 0 NULL ,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	UID_InstallationType	Varchar2(38 ) NULL,
	UID_OsInstType	Varchar2(38 ) NOT NULL,
	UID_Profile	Varchar2(38 ) NOT NULL,
	XDateInserted	Date NULL ,
	Ident_InstTypeAlso	Varchar2(64 ) NOT NULL,
	UID_OS	Varchar2(38 ) NULL,
	Ident_OSAlso	Varchar2(32 ) NOT NULL 
	, Primary Key (UID_OsInstType, UID_Profile)
 	)   
go
Create Table ProfileCanUsedByRD (
	UID_Profile	Varchar2(38 ) NOT NULL,
	UID_SDLDomainAllowed	Varchar2(38 ) NOT NULL,
	Ident_DomainAllowed	Varchar2(32 ) NOT NULL,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_Profile, UID_SDLDomainAllowed)
 	)   
go
 
declare
      v_exists number;
begin
	begin
		v_exists := 0;
		select 1 into v_exists  from dual where exists
				( select 1 from User_Objects where Object_name = upper('QBMCulture') and Object_Type in ('TABLE', 'VIEW'));
		exception
			when no_data_found then
				raise_application_error(-20100, '#LDS#Dependent Table {0} not exists|QBMCulture|', true);
	end;
end;
go
	
 
declare
      v_exists number;
begin
	begin
		v_exists := 0;
		select 1 into v_exists  from dual where exists
				( select 1 from User_Objects where Object_name = upper('QBMServer') and Object_Type in ('TABLE', 'VIEW'));
		exception
			when no_data_found then
				raise_application_error(-20100, '#LDS#Dependent Table {0} not exists|QBMServer|', true);
	end;
end;
go
	
alter table QBMServer add 	BasePathForShares	CLOB
go
 
 
Create Table SDLDomain (
	UID_SDLDomain	Varchar2(38 ) NOT NULL,
	UID_AERoleOwner	Varchar2(38 ) NULL,
	UID_ADSDomain	Varchar2(38 ) NULL,
	UID_ServerTAS	Varchar2(38 ) NULL,
	Ident_Domain	Varchar2(32 ) NOT NULL,
	IsMaster	Number(1,0 ) default 0 ,
	ShareOnServers	Varchar2(32 ) NULL,
	Description	CLOB,
	ServerPartShareOnServers	Varchar2(64 ) NULL,
	ClientPartPathOnServers	Varchar2(32 ) NULL,
	ClientPartApps	Varchar2(32 ) NULL,
	ClientPartDriver	Varchar2(32 ) NULL,
	ClientPartMacType	Varchar2(32 ) NULL,
	DefaultAppsDrive	Varchar2(2 ) NULL,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	ClientDrive	Varchar2(2 ) NULL,
	ShareOnTAS	Varchar2(32 ) NULL,
	NetlogonOnTAS	Varchar2(32 ) NULL,
	ServerPartShareOnTas	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	DomainGroupName	Varchar2(128 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	DisplayName	Varchar2(128 ) NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL ,
	UID_SDLDomainParent	Varchar2(38 ) NULL 
	, Primary Key (UID_SDLDomain)
 	)   
go
Create Table SectionName (
	UID_SectionName	Varchar2(38 ) NOT NULL,
	Ident_SectionName	Varchar2(64 ) NOT NULL,
	Description	CLOB,
	AppsNotDriver	Number(1,0 ) default 0 ,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_SectionName)
 	)   
go
Create Table SoftwareDependsOnSoftware (
	UID_Child	Varchar2(38 ) NOT NULL,
	UID_Parent	Varchar2(38 ) NOT NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL  
	, Primary Key (UID_Child, UID_Parent)
 	)   
go
 
declare
      v_exists number;
begin
	begin
		v_exists := 0;
		select 1 into v_exists  from dual where exists
				( select 1 from User_Objects where Object_name = upper('WorkDesk') and Object_Type in ('TABLE', 'VIEW'));
		exception
			when no_data_found then
				raise_application_error(-20100, '#LDS#Dependent Table {0} not exists|WorkDesk|', true);
	end;
end;
go
	
alter table WorkDesk add 	DisableVIClient	Number(1,0 ) default 0 
go
 
 
alter table WorkDesk add 	IsViClientPCDependent	Number(1,0 ) default 0 
go
 
 
Create Table WorkDeskHasDriver (
	UID_WorkDesk	Varchar2(38 ) NOT NULL,
	UID_Driver	Varchar2(38 ) NOT NULL,
	XTouched	Varchar2(1 ) NULL,
	XObjectKey	Varchar2(138 ) NOT NULL,
	XMarkedForDeletion	Number(14,0) default 0 NULL ,
	XOrigin	Number(14,0) default 0 NULL ,
	XDateInserted	Date NULL ,
	XDateUpdated	Date NULL ,
	XUserInserted	Varchar2(64 ) NULL,
	XUserUpdated	Varchar2(64 ) NULL,
	XIsInEffect	Number(1,0 ) default 0  
	, Primary Key (UID_WorkDesk, UID_Driver)
 	)   
go
