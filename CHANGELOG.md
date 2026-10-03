# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/), and this project
adheres to [Semantic Versioning](http://semver.org/).

## [v2.0.1] - Unreleased

### Added

- Add 12 commands covering current resource endpoints, order items, and quantity adjustments.
- Add acquisition fields, `requestable` flags, and nullable `default_purchase_cost` parameters.
- Add collection filters and assignment search/sort options identified in the current-server audit.
- Add supplemental contracts for Snipe-IT revision `5d7fe00370813649d6b535a43d3a47ec51adbab2`.
  The historical API ledger keeps its original reference.

### Fixed

- Correct model-assets routing and keep request, checkout, seat, and inventory identities separate.
- Preserve maintenance colors, import blank-field options, and actual HTTP status codes on error responses.
- Fix Windows PowerShell 5.1 fixture loading, URI mock capture, and compact empty-object JSON serialization.
- Run test subprocesses noninteractively and reject skipped tests, failed containers, and nonzero integration exits.
- Correct live deletion assertions to match the stock server's category and manufacturer behavior.

### Migration from v2.0.0

- Request rows expose `request_id` instead of `id`. Non-hardware requestable rows expose the corresponding
  `model_id`, `accessory_id`, `consumable_id`, `component_id`, or `license_id` instead of an ambiguous `id`.
- User assignment rows expose the inventory ID as `id` and retain the assignment ID as `checkout_id` or `seat_id`.
  Review scripts that previously treated assignment IDs as inventory IDs.

### Validation and scope

- Before the version update, the committed source passed 2,116 offline tests on PowerShell 7.
  The user verified 2,114 full-suite tests and seven focused contract tests on Windows PowerShell 5.1.
- The isolated current-server integration suite passed 141 tests without skips or teardown errors.
  Native HTTP used a localhost TLS relay and container-local curl, not direct Windows-to-Unraid transport.
- All 288 normalized API method-route pairs are accounted for. Six stock-server limitations and four
  OAuth, SCIM, or diagnostic exclusions remain explicit; this is not a claim of literal full API support.
- Release package validation, tagging, and publication are pending. Snipe-IT source remains unchanged.

## [v2.0.0] - 2026-09-28

### Release scope

- Version 2.0.0 is a major release because it breaks v1.15.2 calling conventions.
  The comparison baseline is commit `28f996c5cce0646b689dcf2ec6da7fc9a0a1d79b`.
- Retain all 115 baseline function exports; this release exports 179 functions.
- Restore the 37 declared legacy aliases at import, including the `SNIPEITPS_DISABLE_LEGACY_ALIASES` opt-out.
  Full `Snipeit` command names remain preferred.
- Keep the earlier 1.16.0 entry as development history, not evidence of publication or current runtime validation.

### Migration from v1.15.2

- Removed per-command connection `url` and `apiKey` parameters require `Connect-SnipeitPS` or `-Session` instead.
  Maintenance `url` parameters describe a maintenance record, not a connection.
- Connections now require HTTPS. HTTP credential transport will not be restored for compatibility.
- Maintenance `assigned_to` is rejected. Use `responsible_party_id` for the responsible user; use paired
  `checked_out_to_id` and `checked_out_to_type` on updates for checkout snapshots.
- Custom regex creation requires a complete Laravel `regex:/.../` rule. Custom regex updates are unsupported;
  omit `format` and `custom_format` when changing other field properties.
- Nullable fields, omitted defaults, pipeline binding, and response handling changed during the API corrections.
  Asset creation with checkout requires an explicit `checkout_to_type`. Prefer named arguments and review scripts
  that depend on ignored fields or implicit defaults. See the README migration section before upgrading.

### Known limitations

- The 249 normalized ledger rows include seven server-blocked declarations and four protocol exclusions.
  They are not 249 supported endpoints. Field-level source and runtime reconciliation remains incomplete for all
  238 active candidates; historical `Verified` labels are not exhaustive verification.
- Company listing lacks explicit `page` support and literal `parent_id=null` filtering. Bulk maintenance images and
  custom regex updates remain unsupported. Deployment-specific permissions, advanced filters, encrypted fields,
  images, and persistence need further checks.

### Fixed

- `Get-SnipeitFile` now rejects `inline` or `AsByteArray` without `file_id` before making an HTTP request,
  including explicitly false switches. It throws `file_id is required for single-file retrieval.` instead of
  prompting for a missing parameter. Four regression tests cover these calls.

### Verification

- After the fix on 2026-09-26, all 1860 offline tests passed on PowerShell 7 and the Windows PowerShell 5.1
  Desktop engine in a temporary SDK host, with exit 0 and zero adverse NUnit counts.
- The user's Windows PowerShell 5.1.26100.9549 Desktop ConsoleHost coverage run passed all 1860 tests,
  including the analyzer checks and missing-file-ID regressions, with zero failures, skips, inconclusive,
  or not-run tests. Pester 5.8.0 measured 92.66% command coverage: 4862 of 5247 commands across 200 files,
  with 385 commands unexecuted. This is command coverage, not complete API compatibility.
- The rebuilt local package contains the fix. All 204 module files matched the tested source snapshot;
  `Public/Get-SnipeitFile.ps1` was the only module file changed from the previous package. New package SHA256:
  `edc27724b8ac3b968b6b550b8ca6328a6ce4943339460054931f5e8602b3601e`.
- The extracted new package passed 29 focused offline tests on each engine, PowerShell 7 and Windows
  PowerShell 5.1, with zero adverse NUnit counts and exit 0.
- The new package passed 12 affected live tests on the Windows PowerShell 5.1 SDK host against the isolated
  server, with 21 API requests and exit 0. Tests covered listing, exact text and byte retrieval with `inline`
  omitted, true, or false, and rejection of missing file IDs without HTTP requests. This was a focused rerun,
  not a repeat of the full integration suite. Fixture cleanup, token revocation, removal of the plaintext token,
  and tunnel shutdown were verified.
- Package verification evidence is stored under
  `Release/release-validation-20260926/fixed-package-20260926-2110/`, including `validation.json`.
- An earlier ConsoleHost run failed during analyzer setup with `Collection was modified; enumeration operation
  may not execute.` The latest full run passed without an analyzer change; the earlier failure remains unexplained.

### Earlier validation

- Before the file-ID fix, PowerShell 7.6.6 on Windows and Windows PowerShell 5.1.26100.9444 Desktop in a temporary
  SDK host each passed 1856 offline tests on 2026-09-26, with exit 0 and zero adverse NUnit counts.
- Subprocess tests now reuse the current host executable. The multipart debug fixture uses `DebugPreference=Continue`
  instead of the interactive 5.1 `-Debug` behavior and also asserts that the binary redaction marker appears.
  The SDK host's stderr contained `No more data is available.` despite the passing result; that diagnostic is retained
  in the evidence. Earlier SDK attempts timed out and are not counted as passes.
- The earlier package, which lacks the file-ID fix, imported and authenticated over validated HTTPS on
  PowerShell 7.4.6, Ubuntu 22.04.5.
  Its 204 module files matched the Windows offline-tested snapshot. Package SHA256:
  `64bd051fd3e77bc44fb34aa952b0f8f8c72bc36ee07585e7e489b46edbaabba1`.
- Isolated integration retry on 2026-09-26: 125 passed, 0 failed, 0 skipped, 342 requests, exit 0. It tested the same
  package on PowerShell 7.4.6 and Ubuntu 22.04.5 with TLS validation enabled. Token revocation, removal of token files
  and the temporary runner, and no remaining active entity fixtures were verified.
- The earlier integration attempt was interrupted when both test containers stopped at 00:02 +03:00. Its cause
  remains unconfirmed; it is not counted as a pass. The later successful retry does not establish that cause.
- The earlier package also passed 117 live tests on the local Windows PowerShell 5.1.26100.9549 SDK host,
  with 323 API requests and exit 0. Eight existing PowerShell 7-only upload tests were excluded explicitly.
  These results and the Linux integration results apply to the earlier package, not the rebuilt artifact.
- macOS remains untested. The earlier package is unchanged.

### Publication

- Published [v2.0.0 on GitHub](https://github.com/mrjcap/SnipeitPS/releases/tag/v2.0.0) on 2026-09-28,
  tagged at commit `566a08f8ba958595843fcf12d017696d6566ef76`.
- Uploaded the validated package and its SHA256 file. The downloaded GitHub asset matched the verified package hash.
- This release operation did not publish to PowerShell Gallery.

## [v1.16.0] - 2026-09-24

### Added

- Added tab completion for nine entity ID types using a five-minute cache, plus `Clear-SnipeitCache`.
- Added typed output and default table views for assets, users, licenses, models, and locations.
- Added bulk asset operations, `Sync-SnipeitAsset`, and multi-tenant `-Session` support.
- Added the MCP server, compiled help, and documentation tests.
- **Pre-defined Kit Management:** `Get-SnipeitKit`, `New-SnipeitKit`, `Set-SnipeitKit`, `Remove-SnipeitKit`,
  `Get-SnipeitKitItem`, `Add-SnipeitKitItem`, `Set-SnipeitKitItem`, and `Remove-SnipeitKitItem` for managing kits and
  attaching/updating models, licenses, accessories, and consumables.
- **File & Attachment Operations:** `Get-SnipeitFile`, `New-SnipeitFile`, `Save-SnipeitFile`, and `Remove-SnipeitFile`
  with multi-part upload transport adapter (`Send-SnipeitMultipart`) supporting 9 entity types.
- **CSV Imports Management:** `Get-SnipeitImport`, `New-SnipeitImport`, `Invoke-SnipeitImport`, and `Remove-SnipeitImport`
  for managing CSV files, column mappings, and import execution.
- **Depreciations & Accounting Reports:** `Get-SnipeitDepreciation`, `New-SnipeitDepreciation`,
  `Set-SnipeitDepreciation`, `Remove-SnipeitDepreciation`, and `Get-SnipeitDepreciationReport`.
- **Universal SelectLists & Entity History:** `Get-SnipeitSelectList` supporting 13 entity types with auto-paging, and
  `Get-SnipeitHistory` supporting 9 entity types with action and IP filtering.
- **Assigned Inventory Queries:** `Get-SnipeitAssetAssignment`, `Get-SnipeitLocationAsset`, and
  `Get-SnipeitLocationAssignment`.
- **Account Requests & Tokens:** `Get-SnipeitAccountRequest`, `New-SnipeitAccountRequest`,
  `Remove-SnipeitAccountRequest`, `Get-SnipeitRequestableAsset`, `Get-SnipeitAccountEula`,
  `Get-SnipeitPersonalAccessToken`, `New-SnipeitPersonalAccessToken`, and `Remove-SnipeitPersonalAccessToken`.
- **Asset Actions & Label Definitions:** `Get-SnipeitAssetDue`, `Get-SnipeitLabelDefinition`, `Get-SnipeitAssetNote`,
  `New-SnipeitAssetNote`, `Set-SnipeitFieldsetOrder`, `Get-SnipeitStatusCount`, `Test-SnipeitStatusDeployable`,
  `Restore-SnipeitManufacturer`, and `Get-SnipeitActivityChart`.
- **Administrative Diagnostics & Sync:** `Test-SnipeitLdap`, `Test-SnipeitLdapCredential`, `Send-SnipeitTestMail`,
  `Clear-SnipeitBarcode`, `Get-SnipeitLoginAttempt`, `Sync-SnipeitLdapUser`, and `Send-SnipeitUserInventory`.
- **Maintenance Management:** `Get-SnipeitMaintenanceType`, `New-SnipeitMaintenanceType`,
  `Set-SnipeitMaintenanceType`, `Remove-SnipeitMaintenanceType`, `Complete-SnipeitAssetMaintenance`,
  `Get-SnipeitAssetMaintenanceNote`, and `New-SnipeitAssetMaintenanceNote`.
- **License Management:** `Set-SnipeitLicenseOwner` and `Reset-SnipeitLicenseOwner`.
- **Fail-Closed Offline Test Runner:** Added `Tests/Support/Invoke-SnipeitOfflineTest.ps1` with proxy guards preventing
  unmocked network calls to `Invoke-RestMethod` and `Invoke-WebRequest`.
- **API Parity Contract Ledger:** Added `Tests/Fixtures/ApiParity.Contracts.psd1` with 249 normalized inventory rows,
  including blocked declarations and protocol exclusions. This does not establish complete API support.
- **Table Formatting Views:** Tagged output types in `SnipeitPS.format.ps1xml` for kits, depreciations, files, imports,
  login attempts, and backup downloads.

### Changed

- Multipart uploads spool to a temporary file instead of holding the full request in memory. The client sets no
  upload-size cap; available temporary storage and the server's configured limit determine the maximum.
- `Set-SnipeitAssetOwner` supports `-tag` for checking out assets by tag.
- `Reset-SnipeitAssetOwner` supports `-tag` (in route) and body-based quickscan checkin via `-checkin_key` and
  `-checkin_by_field`.
- `Save-SnipeitBackup` supports `-Latest` parameter set and typed `SnipeitPS.BackupDownload` result.
- `Get-SnipeitFieldsetField` supports optional `-model_id` for model-specific default values.
- `New-SnipeitAssetLabel` moves asset tag lookups inside ShouldProcess for zero-HTTP `-WhatIf`.
- `Get-SnipeitAssetMaintenance` supports `-id` single lookup and comprehensive query filters.
- `New-SnipeitAssetMaintenance` supports bulk creation via `-asset_ids`.
- Maintenance updates support paired checkout-snapshot fields, including explicit clearing. Creation leaves the
  snapshot to the server instead of sending fields the server overwrites.
- Maintenance completion uses the server timestamp and supports an optional journal note.
- Status updates preserve omitted values while allowing explicit null and false values.
- Existing resource commands expose audited query and writable fields, with explicit null, false, zero, array,
  image, authorization-error, and per-record pipeline tests against the pinned server source.
- Maintenance creation and updates support URL, completion metadata, nullable supplier, cost and duration fields.
  Single-asset creation accepts images; bulk maintenance images remain unsupported.
- Depreciation reports and due-asset listings support shared asset filters and validated custom-field columns.
  Asset model filters accept multiple IDs, and asset sorting accepts server-supported custom-field columns.
- Single-file reads and downloads support `-inline`. Binary reads use `-AsByteArray`; downloads preserve bytes.
  The server honors inline disposition only for its safe file-extension allowlist.

### Breaking changes

- `New-SnipeitAssetMaintenance` and `Set-SnipeitAssetMaintenance` reject the legacy `assigned_to` parameter with
  migration guidance. Use `responsible_party_id` for the responsible user, or the paired `checked_out_to_id` and
  `checked_out_to_type` fields when updating the checkout snapshot.

### Fixed

- Replaced sliding-window array copies with a timestamp queue in the rate limiter.
- Added pipeline property binding for IDs across Get, Set, and Remove commands.
- Corrected multiline backtick formatting in platyPS help.
- User company assignments use the API's `company_ids` field.
- Bulk asset updates use `PATCH /api/v1/hardware/bulk`; bulk removal uses per-asset DELETE requests with results and
  errors correlated to each requested ID.
- Dispatcher handling of bulk response envelopes, structured API errors, and transport failures.
- URI path escaping avoids double encoding.
- Serial-based audits send the API's `audit_by_field` and `audit_key` fields.
- License-seat updates send `notes`, enforce mutually exclusive assignment targets, and support clearing assignments.
- Maintenance types resolve through the server catalog instead of assuming fixed IDs.
- Singleton pagination preserves row counts on PS5, fixing skipped rows and maintenance-name lookups.
- PS5 cache methods normalize empty pipeline output to null instead of throwing an index exception.
- Argument completers bind fetch callbacks to the loaded module, restoring PS5 lookup and disconnected recovery.
- Test fixtures use native PS5 and PS7 behavior for credential conversion, uploads, HTTP errors, subprocess stderr, and
  file paths without skipping tests or weakening assertions.

### Verification

- PowerShell 7 offline tests: 1845 passed, 0 failed, 0 skipped on 2026-09-24.
- PowerShell 5.1 and live-service integration tests were not rerun for this local release.
- Passing offline tests does not establish complete deployed-server API parity.

## [v1.15.2] - 2026-08-17

### Added

- **Labels & Asset Tags:** Added support for `-asset_tags` on `New-SnipeitAssetLabel` with auto-resolution of asset tags
  from provided `-asset_ids` (`e8364ba`).
- **Live Integration Test Framework:** Added comprehensive integration test suites (15 test files) covering 100% of
  all public cmdlets with dedicated runner `run-integration-tests.ps1` (`d07d09d`, `1b8707a`, `0ed8305`).
- **Targeted Core Hardening Unit Tests:** Added `Tests/Engine-Hardening.Tests.ps1` covering module export boundaries,
  pipeline isolation, 429 adaptive throttling, and response normalization (`06b6c30`).

### Fixed

- **Module Manifest & Lifecycle Teardown:**
  - Pinned `CmdletsToExport = @()` and `VariablesToExport = @()` in `SnipeitPS.psd1` while preserving all 37 legacy
    aliases and declaring `CompatiblePSEditions = @('Desktop', 'Core')` (`ff662f2`).
  - Standardized cross-platform script loading with `Join-Path` and added type-safe OnRemove cleanup hook in psm1
    to clear `$SnipeitPSSession` on module unload (`ff662f2`).
  - Silenced uncommanded pipeline output in `Set-SnipeitAlias` with `[void]` and added
    `$env:SNIPEITPS_DISABLE_LEGACY_ALIASES` opt-out (`ff662f2`).
- **Parameter Engine & Query Formatting:**
  - Restricted `Get-ParameterValue` default variable resolution to Scope 0, preventing accidental leakage from caller
    scopes (`7cbe69a`).
  - Excluded CommonParameters (`Verbose`, `Debug`, `Confirm`, `WhatIf`, etc.) and engine automatic variables
    (`$PID`, `$Host`, `$Profile`, `$Error`) from unbound parameter collection (`7cbe69a`).
  - Replaced `System.Web.HttpUtility` with `System.Net.WebUtility` in `ConvertTo-GetParameter` for cross-platform
    Linux/macOS support (`7cbe69a`).
  - Formatted array query parameters using PHP bracket notation (`${key}%5B%5D=${val}`) and lowercased boolean
    values (`'true'` / `'false'`) (`7cbe69a`).
- **HTTP Transport & 429 Throttling:**
  - Isolated `$_headers` per request in `PROCESS` block to prevent cross-request header leakage (`4fd03e6`).
  - Added `MaximumRedirection = 0` to prevent unauthenticated 302 login redirect loops (`4fd03e6`).
  - Hardened dual status code extraction across PowerShell 5.1 and 7+ (`4fd03e6`).
  - Sanitized 502/504 HTML proxy error blobs and handled HTTP 204 No Content gracefully (`4fd03e6`).
  - Normalized empty rows and total-0 envelope responses to emit empty arrays `@()` instead of container objects
    (`4fd03e6`).
  - Hardened sliding window calculations and protected against zero-count indexing in Burst, Constant, and Adaptive
    throttling modes (`4fd03e6`).
- **Audit Cmdlets & Pipeline Binding:**
  - Standardized parameter naming on `$asset_tag` with alias `tag` and added `BySerial` parameter set on
    `New-SnipeitAudit` (`37a10e0`).
  - Fixed pipeline binding in `New-SnipeitAudit` and `Update-SnipeitAssetAudit` by checking variable values in
    `process {}` block instead of `$PSBoundParameters.ContainsKey()` (`37a10e0`).
  - Set `ConfirmImpact = "Medium"` on audit cmdlets (`37a10e0`).
- **Cmdlet Bug Fixes:**
  - `Set-SnipeitAsset`: Warns and overrides `-RequestType Put` to `PATCH` for bulk asset endpoints, and guards
    against `-image` in bulk updates (`06b6c30`).
  - `Set-SnipeitAsset`: Resolved API parameters per-item in `process {}` block for streaming pipeline input and
    preserved `checkout_to_type` in asset checkout body (`567b78c`, `6e23f30`).
  - `Reset-SnipeitPSLegacyApi`: Removed `SupportsShouldProcess` so legacy credential cleanup executes unconditionally
    even under `-WhatIf` (`06b6c30`).
  - `Get-SnipeitFieldsetField`: Switched to POST method with request body matching Snipe-IT API requirements
    (`a33928c`, `535df17`, `e430622`).
  - `New-SnipeitManufacturer` & `Set-SnipeitManufacturer`: Fixed parameter variable casing for `$name` (`0eeb7e4`,
    `fc8d9a6`).
  - `New-SnipeitAssetMaintenance` & `Set-SnipeitAssetMaintenance`: Mapped `$title` to `name` and friendly maintenance
    types to numeric IDs on creation and update (`2b8017f`, `e86684a`).

## [v1.15.1] - 2026-08-14

### Added

- Native bulk asset edit support in `Set-SnipeitAsset` via `PATCH /api/v1/hardware/bulk` when passing
  multiple IDs (grokability/snipe-it#19271).
- Native bulk asset audit support in `Update-SnipeitAssetAudit` and `New-SnipeitAudit` via
  `POST /api/v1/hardware/audit/bulk` when passing multiple IDs (grokability/snipe-it#19271).
- Added `-note` (alias: `notes`) and `-image` upload parameters to `Update-SnipeitAssetAudit` and `New-SnipeitAudit`.
- Added comprehensive unit tests in `Tests/Coverage-BulkOperations.Tests.ps1`.
- Added parameter set enforcement (`ById`, `ByTag`, `BySerial`) to `Update-SnipeitAssetAudit` and `New-SnipeitAudit`
  for mutual exclusion of identifier parameters.
- Added guard against combining `-image` with bulk IDs on audit functions (multipart/form-data corrupts array
  serialization).

### Fixed

- Hardened bulk asset operations against empty arrays (`-id @()`) by adding `[ValidateNotNullOrEmpty()]` to prevent
  malformed empty API calls that silent-fail or hit incorrect endpoints.
- Fixed pipeline binding leak in `Set-SnipeitAsset` where `$Values` was constructed in `begin {}`, dropping piped
  properties; moved evaluation to `process {}` block for safe streaming.
- Fixed pipeline evaluation bug in `Update-SnipeitAssetAudit` where parameters were evaluated in `begin {}` block
  instead of per-item in `process {}`.
- Normalized HTTP method casing to `'POST'` in `New-SnipeitAudit` (was inconsistently `'Post'`).

### Breaking Changes

- `Update-SnipeitAssetAudit` now uses parameter sets (`ById`, `ByTag`, `BySerial`). Passing `-id` with `-asset_tag`
  or `-serial` simultaneously is no longer allowed — PowerShell will reject the call at parameter binding.
- `New-SnipeitAudit` now uses parameter sets (`ByTag`, `ById`). Passing `-tag` with `-id` simultaneously is no
  longer allowed.

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
