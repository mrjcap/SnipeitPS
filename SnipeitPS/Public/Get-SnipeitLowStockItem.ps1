<#
.SYNOPSIS
Lists permission-scoped low-stock items using the server alert settings.
.DESCRIPTION
Queries GET /api/v1/low-stock. Results respect server permissions and company scoping.
The server uses its configured alert threshold and current checkouts to select
low-stock rows. No threshold override is available. Row id is a composite key
such as consumable-5; item.id is the inventory ID. Do not use the row id as an
inventory mutation ID. Models and licenses cannot use quantity adjustment.
Use PreserveResponse for the unmodified response envelope. It takes precedence over all.
.PARAMETER search
Filters item names.
.PARAMETER sort
Sort column. Defaults to remaining. Also accepts name, type, qty, min_amt, or percent.
.PARAMETER order
Sort direction. Defaults to asc.
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
Get-SnipeitLowStockItem -Session $session
#>
function Get-SnipeitLowStockItem {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [string]$search,
        [ValidateSet('name', 'type', 'qty', 'min_amt', 'remaining', 'percent')]
        [string]$sort = 'remaining',
        [ValidateSet('asc', 'desc')]
        [string]$order = 'asc',
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

        $query['sort'] = $sort
        $query['order'] = $order
        if ($PSBoundParameters.ContainsKey('search')) { $query['search'] = $search }
        Invoke-SnipeitMethod -Route "$script:SnipeitApiPrefix/low-stock" -Method Get -GetParameters $query -Session $Session -Paginate:$all -PreserveResponse:$PreserveResponse
    }
}
