BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Remove-SnipeitKitItem' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Detaches Model from kit via DELETE' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Session)
                $script:capturedCalls.Add(@{
                    Route   = $Route
                    Method  = $Method
                    Session = $Session
                })
                return [pscustomobject]@{ status = 'success'; messages = 'Model detached' }
            }

            $res = Remove-SnipeitKitItem -kit_id 4 -ItemType 'Model' -child_id 9 -Session $script:testSession -Confirm:$false
            $res.status | Should -Be 'success'
            $script:capturedCalls.Count | Should -Be 1
            $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/4/models/9'
            $script:capturedCalls[0].Method | Should -Be 'DELETE'
        }

        It 'Detaches License from kit via DELETE' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method })
                return [pscustomobject]@{ status = 'success' }
            }

            $null = Remove-SnipeitKitItem -kit_id 5 -ItemType 'License' -child_id 15 -Session $script:testSession -Confirm:$false
            $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/5/licenses/15'
            $script:capturedCalls[0].Method | Should -Be 'DELETE'
        }

        It 'Detaches Accessory from kit via DELETE' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method })
                return [pscustomobject]@{ status = 'success' }
            }

            $null = Remove-SnipeitKitItem -kit_id 6 -ItemType 'Accessory' -child_id 25 -Session $script:testSession -Confirm:$false
            $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/6/accessories/25'
            $script:capturedCalls[0].Method | Should -Be 'DELETE'
        }

        It 'Detaches Consumable from kit via DELETE' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method })
                return [pscustomobject]@{ status = 'success' }
            }

            $null = Remove-SnipeitKitItem -kit_id 7 -ItemType 'Consumable' -child_id 35 -Session $script:testSession -Confirm:$false
            $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/7/consumables/35'
            $script:capturedCalls[0].Method | Should -Be 'DELETE'
        }

        It 'Honors -WhatIf with zero HTTP requests' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw 'Should not be called when WhatIf is active'
            }

            Remove-SnipeitKitItem -kit_id 4 -ItemType 'Model' -child_id 9 -WhatIf
            $script:capturedCalls.Count | Should -Be 0
        }
    }
}
