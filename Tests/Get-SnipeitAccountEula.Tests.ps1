BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitAccountEula' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Queries authenticated user accepted EULAs via GET /api/v1/account/eulas' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $GetParameters, $Session)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; GetParameters = $GetParameters; Session = $Session })
                return @([pscustomobject]@{ id = 1; name = 'Company Hardware Policy' })
            }

            $res = @(Get-SnipeitAccountEula -Session $script:testSession)
            $res.Count | Should -Be 1
            $res[0].name | Should -Be 'Company Hardware Policy'
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/account/eulas'
            $call.Method | Should -Be 'Get'
            $call.GetParameters.ContainsKey('user_id') | Should -BeFalse
            $call.Session | Should -Be $script:testSession
        }

        It 'Queries direct report EULAs when user_id is provided' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($GetParameters)
                $script:capturedCalls.Add(@{ GetParameters = $GetParameters })
                return @([pscustomobject]@{ id = 2; name = 'Remote Work Agreement' })
            }

            $res = @(Get-SnipeitAccountEula -user_id 7 -Session $script:testSession)
            $res.Count | Should -Be 1
            $script:capturedCalls[0].GetParameters.user_id | Should -Be 7
        }

        It 'Rejects non-positive user_id' {
            { Get-SnipeitAccountEula -user_id 0 -Session $script:testSession } | Should -Throw
            { Get-SnipeitAccountEula -user_id -3 -Session $script:testSession } | Should -Throw
        }
    }
}
