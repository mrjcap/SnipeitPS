BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Kit CRUD Commands' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        Context 'Get-SnipeitKit' {
            It 'Gets all kits with query parameters and pagination' {
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
                        [pscustomobject]@{ id = 1; name = 'Dev Kit' },
                        [pscustomobject]@{ id = 2; name = 'Sales Kit' }
                    )
                }

                $res = @(Get-SnipeitKit -search 'kit' -sort 'name' -order 'desc' -offset 0 -limit 25 -All -Session $script:testSession)
                $res.Count | Should -Be 2
                $script:capturedCalls.Count | Should -Be 1
                $script:capturedCalls[0].Route | Should -Be '/api/v1/kits'
                $script:capturedCalls[0].Method | Should -Be 'GET'
                $script:capturedCalls[0].GetParameters.search | Should -Be 'kit'
                $script:capturedCalls[0].GetParameters.sort | Should -Be 'name'
                $script:capturedCalls[0].GetParameters.order | Should -Be 'desc'
                $script:capturedCalls[0].GetParameters.offset | Should -Be 0
                $script:capturedCalls[0].GetParameters.limit | Should -Be 25
                $script:capturedCalls[0].Paginate | Should -BeTrue
            }

            It 'Gets single kit by ID' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $Session)
                    $script:capturedCalls.Add(@{
                        Route   = $Route
                        Method  = $Method
                        Session = $Session
                    })
                    return [pscustomobject]@{ id = 42; name = 'Executive Kit' }
                }

                $res = Get-SnipeitKit -id 42 -Session $script:testSession
                $res.id | Should -Be 42
                $res.name | Should -Be 'Executive Kit'
                $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/42'
                $script:capturedCalls[0].Method | Should -Be 'GET'
            }
        }

        Context 'New-SnipeitKit' {
            It 'Creates a new kit with name' {
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
                        messages = 'Kit created successfully'
                        payload  = [pscustomobject]@{ id = 5; name = 'Design Kit' }
                    }
                }

                $res = New-SnipeitKit -name 'Design Kit' -Session $script:testSession
                $res.payload.id | Should -Be 5
                $script:capturedCalls.Count | Should -Be 1
                $script:capturedCalls[0].Route | Should -Be '/api/v1/kits'
                $script:capturedCalls[0].Method | Should -Be 'POST'
                $script:capturedCalls[0].Body.name | Should -Be 'Design Kit'
            }

            It 'Honors -WhatIf with zero HTTP requests' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    throw 'Should not be called when WhatIf is active'
                }

                New-SnipeitKit -name 'WhatIf Kit' -Session $script:testSession -WhatIf
                $script:capturedCalls.Count | Should -Be 0
            }
        }

        Context 'Set-SnipeitKit' {
            It 'Updates kit name via PUT' {
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
                        messages = 'Kit updated successfully'
                    }
                }

                $res = Set-SnipeitKit -id 5 -name 'Renamed Kit' -Session $script:testSession
                $res.status | Should -Be 'success'
                $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/5'
                $script:capturedCalls[0].Method | Should -Be 'PUT'
                $script:capturedCalls[0].Body.name | Should -Be 'Renamed Kit'
            }

            It 'Honors -WhatIf with zero HTTP requests' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    throw 'Should not be called when WhatIf is active'
                }

                Set-SnipeitKit -id 5 -name 'WhatIf Kit' -Session $script:testSession -WhatIf
                $script:capturedCalls.Count | Should -Be 0
            }
        }

        Context 'Remove-SnipeitKit' {
            It 'Deletes a kit via DELETE with high confirm impact' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $Session)
                    $script:capturedCalls.Add(@{
                        Route   = $Route
                        Method  = $Method
                        Session = $Session
                    })
                    return [pscustomobject]@{
                        status   = 'success'
                        messages = 'Kit deleted successfully'
                    }
                }

                $res = Remove-SnipeitKit -id 7 -Session $script:testSession -Confirm:$false
                $res.status | Should -Be 'success'
                $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/7'
                $script:capturedCalls[0].Method | Should -Be 'DELETE'
            }

            It 'Accepts pipeline IDs for deletion' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $Session)
                    $script:capturedCalls.Add(@{
                        Route   = $Route
                        Method  = $Method
                        Session = $Session
                    })
                    return [pscustomobject]@{ status = 'success' }
                }

                @(10, 20) | Remove-SnipeitKit -Session $script:testSession -Confirm:$false
                $script:capturedCalls.Count | Should -Be 2
                $script:capturedCalls[0].Route | Should -Be '/api/v1/kits/10'
                $script:capturedCalls[1].Route | Should -Be '/api/v1/kits/20'
            }

            It 'Honors -WhatIf with zero HTTP requests' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    throw 'Should not be called when WhatIf is active'
                }

                Remove-SnipeitKit -id 7 -Session $script:testSession -WhatIf
                $script:capturedCalls.Count | Should -Be 0
            }
        }
    }
}
