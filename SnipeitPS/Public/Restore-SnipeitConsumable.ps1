<#
.SYNOPSIS
Restores soft-deleted consumables or clears their archive flag.
.DESCRIPTION
By default, posts an empty JSON object to /api/v1/consumables/{id}/restore.
Restore requires delete permission. Use Unarchive to post to
/api/v1/consumables/{id}/unarchive instead; this requires update permission.
Restoring a soft-deleted item does not clear its archive flag. Unarchive does
not restore soft-deleted items. Server errors remain on the error stream;
use ErrorAction Stop to terminate on an error.
.PARAMETER id
Positive consumable inventory IDs. Accepts pipeline properties named id or consumable_id.
.PARAMETER Session
Optional custom SnipeitSession instance.
.PARAMETER Unarchive
Clear the archive flag instead of restoring a soft-deleted item.
Omit this switch or pass false to use restore.
.EXAMPLE
Restore-SnipeitConsumable -id 7 -WhatIf
.EXAMPLE
Restore-SnipeitConsumable -id 7 -Unarchive -WhatIf
#>
function Restore-SnipeitConsumable {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('consumable_id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$id,
        [SnipeitSession]$Session,
        [switch]$Unarchive
    )

    process {
        $action = if ($Unarchive) { 'Unarchive' } else { 'Restore' }
        $operation = $action.ToLowerInvariant()
        foreach ($itemId in $id) {
            if ($PSCmdlet.ShouldProcess("Consumable ID $itemId", $action)) {
                Invoke-SnipeitMethod -Route "$script:SnipeitApiPrefix/consumables/$itemId/$operation" -Method Post -Body @{} -Session $Session
            }
        }
    }
}
