<#
.SYNOPSIS
Set properties of a Snipe-IT Asset Maintenance

.PARAMETER id
An ID of a specific Asset Maintenance

.PARAMETER asset_id
ID of the asset

.PARAMETER supplier_id
ID of the supplier

.PARAMETER asset_maintenance_type
Type of maintenance

.PARAMETER title
Title of maintenance

.PARAMETER start_date
Start date of maintenance

.PARAMETER completion_date
Completion date of maintenance

.PARAMETER is_warranty
Whether maintenance is under warranty

.PARAMETER cost
Cost of maintenance

.PARAMETER notes
Notes about the maintenance

.PARAMETER RequestType
HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

.PARAMETER url
Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipe-IT system.

.PARAMETER apiKey
Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipe-IT.

.EXAMPLE
Set-SnipeitAssetMaintenance -id 1 -title "Updated maintenance"

#>

function Set-SnipeitAssetMaintenance() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    Param(
        [parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [int]$asset_id,

        [int]$supplier_id,

        [string]$asset_maintenance_type,

        [string]$title,

        [datetime]$start_date,

        [datetime]$completion_date,

        [bool]$is_warranty,

        [decimal]$cost,

        [string]$notes,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

        $Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        if ($Values['start_date']) {
            $Values['start_date'] = $Values['start_date'].ToString("yyyy-MM-dd")
        }

        if ($Values['completion_date']) {
            $Values['completion_date'] = $Values['completion_date'].ToString("yyyy-MM-dd")
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
        foreach($maintenance_id in $id) {
            $Parameters = @{
                Api           = "/api/v1/maintenances/$maintenance_id"
                Method        = $RequestType
                Body          = $Values
            }

            if ($PSCmdlet.ShouldProcess("ShouldProcess?")) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
        # reset legacy sessions
        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url -or $PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Reset-SnipeitPSLegacyApi
        }
    }
}
