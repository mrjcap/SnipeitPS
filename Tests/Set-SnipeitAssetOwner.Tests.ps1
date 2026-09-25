BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Set-SnipeitAssetOwner' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Checks out asset by ID via POST /api/v1/hardware/{id}/checkout' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ Route = $Route; RouteTokens = $tokens; Method = $Method; Body = $Body; Session = $Session })
                return [pscustomobject]@{ status = 'success' }
            }

            Set-SnipeitAssetOwner -id 42 -assigned_id 7 -checkout_to_type user -note 'Assigned laptop' -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/hardware/{id}/checkout'
            $call.RouteTokens.id | Should -Be 42
            $call.Method | Should -Be 'Post'
            $call.Body.assigned_user | Should -Be 7
            $call.Body.checkout_to_type | Should -Be 'user'
            $call.Body.note | Should -Be 'Assigned laptop'
            $call.Session | Should -Be $script:testSession
        }

        It 'Checks out asset by tag via POST /api/v1/hardware/bytag/{tag}/checkout' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ Route = $Route; RouteTokens = $tokens; Method = $Method; Body = $Body; Session = $Session })
                return [pscustomobject]@{ status = 'success' }
            }

            Set-SnipeitAssetOwner -tag 'TAG-4200' -assigned_id 15 -checkout_to_type location -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/hardware/bytag/{tag}/checkout'
            $call.RouteTokens.tag | Should -Be 'TAG-4200'
            $call.Method | Should -Be 'Post'
            $call.Body.assigned_location | Should -Be 15
            $call.Body.checkout_to_type | Should -Be 'location'
        }

        It 'Checks out asset to target asset type' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $script:capturedCalls.Add(@{ Body = $Body })
                return [pscustomobject]@{ status = 'success' }
            }

            Set-SnipeitAssetOwner -id 10 -assigned_id 20 -checkout_to_type asset -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $script:capturedCalls[0].Body.assigned_asset | Should -Be 20
            $script:capturedCalls[0].Body.checkout_to_type | Should -Be 'asset'
        }

        It 'Serializes optional dates, status_id, and name' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $script:capturedCalls.Add(@{ Body = $Body })
                return [pscustomobject]@{ status = 'success' }
            }

            Set-SnipeitAssetOwner -id 5 -assigned_id 1 -name "Alice's PC" -status_id 3 `
                -expected_checkin ([datetime]'2026-10-01') -checkout_at ([datetime]'2026-09-17') `
                -Session $script:testSession -Confirm:$false

            $script:capturedCalls.Count | Should -Be 1
            $b = $script:capturedCalls[0].Body
            $b.name | Should -Be "Alice's PC"
            $b.status_id | Should -Be 3
            $b.expected_checkin | Should -Be '2026-10-01'
            $b.checkout_at | Should -Be '2026-09-17'
        }

        It 'Supports pipeline input for multiple IDs' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ id = $tokens.id })
                return [pscustomobject]@{ status = 'success' }
            }

            @(101, 102) | Set-SnipeitAssetOwner -assigned_id 9 -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 2
            $script:capturedCalls[0].id | Should -Be 101
            $script:capturedCalls[1].id | Should -Be 102
        }

        It 'Performs zero HTTP requests under -WhatIf' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw 'Should not be invoked under WhatIf'
            }

            Set-SnipeitAssetOwner -id 42 -assigned_id 7 -Session $script:testSession -WhatIf
            Set-SnipeitAssetOwner -tag 'TAG-42' -assigned_id 7 -Session $script:testSession -WhatIf
            Should -Invoke Invoke-SnipeitMethod -Times 0 -ModuleName SnipeitPS
        }
    }
}
