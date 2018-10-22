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
exec MDK_PRelationshipDefine 
	'R/1091',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'ApplicationType',		-- ParentTable
	'Driver',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_ApplicationType'		-- ParentColumn
	, 'UID_ApplicationType'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1104',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Licence',		-- ParentTable
	'LicencePurchase',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'D',		-- ChildExecuteBy
	1		-- ChildAllowUpdate
	, 'UID_Licence'		-- ParentColumn
	, 'UID_Licence'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1105',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Licence',		-- ParentTable
	'AppHasLicence',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'D',		-- ChildExecuteBy
	1		-- ChildAllowUpdate
	, 'UID_Licence'		-- ParentColumn
	, 'UID_Licence'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1106',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Application',		-- ParentTable
	'AppHasLicence',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'D',		-- ChildExecuteBy
	1		-- ChildAllowUpdate
	, 'UID_Application'		-- ParentColumn
	, 'UID_Application'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1107',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Licence',		-- ParentTable
	'DriverHasLicence',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'D',		-- ChildExecuteBy
	1		-- ChildAllowUpdate
	, 'UID_Licence'		-- ParentColumn
	, 'UID_Licence'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1108',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Driver',		-- ParentTable
	'DriverHasLicence',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'D',		-- ChildExecuteBy
	1		-- ChildAllowUpdate
	, 'UID_Driver'		-- ParentColumn
	, 'UID_Driver'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1109',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'LicenceType',		-- ParentTable
	'Licence',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_LicenceType'		-- ParentColumn
	, 'UID_LicenceType'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1110',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Licence',		-- ParentTable
	'LicenceSubstitute',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Licence'		-- ParentColumn
	, 'UID_LicenceSubstitute'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1111',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Licence',		-- ParentTable
	'LicenceSubstitute',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Licence'		-- ParentColumn
	, 'UID_Licence'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1112',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'BaseTree',		-- ParentTable
	'BaseTreeHasLicencePurchase',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Org'		-- ParentColumn
	, 'UID_Org'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1113',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'LicencePurchase',		-- ParentTable
	'BaseTreeHasLicencePurchase',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_LicencePurchase'		-- ParentColumn
	, 'UID_LicencePurchase'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1114',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Licence',		-- ParentTable
	'BaseTreeHasLicence',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Licence'		-- ParentColumn
	, 'UID_Licence'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1115',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'BaseTree',		-- ParentTable
	'BaseTreeHasLicence',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Org'		-- ParentColumn
	, 'UID_Org'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1116',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'QBMCulture',		-- ParentTable
	'Licence',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_DialogCulture'		-- ParentColumn
	, 'UID_DialogCulture'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1117',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'ApplicationType',		-- ParentTable
	'Licence',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_ApplicationType'		-- ParentColumn
	, 'UID_ApplicationType'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1118',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'FirmPartner',		-- ParentTable
	'Licence',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_FirmPartner'		-- ParentColumn
	, 'UID_FirmPartner'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1119',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'FirmPartner',		-- ParentTable
	'LicencePurchase',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_FirmPartner'		-- ParentColumn
	, 'UID_FirmPartnerVendor'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1124',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Org',		-- ParentTable
	'LicencePurchase',		-- ChildTable
	'1',		-- ParentCardinality
	'DS',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Org'		-- ParentColumn
	, 'UID_OrgOwner'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1125',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'OS',		-- ParentTable
	'Licence',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_OS'		-- ParentColumn
	, 'UID_OS'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1126',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Licence',		-- ParentTable
	'OS',		-- ChildTable
	'1',		-- ParentCardinality
	'DS',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Licence'		-- ParentColumn
	, 'UID_Licence'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1128',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Licence',		-- ParentTable
	'LicenceSubstituteTotal',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Licence'		-- ParentColumn
	, 'UID_LicenceSubstitute'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1129',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Licence',		-- ParentTable
	'LicenceSubstituteTotal',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Licence'		-- ParentColumn
	, 'UID_Licence'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1130',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'ApplicationServer',		-- ParentTable
	'ApplicationServer',		-- ChildTable
	'1',		-- ParentCardinality
	'DS',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_ApplicationServer'		-- ParentColumn
	, 'UID_ApplicationServerRedirect'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1242',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'LicenceType',		-- ParentTable
	'LicencePurchase',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_LicenceType'		-- ParentColumn
	, 'UID_LicenceType'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1276',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Driver',		-- ParentTable
	'DriverDependsOnDriver',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Driver'		-- ParentColumn
	, 'UID_DriverParent'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1277',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Driver',		-- ParentTable
	'DriverDependsOnDriver',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Driver'		-- ParentColumn
	, 'UID_DriverChild'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1278',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Application',		-- ParentTable
	'ApplicationDependsOnDriver',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Application'		-- ParentColumn
	, 'UID_ApplicationChild'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1279',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Driver',		-- ParentTable
	'ApplicationDependsOnDriver',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Driver'		-- ParentColumn
	, 'UID_DriverParent'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1314',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'AccProduct',		-- ParentTable
	'Driver',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_AccProduct'		-- ParentColumn
	, 'UID_AccProduct'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1375',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Driver',		-- ParentTable
	'DriverExcludeDriver',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Driver'		-- ParentColumn
	, 'UID_Driver'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1376',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Driver',		-- ParentTable
	'DriverExcludeDriver',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Driver'		-- ParentColumn
	, 'UID_DriverExcluded'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1377',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Driver',		-- ParentTable
	'ApplicationExcludeDriver',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Driver'		-- ParentColumn
	, 'UID_Driver'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1378',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Application',		-- ParentTable
	'ApplicationExcludeDriver',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Application'		-- ParentColumn
	, 'UID_Application'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1467',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'LDAPAccount',		-- ParentTable
	'ClientLog',		-- ChildTable
	'1',		-- ParentCardinality
	'DS',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_LDAPAccount'		-- ParentColumn
	, 'UID_LDAPAccount'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1616',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Driver',		-- ParentTable
	'HardwareTypeHasDriver',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Driver'		-- ParentColumn
	, 'UID_Driver'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1617',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'HardwareType',		-- ParentTable
	'HardwareTypeHasDriver',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_HardwareType'		-- ParentColumn
	, 'UID_HardwareType'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1628',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'BaseTree',		-- ParentTable
	'BaseTreeRelatedToBasetree',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Org'		-- ParentColumn
	, 'UID_OrgRelated'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/1629',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'BaseTree',		-- ParentTable
	'BaseTreeRelatedToBasetree',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Org'		-- ParentColumn
	, 'UID_Org'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/2549',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'SDLDomain',		-- ParentTable
	'MachineType',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_SDLDomain'		-- ParentColumn
	, 'UID_SDLDomain'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/2555',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'OS',		-- ParentTable
	'ProfileCanUsedAlso',		-- ChildTable
	'1',		-- ParentCardinality
	'DS',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_OS'		-- ParentColumn
	, 'UID_OS'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/2556',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'ADSDomain',		-- ParentTable
	'SDLDomain',		-- ChildTable
	'1',		-- ParentCardinality
	'DS',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_ADSDomain'		-- ParentColumn
	, 'UID_ADSDomain'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/2560',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'AERole',		-- ParentTable
	'SDLDomain',		-- ChildTable
	'1',		-- ParentCardinality
	'DS',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_AERole'		-- ParentColumn
	, 'UID_AERoleOwner'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/2562',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'SDLDomain',		-- ParentTable
	'SDLDomain',		-- ChildTable
	'1',		-- ParentCardinality
	'DS',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_SDLDomain'		-- ParentColumn
	, 'UID_SDLDomainParent'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/2563',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Licence',		-- ParentTable
	'LicenceSubstituteTotal',		-- ChildTable
	'1',		-- ParentCardinality
	'D',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'I',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Licence'		-- ParentColumn
	, 'UID_GroupRoot'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/2564',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'InstallationType',		-- ParentTable
	'ProfileCanUsedAlso',		-- ChildTable
	'1',		-- ParentCardinality
	'DS',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_InstallationType'		-- ParentColumn
	, 'UID_InstallationType'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/3207',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Driver',		-- ParentTable
	'MachineHasDriver',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'D',		-- ChildExecuteBy
	1		-- ChildAllowUpdate
	, 'UID_Driver'		-- ParentColumn
	, 'UID_Driver'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/3214',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'InstallationType',		-- ParentTable
	'ApplicationProfile',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_InstallationType'		-- ParentColumn
	, 'UID_InstallationType'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/3230',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'QBMCulture',		-- ParentTable
	'Driver',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_DialogCulture'		-- ParentColumn
	, 'UID_DialogCulture'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/3254',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'SDLDomain',		-- ParentTable
	'ApplicationProfile',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_SDLDomain'		-- ParentColumn
	, 'UID_SDLDomainRD'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/3255',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'SDLDomain',		-- ParentTable
	'ApplicationProfile',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_SDLDomain'		-- ParentColumn
	, 'UID_SDLDomainRDOwner'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/3256',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'SDLDomain',		-- ParentTable
	'ProfileCanUsedByRD',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_SDLDomain'		-- ParentColumn
	, 'UID_SDLDomainAllowed'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/3257',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'ApplicationProfile',		-- ParentTable
	'ProfileCanUsedByRD',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'D',		-- ChildExecuteBy
	1		-- ChildAllowUpdate
	, 'UID_Profile'		-- ParentColumn
	, 'UID_Profile'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/3260',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'SDLDomain',		-- ParentTable
	'DriverProfile',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_SDLDomain'		-- ParentColumn
	, 'UID_SDLDomainRD'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/3261',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'SDLDomain',		-- ParentTable
	'DriverProfile',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_SDLDomain'		-- ParentColumn
	, 'UID_SDLDomainRDOwner'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/3262',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'DriverProfile',		-- ParentTable
	'DriverCanUsedByRD',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'D',		-- ChildExecuteBy
	1		-- ChildAllowUpdate
	, 'UID_Profile'		-- ParentColumn
	, 'UID_Profile'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/3263',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'SDLDomain',		-- ParentTable
	'DriverCanUsedByRD',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_SDLDomain'		-- ParentColumn
	, 'UID_SDLDomainAllowed'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/3267S',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'SDLDomain',		-- ParentTable
	'ApplicationServer',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_SDLDomain'		-- ParentColumn
	, 'UID_SDLDomain'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/3268',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'QBMServer',		-- ParentTable
	'ApplicationServer',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'D',		-- ChildExecuteBy
	1		-- ChildAllowUpdate
	, 'UID_QBMServer'		-- ParentColumn
	, 'UID_Server'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/3289',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'ApplicationProfile',		-- ParentTable
	'ProfileCanUsedAlso',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'D',		-- ChildExecuteBy
	1		-- ChildAllowUpdate
	, 'UID_Profile'		-- ParentColumn
	, 'UID_Profile'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/3335',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'OS',		-- ParentTable
	'OsInstType',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_OS'		-- ParentColumn
	, 'UID_OS'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/3336',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'InstallationType',		-- ParentTable
	'OsInstType',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_InstallationType'		-- ParentColumn
	, 'UID_InstallationType'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/3338',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'OsInstType',		-- ParentTable
	'ProfileCanUsedAlso',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_OsInstType'		-- ParentColumn
	, 'UID_OsInstType'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/3368',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'MachineType',		-- ParentTable
	'Hardware',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'D',		-- ChildExecuteBy
	1		-- ChildAllowUpdate
	, 'UID_MachineType'		-- ParentColumn
	, 'UID_MachineType'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/3394',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Hardware',		-- ParentTable
	'MachineHasDriver',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'D',		-- ChildExecuteBy
	1		-- ChildAllowUpdate
	, 'UID_Hardware'		-- ParentColumn
	, 'UID_Hardware'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/418',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'QBMServer',		-- ParentTable
	'SDLDomain',		-- ChildTable
	'1',		-- ParentCardinality
	'DS',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_QBMServer'		-- ParentColumn
	, 'UID_ServerTAS'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/421',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'SectionName',		-- ParentTable
	'Application',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_SectionName'		-- ParentColumn
	, 'UID_SectionName'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/443',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'SDLDomain',		-- ParentTable
	'Hardware',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_SDLDomain'		-- ParentColumn
	, 'UID_SDLDomainRD'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/495',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'SectionName',		-- ParentTable
	'Driver',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_SectionName'		-- ParentColumn
	, 'UID_SectionName'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/522',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'OS',		-- ParentTable
	'Hardware',		-- ChildTable
	'1',		-- ParentCardinality
	'DS',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_OS'		-- ParentColumn
	, 'UID_OS'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/523',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'InstallationType',		-- ParentTable
	'Hardware',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_InstallationType'		-- ParentColumn
	, 'UID_InstallationType'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/578',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'ApplicationServer',		-- ParentTable
	'AppServerGotAppProfile',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_ApplicationServer'		-- ParentColumn
	, 'UID_ApplicationServer'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/579',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'ApplicationServer',		-- ParentTable
	'AppServerGotDriverProfile',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_ApplicationServer'		-- ParentColumn
	, 'UID_ApplicationServer'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/580',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'ApplicationProfile',		-- ParentTable
	'AppServerGotAppProfile',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'D',		-- ChildExecuteBy
	1		-- ChildAllowUpdate
	, 'UID_Profile'		-- ParentColumn
	, 'UID_Profile'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/581',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'DriverProfile',		-- ParentTable
	'AppServerGotDriverProfile',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'D',		-- ChildExecuteBy
	1		-- ChildAllowUpdate
	, 'UID_Profile'		-- ParentColumn
	, 'UID_Profile'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/614',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'MachineType',		-- ParentTable
	'AppServerGotMactypeInfo',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_MachineType'		-- ParentColumn
	, 'UID_MachineType'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/615',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'ApplicationServer',		-- ParentTable
	'AppServerGotMactypeInfo',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_ApplicationServer'		-- ParentColumn
	, 'UID_ApplicationServer'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/640',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Driver',		-- ParentTable
	'MachineTypeHasDriver',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Driver'		-- ParentColumn
	, 'UID_Driver'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/641',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'MachineType',		-- ParentTable
	'MachineTypeHasDriver',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_MachineType'		-- ParentColumn
	, 'UID_MachineType'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/642',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Driver',		-- ParentTable
	'BaseTreeHasDriver',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Driver'		-- ParentColumn
	, 'UID_Driver'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/643',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'BaseTree',		-- ParentTable
	'BaseTreeHasDriver',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	1		-- ChildAllowUpdate
	, 'UID_Org'		-- ParentColumn
	, 'UID_Org'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/644',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Driver',		-- ParentTable
	'WorkDeskHasDriver',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Driver'		-- ParentColumn
	, 'UID_Driver'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/645',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'WorkDesk',		-- ParentTable
	'WorkDeskHasDriver',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_WorkDesk'		-- ParentColumn
	, 'UID_WorkDesk'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/666',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Hardware',		-- ParentTable
	'MachineAppsInfo',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Hardware'		-- ParentColumn
	, 'UID_Hardware'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/667',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Application',		-- ParentTable
	'MachineAppsInfo',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Application'		-- ParentColumn
	, 'UID_Application'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/668',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Driver',		-- ParentTable
	'MachineAppsInfo',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Driver'		-- ParentColumn
	, 'UID_Driver'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/669',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Hardware',		-- ParentTable
	'ClientLog',		-- ChildTable
	'1',		-- ParentCardinality
	'DS',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Hardware'		-- ParentColumn
	, 'UID_Hardware'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/680',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'OS',		-- ParentTable
	'MachineAppsInfo',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_OS'		-- ParentColumn
	, 'UID_OS'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/681',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'InstallationType',		-- ParentTable
	'MachineAppsInfo',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_InstallationType'		-- ParentColumn
	, 'UID_InstallationType'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/682',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'InstallationType',		-- ParentTable
	'ADSAccountAppsInfo',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_InstallationType'		-- ParentColumn
	, 'UID_InstallationType'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/683',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'OS',		-- ParentTable
	'ADSAccountAppsInfo',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_OS'		-- ParentColumn
	, 'UID_OS'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/769',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'SDLDomain',		-- ParentTable
	'ADSAccount',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_SDLDomain'		-- ParentColumn
	, 'UID_SDLDomainRD'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/770',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Hardware',		-- ParentTable
	'ADSAccount',		-- ChildTable
	'1',		-- ParentCardinality
	'DS',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'D',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Hardware'		-- ParentColumn
	, 'UID_HardwareDefaultMachine'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/796',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Application',		-- ParentTable
	'ADSAccountAppsInfo',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Application'		-- ParentColumn
	, 'UID_Application'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/797',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'ADSAccount',		-- ParentTable
	'ADSAccountAppsInfo',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_ADSAccount'		-- ParentColumn
	, 'UID_ADSAccount'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/799',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'ADSAccount',		-- ParentTable
	'ClientLog',		-- ChildTable
	'1',		-- ParentCardinality
	'DS',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_ADSAccount'		-- ParentColumn
	, 'UID_ADSAccount'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/829',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Application',		-- ParentTable
	'MachineAppsConfig',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Application'		-- ParentColumn
	, 'UID_Application'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/830',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Driver',		-- ParentTable
	'MachineAppsConfig',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Driver'		-- ParentColumn
	, 'UID_Driver'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/831',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Hardware',		-- ParentTable
	'MachineAppsConfig',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Hardware'		-- ParentColumn
	, 'UID_Hardware'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/844',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'ApplicationType',		-- ParentTable
	'Application',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_ApplicationType'		-- ParentColumn
	, 'UID_ApplicationType'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/901',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Application',		-- ParentTable
	'ApplicationProfile',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_Application'		-- ParentColumn
	, 'UID_Application'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/904',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'Driver',		-- ParentTable
	'DriverProfile',		-- ChildTable
	'1',		-- ParentCardinality
	'DC',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'D',		-- ChildExecuteBy
	1		-- ChildAllowUpdate
	, 'UID_Driver'		-- ParentColumn
	, 'UID_Driver'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/908',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'OS',		-- ParentTable
	'ApplicationProfile',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_OS'		-- ParentColumn
	, 'UID_OS'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/909',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'OS',		-- ParentTable
	'Driver',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'T',		-- ParentExecuteBy
	0,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'T',		-- ChildExecuteBy
	0		-- ChildAllowUpdate
	, 'UID_OS'		-- ParentColumn
	, 'UID_OS'		-- ChildColumn
go

exec MDK_PRelationshipDefine 
	'R/912',		-- RelationID
	'SDL',		-- ModuleName
	'',		-- BaseRelationID
	'ApplicationServer',		-- ParentTable
	'ApplicationServer',		-- ChildTable
	'1',		-- ParentCardinality
	'DR',		-- ParentRestriction
	'D',		-- ParentExecuteBy
	1,		-- ParentAllowUpdate
	'*',		-- ChildCardinality
	'IR',		-- ChildRestriction
	'D',		-- ChildExecuteBy
	1		-- ChildAllowUpdate
	, 'UID_ApplicationServer'		-- ParentColumn
	, 'UID_ParentApplicationServer'		-- ChildColumn
go

