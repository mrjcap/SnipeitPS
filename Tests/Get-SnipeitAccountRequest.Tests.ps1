BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitAccountRequest' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Queries self-service requests under /api/v1/account/requests and unwraps rows' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Session, $PreserveResponse)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; Session = $Session; PreserveResponse = $PreserveResponse })
                return [pscustomobject]@{
                    total = 2
                    rows  = @(
                        [pscustomobject]@{ name = 'MacBook Pro 16'; type = 'asset'; qty = 1 },
                        [pscustomobject]@{ name = 'Dell 27 Monitor'; type = 'asset'; qty = 1 }
                    )
                }
            }

            $res = @(Get-SnipeitAccountRequest -Session $script:testSession)
            $res.Count | Should -Be 2
            $res[0].name | Should -Be 'MacBook Pro 16'
            $script:capturedCalls.Count | Should -Be 1
            $script:capturedCalls[0].Route | Should -Be '/api/v1/account/requests'
            $script:capturedCalls[0].Method | Should -Be 'Get'
            $script:capturedCalls[0].Session | Should -Be $script:testSession
        }

        It 'Returns empty list when rows is missing or total is 0' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                return [pscustomobject]@{ total = 0 }
            }

            $res = @(Get-SnipeitAccountRequest -Session $script:testSession)
            $res.Count | Should -Be 0
        }

        It 'Preserves raw envelope when -preserveResponse is specified' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                return [pscustomobject]@{
                    total = 0
                }
            }

            $res = Get-SnipeitAccountRequest -preserveResponse -Session $script:testSession
            $res.total | Should -Be 0
        }
    }
}
