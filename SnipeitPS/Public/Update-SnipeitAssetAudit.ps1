<#
    .SYNOPSIS
    Audit an asset by ID in Snipe-it

    .PARAMETER id
    Unique ID of the asset to audit

    .PARAMETER location_id
    ID of the location to associate with the audit

    .PARAMETER next_audit_date
    Due date for the asset's next audit

    .PARAMETER url
    Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipeit system.

    .PARAMETER apiKey
    Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipeit.

    .EXAMPLE
    Update-SnipeitAssetAudit -id 1 -location_id 5
#>
function Update-SnipeitAssetAudit() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]

    Param(
        [parameter(mandatory = $true)]
        [int]$id,

        [int]$location_id,

        [parameter(mandatory = $false)]
        [datetime]$next_audit_date,

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )

    begin {
        Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

        $Values = @{}

        if ($PSBoundParameters.ContainsKey('location_id')) {
            $Values += @{"location_id" = $location_id}
        }

        if ($PSBoundParameters.ContainsKey('next_audit_date')) {
            $Values += @{"next_audit_date" = ($next_audit_date).ToString("yyyy-MM-dd")}
        }

        $Parameters = @{
            Api    = "/api/v1/hardware/$id/audit"
            Method = 'POST'
            Body   = $Values
        }

        if ($PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Write-Warning "-apiKey parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyApiKey -apiKey $apikey
        }

        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url) {
            Write-Warning "-url parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyUrl -url $url
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("ShouldProcess?")) {
            $result = Invoke-SnipeitMethod @Parameters
        }

        $result
    }

    end {
        # reset legacy sessions
        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url -or $PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Reset-SnipeitPSLegacyApi
        }
    }
}
