<#
.SYNOPSIS
Restores soft-deleted accessories or clears their archive flag.
.DESCRIPTION
By default, posts an empty JSON object to /api/v1/accessories/{id}/restore.
Restore requires delete permission. Use Unarchive to post to
/api/v1/accessories/{id}/unarchive instead; this requires update permission.
Restoring a soft-deleted item does not clear its archive flag. Unarchive does
not restore soft-deleted items. Server errors remain on the error stream;
use ErrorAction Stop to terminate on an error.
.PARAMETER id
Positive accessory inventory IDs. Accepts pipeline properties named id or accessory_id.
For pipeline input, accessory_id takes precedence over id. An explicit id is used as supplied.
.PARAMETER Session
Optional custom SnipeitSession instance.
.PARAMETER Unarchive
Clear the archive flag instead of restoring a soft-deleted item.
Omit this switch or pass false to use restore.
.EXAMPLE
Restore-SnipeitAccessory -id 7 -WhatIf
.EXAMPLE
Restore-SnipeitAccessory -id 7 -Unarchive -WhatIf
#>
function Restore-SnipeitAccessory {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('accessory_id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$id,
        [SnipeitSession]$Session,
        [switch]$Unarchive
    )

    begin { $explicitId = $PSBoundParameters.ContainsKey('id') }

    process {
        $targetIds = $id
        if (-not $explicitId -and $null -ne $PSItem) {
            $inventoryId = $PSItem.PSObject.Properties['accessory_id']
            if ($null -ne $inventoryId) {
                try {
                    [ValidateNotNullOrEmpty()][ValidateRange(1, [int]::MaxValue)][int[]]$targetIds = $inventoryId.Value
                } catch { throw 'Pipeline accessory_id must contain positive inventory IDs.' }
            } elseif ($PSItem.PSObject.Properties['accessory'] -or $PSItem.PSObject.Properties['checkout_id']) {
                throw 'Assignment rows require a valid accessory_id; supply an inventory -id explicitly.'
            }
        }
        $action = if ($Unarchive) { 'Unarchive' } else { 'Restore' }
        $operation = $action.ToLowerInvariant()
        foreach ($itemId in $targetIds) {
            if ($PSCmdlet.ShouldProcess("Accessory ID $itemId", $action)) {
                Invoke-SnipeitMethod -Route "$script:SnipeitApiPrefix/accessories/$itemId/$operation" -Method Post -Body @{} -Session $Session
            }
        }
    }
}
