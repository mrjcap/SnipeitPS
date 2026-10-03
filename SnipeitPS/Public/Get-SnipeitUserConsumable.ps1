<#
.SYNOPSIS
Lists consumable assignments for a user with inventory-safe IDs.
.DESCRIPTION
Queries GET /api/v1/users/{user_id}/consumables. Results respect server permissions
and company scoping. Normalized id is the nested consumable inventory ID;
checkout_id retains the assignment ID. Legacy rows without a nested consumable
remain unchanged. An invalid nested inventory ID raises SnipeitResourceIdentityError.
Use PreserveResponse for the unmodified response envelope. It takes precedence over all.
.PARAMETER user_id
Positive user ID. Accepts pipeline properties named user_id or id.
.PARAMETER search
Searches consumable names or assignment notes.
.PARAMETER sort
Sorts by name or assignment created_at. Defaults to created_at.
.PARAMETER order
Sort direction. Defaults to desc.
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
Get-SnipeitUserConsumable -user_id 7 -Session $session
#>
function Get-SnipeitUserConsumable {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$user_id,
        [string]$search,
        [ValidateSet('name', 'created_at')]
        [string]$sort = 'created_at',
        [ValidateSet('asc', 'desc')]
        [string]$order = 'desc',
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
        Invoke-SnipeitMethod -Route "$script:SnipeitApiPrefix/users/$user_id/consumables" -Method Get -GetParameters $query -Session $Session -Paginate:$all -PreserveResponse:$PreserveResponse
    }
}
