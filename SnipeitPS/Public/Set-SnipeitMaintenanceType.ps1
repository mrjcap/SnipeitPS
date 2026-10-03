<#
.SYNOPSIS
Renames a maintenance type without clearing its existing color.

.DESCRIPTION
Patches /api/v1/maintenance-types/{id}. Omission of tag_color triggers a GET
inside ShouldProcess to preserve each type's color. The lookup must return
exactly one matching ID or the command stops before PATCH. Explicit tag_color
avoids the GET. WhatIf performs neither request. The read and write are not
atomic; preserving color also requires view permission.

.PARAMETER id
Positive maintenance-type ID or array of IDs.

.PARAMETER name
New maintenance-type name.

.PARAMETER tag_color
Explicit color, empty string or null. When omitted, reads the current color before
PATCH. The lookup requires view permission. Missing color on a historical response
keeps the historical name-only request. GET/PATCH is not an atomic operation.

.PARAMETER Session
Optional custom SnipeitSession instance.

.EXAMPLE
Set-SnipeitMaintenanceType -id 2 -name 'Inspection'
#>
function Set-SnipeitMaintenanceType {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$id,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ -not [string]::IsNullOrWhiteSpace($_) })]
        [string]$name,

        [SnipeitSession]$Session,
        [AllowNull()]
        [AllowEmptyString()]
        [object]$tag_color
    )
    process {
        if ($null -ne $tag_color -and $tag_color -isnot [string]) {
            throw [ArgumentException]::new('tag_color must be a string or null.', 'tag_color')
        }
        foreach ($itemId in $id) {
            if (-not $PSCmdlet.ShouldProcess("maintenance-types/$itemId", $MyInvocation.MyCommand.Name)) { continue }
            $body = @{ name = $name }
            if ($PSBoundParameters.ContainsKey('tag_color')) {
                $body['tag_color'] = $PSBoundParameters['tag_color']
            } else {
                $rows = @(Invoke-SnipeitMethod -Api "$script:SnipeitApiPrefix/maintenance-types/$itemId" -Method GET -Session $Session -ErrorAction Stop)
                $currentId = 0L
                if ($rows.Count -ne 1 -or -not [long]::TryParse([string]$rows[0].id, [ref]$currentId) -or $currentId -ne $itemId) {
                    throw [InvalidOperationException]::new("Cannot preserve maintenance-type color: lookup did not return exactly ID $itemId.")
                }
                $row = $rows[0]
                $hasColor = if ($row -is [Collections.IDictionary]) { $row.Contains('tag_color') } else { $null -ne $row.PSObject.Properties['tag_color'] }
                if ($hasColor) {
                    $color = $row.tag_color
                    if ($null -ne $color -and $color -isnot [string]) {
                        throw [InvalidOperationException]::new('Cannot preserve maintenance-type color: expected a string or null.')
                    }
                    $body['tag_color'] = if ($null -eq $color) { $null } else { [Net.WebUtility]::HtmlDecode($color) }
                }
            }
            Invoke-SnipeitMethod -Api "$script:SnipeitApiPrefix/maintenance-types/$itemId" -Method PATCH -Body $body -Session $Session
        }
    }
}
