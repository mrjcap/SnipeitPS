BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'API Parity Contract Ledger' {
    BeforeAll {
        function ConvertFrom-SafeAst($astNode) {
            if ($null -eq $astNode) { return $null }

            if ($astNode -is [System.Management.Automation.Language.HashtableAst]) {
                $hash = [ordered]@{}
                foreach ($kvp in $astNode.KeyValuePairs) {
                    $key = ConvertFrom-SafeAst $kvp.Item1
                    $val = ConvertFrom-SafeAst $kvp.Item2
                    $hash[$key] = $val
                }
                return $hash
            }

            if ($astNode -is [System.Management.Automation.Language.ArrayLiteralAst]) {
                $arr = [System.Collections.Generic.List[object]]::new()
                foreach ($elem in $astNode.Elements) {
                    $arr.Add((ConvertFrom-SafeAst $elem))
                }
                return $arr.ToArray()
            }

            if ($astNode -is [System.Management.Automation.Language.ArrayExpressionAst]) {
                return ConvertFrom-SafeAst $astNode.SubExpression
            }

            if ($astNode -is [System.Management.Automation.Language.StatementBlockAst]) {
                $arr = [System.Collections.Generic.List[object]]::new()
                foreach ($stmt in $astNode.Statements) {
                    $arr.Add((ConvertFrom-SafeAst $stmt))
                }
                if ($arr.Count -eq 1) { return $arr[0] }
                return $arr.ToArray()
            }

            if ($astNode -is [System.Management.Automation.Language.PipelineAst]) {
                if ($astNode.PipelineElements.Count -eq 1) {
                    return ConvertFrom-SafeAst $astNode.PipelineElements[0]
                }
            }

            if ($astNode -is [System.Management.Automation.Language.CommandExpressionAst]) {
                return ConvertFrom-SafeAst $astNode.Expression
            }

            if ($astNode -is [System.Management.Automation.Language.ConstantExpressionAst] -or
                $astNode -is [System.Management.Automation.Language.StringConstantExpressionAst]) {
                return $astNode.Value
            }

            throw [System.InvalidOperationException]::new("Unsupported AST node type: $($astNode.GetType().Name)")
        }

        $ledgerPath = (Resolve-Path "$PSScriptRoot/Fixtures/ApiParity.Contracts.psd1").Path
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($ledgerPath, [ref]$tokens, [ref]$errors)
        if ($errors -and $errors.Count -gt 0) {
            throw "Ledger parse failure: $($errors[0].Message)"
        }

        $rootHash = $ast.EndBlock.Statements[0].PipelineElements[0].Expression
        $script:ledger = ConvertFrom-SafeAst $rootHash
        $script:operations = @($script:ledger.Operations)
    }

    Context 'Ledger File and Pinned Reference' {
        It 'Matches the pinned local Snipe-IT commit hash' {
            $script:ledger.ApiRef | Should -Be '0c381a6482824a9f5d1889a98843393a0b6ad6b3'
        }

        It 'Contains a non-empty operations collection' {
            $script:operations.Count | Should -BeGreaterThan 100
        }
    }

    Context 'Normalized Key Uniqueness and Integrity' {
        It 'Contains zero duplicate normalized operation keys' {
            $keys = $script:operations | ForEach-Object { $_.Key }
            $duplicates = $keys | Group-Object | Where-Object { $_.Count -gt 1 }
            $duplicates | Should -BeNullOrEmpty
        }

        It 'All keys follow dot notation' {
            foreach ($op in $script:operations) {
                $op.Key | Should -Match '^[a-z0-9_-]+(\.[a-z0-9_-]+)*$'
            }
        }
    }

    Context 'Schema and Contract Adherence' {
        It 'Every operation has allowed HTTP methods' {
            $allowedMethods = @('GET', 'POST', 'PUT', 'PATCH', 'DELETE')
            foreach ($op in $script:operations) {
                $methods = @($op.Methods)
                $methods.Count | Should -BeGreaterThan 0
                foreach ($m in $methods) {
                    $m | Should -BeIn $allowedMethods
                }
            }
        }

        It 'Every operation has a valid route starting with /api/v1' {
            foreach ($op in $script:operations) {
                $op.Route | Should -Match '^/api/v1(/.*)?$'
            }
        }

        It 'Core resource show endpoints return direct objects' {
            $resources = @('accessories', 'categories', 'companies', 'components', 'consumables', 'departments',
                'fields', 'fieldsets', 'groups', 'hardware', 'licenses', 'locations', 'manufacturers', 'models',
                'statuslabels', 'suppliers', 'users')
            foreach ($resource in $resources) {
                $operation = @($script:operations | Where-Object { $_.Key -eq "$resource.show" })
                $operation.Count | Should -Be 1
                $operation[0].ResponseKind | Should -Be 'DirectObject'
            }
        }

        It '<Key> cites its exact pinned controller action' -ForEach @(
            @{ Key = 'files.index'; Action = 'UploadedFilesController.php::index' }
            @{ Key = 'files.store'; Action = 'UploadedFilesController.php::store' }
            @{ Key = 'files.destroy'; Action = 'UploadedFilesController.php::destroy' }
            @{ Key = 'account.tokens.index'; Action = 'ProfileController.php::showApiTokens' }
            @{ Key = 'account.tokens.store'; Action = 'ProfileController.php::createApiToken' }
            @{ Key = 'account.tokens.destroy'; Action = 'ProfileController.php::deleteApiToken' }
        ) {
            $operation = $script:operations | Where-Object Key -eq $Key
            $operation.Source | Should -Be "app/Http/Controllers/Api/$Action"
        }

        It 'Records field-level server limitations separately from implemented operations' {
            $script:ledger.Contains('FieldLimitations') | Should -BeTrue
            @($script:ledger.FieldLimitations).Count | Should -BeGreaterThan 0
            foreach ($limitation in $script:ledger.FieldLimitations) {
                $limitation.Operation | Should -Not -BeNullOrEmpty
                $limitation.Field | Should -Not -BeNullOrEmpty
                $limitation.Source | Should -Not -BeNullOrEmpty
                $limitation.Reason | Should -Not -BeNullOrEmpty
            }
        }

        It 'Every operation has an allowed ResponseKind' {
            $allowedKinds = @(
                'StandardEnvelope',
                'RowsTotal',
                'Select2',
                'DirectArray',
                'DirectObject',
                'DirectObjectOrRowsTotal',
                'ScalarText',
                'NoContent',
                'BinaryDownload',
                'BulkResult',
                'ImportResult'
            )
            foreach ($op in $script:operations) {
                $op.ResponseKind | Should -BeIn $allowedKinds
            }
        }

        It 'Every operation has an allowed Pagination mode' {
            $allowedPaging = @('None', 'OffsetLimit', 'Select2', 'UnpaginatedArray')
            foreach ($op in $script:operations) {
                $op.Pagination | Should -BeIn $allowedPaging
            }
        }

        It '<Key> records the pinned Company fillable fields and image inputs' -ForEach @(
            @{ Key = 'companies.store'; ImageFields = @('image') }
            @{ Key = 'companies.update'; ImageFields = @('image', 'image_delete') }
        ) {
            $operation = $script:operations | Where-Object Key -eq $Key
            $fillable = @('name', 'parent_id', 'phone', 'fax', 'email', 'tag_color', 'notes')
            foreach ($field in ($fillable + $ImageFields)) {
                $operation.BodyFields | Should -Contain $field
                (Get-Command $operation.Command).Parameters.Keys | Should -Contain $field
            }
            foreach ($field in @('parent_id', 'phone', 'fax', 'email', 'tag_color', 'notes')) {
                $operation.NullableFields | Should -Contain $field
            }
        }

        It 'Records company page pagination supplied by the API middleware' {
            $operation = $script:operations | Where-Object Key -eq 'companies.index'
            $operation.QueryFields | Should -Contain 'page'
        }

        It 'Records the company query limitation for <Field>' -ForEach @(
            @{ Field = 'parent_id'; Source = 'CompaniesController.php:90-97' }
            @{ Field = 'page'; Source = 'SetPaginationDefaults.php:21-26' }
        ) {
            $limitation = @($script:ledger.FieldLimitations | Where-Object {
                $_.Operation -eq 'companies.index' -and $_.Field -eq $Field
            })
            $limitation.Count | Should -Be 1
            $limitation[0].Source | Should -Match ([regex]::Escape($Source))
            $limitation[0].Reason | Should -Match 'client'
        }

        It 'Records the newly audited query fields for <Resource>' -ForEach @(
            @{ Resource = 'accessories'; Fields = @('location_id', 'notes', 'expand_company_hierarchy', 'filter') }
            @{ Resource = 'categories'; Fields = @('category_type', 'archived', 'require_acceptance', 'filter') }
            @{ Resource = 'companies'; Fields = @('parent_id', 'email', 'tag_color', 'filter') }
            @{ Resource = 'components'; Fields = @('supplier_id', 'manufacturer_id', 'model_number', 'filter') }
            @{ Resource = 'consumables'; Fields = @('supplier_id', 'notes', 'expand_company_hierarchy', 'filter') }
            @{ Resource = 'departments'; Fields = @('tag_color', 'filter') }
            @{ Resource = 'groups'; Fields = @('name', 'filter') }
            @{ Resource = 'hardware'; Fields = @('assigned_to', 'assigned_type', 'byod', 'components', 'filter') }
            @{ Resource = 'licenses'; Fields = @('maintained', 'expires', 'deleted', 'filter') }
            @{ Resource = 'locations'; Fields = @('company_id', 'parent_id', 'manager_id', 'filter') }
            @{ Resource = 'manufacturers'; Fields = @('url', 'support_url', 'warranty_lookup_url', 'filter') }
            @{ Resource = 'models'; Fields = @('requestable', 'depreciation_id', 'notes', 'filter') }
            @{ Resource = 'statuslabels'; Fields = @('status_type', 'filter') }
            @{ Resource = 'suppliers'; Fields = @('url', 'filter') }
            @{ Resource = 'users'; Fields = @('all', 'activated', 'remote', 'manages_users_count', 'filter') }
        ) {
            $operation = $script:operations | Where-Object Key -eq "$Resource.index"
            foreach ($field in $Fields) { $operation.QueryFields | Should -Contain $field }
        }

        It 'Records newly audited writable fields for <Resource>' -ForEach @(
            @{ Resource = 'accessories'; Fields = @('location_id', 'notes') }
            @{ Resource = 'categories'; Fields = @('alert_on_response', 'tag_color', 'notes') }
            @{ Resource = 'components'; Fields = @('manufacturer_id', 'model_number', 'notes') }
            @{ Resource = 'consumables'; Fields = @('model_number', 'notes') }
            @{ Resource = 'departments'; Fields = @('phone', 'fax', 'notes') }
            @{ Resource = 'fields'; Fields = @('is_unique', 'auto_add_to_fieldsets', 'display_audit') }
            @{ Resource = 'groups'; Fields = @('notes') }
            @{ Resource = 'hardware'; Fields = @('location_id', 'eol_explicit', 'expected_checkin', 'last_audit_date') }
            @{ Resource = 'licenses'; Fields = @('serial', 'depreciation_id', 'min_amt') }
            @{ Resource = 'locations'; Fields = @('ldap_ou', 'company_id', 'tag_color', 'notes') }
            @{ Resource = 'manufacturers'; Fields = @('warranty_lookup_url', 'tag_color', 'notes') }
            @{ Resource = 'models'; Fields = @('depreciation_id', 'require_serial') }
            @{ Resource = 'statuslabels'; Fields = @('color') }
            @{ Resource = 'suppliers'; Fields = @('tag_color') }
            @{ Resource = 'users'; Fields = @('avatar', 'permissions', 'display_name', 'scim_externalid') }
        ) {
            foreach ($action in @('store', 'update')) {
                $operation = $script:operations | Where-Object Key -eq "$Resource.$action"
                foreach ($field in $Fields) { $operation.BodyFields | Should -Contain $field }
            }
        }

        It 'Does not advertise server-ignored update fields as writable' {
            $field = $script:operations | Where-Object Key -eq 'fields.update'
            $field.BodyFields | Should -Not -Contain 'field_encrypted'
            $asset = $script:operations | Where-Object Key -eq 'hardware.update'
            foreach ($ignored in @('archived', 'assigned_to', 'asset_attributes', 'user_id', 'checkout_to_type')) {
                $asset.BodyFields | Should -Not -Contain $ignored
            }
        }

        It 'Records accessory checkout quantity without treating it as mandatory' {
            $operation = $script:operations | Where-Object Key -eq 'accessories.checkout'
            $operation.BodyFields | Should -Contain 'checkout_qty'
            $operation.RequiredFields | Should -Not -Contain 'checkout_qty'
        }

        It 'Records the mixed tag lookup and paginated serial lookup response contracts' {
            ($script:operations | Where-Object Key -eq 'hardware.bytag.show').ResponseKind | Should -Be 'DirectObjectOrRowsTotal'
            $serial = $script:operations | Where-Object Key -eq 'hardware.byserial.show'
            $serial.ResponseKind | Should -Be 'RowsTotal'
            $serial.Pagination | Should -Be 'OffsetLimit'
            $serial.QueryFields | Should -Contain 'deleted'
        }

        It 'Records audit mutation controls and bulk ID arrays' {
            foreach ($key in @('hardware.audit', 'hardware.asset.audit', 'hardware.audit.bulk')) {
                $operation = $script:operations | Where-Object Key -eq $key
                $operation.BodyFields | Should -Contain 'update_location'
                $operation.BodyFields | Should -Contain 'clear_name'
            }
            $bulk = $script:operations | Where-Object Key -eq 'hardware.audit.bulk'
            $bulk.BodyFields | Should -Contain 'ids'
            $bulk.BodyFields | Should -Not -Contain 'asset_tags'
            $componentCheckin = $script:operations | Where-Object Key -eq 'components.checkin'
            $componentCheckin.BodyFields | Should -Contain 'checkin_qty'
            $componentCheckin.BodyFields | Should -Not -Contain 'assigned_qty'
            ($script:operations | Where-Object Key -eq 'consumables.checkout').BodyFields | Should -Contain 'checkout_qty'
            ($script:operations | Where-Object Key -eq 'licenses.seats.update').BodyFields | Should -Contain 'asset_id'
            $bulkUpdate = $script:operations | Where-Object Key -eq 'hardware.bulk.update'
            $bulkUpdate.BodyFields | Should -Contain 'status_id'
            $bulkUpdate.BodyFields | Should -Not -Contain 'attributes'
        }

        It 'Records authorization requirements for every core resource operation' {
            $resources = @('accessories', 'categories', 'companies', 'components', 'consumables', 'departments',
                'fields', 'fieldsets', 'groups', 'hardware', 'licenses', 'locations', 'manufacturers', 'models',
                'statuslabels', 'suppliers', 'users')
            foreach ($resource in $resources) {
                foreach ($action in @('index', 'store', 'show', 'update', 'destroy')) {
                    $operation = $script:operations | Where-Object Key -eq "$resource.$action"
                    $operation.Authorization | Should -Not -BeNullOrEmpty -Because "$resource.$action has a pinned authorization contract"
                }
            }
        }

        It 'Records authorization for every supported operation' {
            foreach ($operation in ($script:operations | Where-Object { $_.State -in @('Existing', 'Verified') })) {
                $operation.Authorization | Should -Not -BeNullOrEmpty -Because "$($operation.Key) has an authorization contract"
            }
        }

        It 'Records auxiliary success response shapes from the controller rather than the dispatcher output' {
            foreach ($key in @('maintenances.show', 'maintenance-types.show', 'licenses.seats.show')) {
                ($script:operations | Where-Object Key -eq $key).ResponseKind | Should -Be 'DirectObject'
            }
            foreach ($key in @('maintenances.notes.index', 'hardware.labels')) {
                ($script:operations | Where-Object Key -eq $key).ResponseKind | Should -Be 'StandardEnvelope'
            }
            foreach ($key in @('consumables.users', 'hardware.licenses')) {
                ($script:operations | Where-Object Key -eq $key).Pagination | Should -Be 'None'
            }
        }

        It 'Records license workflow target and notes keys rather than legacy note input' {
            $checkout = $script:operations | Where-Object Key -eq 'licenses.checkout'
            $checkout.BodyFields | Should -Contain 'target_type'
            $checkout.RequiredFields | Should -Contain 'target_type'
            foreach ($key in @('licenses.checkout', 'licenses.checkin')) {
                $operation = $script:operations | Where-Object Key -eq $key
                $operation.BodyFields | Should -Contain 'notes'
                $operation.BodyFields | Should -Not -Contain 'note'
                $operation.NullableFields | Should -Contain 'notes'
            }
        }

        It 'Records relationship pagination and existing checkin controls' {
            foreach ($key in @('users.accessories', 'users.licenses')) {
                $operation = $script:operations | Where-Object Key -eq $key
                foreach ($field in @('limit', 'offset')) { $operation.QueryFields | Should -Contain $field }
            }
            $checkin = $script:operations | Where-Object Key -eq 'hardware.checkin'
            foreach ($field in @('clear_name', 'update_default_location')) { $checkin.BodyFields | Should -Contain $field }
            $labels = $script:operations | Where-Object Key -eq 'hardware.labels'
            $labels.BodyFields | Should -Not -Contain 'asset_ids'
            $labels.RequiredFields | Should -Contain 'asset_tags'
        }

        It 'Records unpaginated rows-total wrappers and chart objects for auxiliary collections' {
            foreach ($key in @('kits.licenses.index', 'kits.models.index', 'kits.accessories.index',
                    'kits.consumables.index', 'locations.assets', 'locations.assigned.assets', 'account.eulas', 'account.requests')) {
                $operation = $script:operations | Where-Object Key -eq $key
                $operation.ResponseKind | Should -Be 'RowsTotal'
                $operation.Pagination | Should -Be 'None'
            }
            foreach ($key in @('statuslabels.count.name', 'statuslabels.count.type', 'settings.mailtest', 'settings.purge_barcodes',
                    'fields.fieldsets.order', 'depreciations.show', 'kits.show')) {
                ($script:operations | Where-Object Key -eq $key).ResponseKind | Should -Be 'DirectObject'
            }
            ($script:operations | Where-Object Key -eq 'notes.index').ResponseKind | Should -Be 'StandardEnvelope'
            $labels = $script:operations | Where-Object Key -eq 'labels.index'
            $labels.ResponseKind | Should -Be 'RowsTotal'
            $labels.Pagination | Should -Be 'OffsetLimit'
            foreach ($field in @('search', 'limit', 'offset')) { $labels.QueryFields | Should -Contain $field }
        }

        It 'Records actual history and kit list controller names' {
            foreach ($operation in ($script:operations | Where-Object Key -Like '*.history')) {
                $operation.Controller | Should -Match 'Controller::history$'
            }
            foreach ($pair in @(@('licenses', 'Licenses'), @('models', 'Models'), @('accessories', 'Accessories'), @('consumables', 'Consumables'))) {
                ($script:operations | Where-Object Key -eq "kits.$($pair[0]).index").Controller | Should -Be "PredefinedKitsController::index$($pair[1])"
            }
        }

        It 'Records maintenance wire names rather than client aliases and create-only asset arrays' {
            foreach ($key in @('maintenances.store', 'maintenances.update')) {
                $operation = $script:operations | Where-Object Key -eq $key
                foreach ($field in @('name', 'maintenance_type_id', 'url', 'completed_at', 'completed_by')) { $operation.BodyFields | Should -Contain $field }
                foreach ($field in @('title', 'asset_maintenance_type_id')) { $operation.BodyFields | Should -Not -Contain $field }
            }
            $create = $script:operations | Where-Object Key -eq 'maintenances.store'
            foreach ($field in @('name', 'maintenance_type_id', 'start_date')) { $create.RequiredFields | Should -Contain $field }
            foreach ($field in @('asset_id', 'supplier_id', 'asset_maintenance_type')) { $create.RequiredFields | Should -Not -Contain $field }
            ($script:operations | Where-Object Key -eq 'maintenances.update').BodyFields | Should -Not -Contain 'asset_ids'
        }

        It 'Records all shared asset-index filters for report and due routes' {
            $asset = $script:operations | Where-Object Key -eq 'hardware.index'
            foreach ($key in @('reports.depreciation', 'hardware.upcoming')) {
                $operation = $script:operations | Where-Object Key -eq $key
                foreach ($field in $asset.QueryFields) { $operation.QueryFields | Should -Contain $field }
            }
        }

        It 'Records flat maintenance reads and nullable durations' {
            ($script:operations | Where-Object Key -eq 'maintenances.index').QueryFields | Should -Contain 'format'
            foreach ($key in @('maintenances.store', 'maintenances.update')) {
                ($script:operations | Where-Object Key -eq $key).NullableFields | Should -Contain 'asset_maintenance_time'
            }
        }

        It 'Distinguishes bulk result envelopes from payload envelopes' {
            foreach ($key in @('hardware.audit.bulk', 'hardware.bulk.update')) {
                ($script:operations | Where-Object Key -eq $key).ResponseKind | Should -Be 'BulkResult'
            }
        }

        It 'Links active operations to existing test files and exported commands' {
            foreach ($operation in ($script:operations | Where-Object { $_.State -in @('Existing', 'Verified') })) {
                Test-Path (Join-Path "$PSScriptRoot/.." $operation.TestFile) | Should -BeTrue -Because $operation.Key
                Get-Command $operation.Command -Module SnipeitPS -ErrorAction Stop | Should -Not -BeNullOrEmpty
            }
        }

        It 'Every operation has an allowed State' {
            $allowedStates = @('Existing', 'Planned', 'BlockedServer', 'ExcludedProtocol', 'Verified')
            foreach ($op in $script:operations) {
                $op.State | Should -BeIn $allowedStates
                foreach ($field in @($op.RequiredFields) + @($op.NullableFields)) {
                    (@($op.BodyFields) + @($op.QueryFields)) | Should -Contain $field -Because "$($op.Key) field references must name actual inputs"
                }
            }
        }
    }

    Context 'Command Naming and Test Linkage for Supported Operations' {
        It 'Active operations specify valid Verb-Noun command names' {
            $approvedVerbs = Get-Verb | Select-Object -ExpandProperty Verb
            $activeOps = $script:operations | Where-Object { $_.State -in @('Existing', 'Planned', 'Verified') }
            foreach ($op in $activeOps) {
                $op.Command | Should -Not -BeNullOrEmpty
                $parts = $op.Command -split '-'
                $parts.Count | Should -Be 2
                $parts[0] | Should -BeIn $approvedVerbs
                $parts[1] | Should -Match '^Snipeit[A-Z][a-zA-Z0-9]+$'
            }
        }

        It 'Active operations specify test files under Tests/' {
            $activeOps = $script:operations | Where-Object { $_.State -in @('Existing', 'Planned', 'Verified') }
            foreach ($op in $activeOps) {
                $op.TestFile | Should -Not -BeNullOrEmpty
                $op.TestFile | Should -Match '^Tests/[a-zA-Z0-9_.-]+\.Tests\.ps1$'
            }
        }

        It 'BlockedServer and ExcludedProtocol operations have empty command strings' {
            $nonActionable = $script:operations | Where-Object { $_.State -in @('BlockedServer', 'ExcludedProtocol') }
            foreach ($op in $nonActionable) {
                $op.Command | Should -BeNullOrEmpty
            }
        }
    }

    Context 'Domain Completeness and Coverage' {
        It 'Accounts for all 21 standard CRUD families' {
            $standardFamilies = @(
                'accessories', 'categories', 'companies', 'departments', 'components',
                'consumables', 'depreciations', 'fields', 'fieldsets', 'groups',
                'hardware', 'maintenances', 'maintenance-types', 'licenses',
                'locations', 'manufacturers', 'models', 'statuslabels',
                'suppliers', 'users', 'kits'
            )
            foreach ($fam in $standardFamilies) {
                $crudKeys = @("$fam.index", "$fam.store", "$fam.show", "$fam.update", "$fam.destroy")
                foreach ($k in $crudKeys) {
                    $found = $script:operations | Where-Object { $_.Key -eq $k }
                    $found | Should -Not -BeNullOrEmpty
                }
            }
        }

        It 'Accounts for all 16 predefined kit relationship operations' {
            $kitRels = @('licenses', 'models', 'accessories', 'consumables')
            $kitActions = @('index', 'attach', 'update', 'detach')
            foreach ($r in $kitRels) {
                foreach ($a in $kitActions) {
                    $key = "kits.$r.$a"
                    $found = $script:operations | Where-Object { $_.Key -eq $key }
                    $found | Should -Not -BeNullOrEmpty
                }
            }
        }

        It 'Accounts for all 13 selectlist operations' {
            $slFamilies = @(
                'accessories', 'categories', 'companies', 'departments', 'consumables',
                'hardware', 'licenses', 'locations', 'manufacturers', 'models',
                'statuslabels', 'suppliers', 'users'
            )
            foreach ($fam in $slFamilies) {
                $key = "$fam.selectlist"
                $found = $script:operations | Where-Object { $_.Key -eq $key }
                $found | Should -Not -BeNullOrEmpty
            }
        }

        It 'Accounts for all 9 history query operations' {
            $histFamilies = @('accessories', 'components', 'consumables', 'hardware', 'licenses', 'locations', 'maintenances', 'models', 'users')
            foreach ($fam in $histFamilies) {
                $key = "$fam.history"
                $found = $script:operations | Where-Object { $_.Key -eq $key }
                $found | Should -Not -BeNullOrEmpty
            }
        }

        It 'Accounts for all 6 assigned relationship queries' {
            $assignedKeys = @(
                'hardware.assigned.assets',
                'hardware.assigned.accessories',
                'hardware.assigned.components',
                'locations.assets',
                'locations.assigned.assets',
                'locations.assigned.accessories'
            )
            foreach ($k in $assignedKeys) {
                $found = $script:operations | Where-Object { $_.Key -eq $k }
                $found | Should -Not -BeNullOrEmpty
            }
        }

        It 'Accounts for all 8 self-service account operations' {
            $accountKeys = @(
                'account.requests',
                'account.request.store',
                'account.request.cancel',
                'account.requestable.hardware',
                'account.eulas',
                'account.tokens.index',
                'account.tokens.store',
                'account.tokens.destroy'
            )
            foreach ($k in $accountKeys) {
                $found = $script:operations | Where-Object { $_.Key -eq $k }
                $found | Should -Not -BeNullOrEmpty
            }
        }

        It 'Accounts for known server blockers' {
            $blockers = @(
                'imports.show',
                'imports.update',
                'settings.index',
                'settings.store',
                'settings.update',
                'models.assets',
                'files.audits.destroy'
            )
            foreach ($b in $blockers) {
                $found = $script:operations | Where-Object { $_.Key -eq $b }
                $found | Should -Not -BeNullOrEmpty
                $found.State | Should -Be 'BlockedServer'
            }
        }
    }
}
