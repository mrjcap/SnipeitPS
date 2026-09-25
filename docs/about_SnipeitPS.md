# About SnipeitPS

## about_SnipeitPS

## SHORT DESCRIPTION

PowerShell module for managing Snipe-IT assets, users, licenses, and inventory through the REST API.

## LONG DESCRIPTION

SnipeitPS wraps the Snipe-IT API with PowerShell cmdlets for assets, users, licenses, accessories, components,
consumables, and fieldsets.

### FEATURES

- Tab completion for models, categories, statuses, locations, companies, suppliers, and departments with 5-minute memory
caching.
- Table formatting using PSTypeName tags on output objects.
- Pipeline parameter binding by property name across commands.
- Bulk updates and deletes through Snipe-IT batch endpoints.
- Idempotent asset sync with Sync-SnipeitAsset.
- Multi-tenant connections using [SnipeitSession] and -Session.
- Stdio Model Context Protocol (MCP) server for AI assistants.

## EXAMPLES

### 1. Connecting

```powershell
Connect-SnipeitPS -url "https://inventory.example.com" -apiKey "your-token"
```

### 2. Multi-tenant sessions

```powershell
$dev = [SnipeitSession]::new("https://dev.snipeit.local", $devKey)
$prod = [SnipeitSession]::new("https://prod.snipeit.local", $prodKey)

Get-SnipeitAsset -Session $dev -limit 10
Get-SnipeitAsset -Session $prod -limit 10
```

### 3. Tab completion

```powershell
New-SnipeitAsset -name "MacBook-01" -model_id 1 -status_id 1

Clear-SnipeitCache
```

### 4. Pipelines and bulk operations

```powershell
Get-SnipeitUser -email "jsmith@example.com" | Get-SnipeitAsset | Update-SnipeitAssetBulk -status_id 2 -notes "Assigned in Q3"
```

### 5. Desired state sync

```powershell
Sync-SnipeitAsset -asset_tag "SRV-01" -name "Core Switch" -model_id 12 -status_id 1 -Ensure Present
```

## NOTE

State-changing commands support -WhatIf and -Confirm.

## SEE ALSO

- [GitHub Repository](https://github.com/mrjcap/SnipeitPS)
- [Snipe-IT Documentation](https://snipe-it.readme.io/reference)

## KEYWORDS

- Snipe-IT
- ITAM
- Asset Management
- Inventory
- PlatyPS
