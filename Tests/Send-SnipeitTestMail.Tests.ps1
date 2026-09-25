BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Send-SnipeitTestMail' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Calls POST /api/v1/settings/mailtest' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Body, $Session)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; Body = $Body; Session = $Session })
                return [pscustomobject]@{
                    message = 'Mail sent to admin@example.com'
                }
            }

            $res = Send-SnipeitTestMail -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/settings/mailtest'
            $call.Method | Should -Be 'Post'
            $call.Session | Should -Be $script:testSession
            $res.message | Should -Be 'Mail sent to admin@example.com'
        }

        It 'Performs zero HTTP requests under -WhatIf' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw "HTTP method should not be invoked under WhatIf"
            }

            { Send-SnipeitTestMail -Session $script:testSession -WhatIf } | Should -Not -Throw
        }
    }
}
