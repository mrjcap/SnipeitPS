<#
.SYNOPSIS
Lists dashboard activity in descending creation order.
.DESCRIPTION
Queries GET /api/v1/dashboard/activity. Results respect server permissions and company scoping.
The server fixes ordering to created_at descending. This endpoint does not
accept report activity filters, date ranges, or sort controls.
Use PreserveResponse for the unmodified response envelope. It takes precedence over all.
.PARAMETER search
Server-side activity search text.
.PARAMETER limit
Records per page, from 1 to 500. Defaults to 25.
.PARAMETER offset
Nonnegative row offset.
.PARAMETER all
Streams rows across pages until the total is reached or an empty page is returned.
.PARAMETER PreserveResponse
Returns the first complete response without row normalization.
.PARAMETER Session
Optional custom SnipeitSession instance.
.EXAMPLE
Get-SnipeitDashboardActivity -Session $session
#>
function Get-SnipeitDashboardActivity {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [string]$search,
        [ValidateRange(1, 500)]
        [int]$limit = 25,
        [ValidateRange(0, [int]::MaxValue)]
        [int]$offset = 0,
        [switch]$all,
        [switch]$PreserveResponse,
        [SnipeitSession]$Session
    )

    process {
        $query = @{ limit = $limit; offset = $offset }

        if ($PSBoundParameters.ContainsKey('search')) { $query['search'] = $search }
        Invoke-SnipeitMethod -Route "$script:SnipeitApiPrefix/dashboard/activity" -Method Get -GetParameters $query -Session $Session -Paginate:$all -PreserveResponse:$PreserveResponse
    }
}
