BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitLocationAssignment' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Queries assigned assets for a location (unpaginated on server)' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Session)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method })
                return @([pscustomobject]@{ id = 501; asset_tag = 'CHECKED-OUT-TO-LOC-01' })
            }

            $res = @(Get-SnipeitLocationAssignment -AssignedType Asset -id 3 -Session $script:testSession)
            $res.Count | Should -Be 1
            $script:capturedCalls[0].Route | Should -Be '/api/v1/locations/3/assigned/assets'
            $script:capturedCalls[0].Method | Should -Be 'GET'
        }

        It 'Queries assigned accessories for a location (paginated on server)' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $GetParameters, $Paginate, $Session)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; GetParameters = $GetParameters; Paginate = $Paginate })
                return @([pscustomobject]@{ id = 601; name = 'HDMI Cable' })
            }

            $res = @(Get-SnipeitLocationAssignment -AssignedType Accessory -id 3 -offset 10 -limit 50 -All -Session $script:testSession)
            $res.Count | Should -Be 1
            $script:capturedCalls[0].Route | Should -Be '/api/v1/locations/3/assigned/accessories'
            $script:capturedCalls[0].GetParameters.offset | Should -Be 10
            $script:capturedCalls[0].GetParameters.limit | Should -Be 50
            $script:capturedCalls[0].Paginate | Should -BeTrue
        }
    }
}
