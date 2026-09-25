BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitAssetDue' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Routes all six semantic due combinations correctly' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Session, $GetParameters)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ Route = $Route; RouteTokens = $tokens; Method = $Method })
                return @()
            }

            Get-SnipeitAssetDue -Action Audit -Status Due -Session $script:testSession
            Get-SnipeitAssetDue -Action Audit -Status Overdue -Session $script:testSession
            Get-SnipeitAssetDue -Action Audit -Status DueOrOverdue -Session $script:testSession
            Get-SnipeitAssetDue -Action Checkin -Status Due -Session $script:testSession
            Get-SnipeitAssetDue -Action Checkin -Status Overdue -Session $script:testSession
            Get-SnipeitAssetDue -Action Checkin -Status DueOrOverdue -Session $script:testSession

            $script:capturedCalls.Count | Should -Be 6
            $script:capturedCalls[0].RouteTokens.action | Should -Be 'audits'
            $script:capturedCalls[0].RouteTokens.upcoming_status | Should -Be 'due'

            $script:capturedCalls[1].RouteTokens.action | Should -Be 'audits'
            $script:capturedCalls[1].RouteTokens.upcoming_status | Should -Be 'overdue'

            $script:capturedCalls[2].RouteTokens.action | Should -Be 'audits'
            $script:capturedCalls[2].RouteTokens.upcoming_status | Should -Be 'due-or-overdue'

            $script:capturedCalls[3].RouteTokens.action | Should -Be 'checkins'
            $script:capturedCalls[3].RouteTokens.upcoming_status | Should -Be 'due'

            $script:capturedCalls[4].RouteTokens.action | Should -Be 'checkins'
            $script:capturedCalls[4].RouteTokens.upcoming_status | Should -Be 'overdue'

            $script:capturedCalls[5].RouteTokens.action | Should -Be 'checkins'
            $script:capturedCalls[5].RouteTokens.upcoming_status | Should -Be 'due-or-overdue'
        }

        It 'Passes search, sort, order, limit, and offset query parameters' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $GetParameters, $Session, $Paginate)
                $script:capturedCalls.Add(@{ GetParameters = $GetParameters; Paginate = $Paginate })
                return @()
            }

            Get-SnipeitAssetDue -Action Audit -Status Due -search 'MacBook' -sort 'asset_tag' -order 'desc' -limit 25 -offset 50 -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $gp = $script:capturedCalls[0].GetParameters
            $gp.search | Should -Be 'MacBook'
            $gp.sort | Should -Be 'asset_tag'
            $gp.order | Should -Be 'desc'
            $gp.limit | Should -Be 25
            $gp.offset | Should -Be 50
            $script:capturedCalls[0].Paginate | Should -Be $false
        }

        It 'Sets Paginate switch when -All is specified' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $GetParameters, $Session, $Paginate)
                $script:capturedCalls.Add(@{ Paginate = $Paginate })
                return @()
            }

            Get-SnipeitAssetDue -Action Checkin -Status Overdue -All -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $script:capturedCalls[0].Paginate | Should -Be $true
        }
    }
}
