<#
.SYNOPSIS
Lists assets belonging to an asset model.
.DESCRIPTION
Queries GET /api/v1/models/{model_id}/assets and returns asset rows.
The former /models/assets route is broken and is not used.
Results respect server permissions and company scoping. Search and sorting
are not supported by this endpoint.
Use PreserveResponse for the unmodified response envelope. It takes precedence over all.
.PARAMETER model_id
Positive model ID. Accepts pipeline properties named model_id or id.
.PARAMETER limit
Records per page, from 1 to 500. Defaults to 50.
.PARAMETER offset
Nonnegative row offset.
.PARAMETER all
Streams rows across pages until the total is reached or an empty page is returned.
.PARAMETER PreserveResponse
Returns the first complete response without row normalization.
.PARAMETER Session
Optional custom SnipeitSession instance.
.EXAMPLE
Get-SnipeitModelAsset -model_id 7 -Session $session
#>
function Get-SnipeitModelAsset {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$model_id,
        [ValidateRange(1, 500)]
        [int]$limit = 50,
        [ValidateRange(0, [int]::MaxValue)]
        [int]$offset = 0,
        [switch]$all,
        [switch]$PreserveResponse,
        [SnipeitSession]$Session
    )

    process {
        $query = @{ limit = $limit; offset = $offset }

        Invoke-SnipeitMethod -Route "$script:SnipeitApiPrefix/models/$model_id/assets" -Method Get -GetParameters $query -Session $Session -Paginate:$all -PreserveResponse:$PreserveResponse
    }
}
