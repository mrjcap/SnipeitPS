BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'New-SnipeitAccountRequest' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Submits checkout request to /api/v1/account/request/{asset} with empty body' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ Route = $Route; RouteTokens = $tokens; Method = $Method; Body = $Body; Session = $Session })
                return [pscustomobject]@{ status = 'success'; messages = 'Asset requested' }
            }

            $res = New-SnipeitAccountRequest -asset_id 42 -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/account/request/{asset}'
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

            $res = @(10, 20 | New-SnipeitAccountRequest -Session $script:testSession -Confirm:$false)
            $script:capturedCalls.Count | Should -Be 2
            $script:capturedCalls[0].asset | Should -Be 10
            $script:capturedCalls[1].asset | Should -Be 20
        }

        It 'Performs zero HTTP requests under -WhatIf' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw 'Should not be invoked under WhatIf'
            }

            New-SnipeitAccountRequest -asset_id 42 -Session $script:testSession -WhatIf
            Should -Invoke Invoke-SnipeitMethod -Times 0 -ModuleName SnipeitPS
        }

        It 'Rejects non-positive asset_id' {
            { New-SnipeitAccountRequest -asset_id 0 -Session $script:testSession -Confirm:$false } | Should -Throw
            { New-SnipeitAccountRequest -asset_id -1 -Session $script:testSession -Confirm:$false } | Should -Throw
        }
    }
}
