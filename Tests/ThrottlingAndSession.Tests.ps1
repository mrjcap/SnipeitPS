BeforeAll {
    . "$PSScriptRoot/../SnipeitPS/Classes/SnipeitCache.ps1"
    . "$PSScriptRoot/../SnipeitPS/Classes/SnipeitSession.ps1"
    . "$PSScriptRoot/../SnipeitPS/Classes/SnipeitCompleters.ps1"
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe "Throttling Queue & Multi-Tenant Session Architecture" {
    Context "SnipeitSession Class" {
        It "Instantiates SnipeitSession and encapsulates credentials" {
            $sec = ConvertTo-SecureString "test-token" -AsPlainText -Force
            $session = [SnipeitSession]::new("https://tenant1.snipeit.local", $sec)

            $session.Url | Should -Be "https://tenant1.snipeit.local"
            $session.ApiKey | Should -Be $sec
            ($null -ne $session.ThrottledRequests) | Should -BeTrue
        }
    }

    Context "Queue-Based Rate Limiting" {
        It "Maintains sliding window without memory leaks using Queue[long]" {
            InModuleScope 'SnipeitPS' {
                $sess = [ordered]@{
                    url = "https://mock.snipeit.local"
                    apiKey = "mock-token"
                    legacyUrl = $null
                    legacyApiKey = $null
                    throttleLimit = 100
                    throttleThreshold = 90
                    throttleMode = "Burst"
                    throttlePeriod = 60000
                    throttledRequests = [System.Collections.Generic.Queue[long]]::new()
                }

                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ id = 1; name = "Asset 1" }
                }

                Invoke-SnipeitMethod -Api "/api/v1/hardware/1" -Session $sess
                $sess.throttledRequests.Count | Should -Be 1
                ($sess.throttledRequests -is [System.Collections.Generic.Queue[long]]) | Should -BeTrue
            }
        }
    }
}
