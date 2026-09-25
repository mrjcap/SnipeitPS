BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'New-SnipeitAssetMaintenance' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()

            Mock Resolve-SnipeitMaintenanceTypeId -ModuleName SnipeitPS {
                param($Name, $Session)
                return 77
            }
        }

        Context 'Single Asset Maintenance Creation' {
            It 'Creates maintenance for a single asset with required and optional fields' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Api, $Method, $Body, $Session, $PreserveResponse)
                    $script:capturedCalls.Add(@{ Api = $Api; Method = $Method; Body = $Body; Session = $Session; PreserveResponse = $PreserveResponse })
                    return [pscustomobject]@{ id = 501; name = 'Repair fan'; asset_id = 1 }
                }

                $res = New-SnipeitAssetMaintenance `
                    -asset_id 1 `
                    -supplier_id 5 `
                    -asset_maintenance_type 'Hardware' `
                    -title 'Repair fan' `
                    -start_date ([datetime]'2026-04-01') `
                    -expected_completion_date ([datetime]'2026-04-05') `
                    -is_warranty $true `
                    -cost 120.50 `
                    -notes 'Replaced failing CPU fan' `
                    -responsible_party_id 12 `
                    -Session $script:testSession `
                    -Confirm:$false

                $res.id | Should -Be 501
                $script:capturedCalls.Count | Should -Be 1
                $call = $script:capturedCalls[0]
                $call.Api | Should -Be '/api/v1/maintenances'
                $call.Method | Should -Be 'Post'
                $call.Body.asset_id | Should -Be 1
                $call.Body.ContainsKey('asset_ids') | Should -BeFalse
                $call.Body.supplier_id | Should -Be 5
                $call.Body.maintenance_type_id | Should -Be 77
                $call.Body.name | Should -Be 'Repair fan'
                $call.Body.title | Should -Be 'Repair fan'
                $call.Body.start_date | Should -Be '2026-04-01'
                $call.Body.expected_completion_date | Should -Be '2026-04-05'
                $call.Body.is_warranty | Should -BeTrue
                $call.Body.cost | Should -Be 120.50
                $call.Body.notes | Should -Be 'Replaced failing CPU fan'
                $call.Body.responsible_party_id | Should -Be 12
                # Snapshot exclusion on create: checked_out_to fields must NOT be present
                $call.Body.ContainsKey('checked_out_to_id') | Should -BeFalse
                $call.Body.ContainsKey('checked_out_to_type') | Should -BeFalse
            }

            It 'Rebuilds request body per pipeline record' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Api, $Method, $Body)
                    $script:capturedCalls.Add(@{ Api = $Api; Method = $Method; Body = $Body })
                    return [pscustomobject]@{ id = $Body.asset_id + 1000 }
                }

                $res = @(10, 20 | New-SnipeitAssetMaintenance `
                    -supplier_id 5 `
                    -asset_maintenance_type 'Hardware' `
                    -title 'Batch check' `
                    -start_date ([datetime]'2026-04-01') `
                    -Session $script:testSession `
                    -Confirm:$false)

                $res.Count | Should -Be 2
                $script:capturedCalls.Count | Should -Be 2
                $script:capturedCalls[0].Body.asset_id | Should -Be 10
                $script:capturedCalls[1].Body.asset_id | Should -Be 20
            }
        }

        Context 'Bulk Asset Maintenance Creation' {
            It 'Sends array asset_ids to /maintenances (not a nonexistent bulk URL)' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Api, $Method, $Body, $Session, $PreserveResponse)
                    $script:capturedCalls.Add(@{ Api = $Api; Method = $Method; Body = $Body; PreserveResponse = $PreserveResponse })
                    return [pscustomobject]@{
                        total = 2
                        rows  = @(
                            [pscustomobject]@{ id = 201; asset_id = 1 },
                            [pscustomobject]@{ id = 202; asset_id = 2 }
                        )
                    }
                }

                $res = New-SnipeitAssetMaintenance `
                    -asset_ids 1, 2 `
                    -supplier_id 3 `
                    -asset_maintenance_type 'Calibration' `
                    -title 'Sensor calibration' `
                    -start_date ([datetime]'2026-05-01') `
                    -Session $script:testSession `
                    -Confirm:$false

                $script:capturedCalls.Count | Should -Be 1
                $call = $script:capturedCalls[0]
                $call.Api | Should -Be '/api/v1/maintenances'
                $call.Method | Should -Be 'Post'
                $call.Body.asset_ids | Should -Be @(1, 2)
                $call.Body.ContainsKey('asset_id') | Should -BeFalse
                $res.total | Should -Be 2
                $res.rows.Count | Should -Be 2
            }

            It 'Preserves partial success without fabricating failures for omitted rows' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Body)
                    # Server created only 1 out of 3 requested assets due to permissions on the other 2
                    return [pscustomobject]@{
                        total = 1
                        rows  = @(
                            [pscustomobject]@{ id = 301; asset_id = 1 }
                        )
                    }
                }

                $res = New-SnipeitAssetMaintenance `
                    -asset_ids 1, 2, 3 `
                    -supplier_id 3 `
                    -asset_maintenance_type 'Checkup' `
                    -title 'Routine check' `
                    -start_date ([datetime]'2026-05-01') `
                    -Session $script:testSession `
                    -Confirm:$false

                $res.total | Should -Be 1
                $res.rows.Count | Should -Be 1
                $res.rows[0].id | Should -Be 301
            }

            It 'Preserves complete response envelope when -preserveResponse is specified' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($PreserveResponse)
                    $script:capturedCalls.Add(@{ PreserveResponse = $PreserveResponse })
                    return [pscustomobject]@{
                        status   = 'success'
                        messages = 'Asset maintenance created successfully'
                        payload  = [pscustomobject]@{
                            total = 2
                            rows  = @([pscustomobject]@{ id = 401 }, [pscustomobject]@{ id = 402 })
                        }
                    }
                }

                $res = New-SnipeitAssetMaintenance `
                    -asset_ids 1, 2 `
                    -supplier_id 3 `
                    -asset_maintenance_type 'Checkup' `
                    -title 'Routine check' `
                    -start_date ([datetime]'2026-05-01') `
                    -preserveResponse `
                    -Session $script:testSession `
                    -Confirm:$false

                $script:capturedCalls[0].PreserveResponse | Should -BeTrue
                $res.status | Should -Be 'success'
                $res.payload.total | Should -Be 2
            }

            It 'Rejects empty or non-positive asset_ids before HTTP' {
                { New-SnipeitAssetMaintenance -asset_ids @() -supplier_id 1 -asset_maintenance_type 'Test' -title 'Test' -start_date (Get-Date) -Confirm:$false } | Should -Throw
                { New-SnipeitAssetMaintenance -asset_ids @(0) -supplier_id 1 -asset_maintenance_type 'Test' -title 'Test' -start_date (Get-Date) -Confirm:$false } | Should -Throw
                { New-SnipeitAssetMaintenance -asset_ids @(1, -2) -supplier_id 1 -asset_maintenance_type 'Test' -title 'Test' -start_date (Get-Date) -Confirm:$false } | Should -Throw
            }
        }

        Context 'Validation, WhatIf, and Legacy Guardrails' {
            It 'Rejects unsupported legacy assigned_to parameter before HTTP' {
                {
                    New-SnipeitAssetMaintenance `
                        -asset_id 1 `
                        -supplier_id 1 `
                        -asset_maintenance_type 'Hardware' `
                        -title 'Test' `
                        -start_date (Get-Date) `
                        -assigned_to 99 `
                        -Confirm:$false
                } | Should -Throw '*assigned_to is unsupported*'
            }

            It 'Performs zero HTTP requests and skips type resolution under -WhatIf' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    throw 'Should not execute under WhatIf'
                }

                New-SnipeitAssetMaintenance `
                    -asset_id 1 `
                    -supplier_id 1 `
                    -asset_maintenance_type 'Hardware' `
                    -title 'WhatIf test' `
                    -start_date ([datetime]'2026-06-01') `
                    -Session $script:testSession `
                    -WhatIf

                Should -Invoke Resolve-SnipeitMaintenanceTypeId -Times 0 -ModuleName SnipeitPS
                Should -Invoke Invoke-SnipeitMethod -Times 0 -ModuleName SnipeitPS
            }
        }
    }
}
