BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitKitItem' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Invokes GET /api/v1/kits/{kit_id}/licenses for License' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Session)
                $script:capturedCalls.Add(@{
                    Route   = $Route
                    Method  = $Method
                    Session = $Session
                })
                return @(
                    [pscustomobject]@{
                        id                = 10
                        pivot_id          = 101
                        owner_id          = 1
                        quantity          = 2
                        name              = 'Office 365'
                        available_actions = [pscustomobject]@{ update = $true; delete = $true }
                    }
                )
            }

            $res = @(Get-SnipeitKitItem -kit_id 1 -ItemType 'License' -Session $script:testSession)
            $res.Count | Should -Be 1
            $res[0].name | Should -Be 'Office 365'
            $res[0].pivot_id | Should -Be 101
            $res[0].owner_id | Should -Be 1
            $res[0].quantity | Should -Be 2
            $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/1/licenses'
            $script:capturedCalls[0].Method | Should -Be 'GET'
        }

        It 'Invokes GET /api/v1/kits/{kit_id}/models for Model' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method })
                return @([pscustomobject]@{ id = 20; name = 'MacBook Pro' })
            }

            $null = Get-SnipeitKitItem -kit_id 2 -ItemType 'Model' -Session $script:testSession
            $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/2/models'
            $script:capturedCalls[0].Method | Should -Be 'GET'
        }

        It 'Invokes GET /api/v1/kits/{kit_id}/accessories for Accessory' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method })
                return @([pscustomobject]@{ id = 30; name = 'Magic Mouse' })
            }

            $null = Get-SnipeitKitItem -kit_id 3 -ItemType 'Accessory' -Session $script:testSession
            $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/3/accessories'
            $script:capturedCalls[0].Method | Should -Be 'GET'
        }

        It 'Invokes GET /api/v1/kits/{kit_id}/consumables for Consumable' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method })
                return @([pscustomobject]@{ id = 40; name = 'Ethernet Cable' })
            }

            $null = Get-SnipeitKitItem -kit_id 4 -ItemType 'Consumable' -Session $script:testSession
            $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/4/consumables'
            $script:capturedCalls[0].Method | Should -Be 'GET'
        }

        It 'Accepts kit_id from pipeline by property name' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method })
                return @()
            }

            [pscustomobject]@{ kit_id = 9 } | Get-SnipeitKitItem -ItemType 'Model' -Session $script:testSession
            $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/9/models'
        }
    }
}
