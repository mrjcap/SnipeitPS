<#
.SYNOPSIS
Adjusts stock by a signed amount using the current Snipe-IT API.

.DESCRIPTION
Posts to the inventory item's adjust-quantity endpoint. Positive amounts increase
stock; negative amounts reduce it subject to the server's assigned-stock floor.
Zero records an audit without changing stock. A positive adjustment creates an
acquisition line only when acquisition metadata is supplied. Receipts belong to
the adjustment log. Server order/file writes are not atomic with stock changes.
No legacy fallback is attempted. Resource IDs are explicit: order-item id fields
are not accepted as parent resource IDs.

.PARAMETER EntityType
Accessory, Component or Consumable.

.PARAMETER resource_id
Positive inventory ID or array of IDs. Pipeline property binding accepts resource_id,
not the ambiguous id field on acquisition rows.

.PARAMETER amount
Signed stock delta, including zero. This is not an absolute quantity.

.PARAMETER note
Required adjustment reason, up to 65535 characters. When acquisition metadata creates
an order, the server's Order model limits order notes to 1000 characters.

.PARAMETER unit_cost
Optional nonnegative per-unit acquisition cost. The wire field is unit_cost, not purchase_cost.

.PARAMETER order_number
Optional order number, up to 191 characters.

.PARAMETER supplier_id
Optional positive acquisition supplier ID, or null.

.PARAMETER purchase_date
Optional acquisition date, serialized as yyyy-MM-dd, or null.

.PARAMETER currency
Optional currency code, up to 10 characters.

.PARAMETER File
Path or FileInfo for one receipt. Uses the multipart field file, not file[].

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Invoke-SnipeitQuantityAdjustment -EntityType Accessory -resource_id 7 -amount 3 -note 'Received' -unit_cost 12.50 -currency EUR

.EXAMPLE
Invoke-SnipeitQuantityAdjustment -EntityType Component -resource_id 7 -amount -1 -note 'Stock count' -WhatIf
#>
function Invoke-SnipeitQuantityAdjustment {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Accessory', 'Component', 'Consumable')]
        [string]$EntityType,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$resource_id,

        [Parameter(Mandatory = $true)]
        [int]$amount,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 65535)]
        [string]$note,

        [Nullable[decimal]]$unit_cost,

        [ValidateLength(0, 191)]
        [string]$order_number,

        [Nullable[int]]$supplier_id,

        [Nullable[datetime]]$purchase_date,

        [ValidateLength(0, 10)]
        [string]$currency,

        [ValidateNotNull()]
        [object]$File,

        [SnipeitSession]$Session
    )

    process {
        if ($null -ne $unit_cost -and ($unit_cost -lt 0 -or $unit_cost -gt 9999999999999999.9999d)) {
            throw [ArgumentOutOfRangeException]::new('unit_cost', 'Use a cost between zero and 9999999999999999.9999, or null.')
        }
        if ($null -ne $supplier_id -and $supplier_id -lt 1) {
            throw [ArgumentOutOfRangeException]::new('supplier_id', 'Use a positive supplier ID or null.')
        }
        $routes = @{ Accessory = 'accessories'; Component = 'components'; Consumable = 'consumables' }
        $types = @{ Accessory = 'SnipeitPS.Accessory'; Component = 'SnipeitPS.Component'; Consumable = 'SnipeitPS.Consumable' }
        $route = $routes[$EntityType]
        $body = @{ amount = $amount; note = $note }
        foreach ($field in @('unit_cost', 'order_number', 'supplier_id', 'purchase_date', 'currency')) {
            if ($PSBoundParameters.ContainsKey($field)) { $body[$field] = $PSBoundParameters[$field] }
        }
        if ($null -ne $body['purchase_date']) {
            $body['purchase_date'] = $purchase_date.ToString('yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture)
        }
        foreach ($resourceId in $resource_id) {
            if (-not $PSCmdlet.ShouldProcess("$EntityType $resourceId", "Adjust stock by $amount")) { continue }
            if ($PSBoundParameters.ContainsKey('File')) {
                $activeSession = if ($null -ne $Session) { $Session } else { $script:SnipeitPSSession }
                $sessionUrl = if ($activeSession -is [Collections.IDictionary]) { $activeSession['url'] } else { $activeSession.Url }
                if ([string]::IsNullOrWhiteSpace([string]$sessionUrl)) {
                    throw [InvalidOperationException]::new('Use Connect-SnipeitPS or supply Session before adjusting quantity.')
                }
                $uri = ([string]$sessionUrl).TrimEnd('/') + "$script:SnipeitApiPrefix/$route/$resourceId/adjust-quantity"
                $fields = $body.Clone()
                if ($null -ne $fields['unit_cost']) {
                    $fields['unit_cost'] = $unit_cost.ToString([Globalization.CultureInfo]::InvariantCulture)
                }
                $response = Send-SnipeitMultipart -Uri $uri -Files @($File) -Fields $fields -FileFieldName 'file' -Session $activeSession
                ConvertFrom-SnipeitApiResponse -Response $response -ResponseKind StandardEnvelope -ResultTypeName $types[$EntityType]
            } else {
                Invoke-SnipeitMethod -Route "$script:SnipeitApiPrefix/$route/{id}/adjust-quantity" -RouteTokens @{ id = $resourceId } -Method Post -Body $body -Session $Session
            }
        }
    }
}
