BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Reset-SnipeitAssetOwner' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Checks in asset by ID via POST /api/v1/hardware/{id}/checkin' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ Route = $Route; RouteTokens = $tokens; Method = $Method; Body = $Body; Session = $Session })
                return [pscustomobject]@{ status = 'success' }
            }

            Reset-SnipeitAssetOwner -id 42 -note 'Returned' -location_id 5 -status_id 1 -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/hardware/{id}/checkin'
            $call.RouteTokens.id | Should -Be 42
            $call.Method | Should -Be 'Post'
            $call.Body.note | Should -Be 'Returned'
            $call.Body.location_id | Should -Be 5
            $call.Body.status_id | Should -Be 1
            $call.Session | Should -Be $script:testSession
        }

        It 'Checks in asset by tag via POST /api/v1/hardware/bytag/{tag}/checkin' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ Route = $Route; RouteTokens = $tokens; Method = $Method; Body = $Body; Session = $Session })
                return [pscustomobject]@{ status = 'success' }
            }

            Reset-SnipeitAssetOwner -tag 'AST-0099' -clear_name -update_default_location -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/hardware/bytag/{tag}/checkin'
            $call.RouteTokens.tag | Should -Be 'AST-0099'
            $call.Method | Should -Be 'Post'
            $call.Body.clear_name | Should -Be 1
            $call.Body.update_default_location | Should -Be 1
        }

        It 'Checks in asset via quickscan body endpoint POST /api/v1/hardware/checkinbytag' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; Body = $Body; Session = $Session })
                return [pscustomobject]@{ status = 'success' }
            }

            Reset-SnipeitAssetOwner -checkin_key 'SRL-882200' -checkin_by_field 'serial' -checkin_at ([datetime]'2026-09-17') -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/hardware/checkinbytag'
            $call.Method | Should -Be 'Post'
            $call.Body.checkin_key | Should -Be 'SRL-882200'
            $call.Body.checkin_by_field | Should -Be 'serial'
            $call.Body.checkin_at | Should -Be '2026-09-17'
        }

        It 'Supports pipeline input for multiple IDs' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ id = $tokens.id })
                return [pscustomobject]@{ status = 'success' }
            }

            @(201, 202) | Reset-SnipeitAssetOwner -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 2
            $script:capturedCalls[0].id | Should -Be 201
            $script:capturedCalls[1].id | Should -Be 202
        }

        It 'Performs zero HTTP requests under -WhatIf' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw 'Should not be invoked under WhatIf'
            }

            Reset-SnipeitAssetOwner -id 42 -Session $script:testSession -WhatIf
            Reset-SnipeitAssetOwner -tag 'AST-42' -Session $script:testSession -WhatIf
            Reset-SnipeitAssetOwner -checkin_key 'AST-42' -Session $script:testSession -WhatIf
            Should -Invoke Invoke-SnipeitMethod -Times 0 -ModuleName SnipeitPS
        }
    }
}
