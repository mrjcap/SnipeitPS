BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'User and asset date and permission contracts' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:dateSession = [SnipeitSession]::new('https://contract.invalid', $key)
            $script:dateSession.ThrottleLimit = 0
            $script:dateCalls = [System.Collections.Generic.List[object]]::new()
            Mock Invoke-RestMethod -ModuleName SnipeitPS {
                param($Body)
                $script:dateCalls.Add(([Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json))
                [pscustomobject]@{ status = 'success'; payload = @{ id = 1 } }
            }
        }

        Context '<Command> dates' -ForEach @(
            @{ Command = 'New-SnipeitUser'; Identity = @{ first_name = 'Test'; username = 'test' }; Dates = @('start_date', 'end_date'); Timestamps = @() }
            @{ Command = 'Set-SnipeitUser'; Identity = @{ id = 1 }; Dates = @('start_date', 'end_date'); Timestamps = @() }
            @{ Command = 'New-SnipeitAsset'; Identity = @{ status_id = 1; model_id = 1; asset_tag = 'TEST-1' }; Dates = @('asset_eol_date', 'expected_checkin', 'next_audit_date'); Timestamps = @('last_checkout', 'last_checkin', 'last_audit_date') }
            @{ Command = 'Set-SnipeitAsset'; Identity = @{ id = 1 }; Dates = @('asset_eol_date', 'expected_checkin', 'next_audit_date'); Timestamps = @('last_checkin', 'last_audit_date') }
        ) {
            It 'Serializes dates and timestamps in invariant server formats' {
                $parameters = $Identity.Clone()
                foreach ($field in @($Dates) + @($Timestamps)) { $parameters[$field] = [datetime]'2026-09-17T13:14:15' }
                & $Command @parameters -Session $script:dateSession -Confirm:$false
                $script:dateCalls.Count | Should -Be 1
                foreach ($field in $Dates) { $script:dateCalls[0].$field | Should -BeExactly '2026-09-17' }
                foreach ($field in $Timestamps) { $script:dateCalls[0].$field | Should -BeExactly '2026-09-17 13:14:15' }
            }

            It 'Preserves explicit null dates' {
                $parameters = $Identity.Clone()
                foreach ($field in @($Dates) + @($Timestamps)) { $parameters[$field] = $null }
                & $Command @parameters -Session $script:dateSession -Confirm:$false
                $script:dateCalls.Count | Should -Be 1
                foreach ($field in @($Dates) + @($Timestamps)) {
                    $script:dateCalls[0].PSObject.Properties.Name | Should -Contain $field
                    ($null -eq $script:dateCalls[0].$field) | Should -BeTrue
                }
            }

            It 'Omits unbound dates' {
                & $Command @Identity -Session $script:dateSession -Confirm:$false
                $script:dateCalls.Count | Should -Be 1
                foreach ($field in @($Dates) + @($Timestamps)) {
                    $script:dateCalls[0].PSObject.Properties.Name | Should -Not -Contain $field
                }
            }

            It 'Does not send dates under WhatIf' {
                $parameters = $Identity.Clone()
                foreach ($field in @($Dates) + @($Timestamps)) { $parameters[$field] = $null }
                & $Command @parameters -Session $script:dateSession -WhatIf
                Should -Invoke Invoke-RestMethod -Times 0 -Exactly -ModuleName SnipeitPS
            }
        }

        It 'Sends <Command> permission maps as nested JSON objects' -ForEach @(
            @{ Command = 'New-SnipeitUser'; Identity = @{ first_name = 'Test'; username = 'test' } }
            @{ Command = 'Set-SnipeitUser'; Identity = @{ id = 1 } }
        ) {
            & $Command @Identity -permissions @{ 'assets.view' = 1; 'assets.edit' = 0 } -Session $script:dateSession -Confirm:$false
            $script:dateCalls.Count | Should -Be 1
            $script:dateCalls[0].permissions.'assets.view' | Should -Be 1
            $script:dateCalls[0].permissions.'assets.edit' | Should -Be 0
            $script:dateCalls[0].permissions | Should -BeOfType [pscustomobject]
        }

        It 'Sends an empty permission object when clearing direct permissions' {
            Set-SnipeitUser -id 1 -permissions @{} -Session $script:dateSession -Confirm:$false
            $script:dateCalls.Count | Should -Be 1
            $script:dateCalls[0].permissions | Should -BeOfType [pscustomobject]
            @($script:dateCalls[0].permissions.PSObject.Properties).Count | Should -Be 0
        }

        It 'Rejects ignored asset field <Field> before HTTP dispatch' -ForEach @(
            @{ Field = 'assigned_to'; Value = 2; Message = '*Set-SnipeitAssetOwner*' }
            @{ Field = 'assigned_to'; Value = $null; Message = '*Set-SnipeitAssetOwner*' }
            @{ Field = 'archived'; Value = $true; Message = '*status_id*' }
            @{ Field = 'archived'; Value = $false; Message = '*status_id*' }
        ) {
            $parameters = @{ id = 1; Session = $script:dateSession; Confirm = $false }
            $parameters[$Field] = $Value
            { Set-SnipeitAsset @parameters } | Should -Throw -ExpectedMessage $Message
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly -ModuleName SnipeitPS
        }
    }
}
