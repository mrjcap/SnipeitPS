BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Current API acquisition contracts' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:acquisitionSession = [SnipeitSession]::new('https://acquisition.invalid', $key)
            $script:acquisitionSession.ThrottleLimit = 0
            $script:acquisitionCalls = [System.Collections.Generic.List[object]]::new()
            $script:acquisitionResponse = [pscustomobject]@{
                status = 'success'; payload = [pscustomobject]@{ id = 7; qty = 12 }
            }
            Mock Invoke-RestMethod -ModuleName SnipeitPS {
                param($Uri, $Method, $Body, $Headers)
                $json = $null
                $multipart = $null
                if ($Body -is [byte[]]) {
                    $json = [Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json
                } elseif ($Body -is [IO.Stream]) {
                    $copy = [IO.MemoryStream]::new()
                    try {
                        $Body.CopyTo($copy)
                        $multipart = [Text.Encoding]::UTF8.GetString($copy.ToArray())
                    } finally { $copy.Dispose() }
                }
                $script:acquisitionCalls.Add(@{ Uri = $Uri; Method = $Method; Json = $json; Multipart = $multipart; Headers = $Headers })
                $script:acquisitionResponse
            }
        }

        It 'Exports <Command> with usable offline help' -ForEach @(
            @{ Command = 'Get-SnipeitOrderItem' }
            @{ Command = 'Invoke-SnipeitQuantityAdjustment' }
        ) {
            Get-Command $Command -Module SnipeitPS | Should -Not -BeNullOrEmpty
            (Get-Help $Command).Synopsis | Should -Not -BeNullOrEmpty
        }

        Context 'Order-item listing' {
            BeforeEach {
                $script:acquisitionResponse = [pscustomobject]@{
                    total = 1; rows = @([pscustomobject]@{ id = 101; qty = 3; unit_cost = '12.50'; receipt = '/receipt/101' })
                }
            }

            It 'Scopes <EntityType> to its actual model class' -ForEach @(
                @{ EntityType = 'Accessory'; Model = 'Accessory' }
                @{ EntityType = 'Component'; Model = 'Component' }
                @{ EntityType = 'Consumable'; Model = 'Consumable' }
                @{ EntityType = 'Asset'; Model = 'Asset' }
                @{ EntityType = 'License'; Model = 'License' }
            ) {
                $result = Get-SnipeitOrderItem -EntityType $EntityType -item_id 7 -Session $script:acquisitionSession
                $script:acquisitionCalls.Count | Should -Be 1
                $call = $script:acquisitionCalls[0]
                $call.Method | Should -Be 'Get'
                ([uri]$call.Uri).AbsolutePath | Should -BeExactly '/api/v1/order-items'
                [uri]::UnescapeDataString(([uri]$call.Uri).Query) | Should -Match "item_type=App\\Models\\$Model"
                $call.Uri | Should -Match 'item_id=7(?:&|$)'
                $result.id | Should -Be 101
                $result.unit_cost | Should -BeExactly '12.50'
                $result.PSObject.TypeNames | Should -Contain 'SnipeitPS.OrderItem'
                $result.PSObject.TypeNames | Should -Not -Contain "SnipeitPS.$EntityType"
            }

            It 'Supports model aggregation and exact list controls' {
                Get-SnipeitOrderItem -asset_model_id 4 -search 'PO 12' -sort total_cost -order asc -limit 2 -offset 1 -Session $script:acquisitionSession
                $query = [uri]::UnescapeDataString(([uri]$script:acquisitionCalls[0].Uri).Query)
                foreach ($value in @('asset_model_id=4', 'sort=total_cost', 'order=asc', 'limit=2', 'offset=1')) {
                    $query | Should -Match ([regex]::Escape($value))
                }
                $query | Should -Not -Match 'item_type|item_id|EntityType|Session|preserveResponse'
            }

            It 'Allows the server-authorized unscoped listing' {
                Get-SnipeitOrderItem -Session $script:acquisitionSession
                ([uri]$script:acquisitionCalls[0].Uri).Query | Should -Not -Match 'item_id|item_type|asset_model_id'
            }

            It 'Requires a complete parent scope and rejects mixed scopes' {
                { Get-SnipeitOrderItem -EntityType Accessory -Session $script:acquisitionSession } | Should -Throw
                { Get-SnipeitOrderItem -item_id 7 -Session $script:acquisitionSession } | Should -Throw
                { Get-SnipeitOrderItem -EntityType Accessory -item_id 7 -asset_model_id 4 -Session $script:acquisitionSession } | Should -Throw
                $script:acquisitionCalls.Count | Should -Be 0
            }

            It 'Preserves the envelope without tagging raw rows' {
                $result = Get-SnipeitOrderItem -preserveResponse -Session $script:acquisitionSession
                $result.total | Should -Be 1
                $result.rows[0].PSObject.TypeNames | Should -Not -Contain 'SnipeitPS.OrderItem'
            }

            It 'Returns no rows for an empty collection' {
                $script:acquisitionResponse = [pscustomobject]@{ total = 0; rows = @() }
                @(Get-SnipeitOrderItem -Session $script:acquisitionSession).Count | Should -Be 0
            }

            It 'Paginates while keeping scope and row identity' {
                Mock Invoke-RestMethod -ModuleName SnipeitPS {
                    param($Uri)
                    $script:acquisitionCalls.Add(@{ Uri = $Uri })
                    $offset = if ($Uri -match 'offset=(\d+)') { [int]$Matches[1] } else { 0 }
                    [pscustomobject]@{ total = 3; rows = @([pscustomobject]@{ id = 101 + $offset }) }
                }
                $rows = @(Get-SnipeitOrderItem -EntityType Component -item_id 7 -limit 1 -all -Session $script:acquisitionSession)
                $rows.id | Should -Be @(101, 102, 103)
                $script:acquisitionCalls.Count | Should -Be 3
                foreach ($row in $rows) { $row.PSObject.TypeNames | Should -Contain 'SnipeitPS.OrderItem' }
                foreach ($call in $script:acquisitionCalls) { $call.Uri | Should -Match 'item_id=7' }
            }

            It 'Rejects all combined with raw envelope preservation' {
                { Get-SnipeitOrderItem -all -preserveResponse -Session $script:acquisitionSession } | Should -Throw
                $script:acquisitionCalls.Count | Should -Be 0
            }
        }

        Context 'Signed quantity adjustments' {
            It 'Posts a signed delta to <Route> and returns the parent' -ForEach @(
                @{ EntityType = 'Accessory'; Route = 'accessories'; Amount = 3 }
                @{ EntityType = 'Component'; Route = 'components'; Amount = -2 }
                @{ EntityType = 'Consumable'; Route = 'consumables'; Amount = 0 }
            ) {
                $result = Invoke-SnipeitQuantityAdjustment -EntityType $EntityType -resource_id 7 -amount $Amount -note 'Stock count' -Session $script:acquisitionSession -Confirm:$false
                $call = $script:acquisitionCalls[0]
                $call.Uri | Should -BeExactly "https://acquisition.invalid/api/v1/$Route/7/adjust-quantity"
                $call.Method | Should -Be 'Post'
                $call.Json.amount | Should -Be $Amount
                $call.Json.note | Should -BeExactly 'Stock count'
                @($call.Json.PSObject.Properties).Count | Should -Be 2
                $result.id | Should -Be 7
                $result.PSObject.TypeNames | Should -Contain "SnipeitPS.$EntityType"
            }

            It 'Serializes all acquisition metadata and preserves zero cost' {
                Invoke-SnipeitQuantityAdjustment -EntityType Accessory -resource_id 7 -amount 3 -note 'Received' -unit_cost 0 -supplier_id 2 -order_number 'PO-12' -purchase_date ([datetime]'2026-10-01') -currency EUR -Session $script:acquisitionSession -Confirm:$false
                $json = $script:acquisitionCalls[0].Json
                $json.unit_cost | Should -Be 0
                $json.supplier_id | Should -Be 2
                $json.purchase_date | Should -BeExactly '2026-10-01'
                $json.currency | Should -BeExactly 'EUR'
                $json.order_number | Should -BeExactly 'PO-12'
                $json.PSObject.Properties.Name | Should -Not -Contain 'purchase_cost'
                $json.PSObject.Properties.Name | Should -Not -Contain 'resource_id'
            }

            It 'Keeps explicitly nullable metadata in JSON' {
                Invoke-SnipeitQuantityAdjustment -EntityType Component -resource_id 7 -amount 1 -note 'Received' -unit_cost $null -supplier_id $null -purchase_date $null -Session $script:acquisitionSession -Confirm:$false
                $json = $script:acquisitionCalls[0].Json
                foreach ($field in @('unit_cost', 'supplier_id', 'purchase_date')) {
                    $json.PSObject.Properties.Name | Should -Contain $field
                    $json.$field | Should -BeNullOrEmpty
                }
            }

            It 'Adjusts each explicitly supplied parent ID' {
                Invoke-SnipeitQuantityAdjustment -EntityType Consumable -resource_id 7,8 -amount 1 -note 'Received' -Session $script:acquisitionSession -Confirm:$false
                $script:acquisitionCalls.Count | Should -Be 2
                $script:acquisitionCalls[1].Uri | Should -Match '/consumables/8/adjust-quantity$'
            }

            It 'Binds deliberate resource_id pipeline properties without accepting ambiguous id' {
                [pscustomobject]@{ resource_id = 7 } | Invoke-SnipeitQuantityAdjustment -EntityType Accessory -amount 1 -note 'Received' -Session $script:acquisitionSession -Confirm:$false
                $script:acquisitionCalls.Count | Should -Be 1
                $script:acquisitionCalls.Clear()
                $row = [pscustomobject]@{ PSTypeName = 'SnipeitPS.OrderItem'; id = 101 }
                $errors = @($row | Invoke-SnipeitQuantityAdjustment -EntityType Accessory -amount 1 -note 'Received' -Session $script:acquisitionSession -Confirm:$false -ErrorAction Continue 2>&1)
                @($errors | Where-Object { $_ -is [Management.Automation.ErrorRecord] }).Count | Should -BeGreaterThan 0
                $script:acquisitionCalls.Count | Should -Be 0
            }

            It 'Rejects <Invalid> before transport' -ForEach @(
                @{ Invalid = 'zero parent ID'; Fields = @{ resource_id = 0 } }
                @{ Invalid = 'negative parent ID'; Fields = @{ resource_id = -1 } }
                @{ Invalid = 'negative cost'; Fields = @{ unit_cost = -1 } }
                @{ Invalid = 'zero supplier ID'; Fields = @{ supplier_id = 0 } }
                @{ Invalid = 'blank note'; Fields = @{ note = '' } }
                @{ Invalid = 'unsupported entity'; Fields = @{ EntityType = 'Asset' } }
            ) {
                $parameters = @{ EntityType = 'Accessory'; resource_id = 7; amount = 1; note = 'Received'; Session = $script:acquisitionSession; Confirm = $false }
                foreach ($entry in $Fields.GetEnumerator()) { $parameters[$entry.Key] = $entry.Value }
                { Invoke-SnipeitQuantityAdjustment @parameters } | Should -Throw
                $script:acquisitionCalls.Count | Should -Be 0
            }

            It 'Makes no request under WhatIf, with or without a receipt' {
                Invoke-SnipeitQuantityAdjustment -EntityType Accessory -resource_id 7 -amount 1 -note 'Received' -Session $script:acquisitionSession -WhatIf
                Invoke-SnipeitQuantityAdjustment -EntityType Accessory -resource_id 7 -amount 1 -note 'Received' -File "$TestDrive/missing.pdf" -Session $script:acquisitionSession -WhatIf
                $script:acquisitionCalls.Count | Should -Be 0
            }

            It 'Uses a single file field, invariant decimal and date formatting, and parent output' {
                $file = Join-Path $TestDrive 'receipt.bin'
                [IO.File]::WriteAllBytes($file, [byte[]](65, 0, 66, 255))
                $originalCulture = [Threading.Thread]::CurrentThread.CurrentCulture
                try {
                    [Threading.Thread]::CurrentThread.CurrentCulture = [Globalization.CultureInfo]::GetCultureInfo('el-GR')
                    $result = Invoke-SnipeitQuantityAdjustment -EntityType Component -resource_id 7 -amount 2 -note 'Received' -unit_cost 12.5 -purchase_date ([datetime]::new(2026, 10, 1)) -File $file -Session $script:acquisitionSession -Confirm:$false
                } finally { [Threading.Thread]::CurrentThread.CurrentCulture = $originalCulture }
                $call = $script:acquisitionCalls[0]
                $call.Uri | Should -BeExactly 'https://acquisition.invalid/api/v1/components/7/adjust-quantity'
                $call.Method | Should -Be 'POST'
                $call.Multipart | Should -Match 'name="file"; filename="receipt.bin"'
                $call.Multipart | Should -Not -Match 'name="file\[\]"|name="_method"|name="Session"'
                $call.Multipart | Should -Match 'name="unit_cost"\r\n\r\n12\.5\r\n'
                $call.Multipart | Should -Match 'name="purchase_date"\r\n\r\n2026-10-01\r\n'
                $call.Multipart | Should -Match "A`0B"
                $result.id | Should -Be 7
                $result.PSObject.TypeNames | Should -Contain 'SnipeitPS.Component'
            }

            It 'Rejects a missing receipt before any request' {
                { Invoke-SnipeitQuantityAdjustment -EntityType Component -resource_id 7 -amount 1 -note 'Received' -File "$TestDrive/missing.pdf" -Session $script:acquisitionSession -Confirm:$false } | Should -Throw
                $script:acquisitionCalls.Count | Should -Be 0
            }

            It 'Surfaces API validation without success output for <Transport>' -ForEach @(
                @{ Transport = 'JSON' }
                @{ Transport = 'Multipart' }
            ) {
                $script:acquisitionResponse = [pscustomobject]@{ status = 'error'; payload = $null; messages = @{ amount = @('Below assigned quantity.') } }
                $parameters = @{ EntityType = 'Component'; resource_id = 7; amount = -1; note = 'Stock count'; Session = $script:acquisitionSession; Confirm = $false; ErrorAction = 'Stop' }
                if ($Transport -eq 'Multipart') {
                    $parameters.File = Join-Path $TestDrive 'receipt.txt'
                    [IO.File]::WriteAllText($parameters.File, 'receipt')
                }
                { Invoke-SnipeitQuantityAdjustment @parameters } | Should -Throw '*Below assigned quantity*'
                $script:acquisitionCalls.Count | Should -Be 1
            }

            It 'Never retries a failed adjustment through ordinary resource updates' {
                Mock Invoke-RestMethod -ModuleName SnipeitPS {
                    param($Uri)
                    $script:acquisitionCalls.Add(@{ Uri = $Uri })
                    throw [InvalidOperationException]::new('HTTP 404: adjustment route unavailable')
                }
                { Invoke-SnipeitQuantityAdjustment -EntityType Accessory -resource_id 7 -amount 1 -note 'Received' -Session $script:acquisitionSession -Confirm:$false -ErrorAction Stop } | Should -Throw
                $script:acquisitionCalls.Count | Should -Be 1
                $script:acquisitionCalls[0].Uri | Should -Match '/adjust-quantity$'
            }
        }

        Context 'Additive fields on legacy create/update commands' {
            It 'Preserves nullable and omitted fields on <Verb>-Snipeit<Family>' -ForEach @(
                @{ Family = 'Accessory'; Verb = 'New' }
                @{ Family = 'Component'; Verb = 'New' }
                @{ Family = 'Consumable'; Verb = 'New' }
                @{ Family = 'Accessory'; Verb = 'Set' }
                @{ Family = 'Component'; Verb = 'Set' }
                @{ Family = 'Consumable'; Verb = 'Set' }
            ) {
                $parameters = @{ Session = $script:acquisitionSession; Confirm = $false; default_supplier_id = $null }
                if ($Verb -eq 'New') { $parameters.name = 'Stock item'; $parameters.category_id = 1; $parameters.qty = 3 }
                else { $parameters.id = 7; $parameters.unit_cost = $null }
                & "$Verb-Snipeit$Family" @parameters
                $json = $script:acquisitionCalls[0].Json
                $json.PSObject.Properties.Name | Should -Contain 'default_supplier_id'
                $json.default_supplier_id | Should -BeNullOrEmpty
                $json.PSObject.Properties.Name | Should -Not -Contain 'currency'
                $json.PSObject.Properties.Name | Should -Not -Contain 'note'
                if ($Verb -eq 'Set') {
                    $json.PSObject.Properties.Name | Should -Contain 'unit_cost'
                    $json.unit_cost | Should -BeNullOrEmpty
                }
            }

            It 'Keeps existing positional parameter order for <Command>' -ForEach @(
                @{ Command = 'New-SnipeitAccessory'; Names = @('name', 'qty', 'category_id', 'company_id', 'manufacturer_id', 'order_number', 'model_number', 'purchase_cost', 'purchase_date', 'min_amt', 'supplier_id', 'location_id', 'image', 'requestable', 'Session', 'notes') }
                @{ Command = 'New-SnipeitComponent'; Names = @('name', 'category_id', 'qty', 'company_id', 'location_id', 'order_number', 'purchase_date', 'purchase_cost', 'image', 'Session', 'supplier_id', 'manufacturer_id', 'model_number', 'serial', 'notes', 'min_amt') }
                @{ Command = 'New-SnipeitConsumable'; Names = @('name', 'qty', 'category_id', 'min_amt', 'company_id', 'order_number', 'manufacturer_id', 'location_id', 'requestable', 'purchase_date', 'purchase_cost', 'model_number', 'item_no', 'image', 'Session', 'supplier_id', 'notes') }
                @{ Command = 'Set-SnipeitAccessory'; Names = @('id', 'name', 'qty', 'category_id', 'company_id', 'manufacturer_id', 'model_number', 'order_number', 'purchase_cost', 'purchase_date', 'min_amt', 'supplier_id', 'location_id', 'image', 'requestable', 'image_delete', 'RequestType', 'Session', 'notes') }
                @{ Command = 'Set-SnipeitComponent'; Names = @('id', 'qty', 'min_amt', 'name', 'company_id', 'location_id', 'order_number', 'purchase_date', 'purchase_cost', 'image', 'image_delete', 'RequestType', 'Session', 'supplier_id', 'manufacturer_id', 'model_number', 'serial', 'notes', 'category_id') }
                @{ Command = 'Set-SnipeitConsumable'; Names = @('id', 'name', 'qty', 'category_id', 'min_amt', 'company_id', 'order_number', 'manufacturer_id', 'location_id', 'requestable', 'purchase_date', 'purchase_cost', 'model_number', 'item_no', 'image', 'image_delete', 'RequestType', 'Session', 'supplier_id', 'notes') }
            ) {
                $parameters = (Get-Command $Command).ParameterSets[0].Parameters | Where-Object Position -GE 0 | Sort-Object Position
                $positionalNames = @($Names | Where-Object { $_ -ne 'image_delete' })
                @($parameters | Select-Object -First $positionalNames.Count -ExpandProperty Name) | Should -Be $positionalNames
                if ($Names -contains 'image_delete') {
                    (Get-Command $Command).ParameterSets[0].Parameters.Where({ $_.Name -eq 'image_delete' }).Position | Should -BeLessThan 0
                }
            }

            It 'Sends template supplier and currency for <Verb>-Snipeit<Family>' -ForEach @(
                @{ Family = 'Accessory'; Verb = 'New' }
                @{ Family = 'Component'; Verb = 'New' }
                @{ Family = 'Consumable'; Verb = 'New' }
                @{ Family = 'Accessory'; Verb = 'Set' }
                @{ Family = 'Component'; Verb = 'Set' }
                @{ Family = 'Consumable'; Verb = 'Set' }
            ) {
                $parameters = @{ Session = $script:acquisitionSession; Confirm = $false; default_supplier_id = 4; currency = 'EUR' }
                if ($Verb -eq 'New') {
                    $parameters.name = 'Stock item'; $parameters.category_id = 1; $parameters.qty = 3; $parameters.purchase_cost = '12.5'
                } else {
                    $parameters.id = 7; $parameters.qty = 12; $parameters.unit_cost = 12.5; $parameters.note = 'Received'
                }
                & "$Verb-Snipeit$Family" @parameters
                $json = $script:acquisitionCalls[0].Json
                $json.default_supplier_id | Should -Be 4
                $json.currency | Should -BeExactly 'EUR'
                if ($Verb -eq 'Set') { $json.unit_cost | Should -Be 12.5; $json.note | Should -BeExactly 'Received'; $json.qty | Should -Be 12 }
                else { $json.purchase_cost | Should -BeExactly '12.5'; $json.PSObject.Properties.Name | Should -Not -Contain 'unit_cost' }
            }
        }
    }
}
