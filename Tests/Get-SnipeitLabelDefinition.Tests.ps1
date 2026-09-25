BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitLabelDefinition' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Queries all label definitions via GET /api/v1/labels with filters' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $GetParameters, $Session, $PreserveResponse)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; GetParameters = $GetParameters; Session = $Session })
                return @(
                    [pscustomobject]@{ name = 'Default\Avery5160'; unit = 'inch'; width = 2.63; height = 1.00 }
                )
            }

            $res = Get-SnipeitLabelDefinition -search 'Avery' -limit 10 -offset 5 -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/labels'
            $call.Method | Should -Be 'Get'
            $call.GetParameters.search | Should -Be 'Avery'
            $call.GetParameters.limit | Should -Be 10
            $call.GetParameters.offset | Should -Be 5
            @($res).Count | Should -Be 1
            $res[0].name | Should -Be 'Default\Avery5160'
        }

        It 'Queries single label definition via GET /api/v1/labels/{name}' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Session, $PreserveResponse)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ Route = $Route; RouteTokens = $tokens; Method = $Method; Session = $Session })
                return [pscustomobject]@{ name = 'Default/Avery5160'; unit = 'inch'; width = 2.63; height = 1.00 }
            }

            $res = Get-SnipeitLabelDefinition -name 'Default/Avery5160' -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/labels/{name}'
            $call.RouteTokens.name | Should -Be 'Default/Avery5160'
            $call.Method | Should -Be 'Get'
            $res.name | Should -Be 'Default/Avery5160'
        }

        It 'Preserves raw response when -preserveResponse is specified' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Session, $PreserveResponse)
                $script:capturedCalls.Add(@{ PreserveResponse = $PreserveResponse })
                return [pscustomobject]@{ status = 'success'; rows = @() }
            }

            Get-SnipeitLabelDefinition -preserveResponse -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $script:capturedCalls[0].PreserveResponse | Should -Be $true
        }
    }
}
