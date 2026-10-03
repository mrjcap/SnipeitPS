<#
.SYNOPSIS
Lists requestable models, accessories, consumables, components, or licenses.
.DESCRIPTION
Queries GET /api/v1/account/requestable/models, /accessories, /consumables,
/components, or /licenses. Results respect server permissions and company scoping.
Rows expose model_id, accessory_id, consumable_id, component_id, or license_id
instead of id so model and accessory rows cannot bind as asset requests.
Consumable, component, and license rows can pipe to account request commands.
This server has no model or accessory account request mutation route.
Use Get-SnipeitRequestableAsset for hardware.
Use PreserveResponse for the unmodified response envelope. It takes precedence over all.
.PARAMETER Type
Resource type to list. Model, Accessory, Consumable, Component, or License.
.PARAMETER search
Server-side search text.
.PARAMETER sort
Sort column. Defaults to name. Also accepts created_at. Only models support remaining.
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
Get-SnipeitRequestableItem -Type Consumable -Session $session
#>
function Get-SnipeitRequestableItem {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Model', 'Accessory', 'Consumable', 'Component', 'License')]
        [string]$Type,
        [string]$search,
        [ValidateSet('name', 'created_at', 'remaining')]
        [string]$sort = 'name',
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
        if ($sort -eq 'remaining' -and $Type -ne 'Model') { throw 'The remaining sort is supported only for models.' }
        $leaf = @{ Model = 'models'; Accessory = 'accessories'; Consumable = 'consumables'; Component = 'components'; License = 'licenses' }[$Type]
        $query['sort'] = $sort
        $query['order'] = $order
        if ($PSBoundParameters.ContainsKey('search')) { $query['search'] = $search }
        Invoke-SnipeitMethod -Route "$script:SnipeitApiPrefix/account/requestable/$leaf" -Method Get -GetParameters $query -Session $Session -Paginate:$all -PreserveResponse:$PreserveResponse
    }
}
