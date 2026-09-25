BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Set-SnipeitFieldsetOrder' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Reorders fields via POST /api/v1/fields/fieldsets/{id}/order and preserves sync statistics' {
            Mock Get-SnipeitFieldsetField -ModuleName SnipeitPS {
                param($id, $Session)
                return @(
                    [pscustomobject]@{ id = 10; name = 'MAC Address' }
                    [pscustomobject]@{ id = 20; name = 'IMEI' }
                )
            }

            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session, $PreserveResponse)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ Route = $Route; RouteTokens = $tokens; Method = $Method; Body = $Body; PreserveResponse = $PreserveResponse })
                return [pscustomobject]@{ attached = @(); detached = @(); updated = @(10, 20) }
            }

            $res = Set-SnipeitFieldsetOrder -id 3 -item 20, 10 -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/fields/fieldsets/{id}/order'
            $call.RouteTokens.id | Should -Be 3
            $call.Method | Should -Be 'Post'
            $call.Body.item | Should -Be @(20, 10)
            $call.PreserveResponse | Should -Be $true
            $res.updated | Should -Be @(10, 20)
        }

        It 'Rejects duplicate field IDs in item' {
            { Set-SnipeitFieldsetOrder -id 3 -item 10, 20, 10 -Session $script:testSession -Confirm:$false } | Should -Throw
        }

        It 'Rejects when item is missing existing fields or contains extra fields' {
            Mock Get-SnipeitFieldsetField -ModuleName SnipeitPS {
                return @(
                    [pscustomobject]@{ id = 10 }
                    [pscustomobject]@{ id = 20 }
                )
            }

            # Missing field 20
            { Set-SnipeitFieldsetOrder -id 3 -item 10 -Session $script:testSession -Confirm:$false } | Should -Throw
            # Extra field 99
            { Set-SnipeitFieldsetOrder -id 3 -item 10, 20, 99 -Session $script:testSession -Confirm:$false } | Should -Throw
        }

        It 'Performs zero HTTP requests under -WhatIf' {
            Mock Get-SnipeitFieldsetField -ModuleName SnipeitPS {
                throw 'Should not be called under WhatIf'
            }
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw 'Should not be called under WhatIf'
            }

            Set-SnipeitFieldsetOrder -id 3 -item 10, 20 -Session $script:testSession -WhatIf
            Should -Invoke Get-SnipeitFieldsetField -Times 0 -ModuleName SnipeitPS
            Should -Invoke Invoke-SnipeitMethod -Times 0 -ModuleName SnipeitPS
        }
    }
}
