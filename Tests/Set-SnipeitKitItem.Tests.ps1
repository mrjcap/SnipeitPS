BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Set-SnipeitKitItem' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Updates kit model quantity via PUT sending quantity only' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Body, $Session)
                $script:capturedCalls.Add(@{
                    Route   = $Route
                    Method  = $Method
                    Body    = $Body
                    Session = $Session
                })
                return [pscustomobject]@{ status = 'success'; messages = 'Model updated' }
            }

            $res = Set-SnipeitKitItem -kit_id 4 -ItemType 'Model' -child_id 9 -quantity 5 -Session $script:testSession
            $res.status | Should -Be 'success'
            $script:capturedCalls.Count | Should -Be 1
            $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/4/models/9'
            $script:capturedCalls[0].Method | Should -Be 'PUT'
            $script:capturedCalls[0].Body.quantity | Should -Be 5
            $script:capturedCalls[0].Body.Count | Should -Be 1
            $script:capturedCalls[0].Body.ContainsKey('model_id') | Should -BeFalse
            $script:capturedCalls[0].Body.ContainsKey('kit_id') | Should -BeFalse
        }

        It 'Updates kit license quantity via PUT' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Body)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; Body = $Body })
                return [pscustomobject]@{ status = 'success' }
            }

            $null = Set-SnipeitKitItem -kit_id 5 -ItemType 'License' -child_id 15 -quantity 10 -Session $script:testSession
            $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/5/licenses/15'
            $script:capturedCalls[0].Method | Should -Be 'PUT'
            $script:capturedCalls[0].Body.quantity | Should -Be 10
        }

        It 'Updates kit accessory quantity via PUT' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Body)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; Body = $Body })
                return [pscustomobject]@{ status = 'success' }
            }

            $null = Set-SnipeitKitItem -kit_id 6 -ItemType 'Accessory' -child_id 25 -quantity 4 -Session $script:testSession
            $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/6/accessories/25'
            $script:capturedCalls[0].Method | Should -Be 'PUT'
            $script:capturedCalls[0].Body.quantity | Should -Be 4
        }

        It 'Updates kit consumable quantity via PUT' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Body)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; Body = $Body })
                return [pscustomobject]@{ status = 'success' }
            }

            $null = Set-SnipeitKitItem -kit_id 7 -ItemType 'Consumable' -child_id 35 -quantity 8 -Session $script:testSession
            $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/7/consumables/35'
            $script:capturedCalls[0].Method | Should -Be 'PUT'
            $script:capturedCalls[0].Body.quantity | Should -Be 8
        }

        It 'Honors -WhatIf with zero HTTP requests' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw 'Should not be called when WhatIf is active'
            }

            Set-SnipeitKitItem -kit_id 4 -ItemType 'Model' -child_id 9 -quantity 3 -WhatIf
            $script:capturedCalls.Count | Should -Be 0
        }
    }
}
