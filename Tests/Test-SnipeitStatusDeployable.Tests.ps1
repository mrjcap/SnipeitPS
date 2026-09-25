BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Test-SnipeitStatusDeployable' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Returns deployable = true when server returns string "1"' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ Route = $Route; RouteTokens = $tokens; Method = $Method; Session = $Session })
                return '1'
            }

            $res = Test-SnipeitStatusDeployable -id 5 -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/statuslabels/{id}/deployable'
            $call.RouteTokens.id | Should -Be 5
            $call.Method | Should -Be 'Get'
            $res.id | Should -Be 5
            $res.deployable | Should -Be $true
            $res.PSObject.TypeNames[0] | Should -Be 'SnipeitPS.StatusDeployable'
        }

        It 'Returns deployable = false when server returns string "0"' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                return '0'
            }

            $res = Test-SnipeitStatusDeployable -id 6 -Session $script:testSession
            $res.deployable | Should -Be $false
        }

        It 'Supports pipeline input for id' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ id = $tokens.id })
                if ($tokens.id -eq 1) { return '1' } else { return '0' }
            }

            $results = @(1, 2 | Test-SnipeitStatusDeployable -Session $script:testSession)
            $results.Count | Should -Be 2
            $results[0].deployable | Should -Be $true
            $results[1].deployable | Should -Be $false
        }
    }
}
