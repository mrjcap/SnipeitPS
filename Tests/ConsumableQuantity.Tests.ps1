BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Consumable quantity wire contract' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:testSession = [SnipeitSession]::new('https://contract.invalid', $key)
            $script:testSession.ThrottleLimit = 0
            $script:quantityCalls = [System.Collections.Generic.List[object]]::new()
            Mock Invoke-RestMethod -ModuleName SnipeitPS {
                param($Body, $Uri, $Method)
                $script:quantityCalls.Add(@{
                    Json = [Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json
                    Uri = $Uri
                    Method = $Method
                })
                [pscustomobject]@{ status = 'success'; payload = @{ id = 1 } }
            }
        }

        It 'Serializes quantity <Quantity> as a number with <Method>' -ForEach @(
            @{ Quantity = 0; Method = 'Patch' }
            @{ Quantity = 0; Method = 'Put' }
            @{ Quantity = 1; Method = 'Patch' }
            @{ Quantity = 99999; Method = 'Patch' }
        ) {
            Set-SnipeitConsumable -id 1 -qty $Quantity -RequestType $Method -Session $script:testSession -Confirm:$false
            $script:quantityCalls.Count | Should -Be 1
            $call = $script:quantityCalls[0]
            $call.Uri | Should -BeExactly 'https://contract.invalid/api/v1/consumables/1'
            $call.Method | Should -Be $Method
            $call.Json.PSObject.Properties.Name | Should -Contain 'qty'
            $call.Json.qty | Should -Be $Quantity
            ($call.Json.qty -is [int] -or $call.Json.qty -is [long]) | Should -BeTrue
        }

        It 'Rejects negative quantities before HTTP dispatch' {
            { Set-SnipeitConsumable -id 1 -qty -1 -Session $script:testSession -Confirm:$false } |
                Should -Throw -ErrorId 'ParameterArgumentValidationError,Set-SnipeitConsumable'
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly -ModuleName SnipeitPS
        }

        It 'Omits an unbound quantity rather than resetting stock to zero' {
            Set-SnipeitConsumable -id 1 -name 'Ink' -Session $script:testSession -Confirm:$false
            $script:quantityCalls.Count | Should -Be 1
            $script:quantityCalls[0].Json.PSObject.Properties.Name | Should -Not -Contain 'qty'
        }

        It 'Makes no HTTP request for zero quantity under WhatIf' {
            Set-SnipeitConsumable -id 1 -qty 0 -Session $script:testSession -WhatIf
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly -ModuleName SnipeitPS
        }
    }
}
