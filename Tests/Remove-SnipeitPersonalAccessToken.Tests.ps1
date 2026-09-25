BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Remove-SnipeitPersonalAccessToken' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Revokes token via DELETE /api/v1/account/personal-access-tokens/{tokenId}' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ Route = $Route; RouteTokens = $tokens; Method = $Method; Session = $Session })
                return $null
            }

            Remove-SnipeitPersonalAccessToken -tokenId 'tok_opaque_id_999' -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/account/personal-access-tokens/{tokenId}'
            $call.RouteTokens.tokenId | Should -Be 'tok_opaque_id_999'
            $call.Method | Should -Be 'Delete'
            $call.Session | Should -Be $script:testSession
        }

        It 'Supports pipeline input for tokenId' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ tokenId = $tokens.tokenId })
                return $null
            }

            @('token-1', 'token-2') | Remove-SnipeitPersonalAccessToken -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 2
            $script:capturedCalls[0].tokenId | Should -Be 'token-1'
            $script:capturedCalls[1].tokenId | Should -Be 'token-2'
        }

        It 'Performs zero HTTP requests under -WhatIf' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw 'Should not be invoked under WhatIf'
            }

            Remove-SnipeitPersonalAccessToken -tokenId 'tok_1' -Session $script:testSession -WhatIf
            Should -Invoke Invoke-SnipeitMethod -Times 0 -ModuleName SnipeitPS
        }

        It 'Rejects empty tokenId' {
            { Remove-SnipeitPersonalAccessToken -tokenId '' -Session $script:testSession -Confirm:$false } | Should -Throw
        }
    }
}
