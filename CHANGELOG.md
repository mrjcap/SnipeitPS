# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/),
and this project adheres to [Semantic Versioning](http://semver.org/).

# [v.1.12.0] - 2026-02-10

## Close Snipe-IT v8 API coverage gaps

### New Functions
- Get-SnipeitAssetLicense: Gets licenses assigned to a specific asset (`/api/v1/hardware/{id}/licenses`)
- Get-SnipeitComponentAsset: Gets assets checked out to a specific component (`/api/v1/components/{id}/assets`)
- Get-SnipeitUserAsset: Gets assets assigned to a specific user (`/api/v1/users/{id}/assets`)
- Get-SnipeitUserAccessory: Gets accessories assigned to a specific user (`/api/v1/users/{id}/accessories`)
- Get-SnipeitUserLicense: Gets licenses assigned to a specific user (`/api/v1/users/{id}/licenses`)
- Get-SnipeitAuditDue: Gets assets due for audit (`/api/v1/hardware/audit/due`)
- Get-SnipeitAuditOverdue: Gets assets overdue for audit (`/api/v1/hardware/audit/overdue`)
- Get-SnipeitBackup: Gets list of available Snipe-IT backups (`/api/v1/settings/backups`)
- Save-SnipeitBackup: Downloads a Snipe-IT backup file (`/api/v1/settings/backups/download/{filename}`)
- Get-SnipeitConsumableUser: Gets users who have a specific consumable checked out (`/api/v1/consumables/{id}/users`)

### Bug Fixes
- Fixed Get-SnipeitSetting: API path was incorrectly pointing to `/api/v1/settings/backups`
  instead of `/api/v1/settings`
- Fixed Set-SnipeitLicenseSeat: `end` block was nested inside `process` block, preventing
  `Reset-SnipeitPSLegacyApi` from ever being called when using legacy parameters
- Fixed Connect-SnipeitPS: `throttlePeriod` default of 60000ms was never applied due to
  `$null` check on `[int]` parameter (which defaults to 0, not `$null`)
- Fixed Connect-SnipeitPS: Simplified PS5/PS7 `ConvertTo-SecureString` to single cross-version call
- Fixed Save-SnipeitBackup: Simplified PS5/PS7 `ConvertFrom-SecureString` to single cross-version call

### Code Cleanup
- Removed dead `if ($search -and $id) { Throw }` checks from 9 Get-* functions (parameter
  sets already enforce mutual exclusion at binding time)
- Fixed ~95 spelling and typo issues across 80+ source and documentation files

### Tests
- Added 615 Pester v5 tests achieving 100% line coverage (2493/2493 lines)
- Added documentation for Connect-SnipeitPS throttle parameters

# [v.1.11.1] - 2026-02-09

## Bug fixes from original repo issue audit

### Critical Fixes
- Fixed New-SnipeitSupplier: API endpoint typo (`/suppilers` -> `/suppliers`) caused
  every call to return 404. Function has never worked. (Original repo issue)
- Fixed Set-SnipeitSupplier: Missing `$id` parameter in Param block made the function
  unable to update any supplier. Added mandatory `[int[]]$id` parameter.
- Fixed Set-SnipeitManufacturer: Missing `$id` parameter in Param block made the function
  unable to update any manufacturer. Added mandatory `[int[]]$id` parameter.

### Moderate Fixes
- Fixed New-SnipeitLicense: `[mailaddress]` type on `license_email` was incompatible
  with `[ValidateLength]` and serialized as object instead of string. Changed to `[string]`.
  (Addresses #299)
- Fixed Set-SnipeitLicense: Same `[mailaddress]` to `[string]` fix for `license_email`.
- Fixed New-SnipeitManufacturer: Body was manually built as `@{ "name" = $Name }`,
  silently ignoring `image` and `image_delete` parameters. Now uses `Get-ParameterValue`.

### Enhancements
- Added `status_id` parameter to Set-SnipeitAssetOwner to allow setting asset status
  during checkout. (Addresses #294)
- Added `supplier_url` parameter to New-SnipeitSupplier and Set-SnipeitSupplier to set
  the supplier website URL (renamed to `url` in API body to avoid conflict with deprecated
  `-url` parameter). (Addresses #195)
- Added `manufacturer_url` parameter to New-SnipeitManufacturer and Set-SnipeitManufacturer
  for the same reason.

### Help Text Fixes
- Fixed New-SnipeitSupplier example (was showing New-SnipeitDepartment)
- Fixed Set-SnipeitSupplier example (was showing New-SnipeitDepartment)
- Fixed Set-SnipeitManufacturer synopsis (was saying "Add a new" instead of "Updates")
- Fixed supplier `.PARAMETER notes` description (was saying "Email address")

### Tests
- Added Pester tests for New-SnipeitSupplier, Set-SnipeitSupplier, Set-SnipeitManufacturer,
  New-SnipeitManufacturer, New-SnipeitLicense, Set-SnipeitLicense, and Set-SnipeitAssetOwner

# [v.1.11.0] - 2026-02-09

## Extended API coverage

### New features
Added 30 new functions covering missing Snipe-IT API endpoints including
groups, fieldsets, status labels, asset/model files, component and consumable
checkout/checkin, custom field association, user/asset restore, audit,
and system information endpoints.

Added file upload support to Invoke-SnipeitMethod for multipart/form-data
file uploads (New-SnipeitAssetFile, New-SnipeitModelFile). Requires
PowerShell 7.0 or later.

Added 180 Pester tests covering all new functions including endpoint
validation, parameter passing, legacy API parameter handling, and
pagination loop behavior.

Added documentation for all 30 new functions in docs/.

### New Functions
- Get-SnipeitAssetFile
- Get-SnipeitCurrentUser
- Get-SnipeitFieldsetField
- Get-SnipeitGroup
- Get-SnipeitModelFile
- Get-SnipeitSetting
- Get-SnipeitStatusAsset
- Get-SnipeitUserEula
- Get-SnipeitVersion
- New-SnipeitAssetFile
- New-SnipeitFieldset
- New-SnipeitGroup
- New-SnipeitModelFile
- New-SnipeitStatus
- Register-SnipeitCustomField
- Remove-SnipeitAssetFile
- Remove-SnipeitFieldset
- Remove-SnipeitGroup
- Remove-SnipeitModelFile
- Remove-SnipeitStatus
- Reset-SnipeitComponentOwner
- Restore-SnipeitAsset
- Restore-SnipeitUser
- Set-SnipeitAssetMaintenance
- Set-SnipeitComponentOwner
- Set-SnipeitConsumableOwner
- Set-SnipeitFieldset
- Set-SnipeitGroup
- Unregister-SnipeitCustomField
- Update-SnipeitAssetAudit

### Fixes
- Fixed file uploads in Invoke-SnipeitMethod using file[] form field name
  for Laravel/Snipe-IT compatibility
- Clarified Reset-SnipeitComponentOwner id parameter is the component_assets
  pivot record ID, not the component ID (matches accessory checkin pattern)
- Fixed ConvertTo-Json debug output in Invoke-SnipeitMethod causing spurious
  "Resulting JSON is truncated" warnings when not in debug mode
- Fixed Restore-SnipeitAsset and Restore-SnipeitUser failing due to missing
  body on POST requests
- Fixed Get-SnipeitStatusAsset -all pagination by preserving id in search
  parameters for recursive calls
- Removed unreachable dead code in Get-SnipeitGroup (parameter set validation
  made the manual throw check redundant)

# [v.1.10.x] - 2021-09-03

## New secure ways to connect Snipe it

### -secureApiKey allow pass apiKey as SecureString
Connect-SnipeitPS -URL 'https://asset.example.com' -secureApiKey 'tokenKey'

### Set connection with safely saved credentials, first save credentials
$SnipeCred= Get-Credential -message "Use url as username and apikey as password"
$SnipeCred | Export-CliXml snipecred.xml

### ..then use your saved credentials like
Connect-SnipeitPS -siteCred (Import-CliXml snipecred.xml)

## Fix for content encoding in invoke-snipeitmethod
Version 1.9 introduced bug that converted non ascii characters to ascii
during request.

# [v.1.9.x] - 2021-07-14

## Image uploads

## New features
Support for image upload and removes. Just specify filename for -image para-
meter when creating or updating item on snipe.
Remove image use -image_delete parameter.

*Snipe It version greater than 5.1.8 is needed to support image parameters.*

Most of set-commands have new -RequestType parameter that defaults to Patch.
If needed request method can be changed from default.

## New Functions
Following new commands have been added to SnipeitPS:
- New-Supplier
- Set-Supplier
- Remove-Supplier
- Set-Manufacturer


# [v.1.8.x] - 2021-06-17

## Support for new Snipe it endpoints

## New features

Get-SnipeitAccessories -user_id
returns accessories checked out to user id

Get-SnipeitAsset -user_id
Return Assets checked out to user id

Get-SnipeitAsset -component_id
Returns assets with specific component id

Get-SnipeitLicense -user_id
Get licenses checked out to user ID

Get-SnipeitLicense -asset_id
Get licenses checked out to asset ID

Get-SnipeitUser -accessory_id
Get users that have specific accessory id checked out

# [v.1.7.x] - 2021-06-14

## Consumables

## New features
Added support for consumables

## New functions
- New-SnipeitConsumable
- Get-SnipeitConsumable
- Set-SnipeitConsumable
- Remove-SnipeitConsumable


# [v.1.6.x] - 2021-06-14

## Remove more things and set some more

### New features
Added some set and remove functions. Pipelineinput supported
for all remove functions.

### New functions
 - Remove-SnipeitAccessory
 - Remove-SnipeitCategory
 - Remove-SnipeitCompany
 - Remove-SnipeitComponent
 - Remove-SnipeitCustomField
 - Remove-SnipeitDepartment
 - Remove-SnipeitLicense
 - Remove-SnipeitLocation
 - Remove-SnipeitManufacturer
 - Remove-SnipeitModel
 - Set-SnipeitCategory
 - Set-SnipeitCompany
 - Set-SnipeitCustomField
 - Set-SnipeitDepartment
 - Set-SnipeitStatus


# [v1.5.x] - 2021-06-08

## Piping input

### New features
Most of "Set" command accepts piped input. Piped objects "id" attribute
is used to select asset set values. Like
Get-SnipeitAsset -model_id 213 | Set-SnipeitAsset -notes 'This is nice!'

Set command accept id parameter as array, so its easier to set multiple items
in one run.

Parameter sets. Get commands have now parameters sets.This will make syntax more
clear between search and get by ID use. Use get-help to

### Fixes
-Empty strings are accepted as input so it's possible to wipe field values if
needed

# [v1.4.x] - 2021-05-27

## More Activity

### New features
Snipeit activity history is now searchable. So finding out checked out the
asset is easy. Api support many different target or item types that can
be uses as filter. Searchable types are 'Accessory','Asset','AssetMaintenance'
,'AssetModel','Category','Company','Component','Consumable','CustomField',
,'Group','Licence','LicenseSeat','Location','Manufacturer','Statuslabel',
'Supplier','User'


### New Functions
- Get-SnipeitActivity Get and search Snipe-It change history.


# [v1.3.x] - 2021-05-27

## Checking out accessories

### New features
You can specify Put or Patch for  Set-SnipeitAsset when updating assets.
Set-SnipeitLocation new -city parameter

### New Functions
- Set-SnipeitAccessoryOwner checkout accessory
- Get-SnipeitAccessoryOwner list checkedout accessories
- Reset-SnipeitAccessoryOwner checkin accessory

### Fixes
- Set-SnipeitAsset fixed datetime and name inputs #126,128
-

# [v1.2.x] - 2021-05-24

## Prefixing SnipeitPS

### New Features
All commands are now prefixed like Set-Info -> Set-SnipeitInfo.
To keep compatibility all old commands are available as aliases.
To update existing scripts theres Update-SnipeitAlias command.

### New functions
- Update-SnipeitAlias Tool to update existing scripts
- Get-SnipeitLicenceSeat lists license seats
- Set-SnipeitLicenseSeat Set and checkouts/in license seats
Licenseseat api is supported from Snipe-It release => v5.1.5

### New fixes
Added -id parameter support to support Get-SnipeitCustomField and
Get-SnipeitFieldSet commands

# [v1.1.x] - 2021-05-18

## Pull request rollup release. Lots of new features including:

### New features
- Powershell 7 compatibility. So you can use SnipeitPS on macos or linux .
- Get every asset, model, licence with snipeit id by using -id parameter
- Get assets also by -asset_tag -or serialnumber
- Get functions also return all results from snipe when using -all parameter (by @PetriAsi)

### New functions
- Reset-AssetOwner by @lunchboxrts
- Remove-Asset by @sheppyh
- Added Remove-AssetMaintenance by @sheppyh
- Remove-User @gvoynov

### Fixes
- Fixed version number on powershell gallery
- Fixed Set-AssetOwner when checking asset out to an other asset.

## [v1.0] - 2017-11-18
