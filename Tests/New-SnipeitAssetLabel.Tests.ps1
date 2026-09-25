BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'New-SnipeitAssetLabel' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Calls /api/v1/hardware/labels endpoint with POST method and resolved asset tags' {
            Mock Get-SnipeitAsset -ModuleName SnipeitPS {
                param($id, $Session)
                return [pscustomobject]@{ id = $id; asset_tag = "TAG-$id" }
            }

            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Api, $Method, $Body, $Session)
                $script:capturedCalls.Add(@{ Api = $Api; Method = $Method; Body = $Body; Session = $Session })
                return [pscustomobject]@{ status = 'success'; payload = @{ pdf = 'base64pdf' } }
            }

            $res = New-SnipeitAssetLabel -asset_ids 1, 2 -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Api | Should -Be '/api/v1/hardware/labels'
            $call.Method | Should -Be 'Post'
            $call.Body.asset_ids | Should -Be @(1, 2)
            $call.Body.asset_tags | Should -Be @('TAG-1', 'TAG-2')
        }

        It 'Uses explicit asset_tags directly without calling Get-SnipeitAsset' {
            Mock Get-SnipeitAsset -ModuleName SnipeitPS {
                throw 'Should not be called when tags are specified directly'
            }

            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Api, $Method, $Body, $Session)
                $script:capturedCalls.Add(@{ Body = $Body })
                return [pscustomobject]@{ status = 'success' }
            }

            New-SnipeitAssetLabel -asset_tags 'TAG-A', 'TAG-B' -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $script:capturedCalls[0].Body.asset_tags | Should -Be @('TAG-A', 'TAG-B')
        }

        It 'Performs zero HTTP requests under -WhatIf' {
            Mock Get-SnipeitAsset -ModuleName SnipeitPS {
                throw 'Should not be invoked under WhatIf'
            }
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw 'Should not be invoked under WhatIf'
            }

            New-SnipeitAssetLabel -asset_ids 1, 2 -Session $script:testSession -WhatIf
            Should -Invoke Get-SnipeitAsset -Times 0 -ModuleName SnipeitPS
            Should -Invoke Invoke-SnipeitMethod -Times 0 -ModuleName SnipeitPS
        }

        It 'Fails fast when asset ID cannot be resolved to a tag' {
            Mock Get-SnipeitAsset -ModuleName SnipeitPS {
                throw 'Asset not found'
            }
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw 'Should not be called if tag resolution fails'
            }

            { New-SnipeitAssetLabel -asset_ids 999 -Session $script:testSession -Confirm:$false } | Should -Throw
        }
    }
}
