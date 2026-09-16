<#
.SYNOPSIS
Stdio JSON-RPC Model Context Protocol (MCP) server for SnipeitPS.

.DESCRIPTION
Exposes Snipe-IT inventory tools to AI coding agents over standard IO.
#>

param(
    [string]$ModulePath = (Join-Path -Path $PSScriptRoot -ChildPath '..\SnipeitPS\SnipeitPS.psd1')
)

$mcpUrl = $env:SNIPEIT_MCP_URL
$mcpApiKey = $env:SNIPEIT_MCP_API_KEY
if ([string]::IsNullOrWhiteSpace($mcpUrl) -or [string]::IsNullOrWhiteSpace($mcpApiKey)) {
    throw 'SNIPEIT_MCP_URL and SNIPEIT_MCP_API_KEY must be set.'
}

$mcpUri = $null
if (-not [System.Uri]::TryCreate($mcpUrl, [System.UriKind]::Absolute, [ref]$mcpUri) -or $mcpUri.Scheme -ne 'https') {
    throw 'SNIPEIT_MCP_URL must be an absolute HTTPS URL.'
}

Import-Module (Resolve-Path $ModulePath) -Force
$loadedModule = Get-Module -Name 'SnipeitPS' | Select-Object -First 1
$moduleVersion = $loadedModule.Version.ToString()
$writeToolNames = @('snipeit_create_asset', 'snipeit_sync_asset')
$writeToolsEnabled = [string]::Equals($env:SNIPEIT_MCP_ENABLE_WRITES, 'true', [System.StringComparison]::OrdinalIgnoreCase)
$script:mcpConnectionEstablished = $false

function Initialize-McpConnection {
    if (-not $script:mcpConnectionEstablished) {
        Connect-SnipeitPS -url $mcpUrl -apiKey $mcpApiKey
        $script:mcpConnectionEstablished = $true
    }
}

function Send-McpMessage([hashtable]$payload) {
    $json = $payload | ConvertTo-Json -Compress -Depth 10
    [Console]::Out.WriteLine($json)
    [Console]::Out.Flush()
}

$allTools = @(
    @{
        name = "snipeit_get_asset"
        description = "Retrieve assets by ID, asset tag, serial number, or search query."
        inputSchema = @{
            type = "object"
            properties = @{
                id = @{ type = "integer"; description = "Asset ID" }
                asset_tag = @{ type = "string"; description = "Asset tag" }
                serial = @{ type = "string"; description = "Serial number" }
                search = @{ type = "string"; description = "Search query" }
                limit = @{ type = "integer"; description = "Max records to return (default 50)" }
            }
        }
    },
    @{
        name = "snipeit_get_user"
        description = "Retrieve users by username, email, ID, or search query."
        inputSchema = @{
            type = "object"
            properties = @{
                id = @{ type = "integer"; description = "User ID" }
                username = @{ type = "string"; description = "Username" }
                email = @{ type = "string"; description = "Email address" }
                search = @{ type = "string"; description = "Search query" }
            }
        }
    },
    @{
        name = "snipeit_create_asset"
        description = "Create an asset in Snipe-IT."
        inputSchema = @{
            type = "object"
            required = @("status_id", "model_id")
            properties = @{
                status_id = @{ type = "integer"; description = "Status ID" }
                model_id = @{ type = "integer"; description = "Model ID" }
                asset_tag = @{ type = "string"; description = "Asset tag" }
                name = @{ type = "string"; description = "Asset name" }
                serial = @{ type = "string"; description = "Serial number" }
                notes = @{ type = "string"; description = "Notes" }
            }
        }
    },
    @{
        name = "snipeit_sync_asset"
        description = "Reconcile an asset state (Ensure: Present or Absent)."
        inputSchema = @{
            type = "object"
            required = @("asset_tag")
            properties = @{
                asset_tag = @{ type = "string"; description = "Unique asset tag" }
                name = @{ type = "string"; description = "Asset name" }
                model_id = @{ type = "integer"; description = "Model ID" }
                status_id = @{ type = "integer"; description = "Status ID" }
                Ensure = @{ type = "string"; enum = @("Present", "Absent"); description = "Desired state" }
            }
        }
    }
)

$tools = if ($writeToolsEnabled) {
    $allTools
} else {
    @($allTools | Where-Object { $writeToolNames -notcontains $_.name })
}

while ($true) {
    $line = [Console]::In.ReadLine()
    if ($null -eq $line) { break }
    if ([string]::IsNullOrWhiteSpace($line)) { continue }

    try {
        $req = $line | ConvertFrom-Json
    } catch {
        continue
    }

    $id = $req.id
    $method = $req.method
    $params = $req.params

    switch ($method) {
        'initialize' {
            Send-McpMessage @{
                jsonrpc = "2.0"
                id = $id
                result = @{
                    protocolVersion = "2024-11-05"
                    capabilities = @{
                        tools = @{ listChanged = $false }
                    }
                    serverInfo = @{
                        name = "SnipeitPS-MCP-Server"
                        version = $moduleVersion
                    }
                }
            }
        }

        'notifications/initialized' {
            # Client acknowledgment, no reply needed
        }

        'tools/list' {
            Send-McpMessage @{
                jsonrpc = "2.0"
                id = $id
                result = @{
                    tools = $tools
                }
            }
        }

        'tools/call' {
            $toolName = $params.name
            $toolArgs = $params.arguments
            $content = $null
            $isError = $false

            if ($writeToolNames -contains $toolName -and -not $writeToolsEnabled) {
                $isError = $true
                $content = "Mutation tool '$toolName' is disabled. Set SNIPEIT_MCP_ENABLE_WRITES=true to enable it."
            } else {
                try {
                    Initialize-McpConnection

                switch ($toolName) {
                    'snipeit_get_asset' {
                        $p = @{}
                        if ($toolArgs.id) { $p['id'] = [int]$toolArgs.id }
                        if ($toolArgs.asset_tag) { $p['asset_tag'] = [string]$toolArgs.asset_tag }
                        if ($toolArgs.serial) { $p['serial'] = [string]$toolArgs.serial }
                        if ($toolArgs.search) { $p['search'] = [string]$toolArgs.search }
                        if ($toolArgs.limit) { $p['limit'] = [int]$toolArgs.limit }
                        $res = Get-SnipeitAsset @p
                        $content = ($res | ConvertTo-Json -Depth 6)
                    }

                    'snipeit_get_user' {
                        $p = @{}
                        if ($toolArgs.id) { $p['id'] = [int]$toolArgs.id }
                        if ($toolArgs.username) { $p['username'] = [string]$toolArgs.username }
                        if ($toolArgs.email) { $p['email'] = [string]$toolArgs.email }
                        if ($toolArgs.search) { $p['search'] = [string]$toolArgs.search }
                        $res = Get-SnipeitUser @p
                        $content = ($res | ConvertTo-Json -Depth 6)
                    }

                    'snipeit_create_asset' {
                        $p = @{
                            status_id = [int]$toolArgs.status_id
                            model_id = [int]$toolArgs.model_id
                        }
                        if ($toolArgs.asset_tag) { $p['asset_tag'] = [string]$toolArgs.asset_tag }
                        if ($toolArgs.name) { $p['name'] = [string]$toolArgs.name }
                        if ($toolArgs.serial) { $p['serial'] = [string]$toolArgs.serial }
                        if ($toolArgs.notes) { $p['notes'] = [string]$toolArgs.notes }
                        $res = New-SnipeitAsset @p
                        $content = ($res | ConvertTo-Json -Depth 6)
                    }

                    'snipeit_sync_asset' {
                        $p = @{
                            asset_tag = [string]$toolArgs.asset_tag
                        }
                        if ($toolArgs.name) { $p['name'] = [string]$toolArgs.name }
                        if ($toolArgs.model_id) { $p['model_id'] = [int]$toolArgs.model_id }
                        if ($toolArgs.status_id) { $p['status_id'] = [int]$toolArgs.status_id }
                        if ($toolArgs.Ensure) { $p['Ensure'] = [string]$toolArgs.Ensure }
                        $res = Sync-SnipeitAsset @p
                        $content = ($res | ConvertTo-Json -Depth 6)
                    }

                    default {
                        $isError = $true
                        $content = "Unknown tool '$toolName'"
                    }
                }
                } catch {
                    $isError = $true
                    $content = "Execution error: $($_.Exception.Message)"
                }
            }

            Send-McpMessage @{
                jsonrpc = "2.0"
                id = $id
                result = @{
                    content = @(@{ type = "text"; text = if ($null -ne $content) { $content } else { "null" } })
                    isError = $isError
                }
            }
        }

        default {
            Send-McpMessage @{
                jsonrpc = "2.0"
                id = $id
                error = @{
                    code = -32601
                    message = "Method not found: $method"
                }
            }
        }
    }
}
