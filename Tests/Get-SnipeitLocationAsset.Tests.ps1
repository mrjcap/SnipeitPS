BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitLocationAsset' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Queries all physical assets at a location (unpaginated on server)' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Session)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method })
                return @(
                    [pscustomobject]@{ id = 401; asset_tag = 'LOC-ASSET-01' },
                    [pscustomobject]@{ id = 402; asset_tag = 'LOC-ASSET-02' }
                )
            }

            $res = @(Get-SnipeitLocationAsset -id 3 -Session $script:testSession)
            $res.Count | Should -Be 2
            $script:capturedCalls[0].Route | Should -Be '/api/v1/locations/3/assets'
            $script:capturedCalls[0].Method | Should -Be 'GET'
        }
    }
}
