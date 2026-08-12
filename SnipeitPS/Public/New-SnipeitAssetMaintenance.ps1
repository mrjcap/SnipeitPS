<#
.SYNOPSIS
Add a new Asset maintenance to Snipe-IT asset system

.DESCRIPTION
Add a new Asset maintenance to Snipe-IT asset system


.PARAMETER asset_id
Required ID of the asset, this can be obtained using Get-SnipeitAsset

.PARAMETER supplier_id
Required maintenance supplier

.PARAMETER asset_maintenance_type
Type of maintenance. Built-in types include Maintenance, Repair, Upgrade, PAT, and Hardware Support.
Custom types created in the Snipe-IT GUI are also accepted.

.PARAMETER title
Required Title of maintenance

.PARAMETER start_date
Required start date

.PARAMETER is_warranty
Optional Maintenance done under warranty

.PARAMETER cost
Optional cost

.PARAMETER completion_date
Optional completion date

.PARAMETER notes
Optional notes

.PARAMETER url
Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipe-IT system.

.PARAMETER apiKey
Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipe-IT.

.EXAMPLE
New-SnipeitAssetMaintenance -asset_id 1 -supplier_id 1 -asset_maintenance_type "Maintenance" -title "replace keyboard" -start_date "2021-01-01"
#>
function New-SnipeitAssetMaintenance() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]

    Param(
        [parameter(mandatory = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$asset_id,

        [parameter(mandatory = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$supplier_id,

        [parameter(mandatory = $true)]
        [string]$asset_maintenance_type,

        [parameter(mandatory = $true)]
        [string]$title,

        [parameter(mandatory = $true)]
        [datetime]$start_date,

        [parameter(mandatory = $false)]
        [Alias('completion_date')]
        [datetime]$expected_completion_date,

        [bool]$is_warranty = $false,

        [decimal]$cost,

        [string]$notes,

        [parameter(mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$assigned_to,

        [parameter(mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [Alias('responsible_party')]
        [int]$responsible_party_id,

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

        if ($Values['completion_date'] -and -not $Values['expected_completion_date']) {
            $Values['expected_completion_date'] = $Values['completion_date']
        }
        if ($Values['expected_completion_date']) {
            $Values['expected_completion_date'] = $Values['expected_completion_date'].ToString("yyyy-MM-dd")
            $Values.Remove('completion_date')
        }


        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/maintenances"
            Method = 'Post'
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
        if ($PSCmdlet.ShouldProcess("Asset ID $asset_id", $MyInvocation.MyCommand.Name)) {
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
