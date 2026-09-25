BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitAssetNote' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Queries manual notes via GET /api/v1/notes/{asset}/index and streams notes array' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Session, $PreserveResponse)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ Route = $Route; RouteTokens = $tokens; Method = $Method; Session = $Session })
                return [pscustomobject]@{
                    asset_id = 42
                    notes = @(
                        [pscustomobject]@{ id = 101; note = 'Screen replaced'; username = 'admin' }
                        [pscustomobject]@{ id = 102; note = 'RAM upgraded'; username = 'tech' }
                    )
                }
            }

            $res = @(Get-SnipeitAssetNote -asset_id 42 -Session $script:testSession)
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/notes/{asset}/index'
            $call.RouteTokens.asset | Should -Be 42
            $call.Method | Should -Be 'Get'
            $res.Count | Should -Be 2
            $res[0].id | Should -Be 101
            $res[0].note | Should -Be 'Screen replaced'
            $res[0].PSObject.TypeNames[0] | Should -Be 'SnipeitPS.AssetNote'
        }

        It 'Supports pipeline input for asset_id' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ asset = $tokens.asset })
                return [pscustomobject]@{ notes = @() }
            }

            @(10, 20) | Get-SnipeitAssetNote -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 2
            $script:capturedCalls[0].asset | Should -Be 10
            $script:capturedCalls[1].asset | Should -Be 20
        }

        It 'Preserves raw response envelope when -preserveResponse is specified' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Session, $PreserveResponse)
                $script:capturedCalls.Add(@{ PreserveResponse = $PreserveResponse })
                return [pscustomobject]@{ status = 'success'; payload = @{ notes = @(); asset_id = 42 } }
            }

            $res = Get-SnipeitAssetNote -asset_id 42 -preserveResponse -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $script:capturedCalls[0].PreserveResponse | Should -Be $true
            $res.status | Should -Be 'success'
        }
    }
}
