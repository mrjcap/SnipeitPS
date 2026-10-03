BeforeDiscovery { Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force }
Describe 'Current model requestability and default purchase costs' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = [Security.SecureString]::new()
            foreach ($character in 'offline'.ToCharArray()) { $key.AppendChar($character) }
            $key.MakeReadOnly()
            $script:modelFieldSession = [SnipeitSession]::new('https://model-fields.invalid', $key)
            $script:modelFieldCalls = [Collections.Generic.List[object]]::new()
            Mock Invoke-RestMethod {
                param($Uri, $Method, $Body)
                $script:modelFieldCalls.Add(@{
                    Uri = ([uri]$Uri).AbsoluteUri
                    Method = [string]$Method
                    Json = [Text.Encoding]::UTF8.GetString($Body)
                })
                [pscustomobject]@{status='success';payload=[pscustomobject]@{id=7;name='Fixture'}}
            }
        }
        It 'preserves true, false, null, and omission for <Command> requestable' -ForEach @(
            @{Command='New-SnipeitComponent';Extra=@{name='Fixture';category_id=3;qty=0};Leaf='components';Method='POST'},
            @{Command='Set-SnipeitComponent';Extra=@{id=7};Leaf='components/7';Method='PATCH'},
            @{Command='New-SnipeitLicense';Extra=@{name='Fixture';seats=1;category_id=3};Leaf='licenses';Method='POST'},
            @{Command='Set-SnipeitLicense';Extra=@{id=7};Leaf='licenses/7';Method='PATCH'}
        ) {
            foreach ($value in @($true, $false, $null)) {
                & $Command @Extra -requestable $value -Session $script:modelFieldSession -Confirm:$false | Out-Null
                $call = $script:modelFieldCalls[$script:modelFieldCalls.Count - 1]
                $call.Uri | Should -Be "https://model-fields.invalid/api/v1/$Leaf"
                $call.Method | Should -Be $Method
                $body = $call.Json | ConvertFrom-Json
                $body.PSObject.Properties.Name | Should -Contain 'requestable'
                if ($null -eq $value) { $body.requestable | Should -BeNullOrEmpty }
                else {
                    $body.requestable | Should -BeOfType ([bool])
                    $body.requestable | Should -Be $value
                }
                $body.PSObject.Properties.Name | Should -Not -Contain 'Session'
            }
            & $Command @Extra -Session $script:modelFieldSession -Confirm:$false | Out-Null
            $body = $script:modelFieldCalls[3].Json | ConvertFrom-Json
            $body.PSObject.Properties.Name | Should -Not -Contain 'requestable'
        }
        It 'preserves default-cost values independently of acquisition cost for <Command>' -ForEach @(
            @{Command='New-SnipeitAccessory';Extra=@{name='Fixture';category_id=3;qty=0;purchase_cost='9.50'};Leaf='accessories';Method='POST'},
            @{Command='Set-SnipeitAccessory';Extra=@{id=7;unit_cost=9.50d};Leaf='accessories/7';Method='PATCH'},
            @{Command='New-SnipeitComponent';Extra=@{name='Fixture';category_id=3;qty=0;purchase_cost='9.50'};Leaf='components';Method='POST'},
            @{Command='Set-SnipeitComponent';Extra=@{id=7;unit_cost=9.50d};Leaf='components/7';Method='PATCH'},
            @{Command='New-SnipeitConsumable';Extra=@{name='Fixture';category_id=3;qty=0;purchase_cost='9.50'};Leaf='consumables';Method='POST'},
            @{Command='Set-SnipeitConsumable';Extra=@{id=7;unit_cost=9.50d};Leaf='consumables/7';Method='PATCH'}
        ) {
            foreach ($value in @(0d, 12.3456d, $null, 99999999999999999.99d)) {
                & $Command @Extra -default_purchase_cost $value -Session $script:modelFieldSession -Confirm:$false | Out-Null
                $call = $script:modelFieldCalls[$script:modelFieldCalls.Count - 1]
                $call.Uri | Should -Be "https://model-fields.invalid/api/v1/$Leaf"
                $call.Method | Should -Be $Method
                $body = $call.Json | ConvertFrom-Json
                $body.PSObject.Properties.Name | Should -Contain 'default_purchase_cost'
                if ($null -eq $value) { $body.default_purchase_cost | Should -BeNullOrEmpty }
                elseif ($value -eq 99999999999999999.99d) {
                    $call.Json | Should -Match '"default_purchase_cost":99999999999999999\.99'
                }
                else { $body.default_purchase_cost | Should -Be $value }
                $acquisitionField = if ($Method -eq 'POST') { 'purchase_cost' } else { 'unit_cost' }
                $body.$acquisitionField | Should -Be $Extra[$acquisitionField]
                $body.PSObject.Properties.Name | Should -Not -Contain 'Session'
            }
            & $Command @Extra -Session $script:modelFieldSession -Confirm:$false | Out-Null
            $body = $script:modelFieldCalls[4].Json | ConvertFrom-Json
            $body.PSObject.Properties.Name | Should -Not -Contain 'default_purchase_cost'
        }
        It 'rejects default costs outside the server range before HTTP for <Command>' -ForEach @(
            @{Command='New-SnipeitAccessory';Extra=@{name='Fixture';category_id=3;qty=0}},
            @{Command='Set-SnipeitAccessory';Extra=@{id=7}},
            @{Command='New-SnipeitComponent';Extra=@{name='Fixture';category_id=3;qty=0}},
            @{Command='Set-SnipeitComponent';Extra=@{id=7}},
            @{Command='New-SnipeitConsumable';Extra=@{name='Fixture';category_id=3;qty=0}},
            @{Command='Set-SnipeitConsumable';Extra=@{id=7}}
        ) {
            { & $Command @Extra -default_purchase_cost -0.01d -Session $script:modelFieldSession -Confirm:$false } | Should -Throw
            { & $Command @Extra -default_purchase_cost 100000000000000000d -Session $script:modelFieldSession -Confirm:$false } | Should -Throw
            $script:modelFieldCalls.Count | Should -Be 0
        }
        It 'suppresses model-field writes with WhatIf for <Command>' -ForEach @(
            @{Command='New-SnipeitComponent';Extra=@{name='Fixture';category_id=3;qty=0;requestable=$false;default_purchase_cost=0d}},
            @{Command='Set-SnipeitComponent';Extra=@{id=7;requestable=$false;default_purchase_cost=0d}},
            @{Command='New-SnipeitLicense';Extra=@{name='Fixture';seats=1;category_id=3;requestable=$false}},
            @{Command='Set-SnipeitLicense';Extra=@{id=7;requestable=$false}},
            @{Command='New-SnipeitAccessory';Extra=@{name='Fixture';category_id=3;qty=0;default_purchase_cost=0d}},
            @{Command='Set-SnipeitAccessory';Extra=@{id=7;default_purchase_cost=0d}},
            @{Command='New-SnipeitConsumable';Extra=@{name='Fixture';category_id=3;qty=0;default_purchase_cost=0d}},
            @{Command='Set-SnipeitConsumable';Extra=@{id=7;default_purchase_cost=0d}}
        ) {
            & $Command @Extra -Session $script:modelFieldSession -WhatIf
            $script:modelFieldCalls.Count | Should -Be 0
        }
    }
}
