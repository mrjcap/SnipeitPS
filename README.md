# SnipeitPS

[![GitHub release](https://img.shields.io/github/release/mrjcap/SnipeitPS.svg)](https://github.com/mrjcap/SnipeitPS/releases/latest)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/snipeitps.svg)](https://www.powershellgallery.com/packages/snipeitps)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

PowerShell module for the Snipe-IT REST API. Works in Windows PowerShell 5.1 and PowerShell 7 on Windows, Linux,
and macOS.

---

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

Install from the [PowerShell Gallery](https://www.powershellgallery.com/packages/SnipeitPS):

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

The local release candidate is **2.0.0 (unreleased)**. It is not a drop-in replacement for v1.15.2.
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

## Known limitations

The API contract ledger is an inventory, not a claim of complete API parity. Its 249 normalized rows include
seven server-blocked declarations and four protocol exclusions. Field-level source and runtime reconciliation remains
incomplete for all 238 active candidates. Historical `Verified` labels do not mean every writable field was verified.

Company listing has no explicit `page` parameter and cannot express the server's literal `parent_id=null` filter with
its integer parameter; `0` is not equivalent. Bulk maintenance images and custom regex updates are unsupported.
Authorization, encrypted fields, advanced filters, image handling, and persistence still need deployment-specific checks.
Offline results do not establish live-server behavior. See `Tests/Fixtures/ApiParity.Contracts.psd1` for per-route limits.

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

Release validation on 2026-09-26 is recorded in [CHANGELOG.md](CHANGELOG.md). After the file-ID fix, all 1860 offline
tests passed on PowerShell 7 and the Windows PowerShell 5.1 SDK host. The user's Windows PowerShell 5.1.26100.9549
Desktop ConsoleHost run also passed all 1860 tests, with 92.66% command coverage across 200 files.
The rebuilt 2.0.0 package passed 29 focused offline tests on each engine and 12 affected live file-retrieval tests
on the Windows PowerShell 5.1 SDK host, with validated HTTPS and verified fixture and token cleanup. The earlier
125-test Linux integration result applies to the older package, not the rebuilt artifact. macOS remains untested.
These results do not establish complete API parity or validate other deployed server versions.

---

## License

MIT
