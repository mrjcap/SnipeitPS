BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Nullable create field contracts' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:createSession = [SnipeitSession]::new('https://contract.invalid', $key)
            $script:createSession.ThrottleLimit = 0
            $script:createCalls = [System.Collections.Generic.List[object]]::new()
            Mock Invoke-RestMethod -ModuleName SnipeitPS {
                param($Body)
                $script:createCalls.Add(([Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json))
                [pscustomobject]@{ status = 'success'; payload = @{ id = 1 } }
            }
        }

        Context '<Family> nullable optional inputs' -ForEach @(
            @{ Family = 'Accessory'; Required = @{ name = 'Test'; category_id = 1; qty = 2 }; Fields = @('company_id', 'location_id', 'min_amt', 'purchase_date'); PositiveIds = @('company_id', 'location_id') }
            @{ Family = 'Asset'; Required = @{ model_id = 1; status_id = 1; asset_tag = 'TEST' }; Fields = @('company_id', 'supplier_id', 'rtd_location_id', 'warranty_months', 'purchase_date'); PositiveIds = @('company_id', 'supplier_id', 'rtd_location_id') }
            @{ Family = 'Component'; Required = @{ name = 'Test'; category_id = 1; qty = 2 }; Fields = @('company_id', 'location_id', 'purchase_date'); PositiveIds = @('company_id', 'location_id') }
            @{ Family = 'Consumable'; Required = @{ name = 'Test'; category_id = 1; qty = 2 }; Fields = @('company_id', 'location_id', 'min_amt', 'purchase_date'); PositiveIds = @('company_id', 'location_id') }
            @{ Family = 'Department'; Required = @{ name = 'Test' }; Fields = @('company_id', 'location_id', 'manager_id'); PositiveIds = @('company_id', 'location_id', 'manager_id') }
            @{ Family = 'License'; Required = @{ name = 'Test'; category_id = 1; seats = 2 }; Fields = @('company_id', 'purchase_date', 'expiration_date', 'termination_date'); PositiveIds = @('company_id') }
            @{ Family = 'Location'; Required = @{ name = 'Test' }; Fields = @('manager_id', 'parent_id'); PositiveIds = @('manager_id', 'parent_id') }
            @{ Family = 'Model'; Required = @{ name = 'Test'; category_id = 1 }; Fields = @('eol'); PositiveIds = @() }
            @{ Family = 'User'; Required = @{ first_name = 'Test'; username = 'test' }; Fields = @('manager_id', 'location_id'); PositiveIds = @('manager_id', 'location_id') }
        ) {
            It 'Preserves explicit null instead of converting it to zero or rejecting it' {
                $parameters = $Required.Clone()
                foreach ($field in $Fields) { $parameters[$field] = $null }
                & "New-Snipeit$Family" @parameters -Session $script:createSession -Confirm:$false
                $script:createCalls.Count | Should -Be 1
                foreach ($field in $Fields) {
                    $script:createCalls[0].PSObject.Properties.Name | Should -Contain $field
                    $script:createCalls[0].$field | Should -BeNullOrEmpty
                    ($null -eq $script:createCalls[0].$field) | Should -BeTrue
                }
            }

            It 'Omits unbound optional fields' {
                & "New-Snipeit$Family" @Required -Session $script:createSession -Confirm:$false
                $script:createCalls.Count | Should -Be 1
                foreach ($field in $Fields) {
                    $script:createCalls[0].PSObject.Properties.Name | Should -Not -Contain $field
                }
            }

            It 'Retains positive-ID validation while allowing null' {
                foreach ($field in $PositiveIds) {
                    $parameters = $Required.Clone()
                    $parameters[$field] = -1
                    { & "New-Snipeit$Family" @parameters -Session $script:createSession -Confirm:$false } | Should -Throw
                }
                $script:createCalls.Count | Should -Be 0
            }

            It 'Makes no HTTP calls under WhatIf with explicit null' {
                $parameters = $Required.Clone()
                foreach ($field in $Fields) { $parameters[$field] = $null }
                & "New-Snipeit$Family" @parameters -Session $script:createSession -WhatIf
                $script:createCalls.Count | Should -Be 0
            }
        }
    }
}
