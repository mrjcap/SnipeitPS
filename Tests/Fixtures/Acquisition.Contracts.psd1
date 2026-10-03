@{
    ApiRef = '5d7fe00370813649d6b535a43d3a47ec51adbab2'
    Operations = @(
        @{
            Key = 'order-items.index'
            Methods = @('GET')
            Route = '/api/v1/order-items'
            Controller = 'OrderItemsController::index'
            Source = 'app/Http/Controllers/Api/OrderItemsController.php:47-95; routes/api.php:46-53'
            QueryFields = @('item_type', 'item_id', 'asset_model_id', 'search', 'sort', 'order', 'limit', 'offset')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view scoped parent or AssetModel; unscoped listing requires superuser'
            Command = 'Get-SnipeitOrderItem'
            TestFile = 'Tests/Acquisition.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'accessories.adjust-quantity'
            Methods = @('POST')
            Route = '/api/v1/accessories/{id}/adjust-quantity'
            Controller = 'AccessoriesController::adjustQuantity'
            Source = 'app/Http/Controllers/Api/AccessoriesController.php:362-374; app/Http/Requests/AdjustQuantityRequest.php:22-63'
            QueryFields = @()
            BodyFields = @('amount', 'note', 'order_number', 'supplier_id', 'purchase_date', 'unit_cost', 'currency', 'file')
            RequiredFields = @('amount', 'note')
            NullableFields = @('order_number', 'supplier_id', 'purchase_date', 'unit_cost', 'currency', 'file')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update resolved Accessory'
            Command = 'Invoke-SnipeitQuantityAdjustment'
            TestFile = 'Tests/Acquisition.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'components.adjust-quantity'
            Methods = @('POST')
            Route = '/api/v1/components/{id}/adjust-quantity'
            Controller = 'ComponentsController::adjustQuantity'
            Source = 'app/Http/Controllers/Api/ComponentsController.php:303-308; app/Http/Requests/AdjustQuantityRequest.php:22-63'
            QueryFields = @()
            BodyFields = @('amount', 'note', 'order_number', 'supplier_id', 'purchase_date', 'unit_cost', 'currency', 'file')
            RequiredFields = @('amount', 'note')
            NullableFields = @('order_number', 'supplier_id', 'purchase_date', 'unit_cost', 'currency', 'file')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update resolved Component'
            Command = 'Invoke-SnipeitQuantityAdjustment'
            TestFile = 'Tests/Acquisition.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'consumables.adjust-quantity'
            Methods = @('POST')
            Route = '/api/v1/consumables/{id}/adjust-quantity'
            Controller = 'ConsumablesController::adjustQuantity'
            Source = 'app/Http/Controllers/Api/ConsumablesController.php:279-285; app/Http/Requests/AdjustQuantityRequest.php:22-63'
            QueryFields = @()
            BodyFields = @('amount', 'note', 'order_number', 'supplier_id', 'purchase_date', 'unit_cost', 'currency', 'file')
            RequiredFields = @('amount', 'note')
            NullableFields = @('order_number', 'supplier_id', 'purchase_date', 'unit_cost', 'currency', 'file')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update resolved Consumable'
            Command = 'Invoke-SnipeitQuantityAdjustment'
            TestFile = 'Tests/Acquisition.Tests.ps1'
            State = 'Verified'
        }
    )
    ExistingCommandFields = @(
        @{ Command = 'New-SnipeitAccessory'; Fields = @('currency', 'default_supplier_id'); Source = 'app/Http/Traits/HandlesAdjustQuantity.php:246-324; app/Http/Requests/StoreAccessoryRequest.php:62' }
        @{ Command = 'New-SnipeitComponent'; Fields = @('currency', 'default_supplier_id'); Source = 'app/Http/Traits/HandlesAdjustQuantity.php:246-324; app/Http/Controllers/Api/ComponentsController.php:209-228' }
        @{ Command = 'New-SnipeitConsumable'; Fields = @('currency', 'default_supplier_id'); Source = 'app/Http/Traits/HandlesAdjustQuantity.php:246-324; app/Http/Requests/StoreConsumableRequest.php:62' }
        @{ Command = 'Set-SnipeitAccessory'; Fields = @('unit_cost', 'currency', 'note', 'default_supplier_id'); Source = 'app/Http/Controllers/Api/AccessoriesController.php:306-359; app/Http/Traits/HandlesAdjustQuantity.php:144-230' }
        @{ Command = 'Set-SnipeitComponent'; Fields = @('unit_cost', 'currency', 'note', 'default_supplier_id'); Source = 'app/Http/Controllers/Api/ComponentsController.php:256-301; app/Http/Traits/HandlesAdjustQuantity.php:144-230' }
        @{ Command = 'Set-SnipeitConsumable'; Fields = @('unit_cost', 'currency', 'note', 'default_supplier_id'); Source = 'app/Http/Controllers/Api/ConsumablesController.php:232-277; app/Http/Traits/HandlesAdjustQuantity.php:144-230' }
    )
    Limitations = @(
        @{ Field = 'orders CRUD'; Source = 'routes/api.php:46-53'; Reason = 'Only order-item listing is routed. No direct Orders or OrderItems create, update or delete endpoint is exposed.' }
        @{ Field = 'legacy acquisition updates'; Source = 'app/Http/Traits/HandlesAdjustQuantity.php:144-230'; Reason = 'Metadata-only updates do not edit purchase history. Positive absolute qty differences may create an acquisition using unit_cost, not purchase_cost. Legacy parameters remain available without automatic fallback.' }
        @{ Field = 'signed amount'; Source = 'app/Models/Traits/AdjustsQuantity.php:95-173'; Reason = 'Negative adjustments respect the assigned-stock floor. Zero logs an audit without changing stock. Negative and zero adjustments do not create acquisition lines.' }
        @{ Field = 'acquisition metadata'; Source = 'app/Http/Traits/HandlesAdjustQuantity.php:163-217'; Reason = 'Positive adjustments create a line only when order_number, supplier_id, purchase_date, unit_cost or currency is non-null. A note alone is insufficient. Matching orders are reused without updating their notes or currency.' }
        @{ Field = 'atomicity and notes'; Source = 'app/Http/Traits/HandlesAdjustQuantity.php:112-230; app/Models/Order.php:25-62'; Reason = 'Order and receipt writes precede the quantity transaction. Save results are not checked. Adjustment notes allow 65535 characters but Order notes allow only 1000. Offline client checks do not verify server persistence or rollback.' }
        @{ Field = 'file'; Source = 'app/Http/Requests/AdjustQuantityRequest.php:50-63'; Reason = 'One receipt uses multipart field file, not file[]. File nulls are omitted by the multipart transport. Download links are UI URLs, not a discovered REST download endpoint.' }
    )
}
