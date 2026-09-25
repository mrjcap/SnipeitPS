BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Clear-SnipeitBarcode' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Calls POST /api/v1/settings/purge_barcodes' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Body, $Session)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; Body = $Body; Session = $Session })
                return [pscustomobject]@{
                    message = 'Deleted 15 barcodes'
                }
            }

            $res = Clear-SnipeitBarcode -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/settings/purge_barcodes'
            $call.Method | Should -Be 'Post'
            $call.Session | Should -Be $script:testSession
            $res.message | Should -Be 'Deleted 15 barcodes'
        }

        It 'Performs zero HTTP requests under -WhatIf' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw "HTTP method should not be invoked under WhatIf"
            }

            { Clear-SnipeitBarcode -Session $script:testSession -WhatIf } | Should -Not -Throw
        }
    }
}
