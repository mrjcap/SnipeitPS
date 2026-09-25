BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitDepreciationReport' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Queries depreciation report with search, sorting, and pagination parameters' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $GetParameters, $Paginate, $Session)
                $script:capturedCalls.Add(@{
                    Route         = $Route
                    Method        = $Method
                    GetParameters = $GetParameters
                    Paginate      = $Paginate
                    Session       = $Session
                })
                return @(
                    [pscustomobject]@{
                        id                   = 101
                        name                 = 'MacBook Pro 16'
                        asset_tag            = 'ASSET-0101'
                        purchase_cost        = '$2,499.00'
                        depreciated_value    = '$1,249.50'
                        monthly_depreciation = '$69.42'
                    },
                    [pscustomobject]@{
                        id                   = 102
                        name                 = 'Dell Precision'
                        asset_tag            = 'ASSET-0102'
                        purchase_cost        = '$1,800.00'
                        depreciated_value    = '$900.00'
                        monthly_depreciation = '$50.00'
                    }
                )
            }

            $res = @(Get-SnipeitDepreciationReport -search 'MacBook' -sort 'asset_tag' -order 'asc' -offset 0 -limit 20 -All -Session $script:testSession)
            $res.Count | Should -Be 2
            $script:capturedCalls.Count | Should -Be 1
            $script:capturedCalls[0].Route | Should -Be '/api/v1/reports/depreciation'
            $script:capturedCalls[0].Method | Should -Be 'GET'
            $script:capturedCalls[0].GetParameters.search | Should -Be 'MacBook'
            $script:capturedCalls[0].GetParameters.sort | Should -Be 'asset_tag'
            $script:capturedCalls[0].GetParameters.order | Should -Be 'asc'
            $script:capturedCalls[0].GetParameters.offset | Should -Be 0
            $script:capturedCalls[0].GetParameters.limit | Should -Be 20
            $script:capturedCalls[0].Paginate | Should -BeTrue
            $script:capturedCalls[0].Session | Should -Be $script:testSession
        }

        It 'Handles empty report results' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $GetParameters, $Session)
                $script:capturedCalls.Add(@{
                    Route = $Route
                })
                return @()
            }

            $res = @(Get-SnipeitDepreciationReport -search 'Nonexistent' -Session $script:testSession)
            $res.Count | Should -Be 0
            $script:capturedCalls[0].Route | Should -Be '/api/v1/reports/depreciation'
        }
    }
}
