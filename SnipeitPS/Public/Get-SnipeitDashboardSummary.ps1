<#
.SYNOPSIS
Lists permission-scoped dashboard category, company, or location summaries.
.DESCRIPTION
Queries GET /api/v1/dashboard/categories, /companies, or /locations.
Counts depend on view permissions. Missing counts remain absent, not zero.
For locations, assets_count and assigned_assets_count are separate counts.
Rows have dashboard summary types, not full resource types.
Use PreserveResponse for the unmodified response envelope. It takes precedence over all.
.PARAMETER By
Selects Category, Company, or Location summaries.
.PARAMETER sort
Column to sort by. Defaults to name. The server falls back to name for invalid
or unauthorized count columns. Categories also support category_type.
.PARAMETER order
Sort direction. Defaults to desc.
.PARAMETER limit
Records per page, from 1 to 50. Defaults to 25.
.PARAMETER offset
Nonnegative row offset.
.PARAMETER all
Streams rows across pages until the total is reached or an empty page is returned.
.PARAMETER PreserveResponse
Returns the first complete response without row normalization.
.PARAMETER Session
Optional custom SnipeitSession instance.
.EXAMPLE
Get-SnipeitDashboardSummary -By Location -Session $session
#>
function Get-SnipeitDashboardSummary {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Category', 'Company', 'Location')]
        [string]$By,
        [string]$sort = 'name',
        [ValidateSet('asc', 'desc')]
        [string]$order = 'desc',
        [ValidateRange(1, 50)]
        [int]$limit = 25,
        [ValidateRange(0, [int]::MaxValue)]
        [int]$offset = 0,
        [switch]$all,
        [switch]$PreserveResponse,
        [SnipeitSession]$Session
    )

    process {
        $query = @{ limit = $limit; offset = $offset }
        $leaf = @{ Category = 'categories'; Company = 'companies'; Location = 'locations' }[$By]
        $query['sort'] = $sort
        $query['order'] = $order
        Invoke-SnipeitMethod -Route "$script:SnipeitApiPrefix/dashboard/$leaf" -Method Get -GetParameters $query -Session $Session -Paginate:$all -PreserveResponse:$PreserveResponse
    }
}
