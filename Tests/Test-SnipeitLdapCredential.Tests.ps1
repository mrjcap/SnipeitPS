BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Test-SnipeitLdapCredential' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Tests LDAP credential using PSCredential via POST /api/v1/settings/ldaptestlogin' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Body, $Session)
                $bodyCopy = if ($Body) { $Body.Clone() } else { $null }
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; Body = $bodyCopy; Session = $Session })
                return [pscustomobject]@{
                    message = 'It worked! jdoe successfully binded to LDAP.'
                }
            }

            $pass = ConvertTo-SecureString 'P@ssword1!' -AsPlainText -Force
            $cred = [System.Management.Automation.PSCredential]::new('jdoe', $pass)

            $res = Test-SnipeitLdapCredential -Credential $cred -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/settings/ldaptestlogin'
            $call.Method | Should -Be 'Post'
            $call.Body.ldaptest_user | Should -Be 'jdoe'
            $call.Body.ldaptest_password | Should -Be 'P@ssword1!'
            $call.Session | Should -Be $script:testSession
            $res.message | Should -Be 'It worked! jdoe successfully binded to LDAP.'
        }

        It 'Tests LDAP credential using explicit Username and Password' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Body, $Session)
                $bodyCopy = if ($Body) { $Body.Clone() } else { $null }
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; Body = $bodyCopy; Session = $Session })
                return [pscustomobject]@{
                    message = 'Login Failed. baduser did not successfully bind to LDAP.'
                }
            }

            $secPass = ConvertTo-SecureString 'WrongSecret' -AsPlainText -Force
            $res = Test-SnipeitLdapCredential -Username 'baduser' -Password $secPass -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/settings/ldaptestlogin'
            $call.Method | Should -Be 'Post'
            $call.Body.ldaptest_user | Should -Be 'baduser'
            $call.Body.ldaptest_password | Should -Be 'WrongSecret'
            $res.message | Should -Be 'Login Failed. baduser did not successfully bind to LDAP.'
        }

        It 'Redacts the LDAP password in dispatcher diagnostics without changing the request' {
            Mock Invoke-RestMethod -ModuleName SnipeitPS {
                param($Body)
                $script:capturedCalls.Add(([System.Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json))
                return [pscustomobject]@{ status = 'success'; payload = 'ok' }
            }
            $secret = 'LDAP-SECRET-SENTINEL'
            $pass = ConvertTo-SecureString $secret -AsPlainText -Force
            $cred = [System.Management.Automation.PSCredential]::new('jdoe', $pass)
            $DebugPreference = 'Continue'
            $records = @(Test-SnipeitLdapCredential -Credential $cred -Session $script:testSession `
                -Verbose -Confirm:$false *>&1)

            $script:capturedCalls.Count | Should -Be 1
            $script:capturedCalls[0].ldaptest_password | Should -Be $secret
            $diagnostics = ($records | Out-String)
            $diagnostics | Should -Match 'ldaptest_password'
            $diagnostics | Should -Match '\[REDACTED\]'
            $diagnostics | Should -Not -Match ([regex]::Escape($secret))
        }

        It 'Performs zero HTTP requests under -WhatIf' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw "HTTP method should not be invoked under WhatIf"
            }

            $pass = ConvertTo-SecureString 'AnyPass' -AsPlainText -Force
            $cred = [System.Management.Automation.PSCredential]::new('jdoe', $pass)
            { Test-SnipeitLdapCredential -Credential $cred -Session $script:testSession -WhatIf } | Should -Not -Throw
        }
    }
}
