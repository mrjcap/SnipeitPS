<#
.SYNOPSIS
Lists pending checkout requests visible to an administrator.
.DESCRIPTION
Queries GET /api/v1/requests. Results respect server permissions and company scoping.
Rows expose request_id instead of id. Nested requestable IDs remain unchanged.
This queue contains pending requests only. There is no admin approval,
fulfillment, or cancellation API in this server revision.
Use PreserveResponse for the unmodified response envelope. It takes precedence over all.
.PARAMETER user_id
Positive requesting user ID to filter by.
.PARAMETER requestable_type
Resource class to filter by. Sends the corresponding App\Models class name.
.PARAMETER search
Server-side search text.
.PARAMETER sort
Sort column. Defaults to requested_at. Also accepts start_date, end_date,
quantity, or requestable.remaining.
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
Get-SnipeitCheckoutRequest -Session $session
#>
function Get-SnipeitCheckoutRequest {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [ValidateRange(1, [int]::MaxValue)]
        [int]$user_id,
        [ValidateSet('Asset', 'AssetModel', 'Accessory', 'Consumable', 'Component', 'License')]
        [string]$requestable_type,
        [string]$search,
        [ValidateSet('requested_at', 'start_date', 'end_date', 'quantity', 'requestable.remaining')]
        [string]$sort = 'requested_at',
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
        if ($PSBoundParameters.ContainsKey('requestable_type')) { $query['requestable_type'] = "App\Models\$requestable_type" }
        $query['sort'] = $sort
        $query['order'] = $order
        if ($PSBoundParameters.ContainsKey('user_id')) { $query['user_id'] = $user_id }
        if ($PSBoundParameters.ContainsKey('search')) { $query['search'] = $search }
        Invoke-SnipeitMethod -Route "$script:SnipeitApiPrefix/requests" -Method Get -GetParameters $query -Session $Session -Paginate:$all -PreserveResponse:$PreserveResponse
    }
}
