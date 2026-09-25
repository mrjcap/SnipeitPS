<#
.SYNOPSIS
Set properties of a Snipe-IT Asset Maintenance

.PARAMETER id
An ID of a specific Asset Maintenance

.PARAMETER asset_id
ID of the asset

.PARAMETER supplier_id
Optional positive supplier ID. Pass null to clear the supplier.

.PARAMETER asset_maintenance_type
Existing numeric maintenance type ID or exact unique catalog name. Omit to preserve the current type.
Names are resolved through the server's maintenance-types catalog.

.PARAMETER title
Title of maintenance

.PARAMETER start_date
Start date of maintenance

.PARAMETER expected_completion_date
Nullable expected completion date. completion_date is a legacy alias.

.PARAMETER is_warranty
Whether maintenance is under warranty

.PARAMETER cost
Nullable cost of maintenance. The server normalizes zero to null.

.PARAMETER url
Related URL, up to 255 characters. An empty value clears the URL.

.PARAMETER completed_at
Nullable actual completion timestamp. Must fall between start_date and the server's current time.

.PARAMETER completed_by
Nullable positive ID of the user who completed the maintenance.

.PARAMETER asset_maintenance_time
Nullable recorded maintenance duration in days. Zero is preserved in the request.

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

        [Nullable[int]]$supplier_id,

        [string]$asset_maintenance_type,

        [string]$title,

        [datetime]$start_date,

        [Alias('completion_date')]
        [Nullable[datetime]]$expected_completion_date,

        [Nullable[bool]]$is_warranty,

        [Nullable[decimal]]$cost,

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
        [SnipeitSession]$Session,

        [ValidateLength(0, 255)]
        [string]$url,

        [Nullable[datetime]]$completed_at,

        [Nullable[int]]$completed_by,

        [Nullable[int]]$asset_maintenance_time
    )

    begin {
        foreach ($field in @('supplier_id', 'completed_by')) {
            if ($null -ne $PSBoundParameters[$field] -and $PSBoundParameters[$field] -lt 1) {
                throw "$field must be positive or null."
            }
        }
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

        if ($null -ne $expected_completion_date) {
            $Values['expected_completion_date'] = $expected_completion_date.ToString('yyyy-MM-dd')
        }
        if ($null -ne $completed_at) {
            $Values['completed_at'] = $completed_at.ToString('yyyy-MM-dd HH:mm:ss', [Globalization.CultureInfo]::InvariantCulture)
        }
        if ($PSBoundParameters.ContainsKey('url')) { $Values['url'] = $url }

        if ($PSBoundParameters.ContainsKey('title')) {
            $Values['name'] = $title
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
