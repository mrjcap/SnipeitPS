<#
.SYNOPSIS
Lists acquisition lines from the current Snipe-IT API.

.DESCRIPTION
Reads GET /api/v1/order-items. Scope by inventory type and item_id, or aggregate
assets by asset_model_id. Unscoped listing requires server superuser permission.
Costs and dates retain the server's transformed representation. This API does not
expose order creation, editing or deletion.

.PARAMETER EntityType
Inventory type for the item_id scope: Accessory, Component, Consumable, Asset or License.

.PARAMETER item_id
Positive parent inventory ID. Must be paired with EntityType.

.PARAMETER asset_model_id
Positive model ID for aggregating acquisition lines across its assets.

.PARAMETER search
Searches order numbers, supplier names and order notes.

.PARAMETER sort
Server-supported sort column.

.PARAMETER order
Ascending or descending sort order.

.PARAMETER limit
Page size. Defaults to 50; the server may impose a lower maximum.

.PARAMETER offset
Starting result offset.

.PARAMETER all
Streams all pages from the starting offset. Cannot be combined with preserveResponse.

.PARAMETER preserveResponse
Returns the raw rows/total envelope for one page, without type decoration.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.OrderItem

.EXAMPLE
Get-SnipeitOrderItem -EntityType Accessory -item_id 7 -all

.EXAMPLE
Get-SnipeitOrderItem -asset_model_id 4 -sort purchase_date -order desc
#>
function Get-SnipeitOrderItem {
    [CmdletBinding(DefaultParameterSetName = 'Unscoped')]
    [OutputType('SnipeitPS.OrderItem')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Item')]
        [ValidateSet('Accessory', 'Component', 'Consumable', 'Asset', 'License')]
        [string]$EntityType,

        [Parameter(Mandatory = $true, ParameterSetName = 'Item', ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$item_id,

        [Parameter(Mandatory = $true, ParameterSetName = 'Model')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$asset_model_id,

        [string]$search,

        [ValidateSet('order_number', 'purchase_date', 'currency', 'supplier', 'qty', 'unit_cost', 'created_at', 'created_by', 'total_cost')]
        [string]$sort,

        [ValidateSet('asc', 'desc')]
        [string]$order,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$limit = 50,

        [ValidateRange(0, [int]::MaxValue)]
        [int]$offset = 0,

        [switch]$all,
        [switch]$preserveResponse,
        [SnipeitSession]$Session
    )

    process {
        if ($all -and $preserveResponse) {
            throw [System.ArgumentException]::new('Use all to stream rows or preserveResponse to retrieve one raw page, not both.')
        }
        $query = @{ limit = $limit; offset = $offset }
        foreach ($field in @('search', 'sort', 'order', 'asset_model_id', 'item_id')) {
            if ($PSBoundParameters.ContainsKey($field)) { $query[$field] = $PSBoundParameters[$field] }
        }
        if ($PSCmdlet.ParameterSetName -eq 'Item') {
            $models = @{ Accessory = 'Accessory'; Component = 'Component'; Consumable = 'Consumable'; Asset = 'Asset'; License = 'License' }
            $query['item_type'] = 'App\Models\' + $models[$EntityType]
        }
        $parameters = @{
            Route = "$script:SnipeitApiPrefix/order-items"
            Method = 'Get'
            GetParameters = $query
            Paginate = [bool]$all
            PreserveResponse = [bool]$preserveResponse
            Session = $Session
        }
        Invoke-SnipeitMethod @parameters | ForEach-Object {
            if (-not $preserveResponse -and -not $_.PSObject.TypeNames.Contains('SnipeitPS.OrderItem')) {
                $_.PSObject.TypeNames.Insert(0, 'SnipeitPS.OrderItem')
            }
            $_
        }
    }
}
