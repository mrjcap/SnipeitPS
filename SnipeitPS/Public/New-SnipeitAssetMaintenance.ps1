<#
.SYNOPSIS
Add a new Asset maintenance to Snipe-IT asset system

.DESCRIPTION
Creates a single asset maintenance or performs bulk asset maintenance creation for multiple assets.
Bulk creation returns a collection payload containing total count and created rows.
Partial success is supported: successfully created rows are returned even if some requested assets fail.

.PARAMETER asset_id
Required ID of the asset for single creation. Mutually exclusive with asset_ids.

.PARAMETER asset_ids
Array of positive asset IDs for bulk creation. Mutually exclusive with asset_id.

.PARAMETER supplier_id
Optional positive supplier ID. Pass null to leave the supplier unset.

.PARAMETER asset_maintenance_type
Existing numeric maintenance type ID or exact unique catalog name.
Names, including built-in types, are resolved through the server's maintenance-types catalog.

.PARAMETER title
Required title/name of maintenance.

.PARAMETER start_date
Required start date.

.PARAMETER expected_completion_date
Optional expected completion date. Accepts null; completion_date is a legacy alias.

.PARAMETER is_warranty
Optional maintenance done under warranty flag. Defaults to false.

.PARAMETER cost
Optional nullable cost. The server normalizes zero to null.

.PARAMETER url
Optional related URL, up to 255 characters. An empty value clears the URL.

.PARAMETER completed_at
Nullable actual completion timestamp. Must fall between start_date and the server's current time.

.PARAMETER completed_by
Nullable positive ID of the user who completed the maintenance.

.PARAMETER asset_maintenance_time
Nullable recorded maintenance duration in days. Zero is preserved in the request.

.PARAMETER image
Path to an image to upload when creating maintenance for one asset.
Bulk creation rejects images because the shared multipart transport does not preserve the asset ID array.

.PARAMETER notes
Optional notes.

.PARAMETER assigned_to
Unsupported legacy input, rejected before HTTP. No automatic relationship mapping is possible.

.PARAMETER responsible_party_id
Nullable ID of the User responsible for maintenance, not the asset checkout snapshot.
The checkout snapshot is captured automatically by the server when maintenance is created.

.PARAMETER preserveResponse
When specified, preserves the complete response envelope instead of extracting the payload.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
New-SnipeitAssetMaintenance -asset_id 1 -supplier_id 1 -asset_maintenance_type "Maintenance" -title "replace keyboard" -start_date "2021-01-01"

.EXAMPLE
New-SnipeitAssetMaintenance -asset_ids 1,2,3 -supplier_id 1 -asset_maintenance_type "Maintenance" -title "Annual inspection" -start_date "2026-03-01"
#>
function New-SnipeitAssetMaintenance {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low",
        DefaultParameterSetName = 'ByAssetId'
    )]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'ByAssetId', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$asset_id,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByAssetIds')]
        [ValidateNotNullOrEmpty()]
        [int[]]$asset_ids,

        [Parameter(Mandatory = $false, Position = 1)]
        [Nullable[int]]$supplier_id,

        [Parameter(Mandatory = $true, Position = 2)]
        [string]$asset_maintenance_type,

        [Parameter(Mandatory = $true, Position = 3)]
        [string]$title,

        [Parameter(Mandatory = $true, Position = 4)]
        [datetime]$start_date,

        [Parameter(Mandatory = $false, Position = 5)]
        [Alias('completion_date')]
        [Nullable[datetime]]$expected_completion_date,

        [Parameter(Mandatory = $false, Position = 6)]
        [bool]$is_warranty = $false,

        [Parameter(Mandatory = $false, Position = 7)]
        [Nullable[decimal]]$cost,

        [Parameter(Mandatory = $false)]
        [ValidateLength(0, 255)]
        [string]$url,

        [Parameter(Mandatory = $false)]
        [Nullable[datetime]]$completed_at,

        [Parameter(Mandatory = $false)]
        [Nullable[int]]$completed_by,

        [Parameter(Mandatory = $false)]
        [Nullable[int]]$asset_maintenance_time,

        [Parameter(Mandatory = $false)]
        [string]$image,

        [Parameter(Mandatory = $false, Position = 8)]
        [string]$notes,

        [Parameter(Mandatory = $false, Position = 9)]
        [Nullable[int]]$assigned_to,

        [Parameter(Mandatory = $false, Position = 10)]
        [Alias('responsible_party')]
        [Nullable[int]]$responsible_party_id,

        [Parameter(Mandatory = $false)]
        [switch]$preserveResponse,

        [Parameter(Mandatory = $false, Position = 11)]
        [SnipeitSession]$Session
    )

    begin {
        foreach ($field in @('supplier_id', 'completed_by')) {
            if ($null -ne $PSBoundParameters[$field] -and $PSBoundParameters[$field] -lt 1) {
                throw "$field must be positive or null."
            }
        }
        if ($null -ne $responsible_party_id -and $responsible_party_id -lt 1) {
            throw 'responsible_party_id must be positive or null.'
        }
        if ($PSBoundParameters.ContainsKey('assigned_to')) {
            throw 'assigned_to is unsupported and was ignored by the server. Use responsible_party_id only for the responsible User; use Set-SnipeitAssetMaintenance checked_out_to_id/type only to edit the separate checkout snapshot. These relationships are not equivalent.'
        }
        if ($PSCmdlet.ParameterSetName -eq 'ByAssetIds') {
            if ($PSBoundParameters.ContainsKey('image')) {
                throw 'Bulk maintenance images are unsupported: use single-asset creation to preserve image and asset ID transport.'
            }
            if ($null -eq $asset_ids -or $asset_ids.Length -eq 0 -or ($asset_ids | Where-Object { $_ -lt 1 })) {
                throw 'asset_ids must contain only positive integers.'
            }
        }
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $targetDesc = if ($PSCmdlet.ParameterSetName -eq 'ByAssetIds') {
            "Asset IDs $($asset_ids -join ',')"
        } else {
            "Asset ID $asset_id"
        }

        if ($PSCmdlet.ShouldProcess($targetDesc, $MyInvocation.MyCommand.Name)) {
            $Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

            if ($PSCmdlet.ParameterSetName -eq 'ByAssetIds') {
                $Values['asset_ids'] = $asset_ids
                $Values.Remove('asset_id')
            } else {
                $Values['asset_id'] = $asset_id
            }

            if ($Values.ContainsKey('start_date') -and $Values['start_date']) {
                $Values['start_date'] = $Values['start_date'].ToString("yyyy-MM-dd")
            }

            if ($null -ne $expected_completion_date) {
                $Values['expected_completion_date'] = $expected_completion_date.ToString('yyyy-MM-dd')
            }
            if ($null -ne $completed_at) {
                $Values['completed_at'] = $completed_at.ToString('yyyy-MM-dd HH:mm:ss', [Globalization.CultureInfo]::InvariantCulture)
            }
            if ($PSBoundParameters.ContainsKey('url')) { $Values['url'] = $url }

            $Values['name'] = $title
            $Values.Remove('asset_maintenance_type')
            $Values.Remove('preserveResponse')
            $Values.Remove('Confirm')
            $Values.Remove('WhatIf')

            $Values['maintenance_type_id'] = Resolve-SnipeitMaintenanceTypeId -Name $asset_maintenance_type -Session $Session

            $Parameters = @{
                Api              = "$script:SnipeitApiPrefix/maintenances"
                Method           = 'Post'
                Session          = $Session
                Body             = $Values
                PreserveResponse = [bool]$preserveResponse
            }

            $result = Invoke-SnipeitMethod @Parameters
            if ($result -and $result.PSObject.Properties['rows'] -and $result.rows) {
                foreach ($r in $result.rows) {
                    if ($r -is [System.Management.Automation.PSObject] -and -not $r.PSObject.TypeNames.Contains('SnipeitPS.AssetMaintenance')) {
                        $r.PSObject.TypeNames.Insert(0, 'SnipeitPS.AssetMaintenance')
                    }
                }
            }
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
