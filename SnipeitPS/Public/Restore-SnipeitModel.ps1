<#
.SYNOPSIS
Restores soft-deleted asset models.
.DESCRIPTION
Posts an empty body to /api/v1/models/{id}/restore for each ID. Requires model
delete permission. Not-deleted, missing-model, and restore failures can arrive
as HTTP 200 domain errors and remain on the error stream.
.PARAMETER id
Positive model IDs. Accepts pipeline properties named id or model_id.
.PARAMETER Session
Optional custom SnipeitSession instance.
.EXAMPLE
Restore-SnipeitModel -id 7 -WhatIf
#>
function Restore-SnipeitModel {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('model_id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$id,
        [SnipeitSession]$Session
    )

    process {
        foreach ($modelId in $id) {
            if ($PSCmdlet.ShouldProcess("Model ID $modelId", 'Restore')) {
                Invoke-SnipeitMethod -Route "$script:SnipeitApiPrefix/models/$modelId/restore" -Method Post -Body @{} -Session $Session
            }
        }
    }
}
