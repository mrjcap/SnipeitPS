BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitActivityChart' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Queries activity chart with preset days parameter' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $GetParameters, $Session, $PreserveResponse)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; GetParameters = $GetParameters; Session = $Session })
                return [pscustomobject]@{
                    labels = @('Sep 1', 'Sep 2')
                    prev_label = 'Aug 1 – Aug 31'
                    new_assets = @(5, 3)
                    prev_new_assets = @(4, 2)
                }
            }

            $res = Get-SnipeitActivityChart -days 60 -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/reports/activity/chart'
            $call.Method | Should -Be 'Get'
            $call.GetParameters.days | Should -Be 60
            $res.labels | Should -Be @('Sep 1', 'Sep 2')
            $res.prev_label | Should -Be 'Aug 1 – Aug 31'
            $res.PSObject.TypeNames[0] | Should -Be 'SnipeitPS.ActivityChart'
        }

        It 'Queries activity chart with custom start_date and end_date' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $GetParameters, $Session, $PreserveResponse)
                $script:capturedCalls.Add(@{ GetParameters = $GetParameters })
                return [pscustomobject]@{
                    labels = @('Jan 1')
                    prev_label = 'Dec 1 – Dec 31'
                }
            }

            $res = Get-SnipeitActivityChart -start_date ([datetime]'2026-01-01') -end_date ([datetime]'2026-01-31') -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $gp = $script:capturedCalls[0].GetParameters
            $gp.start_date | Should -Be '2026-01-01'
            $gp.end_date | Should -Be '2026-01-31'
            $gp.ContainsKey('days') | Should -Be $false
        }

        It 'Preserves raw envelope when -preserveResponse is specified' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $PreserveResponse)
                $script:capturedCalls.Add(@{ PreserveResponse = $PreserveResponse })
                return [pscustomobject]@{ raw = $true }
            }

            $res = Get-SnipeitActivityChart -preserveResponse -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $script:capturedCalls[0].PreserveResponse | Should -Be $true
        }
    }
}
