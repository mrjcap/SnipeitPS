BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitRequestableAsset' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Queries requestable hardware via GET /api/v1/account/requestable/hardware with filters' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $GetParameters, $Paginate, $Session)
                $script:capturedCalls.Add(@{ Route = $Route; Method = $Method; GetParameters = $GetParameters; Paginate = $Paginate; Session = $Session })
                return @([pscustomobject]@{ id = 10; asset_tag = 'REQ-001'; name = 'Available Laptop' })
            }

            $res = @(Get-SnipeitRequestableAsset -search 'laptop' -sort 'name' -order 'asc' -limit 20 -offset 40 -all -Session $script:testSession)
            $res.Count | Should -Be 1
            $res[0].id | Should -Be 10
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/account/requestable/hardware'
            $call.Method | Should -Be 'Get'
            $call.Paginate | Should -BeTrue
            $call.GetParameters.search | Should -Be 'laptop'
            $call.GetParameters.sort | Should -Be 'name'
            $call.GetParameters.order | Should -Be 'asc'
            $call.GetParameters.limit | Should -Be 20
            $call.GetParameters.offset | Should -Be 40
            $call.Session | Should -Be $script:testSession
        }

        It 'Passes custom field search parameters' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($GetParameters)
                $script:capturedCalls.Add(@{ GetParameters = $GetParameters })
                return @()
            }

            $cf = @{ '_snipeit_ram_1' = '32GB' }
            $null = Get-SnipeitRequestableAsset -customfields $cf -Session $script:testSession
            $script:capturedCalls[0].GetParameters['_snipeit_ram_1'] | Should -Be '32GB'
        }
    }
}
