BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitAssetAssignment' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Queries assigned assets for an asset' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $GetParameters, $Paginate, $Session)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; GetParameters = $GetParameters; Paginate = $Paginate })
                return @([pscustomobject]@{ id = 101; asset_tag = 'CHILD-ASSET-01' })
            }

            $res = @(Get-SnipeitAssetAssignment -AssignedType Asset -id 5 -offset 0 -limit 10 -All -Session $script:testSession)
            $res.Count | Should -Be 1
            $res[0].id | Should -Be 101
            $script:capturedCalls[0].Route | Should -Be '/api/v1/hardware/5/assigned/assets'
            $script:capturedCalls[0].Method | Should -Be 'GET'
            $script:capturedCalls[0].Paginate | Should -BeTrue
        }

        It 'Queries assigned accessories for an asset' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $GetParameters, $Session)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method })
                return @([pscustomobject]@{ id = 201; name = 'USB-C Adapter' })
            }

            $res = @(Get-SnipeitAssetAssignment -AssignedType Accessory -id 5 -Session $script:testSession)
            $res.Count | Should -Be 1
            $script:capturedCalls[0].Route | Should -Be '/api/v1/hardware/5/assigned/accessories'
        }

        It 'Queries assigned components for an asset with sorting' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $GetParameters, $Session)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; GetParameters = $GetParameters })
                return @([pscustomobject]@{ id = 301; name = '16GB RAM DDR4' })
            }

            $res = @(Get-SnipeitAssetAssignment -AssignedType Component -id 5 -sort 'created_at' -order 'desc' -Session $script:testSession)
            $res.Count | Should -Be 1
            $script:capturedCalls[0].Route | Should -Be '/api/v1/hardware/5/assigned/components'
            $script:capturedCalls[0].GetParameters.sort | Should -Be 'created_at'
            $script:capturedCalls[0].GetParameters.order | Should -Be 'desc'
        }
    }
}
