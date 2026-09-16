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
Existing numeric maintenance type ID or exact unique catalog name.
Names, including built-in types, are resolved through the server's maintenance-types catalog.

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

.PARAMETER assigned_to
Unsupported legacy input, rejected before HTTP. No automatic relationship mapping is possible.

.PARAMETER responsible_party_id
Nullable ID of the User responsible for maintenance, not the asset checkout snapshot.

The checkout snapshot is captured automatically by the server when maintenance is created.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
New-SnipeitAssetMaintenance -asset_id 1 -supplier_id 1 -asset_maintenance_type "Maintenance" -title "replace keyboard" -start_date "2021-01-01"
#>
function New-SnipeitAssetMaintenance() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([PSCustomObject])]

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
        [Nullable[int]]$assigned_to,

        [parameter(mandatory = $false)]
        [Alias('responsible_party')]
        [Nullable[int]]$responsible_party_id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )
    begin {
        if ($null -ne $responsible_party_id -and $responsible_party_id -lt 1) { throw 'responsible_party_id must be positive or null.' }
        if ($PSBoundParameters.ContainsKey('assigned_to')) {
            throw 'assigned_to is unsupported and was ignored by the server. Use responsible_party_id only for the responsible User; use Set-SnipeitAssetMaintenance checked_out_to_id/type only to edit the separate checkout snapshot. These relationships are not equivalent.'
        }
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
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

        if ($Values['title']) {
            $Values['name'] = $Values['title']
        }
        $Values.Remove('asset_maintenance_type')


        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/maintenances"
            Method = 'Post'
            Session = $Session
            Body   = $Values
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("Asset ID $asset_id", $MyInvocation.MyCommand.Name)) {
            $Values['maintenance_type_id'] = Resolve-SnipeitMaintenanceTypeId -Name $asset_maintenance_type -Session $Session
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
