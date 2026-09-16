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
Existing numeric maintenance type ID or exact unique catalog name. Omit to preserve the current type.
Names are resolved through the server's maintenance-types catalog.

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

.PARAMETER assigned_to
Unsupported legacy input, rejected before HTTP. No automatic relationship mapping is possible.

.PARAMETER responsible_party_id
Nullable ID of the User responsible for maintenance, not the asset checkout snapshot.

.PARAMETER checked_out_to_id
Checkout snapshot ID, not the responsible user. Supply with checked_out_to_type, or both null to clear.

.PARAMETER checked_out_to_type
Checkout snapshot entity type: User, Asset or Location. This does not check out the underlying asset.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Set-SnipeitAssetMaintenance -id 1 -title "Updated maintenance"

#>

function Set-SnipeitAssetMaintenance() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$asset_id,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$supplier_id,

        [string]$asset_maintenance_type,

        [string]$title,

        [datetime]$start_date,

        [Alias('completion_date')]
        [datetime]$expected_completion_date,

        [Nullable[bool]]$is_warranty,

        [decimal]$cost,

        [string]$notes,

        [Nullable[System.Int32]]$assigned_to,

        [Nullable[int]]$checked_out_to_id,

        [AllowNull()]
        [string]$checked_out_to_type,

        [Alias('responsible_party')]
        [Nullable[System.Int32]]$responsible_party_id,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        if ($null -ne $responsible_party_id -and $responsible_party_id -lt 1) { throw 'responsible_party_id must be positive or null.' }
        if ($PSBoundParameters.ContainsKey('assigned_to')) {
            throw 'assigned_to is unsupported and was ignored by the server. Use responsible_party_id only for the responsible User; use Set-SnipeitAssetMaintenance checked_out_to_id/type only to edit the separate checkout snapshot. These relationships are not equivalent.'
        }
        $hasSnapshotId = $PSBoundParameters.ContainsKey('checked_out_to_id')
        $hasSnapshotType = $PSBoundParameters.ContainsKey('checked_out_to_type')
        if ($hasSnapshotId -ne $hasSnapshotType) {
            throw 'Supply checked_out_to_id and checked_out_to_type together, or both null to clear.'
        }
        if ($hasSnapshotId) {
            $snapshotType = $PSBoundParameters['checked_out_to_type']
            if ([string]::IsNullOrEmpty($snapshotType)) { $snapshotType = $null }
            if (($null -eq $checked_out_to_id) -ne ($null -eq $snapshotType)) {
                throw 'Supply both checked_out_to_id and checked_out_to_type as values or both null.'
            }
            if ($null -ne $checked_out_to_id -and ($checked_out_to_id -lt 1 -or $snapshotType -notin @('User', 'Asset', 'Location'))) {
                throw 'checked_out_to_id must be positive and checked_out_to_type must be User, Asset or Location.'
            }
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
        if ($hasSnapshotId -and $null -eq $checked_out_to_id) { $Values['checked_out_to_type'] = $null }
        if ($hasSnapshotId -and $null -ne $checked_out_to_id) {
            $canonicalType = @{ user = 'User'; asset = 'Asset'; location = 'Location' }[$snapshotType]
            $Values['checked_out_to_type'] = "App\Models\$canonicalType"
        }
    }

    process {
        foreach($maintenance_id in $id) {
            $Parameters = @{
                Api           = "$script:SnipeitApiPrefix/maintenances/$maintenance_id"
                Method        = $RequestType
                Session = $Session
                Body          = $Values
            }

            if ($PSCmdlet.ShouldProcess("Maintenance ID $maintenance_id", $MyInvocation.MyCommand.Name)) {
                if ($PSBoundParameters.ContainsKey('asset_maintenance_type')) {
                    $Values['maintenance_type_id'] = Resolve-SnipeitMaintenanceTypeId -Name $asset_maintenance_type -Session $Session
                }
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
