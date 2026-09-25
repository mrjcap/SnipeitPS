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

The pinned-source verification passes 1756 tests on each host. The ledger in
`Tests/Fixtures/ApiParity.Contracts.psd1` records seven server-blocked declarations, four protocol exclusions and
field-level limitations. Offline tests do not prove deployed-server authorization or storage behavior.

---

## License

MIT
