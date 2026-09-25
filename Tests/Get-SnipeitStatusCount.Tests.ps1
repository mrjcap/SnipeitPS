BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitStatusCount' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Queries count by status label name and transforms into SnipeitPS.StatusCount items' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Session, $PreserveResponse)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; Session = $Session })
                return [pscustomobject]@{
                    labels = @('Ready to Deploy (10)', 'Pending (5)')
                    datasets = @(
                        [pscustomobject]@{
                            data = @(10, 5)
                            backgroundColor = @('#00ff00', '#ffff00')
                        }
                    )
                }
            }

            $res = @(Get-SnipeitStatusCount -By Name -Session $script:testSession)
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/statuslabels/assets/name'
            $call.Method | Should -Be 'Get'
            $res.Count | Should -Be 2
            $res[0].label | Should -Be 'Ready to Deploy (10)'
            $res[0].count | Should -Be 10
            $res[0].color | Should -Be '#00ff00'
            $res[0].PSObject.TypeNames[0] | Should -Be 'SnipeitPS.StatusCount'
        }

        It 'Queries count by meta status type' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Session, $PreserveResponse)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method })
                return [pscustomobject]@{
                    labels = @('Deployed (20)')
                    datasets = @(
                        [pscustomobject]@{
                            data = @(20)
                            backgroundColor = @('#0000ff')
                        }
                    )
                }
            }

            $res = @(Get-SnipeitStatusCount -By Type -Session $script:testSession)
            $script:capturedCalls.Count | Should -Be 1
            $script:capturedCalls[0].Route | Should -Be '/api/v1/statuslabels/assets/type'
            $res[0].count | Should -Be 20
        }

        It 'Preserves raw envelope when -preserveResponse is specified' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Session, $PreserveResponse)
                $script:capturedCalls.Add(@{ PreserveResponse = $PreserveResponse })
                return [pscustomobject]@{ labels = @(); datasets = @() }
            }

            $res = Get-SnipeitStatusCount -preserveResponse -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $script:capturedCalls[0].PreserveResponse | Should -Be $true
        }
    }
}
