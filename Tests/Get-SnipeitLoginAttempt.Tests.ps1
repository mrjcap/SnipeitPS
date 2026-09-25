BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitLoginAttempt' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Queries login attempts via GET /api/v1/settings/login-attempts with parameters' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $GetParameters, $Session, $Paginate, $PreserveResponse)
                $script:capturedCalls.Add(@{
                    Route            = $Route
                    Method           = $Method
                    GetParameters    = $GetParameters
                    Session          = $Session
                    Paginate         = $Paginate
                    PreserveResponse = $PreserveResponse
                })
                return @(
                    [pscustomobject]@{ id = 1; username = 'admin'; successful = 1; remote_ip = '10.0.0.1' }
                )
            }

            $res = Get-SnipeitLoginAttempt -sort 'created_at' -order 'desc' -limit 10 -offset 0 -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/settings/login-attempts'
            $call.Method | Should -Be 'Get'
            $call.GetParameters.sort | Should -Be 'created_at'
            $call.GetParameters.order | Should -Be 'desc'
            $call.GetParameters.limit | Should -Be 10
            $call.GetParameters.offset | Should -Be 0
            $call.Paginate | Should -Be $false
            @($res).Count | Should -Be 1
            $res[0].username | Should -Be 'admin'
        }

        It 'Passes Paginate = true when -All switch is specified' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $GetParameters, $Session, $Paginate)
                $script:capturedCalls.Add(@{ Paginate = $Paginate })
                return @()
            }

            $res = Get-SnipeitLoginAttempt -All -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $script:capturedCalls[0].Paginate | Should -Be $true
        }

        It 'Preserves raw response when -preserveResponse is specified' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $GetParameters, $Session, $PreserveResponse)
                $script:capturedCalls.Add(@{ PreserveResponse = $PreserveResponse })
                return [pscustomobject]@{ total = 0; rows = @() }
            }

            $res = Get-SnipeitLoginAttempt -preserveResponse -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $script:capturedCalls[0].PreserveResponse | Should -Be $true
        }
    }
}
