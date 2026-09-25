BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Accessory checkout quantity contract' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:checkoutSession = [SnipeitSession]::new('https://contract.invalid', $key)
            $script:checkoutSession.ThrottleLimit = 0
            $script:checkoutCalls = [System.Collections.Generic.List[object]]::new()
            Mock Invoke-RestMethod -ModuleName SnipeitPS {
                param($Body, $Uri)
                $script:checkoutCalls.Add(@{
                    Json = [Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json
                    Uri = $Uri
                })
                [pscustomobject]@{ status = 'success'; payload = @{ id = 1 } }
            }
        }

        It 'Sends quantity for <Target> checkouts across array IDs' -ForEach @(
            @{ Target = 'user'; Field = 'assigned_user' }
            @{ Target = 'asset'; Field = 'assigned_asset' }
            @{ Target = 'location'; Field = 'assigned_location' }
        ) {
            Set-SnipeitAccessoryOwner -id 4, 5 -assigned_to 12 -checkout_to_type $Target -checkout_qty 3 -Session $script:checkoutSession -Confirm:$false
            $script:checkoutCalls.Count | Should -Be 2
            $script:checkoutCalls[0].Uri | Should -BeExactly 'https://contract.invalid/api/v1/accessories/4/checkout'
            $script:checkoutCalls[1].Uri | Should -BeExactly 'https://contract.invalid/api/v1/accessories/5/checkout'
            foreach ($call in $script:checkoutCalls) {
                $call.Json.checkout_qty | Should -Be 3
                ($call.Json.checkout_qty -is [int] -or $call.Json.checkout_qty -is [long]) | Should -BeTrue
                $call.Json.$Field | Should -Be 12
                $call.Json.PSObject.Properties.Name | Should -Not -Contain 'assigned_to'
            }
        }

        It 'Leaves quantity unset when omitted so the server default applies' {
            Set-SnipeitAccessoryOwner -id 4 -assigned_to 12 -Session $script:checkoutSession -Confirm:$false
            $script:checkoutCalls.Count | Should -Be 1
            $script:checkoutCalls[0].Json.PSObject.Properties.Name | Should -Not -Contain 'checkout_qty'
        }

        It 'Rejects nonpositive quantity <Quantity> before HTTP' -ForEach @(
            @{ Quantity = 0 }
            @{ Quantity = -1 }
        ) {
            { Set-SnipeitAccessoryOwner -id 4 -assigned_to 12 -checkout_qty $Quantity -Session $script:checkoutSession -Confirm:$false } | Should -Throw
            $script:checkoutCalls.Count | Should -Be 0
        }

        It 'Does not make HTTP calls under WhatIf' {
            Set-SnipeitAccessoryOwner -id 4 -assigned_to 12 -checkout_qty 3 -Session $script:checkoutSession -WhatIf
            $script:checkoutCalls.Count | Should -Be 0
        }
    }
}
