@{
    ApiRef = '0c381a6482824a9f5d1889a98843393a0b6ad6b3'
    AcquisitionContract = 'Tests/Fixtures/Acquisition.Contracts.psd1'
    CurrentApiContract = 'Tests/Fixtures/CurrentApi.Contracts.psd1'
    FieldLimitations = @(
        @{ Operation = 'companies.index'; Field = 'parent_id'; Source = 'app/Http/Controllers/Api/CompaniesController.php:90-97; SnipeitPS/Public/Get-SnipeitCompany.ps1:92-93'; Reason = 'Top-level filtering requires the literal string null. Zero is compared as parent_id = 0, not IS NULL. The client integer parameter cannot send the null string; omitting the parameter does not filter for top-level companies.' }
        @{ Operation = 'companies.index'; Field = 'page'; Source = 'app/Http/Middleware/SetPaginationDefaults.php:21-26; SnipeitPS/Public/Get-SnipeitCompany.ps1:82-90'; Reason = 'The server accepts page only when offset is not filled. The client exposes limit, offset and all, but no page parameter.' }
        @{ Operation = 'accessories.store,accessories.update'; Field = 'qty'; Source = 'app/Models/Accessory.php; database/migrations/2015_02_25_204513_add_accessories_table.php:20'; Reason = 'Model validation declares qty nullable but the table column is not nullable. The client retains a non-nullable integer quantity.' }
        @{ Operation = 'hardware.audit,hardware.asset.audit,hardware.audit.bulk'; Field = '_snipeit_*'; Source = 'app/Http/Controllers/Api/AssetsController.php:1681-1708'; Reason = 'Only custom fields enabled for display_audit are persisted. Encrypted writes require assets.view.encrypted_custom_fields; the response can echo values without persisting them when permission is absent.' }
        @{ Operation = 'hardware.audit.bulk'; Field = 'image'; Source = 'SnipeitPS/Public/New-SnipeitAudit.ps1; SnipeitPS/Public/Update-SnipeitAssetAudit.ps1'; Reason = 'Client bulk audits reject images because the legacy multipart conversion does not preserve the ids array. Audit individual assets when attaching images.' }
        @{ Operation = 'consumables.update,models.update'; Field = 'authorization'; Source = 'app/Http/Requests/StoreConsumableRequest.php; app/Http/Requests/StoreAssetModelRequest.php'; Reason = 'Update handlers reuse create-authorized FormRequests and therefore require create permission as well as update permission on the pinned server.' }
        @{ Operation = 'components.assets'; Field = 'limit,offset'; Source = 'app/Http/Controllers/Api/ComponentsController.php:271-289'; Reason = 'When search is supplied the server returns all matching assets without applying limit or offset.' }
        @{ Operation = 'models.index'; Field = 'manufacturer_id'; Source = 'app/Http/Controllers/Api/AssetModelsController.php:34-197'; Reason = 'The legacy client exposes manufacturer_id, but the pinned collection handler never consumes it. It is not a verified server filter.' }
        @{ Operation = 'fields.index,fieldsets.index'; Field = 'search,sort,order,limit,offset'; Source = 'app/Http/Controllers/Api/CustomFieldsController.php:25-30; app/Http/Controllers/Api/CustomFieldsetsController.php:38-43'; Reason = 'These handlers return the whole collection and do not consume query parameters. Legacy client parameters do not imply server filtering or pagination.' }
        @{ Operation = 'users.store,users.update'; Field = 'username,password,first_name'; Source = 'app/Http/Requests/SaveUserRequest.php:34-81'; Reason = 'RequiredFields lists unconditional requirements only. Username is required unless ldap_import is 1. POST password validation depends on ldap_import and activated. PUT requires first_name and username unlike PATCH and applies password confirmation rules.' }
        @{ Operation = 'accessories.checkout'; Field = 'assigned_user,assigned_asset,assigned_location'; Source = 'app/Http/Requests/AccessoryCheckoutRequest.php:44-47'; Reason = 'At least one target is required. RequiredFields does not express required_without_all. The client maps assigned_to and checkout_to_type to the target key.' }
        @{ Operation = 'hardware.store,hardware.update'; Field = '_snipeit_*'; Source = 'app/Http/Controllers/Api/AssetsController.php:965-1008'; Reason = 'Custom-field values use dynamic database-column keys at the top level, not an asset_attributes object. The client flattens its customfields argument.' }
        @{ Operation = 'manufacturers.index'; Field = 'tag_color'; Source = 'app/Http/Controllers/Api/ManufacturersController.php:115-116'; Reason = 'Tests tag_color but reads manufacturers.tag_color. A normal tag_color query is not applied correctly.' }
        @{ Operation = 'locations.index'; Field = 'tag_color'; Source = 'app/Http/Controllers/Api/LocationsController.php:176-177'; Reason = 'Tests tag_color but reads locations.tag_color. A normal tag_color query is not applied correctly.' }
        @{ Operation = 'departments.store'; Field = 'tag_color'; Source = 'app/Http/Controllers/Api/DepartmentsController.php:117; app/Models/Department.php:46-54'; Reason = 'Creation fills validated fields only, and tag_color has no request validation rule. Department updates accept it.' }
        @{ Operation = 'fields.update'; Field = 'custom_format'; Source = 'app/Http/Controllers/Api/CustomFieldsController.php:72-79; app/Models/CustomField.php:723-728'; Reason = 'Update validation does not allow arbitrary PCRE rules. The client rejects custom_format updates instead of silently removing validation.' }
        @{ Operation = 'fields.update'; Field = 'field_encrypted'; Source = 'app/Http/Controllers/Api/CustomFieldsController.php:72-79'; Reason = 'Encryption is excluded from update input by server design.' }
        @{ Operation = 'accessories.update,components.update,consumables.update,departments.update,licenses.update'; Field = 'company_id'; Source = 'app/Http/Controllers/Api/AccessoriesController.php:275; ComponentsController.php:221; ConsumablesController.php:209; DepartmentsController.php:163; LicensesController.php:266'; Reason = 'The server resolves company_id even when omitted. A partial update can change company membership. No implicit client read-modify-write workaround is used.' }
        @{ Operation = 'hardware.store,hardware.update'; Field = 'last_audit_date'; Source = 'app/Http/Requests/StoreAssetRequest.php:67-75; app/Http/Controllers/Api/AssetsController.php:975-976'; Reason = 'The server normalizes supplied audit timestamps to midnight. The client preserves the supplied timestamp on the wire.' }
        @{ Operation = 'maintenances.store,maintenances.update'; Field = 'cost,notes,completion_date,expected_completion_date'; Source = 'app/Models/Maintenance.php'; Reason = 'The server normalizes zero cost and empty notes or dates to null. completion_date aliases expected_completion_date; actual completion uses completed_at.' }
        @{ Operation = 'maintenances.store'; Field = 'checked_out_to_id,checked_out_to_type,image_delete'; Source = 'app/Observers/MaintenanceObserver.php; app/Http/Requests/ImageUploadRequest.php'; Reason = 'Creation captures checkout snapshots from the asset. Image deletion has no existing image to remove. Neither is exposed as a creation control.' }
        @{ Operation = 'maintenances.store'; Field = 'image with asset_ids'; Source = 'SnipeitPS/Private/Invoke-SnipeitMethod.ps1'; Reason = 'Client bulk creation rejects images because shared multipart transport does not preserve asset_ids as a PHP array. Use single-asset creation for images.' }
        @{ Operation = 'maintenances.update'; Field = 'image,image_delete'; Source = 'app/Http/Controllers/Api/MaintenancesController.php::update'; Reason = 'The update handler does not invoke image handling and image is not fillable. The client exposes image upload only on creation.' }
        @{ Operation = 'hardware.index,reports.depreciation,hardware.upcoming'; Field = '_snipeit_*,requestable,assigned_to,assigned_type'; Source = 'app/Http/Controllers/Api/AssetsController.php::index'; Reason = 'Custom filters use dynamic internal column names. requestable=true filters requestable assets; false does not select non-requestable assets. Assignment filtering requires both assigned_to and assigned_type.' }
        @{ Operation = 'reports.depreciation'; Field = 'components'; Source = 'app/Http/Controllers/Api/AssetsController.php::index; app/Http/Transformers/DepreciationReportTransformer.php'; Reason = 'The shared handler can load components, but the depreciation transformer does not return component details.' }
        @{ Operation = 'files.show,hardware.files.show,models.files.show'; Field = 'inline'; Source = 'app/Http/Controllers/Api/UploadedFilesController.php::show'; Reason = 'Only safe allowlisted extensions receive inline disposition. The response remains binary; Save-SnipeitFile or AsByteArray preserves the original bytes.' }
        @{ Operation = 'licenses.seats.index'; Field = 'offset'; Source = 'app/Http/Controllers/Api/LicenseSeatsController.php::index'; Reason = 'An offset at or beyond the total is reset to zero by the server. Client pagination stops at the reported total.' }
    )
    Operations = @(
        @{
            Key = 'accessories.index'
            Methods = @('GET')
            Route = '/api/v1/accessories'
            Controller = 'AccessoriesController::index'
            Source = 'app/Http/Controllers/Api/AccessoriesController.php'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset', 'company_id', 'expand_company_hierarchy', 'order_number', 'category_id', 'manufacturer_id', 'supplier_id', 'location_id', 'notes')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view Accessory'
            Command = 'Get-SnipeitAccessory'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'accessories.store'
            Methods = @('POST')
            Route = '/api/v1/accessories'
            Controller = 'AccessoriesController::store'
            Source = 'app/Http/Controllers/Api/AccessoriesController.php'
            QueryFields = @()
            BodyFields = @('name', 'category_id', 'qty', 'min_amt', 'company_id', 'manufacturer_id', 'model_number', 'order_number', 'purchase_date', 'purchase_cost', 'supplier_id', 'image', 'requestable', 'location_id', 'notes')
            RequiredFields = @('name', 'category_id')
            NullableFields = @('company_id', 'manufacturer_id', 'supplier_id', 'location_id', 'purchase_date', 'purchase_cost', 'min_amt')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'create Accessory via StoreAccessoryRequest'
            Command = 'New-SnipeitAccessory'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'accessories.show'
            Methods = @('GET')
            Route = '/api/v1/accessories/{id}'
            Controller = 'AccessoriesController::show'
            Source = 'app/Http/Controllers/Api/AccessoriesController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view Accessory'
            Command = 'Get-SnipeitAccessory'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'accessories.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/accessories/{id}'
            Controller = 'AccessoriesController::update'
            Source = 'app/Http/Controllers/Api/AccessoriesController.php'
            QueryFields = @()
            BodyFields = @('name', 'category_id', 'qty', 'min_amt', 'company_id', 'manufacturer_id', 'model_number', 'order_number', 'purchase_date', 'purchase_cost', 'supplier_id', 'image', 'requestable', 'location_id', 'notes', 'image_delete')
            RequiredFields = @()
            NullableFields = @('company_id', 'manufacturer_id', 'supplier_id', 'location_id', 'purchase_date', 'purchase_cost', 'min_amt')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update Accessory'
            Command = 'Set-SnipeitAccessory'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'accessories.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/accessories/{id}'
            Controller = 'AccessoriesController::destroy'
            Source = 'app/Http/Controllers/Api/AccessoriesController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete Accessory class and instance'
            Command = 'Remove-SnipeitAccessory'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'categories.index'
            Methods = @('GET')
            Route = '/api/v1/categories'
            Controller = 'CategoriesController::index'
            Source = 'app/Http/Controllers/Api/CategoriesController.php'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset', 'archived', 'name', 'category_type', 'use_default_eula', 'require_acceptance', 'checkin_email', 'created_by', 'created_at', 'updated_at')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view Category'
            Command = 'Get-SnipeitCategory'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'categories.store'
            Methods = @('POST')
            Route = '/api/v1/categories'
            Controller = 'CategoriesController::store'
            Source = 'app/Http/Controllers/Api/CategoriesController.php'
            QueryFields = @()
            BodyFields = @('name', 'category_type', 'eula_text', 'use_default_eula', 'require_acceptance', 'checkin_email', 'alert_on_response', 'tag_color', 'notes', 'image')
            RequiredFields = @('name', 'category_type')
            NullableFields = @('eula_text')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'create Category'
            Command = 'New-SnipeitCategory'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'categories.show'
            Methods = @('GET')
            Route = '/api/v1/categories/{id}'
            Controller = 'CategoriesController::show'
            Source = 'app/Http/Controllers/Api/CategoriesController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view Category'
            Command = 'Get-SnipeitCategory'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'categories.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/categories/{id}'
            Controller = 'CategoriesController::update'
            Source = 'app/Http/Controllers/Api/CategoriesController.php'
            QueryFields = @()
            BodyFields = @('name', 'category_type', 'eula_text', 'use_default_eula', 'require_acceptance', 'checkin_email', 'alert_on_response', 'tag_color', 'notes', 'image', 'image_delete')
            RequiredFields = @()
            NullableFields = @('eula_text')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update Category'
            Command = 'Set-SnipeitCategory'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'categories.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/categories/{id}'
            Controller = 'CategoriesController::destroy'
            Source = 'app/Http/Controllers/Api/CategoriesController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete Category'
            Command = 'Remove-SnipeitCategory'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'companies.index'
            Methods = @('GET')
            Route = '/api/v1/companies'
            Controller = 'CompaniesController::index'
            Source = 'app/Http/Controllers/Api/CompaniesController.php'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset', 'page', 'name', 'email', 'created_by', 'tag_color', 'parent_id')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view Company'
            Command = 'Get-SnipeitCompany'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'companies.store'
            Methods = @('POST')
            Route = '/api/v1/companies'
            Controller = 'CompaniesController::store'
            Source = 'app/Http/Controllers/Api/CompaniesController.php'
            QueryFields = @()
            BodyFields = @('name', 'parent_id', 'phone', 'fax', 'email', 'tag_color', 'notes', 'image')
            RequiredFields = @('name')
            NullableFields = @('parent_id', 'phone', 'fax', 'email', 'tag_color', 'notes')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'create Company'
            Command = 'New-SnipeitCompany'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'companies.show'
            Methods = @('GET')
            Route = '/api/v1/companies/{id}'
            Controller = 'CompaniesController::show'
            Source = 'app/Http/Controllers/Api/CompaniesController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view Company class and instance'
            Command = 'Get-SnipeitCompany'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'companies.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/companies/{id}'
            Controller = 'CompaniesController::update'
            Source = 'app/Http/Controllers/Api/CompaniesController.php'
            QueryFields = @()
            BodyFields = @('name', 'parent_id', 'phone', 'fax', 'email', 'tag_color', 'notes', 'image', 'image_delete')
            RequiredFields = @()
            NullableFields = @('parent_id', 'phone', 'fax', 'email', 'tag_color', 'notes')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update Company class and instance'
            Command = 'Set-SnipeitCompany'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'companies.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/companies/{id}'
            Controller = 'CompaniesController::destroy'
            Source = 'app/Http/Controllers/Api/CompaniesController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete Company class and instance'
            Command = 'Remove-SnipeitCompany'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'departments.index'
            Methods = @('GET')
            Route = '/api/v1/departments'
            Controller = 'DepartmentsController::index'
            Source = 'app/Http/Controllers/Api/DepartmentsController.php'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset', 'name', 'company_id', 'manager_id', 'location_id', 'tag_color')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view Department'
            Command = 'Get-SnipeitDepartment'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'departments.store'
            Methods = @('POST')
            Route = '/api/v1/departments'
            Controller = 'DepartmentsController::store'
            Source = 'app/Http/Controllers/Api/DepartmentsController.php'
            QueryFields = @()
            BodyFields = @('name', 'company_id', 'manager_id', 'location_id', 'image', 'phone', 'fax', 'notes')
            RequiredFields = @('name')
            NullableFields = @('company_id', 'manager_id', 'location_id', 'phone', 'fax', 'notes')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'create Department via StoreDepartmentRequest'
            Command = 'New-SnipeitDepartment'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'departments.show'
            Methods = @('GET')
            Route = '/api/v1/departments/{id}'
            Controller = 'DepartmentsController::show'
            Source = 'app/Http/Controllers/Api/DepartmentsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view Department'
            Command = 'Get-SnipeitDepartment'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'departments.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/departments/{id}'
            Controller = 'DepartmentsController::update'
            Source = 'app/Http/Controllers/Api/DepartmentsController.php'
            QueryFields = @()
            BodyFields = @('name', 'company_id', 'manager_id', 'location_id', 'image', 'phone', 'fax', 'notes', 'tag_color', 'image_delete')
            RequiredFields = @()
            NullableFields = @('company_id', 'manager_id', 'location_id', 'phone', 'fax', 'notes')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update Department'
            Command = 'Set-SnipeitDepartment'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'departments.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/departments/{id}'
            Controller = 'DepartmentsController::destroy'
            Source = 'app/Http/Controllers/Api/DepartmentsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete Department instance'
            Command = 'Remove-SnipeitDepartment'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'components.index'
            Methods = @('GET')
            Route = '/api/v1/components'
            Controller = 'ComponentsController::index'
            Source = 'app/Http/Controllers/Api/ComponentsController.php'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset', 'name', 'company_id', 'expand_company_hierarchy', 'order_number', 'category_id', 'supplier_id', 'manufacturer_id', 'model_number', 'location_id', 'notes')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view Component'
            Command = 'Get-SnipeitComponent'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'components.store'
            Methods = @('POST')
            Route = '/api/v1/components'
            Controller = 'ComponentsController::store'
            Source = 'app/Http/Controllers/Api/ComponentsController.php'
            QueryFields = @()
            BodyFields = @('name', 'category_id', 'qty', 'min_amt', 'serial', 'company_id', 'location_id', 'order_number', 'purchase_date', 'purchase_cost', 'supplier_id', 'image', 'manufacturer_id', 'model_number', 'notes')
            RequiredFields = @('name', 'category_id', 'qty')
            NullableFields = @('company_id', 'location_id', 'supplier_id', 'manufacturer_id', 'purchase_date', 'purchase_cost', 'min_amt')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'create Component'
            Command = 'New-SnipeitComponent'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'components.show'
            Methods = @('GET')
            Route = '/api/v1/components/{id}'
            Controller = 'ComponentsController::show'
            Source = 'app/Http/Controllers/Api/ComponentsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view Component'
            Command = 'Get-SnipeitComponent'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'components.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/components/{id}'
            Controller = 'ComponentsController::update'
            Source = 'app/Http/Controllers/Api/ComponentsController.php'
            QueryFields = @()
            BodyFields = @('name', 'category_id', 'qty', 'min_amt', 'serial', 'company_id', 'location_id', 'order_number', 'purchase_date', 'purchase_cost', 'supplier_id', 'image', 'manufacturer_id', 'model_number', 'notes', 'image_delete')
            RequiredFields = @()
            NullableFields = @('company_id', 'location_id', 'supplier_id', 'manufacturer_id', 'purchase_date', 'purchase_cost', 'min_amt')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update Component'
            Command = 'Set-SnipeitComponent'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'components.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/components/{id}'
            Controller = 'ComponentsController::destroy'
            Source = 'app/Http/Controllers/Api/ComponentsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete Component class and instance'
            Command = 'Remove-SnipeitComponent'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'consumables.index'
            Methods = @('GET')
            Route = '/api/v1/consumables'
            Controller = 'ConsumablesController::index'
            Source = 'app/Http/Controllers/Api/ConsumablesController.php'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset', 'name', 'company_id', 'expand_company_hierarchy', 'order_number', 'category_id', 'model_number', 'manufacturer_id', 'supplier_id', 'location_id', 'notes')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'index Consumable'
            Command = 'Get-SnipeitConsumable'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'consumables.store'
            Methods = @('POST')
            Route = '/api/v1/consumables'
            Controller = 'ConsumablesController::store'
            Source = 'app/Http/Controllers/Api/ConsumablesController.php'
            QueryFields = @()
            BodyFields = @('name', 'category_id', 'qty', 'min_amt', 'company_id', 'item_no', 'order_number', 'purchase_date', 'purchase_cost', 'supplier_id', 'manufacturer_id', 'location_id', 'image', 'requestable', 'model_number', 'notes')
            RequiredFields = @('name', 'category_id', 'qty')
            NullableFields = @('company_id', 'location_id', 'supplier_id', 'manufacturer_id', 'purchase_date', 'purchase_cost', 'min_amt')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'create Consumable'
            Command = 'New-SnipeitConsumable'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'consumables.show'
            Methods = @('GET')
            Route = '/api/v1/consumables/{id}'
            Controller = 'ConsumablesController::show'
            Source = 'app/Http/Controllers/Api/ConsumablesController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view Consumable'
            Command = 'Get-SnipeitConsumable'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'consumables.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/consumables/{id}'
            Controller = 'ConsumablesController::update'
            Source = 'app/Http/Controllers/Api/ConsumablesController.php'
            QueryFields = @()
            BodyFields = @('name', 'category_id', 'qty', 'min_amt', 'company_id', 'item_no', 'order_number', 'purchase_date', 'purchase_cost', 'supplier_id', 'manufacturer_id', 'location_id', 'image', 'requestable', 'model_number', 'notes', 'image_delete')
            RequiredFields = @()
            NullableFields = @('company_id', 'location_id', 'supplier_id', 'manufacturer_id', 'purchase_date', 'purchase_cost', 'min_amt')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update Consumable; create Consumable via StoreConsumableRequest'
            Command = 'Set-SnipeitConsumable'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'consumables.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/consumables/{id}'
            Controller = 'ConsumablesController::destroy'
            Source = 'app/Http/Controllers/Api/ConsumablesController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete Consumable class and instance'
            Command = 'Remove-SnipeitConsumable'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'depreciations.index'
            Methods = @('GET')
            Route = '/api/v1/depreciations'
            Controller = 'DepreciationsController::index'
            Source = 'app/Http/Controllers/Api/DepreciationsController.php'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view Depreciation'
            Command = 'Get-SnipeitDepreciation'
            TestFile = 'Tests/Depreciation.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'depreciations.store'
            Methods = @('POST')
            Route = '/api/v1/depreciations'
            Controller = 'DepreciationsController::store'
            Source = 'app/Http/Controllers/Api/DepreciationsController.php'
            QueryFields = @()
            BodyFields = @('name', 'months')
            RequiredFields = @('name', 'months')
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'create Depreciation'
            Command = 'New-SnipeitDepreciation'
            TestFile = 'Tests/Depreciation.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'depreciations.show'
            Methods = @('GET')
            Route = '/api/v1/depreciations/{id}'
            Controller = 'DepreciationsController::show'
            Source = 'app/Http/Controllers/Api/DepreciationsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view Depreciation'
            Command = 'Get-SnipeitDepreciation'
            TestFile = 'Tests/Depreciation.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'depreciations.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/depreciations/{id}'
            Controller = 'DepreciationsController::update'
            Source = 'app/Http/Controllers/Api/DepreciationsController.php'
            QueryFields = @()
            BodyFields = @('name', 'months')
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update Depreciation'
            Command = 'Set-SnipeitDepreciation'
            TestFile = 'Tests/Depreciation.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'depreciations.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/depreciations/{id}'
            Controller = 'DepreciationsController::destroy'
            Source = 'app/Http/Controllers/Api/DepreciationsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete Depreciation class and instance'
            Command = 'Remove-SnipeitDepreciation'
            TestFile = 'Tests/Depreciation.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'fields.index'
            Methods = @('GET')
            Route = '/api/v1/fields'
            Controller = 'CustomFieldsController::index'
            Source = 'app/Http/Controllers/Api/CustomFieldsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'None'
            Authorization = 'index CustomField'
            Command = 'Get-SnipeitCustomField'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'fields.store'
            Methods = @('POST')
            Route = '/api/v1/fields'
            Controller = 'CustomFieldsController::store'
            Source = 'app/Http/Controllers/Api/CustomFieldsController.php'
            QueryFields = @()
            BodyFields = @('name', 'element', 'format', 'field_values', 'field_encrypted', 'show_in_email', 'help_text', 'show_in_requestable_list', 'is_unique', 'display_in_user_view', 'auto_add_to_fieldsets', 'show_in_listview', 'display_checkout', 'display_checkin', 'display_audit')
            RequiredFields = @('name', 'element')
            NullableFields = @('help_text', 'field_values', 'format')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'create CustomField'
            Command = 'New-SnipeitCustomField'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'fields.show'
            Methods = @('GET')
            Route = '/api/v1/fields/{id}'
            Controller = 'CustomFieldsController::show'
            Source = 'app/Http/Controllers/Api/CustomFieldsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view CustomField'
            Command = 'Get-SnipeitCustomField'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'fields.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/fields/{id}'
            Controller = 'CustomFieldsController::update'
            Source = 'app/Http/Controllers/Api/CustomFieldsController.php'
            QueryFields = @()
            BodyFields = @('name', 'element', 'format', 'field_values', 'show_in_email', 'help_text', 'show_in_requestable_list', 'is_unique', 'display_in_user_view', 'auto_add_to_fieldsets', 'show_in_listview', 'display_checkout', 'display_checkin', 'display_audit')
            RequiredFields = @()
            NullableFields = @('help_text', 'field_values', 'format')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update CustomField'
            Command = 'Set-SnipeitCustomField'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'fields.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/fields/{id}'
            Controller = 'CustomFieldsController::destroy'
            Source = 'app/Http/Controllers/Api/CustomFieldsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete CustomField instance'
            Command = 'Remove-SnipeitCustomField'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'fieldsets.index'
            Methods = @('GET')
            Route = '/api/v1/fieldsets'
            Controller = 'CustomFieldsetsController::index'
            Source = 'app/Http/Controllers/Api/CustomFieldsetsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'None'
            Authorization = 'index CustomField'
            Command = 'Get-SnipeitFieldset'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'fieldsets.store'
            Methods = @('POST')
            Route = '/api/v1/fieldsets'
            Controller = 'CustomFieldsetsController::store'
            Source = 'app/Http/Controllers/Api/CustomFieldsetsController.php'
            QueryFields = @()
            BodyFields = @('name')
            RequiredFields = @('name')
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'create CustomField'
            Command = 'New-SnipeitFieldset'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'fieldsets.show'
            Methods = @('GET')
            Route = '/api/v1/fieldsets/{id}'
            Controller = 'CustomFieldsetsController::show'
            Source = 'app/Http/Controllers/Api/CustomFieldsetsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view CustomField'
            Command = 'Get-SnipeitFieldset'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'fieldsets.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/fieldsets/{id}'
            Controller = 'CustomFieldsetsController::update'
            Source = 'app/Http/Controllers/Api/CustomFieldsetsController.php'
            QueryFields = @()
            BodyFields = @('name')
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update CustomField'
            Command = 'Set-SnipeitFieldset'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'fieldsets.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/fieldsets/{id}'
            Controller = 'CustomFieldsetsController::destroy'
            Source = 'app/Http/Controllers/Api/CustomFieldsetsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete CustomField'
            Command = 'Remove-SnipeitFieldset'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'groups.index'
            Methods = @('GET')
            Route = '/api/v1/groups'
            Controller = 'GroupsController::index'
            Source = 'app/Http/Controllers/Api/GroupsController.php'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset', 'name')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'superadmin; view Group'
            Command = 'Get-SnipeitGroup'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'groups.store'
            Methods = @('POST')
            Route = '/api/v1/groups'
            Controller = 'GroupsController::store'
            Source = 'app/Http/Controllers/Api/GroupsController.php'
            QueryFields = @()
            BodyFields = @('name', 'permissions', 'notes')
            RequiredFields = @('name')
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'superadmin'
            Command = 'New-SnipeitGroup'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'groups.show'
            Methods = @('GET')
            Route = '/api/v1/groups/{id}'
            Controller = 'GroupsController::show'
            Source = 'app/Http/Controllers/Api/GroupsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'superadmin'
            Command = 'Get-SnipeitGroup'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'groups.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/groups/{id}'
            Controller = 'GroupsController::update'
            Source = 'app/Http/Controllers/Api/GroupsController.php'
            QueryFields = @()
            BodyFields = @('name', 'permissions', 'notes')
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'superadmin'
            Command = 'Set-SnipeitGroup'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'groups.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/groups/{id}'
            Controller = 'GroupsController::destroy'
            Source = 'app/Http/Controllers/Api/GroupsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'superadmin'
            Command = 'Remove-SnipeitGroup'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'hardware.index'
            Methods = @('GET')
            Route = '/api/v1/hardware'
            Controller = 'AssetsController::index'
            Source = 'app/Http/Controllers/Api/AssetsController.php'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset', 'status_id', 'model_id', 'category_id', 'location_id', 'supplier_id', 'company_id', 'assigned_to', 'assigned_type', 'rtd_location_id', 'asset_tag', 'serial', 'status_type', 'status', 'requestable', 'asset_eol_date', 'expand_company_hierarchy', 'manufacturer_id', 'depreciation_id', 'byod', 'order_number', 'components')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'index Asset'
            Command = 'Get-SnipeitAsset'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'hardware.store'
            Methods = @('POST')
            Route = '/api/v1/hardware'
            Controller = 'AssetsController::store'
            Source = 'app/Http/Controllers/Api/AssetsController.php'
            QueryFields = @()
            BodyFields = @('asset_tag', 'model_id', 'status_id', 'name', 'serial', 'purchase_date', 'purchase_cost', 'order_number', 'supplier_id', 'notes', 'assigned_user', 'assigned_asset', 'assigned_location', 'warranty_months', 'rtd_location_id', 'requestable', 'company_id', 'byod', 'location_id', 'eol_explicit', 'asset_eol_date', 'expected_checkin', 'next_audit_date', 'last_audit_date', 'last_checkin', 'last_checkout', 'image', 'image_source')
            RequiredFields = @('model_id', 'status_id')
            NullableFields = @('supplier_id', 'company_id', 'rtd_location_id', 'purchase_date', 'purchase_cost', 'warranty_months', 'notes', 'serial', 'name', 'order_number', 'location_id', 'byod', 'eol_explicit', 'asset_eol_date', 'last_checkout', 'last_checkin', 'expected_checkin', 'last_audit_date', 'next_audit_date', 'requestable', 'assigned_user', 'assigned_asset', 'assigned_location')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'create Asset via StoreAssetRequest; encrypted custom fields require assets.view.encrypted_custom_fields'
            Command = 'New-SnipeitAsset'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'hardware.show'
            Methods = @('GET')
            Route = '/api/v1/hardware/{id}'
            Controller = 'AssetsController::show'
            Source = 'app/Http/Controllers/Api/AssetsController.php'
            QueryFields = @('components')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view Asset instance'
            Command = 'Get-SnipeitAsset'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'hardware.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/hardware/{id}'
            Controller = 'AssetsController::update'
            Source = 'app/Http/Controllers/Api/AssetsController.php'
            QueryFields = @()
            BodyFields = @('asset_tag', 'model_id', 'status_id', 'name', 'serial', 'purchase_date', 'purchase_cost', 'order_number', 'supplier_id', 'notes', 'assigned_user', 'assigned_asset', 'assigned_location', 'warranty_months', 'rtd_location_id', 'requestable', 'company_id', 'byod', 'location_id', 'eol_explicit', 'asset_eol_date', 'expected_checkin', 'next_audit_date', 'last_audit_date', 'last_checkin', 'last_checkout', 'image', 'image_source', 'image_delete')
            RequiredFields = @()
            NullableFields = @('supplier_id', 'company_id', 'rtd_location_id', 'purchase_date', 'purchase_cost', 'warranty_months', 'notes', 'serial', 'name', 'order_number', 'location_id', 'byod', 'eol_explicit', 'asset_eol_date', 'last_checkout', 'last_checkin', 'expected_checkin', 'last_audit_date', 'next_audit_date', 'requestable', 'assigned_user', 'assigned_asset', 'assigned_location')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update Asset instance via UpdateAssetRequest; assignments additionally require checkout permission'
            Command = 'Set-SnipeitAsset'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'hardware.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/hardware/{id}'
            Controller = 'AssetsController::destroy'
            Source = 'app/Http/Controllers/Api/AssetsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete Asset class and instance'
            Command = 'Remove-SnipeitAsset'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'maintenances.index'
            Methods = @('GET')
            Route = '/api/v1/maintenances'
            Controller = 'MaintenancesController::index'
            Source = 'app/Http/Controllers/Api/MaintenancesController.php'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset', 'asset_id', 'supplier_id', 'created_by', 'url', 'maintenance_type', 'maintenance_type_id', 'responsible_party_id', 'checked_out_to_id', 'checked_out_to_type', 'completed', 'upcoming_status', 'format')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view Asset'
            Command = 'Get-SnipeitAssetMaintenance'
            TestFile = 'Tests/Get-SnipeitAssetMaintenance.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'maintenances.store'
            Methods = @('POST')
            Route = '/api/v1/maintenances'
            Controller = 'MaintenancesController::store'
            Source = 'app/Http/Controllers/Api/MaintenancesController.php; app/Models/Maintenance.php; app/Observers/MaintenanceObserver.php'
            QueryFields = @()
            BodyFields = @('asset_id', 'supplier_id', 'name', 'asset_maintenance_type', 'maintenance_type_id', 'is_warranty', 'start_date', 'completion_date', 'expected_completion_date', 'asset_maintenance_time', 'cost', 'notes', 'url', 'responsible_party_id', 'completed_at', 'completed_by', 'asset_ids', 'image', 'image_delete')
            RequiredFields = @('name', 'maintenance_type_id', 'start_date')
            NullableFields = @('supplier_id', 'cost', 'notes', 'url', 'responsible_party_id', 'completion_date', 'expected_completion_date', 'completed_at', 'completed_by', 'asset_maintenance_time')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update Asset; company access to each asset'
            Command = 'New-SnipeitAssetMaintenance'
            TestFile = 'Tests/New-SnipeitAssetMaintenance.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'maintenances.show'
            Methods = @('GET')
            Route = '/api/v1/maintenances/{id}'
            Controller = 'MaintenancesController::show'
            Source = 'app/Http/Controllers/Api/MaintenancesController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view Asset; company access to maintenance asset'
            Command = 'Get-SnipeitAssetMaintenance'
            TestFile = 'Tests/Get-SnipeitAssetMaintenance.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'maintenances.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/maintenances/{id}'
            Controller = 'MaintenancesController::update'
            Source = 'app/Http/Controllers/Api/MaintenancesController.php; app/Models/Maintenance.php'
            QueryFields = @()
            BodyFields = @('asset_id', 'supplier_id', 'name', 'asset_maintenance_type', 'maintenance_type_id', 'is_warranty', 'start_date', 'completion_date', 'expected_completion_date', 'asset_maintenance_time', 'cost', 'notes', 'url', 'responsible_party_id', 'completed_at', 'completed_by', 'checked_out_to_id', 'checked_out_to_type')
            RequiredFields = @()
            NullableFields = @('supplier_id', 'cost', 'notes', 'url', 'responsible_party_id', 'completion_date', 'expected_completion_date', 'completed_at', 'completed_by', 'checked_out_to_id', 'checked_out_to_type', 'asset_maintenance_time')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update Asset; company access to existing and replacement asset'
            Command = 'Set-SnipeitAssetMaintenance'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'maintenances.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/maintenances/{id}'
            Controller = 'MaintenancesController::destroy'
            Source = 'app/Http/Controllers/Api/MaintenancesController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update Asset'
            Command = 'Remove-SnipeitAssetMaintenance'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'maintenance-types.index'
            Methods = @('GET')
            Route = '/api/v1/maintenance-types'
            Controller = 'MaintenanceTypesController::index'
            Source = 'app/Http/Controllers/Api/MaintenanceTypesController.php'
            QueryFields = @('search', 'name', 'deleted', 'order', 'sort', 'limit', 'offset')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view MaintenanceType'
            Command = 'Get-SnipeitMaintenanceType'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'maintenance-types.store'
            Methods = @('POST')
            Route = '/api/v1/maintenance-types'
            Controller = 'MaintenanceTypesController::store'
            Source = 'app/Http/Controllers/Api/MaintenanceTypesController.php'
            QueryFields = @()
            BodyFields = @('name')
            RequiredFields = @('name')
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'create MaintenanceType'
            Command = 'New-SnipeitMaintenanceType'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'maintenance-types.show'
            Methods = @('GET')
            Route = '/api/v1/maintenance-types/{id}'
            Controller = 'MaintenanceTypesController::show'
            Source = 'app/Http/Controllers/Api/MaintenanceTypesController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view MaintenanceType instance'
            Command = 'Get-SnipeitMaintenanceType'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'maintenance-types.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/maintenance-types/{id}'
            Controller = 'MaintenanceTypesController::update'
            Source = 'app/Http/Controllers/Api/MaintenanceTypesController.php'
            QueryFields = @()
            BodyFields = @('name')
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update MaintenanceType instance'
            Command = 'Set-SnipeitMaintenanceType'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'maintenance-types.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/maintenance-types/{id}'
            Controller = 'MaintenanceTypesController::destroy'
            Source = 'app/Http/Controllers/Api/MaintenanceTypesController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete MaintenanceType instance'
            Command = 'Remove-SnipeitMaintenanceType'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'licenses.index'
            Methods = @('GET')
            Route = '/api/v1/licenses'
            Controller = 'LicensesController::index'
            Source = 'app/Http/Controllers/Api/LicensesController.php'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset', 'status', 'company_id', 'expand_company_hierarchy', 'name', 'product_key', 'order_number', 'purchase_order', 'license_name', 'license_email', 'manufacturer_id', 'supplier_id', 'category_id', 'depreciation_id', 'created_by', 'maintained', 'expires', 'deleted')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view License; product_key and serial search require viewKeys'
            Command = 'Get-SnipeitLicense'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'licenses.store'
            Methods = @('POST')
            Route = '/api/v1/licenses'
            Controller = 'LicensesController::store'
            Source = 'app/Http/Controllers/Api/LicensesController.php'
            QueryFields = @()
            BodyFields = @('name', 'license_email', 'license_name', 'seats', 'category_id', 'company_id', 'supplier_id', 'manufacturer_id', 'order_number', 'purchase_order', 'purchase_date', 'purchase_cost', 'notes', 'expiration_date', 'termination_date', 'maintained', 'reassignable', 'serial', 'depreciation_id', 'min_amt')
            RequiredFields = @('name', 'seats', 'category_id')
            NullableFields = @('company_id', 'supplier_id', 'manufacturer_id', 'purchase_date', 'purchase_cost', 'notes', 'expiration_date', 'termination_date', 'license_name', 'license_email', 'min_amt')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'create License'
            Command = 'New-SnipeitLicense'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'licenses.show'
            Methods = @('GET')
            Route = '/api/v1/licenses/{id}'
            Controller = 'LicensesController::show'
            Source = 'app/Http/Controllers/Api/LicensesController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view License'
            Command = 'Get-SnipeitLicense'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'licenses.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/licenses/{id}'
            Controller = 'LicensesController::update'
            Source = 'app/Http/Controllers/Api/LicensesController.php'
            QueryFields = @()
            BodyFields = @('name', 'license_email', 'license_name', 'seats', 'category_id', 'company_id', 'supplier_id', 'manufacturer_id', 'order_number', 'purchase_order', 'purchase_date', 'purchase_cost', 'notes', 'expiration_date', 'termination_date', 'maintained', 'reassignable', 'serial', 'depreciation_id', 'min_amt')
            RequiredFields = @()
            NullableFields = @('company_id', 'supplier_id', 'manufacturer_id', 'purchase_date', 'purchase_cost', 'notes', 'expiration_date', 'termination_date', 'license_name', 'license_email', 'min_amt')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update License'
            Command = 'Set-SnipeitLicense'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'licenses.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/licenses/{id}'
            Controller = 'LicensesController::destroy'
            Source = 'app/Http/Controllers/Api/LicensesController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete License instance'
            Command = 'Remove-SnipeitLicense'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'locations.index'
            Methods = @('GET')
            Route = '/api/v1/locations'
            Controller = 'LocationsController::index'
            Source = 'app/Http/Controllers/Api/LocationsController.php'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset', 'name', 'address', 'address2', 'city', 'zip', 'country', 'manager_id', 'company_id', 'parent_id', 'status', 'tag_color')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view Location'
            Command = 'Get-SnipeitLocation'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'locations.store'
            Methods = @('POST')
            Route = '/api/v1/locations'
            Controller = 'LocationsController::store'
            Source = 'app/Http/Controllers/Api/LocationsController.php'
            QueryFields = @()
            BodyFields = @('name', 'parent_id', 'currency', 'address', 'address2', 'city', 'state', 'country', 'zip', 'phone', 'fax', 'manager_id', 'image', 'ldap_ou', 'company_id', 'tag_color', 'notes')
            RequiredFields = @('name')
            NullableFields = @('parent_id', 'manager_id', 'zip', 'phone', 'fax', 'company_id', 'address', 'address2', 'city', 'state', 'country')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'create Location'
            Command = 'New-SnipeitLocation'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'locations.show'
            Methods = @('GET')
            Route = '/api/v1/locations/{id}'
            Controller = 'LocationsController::show'
            Source = 'app/Http/Controllers/Api/LocationsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view Location'
            Command = 'Get-SnipeitLocation'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'locations.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/locations/{id}'
            Controller = 'LocationsController::update'
            Source = 'app/Http/Controllers/Api/LocationsController.php'
            QueryFields = @()
            BodyFields = @('name', 'parent_id', 'currency', 'address', 'address2', 'city', 'state', 'country', 'zip', 'phone', 'fax', 'manager_id', 'image', 'ldap_ou', 'company_id', 'tag_color', 'notes', 'image_delete')
            RequiredFields = @()
            NullableFields = @('parent_id', 'manager_id', 'zip', 'phone', 'fax', 'company_id', 'address', 'address2', 'city', 'state', 'country')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update Location'
            Command = 'Set-SnipeitLocation'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'locations.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/locations/{id}'
            Controller = 'LocationsController::destroy'
            Source = 'app/Http/Controllers/Api/LocationsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete Location class and instance'
            Command = 'Remove-SnipeitLocation'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'manufacturers.index'
            Methods = @('GET')
            Route = '/api/v1/manufacturers'
            Controller = 'ManufacturersController::index'
            Source = 'app/Http/Controllers/Api/ManufacturersController.php'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset', 'deleted', 'status', 'name', 'url', 'support_url', 'warranty_lookup_url', 'support_phone', 'support_email', 'tag_color')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view Manufacturer'
            Command = 'Get-SnipeitManufacturer'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'manufacturers.store'
            Methods = @('POST')
            Route = '/api/v1/manufacturers'
            Controller = 'ManufacturersController::store'
            Source = 'app/Http/Controllers/Api/ManufacturersController.php'
            QueryFields = @()
            BodyFields = @('name', 'url', 'support_url', 'support_phone', 'support_email', 'image', 'warranty_lookup_url', 'tag_color', 'notes')
            RequiredFields = @('name')
            NullableFields = @('url', 'support_url', 'support_phone', 'support_email', 'warranty_lookup_url')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'create Manufacturer'
            Command = 'New-SnipeitManufacturer'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'manufacturers.show'
            Methods = @('GET')
            Route = '/api/v1/manufacturers/{id}'
            Controller = 'ManufacturersController::show'
            Source = 'app/Http/Controllers/Api/ManufacturersController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view Manufacturer'
            Command = 'Get-SnipeitManufacturer'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'manufacturers.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/manufacturers/{id}'
            Controller = 'ManufacturersController::update'
            Source = 'app/Http/Controllers/Api/ManufacturersController.php'
            QueryFields = @()
            BodyFields = @('name', 'url', 'support_url', 'support_phone', 'support_email', 'image', 'warranty_lookup_url', 'tag_color', 'notes', 'image_delete')
            RequiredFields = @()
            NullableFields = @('url', 'support_url', 'support_phone', 'support_email', 'warranty_lookup_url')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update Manufacturer'
            Command = 'Set-SnipeitManufacturer'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'manufacturers.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/manufacturers/{id}'
            Controller = 'ManufacturersController::destroy'
            Source = 'app/Http/Controllers/Api/ManufacturersController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete Manufacturer instance'
            Command = 'Remove-SnipeitManufacturer'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'models.index'
            Methods = @('GET')
            Route = '/api/v1/models'
            Controller = 'AssetModelsController::index'
            Source = 'app/Http/Controllers/Api/AssetModelsController.php'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset', 'status', 'name', 'model_number', 'requestable', 'notes', 'category_id', 'depreciation_id')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view AssetModel'
            Command = 'Get-SnipeitModel'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'models.store'
            Methods = @('POST')
            Route = '/api/v1/models'
            Controller = 'AssetModelsController::store'
            Source = 'app/Http/Controllers/Api/AssetModelsController.php'
            QueryFields = @()
            BodyFields = @('name', 'model_number', 'category_id', 'manufacturer_id', 'fieldset_id', 'eol', 'notes', 'requestable', 'image', 'min_amt', 'depreciation_id', 'require_serial')
            RequiredFields = @('name', 'category_id')
            NullableFields = @('fieldset_id', 'eol', 'notes', 'model_number', 'manufacturer_id', 'min_amt')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'create AssetModel'
            Command = 'New-SnipeitModel'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'models.show'
            Methods = @('GET')
            Route = '/api/v1/models/{id}'
            Controller = 'AssetModelsController::show'
            Source = 'app/Http/Controllers/Api/AssetModelsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view AssetModel'
            Command = 'Get-SnipeitModel'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'models.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/models/{id}'
            Controller = 'AssetModelsController::update'
            Source = 'app/Http/Controllers/Api/AssetModelsController.php'
            QueryFields = @()
            BodyFields = @('name', 'model_number', 'category_id', 'manufacturer_id', 'fieldset_id', 'eol', 'notes', 'requestable', 'image', 'min_amt', 'depreciation_id', 'require_serial', 'image_delete')
            RequiredFields = @()
            NullableFields = @('fieldset_id', 'eol', 'notes', 'model_number', 'manufacturer_id', 'min_amt')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update AssetModel; create AssetModel via StoreAssetModelRequest'
            Command = 'Set-SnipeitModel'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'models.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/models/{id}'
            Controller = 'AssetModelsController::destroy'
            Source = 'app/Http/Controllers/Api/AssetModelsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete AssetModel class and instance'
            Command = 'Remove-SnipeitModel'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'statuslabels.index'
            Methods = @('GET')
            Route = '/api/v1/statuslabels'
            Controller = 'StatuslabelsController::index'
            Source = 'app/Http/Controllers/Api/StatuslabelsController.php'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset', 'name', 'status_type')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view Statuslabel'
            Command = 'Get-SnipeitStatus'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'statuslabels.store'
            Methods = @('POST')
            Route = '/api/v1/statuslabels'
            Controller = 'StatuslabelsController::store'
            Source = 'app/Http/Controllers/Api/StatuslabelsController.php'
            QueryFields = @()
            BodyFields = @('name', 'type', 'notes', 'show_in_nav', 'default_label', 'color')
            RequiredFields = @('name', 'type')
            NullableFields = @('notes')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'create Statuslabel'
            Command = 'New-SnipeitStatus'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'statuslabels.show'
            Methods = @('GET')
            Route = '/api/v1/statuslabels/{id}'
            Controller = 'StatuslabelsController::show'
            Source = 'app/Http/Controllers/Api/StatuslabelsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view Statuslabel'
            Command = 'Get-SnipeitStatus'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'statuslabels.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/statuslabels/{id}'
            Controller = 'StatuslabelsController::update'
            Source = 'app/Http/Controllers/Api/StatuslabelsController.php'
            QueryFields = @()
            BodyFields = @('name', 'type', 'notes', 'show_in_nav', 'default_label', 'color')
            RequiredFields = @('type')
            NullableFields = @('notes')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update Statuslabel'
            Command = 'Set-SnipeitStatus'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'statuslabels.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/statuslabels/{id}'
            Controller = 'StatuslabelsController::destroy'
            Source = 'app/Http/Controllers/Api/StatuslabelsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete Statuslabel class and instance'
            Command = 'Remove-SnipeitStatus'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'suppliers.index'
            Methods = @('GET')
            Route = '/api/v1/suppliers'
            Controller = 'SuppliersController::index'
            Source = 'app/Http/Controllers/Api/SuppliersController.php'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset', 'name', 'address', 'address2', 'city', 'zip', 'country', 'fax', 'email', 'url', 'notes')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view Supplier'
            Command = 'Get-SnipeitSupplier'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'suppliers.store'
            Methods = @('POST')
            Route = '/api/v1/suppliers'
            Controller = 'SuppliersController::store'
            Source = 'app/Http/Controllers/Api/SuppliersController.php'
            QueryFields = @()
            BodyFields = @('name', 'address', 'address2', 'city', 'state', 'country', 'zip', 'contact', 'phone', 'fax', 'email', 'url', 'notes', 'image', 'tag_color')
            RequiredFields = @('name')
            NullableFields = @('address', 'address2', 'city', 'state', 'country', 'zip', 'contact', 'phone', 'fax', 'email', 'url', 'notes')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'create Supplier'
            Command = 'New-SnipeitSupplier'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'suppliers.show'
            Methods = @('GET')
            Route = '/api/v1/suppliers/{id}'
            Controller = 'SuppliersController::show'
            Source = 'app/Http/Controllers/Api/SuppliersController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view Supplier'
            Command = 'Get-SnipeitSupplier'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'suppliers.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/suppliers/{id}'
            Controller = 'SuppliersController::update'
            Source = 'app/Http/Controllers/Api/SuppliersController.php'
            QueryFields = @()
            BodyFields = @('name', 'address', 'address2', 'city', 'state', 'country', 'zip', 'contact', 'phone', 'fax', 'email', 'url', 'notes', 'image', 'tag_color', 'image_delete')
            RequiredFields = @()
            NullableFields = @('address', 'address2', 'city', 'state', 'country', 'zip', 'contact', 'phone', 'fax', 'email', 'url', 'notes')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update Supplier'
            Command = 'Set-SnipeitSupplier'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'suppliers.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/suppliers/{id}'
            Controller = 'SuppliersController::destroy'
            Source = 'app/Http/Controllers/Api/SuppliersController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete Supplier instance'
            Command = 'Remove-SnipeitSupplier'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'users.index'
            Methods = @('GET')
            Route = '/api/v1/users'
            Controller = 'UsersController::index'
            Source = 'app/Http/Controllers/Api/UsersController.php'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset', 'company_id', 'location_id', 'department_id', 'group_id', 'deleted', 'all', 'activated', 'admins', 'superadmins', 'expand_company_hierarchy', 'phone', 'mobile', 'created_by', 'email', 'username', 'first_name', 'last_name', 'display_name', 'employee_num', 'state', 'country', 'website', 'zip', 'manager_id', 'ldap_import', 'remote', 'vip', 'two_factor_enrolled', 'two_factor_optin', 'start_date', 'end_date', 'assets_count', 'consumables_count', 'licenses_count', 'accessories_count', 'assigned_maintenances_count', 'manages_users_count', 'manages_locations_count', 'autoassign_licenses', 'locale')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view User'
            Command = 'Get-SnipeitUser'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'users.store'
            Methods = @('POST')
            Route = '/api/v1/users'
            Controller = 'UsersController::store'
            Source = 'app/Http/Controllers/Api/UsersController.php'
            QueryFields = @()
            BodyFields = @('first_name', 'last_name', 'username', 'password', 'password_confirmation', 'email', 'phone', 'jobtitle', 'manager_id', 'employee_num', 'activated', 'notes', 'company_id', 'company_ids', 'location_id', 'department_id', 'groups', 'autoassign_licenses', 'remote', 'start_date', 'end_date', 'vip', 'display_name', 'address', 'city', 'state', 'country', 'zip', 'locale', 'mobile', 'website', 'gravatar', 'scim_externalid', 'permissions', 'ldap_import', 'avatar', 'send_welcome')
            RequiredFields = @('first_name')
            NullableFields = @('manager_id', 'company_id', 'company_ids', 'location_id', 'department_id', 'phone', 'jobtitle', 'employee_num', 'start_date', 'end_date', 'notes', 'last_name', 'display_name', 'email', 'locale', 'website', 'address', 'city', 'state', 'country', 'zip')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'create User; privileged permission changes are separately gated'
            Command = 'New-SnipeitUser'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'users.show'
            Methods = @('GET')
            Route = '/api/v1/users/{id}'
            Controller = 'UsersController::show'
            Source = 'app/Http/Controllers/Api/UsersController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view User class and instance'
            Command = 'Get-SnipeitUser'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'users.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/users/{id}'
            Controller = 'UsersController::update'
            Source = 'app/Http/Controllers/Api/UsersController.php'
            QueryFields = @()
            BodyFields = @('first_name', 'last_name', 'username', 'password', 'password_confirmation', 'email', 'phone', 'jobtitle', 'manager_id', 'employee_num', 'activated', 'notes', 'company_id', 'company_ids', 'location_id', 'department_id', 'groups', 'autoassign_licenses', 'remote', 'start_date', 'end_date', 'vip', 'display_name', 'address', 'city', 'state', 'country', 'zip', 'locale', 'mobile', 'website', 'gravatar', 'scim_externalid', 'permissions', 'ldap_import', 'avatar', 'image_delete')
            RequiredFields = @()
            NullableFields = @('manager_id', 'company_id', 'company_ids', 'location_id', 'department_id', 'phone', 'jobtitle', 'employee_num', 'start_date', 'end_date', 'notes', 'last_name', 'display_name', 'email', 'locale', 'website', 'address', 'city', 'state', 'country', 'zip')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update User instance; authentication and privileged permission changes are separately gated'
            Command = 'Set-SnipeitUser'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'users.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/users/{id}'
            Controller = 'UsersController::destroy'
            Source = 'app/Http/Controllers/Api/UsersController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete User class and instance'
            Command = 'Remove-SnipeitUser'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'kits.index'
            Methods = @('GET')
            Route = '/api/v1/kits'
            Controller = 'PredefinedKitsController::index'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @('search', 'order', 'sort', 'limit', 'offset')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view PredefinedKit'
            Command = 'Get-SnipeitKit'
            TestFile = 'Tests/Kit.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'kits.store'
            Methods = @('POST')
            Route = '/api/v1/kits'
            Controller = 'PredefinedKitsController::store'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @('name')
            RequiredFields = @('name')
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'create PredefinedKit'
            Command = 'New-SnipeitKit'
            TestFile = 'Tests/Kit.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'kits.show'
            Methods = @('GET')
            Route = '/api/v1/kits/{id}'
            Controller = 'PredefinedKitsController::show'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view PredefinedKit'
            Command = 'Get-SnipeitKit'
            TestFile = 'Tests/Kit.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'kits.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/kits/{id}'
            Controller = 'PredefinedKitsController::update'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @('name')
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update PredefinedKit'
            Command = 'Set-SnipeitKit'
            TestFile = 'Tests/Kit.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'kits.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/kits/{id}'
            Controller = 'PredefinedKitsController::destroy'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete PredefinedKit'
            Command = 'Remove-SnipeitKit'
            TestFile = 'Tests/Kit.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'licenses.seats.index'
            Methods = @('GET')
            Route = '/api/v1/licenses/{id}/seats'
            Controller = 'LicenseSeatsController::index'
            Source = 'app/Http/Controllers/Api/LicenseSeatsController.php:26-78'
            QueryFields = @('status', 'search', 'order', 'sort', 'offset', 'limit')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view License instance'
            Command = 'Get-SnipeitLicenseSeat'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'licenses.seats.show'
            Methods = @('GET')
            Route = '/api/v1/licenses/{id}/seats/{seat_id}'
            Controller = 'LicenseSeatsController::show'
            Source = 'app/Http/Controllers/Api/LicenseSeatsController.php:57-75'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view License'
            Command = 'Get-SnipeitLicenseSeat'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'licenses.seats.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/licenses/{id}/seats/{seat_id}'
            Controller = 'LicenseSeatsController::update'
            Source = 'app/Http/Controllers/Api/LicenseSeatsController.php:80-142'
            QueryFields = @()
            BodyFields = @('assigned_to', 'asset_id', 'notes')
            RequiredFields = @()
            NullableFields = @('assigned_to', 'asset_id', 'notes')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'checkout License; company checks on assignment target'
            Command = 'Set-SnipeitLicenseSeat'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'imports.index'
            Methods = @('GET')
            Route = '/api/v1/imports'
            Controller = 'ImportController::index'
            Source = 'app/Http/Controllers/Api/ImportController.php:28-41'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectArray'
            Pagination = 'UnpaginatedArray'
            Authorization = 'import'
            Command = 'Get-SnipeitImport'
            TestFile = 'Tests/Get-SnipeitImport.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'imports.store'
            Methods = @('POST')
            Route = '/api/v1/imports'
            Controller = 'ImportController::store'
            Source = 'app/Http/Controllers/Api/ImportController.php:49-208'
            QueryFields = @()
            BodyFields = @('files[]')
            RequiredFields = @('files[]')
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'import'
            Command = 'New-SnipeitImport'
            TestFile = 'Tests/New-SnipeitImport.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'imports.show'
            Methods = @('GET')
            Route = '/api/v1/imports/{id}'
            Controller = 'ImportController::show'
            Source = 'routes/api.php:694-706'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = ''
            Command = ''
            TestFile = ''
            State = 'BlockedServer'
        }
        @{
            Key = 'imports.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/imports/{id}'
            Controller = 'ImportController::update'
            Source = 'routes/api.php:694-706'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = ''
            Command = ''
            TestFile = ''
            State = 'BlockedServer'
        }
        @{
            Key = 'imports.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/imports/{id}'
            Controller = 'ImportController::destroy'
            Source = 'app/Http/Controllers/Api/ImportController.php:320-355'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'import'
            Command = 'Remove-SnipeitImport'
            TestFile = 'Tests/Remove-SnipeitImport.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'imports.process'
            Methods = @('POST')
            Route = '/api/v1/imports/process/{import}'
            Controller = 'ImportController::process'
            Source = 'app/Http/Controllers/Api/ImportController.php:216-310'
            QueryFields = @()
            BodyFields = @('import-type', 'column-mappings', 'import-update', 'send-welcome', 'run-backup', 'offset', 'limit', 'match_username', 'match_email', 'match_firstnamelastname', 'match_flastname', 'match_firstname')
            RequiredFields = @('import-type')
            NullableFields = @('column-mappings', 'offset', 'limit')
            ResponseKind = 'ImportResult'
            Pagination = 'None'
            Authorization = 'import'
            Command = 'Invoke-SnipeitImport'
            TestFile = 'Tests/Invoke-SnipeitImport.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'settings.index'
            Methods = @('GET')
            Route = '/api/v1/settings'
            Controller = 'SettingsController::index'
            Source = 'routes/api.php:1002-1012'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = ''
            Command = ''
            TestFile = ''
            State = 'BlockedServer'
        }
        @{
            Key = 'settings.store'
            Methods = @('POST')
            Route = '/api/v1/settings'
            Controller = 'SettingsController::store'
            Source = 'routes/api.php:1002-1012'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = ''
            Command = ''
            TestFile = ''
            State = 'BlockedServer'
        }
        @{
            Key = 'settings.update'
            Methods = @('PUT', 'PATCH')
            Route = '/api/v1/settings/{id}'
            Controller = 'SettingsController::update'
            Source = 'routes/api.php:1002-1012'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = ''
            Command = ''
            TestFile = ''
            State = 'BlockedServer'
        }
        @{
            Key = 'kits.licenses.index'
            Methods = @('GET')
            Route = '/api/v1/kits/{kit_id}/licenses'
            Controller = 'PredefinedKitsController::indexLicenses'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'None'
            Authorization = 'view PredefinedKit'
            Command = 'Get-SnipeitKitItem'
            TestFile = 'Tests/Get-SnipeitKitItem.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'kits.licenses.attach'
            Methods = @('POST')
            Route = '/api/v1/kits/{kit_id}/licenses'
            Controller = 'PredefinedKitsController::storeLicense'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @('license', 'quantity')
            RequiredFields = @('license')
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update PredefinedKit and view License instance'
            Command = 'Add-SnipeitKitItem'
            TestFile = 'Tests/Add-SnipeitKitItem.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'kits.licenses.update'
            Methods = @('PUT')
            Route = '/api/v1/kits/{kit_id}/licenses/{license_id}'
            Controller = 'PredefinedKitsController::updateLicense'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @('quantity')
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update PredefinedKit and view License instance'
            Command = 'Set-SnipeitKitItem'
            TestFile = 'Tests/Set-SnipeitKitItem.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'kits.licenses.detach'
            Methods = @('DELETE')
            Route = '/api/v1/kits/{kit_id}/licenses/{license_id}'
            Controller = 'PredefinedKitsController::detachLicense'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update PredefinedKit'
            Command = 'Remove-SnipeitKitItem'
            TestFile = 'Tests/Remove-SnipeitKitItem.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'kits.models.index'
            Methods = @('GET')
            Route = '/api/v1/kits/{kit_id}/models'
            Controller = 'PredefinedKitsController::indexModels'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'None'
            Authorization = 'view PredefinedKit'
            Command = 'Get-SnipeitKitItem'
            TestFile = 'Tests/Get-SnipeitKitItem.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'kits.models.attach'
            Methods = @('POST')
            Route = '/api/v1/kits/{kit_id}/models'
            Controller = 'PredefinedKitsController::storeModel'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @('model', 'quantity')
            RequiredFields = @('model')
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update PredefinedKit and view AssetModel instance'
            Command = 'Add-SnipeitKitItem'
            TestFile = 'Tests/Add-SnipeitKitItem.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'kits.models.update'
            Methods = @('PUT')
            Route = '/api/v1/kits/{kit_id}/models/{model_id}'
            Controller = 'PredefinedKitsController::updateModel'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @('quantity')
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update PredefinedKit and view AssetModel instance'
            Command = 'Set-SnipeitKitItem'
            TestFile = 'Tests/Set-SnipeitKitItem.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'kits.models.detach'
            Methods = @('DELETE')
            Route = '/api/v1/kits/{kit_id}/models/{model_id}'
            Controller = 'PredefinedKitsController::detachModel'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update PredefinedKit'
            Command = 'Remove-SnipeitKitItem'
            TestFile = 'Tests/Remove-SnipeitKitItem.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'kits.accessories.index'
            Methods = @('GET')
            Route = '/api/v1/kits/{kit_id}/accessories'
            Controller = 'PredefinedKitsController::indexAccessories'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'None'
            Authorization = 'view PredefinedKit'
            Command = 'Get-SnipeitKitItem'
            TestFile = 'Tests/Get-SnipeitKitItem.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'kits.accessories.attach'
            Methods = @('POST')
            Route = '/api/v1/kits/{kit_id}/accessories'
            Controller = 'PredefinedKitsController::storeAccessory'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @('accessory', 'quantity')
            RequiredFields = @('accessory')
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update PredefinedKit and view Accessory instance'
            Command = 'Add-SnipeitKitItem'
            TestFile = 'Tests/Add-SnipeitKitItem.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'kits.accessories.update'
            Methods = @('PUT')
            Route = '/api/v1/kits/{kit_id}/accessories/{accessory_id}'
            Controller = 'PredefinedKitsController::updateAccessory'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @('quantity')
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update PredefinedKit and view Accessory instance'
            Command = 'Set-SnipeitKitItem'
            TestFile = 'Tests/Set-SnipeitKitItem.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'kits.accessories.detach'
            Methods = @('DELETE')
            Route = '/api/v1/kits/{kit_id}/accessories/{accessory_id}'
            Controller = 'PredefinedKitsController::detachAccessory'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update PredefinedKit'
            Command = 'Remove-SnipeitKitItem'
            TestFile = 'Tests/Remove-SnipeitKitItem.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'kits.consumables.index'
            Methods = @('GET')
            Route = '/api/v1/kits/{kit_id}/consumables'
            Controller = 'PredefinedKitsController::indexConsumables'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'None'
            Authorization = 'view PredefinedKit'
            Command = 'Get-SnipeitKitItem'
            TestFile = 'Tests/Get-SnipeitKitItem.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'kits.consumables.attach'
            Methods = @('POST')
            Route = '/api/v1/kits/{kit_id}/consumables'
            Controller = 'PredefinedKitsController::storeConsumable'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @('consumable', 'quantity')
            RequiredFields = @('consumable')
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update PredefinedKit and view Consumable instance'
            Command = 'Add-SnipeitKitItem'
            TestFile = 'Tests/Add-SnipeitKitItem.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'kits.consumables.update'
            Methods = @('PUT')
            Route = '/api/v1/kits/{kit_id}/consumables/{consumable_id}'
            Controller = 'PredefinedKitsController::updateConsumable'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @('quantity')
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update PredefinedKit and view Consumable instance'
            Command = 'Set-SnipeitKitItem'
            TestFile = 'Tests/Set-SnipeitKitItem.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'kits.consumables.detach'
            Methods = @('DELETE')
            Route = '/api/v1/kits/{kit_id}/consumables/{consumable_id}'
            Controller = 'PredefinedKitsController::detachConsumable'
            Source = 'app/Http/Controllers/Api/PredefinedKitsController.php'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update PredefinedKit'
            Command = 'Remove-SnipeitKitItem'
            TestFile = 'Tests/Remove-SnipeitKitItem.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'files.index'
            Methods = @('GET')
            Route = '/api/v1/{object_type}/{id}/files'
            Controller = 'UploadedFilesController::index'
            Source = 'app/Http/Controllers/Api/UploadedFilesController.php::index'
            QueryFields = @('search', 'sort', 'order', 'offset', 'limit')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'files'
            Command = 'Get-SnipeitFile'
            TestFile = 'Tests/Get-SnipeitFile.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'files.show'
            Methods = @('GET')
            Route = '/api/v1/{object_type}/{id}/files/{file_id}'
            Controller = 'UploadedFilesController::show'
            Source = 'app/Http/Controllers/Api/UploadedFilesController.php:147-183'
            QueryFields = @('inline')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'BinaryDownload'
            Pagination = 'None'
            Authorization = 'files'
            Command = 'Save-SnipeitFile'
            TestFile = 'Tests/Save-SnipeitFile.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'files.store'
            Methods = @('POST')
            Route = '/api/v1/{object_type}/{id}/files'
            Controller = 'UploadedFilesController::store'
            Source = 'app/Http/Controllers/Api/UploadedFilesController.php::store'
            QueryFields = @()
            BodyFields = @('file[]', 'notes')
            RequiredFields = @('file[]')
            NullableFields = @('notes')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'manageFiles'
            Command = 'New-SnipeitFile'
            TestFile = 'Tests/New-SnipeitFile.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'files.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/{object_type}/{id}/files/{file_id}/delete'
            Controller = 'UploadedFilesController::destroy'
            Source = 'app/Http/Controllers/Api/UploadedFilesController.php::destroy'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'manageFiles'
            Command = 'Remove-SnipeitFile'
            TestFile = 'Tests/Remove-SnipeitFile.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'files.audits.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/audits/{id}/files/{file_id}/delete'
            Controller = 'UploadedFilesController::destroy'
            Source = 'routes/api.php:1416-1423'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = ''
            Command = ''
            TestFile = ''
            State = 'BlockedServer'
        }
        @{
            Key = 'hardware.files.index'
            Methods = @('GET')
            Route = '/api/v1/hardware/{id}/files'
            Controller = 'UploadedFilesController::index'
            Source = 'app/Http/Controllers/Api/UploadedFilesController.php:30-79'
            QueryFields = @('search', 'order', 'sort', 'offset', 'limit')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'files on Asset instance'
            Command = 'Get-SnipeitAssetFile'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'hardware.files.show'
            Methods = @('GET')
            Route = '/api/v1/hardware/{id}/files/{file_id}'
            Controller = 'UploadedFilesController::show'
            Source = 'routes/api.php:1398'
            QueryFields = @('inline')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'BinaryDownload'
            Pagination = 'None'
            Authorization = 'files on Asset instance'
            Command = 'Get-SnipeitAssetFile'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'hardware.files.store'
            Methods = @('POST')
            Route = '/api/v1/hardware/{id}/files'
            Controller = 'UploadedFilesController::store'
            Source = 'routes/api.php:1407'
            QueryFields = @()
            BodyFields = @('file[]', 'notes')
            RequiredFields = @('file[]')
            NullableFields = @('notes')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'manageFiles on Asset instance'
            Command = 'New-SnipeitAssetFile'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'hardware.files.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/hardware/{id}/files/{file_id}/delete'
            Controller = 'UploadedFilesController::destroy'
            Source = 'routes/api.php:1416'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'manageFiles on Asset instance'
            Command = 'Remove-SnipeitAssetFile'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'models.files.index'
            Methods = @('GET')
            Route = '/api/v1/models/{id}/files'
            Controller = 'UploadedFilesController::index'
            Source = 'app/Http/Controllers/Api/UploadedFilesController.php:30-79'
            QueryFields = @('search', 'order', 'sort', 'offset', 'limit')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'files on AssetModel instance'
            Command = 'Get-SnipeitModelFile'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'models.files.show'
            Methods = @('GET')
            Route = '/api/v1/models/{id}/files/{file_id}'
            Controller = 'UploadedFilesController::show'
            Source = 'routes/api.php:1398'
            QueryFields = @('inline')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'BinaryDownload'
            Pagination = 'None'
            Authorization = 'files on AssetModel instance'
            Command = 'Get-SnipeitModelFile'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'models.files.store'
            Methods = @('POST')
            Route = '/api/v1/models/{id}/files'
            Controller = 'UploadedFilesController::store'
            Source = 'routes/api.php:1407'
            QueryFields = @()
            BodyFields = @('file[]', 'notes')
            RequiredFields = @('file[]')
            NullableFields = @('notes')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'manageFiles on AssetModel instance'
            Command = 'New-SnipeitModelFile'
            TestFile = 'Tests/Coverage-New-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'models.files.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/models/{id}/files/{file_id}/delete'
            Controller = 'UploadedFilesController::destroy'
            Source = 'routes/api.php:1416'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'manageFiles on AssetModel instance'
            Command = 'Remove-SnipeitModelFile'
            TestFile = 'Tests/Coverage-Remove-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'reports.depreciation'
            Methods = @('GET')
            Route = '/api/v1/reports/depreciation'
            Controller = 'AssetsController::index'
            Source = 'app/Http/Controllers/Api/AssetsController.php::index'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset', 'status_id', 'model_id', 'category_id', 'location_id', 'supplier_id', 'company_id', 'assigned_to', 'assigned_type', 'rtd_location_id', 'asset_tag', 'serial', 'status_type', 'status', 'requestable', 'asset_eol_date', 'expand_company_hierarchy', 'manufacturer_id', 'depreciation_id', 'byod', 'order_number', 'components')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'reports.view'
            Command = 'Get-SnipeitDepreciationReport'
            TestFile = 'Tests/Get-SnipeitDepreciationReport.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'accessories.selectlist'
            Methods = @('GET')
            Route = '/api/v1/accessories/selectlist'
            Controller = 'AccessoriesController::selectlist'
            Source = 'routes/api.php'
            QueryFields = @('search', 'page')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'Select2'
            Pagination = 'Select2'
            Authorization = 'view.selectlists'
            Command = 'Get-SnipeitSelectList'
            TestFile = 'Tests/Get-SnipeitSelectList.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'categories.selectlist'
            Methods = @('GET')
            Route = '/api/v1/categories/{item_type}/selectlist'
            Controller = 'CategoriesController::selectlist'
            Source = 'routes/api.php'
            QueryFields = @('search', 'page')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'Select2'
            Pagination = 'Select2'
            Authorization = 'view.selectlists'
            Command = 'Get-SnipeitSelectList'
            TestFile = 'Tests/Get-SnipeitSelectList.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'companies.selectlist'
            Methods = @('GET')
            Route = '/api/v1/companies/selectlist'
            Controller = 'CompaniesController::selectlist'
            Source = 'routes/api.php'
            QueryFields = @('search', 'page', 'excludeId', 'onlyTopLevel')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'Select2'
            Pagination = 'Select2'
            Authorization = 'view.selectlists'
            Command = 'Get-SnipeitSelectList'
            TestFile = 'Tests/Get-SnipeitSelectList.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'departments.selectlist'
            Methods = @('GET')
            Route = '/api/v1/departments/selectlist'
            Controller = 'DepartmentsController::selectlist'
            Source = 'routes/api.php'
            QueryFields = @('search', 'page')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'Select2'
            Pagination = 'Select2'
            Authorization = 'view.selectlists'
            Command = 'Get-SnipeitSelectList'
            TestFile = 'Tests/Get-SnipeitSelectList.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'consumables.selectlist'
            Methods = @('GET')
            Route = '/api/v1/consumables/selectlist'
            Controller = 'ConsumablesController::selectlist'
            Source = 'routes/api.php'
            QueryFields = @('search', 'page')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'Select2'
            Pagination = 'Select2'
            Authorization = 'view.selectlists'
            Command = 'Get-SnipeitSelectList'
            TestFile = 'Tests/Get-SnipeitSelectList.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'hardware.selectlist'
            Methods = @('GET')
            Route = '/api/v1/hardware/selectlist'
            Controller = 'AssetsController::selectlist'
            Source = 'routes/api.php'
            QueryFields = @('search', 'page', 'companyId', 'excludeId', 'statusType')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'Select2'
            Pagination = 'Select2'
            Authorization = 'view.selectlists'
            Command = 'Get-SnipeitSelectList'
            TestFile = 'Tests/Get-SnipeitSelectList.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'licenses.selectlist'
            Methods = @('GET')
            Route = '/api/v1/licenses/selectlist'
            Controller = 'LicensesController::selectlist'
            Source = 'routes/api.php'
            QueryFields = @('search', 'page')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'Select2'
            Pagination = 'Select2'
            Authorization = 'view.selectlists'
            Command = 'Get-SnipeitSelectList'
            TestFile = 'Tests/Get-SnipeitSelectList.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'locations.selectlist'
            Methods = @('GET')
            Route = '/api/v1/locations/selectlist'
            Controller = 'LocationsController::selectlist'
            Source = 'routes/api.php'
            QueryFields = @('search', 'page', 'companyId', 'excludeId')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'Select2'
            Pagination = 'Select2'
            Authorization = 'self.edit_location or view.selectlists'
            Command = 'Get-SnipeitSelectList'
            TestFile = 'Tests/Get-SnipeitSelectList.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'manufacturers.selectlist'
            Methods = @('GET')
            Route = '/api/v1/manufacturers/selectlist'
            Controller = 'ManufacturersController::selectlist'
            Source = 'routes/api.php'
            QueryFields = @('search', 'page')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'Select2'
            Pagination = 'Select2'
            Authorization = 'view.selectlists'
            Command = 'Get-SnipeitSelectList'
            TestFile = 'Tests/Get-SnipeitSelectList.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'models.selectlist'
            Methods = @('GET')
            Route = '/api/v1/models/selectlist'
            Controller = 'AssetModelsController::selectlist'
            Source = 'routes/api.php'
            QueryFields = @('search', 'page')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'Select2'
            Pagination = 'Select2'
            Authorization = 'view.selectlists'
            Command = 'Get-SnipeitSelectList'
            TestFile = 'Tests/Get-SnipeitSelectList.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'statuslabels.selectlist'
            Methods = @('GET')
            Route = '/api/v1/statuslabels/selectlist'
            Controller = 'StatuslabelsController::selectlist'
            Source = 'routes/api.php'
            QueryFields = @('search', 'page', 'deployable', 'pending', 'archived')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'Select2'
            Pagination = 'Select2'
            Authorization = 'view.selectlists'
            Command = 'Get-SnipeitSelectList'
            TestFile = 'Tests/Get-SnipeitSelectList.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'suppliers.selectlist'
            Methods = @('GET')
            Route = '/api/v1/suppliers/selectlist'
            Controller = 'SuppliersController::selectlist'
            Source = 'routes/api.php'
            QueryFields = @('search', 'page')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'Select2'
            Pagination = 'Select2'
            Authorization = 'view.selectlists'
            Command = 'Get-SnipeitSelectList'
            TestFile = 'Tests/Get-SnipeitSelectList.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'users.selectlist'
            Methods = @('GET')
            Route = '/api/v1/users/selectlist'
            Controller = 'UsersController::selectlist'
            Source = 'routes/api.php'
            QueryFields = @('search', 'page', 'companyId', 'excludeId')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'Select2'
            Pagination = 'Select2'
            Authorization = 'view.selectlists'
            Command = 'Get-SnipeitSelectList'
            TestFile = 'Tests/Get-SnipeitSelectList.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'accessories.history'
            Methods = @('GET')
            Route = '/api/v1/accessories/{id}/history'
            Controller = 'AccessoriesController::history'
            Source = 'app/Http/Controllers/Api/AccessoriesController.php; app/Models/Traits/Loggable.php'
            QueryFields = @('search', 'action_type', 'created_by', 'action_source', 'remote_ip', 'uploads', 'sort', 'order', 'offset', 'limit')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'history Accessory instance'
            Command = 'Get-SnipeitHistory'
            TestFile = 'Tests/Get-SnipeitHistory.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'components.history'
            Methods = @('GET')
            Route = '/api/v1/components/{id}/history'
            Controller = 'ComponentsController::history'
            Source = 'app/Http/Controllers/Api/ComponentsController.php; app/Models/Traits/Loggable.php'
            QueryFields = @('search', 'action_type', 'created_by', 'action_source', 'remote_ip', 'uploads', 'sort', 'order', 'offset', 'limit')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'history Component instance'
            Command = 'Get-SnipeitHistory'
            TestFile = 'Tests/Get-SnipeitHistory.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'consumables.history'
            Methods = @('GET')
            Route = '/api/v1/consumables/{id}/history'
            Controller = 'ConsumablesController::history'
            Source = 'app/Http/Controllers/Api/ConsumablesController.php; app/Models/Traits/Loggable.php'
            QueryFields = @('search', 'action_type', 'created_by', 'action_source', 'remote_ip', 'uploads', 'sort', 'order', 'offset', 'limit')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'history Consumable instance'
            Command = 'Get-SnipeitHistory'
            TestFile = 'Tests/Get-SnipeitHistory.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'hardware.history'
            Methods = @('GET')
            Route = '/api/v1/hardware/{id}/history'
            Controller = 'AssetsController::history'
            Source = 'app/Http/Controllers/Api/AssetsController.php; app/Models/Traits/Loggable.php'
            QueryFields = @('search', 'action_type', 'created_by', 'action_source', 'remote_ip', 'uploads', 'sort', 'order', 'offset', 'limit')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'history Asset instance'
            Command = 'Get-SnipeitHistory'
            TestFile = 'Tests/Get-SnipeitHistory.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'licenses.history'
            Methods = @('GET')
            Route = '/api/v1/licenses/{id}/history'
            Controller = 'LicensesController::history'
            Source = 'app/Http/Controllers/Api/LicensesController.php; app/Models/Traits/Loggable.php'
            QueryFields = @('search', 'action_type', 'created_by', 'action_source', 'remote_ip', 'uploads', 'sort', 'order', 'offset', 'limit')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'history License instance'
            Command = 'Get-SnipeitHistory'
            TestFile = 'Tests/Get-SnipeitHistory.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'locations.history'
            Methods = @('GET')
            Route = '/api/v1/locations/{id}/history'
            Controller = 'LocationsController::history'
            Source = 'app/Http/Controllers/Api/LocationsController.php; app/Models/Traits/Loggable.php'
            QueryFields = @('search', 'action_type', 'created_by', 'action_source', 'remote_ip', 'uploads', 'sort', 'order', 'offset', 'limit')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'history Location instance'
            Command = 'Get-SnipeitHistory'
            TestFile = 'Tests/Get-SnipeitHistory.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'maintenances.history'
            Methods = @('GET')
            Route = '/api/v1/maintenances/{id}/history'
            Controller = 'MaintenancesController::history'
            Source = 'app/Http/Controllers/Api/MaintenancesController.php; app/Models/Traits/Loggable.php'
            QueryFields = @('search', 'action_type', 'created_by', 'action_source', 'remote_ip', 'uploads', 'sort', 'order', 'offset', 'limit')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'history Maintenance instance'
            Command = 'Get-SnipeitHistory'
            TestFile = 'Tests/Get-SnipeitHistory.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'models.history'
            Methods = @('GET')
            Route = '/api/v1/models/{id}/history'
            Controller = 'AssetModelsController::history'
            Source = 'app/Http/Controllers/Api/AssetModelsController.php; app/Models/Traits/Loggable.php'
            QueryFields = @('search', 'action_type', 'created_by', 'action_source', 'remote_ip', 'uploads', 'sort', 'order', 'offset', 'limit')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'history AssetModel instance'
            Command = 'Get-SnipeitHistory'
            TestFile = 'Tests/Get-SnipeitHistory.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'users.history'
            Methods = @('GET')
            Route = '/api/v1/users/{id}/history'
            Controller = 'UsersController::history'
            Source = 'app/Http/Controllers/Api/UsersController.php; app/Models/Traits/Loggable.php'
            QueryFields = @('search', 'action_type', 'created_by', 'action_source', 'remote_ip', 'uploads', 'sort', 'order', 'offset', 'limit')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'history User instance'
            Command = 'Get-SnipeitHistory'
            TestFile = 'Tests/Get-SnipeitHistory.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'hardware.assigned.assets'
            Methods = @('GET')
            Route = '/api/v1/hardware/{id}/assigned/assets'
            Controller = 'AssetsController::assignedAssets'
            Source = 'app/Http/Controllers/Api/AssetsController.php:1914-1935'
            QueryFields = @('limit', 'offset')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view Asset class and instance'
            Command = 'Get-SnipeitAssetAssignment'
            TestFile = 'Tests/Get-SnipeitAssetAssignment.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'hardware.assigned.accessories'
            Methods = @('GET')
            Route = '/api/v1/hardware/{id}/assigned/accessories'
            Controller = 'AssetsController::assignedAccessories'
            Source = 'app/Http/Controllers/Api/AssetsController.php:1937-1959'
            QueryFields = @('limit', 'offset')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view Asset instance'
            Command = 'Get-SnipeitAssetAssignment'
            TestFile = 'Tests/Get-SnipeitAssetAssignment.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'hardware.assigned.components'
            Methods = @('GET')
            Route = '/api/v1/hardware/{id}/assigned/components'
            Controller = 'AssetsController::assignedComponents'
            Source = 'app/Http/Controllers/Api/AssetsController.php:1961-1982'
            QueryFields = @('limit', 'offset', 'sort', 'order')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view Asset instance'
            Command = 'Get-SnipeitAssetAssignment'
            TestFile = 'Tests/Get-SnipeitAssetAssignment.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'locations.assets'
            Methods = @('GET')
            Route = '/api/v1/locations/{id}/assets'
            Controller = 'LocationsController::assets'
            Source = 'app/Http/Controllers/Api/LocationsController.php:367-378'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'None'
            Authorization = 'view Asset and Location instance'
            Command = 'Get-SnipeitLocationAsset'
            TestFile = 'Tests/Get-SnipeitLocationAsset.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'locations.assigned.assets'
            Methods = @('GET')
            Route = '/api/v1/locations/{id}/assigned/assets'
            Controller = 'LocationsController::assignedAssets'
            Source = 'app/Http/Controllers/Api/LocationsController.php:380-391'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'None'
            Authorization = 'view Asset and Location instance'
            Command = 'Get-SnipeitLocationAssignment'
            TestFile = 'Tests/Get-SnipeitLocationAssignment.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'locations.assigned.accessories'
            Methods = @('GET')
            Route = '/api/v1/locations/{id}/assigned/accessories'
            Controller = 'LocationsController::assignedAccessories'
            Source = 'app/Http/Controllers/Api/LocationsController.php:393-401'
            QueryFields = @('limit', 'offset')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view Accessory and Location instance'
            Command = 'Get-SnipeitLocationAssignment'
            TestFile = 'Tests/Get-SnipeitLocationAssignment.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'account.requests'
            Methods = @('GET')
            Route = '/api/v1/account/requests'
            Controller = 'ProfileController::requestedAssets'
            Source = 'app/Http/Controllers/Api/ProfileController.php:49-88'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'None'
            Authorization = 'authenticated API user; current user requests only'
            Command = 'Get-SnipeitAccountRequest'
            TestFile = 'Tests/Get-SnipeitAccountRequest.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'account.request.store'
            Methods = @('POST')
            Route = '/api/v1/account/request/{asset}'
            Controller = 'CheckoutRequest::store'
            Source = 'app/Http/Controllers/Api/CheckoutRequest.php:17-47'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'authenticated API user; asset must be requestable and company-accessible'
            Command = 'New-SnipeitAccountRequest'
            TestFile = 'Tests/New-SnipeitAccountRequest.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'account.request.cancel'
            Methods = @('POST')
            Route = '/api/v1/account/request/{asset}/cancel'
            Controller = 'CheckoutRequest::destroy'
            Source = 'app/Http/Controllers/Api/CheckoutRequest.php:49-65'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'authenticated API user; company access to asset'
            Command = 'Remove-SnipeitAccountRequest'
            TestFile = 'Tests/Remove-SnipeitAccountRequest.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'account.requestable.hardware'
            Methods = @('GET')
            Route = '/api/v1/account/requestable/hardware'
            Controller = 'AssetsController::requestable'
            Source = 'app/Http/Controllers/Api/AssetsController.php:1835-1912'
            QueryFields = @('search', 'order', 'sort', 'limit', 'offset')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'viewRequestable Asset'
            Command = 'Get-SnipeitRequestableAsset'
            TestFile = 'Tests/Get-SnipeitRequestableAsset.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'account.eulas'
            Methods = @('GET')
            Route = '/api/v1/account/eulas'
            Controller = 'ProfileController::eulas'
            Source = 'app/Http/Controllers/Api/ProfileController.php:199-218'
            QueryFields = @('user_id')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'None'
            Authorization = 'authenticated API user; other user requires manager_view_enabled and isManagerOf'
            Command = 'Get-SnipeitAccountEula'
            TestFile = 'Tests/Get-SnipeitAccountEula.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'account.tokens.index'
            Methods = @('GET')
            Route = '/api/v1/account/personal-access-tokens'
            Controller = 'ProfileController::showApiTokens'
            Source = 'app/Http/Controllers/Api/ProfileController.php::showApiTokens'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'self.api and completed two-factor authentication; current user tokens only'
            Command = 'Get-SnipeitPersonalAccessToken'
            TestFile = 'Tests/Get-SnipeitPersonalAccessToken.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'account.tokens.store'
            Methods = @('POST')
            Route = '/api/v1/account/personal-access-tokens'
            Controller = 'ProfileController::createApiToken'
            Source = 'app/Http/Controllers/Api/ProfileController.php::createApiToken'
            QueryFields = @()
            BodyFields = @('name')
            RequiredFields = @()
            NullableFields = @('name')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'self.api and completed two-factor authentication; current user tokens only'
            Command = 'New-SnipeitPersonalAccessToken'
            TestFile = 'Tests/New-SnipeitPersonalAccessToken.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'account.tokens.destroy'
            Methods = @('DELETE')
            Route = '/api/v1/account/personal-access-tokens/{tokenId}'
            Controller = 'ProfileController::deleteApiToken'
            Source = 'app/Http/Controllers/Api/ProfileController.php::deleteApiToken'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'NoContent'
            Pagination = 'None'
            Authorization = 'self.api and completed two-factor authentication; current user tokens only'
            Command = 'Remove-SnipeitPersonalAccessToken'
            TestFile = 'Tests/Remove-SnipeitPersonalAccessToken.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'hardware.bytag.show'
            Methods = @('GET')
            Route = '/api/v1/hardware/bytag/{tag}'
            Controller = 'AssetsController::showByTag'
            Source = 'app/Http/Controllers/Api/AssetsController.php:491-516'
            QueryFields = @('deleted')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObjectOrRowsTotal'
            Pagination = 'None'
            Authorization = 'index Asset'
            Command = 'Get-SnipeitAsset'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'hardware.bytag.checkout'
            Methods = @('POST')
            Route = '/api/v1/hardware/bytag/{any}/checkout'
            Controller = 'AssetsController::checkoutByTag'
            Source = 'app/Http/Controllers/Api/AssetsController.php:493-498'
            QueryFields = @()
            BodyFields = @('assigned_user', 'assigned_asset', 'assigned_location', 'checkout_to_type', 'checkout_at', 'expected_checkin', 'note', 'name', 'status_id', 'requestable')
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'checkout Asset class and instance via checkout'
            Command = 'Set-SnipeitAssetOwner'
            TestFile = 'Tests/Set-SnipeitAssetOwner.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'hardware.bytag.checkin'
            Methods = @('POST')
            Route = '/api/v1/hardware/bytag/{any}/checkin'
            Controller = 'AssetsController::checkinByTag'
            Source = 'app/Http/Controllers/Api/AssetsController.php:500-505'
            QueryFields = @()
            BodyFields = @('name', 'clear_name', 'checkin_at', 'status_id', 'location_id', 'update_default_location', 'note')
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'checkin Asset class and instance'
            Command = 'Reset-SnipeitAssetOwner'
            TestFile = 'Tests/Reset-SnipeitAssetOwner.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'hardware.checkinbytag'
            Methods = @('POST')
            Route = '/api/v1/hardware/checkinbytag'
            Controller = 'AssetsController::checkinByTag'
            Source = 'app/Http/Controllers/Api/AssetsController.php:507-512'
            QueryFields = @()
            BodyFields = @('checkin_key', 'checkin_by_field', 'asset_tag', 'name', 'clear_name', 'checkin_at', 'status_id', 'location_id', 'update_default_location', 'note')
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'checkin Asset class and instance'
            Command = 'Reset-SnipeitAssetOwner'
            TestFile = 'Tests/Reset-SnipeitAssetOwner.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'hardware.byserial.show'
            Methods = @('GET')
            Route = '/api/v1/hardware/byserial/{serial}'
            Controller = 'AssetsController::showBySerial'
            Source = 'app/Http/Controllers/Api/AssetsController.php:530-563'
            QueryFields = @('deleted', 'limit', 'offset')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'index Asset'
            Command = 'Get-SnipeitAsset'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'hardware.upcoming'
            Methods = @('GET')
            Route = '/api/v1/hardware/{action}/{upcoming_status}'
            Controller = 'AssetsController::index'
            Source = 'app/Http/Controllers/Api/AssetsController.php::index'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset', 'status_id', 'model_id', 'category_id', 'location_id', 'supplier_id', 'company_id', 'assigned_to', 'assigned_type', 'rtd_location_id', 'asset_tag', 'serial', 'status_type', 'status', 'requestable', 'asset_eol_date', 'expand_company_hierarchy', 'manufacturer_id', 'depreciation_id', 'byod', 'order_number', 'components')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'index Asset'
            Command = 'Get-SnipeitAssetDue'
            TestFile = 'Tests/Get-SnipeitAssetDue.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'labels.index'
            Methods = @('GET')
            Route = '/api/v1/labels'
            Controller = 'LabelsController::index'
            Source = 'app/Http/Controllers/Api/LabelsController.php:20-40'
            QueryFields = @('search', 'limit', 'offset')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view Label'
            Command = 'Get-SnipeitLabelDefinition'
            TestFile = 'Tests/Get-SnipeitLabelDefinition.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'labels.show'
            Methods = @('GET')
            Route = '/api/v1/labels/{name}'
            Controller = 'LabelsController::show'
            Source = 'app/Http/Controllers/Api/LabelsController.php:42-66'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view Label instance'
            Command = 'Get-SnipeitLabelDefinition'
            TestFile = 'Tests/Get-SnipeitLabelDefinition.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'notes.index'
            Methods = @('GET')
            Route = '/api/v1/notes/{asset}/index'
            Controller = 'NotesController::index'
            Source = 'app/Http/Controllers/Api/NotesController.php:30-50'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'view Asset instance'
            Command = 'Get-SnipeitAssetNote'
            TestFile = 'Tests/Get-SnipeitAssetNote.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'notes.store'
            Methods = @('POST')
            Route = '/api/v1/notes/{asset}/store'
            Controller = 'NotesController::store'
            Source = 'app/Http/Controllers/Api/NotesController.php:52-91'
            QueryFields = @()
            BodyFields = @('note')
            RequiredFields = @('note')
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update Asset instance'
            Command = 'New-SnipeitAssetNote'
            TestFile = 'Tests/New-SnipeitAssetNote.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'fields.fieldsets.order'
            Methods = @('POST')
            Route = '/api/v1/fields/fieldsets/{id}/order'
            Controller = 'CustomFieldsController::postReorder'
            Source = 'app/Http/Controllers/Api/CustomFieldsController.php:121-178'
            QueryFields = @()
            BodyFields = @('item')
            RequiredFields = @('item')
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'update CustomFieldset instance'
            Command = 'Set-SnipeitFieldsetOrder'
            TestFile = 'Tests/Set-SnipeitFieldsetOrder.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'fieldsets.fields.model'
            Methods = @('POST')
            Route = '/api/v1/fieldsets/{fieldset}/fields/{model}'
            Controller = 'CustomFieldsetsController::fieldsWithDefaultValues'
            Source = 'app/Http/Controllers/Api/CustomFieldsetsController.php:156-178'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'None'
            Authorization = 'view CustomField'
            Command = 'Get-SnipeitFieldsetField'
            TestFile = 'Tests/Get-SnipeitFieldsetField.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'statuslabels.count.name'
            Methods = @('GET')
            Route = '/api/v1/statuslabels/assets/name'
            Controller = 'StatuslabelsController::getAssetCountByStatuslabel'
            Source = 'app/Http/Controllers/Api/StatuslabelsController.php:212-240'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view Statuslabel'
            Command = 'Get-SnipeitStatusCount'
            TestFile = 'Tests/Get-SnipeitStatusCount.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'statuslabels.count.type'
            Methods = @('GET')
            Route = '/api/v1/statuslabels/assets/type'
            Controller = 'StatuslabelsController::getAssetCountByMetaStatus'
            Source = 'app/Http/Controllers/Api/StatuslabelsController.php:242-270'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'view Statuslabel'
            Command = 'Get-SnipeitStatusCount'
            TestFile = 'Tests/Get-SnipeitStatusCount.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'statuslabels.deployable'
            Methods = @('GET')
            Route = '/api/v1/statuslabels/{id}/deployable'
            Controller = 'StatuslabelsController::checkIfDeployable'
            Source = 'app/Http/Controllers/Api/StatuslabelsController.php:300-319'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'ScalarText'
            Pagination = 'None'
            Authorization = 'authenticated API user; no additional policy gate'
            Command = 'Test-SnipeitStatusDeployable'
            TestFile = 'Tests/Test-SnipeitStatusDeployable.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'manufacturers.restore'
            Methods = @('POST')
            Route = '/api/v1/manufacturers/{id}/restore'
            Controller = 'ManufacturersController::restore'
            Source = 'app/Http/Controllers/Api/ManufacturersController.php:239-266'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete Manufacturer'
            Command = 'Restore-SnipeitManufacturer'
            TestFile = 'Tests/Restore-SnipeitManufacturer.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'reports.activity.chart'
            Methods = @('GET')
            Route = '/api/v1/reports/activity/chart'
            Controller = 'ReportsController::activityChart'
            Source = 'app/Http/Controllers/Api/ReportsController.php:162-301'
            QueryFields = @('days', 'start_date', 'end_date')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'reports.view'
            Command = 'Get-SnipeitActivityChart'
            TestFile = 'Tests/Get-SnipeitActivityChart.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'settings.ldaptest'
            Methods = @('GET')
            Route = '/api/v1/settings/ldaptest'
            Controller = 'SettingsController::ldaptest'
            Source = 'app/Http/Controllers/Api/SettingsController.php:23-94'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'superuser'
            Command = 'Test-SnipeitLdap'
            TestFile = 'Tests/Test-SnipeitLdap.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'settings.ldaptestlogin'
            Methods = @('POST')
            Route = '/api/v1/settings/ldaptestlogin'
            Controller = 'SettingsController::ldaptestlogin'
            Source = 'app/Http/Controllers/Api/SettingsController.php:97-153'
            QueryFields = @()
            BodyFields = @('ldaptest_user', 'ldaptest_password')
            RequiredFields = @('ldaptest_user', 'ldaptest_password')
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'superuser'
            Command = 'Test-SnipeitLdapCredential'
            TestFile = 'Tests/Test-SnipeitLdapCredential.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'settings.mailtest'
            Methods = @('POST')
            Route = '/api/v1/settings/mailtest'
            Controller = 'SettingsController::ajaxTestEmail'
            Source = 'app/Http/Controllers/Api/SettingsController.php:162-186'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'superuser'
            Command = 'Send-SnipeitTestMail'
            TestFile = 'Tests/Send-SnipeitTestMail.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'settings.purge_barcodes'
            Methods = @('POST')
            Route = '/api/v1/settings/purge_barcodes'
            Controller = 'SettingsController::purgeBarcodes'
            Source = 'app/Http/Controllers/Api/SettingsController.php:196-222'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'superuser'
            Command = 'Clear-SnipeitBarcode'
            TestFile = 'Tests/Clear-SnipeitBarcode.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'settings.login_attempts'
            Methods = @('GET')
            Route = '/api/v1/settings/login-attempts'
            Controller = 'SettingsController::showLoginAttempts'
            Source = 'app/Http/Controllers/Api/SettingsController.php:231-244'
            QueryFields = @('offset', 'limit', 'sort', 'order')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'superuser'
            Command = 'Get-SnipeitLoginAttempt'
            TestFile = 'Tests/Get-SnipeitLoginAttempt.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'users.ldapsync'
            Methods = @('POST')
            Route = '/api/v1/users/ldapsync'
            Controller = 'UsersController::syncLdapUsers'
            Source = 'app/Http/Controllers/Api/UsersController.php:1044-1065'
            QueryFields = @()
            BodyFields = @('location_id')
            RequiredFields = @()
            NullableFields = @('location_id')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update user'
            Command = 'Sync-SnipeitLdapUser'
            TestFile = 'Tests/Sync-SnipeitLdapUser.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'users.email'
            Methods = @('POST')
            Route = '/api/v1/users/{id}/email'
            Controller = 'UsersController::emailAssetList'
            Source = 'app/Http/Controllers/Api/UsersController.php:861-879'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update user'
            Command = 'Send-SnipeitUserInventory'
            TestFile = 'Tests/Send-SnipeitUserInventory.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'settings.backups.download.latest'
            Methods = @('GET')
            Route = '/api/v1/settings/backups/download/latest'
            Controller = 'SettingsController::downloadLatestBackup'
            Source = 'app/Http/Controllers/Api/SettingsController.php:986'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'BinaryDownload'
            Pagination = 'None'
            Authorization = 'superuser'
            Command = 'Save-SnipeitBackup'
            TestFile = 'Tests/Save-SnipeitBackup.Tests.ps1'
            State = 'Verified'
        }
        @{
            Key = 'accessories.checkedout'
            Methods = @('GET')
            Route = '/api/v1/accessories/{id}/checkedout'
            Controller = 'AccessoriesController::checkedout'
            Source = 'app/Http/Controllers/Api/AccessoriesController.php:234-257'
            QueryFields = @('search', 'offset', 'limit')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view Accessory'
            Command = 'Get-SnipeitAccessoryOwner'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'accessories.checkout'
            Methods = @('POST')
            Route = '/api/v1/accessories/{id}/checkout'
            Controller = 'AccessoriesController::checkout'
            Source = 'app/Http/Controllers/Api/AccessoriesController.php:321; app/Http/Requests/AccessoryCheckoutRequest.php:44-47'
            QueryFields = @()
            BodyFields = @('assigned_user', 'assigned_asset', 'assigned_location', 'checkout_qty', 'note')
            RequiredFields = @()
            NullableFields = @('note')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'checkout Accessory instance; company checks on assignment target'
            Command = 'Set-SnipeitAccessoryOwner'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'accessories.checkin'
            Methods = @('POST')
            Route = '/api/v1/accessories/{assigned_pivot_id}/checkin'
            Controller = 'AccessoriesController::checkin'
            Source = 'routes/api.php:124'
            QueryFields = @()
            BodyFields = @('note')
            RequiredFields = @()
            NullableFields = @('note')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'checkin Accessory instance'
            Command = 'Reset-SnipeitAccessoryOwner'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'components.assets'
            Methods = @('GET')
            Route = '/api/v1/components/{id}/assets'
            Controller = 'ComponentsController::getAssets'
            Source = 'app/Http/Controllers/Api/ComponentsController.php:264-290'
            QueryFields = @('search', 'offset', 'limit')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view Asset'
            Command = 'Get-SnipeitComponentAsset'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'components.checkin'
            Methods = @('POST')
            Route = '/api/v1/components/{id}/checkin'
            Controller = 'ComponentsController::checkin'
            Source = 'routes/api.php:258'
            QueryFields = @()
            BodyFields = @('checkin_qty', 'note')
            RequiredFields = @('checkin_qty')
            NullableFields = @('note')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'checkin Component instance'
            Command = 'Reset-SnipeitComponentOwner'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'components.checkout'
            Methods = @('POST')
            Route = '/api/v1/components/{id}/checkout'
            Controller = 'ComponentsController::checkout'
            Source = 'routes/api.php:265'
            QueryFields = @()
            BodyFields = @('assigned_to', 'assigned_qty', 'note')
            RequiredFields = @('assigned_to', 'assigned_qty')
            NullableFields = @('note')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'checkout Component instance; company checks on assignment target'
            Command = 'Set-SnipeitComponentOwner'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'consumables.users'
            Methods = @('GET')
            Route = '/api/v1/consumables/{id}/users'
            Controller = 'ConsumablesController::getDataView'
            Source = 'routes/api.php:305'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'None'
            Authorization = 'view Consumable; company access check'
            Command = 'Get-SnipeitConsumableUser'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'consumables.checkout'
            Methods = @('POST')
            Route = '/api/v1/consumables/{id}/checkout'
            Controller = 'ConsumablesController::checkout'
            Source = 'routes/api.php:312'
            QueryFields = @()
            BodyFields = @('assigned_to', 'checkout_qty', 'note')
            RequiredFields = @('assigned_to')
            NullableFields = @('note')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'checkout Consumable instance; company checks on assignment target'
            Command = 'Set-SnipeitConsumableOwner'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'fields.associate'
            Methods = @('POST')
            Route = '/api/v1/fields/{id}/associate'
            Controller = 'CustomFieldsController::associate'
            Source = 'routes/api.php:371'
            QueryFields = @()
            BodyFields = @('fieldset_id', 'required', 'order')
            RequiredFields = @('fieldset_id')
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update CustomFieldset'
            Command = 'Register-SnipeitCustomField'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'fields.disassociate'
            Methods = @('POST')
            Route = '/api/v1/fields/{id}/disassociate'
            Controller = 'CustomFieldsController::disassociate'
            Source = 'routes/api.php:378'
            QueryFields = @()
            BodyFields = @('fieldset_id')
            RequiredFields = @('fieldset_id')
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update CustomFieldset'
            Command = 'Unregister-SnipeitCustomField'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'fieldsets.fields'
            Methods = @('POST')
            Route = '/api/v1/fieldsets/{fieldset}/fields'
            Controller = 'CustomFieldsetsController::fields'
            Source = 'routes/api.php:405'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'None'
            Authorization = 'view CustomField'
            Command = 'Get-SnipeitFieldsetField'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'hardware.licenses'
            Methods = @('GET')
            Route = '/api/v1/hardware/{id}/licenses'
            Controller = 'AssetsController::licenses'
            Source = 'routes/api.php:464'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'None'
            Authorization = 'view Asset instance and view License'
            Command = 'Get-SnipeitAssetLicense'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'hardware.audit'
            Methods = @('POST')
            Route = '/api/v1/hardware/audit'
            Controller = 'AssetsController::audit'
            Source = 'routes/api.php:532'
            QueryFields = @()
            BodyFields = @('asset_tag', 'audit_by_field', 'audit_key', 'location_id', 'next_audit_date', 'note', 'image', 'update_location', 'clear_name')
            RequiredFields = @()
            NullableFields = @('location_id', 'note')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'audit Asset class and resolved instance'
            Command = 'New-SnipeitAudit'
            TestFile = 'Tests/AuditSeatUri-Contracts.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'hardware.audit.bulk'
            Methods = @('POST')
            Route = '/api/v1/hardware/audit/bulk'
            Controller = 'AssetsController::bulkAudit'
            Source = 'routes/api.php:542'
            QueryFields = @()
            BodyFields = @('ids', 'next_audit_date', 'note', 'location_id', 'image', 'update_location', 'clear_name')
            RequiredFields = @('ids')
            NullableFields = @('location_id', 'note')
            ResponseKind = 'BulkResult'
            Pagination = 'None'
            Authorization = 'audit Asset class and each resolved instance'
            Command = 'New-SnipeitAudit'
            TestFile = 'Tests/AuditSeatUri-Contracts.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'hardware.asset.audit'
            Methods = @('POST')
            Route = '/api/v1/hardware/{id}/audit'
            Controller = 'AssetsController::audit'
            Source = 'routes/api.php:550'
            QueryFields = @()
            BodyFields = @('location_id', 'next_audit_date', 'note', 'image', 'update_location', 'clear_name')
            RequiredFields = @()
            NullableFields = @('location_id', 'note')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'audit Asset class and resolved instance'
            Command = 'New-SnipeitAudit'
            TestFile = 'Tests/AuditSeatUri-Contracts.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'hardware.checkin'
            Methods = @('POST')
            Route = '/api/v1/hardware/{id}/checkin'
            Controller = 'AssetsController::checkin'
            Source = 'routes/api.php:557'
            QueryFields = @()
            BodyFields = @('name', 'clear_name', 'checkin_at', 'status_id', 'location_id', 'update_default_location', 'note')
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'checkin Asset instance'
            Command = 'Reset-SnipeitAssetOwner'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'hardware.checkout'
            Methods = @('POST')
            Route = '/api/v1/hardware/{id}/checkout'
            Controller = 'AssetsController::checkout'
            Source = 'routes/api.php:564'
            QueryFields = @()
            BodyFields = @('assigned_user', 'assigned_asset', 'assigned_location', 'checkout_to_type', 'checkout_at', 'expected_checkin', 'note', 'name', 'status_id', 'requestable')
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'checkout Asset class and instance; company checks on assignment target'
            Command = 'Set-SnipeitAssetOwner'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'hardware.restore'
            Methods = @('POST')
            Route = '/api/v1/hardware/{id}/restore'
            Controller = 'AssetsController::restore'
            Source = 'routes/api.php:571'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete Asset instance'
            Command = 'Restore-SnipeitAsset'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'hardware.bulk.update'
            Methods = @('PATCH')
            Route = '/api/v1/hardware/bulk'
            Controller = 'AssetsController::bulkUpdate'
            Source = 'routes/api.php:605'
            QueryFields = @()
            BodyFields = @('ids', 'asset_tag', 'model_id', 'status_id', 'name', 'serial', 'purchase_date', 'purchase_cost', 'order_number', 'supplier_id', 'notes', 'assigned_user', 'assigned_asset', 'assigned_location', 'warranty_months', 'rtd_location_id', 'requestable', 'company_id', 'byod', 'location_id', 'eol_explicit', 'asset_eol_date', 'expected_checkin', 'next_audit_date', 'last_audit_date', 'last_checkin', 'last_checkout', 'image', 'image_delete')
            RequiredFields = @('ids')
            NullableFields = @()
            ResponseKind = 'BulkResult'
            Pagination = 'None'
            Authorization = 'update Asset via BulkUpdateAssetsRequest and each resolved instance'
            Command = 'Update-SnipeitAssetBulk'
            TestFile = 'Tests/Coverage-BulkOperations.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'maintenances.notes.index'
            Methods = @('GET')
            Route = '/api/v1/maintenances/{id}/notes'
            Controller = 'MaintenancesController::notesIndex'
            Source = 'routes/api.php:637'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'journal Maintenance instance'
            Command = 'Get-SnipeitAssetMaintenanceNote'
            TestFile = 'Tests/MaintenanceLicense-SliceA.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'maintenances.notes.store'
            Methods = @('POST')
            Route = '/api/v1/maintenances/{id}/notes'
            Controller = 'MaintenancesController::notesStore'
            Source = 'routes/api.php:641'
            QueryFields = @()
            BodyFields = @('note')
            RequiredFields = @('note')
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update Maintenance instance'
            Command = 'New-SnipeitAssetMaintenanceNote'
            TestFile = 'Tests/MaintenanceLicense-SliceA.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'maintenances.complete'
            Methods = @('POST')
            Route = '/api/v1/maintenances/{id}/complete'
            Controller = 'MaintenancesController::complete'
            Source = 'routes/api.php:645'
            QueryFields = @()
            BodyFields = @('note')
            RequiredFields = @()
            NullableFields = @('note')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'update Asset; company access to maintenance asset'
            Command = 'Complete-SnipeitAssetMaintenance'
            TestFile = 'Tests/MaintenanceLicense-SliceA.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'licenses.checkout'
            Methods = @('POST')
            Route = '/api/v1/licenses/{id}/checkout'
            Controller = 'LicensesController::checkout'
            Source = 'routes/api.php:738'
            QueryFields = @()
            BodyFields = @('target_type', 'asset_id', 'assigned_to', 'notes', 'seat_id')
            RequiredFields = @('target_type')
            NullableFields = @('asset_id', 'assigned_to', 'notes', 'seat_id')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'checkout License instance; company checks on assignment target'
            Command = 'Set-SnipeitLicenseOwner'
            TestFile = 'Tests/MaintenanceLicense-SliceA.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'licenses.checkin'
            Methods = @('POST')
            Route = '/api/v1/licenses/{id}/checkin'
            Controller = 'LicensesController::checkin'
            Source = 'routes/api.php:745'
            QueryFields = @()
            BodyFields = @('notes', 'seat_id')
            RequiredFields = @('seat_id')
            NullableFields = @('notes')
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'checkin License instance'
            Command = 'Reset-SnipeitLicenseOwner'
            TestFile = 'Tests/MaintenanceLicense-SliceA.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'statuslabels.assetlist'
            Methods = @('GET')
            Route = '/api/v1/statuslabels/{id}/assetlist'
            Controller = 'StatuslabelsController::assets'
            Source = 'app/Http/Controllers/Api/StatuslabelsController.php:297-321'
            QueryFields = @('limit', 'offset', 'order', 'sort')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view Statuslabel and index Asset'
            Command = 'Get-SnipeitStatusAsset'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'users.me'
            Methods = @('GET')
            Route = '/api/v1/users/me'
            Controller = 'UsersController::getCurrentUserInfo'
            Source = 'routes/api.php:1130'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'authenticated API user; returns current user only'
            Command = 'Get-SnipeitCurrentUser'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'users.eulas'
            Methods = @('GET')
            Route = '/api/v1/users/{id}/eulas'
            Controller = 'UsersController::eulas'
            Source = 'app/Http/Controllers/Api/UsersController.php:979-993'
            QueryFields = @('limit', 'offset')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view User instance'
            Command = 'Get-SnipeitUserEula'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'users.assets'
            Methods = @('GET')
            Route = '/api/v1/users/{id}/assets'
            Controller = 'UsersController::assets'
            Source = 'app/Http/Controllers/Api/UsersController.php:816-848'
            QueryFields = @('category_id', 'model_id', 'offset', 'limit')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view User class and instance; view Asset'
            Command = 'Get-SnipeitUserAsset'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'users.accessories'
            Methods = @('GET')
            Route = '/api/v1/users/{id}/accessories'
            Controller = 'UsersController::accessories'
            Source = 'routes/api.php:1158'
            QueryFields = @('limit', 'offset')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view User class and instance; view Accessory'
            Command = 'Get-SnipeitUserAccessory'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'users.licenses'
            Methods = @('GET')
            Route = '/api/v1/users/{id}/licenses'
            Controller = 'UsersController::licenses'
            Source = 'routes/api.php:1165'
            QueryFields = @('limit', 'offset')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'view User and License'
            Command = 'Get-SnipeitUserLicense'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'users.restore'
            Methods = @('POST')
            Route = '/api/v1/users/{id}/restore'
            Controller = 'UsersController::restore'
            Source = 'routes/api.php:1172'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'delete User class and instance'
            Command = 'Restore-SnipeitUser'
            TestFile = 'Tests/Coverage-Set-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'reports.activity'
            Methods = @('GET')
            Route = '/api/v1/reports/activity'
            Controller = 'ReportsController::index'
            Source = 'routes/api.php:1337'
            QueryFields = @('search', 'filter', 'order', 'sort', 'limit', 'offset', 'target_id', 'target_type', 'item_id', 'item_type', 'action_type', 'created_by', 'action_source', 'remote_ip', 'uploads')
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = 'activity.view unless scoped to an item or target with view permission'
            Command = 'Get-SnipeitActivity'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'hardware.labels'
            Methods = @('POST')
            Route = '/api/v1/hardware/labels'
            Controller = 'AssetsController::getLabels'
            Source = 'routes/api.php:1378'
            QueryFields = @()
            BodyFields = @('asset_tags')
            RequiredFields = @('asset_tags')
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = 'view Asset'
            Command = 'New-SnipeitAssetLabel'
            TestFile = 'Tests/New-SnipeitAssetLabel.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'settings.backups.index'
            Methods = @('GET')
            Route = '/api/v1/settings/backups'
            Controller = 'SettingsController::listBackups'
            Source = 'routes/api.php:979'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'None'
            Authorization = 'superuser'
            Command = 'Get-SnipeitBackup'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'settings.backups.download'
            Methods = @('GET')
            Route = '/api/v1/settings/backups/download/{file}'
            Controller = 'SettingsController::downloadBackup'
            Source = 'routes/api.php:993'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'BinaryDownload'
            Pagination = 'None'
            Authorization = 'superuser'
            Command = 'Save-SnipeitBackup'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'version'
            Methods = @('GET')
            Route = '/api/v1/version'
            Controller = 'routes/api.php::closure'
            Source = 'routes/api.php:1355-1364'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = 'authenticated API user; no additional policy gate'
            Command = 'Get-SnipeitVersion'
            TestFile = 'Tests/Coverage-Get-Legacy.Tests.ps1'
            State = 'Existing'
        }
        @{
            Key = 'models.assets'
            Methods = @('GET')
            Route = '/api/v1/models/assets'
            Controller = 'AssetModelsController::assets'
            Source = 'routes/api.php:894-899'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'RowsTotal'
            Pagination = 'OffsetLimit'
            Authorization = ''
            Command = ''
            TestFile = ''
            State = 'BlockedServer'
        }
        @{
            Key = 'client'
            Methods = @('GET')
            Route = '/api/v1/client'
            Controller = 'OAuth::client'
            Source = 'routes/api.php:29-44'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = ''
            Command = ''
            TestFile = ''
            State = 'ExcludedProtocol'
        }
        @{
            Key = 'root'
            Methods = @('GET')
            Route = '/api/v1'
            Controller = 'Diagnostic::root'
            Source = 'routes/api.php:20-27'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = ''
            Command = ''
            TestFile = ''
            State = 'ExcludedProtocol'
        }
        @{
            Key = 'fallback'
            Methods = @('GET')
            Route = '/api/v1/{fallbackPlaceholder}'
            Controller = 'Diagnostic::fallback'
            Source = 'routes/api.php:1366-1373'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'StandardEnvelope'
            Pagination = 'None'
            Authorization = ''
            Command = ''
            TestFile = ''
            State = 'ExcludedProtocol'
        }
        @{
            Key = 'scim'
            Methods = @('GET', 'POST', 'PUT', 'PATCH', 'DELETE')
            Route = '/api/v1/scim/{any}'
            Controller = 'SCIMController::router'
            Source = 'routes/scim.php:17-37'
            QueryFields = @()
            BodyFields = @()
            RequiredFields = @()
            NullableFields = @()
            ResponseKind = 'DirectObject'
            Pagination = 'None'
            Authorization = ''
            Command = ''
            TestFile = ''
            State = 'ExcludedProtocol'
        }
    )
}
