BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'New-SnipeitAssetNote' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Stores manual note via POST /api/v1/notes/{asset}/store' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ Route = $Route; RouteTokens = $tokens; Method = $Method; Body = $Body; Session = $Session })
                return [pscustomobject]@{ status = 'success'; messages = 'Note added' }
            }

            New-SnipeitAssetNote -asset_id 42 -note 'Replaced battery' -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/notes/{asset}/store'
            $call.RouteTokens.asset | Should -Be 42
            $call.Method | Should -Be 'Post'
            $call.Body.note | Should -Be 'Replaced battery'
            $call.Session | Should -Be $script:testSession
        }

        It 'Performs zero HTTP requests under -WhatIf' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw 'Should not be invoked under WhatIf'
            }

            New-SnipeitAssetNote -asset_id 42 -note 'WhatIf note' -Session $script:testSession -WhatIf
            Should -Invoke Invoke-SnipeitMethod -Times 0 -ModuleName SnipeitPS
        }

        It 'Rejects non-positive asset ID or empty note' {
            { New-SnipeitAssetNote -asset_id 0 -note 'Note' -Session $script:testSession -Confirm:$false } | Should -Throw
            { New-SnipeitAssetNote -asset_id 42 -note '' -Session $script:testSession -Confirm:$false } | Should -Throw
        }
    }
}
