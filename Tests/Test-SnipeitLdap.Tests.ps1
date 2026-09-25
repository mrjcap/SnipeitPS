BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Test-SnipeitLdap' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Calls GET /api/v1/settings/ldaptest' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Session)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; Session = $Session })
                return [pscustomobject]@{
                    bind      = [pscustomobject]@{ message = 'Successfully bound to LDAP server.' }
                    login     = [pscustomobject]@{ message = 'Successfully connected to LDAP server.' }
                    user_sync = [pscustomobject]@{ users = @([pscustomobject]@{ username = 'jdoe' }) }
                }
            }

            $res = Test-SnipeitLdap -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/settings/ldaptest'
            $call.Method | Should -Be 'Get'
            $call.Session | Should -Be $script:testSession
            $res.bind.message | Should -Be 'Successfully bound to LDAP server.'
            $res.user_sync.users[0].username | Should -Be 'jdoe'
        }

        It 'Performs zero HTTP requests under -WhatIf' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw "HTTP method should not be invoked under WhatIf"
            }

            { Test-SnipeitLdap -Session $script:testSession -WhatIf } | Should -Not -Throw
        }
    }
}
