BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Depreciation CRUD Commands' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        Context 'Get-SnipeitDepreciation' {
            It 'Gets all depreciations with query parameters and pagination' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Paginate, $Session)
                    $script:capturedCalls.Add(@{
                        Route         = $Route
                        Method        = $Method
                        GetParameters = $GetParameters
                        Paginate      = $Paginate
                        Session       = $Session
                    })
                    return @(
                        [pscustomobject]@{
                            id               = 1
                            name             = 'Computer Equipment 36M'
                            months           = '36 months'
                            depreciation_min = '$0.00'
                            assets_count     = 10
                            models_count     = 3
                            licenses_count   = 0
                        },
                        [pscustomobject]@{
                            id               = 2
                            name             = 'Displays 24M'
                            months           = '24 months'
                            depreciation_min = '10%'
                            assets_count     = 5
                            models_count     = 2
                            licenses_count   = 0
                        }
                    )
                }

                $res = @(Get-SnipeitDepreciation -search 'Equipment' -filter 'Computer' -sort 'name' -order 'desc' -offset 10 -limit 50 -All -Session $script:testSession)
                $res.Count | Should -Be 2
                $script:capturedCalls.Count | Should -Be 1
                $script:capturedCalls[0].Route | Should -Be '/api/v1/depreciations'
                $script:capturedCalls[0].Method | Should -Be 'GET'
                $script:capturedCalls[0].GetParameters.search | Should -Be 'Equipment'
                $script:capturedCalls[0].GetParameters.filter | Should -Be 'Computer'
                $script:capturedCalls[0].GetParameters.sort | Should -Be 'name'
                $script:capturedCalls[0].GetParameters.order | Should -Be 'desc'
                $script:capturedCalls[0].GetParameters.offset | Should -Be 10
                $script:capturedCalls[0].GetParameters.limit | Should -Be 50
                $script:capturedCalls[0].Paginate | Should -BeTrue

                # Preserves human-formatted string months and counts without integer coercion
                $res[0].months | Should -Be '36 months'
                $res[0].assets_count | Should -Be 10
                $res[1].depreciation_min | Should -Be '10%'
            }

            It 'Gets single depreciation by ID' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $Session)
                    $script:capturedCalls.Add(@{
                        Route   = $Route
                        Method  = $Method
                        Session = $Session
                    })
                    return [pscustomobject]@{
                        id               = 5
                        name             = 'Phones 12M'
                        months           = '12 months'
                        depreciation_min = '0'
                    }
                }

                $res = Get-SnipeitDepreciation -id 5 -Session $script:testSession
                $res.id | Should -Be 5
                $res.name | Should -Be 'Phones 12M'
                $res.months | Should -Be '12 months'
                $script:capturedCalls[0].Route | Should -Be '/api/v1/depreciations/5'
                $script:capturedCalls[0].Method | Should -Be 'GET'
            }

            It 'Handles pipeline input for ID' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $Session)
                    $script:capturedCalls.Add(@{
                        Route   = $Route
                        Method  = $Method
                        Session = $Session
                    })
                    return [pscustomobject]@{ id = 7; name = 'Server 60M' }
                }

                $res = @(7 | Get-SnipeitDepreciation -Session $script:testSession)
                $res.Count | Should -Be 1
                $script:capturedCalls[0].Route | Should -Be '/api/v1/depreciations/7'
            }
        }

        Context 'New-SnipeitDepreciation' {
            It 'Creates a new depreciation schedule with name and months' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $Body, $Session)
                    $script:capturedCalls.Add(@{
                        Route   = $Route
                        Method  = $Method
                        Body    = $Body
                        Session = $Session
                    })
                    return [pscustomobject]@{
                        status   = 'success'
                        messages = 'Depreciation created successfully'
                        payload  = [pscustomobject]@{ id = 12; name = 'Laptops 36M'; months = 36 }
                    }
                }

                $res = New-SnipeitDepreciation -name 'Laptops 36M' -months 36 -Session $script:testSession
                $res.payload.id | Should -Be 12
                $script:capturedCalls.Count | Should -Be 1
                $script:capturedCalls[0].Route | Should -Be '/api/v1/depreciations'
                $script:capturedCalls[0].Method | Should -Be 'POST'
                $script:capturedCalls[0].Body.name | Should -Be 'Laptops 36M'
                $script:capturedCalls[0].Body.months | Should -Be 36
            }

            It 'Honors -WhatIf with zero HTTP requests' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    throw 'Should not be called when WhatIf is active'
                }

                New-SnipeitDepreciation -name 'WhatIf Dep' -months 24 -Session $script:testSession -WhatIf
                $script:capturedCalls.Count | Should -Be 0
            }
        }

        Context 'Set-SnipeitDepreciation' {
            It 'Updates depreciation name and months via PUT' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $Body, $Session)
                    $script:capturedCalls.Add(@{
                        Route   = $Route
                        Method  = $Method
                        Body    = $Body
                        Session = $Session
                    })
                    return [pscustomobject]@{
                        status   = 'success'
                        messages = 'Depreciation updated successfully'
                        payload  = [pscustomobject]@{ id = 12; name = 'Laptops 48M'; months = 48 }
                    }
                }

                $res = Set-SnipeitDepreciation -id 12 -name 'Laptops 48M' -months 48 -Session $script:testSession
                $res.payload.name | Should -Be 'Laptops 48M'
                $script:capturedCalls.Count | Should -Be 1
                $script:capturedCalls[0].Route | Should -Be '/api/v1/depreciations/12'
                $script:capturedCalls[0].Method | Should -Be 'PUT'
                $script:capturedCalls[0].Body.name | Should -Be 'Laptops 48M'
                $script:capturedCalls[0].Body.months | Should -Be 48
                # Never sends read-only fields
                $script:capturedCalls[0].Body.ContainsKey('depreciation_min') | Should -BeFalse
                $script:capturedCalls[0].Body.ContainsKey('depreciation_type') | Should -BeFalse
            }

            It 'Updates only bound name when months is omitted' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $Body, $Session)
                    $script:capturedCalls.Add(@{
                        Route   = $Route
                        Method  = $Method
                        Body    = $Body
                        Session = $Session
                    })
                    return [pscustomobject]@{ status = 'success'; payload = [pscustomobject]@{ id = 12 } }
                }

                Set-SnipeitDepreciation -id 12 -name 'New Name' -Session $script:testSession
                $script:capturedCalls[0].Body.name | Should -Be 'New Name'
                $script:capturedCalls[0].Body.ContainsKey('months') | Should -BeFalse
            }

            It 'Updates only bound months when name is omitted' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $Body, $Session)
                    $script:capturedCalls.Add(@{
                        Route   = $Route
                        Method  = $Method
                        Body    = $Body
                        Session = $Session
                    })
                    return [pscustomobject]@{ status = 'success'; payload = [pscustomobject]@{ id = 12 } }
                }

                Set-SnipeitDepreciation -id 12 -months 60 -Session $script:testSession
                $script:capturedCalls[0].Body.months | Should -Be 60
                $script:capturedCalls[0].Body.ContainsKey('name') | Should -BeFalse
            }

            It 'Throws terminating error when neither name nor months is provided' {
                { Set-SnipeitDepreciation -id 12 -Session $script:testSession } |
                    Should -Throw "*At least one property*"
            }

            It 'Honors -WhatIf with zero HTTP requests' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    throw 'Should not be called when WhatIf is active'
                }

                Set-SnipeitDepreciation -id 12 -name 'WhatIf' -Session $script:testSession -WhatIf
                $script:capturedCalls.Count | Should -Be 0
            }
        }

        Context 'Remove-SnipeitDepreciation' {
            It 'Deletes depreciation via DELETE' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $Session)
                    $script:capturedCalls.Add(@{
                        Route   = $Route
                        Method  = $Method
                        Session = $Session
                    })
                    return [pscustomobject]@{
                        status   = 'success'
                        messages = 'Depreciation deleted successfully'
                        payload  = $null
                    }
                }

                Remove-SnipeitDepreciation -id 9 -Session $script:testSession -Confirm:$false
                $script:capturedCalls.Count | Should -Be 1
                $script:capturedCalls[0].Route | Should -Be '/api/v1/depreciations/9'
                $script:capturedCalls[0].Method | Should -Be 'DELETE'
            }

            It 'Supports multiple pipeline IDs' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $Session)
                    $script:capturedCalls.Add(@{
                        Route   = $Route
                        Method  = $Method
                        Session = $Session
                    })
                }

                @(10, 11) | Remove-SnipeitDepreciation -Session $script:testSession -Confirm:$false
                $script:capturedCalls.Count | Should -Be 2
                $script:capturedCalls[0].Route | Should -Be '/api/v1/depreciations/10'
                $script:capturedCalls[1].Route | Should -Be '/api/v1/depreciations/11'
            }

            It 'Honors -WhatIf with zero HTTP requests' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    throw 'Should not be called when WhatIf is active'
                }

                Remove-SnipeitDepreciation -id 9 -Session $script:testSession -WhatIf
                $script:capturedCalls.Count | Should -Be 0
            }
        }
    }
}
