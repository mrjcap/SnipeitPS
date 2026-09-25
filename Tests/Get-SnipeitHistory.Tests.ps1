BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitHistory' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        Context '9 History Entity Types' {
            It 'Queries Asset (hardware) history' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Session)
                    $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; GetParameters = $GetParameters })
                    return @(
                        [pscustomobject]@{
                            id          = 1
                            action_type = 'checkout'
                            note        = 'Issued to user'
                            created_at  = '2026-01-01'
                        }
                    )
                }

                $res = @(Get-SnipeitHistory -EntityType Asset -id 10 -Session $script:testSession)
                $res.Count | Should -Be 1
                $res[0].action_type | Should -Be 'checkout'
                $script:capturedCalls[0].Route | Should -Be '/api/v1/hardware/10/history'
                $script:capturedCalls[0].Method | Should -Be 'GET'
            }

            It 'Queries Accessory history' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Session)
                    $script:capturedCalls.Add(@{ Route = $Route })
                    return @([pscustomobject]@{ id = 2; action_type = 'checkin from' })
                }

                $res = @(Get-SnipeitHistory -EntityType Accessory -id 5 -Session $script:testSession)
                $script:capturedCalls[0].Route | Should -Be '/api/v1/accessories/5/history'
            }

            It 'Queries Component history' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method)
                    $script:capturedCalls.Add(@{ Route = $Route })
                    return @()
                }

                $res = @(Get-SnipeitHistory -EntityType Component -id 3 -Session $script:testSession)
                $script:capturedCalls[0].Route | Should -Be '/api/v1/components/3/history'
            }

            It 'Queries Consumable history' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method)
                    $script:capturedCalls.Add(@{ Route = $Route })
                    return @()
                }

                $res = @(Get-SnipeitHistory -EntityType Consumable -id 7 -Session $script:testSession)
                $script:capturedCalls[0].Route | Should -Be '/api/v1/consumables/7/history'
            }

            It 'Queries Maintenance history' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method)
                    $script:capturedCalls.Add(@{ Route = $Route })
                    return @()
                }

                $res = @(Get-SnipeitHistory -EntityType Maintenance -id 12 -Session $script:testSession)
                $script:capturedCalls[0].Route | Should -Be '/api/v1/maintenances/12/history'
            }

            It 'Queries License history' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method)
                    $script:capturedCalls.Add(@{ Route = $Route })
                    return @()
                }

                $res = @(Get-SnipeitHistory -EntityType License -id 8 -Session $script:testSession)
                $script:capturedCalls[0].Route | Should -Be '/api/v1/licenses/8/history'
            }

            It 'Queries Location history' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method)
                    $script:capturedCalls.Add(@{ Route = $Route })
                    return @()
                }

                $res = @(Get-SnipeitHistory -EntityType Location -id 4 -Session $script:testSession)
                $script:capturedCalls[0].Route | Should -Be '/api/v1/locations/4/history'
            }

            It 'Queries Model history' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method)
                    $script:capturedCalls.Add(@{ Route = $Route })
                    return @()
                }

                $res = @(Get-SnipeitHistory -EntityType Model -id 15 -Session $script:testSession)
                $script:capturedCalls[0].Route | Should -Be '/api/v1/models/15/history'
            }

            It 'Queries User history' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method)
                    $script:capturedCalls.Add(@{ Route = $Route })
                    return @()
                }

                $res = @(Get-SnipeitHistory -EntityType User -id 20 -Session $script:testSession)
                $script:capturedCalls[0].Route | Should -Be '/api/v1/users/20/history'
            }
        }

        Context 'Filters, uploads, and pagination' {
            It 'Passes search, action_type, created_by, and presence-style uploads' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Paginate, $Session)
                    $script:capturedCalls.Add(@{
                        Route         = $Route
                        Method        = $Method
                        GetParameters = $GetParameters
                        Paginate      = $Paginate
                    })
                    return @([pscustomobject]@{ id = 1; action_type = 'upload' })
                }

                $res = @(Get-SnipeitHistory -EntityType Asset -id 10 -search 'doc' -action_type 'uploaded' -created_by 2 -action_source 'api' -remote_ip '10.0.0.1' -uploads -sort 'created_at' -order 'desc' -offset 5 -limit 25 -All -Session $script:testSession)
                $script:capturedCalls[0].GetParameters.search | Should -Be 'doc'
                $script:capturedCalls[0].GetParameters.action_type | Should -Be 'uploaded'
                $script:capturedCalls[0].GetParameters.created_by | Should -Be 2
                $script:capturedCalls[0].GetParameters.action_source | Should -Be 'api'
                $script:capturedCalls[0].GetParameters.remote_ip | Should -Be '10.0.0.1'
                $script:capturedCalls[0].GetParameters.uploads | Should -Be '1'
                $script:capturedCalls[0].GetParameters.sort | Should -Be 'created_at'
                $script:capturedCalls[0].GetParameters.order | Should -Be 'desc'
                $script:capturedCalls[0].GetParameters.offset | Should -Be 5
                $script:capturedCalls[0].GetParameters.limit | Should -Be 25
                $script:capturedCalls[0].Paginate | Should -BeTrue
            }

            It 'Omits uploads filter when switch is not specified' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Session)
                    $script:capturedCalls.Add(@{ GetParameters = $GetParameters })
                    return @()
                }

                Get-SnipeitHistory -EntityType Asset -id 10 -Session $script:testSession
                ($null -eq $script:capturedCalls[0].GetParameters -or -not $script:capturedCalls[0].GetParameters.ContainsKey('uploads')) | Should -BeTrue
            }

            It 'Supports pipeline input for ID' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method)
                    $script:capturedCalls.Add(@{ Route = $Route })
                    return @()
                }

                @(11, 12) | Get-SnipeitHistory -EntityType User -Session $script:testSession
                $script:capturedCalls.Count | Should -Be 2
                $script:capturedCalls[0].Route | Should -Be '/api/v1/users/11/history'
                $script:capturedCalls[1].Route | Should -Be '/api/v1/users/12/history'
            }
        }
    }
}
