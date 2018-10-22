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
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2391ADSAccount', 'ADSAccount' ,'UID_SDLDomainRD' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2391ADSAccount on ADSAccount
    (
UID_SDLDomainRD
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI770ADSAccount', 'ADSAccount' ,'UID_HardwareDefaultMachine' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI770ADSAccount on ADSAccount
    (
UID_HardwareDefaultMachine
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9ADSAccountAppsInfo', 'ADSAccountAppsInfo' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9ADSAccountAppsInfo on ADSAccountAppsInfo
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9AppHasLicence', 'AppHasLicence' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9AppHasLicence on AppHasLicence
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1106AppHasLicence', 'AppHasLicence' ,'UID_Application' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1106AppHasLicence on AppHasLicence
    (
UID_Application
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI421Application', 'Application' ,'UID_SectionName' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI421Application on Application
    (
UID_SectionName
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI844Application', 'Application' ,'UID_ApplicationType' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI844Application on Application
    (
UID_ApplicationType
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9ApplicationDependsOnDri', 'ApplicationDependsOnDriver' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9ApplicationDependsOnDri on ApplicationDependsOnDriver
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1279ApplicationDependsOn', 'ApplicationDependsOnDriver' ,'UID_DriverParent' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1279ApplicationDependsOn on ApplicationDependsOnDriver
    (
UID_DriverParent
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9ApplicationExcludeDrive', 'ApplicationExcludeDriver' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9ApplicationExcludeDrive on ApplicationExcludeDriver
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1378ApplicationExcludeDr', 'ApplicationExcludeDriver' ,'UID_Application' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1378ApplicationExcludeDr on ApplicationExcludeDriver
    (
UID_Application
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA1ApplicationProfile', 'ApplicationProfile' ,'UID_Application' ,'UID_InstallationType' ,'UID_OS' ,'UID_SDLDomainRD' , default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA1ApplicationProfile on ApplicationProfile
    (
UID_Application, UID_InstallationType, UID_OS, UID_SDLDomainRD
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9ApplicationProfile', 'ApplicationProfile' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9ApplicationProfile on ApplicationProfile
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI214ApplicationProfile', 'ApplicationProfile' ,'UID_InstallationType' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI214ApplicationProfile on ApplicationProfile
    (
UID_InstallationType
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI21AppProfile', 'ApplicationProfile' ,'UID_Application' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI21AppProfile on ApplicationProfile
    (
UID_Application
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2394ApplicationProfile', 'ApplicationProfile' ,'UID_SDLDomainRD' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2394ApplicationProfile on ApplicationProfile
    (
UID_SDLDomainRD
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2395ApplicationProfile', 'ApplicationProfile' ,'UID_SDLDomainRDOwner' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2395ApplicationProfile on ApplicationProfile
    (
UID_SDLDomainRDOwner
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2553ApplicationProfile', 'ApplicationProfile' ,'UID_OS' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2553ApplicationProfile on ApplicationProfile
    (
UID_OS
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9ApplicationServer', 'ApplicationServer' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9ApplicationServer on ApplicationServer
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1130ApplicationServer', 'ApplicationServer' ,'UID_ApplicationServerRedirect' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1130ApplicationServer on ApplicationServer
    (
UID_ApplicationServerRedirect
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2443ApplicationServer', 'ApplicationServer' ,'UID_SDLDomain' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2443ApplicationServer on ApplicationServer
    (
UID_SDLDomain
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2482ApplicationServer', 'ApplicationServer' ,'UID_Server' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2482ApplicationServer on ApplicationServer
    (
UID_Server
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI401ApplicationServer', 'ApplicationServer' ,'UID_ParentApplicationServer' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI401ApplicationServer on ApplicationServer
    (
UID_ParentApplicationServer
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9ApplicationType', 'ApplicationType' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9ApplicationType on ApplicationType
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9AppServerGotAppProfile', 'AppServerGotAppProfile' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9AppServerGotAppProfile on AppServerGotAppProfile
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI580AppServerGotAppProfil', 'AppServerGotAppProfile' ,'UID_Profile' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI580AppServerGotAppProfil on AppServerGotAppProfile
    (
UID_Profile
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9AppServerGotDriverProfi', 'AppServerGotDriverProfile' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9AppServerGotDriverProfi on AppServerGotDriverProfile
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI581AppServerGotDriverPro', 'AppServerGotDriverProfile' ,'UID_Profile' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI581AppServerGotDriverPro on AppServerGotDriverProfile
    (
UID_Profile
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9AppServerGotMactypeInfo', 'AppServerGotMactypeInfo' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9AppServerGotMactypeInfo on AppServerGotMactypeInfo
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI615AppServerGotMactypeIn', 'AppServerGotMactypeInfo' ,'UID_ApplicationServer' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI615AppServerGotMactypeIn on AppServerGotMactypeInfo
    (
UID_ApplicationServer
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9BaseTreeHasDriver', 'BaseTreeHasDriver' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9BaseTreeHasDriver on BaseTreeHasDriver
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI642BaseTreeHasDriver', 'BaseTreeHasDriver' ,'UID_Driver' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI642BaseTreeHasDriver on BaseTreeHasDriver
    (
UID_Driver
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9BaseTreeHasLicence', 'BaseTreeHasLicence' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9BaseTreeHasLicence on BaseTreeHasLicence
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1115BaseTreeHasLicence', 'BaseTreeHasLicence' ,'UID_Org' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1115BaseTreeHasLicence on BaseTreeHasLicence
    (
UID_Org
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9BaseTreeHasLicencePurch', 'BaseTreeHasLicencePurchase' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9BaseTreeHasLicencePurch on BaseTreeHasLicencePurchase
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1113BaseTreeHasLicencePu', 'BaseTreeHasLicencePurchase' ,'UID_LicencePurchase' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1113BaseTreeHasLicencePu on BaseTreeHasLicencePurchase
    (
UID_LicencePurchase
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9BaseTreeRelatedToBasetr', 'BaseTreeRelatedToBasetree' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9BaseTreeRelatedToBasetr on BaseTreeRelatedToBasetree
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1628BaseTreeRelatedToBas', 'BaseTreeRelatedToBasetree' ,'UID_OrgRelated' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1628BaseTreeRelatedToBas on BaseTreeRelatedToBasetree
    (
UID_OrgRelated
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9ClientLog', 'ClientLog' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9ClientLog on ClientLog
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1467ClientLog', 'ClientLog' ,'UID_LDAPAccount' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1467ClientLog on ClientLog
    (
UID_LDAPAccount
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI669ClientLog', 'ClientLog' ,'UID_Hardware' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI669ClientLog on ClientLog
    (
UID_Hardware
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI799ClientLog', 'ClientLog' ,'UID_ADSAccount' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI799ClientLog on ClientLog
    (
UID_ADSAccount
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA1Driver', 'Driver' ,'Ident_Driver' ,'Version' ,'UID_OS' ,'UID_DialogCulture' , default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA1Driver on Driver
    (
Ident_Driver, Version, UID_OS, UID_DialogCulture
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9Driver', 'Driver' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9Driver on Driver
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1091Driver', 'Driver' ,'UID_ApplicationType' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1091Driver on Driver
    (
UID_ApplicationType
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1314Driver', 'Driver' ,'UID_AccProduct' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1314Driver on Driver
    (
UID_AccProduct
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2386Driver', 'Driver' ,'UID_DialogCulture' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2386Driver on Driver
    (
UID_DialogCulture
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2552Driver', 'Driver' ,'UID_OS' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2552Driver on Driver
    (
UID_OS
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI495Driver', 'Driver' ,'UID_SectionName' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI495Driver on Driver
    (
UID_SectionName
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9DriverCanUsedByRD', 'DriverCanUsedByRD' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9DriverCanUsedByRD on DriverCanUsedByRD
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2404DriverCanUsedByRD', 'DriverCanUsedByRD' ,'UID_SDLDomainAllowed' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2404DriverCanUsedByRD on DriverCanUsedByRD
    (
UID_SDLDomainAllowed
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9DriverDependsOnDriver', 'DriverDependsOnDriver' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9DriverDependsOnDriver on DriverDependsOnDriver
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1276DriverDependsOnDrive', 'DriverDependsOnDriver' ,'UID_DriverParent' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1276DriverDependsOnDrive on DriverDependsOnDriver
    (
UID_DriverParent
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9DriverExcludeDriver', 'DriverExcludeDriver' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9DriverExcludeDriver on DriverExcludeDriver
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1375DriverExcludeDriver', 'DriverExcludeDriver' ,'UID_Driver' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1375DriverExcludeDriver on DriverExcludeDriver
    (
UID_Driver
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9DriverHasLicence', 'DriverHasLicence' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9DriverHasLicence on DriverHasLicence
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1108DriverHasLicence', 'DriverHasLicence' ,'UID_Driver' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1108DriverHasLicence on DriverHasLicence
    (
UID_Driver
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA1DriverProfile', 'DriverProfile' ,'UID_Driver' ,'UID_SDLDomainRD' , default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA1DriverProfile on DriverProfile
    (
UID_Driver, UID_SDLDomainRD
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9DriverProfile', 'DriverProfile' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9DriverProfile on DriverProfile
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2405DriverProfile', 'DriverProfile' ,'UID_SDLDomainRD' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2405DriverProfile on DriverProfile
    (
UID_SDLDomainRD
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2406DriverProfile', 'DriverProfile' ,'UID_SDLDomainRDOwner' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2406DriverProfile on DriverProfile
    (
UID_SDLDomainRDOwner
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI31DriverProfile', 'DriverProfile' ,'UID_Driver' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI31DriverProfile on DriverProfile
    (
UID_Driver
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2412Hardware', 'Hardware' ,'UID_SDLDomainRD' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2412Hardware on Hardware
    (
UID_SDLDomainRD
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2561Hardware', 'Hardware' ,'UID_OS' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2561Hardware on Hardware
    (
UID_OS
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI368Hardware', 'Hardware' ,'UID_MachineType' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI368Hardware on Hardware
    (
UID_MachineType
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI523Hardware', 'Hardware' ,'UID_InstallationType' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI523Hardware on Hardware
    (
UID_InstallationType
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9HardwaretypeHasDriver', 'HardwareTypeHasDriver' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9HardwaretypeHasDriver on HardwareTypeHasDriver
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1616HardwareTypeHasDrive', 'HardwareTypeHasDriver' ,'UID_Driver' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1616HardwareTypeHasDrive on HardwareTypeHasDriver
    (
UID_Driver
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9InstallationType', 'InstallationType' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9InstallationType on InstallationType
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9Licence', 'Licence' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9Licence on Licence
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1109Licence', 'Licence' ,'UID_LicenceType' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1109Licence on Licence
    (
UID_LicenceType
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1117Licence', 'Licence' ,'UID_ApplicationType' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1117Licence on Licence
    (
UID_ApplicationType
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1118Licence', 'Licence' ,'UID_FirmPartner' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1118Licence on Licence
    (
UID_FirmPartner
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2385Licence', 'Licence' ,'UID_DialogCulture' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2385Licence on Licence
    (
UID_DialogCulture
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2554Licence', 'Licence' ,'UID_OS' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2554Licence on Licence
    (
UID_OS
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9LicencePurchase', 'LicencePurchase' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9LicencePurchase on LicencePurchase
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1104LicencePurchase', 'LicencePurchase' ,'UID_Licence' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1104LicencePurchase on LicencePurchase
    (
UID_Licence
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1119LicencePurchase', 'LicencePurchase' ,'UID_FirmPartnerVendor' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1119LicencePurchase on LicencePurchase
    (
UID_FirmPartnerVendor
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1204LicencePurchase', 'LicencePurchase' ,'UID_OrgOwner' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1204LicencePurchase on LicencePurchase
    (
UID_OrgOwner
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1242LicencePurchase', 'LicencePurchase' ,'UID_LicenceType' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1242LicencePurchase on LicencePurchase
    (
UID_LicenceType
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9LicenceSubstitute', 'LicenceSubstitute' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9LicenceSubstitute on LicenceSubstitute
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1110LicenceSubstitute', 'LicenceSubstitute' ,'UID_LicenceSubstitute' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1110LicenceSubstitute on LicenceSubstitute
    (
UID_LicenceSubstitute
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9LicenceSubstituteTotal', 'LicenceSubstituteTotal' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9LicenceSubstituteTotal on LicenceSubstituteTotal
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI1128LicenceSubstituteTot', 'LicenceSubstituteTotal' ,'UID_LicenceSubstitute' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI1128LicenceSubstituteTot on LicenceSubstituteTotal
    (
UID_LicenceSubstitute
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2563LicenceSubstituteTot', 'LicenceSubstituteTotal' ,'UID_GroupRoot' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2563LicenceSubstituteTot on LicenceSubstituteTotal
    (
UID_GroupRoot
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9LicenceType', 'LicenceType' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9LicenceType on LicenceType
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9MachineAppsConfig', 'MachineAppsConfig' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9MachineAppsConfig on MachineAppsConfig
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9MachineAppsInfo', 'MachineAppsInfo' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9MachineAppsInfo on MachineAppsInfo
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9MachineHasDriver', 'MachineHasDriver' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9MachineHasDriver on MachineHasDriver
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI207MachineHasDriver', 'MachineHasDriver' ,'UID_Driver' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI207MachineHasDriver on MachineHasDriver
    (
UID_Driver
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA1MachineType', 'MachineType' ,'Ident_MachineType' ,'UID_SDLDomain' , default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA1MachineType on MachineType
    (
Ident_MachineType, UID_SDLDomain
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9MachineType', 'MachineType' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9MachineType on MachineType
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2549MachineType', 'MachineType' ,'UID_SDLDomain' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2549MachineType on MachineType
    (
UID_SDLDomain
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9MachineTypeHasDriver', 'MachineTypeHasDriver' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9MachineTypeHasDriver on MachineTypeHasDriver
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI640MachineTypeHasDriver', 'MachineTypeHasDriver' ,'UID_Driver' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI640MachineTypeHasDriver on MachineTypeHasDriver
    (
UID_Driver
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2550OS', 'OS' ,'UID_Licence' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2550OS on OS
    (
UID_Licence
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9OsInstType', 'OsInstType' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9OsInstType on OsInstType
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2551OsInstType', 'OsInstType' ,'UID_OS' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2551OsInstType on OsInstType
    (
UID_OS
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI336OsInstType', 'OsInstType' ,'UID_InstallationType' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI336OsInstType on OsInstType
    (
UID_InstallationType
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9ProfileCanUsedAlso', 'ProfileCanUsedAlso' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9ProfileCanUsedAlso on ProfileCanUsedAlso
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2555ProfileCanUsedAlso', 'ProfileCanUsedAlso' ,'UID_OS' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2555ProfileCanUsedAlso on ProfileCanUsedAlso
    (
UID_OS
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2564ProfileCanUsedAlso', 'ProfileCanUsedAlso' ,'UID_InstallationType' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2564ProfileCanUsedAlso on ProfileCanUsedAlso
    (
UID_InstallationType
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI289ProfileCanUsedAlso', 'ProfileCanUsedAlso' ,'UID_Profile' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI289ProfileCanUsedAlso on ProfileCanUsedAlso
    (
UID_Profile
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9ProfileCanUsedByRD', 'ProfileCanUsedByRD' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9ProfileCanUsedByRD on ProfileCanUsedByRD
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2418ProfileCanUsedByRD', 'ProfileCanUsedByRD' ,'UID_SDLDomainAllowed' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2418ProfileCanUsedByRD on ProfileCanUsedByRD
    (
UID_SDLDomainAllowed
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9SDLDomain', 'SDLDomain' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9SDLDomain on SDLDomain
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2484SDLDomain', 'SDLDomain' ,'UID_ServerTAS' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2484SDLDomain on SDLDomain
    (
UID_ServerTAS
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2556SDLDomain', 'SDLDomain' ,'UID_ADSDomain' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2556SDLDomain on SDLDomain
    (
UID_ADSDomain
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2560SDLDomain', 'SDLDomain' ,'UID_AERoleOwner' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2560SDLDomain on SDLDomain
    (
UID_AERoleOwner
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2562SDLDomain', 'SDLDomain' ,'UID_SDLDomainParent' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2562SDLDomain on SDLDomain
    (
UID_SDLDomainParent
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9SectionName', 'SectionName' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9SectionName on SectionName
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9SoftwareDependsOnSoftwa', 'SoftwareDependsOnSoftware' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9SoftwareDependsOnSoftwa on SoftwareDependsOnSoftware
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XA9WorkDeskHasDriver', 'WorkDeskHasDriver' ,'XObjectKey' , default, default, default, default, default, default, default  )
  begin
   Create UNIQUE  Index SDL_XA9WorkDeskHasDriver on WorkDeskHasDriver
    (
XObjectKey
    )
  end
go
if 0 = dbo.QBM_FGIIndexExists('SDL_XI2559WorkDeskHasDriver', 'WorkDeskHasDriver' ,'UID_Driver' , default, default, default, default, default, default, default  )
  begin
   Create  Index SDL_XI2559WorkDeskHasDriver on WorkDeskHasDriver
    (
UID_Driver
    )
  end
go
