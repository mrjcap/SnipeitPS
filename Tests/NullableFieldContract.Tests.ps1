BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Nullable field wire contracts' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:testSession = [SnipeitSession]::new('https://contract.invalid', $key)
            $script:testSession.ThrottleLimit = 0
            $script:nullableCalls = [System.Collections.Generic.List[object]]::new()
            Mock Invoke-RestMethod -ModuleName SnipeitPS {
                param($Body, $Uri, $Method)
                $script:nullableCalls.Add(@{
                    Json = [Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json
                    Uri = $Uri
                    Method = $Method
                })
                [pscustomobject]@{ status = 'success'; payload = @{ id = 1 } }
            }
        }

        Context '<Command> <Field>' -ForEach @(
            @{ Command = 'Set-SnipeitModel'; Field = 'manufacturer_id'; Route = 'models'; Value = 7; Expected = 7 }
            @{ Command = 'Set-SnipeitLicense'; Field = 'manufacturer_id'; Route = 'licenses'; Value = 7; Expected = 7 }
            @{ Command = 'Set-SnipeitAsset'; Field = 'supplier_id'; Route = 'hardware'; Value = 7; Expected = 7 }
            @{ Command = 'Set-SnipeitAsset'; Field = 'last_checkout'; Route = 'hardware'; Value = [datetime]'2026-09-17T13:14:15'; Expected = '2026-09-17 13:14:15' }
            @{ Command = 'Set-SnipeitAsset'; Field = 'purchase_date'; Route = 'hardware'; Value = [datetime]'2026-09-17T13:14:15'; Expected = '2026-09-17' }
            @{ Command = 'Set-SnipeitLicense'; Field = 'purchase_date'; Route = 'licenses'; Value = [datetime]'2026-09-17T13:14:15'; Expected = '2026-09-17' }
            @{ Command = 'Set-SnipeitLicense'; Field = 'expiration_date'; Route = 'licenses'; Value = [datetime]'2026-09-17T13:14:15'; Expected = '2026-09-17' }
            @{ Command = 'Set-SnipeitLicense'; Field = 'termination_date'; Route = 'licenses'; Value = [datetime]'2026-09-17T13:14:15'; Expected = '2026-09-17' }
            @{ Command = 'Set-SnipeitAccessory'; Field = 'purchase_date'; Route = 'accessories'; Value = [datetime]'2026-09-17T13:14:15'; Expected = '2026-09-17' }
            @{ Command = 'Set-SnipeitComponent'; Field = 'purchase_date'; Route = 'components'; Value = [datetime]'2026-09-17T13:14:15'; Expected = '2026-09-17' }
            @{ Command = 'Set-SnipeitConsumable'; Field = 'purchase_date'; Route = 'consumables'; Value = [datetime]'2026-09-17T13:14:15'; Expected = '2026-09-17' }
        ) {
            It 'Sends explicit JSON null with <RequestType>' -ForEach @(
                @{ RequestType = 'Patch' }
                @{ RequestType = 'Put' }
            ) {
                $parameters = @{ id = 1; Session = $script:testSession; Confirm = $false; RequestType = $RequestType }
                $parameters[$Field] = $null
                & $Command @parameters
                $script:nullableCalls.Count | Should -Be 1
                $call = $script:nullableCalls[0]
                $call.Uri | Should -BeExactly "https://contract.invalid/api/v1/$Route/1"
                $call.Method | Should -Be $RequestType
                $call.Json.PSObject.Properties.Name | Should -Contain $Field
                ($null -eq $call.Json.$Field) | Should -BeTrue
            }

            It 'Leaves an omitted field absent from the request' {
                & $Command -id 1 -name 'Updated name' -Session $script:testSession -Confirm:$false
                $script:nullableCalls.Count | Should -Be 1
                $script:nullableCalls[0].Json.PSObject.Properties.Name | Should -Not -Contain $Field
            }

            It 'Preserves the non-null wire value and type' {
                $parameters = @{ id = 1; Session = $script:testSession; Confirm = $false }
                $parameters[$Field] = $Value
                & $Command @parameters
                $script:nullableCalls.Count | Should -Be 1
                $actual = $script:nullableCalls[0].Json.$Field
                $actual | Should -Be $Expected
                if ($Value -is [datetime]) {
                    $actual | Should -BeOfType [string]
                } else {
                    ($actual -is [int] -or $actual -is [long]) | Should -BeTrue
                }
            }

            It 'Does not dispatch null updates under WhatIf' {
                $parameters = @{ id = 1; Session = $script:testSession; WhatIf = $true }
                $parameters[$Field] = $null
                & $Command @parameters
                Should -Invoke Invoke-RestMethod -Times 0 -Exactly -ModuleName SnipeitPS
            }
        }

        It 'Rejects nonpositive <Field> on <Command> before HTTP dispatch' -ForEach @(
            @{ Command = 'Set-SnipeitModel'; Field = 'manufacturer_id' }
            @{ Command = 'Set-SnipeitLicense'; Field = 'manufacturer_id' }
            @{ Command = 'Set-SnipeitAsset'; Field = 'supplier_id' }
        ) {
            foreach ($invalid in @(0, -1)) {
                $parameters = @{ id = 1; Session = $script:testSession; Confirm = $false }
                $parameters[$Field] = $invalid
                { & $Command @parameters } | Should -Throw
            }
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly -ModuleName SnipeitPS
        }

        It 'Sends nullable asset fields through the bulk route' {
            Set-SnipeitAsset -id 1,2 -supplier_id $null -purchase_date $null -last_checkout $null -Session $script:testSession -Confirm:$false
            $script:nullableCalls.Count | Should -Be 1
            $call = $script:nullableCalls[0]
            $call.Uri | Should -BeExactly 'https://contract.invalid/api/v1/hardware/bulk'
            $call.Method | Should -Be 'Patch'
            @($call.Json.ids) | Should -Be @(1,2)
            foreach ($field in @('supplier_id', 'purchase_date', 'last_checkout')) {
                $call.Json.PSObject.Properties.Name | Should -Contain $field
                ($null -eq $call.Json.$field) | Should -BeTrue
            }
        }

        It 'Maps model <Parameter> to the writable fieldset_id field with value <Value>' -ForEach @(
            @{ Parameter = 'custom_fieldset_id'; Value = $null }
            @{ Parameter = 'fieldset_id'; Value = $null }
            @{ Parameter = 'custom_fieldset_id'; Value = 7 }
            @{ Parameter = 'fieldset_id'; Value = 7 }
        ) {
            $parameters = @{ id = 1; Session = $script:testSession; Confirm = $false }
            $parameters[$Parameter] = $Value
            Set-SnipeitModel @parameters
            $script:nullableCalls.Count | Should -Be 1
            $json = $script:nullableCalls[0].Json
            $json.PSObject.Properties.Name | Should -Contain 'fieldset_id'
            $json.PSObject.Properties.Name | Should -Not -Contain 'custom_fieldset_id'
            if ($null -eq $Value) {
                ($null -eq $json.fieldset_id) | Should -BeTrue
            } else {
                $json.fieldset_id | Should -Be $Value
            }
        }

        It 'Does not send either fieldset key when omitted' {
            Set-SnipeitModel -id 1 -name 'Updated model' -Session $script:testSession -Confirm:$false
            $script:nullableCalls.Count | Should -Be 1
            $script:nullableCalls[0].Json.PSObject.Properties.Name | Should -Not -Contain 'fieldset_id'
            $script:nullableCalls[0].Json.PSObject.Properties.Name | Should -Not -Contain 'custom_fieldset_id'
        }

        It 'Creates a model without forcing a manufacturer' {
            New-SnipeitModel -name 'Model' -category_id 1 -Session $script:testSession -Confirm:$false
            $script:nullableCalls.Count | Should -Be 1
            $script:nullableCalls[0].Json.PSObject.Properties.Name | Should -Not -Contain 'manufacturer_id'
        }

        It 'Creates a model with an explicit null manufacturer' {
            New-SnipeitModel -name 'Model' -category_id 1 -manufacturer_id $null -Session $script:testSession -Confirm:$false
            $script:nullableCalls.Count | Should -Be 1
            $script:nullableCalls[0].Json.PSObject.Properties.Name | Should -Contain 'manufacturer_id'
            ($null -eq $script:nullableCalls[0].Json.manufacturer_id) | Should -BeTrue
        }

        It 'Still rejects nonpositive manufacturer IDs on model creation' {
            foreach ($invalid in @(0, -1)) {
                { New-SnipeitModel -name 'Model' -category_id 1 -manufacturer_id $invalid -Session $script:testSession -Confirm:$false } | Should -Throw
            }
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly -ModuleName SnipeitPS
        }

        It 'Creates a user without forcing a last name' {
            New-SnipeitUser -first_name 'Test' -username 'test' -Session $script:testSession -Confirm:$false
            $script:nullableCalls.Count | Should -Be 1
            $script:nullableCalls[0].Json.PSObject.Properties.Name | Should -Not -Contain 'last_name'
        }

        It 'Accepts an explicitly empty last name' {
            New-SnipeitUser -first_name 'Test' -last_name '' -username 'test' -Session $script:testSession -Confirm:$false
            $script:nullableCalls.Count | Should -Be 1
            $script:nullableCalls[0].Json.PSObject.Properties.Name | Should -Contain 'last_name'
            $script:nullableCalls[0].Json.last_name | Should -BeExactly ''
        }

        It 'Makes no HTTP request when optional create fields are omitted under WhatIf' {
            New-SnipeitModel -name 'Model' -category_id 1 -Session $script:testSession -WhatIf
            New-SnipeitUser -first_name 'Test' -username 'test' -Session $script:testSession -WhatIf
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly -ModuleName SnipeitPS
        }
    }
}
