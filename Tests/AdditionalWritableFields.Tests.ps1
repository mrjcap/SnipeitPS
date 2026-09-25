BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Additional writable resource fields' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:fieldSession = [SnipeitSession]::new('https://contract.invalid', $key)
            $script:fieldSession.ThrottleLimit = 0
            $script:fieldCalls = [System.Collections.Generic.List[object]]::new()
            Mock Invoke-RestMethod -ModuleName SnipeitPS {
                param($Body, $Uri, $Method)
                $script:fieldCalls.Add(@{
                    Json = [Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json
                    Uri = $Uri
                    Method = $Method
                })
                [pscustomobject]@{ status = 'success'; payload = @{ id = 1 } }
            }
        }

        Context '<Family> fields from server fillable attributes and request handlers' -ForEach @(
            @{ Family = 'User'; Route = 'users'; Create = @{ first_name = 'Test'; username = 'test' }; Fields = @{ display_name = 'Test User'; address = '1 Test Street'; city = 'Athens'; state = 'Attica'; country = 'GR'; zip = '11111'; locale = 'en-US'; mobile = '+30 690 1234567'; remote = $true; vip = $true; autoassign_licenses = $true; website = 'https://example.invalid'; gravatar = 'test@example.invalid'; scim_externalid = 'external-123' }; NewOnly = @{ send_welcome = $false }; SetOnly = @{}; Nullable = @() }
            @{ Family = 'Asset'; Route = 'hardware'; Create = @{ status_id = 1; model_id = 1; asset_tag = 'TEST-1' }; Fields = @{ location_id = 2; byod = $true; eol_explicit = $true }; NewOnly = @{ requestable = $true }; SetOnly = @{}; Nullable = @('location_id') }
            @{ Family = 'Accessory'; Route = 'accessories'; Create = @{ name = 'Accessory'; category_id = 1; qty = 2 }; Fields = @{ notes = 'Accessory notes' }; NewOnly = @{}; SetOnly = @{}; Nullable = @() }
            @{ Family = 'Category'; Route = 'categories'; Create = @{ name = 'Category'; category_type = 'asset' }; Fields = @{ alert_on_response = $true; tag_color = '#123456'; notes = 'Category notes' }; NewOnly = @{}; SetOnly = @{}; Nullable = @() }
            @{ Family = 'Component'; Route = 'components'; Create = @{ name = 'Component'; category_id = 1; qty = 2 }; Fields = @{ supplier_id = 2; manufacturer_id = 3; model_number = 'M-1'; serial = 'S-1'; notes = 'Component notes' }; NewOnly = @{ min_amt = 0 }; SetOnly = @{ category_id = 1 }; Nullable = @('supplier_id', 'manufacturer_id') }
            @{ Family = 'Consumable'; Route = 'consumables'; Create = @{ name = 'Consumable'; category_id = 1; qty = 2 }; Fields = @{ supplier_id = 2; notes = 'Consumable notes' }; NewOnly = @{}; SetOnly = @{}; Nullable = @('supplier_id') }
            @{ Family = 'CustomField'; Route = 'fields'; Create = @{ name = 'Field'; element = 'text'; format = 'ANY' }; Fields = @{ is_unique = $true; display_in_user_view = $true; auto_add_to_fieldsets = $true; show_in_listview = $true; display_checkout = $true; display_checkin = $true; display_audit = $true; show_in_requestable_list = $true }; NewOnly = @{}; SetOnly = @{}; Nullable = @() }
            @{ Family = 'Department'; Route = 'departments'; Create = @{ name = 'Department' }; Fields = @{ phone = '+30 210 1234567'; fax = '+30 210 7654321' }; NewOnly = @{}; SetOnly = @{ tag_color = '#123456' }; Nullable = @() }
            @{ Family = 'License'; Route = 'licenses'; Create = @{ name = 'License'; category_id = 1; seats = 2 }; Fields = @{ depreciation_id = 2; purchase_order = 'PO-123'; min_amt = 0 }; NewOnly = @{}; SetOnly = @{}; Nullable = @('depreciation_id', 'min_amt') }
            @{ Family = 'Location'; Route = 'locations'; Create = @{ name = 'Location' }; Fields = @{ phone = '+30 210 1234567'; fax = '+30 210 7654321'; company_id = 2; tag_color = '#123456'; notes = 'Location notes' }; NewOnly = @{}; SetOnly = @{}; Nullable = @('company_id') }
            @{ Family = 'Manufacturer'; Route = 'manufacturers'; Create = @{ name = 'Manufacturer' }; Fields = @{ support_email = 'support@example.invalid'; support_phone = '+30 210 1234567'; support_url = 'https://support.example.invalid'; warranty_lookup_url = 'https://warranty.example.invalid/{serial}'; tag_color = '#123456'; notes = 'Manufacturer notes' }; NewOnly = @{}; SetOnly = @{}; Nullable = @() }
            @{ Family = 'Model'; Route = 'models'; Create = @{ name = 'Model'; category_id = 1 }; Fields = @{ depreciation_id = 2; min_amt = 0; notes = 'Model notes'; requestable = $true; require_serial = $true }; NewOnly = @{}; SetOnly = @{}; Nullable = @('depreciation_id', 'min_amt') }
            @{ Family = 'Supplier'; Route = 'suppliers'; Create = @{ name = 'Supplier' }; Fields = @{ tag_color = '#123456' }; NewOnly = @{}; SetOnly = @{}; Nullable = @() }
        ) {
            It 'Serializes supplied fields on <Verb> with their JSON types' -ForEach @(
                @{ Verb = 'New'; Method = 'Post' }
                @{ Verb = 'Set'; Method = 'Patch' }
            ) {
                $parameters = @{ Session = $script:fieldSession; Confirm = $false }
                $expected = $Fields.Clone()
                if ($Verb -eq 'New') {
                    foreach ($entry in $Create.GetEnumerator()) { $parameters[$entry.Key] = $entry.Value }
                    foreach ($entry in $NewOnly.GetEnumerator()) { $expected[$entry.Key] = $entry.Value }
                    $expectedUri = "https://contract.invalid/api/v1/$Route"
                } else {
                    $parameters['id'] = 1
                    $parameters['RequestType'] = $Method
                    foreach ($entry in $SetOnly.GetEnumerator()) { $expected[$entry.Key] = $entry.Value }
                    $expectedUri = "https://contract.invalid/api/v1/$Route/1"
                }
                foreach ($entry in $expected.GetEnumerator()) { $parameters[$entry.Key] = $entry.Value }
                & "$Verb-Snipeit$Family" @parameters
                $script:fieldCalls.Count | Should -Be 1
                $call = $script:fieldCalls[0]
                $call.Uri | Should -BeExactly $expectedUri
                $call.Method | Should -Be $Method
                foreach ($entry in $expected.GetEnumerator()) {
                    $call.Json.PSObject.Properties.Name | Should -Contain $entry.Key
                    $actual = $call.Json.($entry.Key)
                    $actual | Should -Be $entry.Value
                    if ($entry.Value -is [bool]) { $actual | Should -BeOfType [bool] }
                    elseif ($entry.Value -is [int]) { ($actual -is [int] -or $actual -is [long]) | Should -BeTrue }
                    else { $actual | Should -BeOfType [string] }
                }
            }

            It 'Omits unbound optional fields on <Verb>' -ForEach @(
                @{ Verb = 'New' }
                @{ Verb = 'Set' }
            ) {
                $parameters = @{ Session = $script:fieldSession; Confirm = $false }
                if ($Verb -eq 'New') {
                    foreach ($entry in $Create.GetEnumerator()) { $parameters[$entry.Key] = $entry.Value }
                } else {
                    $parameters['id'] = 1
                    if ($Family -eq 'User') { $parameters['first_name'] = 'Updated name' }
                    else { $parameters['name'] = 'Updated name' }
                }
                & "$Verb-Snipeit$Family" @parameters
                $script:fieldCalls.Count | Should -Be 1
                foreach ($field in $Fields.Keys) {
                    $script:fieldCalls[0].Json.PSObject.Properties.Name | Should -Not -Contain $field
                }
            }

            It 'Preserves false flags, empty strings, and nullable IDs in updates' {
                $parameters = @{ id = 1; Session = $script:fieldSession; Confirm = $false }
                $expected = @{}
                foreach ($entry in $Fields.GetEnumerator()) {
                    if ($entry.Value -is [bool]) { $expected[$entry.Key] = $false }
                    elseif ($entry.Value -is [string]) { $expected[$entry.Key] = '' }
                    elseif ($entry.Key -in $Nullable) { $expected[$entry.Key] = $null }
                    else { $expected[$entry.Key] = $entry.Value }
                }
                foreach ($entry in $expected.GetEnumerator()) { $parameters[$entry.Key] = $entry.Value }
                & "Set-Snipeit$Family" @parameters
                $script:fieldCalls.Count | Should -Be 1
                foreach ($entry in $expected.GetEnumerator()) {
                    $script:fieldCalls[0].Json.PSObject.Properties.Name | Should -Contain $entry.Key
                    $actual = $script:fieldCalls[0].Json.($entry.Key)
                    if ($null -eq $entry.Value) { ($null -eq $actual) | Should -BeTrue }
                    else { $actual | Should -Be $entry.Value }
                }
            }

            It 'Preserves supplied fields with Put' {
                $parameters = @{ id = 1; RequestType = 'Put'; Session = $script:fieldSession; Confirm = $false }
                foreach ($entry in $Fields.GetEnumerator()) { $parameters[$entry.Key] = $entry.Value }
                & "Set-Snipeit$Family" @parameters
                $script:fieldCalls.Count | Should -Be 1
                $script:fieldCalls[0].Method | Should -Be 'Put'
                foreach ($entry in $Fields.GetEnumerator()) {
                    $script:fieldCalls[0].Json.($entry.Key) | Should -Be $entry.Value
                }
            }

            It 'Makes no HTTP request under WhatIf on <Verb>' -ForEach @(
                @{ Verb = 'New' }
                @{ Verb = 'Set' }
            ) {
                $parameters = @{ Session = $script:fieldSession; WhatIf = $true }
                if ($Verb -eq 'New') {
                    foreach ($entry in $Create.GetEnumerator()) { $parameters[$entry.Key] = $entry.Value }
                } else { $parameters['id'] = 1 }
                foreach ($entry in $Fields.GetEnumerator()) { $parameters[$entry.Key] = $entry.Value }
                & "$Verb-Snipeit$Family" @parameters
                Should -Invoke Invoke-RestMethod -Times 0 -Exactly -ModuleName SnipeitPS
            }
        }
    }
}
