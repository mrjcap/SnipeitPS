# SnipeitPS

[![GitHub release](https://img.shields.io/github/release/mrjcap/SnipeitPS.svg)][github-release]
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/snipeitps.svg)][gallery-package]
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[github-release]: https://github.com/mrjcap/SnipeitPS/releases/latest
[gallery-package]: https://www.powershellgallery.com/packages/snipeitps

SnipeitPS is a PowerShell module for the Snipe-IT REST API. It runs on Windows PowerShell 5.1 and PowerShell 7 on
Windows, Linux, and macOS.

---

## Features

- **REST v1 API coverage.** The module exports 194 commands for assets, models, licenses, accessories, consumables,
  components, categories, companies, departments, locations, manufacturers, status labels, suppliers, users, groups,
  kits, depreciations, CSV imports, file attachments, selectlists, activity history, account requests, personal access
  tokens, and server diagnostics.
- **Tab completion.** Press Tab on ID parameters such as `-model_id`, `-status_id`, `-location_id`, and `-category_id`
  to search by name and insert the matching ID. The module caches lookups in memory for 5 minutes. Run
  `Clear-SnipeitCache` to clear the cache.
- **Default table formatting.** Commands tag output objects with `PSTypeName` so PowerShell renders summary tables
  instead of raw JSON properties.
- **Pipeline binding.** Pipe objects between commands by property name, such as `Get-SnipeitUser | Get-SnipeitAsset`.
- **Bulk operations.** `Update-SnipeitAssetBulk` sends batch updates, and `Remove-SnipeitAssetBulk` sends per-asset
  DELETE requests and returns each result.
- **Desired state sync.** `Sync-SnipeitAsset` compares target values against the server and creates or updates the
  asset only when fields differ.
- **Multi-tenant sessions.** Pass a `[SnipeitSession]` object to `-Session` to query multiple Snipe-IT servers in the
  same script.
- **MCP server.** `mcp/SnipeitMcpServer.ps1` runs a Model Context Protocol server over stdio for AI clients.
- **Offline help.** The package includes compiled MAML XML help in `SnipeitPS/en-US/` for `Get-Help`.

---

## Installation

Install the module from the [PowerShell Gallery](https://www.powershellgallery.com/packages/SnipeitPS):

```powershell
Install-Module -Name SnipeitPS -Scope CurrentUser
```

Or import the module from a local clone:

```powershell
Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force
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
# Press Tab to resolve names to IDs
New-SnipeitAsset -name "Workstation-01" -model_id <TAB> -status_id <TAB>

# Clear cache after adding items in the web UI
Clear-SnipeitCache
```

### 4. Pipelines and bulk edits

```powershell
# Update all assets checked out to a user
Get-SnipeitUser -email "jsmith@example.com" | Get-SnipeitAsset | Update-SnipeitAssetBulk -notes "Verified in 2026 audit"

# Preview a bulk delete with -WhatIf
Get-SnipeitAsset -status "Archived" | Remove-SnipeitAssetBulk -WhatIf
```

### 5. Desired state sync

```powershell
# Create the asset if missing, or update only fields that differ
Sync-SnipeitAsset -asset_tag "SRV-01" -name "Core Router" -model_id 12 -status_id 1 -Ensure Present
```

---

## Building documentation

Rebuild the Markdown command docs and recompile MAML XML help with platyPS:

```powershell
./build-docs.ps1 -UpdateMarkdown
```

---

## Running tests

Run the Pester test suite:

```powershell
./run-tests.ps1
```

---

## License

MIT
