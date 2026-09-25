BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Restore-SnipeitManufacturer' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Restores manufacturer via POST /api/v1/manufacturers/{id}/restore' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ Route = $Route; RouteTokens = $tokens; Method = $Method; Body = $Body; Session = $Session })
                return [pscustomobject]@{ status = 'success'; messages = 'Manufacturer restored successfully.' }
            }

            $res = Restore-SnipeitManufacturer -id 14 -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/manufacturers/{id}/restore'
            $call.RouteTokens.id | Should -Be 14
            $call.Method | Should -Be 'Post'
            $call.Body.Keys.Count | Should -Be 0
            $call.Session | Should -Be $script:testSession
        }

        It 'Supports pipeline input for multiple IDs' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ id = $tokens.id })
                return [pscustomobject]@{ status = 'success' }
            }

            @(14, 15) | Restore-SnipeitManufacturer -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 2
            $script:capturedCalls[0].id | Should -Be 14
            $script:capturedCalls[1].id | Should -Be 15
        }

        It 'Performs zero HTTP requests under -WhatIf' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw 'Should not be invoked under WhatIf'
            }

            Restore-SnipeitManufacturer -id 14 -Session $script:testSession -WhatIf
            Should -Invoke Invoke-SnipeitMethod -Times 0 -ModuleName SnipeitPS
        }

        It 'Rejects non-positive ID' {
            { Restore-SnipeitManufacturer -id 0 -Session $script:testSession -Confirm:$false } | Should -Throw
            { Restore-SnipeitManufacturer -id -1 -Session $script:testSession -Confirm:$false } | Should -Throw
        }
    }
}
