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
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2391ADSAccount', 'ADSAccount', 'UID_SDLDomainRD') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2391ADSAccount ON ADSAccount (UID_SDLDomainRD )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI770ADSAccount', 'ADSAccount', 'UID_HardwareDefaultMachine') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI770ADSAccount ON ADSAccount (UID_HardwareDefaultMachine )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9ADSAccountAppsInfo', 'ADSAccountAppsInfo', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9ADSAccountAppsInfo ON ADSAccountAppsInfo (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9AppHasLicence', 'AppHasLicence', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9AppHasLicence ON AppHasLicence (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1106AppHasLicence', 'AppHasLicence', 'UID_Application') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1106AppHasLicence ON AppHasLicence (UID_Application )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI421Application', 'Application', 'UID_SectionName') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI421Application ON Application (UID_SectionName )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI844Application', 'Application', 'UID_ApplicationType') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI844Application ON Application (UID_ApplicationType )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9ApplicationDependsOnDri', 'ApplicationDependsOnDriver', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9ApplicationDependsOnDri ON ApplicationDependsOnDriver (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1279ApplicationDependsOn', 'ApplicationDependsOnDriver', 'UID_DriverParent') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1279ApplicationDependsOn ON ApplicationDependsOnDriver (UID_DriverParent )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9ApplicationExcludeDrive', 'ApplicationExcludeDriver', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9ApplicationExcludeDrive ON ApplicationExcludeDriver (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1378ApplicationExcludeDr', 'ApplicationExcludeDriver', 'UID_Application') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1378ApplicationExcludeDr ON ApplicationExcludeDriver (UID_Application )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA1ApplicationProfile', 'ApplicationProfile', 'UID_Application', 'UID_InstallationType', 'UID_OS', 'UID_SDLDomainRD') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA1ApplicationProfile ON ApplicationProfile (UID_Application, UID_InstallationType, UID_OS, UID_SDLDomainRD )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9ApplicationProfile', 'ApplicationProfile', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9ApplicationProfile ON ApplicationProfile (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI214ApplicationProfile', 'ApplicationProfile', 'UID_InstallationType') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI214ApplicationProfile ON ApplicationProfile (UID_InstallationType )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI21AppProfile', 'ApplicationProfile', 'UID_Application') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI21AppProfile ON ApplicationProfile (UID_Application )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2394ApplicationProfile', 'ApplicationProfile', 'UID_SDLDomainRD') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2394ApplicationProfile ON ApplicationProfile (UID_SDLDomainRD )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2395ApplicationProfile', 'ApplicationProfile', 'UID_SDLDomainRDOwner') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2395ApplicationProfile ON ApplicationProfile (UID_SDLDomainRDOwner )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2553ApplicationProfile', 'ApplicationProfile', 'UID_OS') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2553ApplicationProfile ON ApplicationProfile (UID_OS )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9ApplicationServer', 'ApplicationServer', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9ApplicationServer ON ApplicationServer (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1130ApplicationServer', 'ApplicationServer', 'UID_ApplicationServerRedirect') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1130ApplicationServer ON ApplicationServer (UID_ApplicationServerRedirect )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2443ApplicationServer', 'ApplicationServer', 'UID_SDLDomain') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2443ApplicationServer ON ApplicationServer (UID_SDLDomain )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2482ApplicationServer', 'ApplicationServer', 'UID_Server') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2482ApplicationServer ON ApplicationServer (UID_Server )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI401ApplicationServer', 'ApplicationServer', 'UID_ParentApplicationServer') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI401ApplicationServer ON ApplicationServer (UID_ParentApplicationServer )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9ApplicationType', 'ApplicationType', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9ApplicationType ON ApplicationType (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9AppServerGotAppProfile', 'AppServerGotAppProfile', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9AppServerGotAppProfile ON AppServerGotAppProfile (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI580AppServerGotAppProfil', 'AppServerGotAppProfile', 'UID_Profile') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI580AppServerGotAppProfil ON AppServerGotAppProfile (UID_Profile )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9AppServerGotDriverProfi', 'AppServerGotDriverProfile', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9AppServerGotDriverProfi ON AppServerGotDriverProfile (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI581AppServerGotDriverPro', 'AppServerGotDriverProfile', 'UID_Profile') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI581AppServerGotDriverPro ON AppServerGotDriverProfile (UID_Profile )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9AppServerGotMactypeInfo', 'AppServerGotMactypeInfo', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9AppServerGotMactypeInfo ON AppServerGotMactypeInfo (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI615AppServerGotMactypeIn', 'AppServerGotMactypeInfo', 'UID_ApplicationServer') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI615AppServerGotMactypeIn ON AppServerGotMactypeInfo (UID_ApplicationServer )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9BaseTreeHasDriver', 'BaseTreeHasDriver', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9BaseTreeHasDriver ON BaseTreeHasDriver (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI642BaseTreeHasDriver', 'BaseTreeHasDriver', 'UID_Driver') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI642BaseTreeHasDriver ON BaseTreeHasDriver (UID_Driver )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9BaseTreeHasLicence', 'BaseTreeHasLicence', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9BaseTreeHasLicence ON BaseTreeHasLicence (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1115BaseTreeHasLicence', 'BaseTreeHasLicence', 'UID_Org') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1115BaseTreeHasLicence ON BaseTreeHasLicence (UID_Org )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9BaseTreeHasLicencePurch', 'BaseTreeHasLicencePurchase', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9BaseTreeHasLicencePurch ON BaseTreeHasLicencePurchase (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1113BaseTreeHasLicencePu', 'BaseTreeHasLicencePurchase', 'UID_LicencePurchase') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1113BaseTreeHasLicencePu ON BaseTreeHasLicencePurchase (UID_LicencePurchase )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9BaseTreeRelatedToBasetr', 'BaseTreeRelatedToBasetree', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9BaseTreeRelatedToBasetr ON BaseTreeRelatedToBasetree (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1628BaseTreeRelatedToBas', 'BaseTreeRelatedToBasetree', 'UID_OrgRelated') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1628BaseTreeRelatedToBas ON BaseTreeRelatedToBasetree (UID_OrgRelated )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9ClientLog', 'ClientLog', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9ClientLog ON ClientLog (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1467ClientLog', 'ClientLog', 'UID_LDAPAccount') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1467ClientLog ON ClientLog (UID_LDAPAccount )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI669ClientLog', 'ClientLog', 'UID_Hardware') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI669ClientLog ON ClientLog (UID_Hardware )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI799ClientLog', 'ClientLog', 'UID_ADSAccount') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI799ClientLog ON ClientLog (UID_ADSAccount )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA1Driver', 'Driver', 'Ident_Driver', 'Version', 'UID_OS', 'UID_DialogCulture') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA1Driver ON Driver (Ident_Driver, Version, UID_OS, UID_DialogCulture )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9Driver', 'Driver', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9Driver ON Driver (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1091Driver', 'Driver', 'UID_ApplicationType') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1091Driver ON Driver (UID_ApplicationType )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1314Driver', 'Driver', 'UID_AccProduct') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1314Driver ON Driver (UID_AccProduct )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2386Driver', 'Driver', 'UID_DialogCulture') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2386Driver ON Driver (UID_DialogCulture )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2552Driver', 'Driver', 'UID_OS') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2552Driver ON Driver (UID_OS )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI495Driver', 'Driver', 'UID_SectionName') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI495Driver ON Driver (UID_SectionName )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9DriverCanUsedByRD', 'DriverCanUsedByRD', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9DriverCanUsedByRD ON DriverCanUsedByRD (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2404DriverCanUsedByRD', 'DriverCanUsedByRD', 'UID_SDLDomainAllowed') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2404DriverCanUsedByRD ON DriverCanUsedByRD (UID_SDLDomainAllowed )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9DriverDependsOnDriver', 'DriverDependsOnDriver', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9DriverDependsOnDriver ON DriverDependsOnDriver (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1276DriverDependsOnDrive', 'DriverDependsOnDriver', 'UID_DriverParent') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1276DriverDependsOnDrive ON DriverDependsOnDriver (UID_DriverParent )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9DriverExcludeDriver', 'DriverExcludeDriver', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9DriverExcludeDriver ON DriverExcludeDriver (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1375DriverExcludeDriver', 'DriverExcludeDriver', 'UID_Driver') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1375DriverExcludeDriver ON DriverExcludeDriver (UID_Driver )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9DriverHasLicence', 'DriverHasLicence', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9DriverHasLicence ON DriverHasLicence (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1108DriverHasLicence', 'DriverHasLicence', 'UID_Driver') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1108DriverHasLicence ON DriverHasLicence (UID_Driver )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA1DriverProfile', 'DriverProfile', 'UID_Driver', 'UID_SDLDomainRD') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA1DriverProfile ON DriverProfile (UID_Driver, UID_SDLDomainRD )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9DriverProfile', 'DriverProfile', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9DriverProfile ON DriverProfile (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2405DriverProfile', 'DriverProfile', 'UID_SDLDomainRD') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2405DriverProfile ON DriverProfile (UID_SDLDomainRD )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2406DriverProfile', 'DriverProfile', 'UID_SDLDomainRDOwner') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2406DriverProfile ON DriverProfile (UID_SDLDomainRDOwner )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI31DriverProfile', 'DriverProfile', 'UID_Driver') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI31DriverProfile ON DriverProfile (UID_Driver )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2412Hardware', 'Hardware', 'UID_SDLDomainRD') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2412Hardware ON Hardware (UID_SDLDomainRD )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2561Hardware', 'Hardware', 'UID_OS') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2561Hardware ON Hardware (UID_OS )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI368Hardware', 'Hardware', 'UID_MachineType') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI368Hardware ON Hardware (UID_MachineType )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI523Hardware', 'Hardware', 'UID_InstallationType') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI523Hardware ON Hardware (UID_InstallationType )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9HardwaretypeHasDriver', 'HardwareTypeHasDriver', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9HardwaretypeHasDriver ON HardwareTypeHasDriver (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1616HardwareTypeHasDrive', 'HardwareTypeHasDriver', 'UID_Driver') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1616HardwareTypeHasDrive ON HardwareTypeHasDriver (UID_Driver )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9InstallationType', 'InstallationType', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9InstallationType ON InstallationType (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9Licence', 'Licence', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9Licence ON Licence (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1109Licence', 'Licence', 'UID_LicenceType') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1109Licence ON Licence (UID_LicenceType )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1117Licence', 'Licence', 'UID_ApplicationType') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1117Licence ON Licence (UID_ApplicationType )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1118Licence', 'Licence', 'UID_FirmPartner') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1118Licence ON Licence (UID_FirmPartner )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2385Licence', 'Licence', 'UID_DialogCulture') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2385Licence ON Licence (UID_DialogCulture )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2554Licence', 'Licence', 'UID_OS') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2554Licence ON Licence (UID_OS )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9LicencePurchase', 'LicencePurchase', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9LicencePurchase ON LicencePurchase (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1104LicencePurchase', 'LicencePurchase', 'UID_Licence') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1104LicencePurchase ON LicencePurchase (UID_Licence )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1119LicencePurchase', 'LicencePurchase', 'UID_FirmPartnerVendor') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1119LicencePurchase ON LicencePurchase (UID_FirmPartnerVendor )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1204LicencePurchase', 'LicencePurchase', 'UID_OrgOwner') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1204LicencePurchase ON LicencePurchase (UID_OrgOwner )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1242LicencePurchase', 'LicencePurchase', 'UID_LicenceType') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1242LicencePurchase ON LicencePurchase (UID_LicenceType )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9LicenceSubstitute', 'LicenceSubstitute', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9LicenceSubstitute ON LicenceSubstitute (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1110LicenceSubstitute', 'LicenceSubstitute', 'UID_LicenceSubstitute') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1110LicenceSubstitute ON LicenceSubstitute (UID_LicenceSubstitute )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9LicenceSubstituteTotal', 'LicenceSubstituteTotal', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9LicenceSubstituteTotal ON LicenceSubstituteTotal (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI1128LicenceSubstituteTot', 'LicenceSubstituteTotal', 'UID_LicenceSubstitute') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI1128LicenceSubstituteTot ON LicenceSubstituteTotal (UID_LicenceSubstitute )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2563LicenceSubstituteTot', 'LicenceSubstituteTotal', 'UID_GroupRoot') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2563LicenceSubstituteTot ON LicenceSubstituteTotal (UID_GroupRoot )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9LicenceType', 'LicenceType', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9LicenceType ON LicenceType (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9MachineAppsConfig', 'MachineAppsConfig', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9MachineAppsConfig ON MachineAppsConfig (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9MachineAppsInfo', 'MachineAppsInfo', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9MachineAppsInfo ON MachineAppsInfo (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9MachineHasDriver', 'MachineHasDriver', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9MachineHasDriver ON MachineHasDriver (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI207MachineHasDriver', 'MachineHasDriver', 'UID_Driver') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI207MachineHasDriver ON MachineHasDriver (UID_Driver )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA1MachineType', 'MachineType', 'Ident_MachineType', 'UID_SDLDomain') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA1MachineType ON MachineType (Ident_MachineType, UID_SDLDomain )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9MachineType', 'MachineType', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9MachineType ON MachineType (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2549MachineType', 'MachineType', 'UID_SDLDomain') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2549MachineType ON MachineType (UID_SDLDomain )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9MachineTypeHasDriver', 'MachineTypeHasDriver', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9MachineTypeHasDriver ON MachineTypeHasDriver (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI640MachineTypeHasDriver', 'MachineTypeHasDriver', 'UID_Driver') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI640MachineTypeHasDriver ON MachineTypeHasDriver (UID_Driver )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2550OS', 'OS', 'UID_Licence') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2550OS ON OS (UID_Licence )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9OsInstType', 'OsInstType', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9OsInstType ON OsInstType (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2551OsInstType', 'OsInstType', 'UID_OS') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2551OsInstType ON OsInstType (UID_OS )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI336OsInstType', 'OsInstType', 'UID_InstallationType') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI336OsInstType ON OsInstType (UID_InstallationType )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9ProfileCanUsedAlso', 'ProfileCanUsedAlso', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9ProfileCanUsedAlso ON ProfileCanUsedAlso (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2555ProfileCanUsedAlso', 'ProfileCanUsedAlso', 'UID_OS') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2555ProfileCanUsedAlso ON ProfileCanUsedAlso (UID_OS )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2564ProfileCanUsedAlso', 'ProfileCanUsedAlso', 'UID_InstallationType') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2564ProfileCanUsedAlso ON ProfileCanUsedAlso (UID_InstallationType )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI289ProfileCanUsedAlso', 'ProfileCanUsedAlso', 'UID_Profile') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI289ProfileCanUsedAlso ON ProfileCanUsedAlso (UID_Profile )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9ProfileCanUsedByRD', 'ProfileCanUsedByRD', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9ProfileCanUsedByRD ON ProfileCanUsedByRD (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2418ProfileCanUsedByRD', 'ProfileCanUsedByRD', 'UID_SDLDomainAllowed') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2418ProfileCanUsedByRD ON ProfileCanUsedByRD (UID_SDLDomainAllowed )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9SDLDomain', 'SDLDomain', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9SDLDomain ON SDLDomain (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2484SDLDomain', 'SDLDomain', 'UID_ServerTAS') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2484SDLDomain ON SDLDomain (UID_ServerTAS )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2556SDLDomain', 'SDLDomain', 'UID_ADSDomain') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2556SDLDomain ON SDLDomain (UID_ADSDomain )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2560SDLDomain', 'SDLDomain', 'UID_AERoleOwner') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2560SDLDomain ON SDLDomain (UID_AERoleOwner )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2562SDLDomain', 'SDLDomain', 'UID_SDLDomainParent') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2562SDLDomain ON SDLDomain (UID_SDLDomainParent )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9SectionName', 'SectionName', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9SectionName ON SectionName (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9SoftwareDependsOnSoftwa', 'SoftwareDependsOnSoftware', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9SoftwareDependsOnSoftwa ON SoftwareDependsOnSoftware (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XA9WorkDeskHasDriver', 'WorkDeskHasDriver', 'XObjectKey') = 0 then
        execute immediate 'CREATE UNIQUE  INDEX SDL_XA9WorkDeskHasDriver ON WorkDeskHasDriver (XObjectKey )';
  end if;
end;
go
begin
  if QBM_GGetInfo.FGIIndexExists('SDL_XI2559WorkDeskHasDriver', 'WorkDeskHasDriver', 'UID_Driver') = 0 then
        execute immediate 'CREATE  INDEX SDL_XI2559WorkDeskHasDriver ON WorkDeskHasDriver (UID_Driver )';
  end if;
end;
go
