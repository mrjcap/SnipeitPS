BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Send-SnipeitUserInventory' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Calls POST /api/v1/users/{id}/email' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ Route = $Route; RouteTokens = $tokens; Method = $Method; Body = $Body; Session = $Session })
                return [pscustomobject]@{
                    status   = 'success'
                    messages = 'User inventory list emailed.'
                }
            }

            $res = Send-SnipeitUserInventory -id 42 -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/users/{id}/email'
            $call.RouteTokens.id | Should -Be 42
            $call.Method | Should -Be 'Post'
            $call.Session | Should -Be $script:testSession
            $res.messages | Should -Be 'User inventory list emailed.'
        }

        It 'Supports pipeline input for multiple user IDs' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ RouteTokens = $tokens })
                return [pscustomobject]@{ status = 'success' }
            }

            10, 20, 30 | Send-SnipeitUserInventory -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 3
            $script:capturedCalls[0].RouteTokens.id | Should -Be 10
            $script:capturedCalls[1].RouteTokens.id | Should -Be 20
            $script:capturedCalls[2].RouteTokens.id | Should -Be 30
        }

        It 'Performs zero HTTP requests under -WhatIf' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw "HTTP method should not be invoked under WhatIf"
            }

            { 42 | Send-SnipeitUserInventory -Session $script:testSession -WhatIf } | Should -Not -Throw
        }
    }
}
