BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'New-SnipeitPersonalAccessToken' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Creates token via POST /api/v1/account/personal-access-tokens and securely encapsulates secret' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Body, $Session)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; Body = $Body; Session = $Session })
                return [pscustomobject]@{
                    id    = 'new-token-id-123'
                    name  = 'Deployer'
                    token = 'secret-bearer-string-xyz'
                }
            }

            $res = New-SnipeitPersonalAccessToken -name 'Deployer' -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/account/personal-access-tokens'
            $call.Method | Should -Be 'Post'
            $call.Body.name | Should -Be 'Deployer'
            $call.Session | Should -Be $script:testSession

            # Secret encapsulation check:
            $res.id | Should -Be 'new-token-id-123'
            $res.name | Should -Be 'Deployer'
            $res.TokenSecret | Should -BeOfType [System.Security.SecureString]
            # Plain text token property must NOT be present
            $res.PSObject.Properties['token'] | Should -BeNullOrEmpty
            # TypeName tag
            $res.PSObject.TypeNames[0] | Should -Be 'SnipeitPS.PersonalAccessToken'

            # Ensure secret can be decrypted back from SecureString
            $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($res.TokenSecret)
            $plain = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
            $plain | Should -Be 'secret-bearer-string-xyz'
        }

        It 'Performs zero HTTP requests under -WhatIf' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw 'Should not be invoked under WhatIf'
            }

            New-SnipeitPersonalAccessToken -name 'WhatIf Token' -Session $script:testSession -WhatIf
            Should -Invoke Invoke-SnipeitMethod -Times 0 -ModuleName SnipeitPS
        }
    }
}
