# SnipeitPS

[![GitHub release](https://img.shields.io/github/release/mrjcap/SnipeitPS.svg)][github-release]
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/snipeitps.svg)][gallery-package]
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[github-release]: https://github.com/mrjcap/SnipeitPS/releases/latest
[gallery-package]: https://www.powershellgallery.com/packages/snipeitps

PowerShell module for the Snipe-IT REST API, targeting Windows PowerShell 5.1 and PowerShell 7.
Release validation covers Windows and selected Linux scenarios; macOS remains untested.

---

## What's new in 2.0.0

Version 2.0.0 retains all 115 functions from v1.15.2 and adds 64, for 179 exported functions.
The earlier 1.16.0 changelog entry records development work included in this major release.

- New commands cover kits, generic attachments, CSV imports, depreciation reports, history, selectlists,
  account requests and tokens, maintenance types and notes, license checkout, and administrative diagnostics.
- Request handling now distinguishes omitted values from explicit null and false. Updates include corrected
  API field names, pipeline routing, pagination, timestamps, and structured errors.
- Sessions support multiple servers. Typed results, cached argument completion, bulk operations, desired-state
  sync, and the MCP server extend interactive and scripted workflows.
- Connections require HTTPS. Download handling preserves existing files on failure, and transport diagnostics
  redact credentials and upload content. Mutation commands support `-WhatIf` and `-Confirm`.
- `Get-SnipeitFile` rejects `inline` or `AsByteArray` without `file_id`, including explicitly false switches,
  instead of prompting for a missing parameter.

Start with [migration requirements](#migrating-to-200), then browse the [command reference](#command-reference).
See the [changelog](CHANGELOG.md) for individual fixes, behavior changes, verification results, and remaining limits.

## Features

- **REST v1 API coverage.** Commands for assets, models, licenses, accessories, consumables,
  components, categories, companies, departments, locations, manufacturers, status labels, suppliers, users, groups,
  pre-defined kits, depreciations, CSV imports, file attachments, selectlists, activity history, account requests,
  personal access tokens, and administrative diagnostics. Full field-level parity remains under audit;
  the contract ledger is not proof that every writable server field is supported.
- **Tab completion.** Press Tab on ID parameters (`-model_id`, `-status_id`, `-location_id`, `-category_id`) to search
  by name and insert IDs automatically. Lookups are cached in memory for 5 minutes. Use `Clear-SnipeitCache` to refresh
  immediately.
- **Default table formatting.** Objects are tagged with `PSTypeName` so PowerShell prints clean summary tables instead
  of dumping raw JSON.
- **Pipeline binding.** Pipe objects between commands by property name (e.g. `Get-SnipeitUser | Get-SnipeitAsset`).
- **Bulk operations.** `Update-SnipeitAssetBulk` sends batch updates. `Remove-SnipeitAssetBulk` uses per-asset DELETE
  requests and reports each result.
- **Desired state sync.** `Sync-SnipeitAsset` checks for drift and updates or creates assets only when needed.
- **Multi-tenant sessions.** Pass a `[SnipeitSession]` object to `-Session` to query multiple Snipe-IT servers in the
  same script.
- **MCP server.** `mcp/SnipeitMcpServer.ps1` runs a Model Context Protocol server over stdio for AI tools.
- **Offline help.** Shipped with compiled MAML XML help in `en-US/` for `Get-Help`.

---

## Installation

Version 2.0.0 is available from the [GitHub release](https://github.com/mrjcap/SnipeitPS/releases/tag/v2.0.0).
Download and extract the source archive, open PowerShell in the extracted repository directory, and import the module:

```powershell
Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force
```

The release also includes the validated `.nupkg` and its SHA256 file. This release operation did not publish to
PowerShell Gallery. To install the version available on the
[PowerShell Gallery](https://www.powershellgallery.com/packages/SnipeitPS), which may differ from the GitHub release:

```powershell
Install-Module -Name SnipeitPS -Scope CurrentUser
```

---

## Quick start

### 1. Connecting

```powershell
Import-Module SnipeitPS

# Connect with plain token
Connect-SnipeitPS -url 'https://inventory.example.com' -apiKey 'your_token'

# Or connect with SecureString
$key = Read-Host -AsSecureString "Enter API token"
Connect-SnipeitPS -url 'https://inventory.example.com' -secureApiKey $key
```

### 2. Multi-tenant sessions

```powershell
$dev = [SnipeitSession]::new("https://dev.snipeit.local", $devToken)
$prod = [SnipeitSession]::new("https://prod.snipeit.local", $prodToken)

Get-SnipeitAsset -Session $dev -limit 5
Get-SnipeitAsset -Session $prod -limit 5
```

### 3. Tab completion

```powershell
# Press Tab to resolve names to IDs:
New-SnipeitAsset -name "Workstation-01" -model_id <TAB> -status_id <TAB>

# Clear cache after adding items in the web UI:
Clear-SnipeitCache
```

### 4. Pipelines and bulk edits

```powershell
# Update all assets checked out to a user:
Get-SnipeitUser -email "jsmith@example.com" | Get-SnipeitAsset | Update-SnipeitAssetBulk -notes "Verified in 2026 audit"

# Preview a bulk delete with -WhatIf:
Get-SnipeitAsset -status "Archived" | Remove-SnipeitAssetBulk -WhatIf
```

### 5. Desired state sync

```powershell
# Creates the asset if missing, updates only drifted fields:
Sync-SnipeitAsset -asset_tag "SRV-01" -name "Core Router" -model_id 12 -status_id 1 -Ensure Present
```

---

## Migrating to 2.0.0

Version **2.0.0** was released on GitHub on **2026-09-28**. It is not a drop-in replacement for v1.15.2.
All 115 function exports from that baseline remain, but parameter and request behavior changed.

- Move removed per-command `-url` and `-apiKey` arguments to `Connect-SnipeitPS`, or pass a `-Session`.
  Maintenance commands still use `-url` for a maintenance record's URL, not the server address.
- Use an HTTPS server URL. HTTP connections are rejected to protect credentials.
- Legacy aliases are restored, but full names such as `Get-SnipeitAsset` are preferred.
  Set `SNIPEITPS_DISABLE_LEGACY_ALIASES` to `1` or `true` before import to disable them.
- Replace maintenance `-assigned_to` with `-responsible_party_id`. To update a checkout snapshot, pass both
  `-checked_out_to_id` and `-checked_out_to_type`; creation leaves the snapshot to the server.
- For new custom regex fields, use `-format 'CUSTOM REGEX'` and a complete Laravel rule such as
  `-custom_format 'regex:/^\d+$/'`. `Set-SnipeitCustomField` rejects custom regex updates. Omit `format` and
  `custom_format` when updating other properties.
- Review scripts that depend on implicit defaults, positional arguments, response shapes, or ignored fields.
  Nullable fields distinguish omission from explicit null. Checkout during asset creation requires an explicit
  `-checkout_to_type`. Use named arguments and test requests against your server version before upgrading.

## Compatibility

| Engine and platform | Recorded validation |
| --- | --- |
| Windows PowerShell 5.1 on Windows | 1,860 offline tests passed in ConsoleHost and the SDK host. |
| PowerShell 7 on Windows | 1,860 offline tests passed, including the pre-commit rerun on 2026-09-28. |
| PowerShell 7.4.6 on Ubuntu 22.04.5 | 125 live tests passed on the earlier package, before the file-ID fix. |
| PowerShell 7 on macOS | Not tested for this release. |

The released package passed 29 focused offline tests on each Windows engine and 12 affected live tests on the
Windows PowerShell 5.1 SDK host. Those live tests do not establish full API parity or replace deployment testing.
See [running tests](#running-tests) and the [changelog](CHANGELOG.md) for the complete evidence and qualifications.

Legacy attachment uploads through `New-SnipeitAssetFile` and `New-SnipeitModelFile` require PowerShell 7.
The generic `New-SnipeitFile` upload path was exercised successfully by the Windows PowerShell 5.1 live tests.
Image uploads use multipart requests on PowerShell 7 and base64 encoding on Windows PowerShell 5.1.
All versions require an HTTPS Snipe-IT endpoint and a token with permissions for the requested operations.

## Known limitations

The API contract ledger is an inventory, not a claim of complete API parity. Its 249 normalized rows include
seven server-blocked declarations and four protocol exclusions. Field-level source and runtime reconciliation remains
incomplete for all 238 active candidates. Historical `Verified` labels do not mean every writable field was verified.

Company listing has no explicit `page` parameter and cannot express the server's literal `parent_id=null` filter with
its integer parameter; `0` is not equivalent. Bulk maintenance images and custom regex updates are unsupported.
Authorization, encrypted fields, advanced filters, image handling, and persistence still need deployment-specific
checks. Offline results do not establish live-server behavior.
See `Tests/Fixtures/ApiParity.Contracts.psd1` for per-route limits.

## Command reference

All 179 exported functions are linked below, grouped by verb. Each reference page covers syntax, parameters,
examples, and command-specific notes. Legacy aliases are not separate functions in this index.
For conceptual help, see [about SnipeitPS](docs/about_SnipeitPS.md).

- [Get commands](#get-commands)
- [New commands](#new-commands)
- [Set commands](#set-commands)
- [Remove commands](#remove-commands)
- [Other commands](#other-commands)

```powershell
Get-Command -Module SnipeitPS
Get-Help Get-SnipeitAsset -Full
```

### Get commands

Read and query records.

- [Get-SnipeitAccessory](docs/Get-SnipeitAccessory.md)
- [Get-SnipeitAccessoryOwner](docs/Get-SnipeitAccessoryOwner.md)
- [Get-SnipeitAccountEula](docs/Get-SnipeitAccountEula.md)
- [Get-SnipeitAccountRequest](docs/Get-SnipeitAccountRequest.md)
- [Get-SnipeitActivity](docs/Get-SnipeitActivity.md)
- [Get-SnipeitActivityChart](docs/Get-SnipeitActivityChart.md)
- [Get-SnipeitAsset](docs/Get-SnipeitAsset.md)
- [Get-SnipeitAssetAssignment](docs/Get-SnipeitAssetAssignment.md)
- [Get-SnipeitAssetDue](docs/Get-SnipeitAssetDue.md)
- [Get-SnipeitAssetFile](docs/Get-SnipeitAssetFile.md)
- [Get-SnipeitAssetLicense](docs/Get-SnipeitAssetLicense.md)
- [Get-SnipeitAssetMaintenance](docs/Get-SnipeitAssetMaintenance.md)
- [Get-SnipeitAssetMaintenanceNote](docs/Get-SnipeitAssetMaintenanceNote.md)
- [Get-SnipeitAssetNote](docs/Get-SnipeitAssetNote.md)
- [Get-SnipeitAuditDue](docs/Get-SnipeitAuditDue.md)
- [Get-SnipeitAuditOverdue](docs/Get-SnipeitAuditOverdue.md)
- [Get-SnipeitBackup](docs/Get-SnipeitBackup.md)
- [Get-SnipeitCategory](docs/Get-SnipeitCategory.md)
- [Get-SnipeitCompany](docs/Get-SnipeitCompany.md)
- [Get-SnipeitComponent](docs/Get-SnipeitComponent.md)
- [Get-SnipeitComponentAsset](docs/Get-SnipeitComponentAsset.md)
- [Get-SnipeitConsumable](docs/Get-SnipeitConsumable.md)
- [Get-SnipeitConsumableUser](docs/Get-SnipeitConsumableUser.md)
- [Get-SnipeitCurrentUser](docs/Get-SnipeitCurrentUser.md)
- [Get-SnipeitCustomField](docs/Get-SnipeitCustomField.md)
- [Get-SnipeitDepartment](docs/Get-SnipeitDepartment.md)
- [Get-SnipeitDepreciation](docs/Get-SnipeitDepreciation.md)
- [Get-SnipeitDepreciationReport](docs/Get-SnipeitDepreciationReport.md)
- [Get-SnipeitFieldset](docs/Get-SnipeitFieldset.md)
- [Get-SnipeitFieldsetField](docs/Get-SnipeitFieldsetField.md)
- [Get-SnipeitFile](docs/Get-SnipeitFile.md)
- [Get-SnipeitGroup](docs/Get-SnipeitGroup.md)
- [Get-SnipeitHistory](docs/Get-SnipeitHistory.md)
- [Get-SnipeitImport](docs/Get-SnipeitImport.md)
- [Get-SnipeitKit](docs/Get-SnipeitKit.md)
- [Get-SnipeitKitItem](docs/Get-SnipeitKitItem.md)
- [Get-SnipeitLabelDefinition](docs/Get-SnipeitLabelDefinition.md)
- [Get-SnipeitLicense](docs/Get-SnipeitLicense.md)
- [Get-SnipeitLicenseSeat](docs/Get-SnipeitLicenseSeat.md)
- [Get-SnipeitLocation](docs/Get-SnipeitLocation.md)
- [Get-SnipeitLocationAsset](docs/Get-SnipeitLocationAsset.md)
- [Get-SnipeitLocationAssignment](docs/Get-SnipeitLocationAssignment.md)
- [Get-SnipeitLoginAttempt](docs/Get-SnipeitLoginAttempt.md)
- [Get-SnipeitMaintenanceType](docs/Get-SnipeitMaintenanceType.md)
- [Get-SnipeitManufacturer](docs/Get-SnipeitManufacturer.md)
- [Get-SnipeitModel](docs/Get-SnipeitModel.md)
- [Get-SnipeitModelFile](docs/Get-SnipeitModelFile.md)
- [Get-SnipeitPersonalAccessToken](docs/Get-SnipeitPersonalAccessToken.md)
- [Get-SnipeitRequestableAsset](docs/Get-SnipeitRequestableAsset.md)
- [Get-SnipeitSelectList](docs/Get-SnipeitSelectList.md)
- [Get-SnipeitSetting](docs/Get-SnipeitSetting.md)
- [Get-SnipeitStatus](docs/Get-SnipeitStatus.md)
- [Get-SnipeitStatusAsset](docs/Get-SnipeitStatusAsset.md)
- [Get-SnipeitStatusCount](docs/Get-SnipeitStatusCount.md)
- [Get-SnipeitSupplier](docs/Get-SnipeitSupplier.md)
- [Get-SnipeitUser](docs/Get-SnipeitUser.md)
- [Get-SnipeitUserAccessory](docs/Get-SnipeitUserAccessory.md)
- [Get-SnipeitUserAsset](docs/Get-SnipeitUserAsset.md)
- [Get-SnipeitUserEula](docs/Get-SnipeitUserEula.md)
- [Get-SnipeitUserLicense](docs/Get-SnipeitUserLicense.md)
- [Get-SnipeitVersion](docs/Get-SnipeitVersion.md)

### New commands

Create records and upload files.

- [New-SnipeitAccessory](docs/New-SnipeitAccessory.md)
- [New-SnipeitAccountRequest](docs/New-SnipeitAccountRequest.md)
- [New-SnipeitAsset](docs/New-SnipeitAsset.md)
- [New-SnipeitAssetFile](docs/New-SnipeitAssetFile.md)
- [New-SnipeitAssetLabel](docs/New-SnipeitAssetLabel.md)
- [New-SnipeitAssetMaintenance](docs/New-SnipeitAssetMaintenance.md)
- [New-SnipeitAssetMaintenanceNote](docs/New-SnipeitAssetMaintenanceNote.md)
- [New-SnipeitAssetNote](docs/New-SnipeitAssetNote.md)
- [New-SnipeitAudit](docs/New-SnipeitAudit.md)
- [New-SnipeitCategory](docs/New-SnipeitCategory.md)
- [New-SnipeitCompany](docs/New-SnipeitCompany.md)
- [New-SnipeitComponent](docs/New-SnipeitComponent.md)
- [New-SnipeitConsumable](docs/New-SnipeitConsumable.md)
- [New-SnipeitCustomField](docs/New-SnipeitCustomField.md)
- [New-SnipeitDepartment](docs/New-SnipeitDepartment.md)
- [New-SnipeitDepreciation](docs/New-SnipeitDepreciation.md)
- [New-SnipeitFieldset](docs/New-SnipeitFieldset.md)
- [New-SnipeitFile](docs/New-SnipeitFile.md)
- [New-SnipeitGroup](docs/New-SnipeitGroup.md)
- [New-SnipeitImport](docs/New-SnipeitImport.md)
- [New-SnipeitKit](docs/New-SnipeitKit.md)
- [New-SnipeitLicense](docs/New-SnipeitLicense.md)
- [New-SnipeitLocation](docs/New-SnipeitLocation.md)
- [New-SnipeitMaintenanceType](docs/New-SnipeitMaintenanceType.md)
- [New-SnipeitManufacturer](docs/New-SnipeitManufacturer.md)
- [New-SnipeitModel](docs/New-SnipeitModel.md)
- [New-SnipeitModelFile](docs/New-SnipeitModelFile.md)
- [New-SnipeitPersonalAccessToken](docs/New-SnipeitPersonalAccessToken.md)
- [New-SnipeitStatus](docs/New-SnipeitStatus.md)
- [New-SnipeitSupplier](docs/New-SnipeitSupplier.md)
- [New-SnipeitUser](docs/New-SnipeitUser.md)

### Set commands

Update records and assignments.

- [Set-SnipeitAccessory](docs/Set-SnipeitAccessory.md)
- [Set-SnipeitAccessoryOwner](docs/Set-SnipeitAccessoryOwner.md)
- [Set-SnipeitAsset](docs/Set-SnipeitAsset.md)
- [Set-SnipeitAssetCheckoutBulk](docs/Set-SnipeitAssetCheckoutBulk.md)
- [Set-SnipeitAssetMaintenance](docs/Set-SnipeitAssetMaintenance.md)
- [Set-SnipeitAssetOwner](docs/Set-SnipeitAssetOwner.md)
- [Set-SnipeitCategory](docs/Set-SnipeitCategory.md)
- [Set-SnipeitCompany](docs/Set-SnipeitCompany.md)
- [Set-SnipeitComponent](docs/Set-SnipeitComponent.md)
- [Set-SnipeitComponentOwner](docs/Set-SnipeitComponentOwner.md)
- [Set-SnipeitConsumable](docs/Set-SnipeitConsumable.md)
- [Set-SnipeitConsumableOwner](docs/Set-SnipeitConsumableOwner.md)
- [Set-SnipeitCustomField](docs/Set-SnipeitCustomField.md)
- [Set-SnipeitDepartment](docs/Set-SnipeitDepartment.md)
- [Set-SnipeitDepreciation](docs/Set-SnipeitDepreciation.md)
- [Set-SnipeitFieldset](docs/Set-SnipeitFieldset.md)
- [Set-SnipeitFieldsetOrder](docs/Set-SnipeitFieldsetOrder.md)
- [Set-SnipeitGroup](docs/Set-SnipeitGroup.md)
- [Set-SnipeitInfo](docs/Set-SnipeitInfo.md)
- [Set-SnipeitKit](docs/Set-SnipeitKit.md)
- [Set-SnipeitKitItem](docs/Set-SnipeitKitItem.md)
- [Set-SnipeitLicense](docs/Set-SnipeitLicense.md)
- [Set-SnipeitLicenseOwner](docs/Set-SnipeitLicenseOwner.md)
- [Set-SnipeitLicenseSeat](docs/Set-SnipeitLicenseSeat.md)
- [Set-SnipeitLocation](docs/Set-SnipeitLocation.md)
- [Set-SnipeitMaintenanceType](docs/Set-SnipeitMaintenanceType.md)
- [Set-SnipeitManufacturer](docs/Set-SnipeitManufacturer.md)
- [Set-SnipeitModel](docs/Set-SnipeitModel.md)
- [Set-SnipeitStatus](docs/Set-SnipeitStatus.md)
- [Set-SnipeitSupplier](docs/Set-SnipeitSupplier.md)
- [Set-SnipeitUser](docs/Set-SnipeitUser.md)

### Remove commands

Delete records and detach relationships.

- [Remove-SnipeitAccessory](docs/Remove-SnipeitAccessory.md)
- [Remove-SnipeitAccountRequest](docs/Remove-SnipeitAccountRequest.md)
- [Remove-SnipeitAsset](docs/Remove-SnipeitAsset.md)
- [Remove-SnipeitAssetBulk](docs/Remove-SnipeitAssetBulk.md)
- [Remove-SnipeitAssetFile](docs/Remove-SnipeitAssetFile.md)
- [Remove-SnipeitAssetMaintenance](docs/Remove-SnipeitAssetMaintenance.md)
- [Remove-SnipeitCategory](docs/Remove-SnipeitCategory.md)
- [Remove-SnipeitCompany](docs/Remove-SnipeitCompany.md)
- [Remove-SnipeitComponent](docs/Remove-SnipeitComponent.md)
- [Remove-SnipeitConsumable](docs/Remove-SnipeitConsumable.md)
- [Remove-SnipeitCustomField](docs/Remove-SnipeitCustomField.md)
- [Remove-SnipeitDepartment](docs/Remove-SnipeitDepartment.md)
- [Remove-SnipeitDepreciation](docs/Remove-SnipeitDepreciation.md)
- [Remove-SnipeitFieldset](docs/Remove-SnipeitFieldset.md)
- [Remove-SnipeitFile](docs/Remove-SnipeitFile.md)
- [Remove-SnipeitGroup](docs/Remove-SnipeitGroup.md)
- [Remove-SnipeitImport](docs/Remove-SnipeitImport.md)
- [Remove-SnipeitKit](docs/Remove-SnipeitKit.md)
- [Remove-SnipeitKitItem](docs/Remove-SnipeitKitItem.md)
- [Remove-SnipeitLicense](docs/Remove-SnipeitLicense.md)
- [Remove-SnipeitLocation](docs/Remove-SnipeitLocation.md)
- [Remove-SnipeitMaintenanceType](docs/Remove-SnipeitMaintenanceType.md)
- [Remove-SnipeitManufacturer](docs/Remove-SnipeitManufacturer.md)
- [Remove-SnipeitModel](docs/Remove-SnipeitModel.md)
- [Remove-SnipeitModelFile](docs/Remove-SnipeitModelFile.md)
- [Remove-SnipeitPersonalAccessToken](docs/Remove-SnipeitPersonalAccessToken.md)
- [Remove-SnipeitStatus](docs/Remove-SnipeitStatus.md)
- [Remove-SnipeitSupplier](docs/Remove-SnipeitSupplier.md)
- [Remove-SnipeitUser](docs/Remove-SnipeitUser.md)

### Other commands

Connect, run actions, download files, sync records, and diagnose server settings.

- [Add-SnipeitKitItem](docs/Add-SnipeitKitItem.md)
- [Clear-SnipeitBarcode](docs/Clear-SnipeitBarcode.md)
- [Clear-SnipeitCache](docs/Clear-SnipeitCache.md)
- [Complete-SnipeitAssetMaintenance](docs/Complete-SnipeitAssetMaintenance.md)
- [Connect-SnipeitPS](docs/Connect-SnipeitPS.md)
- [Invoke-SnipeitImport](docs/Invoke-SnipeitImport.md)
- [Register-SnipeitCustomField](docs/Register-SnipeitCustomField.md)
- [Reset-SnipeitAccessoryOwner](docs/Reset-SnipeitAccessoryOwner.md)
- [Reset-SnipeitAssetOwner](docs/Reset-SnipeitAssetOwner.md)
- [Reset-SnipeitComponentOwner](docs/Reset-SnipeitComponentOwner.md)
- [Reset-SnipeitLicenseOwner](docs/Reset-SnipeitLicenseOwner.md)
- [Restore-SnipeitAsset](docs/Restore-SnipeitAsset.md)
- [Restore-SnipeitManufacturer](docs/Restore-SnipeitManufacturer.md)
- [Restore-SnipeitUser](docs/Restore-SnipeitUser.md)
- [Save-SnipeitBackup](docs/Save-SnipeitBackup.md)
- [Save-SnipeitFile](docs/Save-SnipeitFile.md)
- [Send-SnipeitTestMail](docs/Send-SnipeitTestMail.md)
- [Send-SnipeitUserInventory](docs/Send-SnipeitUserInventory.md)
- [Sync-SnipeitAsset](docs/Sync-SnipeitAsset.md)
- [Sync-SnipeitLdapUser](docs/Sync-SnipeitLdapUser.md)
- [Test-SnipeitLdap](docs/Test-SnipeitLdap.md)
- [Test-SnipeitLdapCredential](docs/Test-SnipeitLdapCredential.md)
- [Test-SnipeitStatusDeployable](docs/Test-SnipeitStatusDeployable.md)
- [Unregister-SnipeitCustomField](docs/Unregister-SnipeitCustomField.md)
- [Update-SnipeitAlias](docs/Update-SnipeitAlias.md)
- [Update-SnipeitAssetAudit](docs/Update-SnipeitAssetAudit.md)
- [Update-SnipeitAssetBulk](docs/Update-SnipeitAssetBulk.md)

## Building documentation

To rebuild markdown docs and recompile MAML XML help with platyPS:

```powershell
./build-docs.ps1 -UpdateMarkdown
```

---

## Running tests

Run the Pester test suite:

```powershell
./run-tests.ps1
```

For fail-closed offline verification with unmocked HTTP blocked:

```powershell
pwsh -NoProfile -File ./Tests/Support/Invoke-SnipeitOfflineTest.ps1
powershell.exe -NoProfile -File ./Tests/Support/Invoke-SnipeitOfflineTest.ps1
```

See the [changelog](CHANGELOG.md) for release validation results and known limitations. Test results do not establish
complete API parity or guarantee behavior on every Snipe-IT deployment.

---

## License

MIT
