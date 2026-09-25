BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Add-SnipeitKitItem' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Attaches Model using model key rather than model_id' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Body, $Session)
                $script:capturedCalls.Add(@{
                    Route   = $Route
                    Method  = $Method
                    Body    = $Body
                    Session = $Session
                })
                return [pscustomobject]@{ status = 'success'; messages = 'Model added' }
            }

            $res = Add-SnipeitKitItem -kit_id 4 -ItemType 'Model' -item_id 9 -quantity 2 -Session $script:testSession -Confirm:$false
            $res.status | Should -Be 'success'
            $script:capturedCalls.Count | Should -Be 1
            $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/4/models'
            $script:capturedCalls[0].Method | Should -Be 'POST'
            $script:capturedCalls[0].Body.model | Should -Be 9
            $script:capturedCalls[0].Body.quantity | Should -Be 2
            $script:capturedCalls[0].Body.ContainsKey('model_id') | Should -BeFalse
            $script:capturedCalls[0].Body.ContainsKey('kit_id') | Should -BeFalse
        }

        It 'Attaches License using license key with default quantity of 1' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Body)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; Body = $Body })
                return [pscustomobject]@{ status = 'success' }
            }

            $null = Add-SnipeitKitItem -kit_id 5 -ItemType 'License' -item_id 15 -Session $script:testSession -Confirm:$false
            $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/5/licenses'
            $script:capturedCalls[0].Body.license | Should -Be 15
            $script:capturedCalls[0].Body.quantity | Should -Be 1
        }

        It 'Attaches Accessory using accessory key' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Body)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; Body = $Body })
                return [pscustomobject]@{ status = 'success' }
            }

            $null = Add-SnipeitKitItem -kit_id 6 -ItemType 'Accessory' -item_id 25 -quantity 3 -Session $script:testSession -Confirm:$false
            $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/6/accessories'
            $script:capturedCalls[0].Body.accessory | Should -Be 25
            $script:capturedCalls[0].Body.quantity | Should -Be 3
        }

        It 'Attaches Consumable using consumable key' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Body)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; Body = $Body })
                return [pscustomobject]@{ status = 'success' }
            }

            $null = Add-SnipeitKitItem -kit_id 7 -ItemType 'Consumable' -item_id 35 -quantity 5 -Session $script:testSession -Confirm:$false
            $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/7/consumables'
            $script:capturedCalls[0].Body.consumable | Should -Be 35
            $script:capturedCalls[0].Body.quantity | Should -Be 5
        }

        It 'Honors -WhatIf with zero HTTP requests' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw 'Should not be called when WhatIf is active'
            }

            Add-SnipeitKitItem -kit_id 4 -ItemType 'Model' -item_id 9 -WhatIf
            $script:capturedCalls.Count | Should -Be 0
        }
    }
}
