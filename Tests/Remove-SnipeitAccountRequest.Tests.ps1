BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Remove-SnipeitAccountRequest' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Cancels checkout request via POST /api/v1/account/request/{asset}/cancel with empty body' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ Route = $Route; RouteTokens = $tokens; Method = $Method; Body = $Body; Session = $Session })
                return [pscustomobject]@{ status = 'success'; messages = 'Request canceled' }
            }

            $res = Remove-SnipeitAccountRequest -asset_id 42 -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/account/request/{asset}/cancel'
            $call.RouteTokens.asset | Should -Be 42
            $call.Method | Should -Be 'Post'
            $call.Body.Keys.Count | Should -Be 0
            $call.Session | Should -Be $script:testSession
        }

        It 'Supports pipeline input for asset_id' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ asset = $tokens.asset })
                return [pscustomobject]@{ status = 'success' }
            }

            $res = @(50, 60 | Remove-SnipeitAccountRequest -Session $script:testSession -Confirm:$false)
            $script:capturedCalls.Count | Should -Be 2
            $script:capturedCalls[0].asset | Should -Be 50
            $script:capturedCalls[1].asset | Should -Be 60
        }

        It 'Performs zero HTTP requests under -WhatIf' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw 'Should not be invoked under WhatIf'
            }

            Remove-SnipeitAccountRequest -asset_id 42 -Session $script:testSession -WhatIf
            Should -Invoke Invoke-SnipeitMethod -Times 0 -ModuleName SnipeitPS
        }

        It 'Rejects non-positive asset_id' {
            { Remove-SnipeitAccountRequest -asset_id 0 -Session $script:testSession -Confirm:$false } | Should -Throw
            { Remove-SnipeitAccountRequest -asset_id -5 -Session $script:testSession -Confirm:$false } | Should -Throw
        }
    }
}
