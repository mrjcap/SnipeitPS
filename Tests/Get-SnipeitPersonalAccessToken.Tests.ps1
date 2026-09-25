BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitPersonalAccessToken' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Queries tokens via GET /api/v1/account/personal-access-tokens and tags type' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Session)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; Session = $Session })
                return @(
                    [pscustomobject]@{ id = 'token-uuid-1'; name = 'CI Runner' },
                    [pscustomobject]@{ id = 'token-uuid-2'; name = 'Backup Script' }
                )
            }

            $res = @(Get-SnipeitPersonalAccessToken -Session $script:testSession)
            $res.Count | Should -Be 2
            $res[0].id | Should -Be 'token-uuid-1'
            $res[0].PSObject.TypeNames[0] | Should -Be 'SnipeitPS.PersonalAccessToken'
            $script:capturedCalls.Count | Should -Be 1
            $script:capturedCalls[0].Route | Should -Be '/api/v1/account/personal-access-tokens'
            $script:capturedCalls[0].Method | Should -Be 'Get'
            $script:capturedCalls[0].Session | Should -Be $script:testSession
        }

        It 'Returns empty list when user has no tokens' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                return @()
            }

            $res = @(Get-SnipeitPersonalAccessToken -Session $script:testSession)
            $res.Count | Should -Be 0
        }
    }
}
