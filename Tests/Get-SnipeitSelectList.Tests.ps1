BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitSelectList' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        Context '13 EntityType Routes' {
            It 'Queries Accessory selectlist' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Session)
                    $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; GetParameters = $GetParameters })
                    return [pscustomobject]@{
                        results     = @([pscustomobject]@{ id = 1; text = 'USB Cable'; image = $null })
                        pagination  = [pscustomobject]@{ more = $false; per_page = 50 }
                        total_count = 1
                        page        = 1
                        page_count  = 1
                    }
                }

                $res = @(Get-SnipeitSelectList -EntityType Accessory -search 'Cable' -Session $script:testSession)
                $res.Count | Should -Be 1
                $res[0].id | Should -Be 1
                $res[0].text | Should -Be 'USB Cable'
                $script:capturedCalls[0].Route | Should -Be '/api/v1/accessories/selectlist'
                $script:capturedCalls[0].GetParameters.search | Should -Be 'Cable'
            }

            It 'Queries Category selectlist with required ItemType' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Session)
                    $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; GetParameters = $GetParameters })
                    return [pscustomobject]@{
                        results     = @([pscustomobject]@{ id = 2; text = 'Laptops' })
                        pagination  = [pscustomobject]@{ more = $false; per_page = 50 }
                        total_count = 1
                    }
                }

                $res = @(Get-SnipeitSelectList -EntityType Category -ItemType asset -Session $script:testSession)
                $res.Count | Should -Be 1
                $script:capturedCalls[0].Route | Should -Be '/api/v1/categories/asset/selectlist'
            }

            It 'Queries Company selectlist with excludeId and onlyTopLevel' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Session)
                    $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; GetParameters = $GetParameters })
                    return [pscustomobject]@{
                        results = @(
                            [pscustomobject]@{ id = 1; text = 'Parent Corp'; disabled = $false },
                            [pscustomobject]@{ id = 2; text = '  Child Sub'; disabled = $true }
                        )
                        pagination = [pscustomobject]@{ more = $false; per_page = 50 }
                        total_count = 2
                    }
                }

                $res = @(Get-SnipeitSelectList -EntityType Company -excludeId 5 -onlyTopLevel -Session $script:testSession)
                $res.Count | Should -Be 2
                $res[1].text | Should -Be '  Child Sub'
                $res[1].disabled | Should -BeTrue
                $script:capturedCalls[0].Route | Should -Be '/api/v1/companies/selectlist'
                $script:capturedCalls[0].GetParameters.excludeId | Should -Be 5
                $script:capturedCalls[0].GetParameters.onlyTopLevel | Should -Be 'true'
            }

            It 'Queries Department selectlist' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Session)
                    $script:capturedCalls.Add(@{ Route = $Route; Method = $Method })
                    return [pscustomobject]@{ results = @([pscustomobject]@{ id = 1; text = 'IT' }); pagination = [pscustomobject]@{ more = $false } }
                }

                $res = @(Get-SnipeitSelectList -EntityType Department -Session $script:testSession)
                $script:capturedCalls[0].Route | Should -Be '/api/v1/departments/selectlist'
            }

            It 'Queries Consumable selectlist' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Session)
                    $script:capturedCalls.Add(@{ Route = $Route; Method = $Method })
                    return [pscustomobject]@{ results = @([pscustomobject]@{ id = 1; text = 'Paper' }); pagination = [pscustomobject]@{ more = $false } }
                }

                $res = @(Get-SnipeitSelectList -EntityType Consumable -Session $script:testSession)
                $script:capturedCalls[0].Route | Should -Be '/api/v1/consumables/selectlist'
            }

            It 'Queries Asset (hardware) selectlist with companyId, excludeId, and statusType' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Session)
                    $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; GetParameters = $GetParameters })
                    return [pscustomobject]@{
                        results = @([pscustomobject]@{ id = 10; text = 'MacBook Pro 16 (TAG-10)' })
                        pagination = [pscustomobject]@{ more = $false }
                    }
                }

                $res = @(Get-SnipeitSelectList -EntityType Asset -companyId '1,2,3' -excludeId 4 -statusType RTD -Session $script:testSession)
                $script:capturedCalls[0].Route | Should -Be '/api/v1/hardware/selectlist'
                $script:capturedCalls[0].GetParameters.companyId | Should -Be '1,2,3'
                $script:capturedCalls[0].GetParameters.excludeId | Should -Be 4
                $script:capturedCalls[0].GetParameters.statusType | Should -Be 'RTD'
            }

            It 'Queries License selectlist' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Session)
                    $script:capturedCalls.Add(@{ Route = $Route; Method = $Method })
                    return [pscustomobject]@{ results = @([pscustomobject]@{ id = 1; text = 'Office 365' }); pagination = [pscustomobject]@{ more = $false } }
                }

                $res = @(Get-SnipeitSelectList -EntityType License -Session $script:testSession)
                $script:capturedCalls[0].Route | Should -Be '/api/v1/licenses/selectlist'
            }

            It 'Queries Location selectlist with companyId and excludeId' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Session)
                    $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; GetParameters = $GetParameters })
                    return [pscustomobject]@{ results = @([pscustomobject]@{ id = 1; text = 'Building A' }); pagination = [pscustomobject]@{ more = $false } }
                }

                $res = @(Get-SnipeitSelectList -EntityType Location -companyId '3' -excludeId 9 -Session $script:testSession)
                $script:capturedCalls[0].Route | Should -Be '/api/v1/locations/selectlist'
                $script:capturedCalls[0].GetParameters.companyId | Should -Be '3'
                $script:capturedCalls[0].GetParameters.excludeId | Should -Be 9
            }

            It 'Queries Manufacturer selectlist' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Session)
                    $script:capturedCalls.Add(@{ Route = $Route; Method = $Method })
                    return [pscustomobject]@{ results = @([pscustomobject]@{ id = 1; text = 'Apple' }); pagination = [pscustomobject]@{ more = $false } }
                }

                $res = @(Get-SnipeitSelectList -EntityType Manufacturer -Session $script:testSession)
                $script:capturedCalls[0].Route | Should -Be '/api/v1/manufacturers/selectlist'
            }

            It 'Queries Model selectlist' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Session)
                    $script:capturedCalls.Add(@{ Route = $Route; Method = $Method })
                    return [pscustomobject]@{ results = @([pscustomobject]@{ id = 1; text = 'MacBook Pro' }); pagination = [pscustomobject]@{ more = $false } }
                }

                $res = @(Get-SnipeitSelectList -EntityType Model -Session $script:testSession)
                $script:capturedCalls[0].Route | Should -Be '/api/v1/models/selectlist'
            }

            It 'Queries Status selectlist and serializes switches only when true' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Session)
                    $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; GetParameters = $GetParameters })
                    return [pscustomobject]@{ results = @([pscustomobject]@{ id = 1; text = 'Ready to Deploy' }); pagination = [pscustomobject]@{ more = $false } }
                }

                $res = @(Get-SnipeitSelectList -EntityType Status -deployable -Session $script:testSession)
                $script:capturedCalls[0].Route | Should -Be '/api/v1/statuslabels/selectlist'
                $script:capturedCalls[0].GetParameters.deployable | Should -Be '1'
                $script:capturedCalls[0].GetParameters.ContainsKey('pending') | Should -BeFalse
                $script:capturedCalls[0].GetParameters.ContainsKey('archived') | Should -BeFalse
            }

            It 'Queries Supplier selectlist' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Session)
                    $script:capturedCalls.Add(@{ Route = $Route; Method = $Method })
                    return [pscustomobject]@{ results = @([pscustomobject]@{ id = 1; text = 'CDW' }); pagination = [pscustomobject]@{ more = $false } }
                }

                $res = @(Get-SnipeitSelectList -EntityType Supplier -Session $script:testSession)
                $script:capturedCalls[0].Route | Should -Be '/api/v1/suppliers/selectlist'
            }

            It 'Queries User selectlist with companyId and excludeId' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Session)
                    $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; GetParameters = $GetParameters })
                    return [pscustomobject]@{ results = @([pscustomobject]@{ id = 1; text = 'Jane Doe (jdoe)' }); pagination = [pscustomobject]@{ more = $false } }
                }

                $res = @(Get-SnipeitSelectList -EntityType User -companyId '2,5' -excludeId 1 -Session $script:testSession)
                $script:capturedCalls[0].Route | Should -Be '/api/v1/users/selectlist'
                $script:capturedCalls[0].GetParameters.companyId | Should -Be '2,5'
                $script:capturedCalls[0].GetParameters.excludeId | Should -Be 1
            }
        }

        Context 'Validation and Edge Cases' {
            It 'Rejects invalid selectors for entity type' {
                { Get-SnipeitSelectList -EntityType Accessory -companyId '1' -Session $script:testSession } |
                    Should -Throw "*Parameter 'companyId' is not supported for EntityType 'Accessory'*"

                { Get-SnipeitSelectList -EntityType Asset -onlyTopLevel -Session $script:testSession } |
                    Should -Throw "*Parameter 'onlyTopLevel' is not supported for EntityType 'Asset'*"

                { Get-SnipeitSelectList -EntityType User -deployable -Session $script:testSession } |
                    Should -Throw "*Parameter 'deployable' is not supported for EntityType 'User'*"
            }

            It 'Paginates all pages when -All is specified' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Session)
                    $page = if ($GetParameters -and $GetParameters.page) { $GetParameters.page } else { 1 }
                    if ($page -eq 1) {
                        return [pscustomobject]@{
                            results = @([pscustomobject]@{ id = 1; text = 'Page 1 Item' })
                            pagination = [pscustomobject]@{ more = $true; per_page = 50 }
                            page = 1
                            page_count = 2
                        }
                    } else {
                        return [pscustomobject]@{
                            results = @([pscustomobject]@{ id = 2; text = 'Page 2 Item' })
                            pagination = [pscustomobject]@{ more = $false; per_page = 50 }
                            page = 2
                            page_count = 2
                        }
                    }
                }

                $allResults = @(Get-SnipeitSelectList -EntityType Accessory -All -Session $script:testSession)
                $allResults.Count | Should -Be 2
                $allResults[0].id | Should -Be 1
                $allResults[1].id | Should -Be 2
            }

            It 'Propagates API errors when All preserves the raw Select2 envelope' {
                Mock Invoke-RestMethod -ModuleName SnipeitPS {
                    [pscustomobject]@{ status = 'error'; messages = 'Selectlist denied'; payload = $null }
                }
                { Get-SnipeitSelectList -EntityType User -All -Session $script:testSession -ErrorAction Stop } |
                    Should -Throw -ExpectedMessage '*Selectlist denied*' -ErrorId 'SnipeitApiError*'
            }

            It 'Rejects empty results with more=true on the public All path' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    $script:capturedCalls.Add('request')
                    if ($script:capturedCalls.Count -gt 2) { throw 'Test request limit reached' }
                    [pscustomobject]@{ results = @(); pagination = @{ more = $true } }
                }
                { Get-SnipeitSelectList -EntityType User -All -Session $script:testSession } |
                    Should -Throw -ExpectedMessage '*contradictory*' -ErrorId 'SnipeitPaginationError*'
                $script:capturedCalls.Count | Should -Be 1
            }

            It 'Rejects <Kind> before emitting a duplicate page' -ForEach @(
                @{ Kind = 'nonadvancing page metadata'; FixedPage = $true }
                @{ Kind = 'repeated content without page metadata'; FixedPage = $false }
            ) {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    $script:capturedCalls.Add('request')
                    if ($script:capturedCalls.Count -gt 3) { throw 'Test request limit reached' }
                    $response = @{
                        results = @([pscustomobject]@{ id = 10; text = 'Repeated' })
                        pagination = @{ more = $true }
                        page_count = 3
                    }
                    if ($FixedPage) { $response.page = 1 }
                    $response
                }
                $items = [System.Collections.Generic.List[object]]::new()
                { Get-SnipeitSelectList -EntityType User -All -Session $script:testSession |
                    ForEach-Object { $items.Add($_) } } |
                    Should -Throw -ErrorId 'SnipeitPaginationError*'
                $script:capturedCalls.Count | Should -Be 2
                $items.Count | Should -Be 1
                $items[0].id | Should -Be 10
            }

            It 'Starts All from the requested page and preserves filters and session' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($GetParameters, $Session)
                    $script:capturedCalls.Add(@{ Query = $GetParameters.Clone(); Session = $Session })
                    [pscustomobject]@{
                        results = @([pscustomobject]@{ id = $GetParameters.page; text = 'Item' })
                        pagination = @{ more = $GetParameters.page -lt 3 }
                        page = $GetParameters.page
                    }
                }
                $items = @(Get-SnipeitSelectList -EntityType User -All -page 2 -search 'Jane' `
                    -companyId '1,2' -Session $script:testSession)
                $items.id | Should -Be @(2, 3)
                $script:capturedCalls.Count | Should -Be 2
                foreach ($call in $script:capturedCalls) {
                    $call.Query.search | Should -Be 'Jane'
                    $call.Query.companyId | Should -Be '1,2'
                    $call.Session | Should -Be $script:testSession
                }
            }

            It 'Preserves response envelope when -preserveResponse is specified' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $Method, $GetParameters, $Session)
                    return [pscustomobject]@{
                        results     = @([pscustomobject]@{ id = 1; text = 'Item 1' })
                        pagination  = [pscustomobject]@{ more = $false; per_page = 50 }
                        total_count = 42
                        page        = 1
                        page_count  = 1
                    }
                }

                $env = Get-SnipeitSelectList -EntityType Model -preserveResponse -Session $script:testSession
                $env.total_count | Should -Be 42
                $env.results.Count | Should -Be 1
            }
        }
    }
}
