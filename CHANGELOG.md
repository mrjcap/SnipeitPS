# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/), and this project
adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### Added
- Native bulk asset edit support in `Set-SnipeitAsset` via `PATCH /api/v1/hardware/bulk` when passing multiple IDs (grokability/snipe-it#19271).
- Native bulk asset audit support in `Update-SnipeitAssetAudit` and `New-SnipeitAudit` via `POST /api/v1/hardware/audit/bulk` when passing multiple IDs (grokability/snipe-it#19271).
- Added `-note` (alias: `notes`) and `-image` upload parameters to `Update-SnipeitAssetAudit` and `New-SnipeitAudit`.
- Added comprehensive unit tests in `Tests/Coverage-BulkOperations.Tests.ps1`.
- Added parameter set enforcement (`ById`, `ByTag`, `BySerial`) to `Update-SnipeitAssetAudit` and `New-SnipeitAudit` for mutual exclusion of identifier parameters.
- Added guard against combining `-image` with bulk IDs on audit functions (multipart/form-data corrupts array serialization).

### Fixed
- Fixed pipeline evaluation bug in `Update-SnipeitAssetAudit` where parameters were evaluated in `begin {}` block instead of per-item in `process {}`.
- Normalized HTTP method casing to `'POST'` in `New-SnipeitAudit` (was inconsistently `'Post'`).

### Breaking Changes
- `Update-SnipeitAssetAudit` now uses parameter sets (`ById`, `ByTag`, `BySerial`). Passing `-id` with `-asset_tag` or `-serial` simultaneously is no longer allowed — PowerShell will reject the call at parameter binding.
- `New-SnipeitAudit` now uses parameter sets (`ByTag`, `ById`). Passing `-tag` with `-id` simultaneously is no longer allowed.

## [v.1.15.0] - 2026-08-12

### Snipe-IT 8.7 Support and Compatibility

- Added `-Paginate` switch parameter to `Invoke-SnipeitMethod`.
- Updated maintenance completion date parameter to `-expected_completion_date` (with `-completion_date` alias) for
  Snipe-IT 8.7 maintenance API endpoints (`New-SnipeitAssetMaintenance` and `Set-SnipeitAssetMaintenance`)
  (grokability/snipe-it#19339).
- Added explicit `SnipeitPS/1.15.0` `User-Agent` request header to `Invoke-SnipeitMethod` to satisfy Snipe-IT 8.7 API
  non-generic User-Agent requirement settings (grokability/snipe-it#19218).
- Added `-serial` and `-asset_tag` parameters to `Update-SnipeitAssetAudit` to support quickscan asset auditing by
  serial number (grokability/snipe-it#19332).
- Added `-requestable` parameter to `New-SnipeitAccessory` and `Set-SnipeitAccessory` for requestable accessories
  (grokability/snipe-it#19169).
- Added `-parent_id` parameter to `New-SnipeitCompany` and `Set-SnipeitCompany` for parent company hierarchies
  (grokability/snipe-it#19230).
- Added Pester unit tests covering all Snipe-IT 8.7 feature updates and header verifications.
- Formatted all module documentation files for markdownlint compliance.

## [v.1.14.0] - 2026-05-30

### Snipe-IT 8.6 Support, Security hardening, and fixes

### Features (Snipe-IT 8.6 Support)

- Added `$companies` parameter (`[int[]]`) to `New-SnipeitUser` and `Set-SnipeitUser` to
  support multiple companies (aliased `$company_id` for backward compatibility).
- Removed `[ValidateSet]` on `$asset_maintenance_type` in `New-SnipeitAssetMaintenance`
  and `Set-SnipeitAssetMaintenance` to support custom maintenance types.
- Added `$assigned_to` and `$responsible_party_id` (aliased to `$responsible_party`)
  parameters to `New-SnipeitAssetMaintenance` and `Set-SnipeitAssetMaintenance`.

### Security

- Added TLS 1.2 enforcement in Connect-SnipeitPS
  (`[Net.ServicePointManager]::SecurityProtocol`) for PS5.1 environments that may
  default to TLS 1.0/1.1
- Added URI scheme validation (http/https only) on Connect-SnipeitPS `-url` parameter
- Added `[ValidateNotNullOrEmpty()]` on Connect-SnipeitPS `-apiKey` parameter
- Redacted API key from `Write-Debug` output in Invoke-SnipeitMethod and
  Connect-SnipeitPS

### Bug Fixes

- Fixed shared mutable `$Values` hashtable corruption on multi-ID image uploads in 12
  Set-\* functions by cloning per iteration (Set-SnipeitAccessory, Set-SnipeitAsset,
  Set-SnipeitCategory, Set-SnipeitCompany, Set-SnipeitComponent, Set-SnipeitConsumable,
  Set-SnipeitDepartment, Set-SnipeitLicense, Set-SnipeitLocation,
  Set-SnipeitManufacturer, Set-SnipeitModel, Set-SnipeitSupplier, Set-SnipeitUser)
- Fixed malformed `data:@mimetype` base64 URI prefix in PS5 image uploads (removed
  spurious `@` in Invoke-SnipeitMethod)
- Fixed `$last_checkout` DateTime not formatted as `yyyy-MM-dd` in Set-SnipeitAsset
- Removed spurious `/delete` suffix from Remove-SnipeitAssetFile and
  Remove-SnipeitModelFile API paths (Snipe-IT uses DELETE method, not a `/delete`
  endpoint)
- Fixed `$_` shadowing in catch blocks losing HTTP status code in Invoke-SnipeitMethod
  (saved to `$httpError` before nested try/catch)
- Fixed StreamReader not disposed on PS5 error path in Invoke-SnipeitMethod (moved
  `.Close()` to `finally` block)
- Fixed `$false` from auth failure leaking into pipeline output in Invoke-SnipeitMethod
  (changed `return $false` to bare `return`)
- Fixed Get-ParameterValue not converting negated switches (`-Param:$false`); now checks
  `[SwitchParameter]` type and uses `.IsPresent` value instead of only detecting `$true`
- Fixed Constant throttle mode arithmetic going negative on first request when no
  previous requests exist
- Fixed Get-SnipeitAsset `$requestable` silently filtering all searches (`[bool]`
  defaulted to `$false`; changed to `[switch]`)
- Fixed Get-SnipeitFieldsetField using POST instead of GET
- Fixed Get-SnipeitUser `$id` and `$accessory_id` typed as `[string]` instead of `[int]`
- Fixed Get-SnipeitLicenseSeat and 3 other non-paginated Get-\* functions using falsy
  `if($id)` check; replaced with `$PSBoundParameters.ContainsKey`
- Fixed `$offset` falsy check replaced with `$PSBoundParameters.ContainsKey('offset')`
  in pagination logic
- Fixed New-SnipeitComponent `$qty` type mismatch
- Fixed Update-SnipeitAlias regex injection vulnerability
- Fixed `checkout_to_type` default leaking into API body on non-checkout creates in
  New-SnipeitAsset
- Removed `checkout_to_type` from `$Values` body in Set-SnipeitAssetOwner
- Removed `seat_id` from API body in Set-SnipeitLicenseSeat
- Fixed `$null` pipeline leak in pagination loops across 27 Get-\* functions
- Fixed pagination PS7 compatibility and raised offset safety cap to 10M
- Fixed Get-SnipeitConsumable missing `.Clone()` on search parameters for pagination
- Removed dead `image_delete` switch from New-SnipeitLocation and New-SnipeitDepartment
  (not applicable to create operations)
- Fixed `$apikey` variable case to `$apiKey` for consistency
- Fixed `$Values` casing in Set-SnipeitCategory
- Fixed LF line endings to CRLF in 4 source/test files

### Parameter Validation

- Added `[ValidateRange(1, [int]::MaxValue)]` on foreign-key ID parameters across 12+
  functions (New-SnipeitAsset, New-SnipeitAssetMaintenance, New-SnipeitAudit,
  New-SnipeitComponent, New-SnipeitConsumable, New-SnipeitDepartment,
  New-SnipeitLicense, New-SnipeitLocation, New-SnipeitModel, New-SnipeitUser,
  Set-SnipeitAsset, Set-SnipeitAssetMaintenance, Set-SnipeitModel)
- Added `[ValidateSet]` on `$asset_maintenance_type` in New-SnipeitAssetMaintenance and
  Set-SnipeitAssetMaintenance (Maintenance, Repair, Upgrade, PAT Test, Calibration,
  Software Support, Hardware Support)
- Added `[ValidateRange(1, [int]::MaxValue)]` on `$seats` in New-SnipeitLicense
- Standardized `$purchase_cost` from `[float]` to `[string]` across 7 functions
  (New-SnipeitAccessory, New-SnipeitComponent, New-SnipeitLicense, Set-SnipeitAccessory,
  Set-SnipeitAsset, Set-SnipeitComponent, Set-SnipeitLicense) to match Snipe-IT API
  expectations and avoid floating-point precision issues
- Changed optional `[bool]` parameters to `[Nullable[bool]]` to prevent `$false` default
  injection into API body
- Made Set-SnipeitComponent `$qty` optional for partial updates
- Removed mandatory constraint from Set-SnipeitCustomField, Set-SnipeitStatus,
  Set-SnipeitCompany (allows partial updates)
- Added missing `$sort` parameter to 9 Get-\* functions (Get-SnipeitCategory,
  Get-SnipeitCompany, Get-SnipeitGroup, Get-SnipeitLocation, Get-SnipeitManufacturer,
  Get-SnipeitModel, Get-SnipeitStatus, Get-SnipeitSupplier, Get-SnipeitUser)
- Added `$image` parameter to `$Values` body in New-SnipeitModel (was silently ignored)
- Accept `[SecureString]` for password in New-SnipeitUser and Set-SnipeitUser

### Code Quality

- Formatted CHANGELOG.md to comply with markdownlint standards (MD013 line length,
  MD001/MD025 heading structures).
- Added `.markdownlint.json` to project root to allow duplicate sibling headings (MD024)
  which is standard for changelogs.
- Set ConfirmImpact to `High` on all 20 Remove-\* functions with meaningful
  ShouldProcess targets
- Set ConfirmImpact to `Medium` on all Set-\* functions
- Set ConfirmImpact to `High` on Unregister-SnipeitCustomField, `Medium` on
  Update-SnipeitAssetAudit
- Replaced ShouldProcess placeholder strings with meaningful resource identifiers across
  74 functions
- Added explicit parentheses to operator precedence in `end{}` legacy reset condition
- Moved legacy param handling from `process{}` to `begin{}` in Set-SnipeitCustomField
- Fixed pagination bugs across 26 Get-\* functions: clone search params, validate
  offsets, guard against infinite loops
- Removed dead commented-out tests from SnipeitPS.Tests.ps1
- Added `Coverage-Invoke-Method.Tests.ps1` and `Coverage-LoopPrevention.Tests.ps1` test
  files
- Updated `Coverage-New-Legacy.Tests.ps1` and `Coverage-Set-Legacy.Tests.ps1`

### Documentation

- Updated README badge URLs from archived repo to maintained fork
- Added `$sort` parameter documentation to 9 Get-\* docs
- Fixed Connect-SnipeitPS example syntax
- Updated `New-SnipeitAssetMaintenance` `$asset_maintenance_type` parameter help to note
  that custom maintenance types are also accepted

### Infrastructure

- Removed AppVeyor CI (`appveyor.yml`, `SnipeitPS.build.ps1`, `build.ps1`)
- Added `.gitignore` for build artifacts (`coverage.xml`, `Release/`, `TestResult.xml`)
- Updated ProjectUri and LicenseUri in module manifest to point to maintained fork

## [v.1.13.0] - 2026-03-26

### New Functions

- New-SnipeitAssetLabel: Generates printable asset labels
  (`POST /api/v1/hardware/labels`)

### Bug Fixes

- Fixed Set-SnipeitUser: `-RequestType` parameter was ignored; method was hardcoded to
  PATCH instead of using the parameter value. Users could not send PUT requests.

## [v.1.12.0] - 2026-02-10

### Close Snipe-IT v8 API coverage gaps

### New Functions

- Get-SnipeitAssetLicense: Gets licenses assigned to a specific asset
  (`/api/v1/hardware/{id}/licenses`)
- Get-SnipeitComponentAsset: Gets assets checked out to a specific component
  (`/api/v1/components/{id}/assets`)
- Get-SnipeitUserAsset: Gets assets assigned to a specific user
  (`/api/v1/users/{id}/assets`)
- Get-SnipeitUserAccessory: Gets accessories assigned to a specific user
  (`/api/v1/users/{id}/accessories`)
- Get-SnipeitUserLicense: Gets licenses assigned to a specific user
  (`/api/v1/users/{id}/licenses`)
- Get-SnipeitAuditDue: Gets assets due for audit (`/api/v1/hardware/audit/due`)
- Get-SnipeitAuditOverdue: Gets assets overdue for audit
  (`/api/v1/hardware/audit/overdue`)
- Get-SnipeitBackup: Gets list of available Snipe-IT backups
  (`/api/v1/settings/backups`)
- Save-SnipeitBackup: Downloads a Snipe-IT backup file
  (`/api/v1/settings/backups/download/{filename}`)
- Get-SnipeitConsumableUser: Gets users who have a specific consumable checked out
  (`/api/v1/consumables/{id}/users`)

### Bug Fixes

- Fixed Get-SnipeitSetting: API path was incorrectly pointing to
  `/api/v1/settings/backups` instead of `/api/v1/settings`
- Fixed Set-SnipeitLicenseSeat: `end` block was nested inside `process` block,
  preventing `Reset-SnipeitPSLegacyApi` from ever being called when using legacy
  parameters
- Fixed Connect-SnipeitPS: `throttlePeriod` default of 60000ms was never applied due to
  `$null` check on `[int]` parameter (which defaults to 0, not `$null`)
- Fixed Connect-SnipeitPS: Simplified PS5/PS7 `ConvertTo-SecureString` to single
  cross-version call
- Fixed Save-SnipeitBackup: Simplified PS5/PS7 `ConvertFrom-SecureString` to single
  cross-version call

### Code Cleanup

- Removed dead `if ($search -and $id) { Throw }` checks from 9 Get-\* functions
  (parameter sets already enforce mutual exclusion at binding time)
- Fixed ~95 spelling and typo issues across 80+ source and documentation files

### Tests

- Added 615 Pester v5 tests achieving 100% line coverage (2493/2493 lines)
- Added documentation for Connect-SnipeitPS throttle parameters

## [v.1.11.1] - 2026-02-09

### Bug fixes from original repo issue audit

### Critical Fixes

- Fixed New-SnipeitSupplier: API endpoint typo (`/suppilers` -> `/suppliers`) caused
  every call to return 404. Function has never worked. (Original repo issue)
- Fixed Set-SnipeitSupplier: Missing `$id` parameter in Param block made the function
  unable to update any supplier. Added mandatory `[int[]]$id` parameter.
- Fixed Set-SnipeitManufacturer: Missing `$id` parameter in Param block made the
  function unable to update any manufacturer. Added mandatory `[int[]]$id` parameter.

### Moderate Fixes

- Fixed New-SnipeitLicense: `[mailaddress]` type on `license_email` was incompatible
  with `[ValidateLength]` and serialized as object instead of string. Changed to
  `[string]`. (Addresses #299)
- Fixed Set-SnipeitLicense: Same `[mailaddress]` to `[string]` fix for `license_email`.
- Fixed New-SnipeitManufacturer: Body was manually built as `@{ "name" = $Name }`,
  silently ignoring `image` and `image_delete` parameters. Now uses
  `Get-ParameterValue`.

### Enhancements

- Added `status_id` parameter to Set-SnipeitAssetOwner to allow setting asset status
  during checkout. (Addresses #294)
- Added `supplier_url` parameter to New-SnipeitSupplier and Set-SnipeitSupplier to set
  the supplier website URL (renamed to `url` in API body to avoid conflict with
  deprecated `-url` parameter). (Addresses #195)
- Added `manufacturer_url` parameter to New-SnipeitManufacturer and
  Set-SnipeitManufacturer for the same reason.

### Help Text Fixes

- Fixed New-SnipeitSupplier example (was showing New-SnipeitDepartment)
- Fixed Set-SnipeitSupplier example (was showing New-SnipeitDepartment)
- Fixed Set-SnipeitManufacturer synopsis (was saying "Add a new" instead of "Updates")
- Fixed supplier `.PARAMETER notes` description (was saying "Email address")

### Tests

- Added Pester tests for New-SnipeitSupplier, Set-SnipeitSupplier,
  Set-SnipeitManufacturer, New-SnipeitManufacturer, New-SnipeitLicense,
  Set-SnipeitLicense, and Set-SnipeitAssetOwner

## [v.1.11.0] - 2026-02-09

### Extended API coverage

### New features

Added 30 new functions covering missing Snipe-IT API endpoints including groups,
fieldsets, status labels, asset/model files, component and consumable checkout/checkin,
custom field association, user/asset restore, audit, and system information endpoints.

Added file upload support to Invoke-SnipeitMethod for multipart/form-data file uploads
(New-SnipeitAssetFile, New-SnipeitModelFile). Requires PowerShell 7.0 or later.

Added 180 Pester tests covering all new functions including endpoint validation,
parameter passing, legacy API parameter handling, and pagination loop behavior.

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

- Fixed file uploads in Invoke-SnipeitMethod using file[] form field name for
  Laravel/Snipe-IT compatibility
- Clarified Reset-SnipeitComponentOwner id parameter is the component_assets pivot
  record ID, not the component ID (matches accessory checkin pattern)
- Fixed ConvertTo-Json debug output in Invoke-SnipeitMethod causing spurious "Resulting
  JSON is truncated" warnings when not in debug mode
- Fixed Restore-SnipeitAsset and Restore-SnipeitUser failing due to missing body on POST
  requests
- Fixed Get-SnipeitStatusAsset -all pagination by preserving id in search parameters for
  recursive calls
- Removed unreachable dead code in Get-SnipeitGroup (parameter set validation made the
  manual throw check redundant)

## [v.1.10.x] - 2021-09-03

### New secure ways to connect Snipe-IT

### -secureApiKey allows passing apiKey as SecureString

Connect-SnipeitPS -URL '<https://asset.example.com>' -secureApiKey 'tokenKey'

### Set connection with safely saved credentials, first save credentials

$SnipeCred = Get-Credential -message "Use URL as username and API key as password"
$SnipeCred | Export-CliXml snipecred.xml

### ..then use your saved credentials like

Connect-SnipeitPS -siteCred (Import-CliXml snipecred.xml)

### Fix for content encoding in Invoke-SnipeitMethod

Version 1.9 introduced a bug that converted non-ASCII characters to ASCII during
request.

## [v.1.9.x] - 2021-07-14

### Image uploads

### New features

Support for image upload and removal. Just specify filename for -image parameter when
creating or updating item in Snipe-IT. To remove an image, use the -image_delete
parameter.

_Snipe-IT version greater than 5.1.8 is needed to support image parameters._

Most Set-\* commands have a new -RequestType parameter that defaults to Patch. If needed
request method can be changed from default.

### New Functions

Following new commands have been added to SnipeitPS:

- New-Supplier
- Set-Supplier
- Remove-Supplier
- Set-Manufacturer

## [v.1.8.x] - 2021-06-17

### Support for new Snipe-IT endpoints

### New features

Get-SnipeitAccessories -user_id Returns accessories checked out to user ID

Get-SnipeitAsset -user_id Returns assets checked out to user ID

Get-SnipeitAsset -component_id Returns assets with specific component ID

Get-SnipeitLicense -user_id Get licenses checked out to user ID

Get-SnipeitLicense -asset_id Get licenses checked out to asset ID

Get-SnipeitUser -accessory_id Get users that have specific accessory ID checked out

## [v.1.7.x] - 2021-06-14

### Consumables

### New features

Added support for consumables

### New functions

- New-SnipeitConsumable
- Get-SnipeitConsumable
- Set-SnipeitConsumable
- Remove-SnipeitConsumable

## [v.1.6.x] - 2021-06-14

### Remove more things and set some more

### New features

Added some set and remove functions. Pipeline input is supported for all remove
functions.

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

## [v1.5.x] - 2021-06-08

### Piping input

### New features

Most "Set" commands accept piped input. Piped objects "id" attribute is used to select
asset set values. Like Get-SnipeitAsset -model_id 213 | Set-SnipeitAsset -notes 'This is
nice!'

Set commands accept the ID parameter as an array, so it's easier to set multiple items
in one run.

Parameter sets. Get commands now have parameter sets. This will make syntax more clear
between search and get by ID use. Use Get-Help to see parameter sets.

### Fixes

- Empty strings are accepted as input, so it's possible to wipe field values if needed

## [v1.4.x] - 2021-05-27

### More Activity

### New features

Snipe-IT activity history is now searchable. So finding out who checked out the asset is
easy. API supports many different target or item types that can be used as a filter.
Searchable types are 'Accessory','Asset','AssetMaintenance'
'AssetModel','Category','Company','Component','Consumable','CustomField',
'Group','Licence','LicenseSeat','Location','Manufacturer','Statuslabel',
'Supplier','User'

### New Functions

- Get-SnipeitActivity Get and search Snipe-IT change history.

## [v1.3.x] - 2021-05-27

### Checking out accessories

### New features

You can specify Put or Patch for Set-SnipeitAsset when updating assets.
Set-SnipeitLocation new -city parameter

### New Functions

- Set-SnipeitAccessoryOwner checkout accessory
- Get-SnipeitAccessoryOwner list checked-out accessories
- Reset-SnipeitAccessoryOwner checkin accessory

### Fixes

- Set-SnipeitAsset fixed datetime and name inputs #126,128

## [v1.2.x] - 2021-05-24

### Prefixing SnipeitPS

### New Features

All commands are now prefixed like Set-Info -> Set-SnipeitInfo. To keep compatibility
all old commands are available as aliases. To update existing scripts there's the
Update-SnipeitAlias command.

### New functions

- Update-SnipeitAlias Tool to update existing scripts
- Get-SnipeitLicenseSeat lists license seats
- Set-SnipeitLicenseSeat Sets and checks out/in license seats License seat API is
  supported from Snipe-IT release >= v5.1.5

### New fixes

Added -id parameter support for Get-SnipeitCustomField and Get-SnipeitFieldset commands

## [v1.1.x] - 2021-05-18

### Pull request rollup release. Lots of new features including

### New features

- PowerShell 7 compatibility. So you can use SnipeitPS on macOS or Linux.
- Get every asset, model, license with Snipe-IT ID by using -id parameter
- Get assets also by -asset_tag or serial number
- Get functions also return all results from Snipe-IT when using -all parameter (by
  @PetriAsi)

### New functions

- Reset-AssetOwner by @lunchboxrts
- Remove-Asset by @sheppyh
- Added Remove-AssetMaintenance by @sheppyh
- Remove-User @gvoynov

### Fixes

- Fixed version number on PowerShell Gallery
- Fixed Set-AssetOwner when checking asset out to another asset.

## [v1.0] - 2017-11-18
