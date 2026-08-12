<#
    .SYNOPSIS
    Audit an asset by ID in Snipe-IT

    .PARAMETER id
    Unique ID of the asset to audit

    .PARAMETER location_id
    ID of the location to associate with the audit

    .PARAMETER next_audit_date
    Due date for the asset's next audit

    .PARAMETER url
    Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipe-IT system.

    .PARAMETER apiKey
    Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipe-IT.

    .EXAMPLE
    Update-SnipeitAssetAudit -id 1 -location_id 5
#>
function Update-SnipeitAssetAudit() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]

    Param(
        [parameter(mandatory = $false)]
        [int]$id,

        [parameter(mandatory = $false)]
        [string]$asset_tag,

        [parameter(mandatory = $false)]
        [string]$serial,

        [int]$location_id,

        [parameter(mandatory = $false)]
        [datetime]$next_audit_date,

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

        if (-not $id -and -not $asset_tag -and -not $serial) {
            throw "Must specify -id, -asset_tag, or -serial for audit."
        }

        $Values = @{}

        if ($PSBoundParameters.ContainsKey('asset_tag')) {
            $Values += @{"asset_tag" = $asset_tag}
        }

        if ($PSBoundParameters.ContainsKey('serial')) {
            $Values += @{"serial" = $serial}
        }

        if ($PSBoundParameters.ContainsKey('location_id')) {
            $Values += @{"location_id" = $location_id}
        }

        if ($PSBoundParameters.ContainsKey('next_audit_date')) {
            $Values += @{"next_audit_date" = ($next_audit_date).ToString("yyyy-MM-dd")}
        }

        $ApiEndpoint = if ($id) { "$script:SnipeitApiPrefix/hardware/$id/audit" } else { "$script:SnipeitApiPrefix/hardware/audit" }

        $Parameters = @{
            Api    = $ApiEndpoint
            Method = 'POST'
            Body   = $Values
        }

        if ($PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Write-Warning "-apiKey parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyApiKey -apiKey $apiKey
        }

        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url) {
            Write-Warning "-url parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyUrl -url $url
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("Asset ID $id", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
        # reset legacy sessions
        if (($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url) -or ($PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey)) {
            Reset-SnipeitPSLegacyApi
        }
    }
}
