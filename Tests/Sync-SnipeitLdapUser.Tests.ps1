BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Sync-SnipeitLdapUser' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Calls POST /api/v1/users/ldapsync with empty body when no location_id specified' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Body, $Session, $PreserveResponse)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; Body = $Body; Session = $Session })
                return [pscustomobject]@{
                    status   = 'success'
                    messages = '25 users imported/synchronized.'
                    payload  = $null
                }
            }

            $res = Sync-SnipeitLdapUser -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/users/ldapsync'
            $call.Method | Should -Be 'Post'
            $call.Body.ContainsKey('location_id') | Should -Be $false
            $res.status | Should -Be 'success'
            $res.messages | Should -Be '25 users imported/synchronized.'
        }

        It 'Calls POST /api/v1/users/ldapsync with location_id in body' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Body, $Session, $PreserveResponse)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; Body = $Body; Session = $Session })
                return [pscustomobject]@{
                    status   = 'success'
                    messages = '5 users imported for location 3.'
                    payload  = $null
                }
            }

            $res = Sync-SnipeitLdapUser -location_id 3 -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Body.location_id | Should -Be 3
            $res.messages | Should -Be '5 users imported for location 3.'
        }

        It 'Performs zero HTTP requests under -WhatIf' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw "HTTP method should not be invoked under WhatIf"
            }

            { Sync-SnipeitLdapUser -location_id 2 -Session $script:testSession -WhatIf } | Should -Not -Throw
        }
    }
}
