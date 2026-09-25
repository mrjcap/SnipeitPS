BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitFieldsetField' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Queries fields for fieldset via POST /api/v1/fieldsets/{id}/fields' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ Route = $Route; RouteTokens = $tokens; Method = $Method; Body = $Body; Session = $Session })
                return @([pscustomobject]@{ id = 10; name = 'MAC' })
            }

            $res = Get-SnipeitFieldsetField -id 3 -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/fieldsets/{id}/fields'
            $call.RouteTokens.id | Should -Be 3
            $call.Method | Should -Be 'Post'
            $call.Body.Keys.Count | Should -Be 0
            $res[0].id | Should -Be 10
        }

        It 'Queries fields with model default values via POST /api/v1/fieldsets/{fieldset}/fields/{model}' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $RouteTokens, $PathParameter, $Method, $Body, $Session)
                $tokens = if ($RouteTokens) { $RouteTokens } else { $PathParameter }
                $script:capturedCalls.Add(@{ Route = $Route; RouteTokens = $tokens; Method = $Method; Body = $Body; Session = $Session })
                return @([pscustomobject]@{ id = 10; name = 'MAC'; defaultValue = '00:11:22:33:44:55' })
            }

            $res = Get-SnipeitFieldsetField -id 3 -model_id 7 -Session $script:testSession
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Route | Should -Be '/api/v1/fieldsets/{fieldset}/fields/{model}'
            $call.RouteTokens.fieldset | Should -Be 3
            $call.RouteTokens.model | Should -Be 7
            $call.Method | Should -Be 'Post'
            $call.Body.Keys.Count | Should -Be 0
            $res[0].defaultValue | Should -Be '00:11:22:33:44:55'
        }
    }
}
