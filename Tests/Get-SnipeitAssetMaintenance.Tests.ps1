BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitAssetMaintenance' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        Context 'ById Parameter Set' {
            It 'Queries a single maintenance record by ID' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $Session)
                    $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; Session = $Session })
                    return [pscustomobject]@{ id = 42; title = 'Screen replacement' }
                }

                $res = Get-SnipeitAssetMaintenance -id 42 -Session $script:testSession
                $res.id | Should -Be 42
                $script:capturedCalls.Count | Should -Be 1
                $script:capturedCalls[0].Route | Should -Be '/api/v1/maintenances/42'
                $script:capturedCalls[0].Method | Should -Be 'Get'
                $script:capturedCalls[0].Session | Should -Be $script:testSession
            }

            It 'Supports pipeline input for ID' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method)
                    $script:capturedCalls.Add(@{ Route = $Route; Method = $Method })
                    return [pscustomobject]@{ id = [int]($Route -replace '.*/', '') }
                }

                $res = @(101, 102 | Get-SnipeitAssetMaintenance -Session $script:testSession)
                $res.Count | Should -Be 2
                $script:capturedCalls.Count | Should -Be 2
                $script:capturedCalls[0].Route | Should -Be '/api/v1/maintenances/101'
                $script:capturedCalls[1].Route | Should -Be '/api/v1/maintenances/102'
            }

            It 'Rejects non-positive ID' {
                { Get-SnipeitAssetMaintenance -id 0 -Session $script:testSession } | Should -Throw
                { Get-SnipeitAssetMaintenance -id -5 -Session $script:testSession } | Should -Throw
            }
        }

        Context 'ByFilter Parameter Set - Query and Filtering' {
            It 'Gives filter precedence over search when both are provided' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters)
                    $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; GetParameters = $GetParameters })
                    return @([pscustomobject]@{ id = 1 })
                }

                $res = @(Get-SnipeitAssetMaintenance -filter 'high-priority' -search 'ignored-search' -Session $script:testSession)
                $script:capturedCalls[0].GetParameters.filter | Should -Be 'high-priority'
                $script:capturedCalls[0].GetParameters.ContainsKey('search') | Should -BeFalse
            }

            It 'Passes search when filter is not provided' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters)
                    $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; GetParameters = $GetParameters })
                    return @([pscustomobject]@{ id = 1 })
                }

                $res = @(Get-SnipeitAssetMaintenance -search 'battery' -Session $script:testSession)
                $script:capturedCalls[0].GetParameters.search | Should -Be 'battery'
            }

            It 'Serializes completed as lowercase true when true' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($GetParameters)
                    $script:capturedCalls.Add(@{ GetParameters = $GetParameters })
                    return @()
                }

                $null = Get-SnipeitAssetMaintenance -completed $true -Session $script:testSession
                $script:capturedCalls[0].GetParameters.completed | Should -Be 'true'
            }

            It 'Serializes completed as lowercase false when false (does not omit bound false)' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($GetParameters)
                    $script:capturedCalls.Add(@{ GetParameters = $GetParameters })
                    return @()
                }

                $null = Get-SnipeitAssetMaintenance -completed $false -Session $script:testSession
                $script:capturedCalls[0].GetParameters.completed | Should -Be 'false'
            }

            It 'Omits completed query parameter when not specified' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($GetParameters)
                    $script:capturedCalls.Add(@{ GetParameters = $GetParameters })
                    return @()
                }

                $null = Get-SnipeitAssetMaintenance -search 'test' -Session $script:testSession
                $script:capturedCalls[0].GetParameters.ContainsKey('completed') | Should -BeFalse
            }

            It 'Passes upcoming_status valid options' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($GetParameters)
                    $script:capturedCalls.Add(@{ GetParameters = $GetParameters })
                    return @()
                }

                $null = Get-SnipeitAssetMaintenance -upcoming_status 'due' -Session $script:testSession
                $null = Get-SnipeitAssetMaintenance -upcoming_status 'overdue' -Session $script:testSession
                $null = Get-SnipeitAssetMaintenance -upcoming_status 'due-or-overdue' -Session $script:testSession

                $script:capturedCalls[0].GetParameters.upcoming_status | Should -Be 'due'
                $script:capturedCalls[1].GetParameters.upcoming_status | Should -Be 'overdue'
                $script:capturedCalls[2].GetParameters.upcoming_status | Should -Be 'due-or-overdue'
            }

            It 'Passes polymorphic checked_out_to parameters' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($GetParameters)
                    $script:capturedCalls.Add(@{ GetParameters = $GetParameters })
                    return @()
                }

                $null = Get-SnipeitAssetMaintenance -checked_out_to_id 99 -checked_out_to_type 'App\Models\User' -Session $script:testSession
                $script:capturedCalls[0].GetParameters.checked_out_to_id | Should -Be 99
                $script:capturedCalls[0].GetParameters.checked_out_to_type | Should -Be 'App\Models\User'
            }

            It 'Passes all filter attributes and pagination settings' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Paginate)
                    $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; GetParameters = $GetParameters; Paginate = $Paginate })
                    return @()
                }

                $null = Get-SnipeitAssetMaintenance `
                    -asset_id 10 `
                    -supplier_id 20 `
                    -created_by 30 `
                    -url 'https://repair.example.com' `
                    -maintenance_type 'Hardware' `
                    -maintenance_type_id 4 `
                    -responsible_party_id 50 `
                    -sort 'cost' `
                    -order 'asc' `
                    -limit 25 `
                    -offset 75 `
                    -all `
                    -Session $script:testSession

                $call = $script:capturedCalls[0]
                $call.Route | Should -Be '/api/v1/maintenances'
                $call.Method | Should -Be 'Get'
                $call.Paginate | Should -BeTrue
                $call.GetParameters.asset_id | Should -Be 10
                $call.GetParameters.supplier_id | Should -Be 20
                $call.GetParameters.created_by | Should -Be 30
                $call.GetParameters.url | Should -Be 'https://repair.example.com'
                $call.GetParameters.maintenance_type | Should -Be 'Hardware'
                $call.GetParameters.maintenance_type_id | Should -Be 4
                $call.GetParameters.responsible_party_id | Should -Be 50
                $call.GetParameters.sort | Should -Be 'cost'
                $call.GetParameters.order | Should -Be 'asc'
                $call.GetParameters.limit | Should -Be 25
                $call.GetParameters.offset | Should -Be 75
            }
        }
    }
}
