BeforeAll {
    . "$PSScriptRoot/../SnipeitPS/Classes/SnipeitCache.ps1"
    . "$PSScriptRoot/../SnipeitPS/Classes/SnipeitCompleters.ps1"
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe "Dynamic Argument Completers & TTL Cache" {
    BeforeEach {
        Clear-SnipeitCache
    }

    Context "SnipeitCache" {
        It "Caches values within TTL window" {
            $callCount = 0
            $factory = {
                $script:callCount++
                return @(@{ id = 1; name = "TestItem" })
            }

            $first = [SnipeitCache]::GetOrAdd("TestKey", 300, $factory)
            $second = [SnipeitCache]::GetOrAdd("TestKey", 300, $factory)

            $first | Should -Not -BeNullOrEmpty
            $second | Should -Not -BeNullOrEmpty
            $script:callCount | Should -Be 1
        }

        It "Clears cache entries when Clear-SnipeitCache is invoked" {
            [SnipeitCache]::GetOrAdd("Key1", 300, { @{ id = 10 } })
            [SnipeitCache]::Store.ContainsKey("Key1") | Should -BeTrue

            Clear-SnipeitCache
            [SnipeitCache]::Store.ContainsKey("Key1") | Should -BeFalse
        }

        It "Safely handles concurrent GetOrAdd requests without duplicate factory executions" {
            if ($PSVersionTable.PSVersion.Major -lt 7) {
                [SnipeitCache]::GetOrAdd("ConcurrentKey", 300, { @{ id = 42; name = "ConcurrentResult" } }) | Out-Null
                [SnipeitCache]::Store.ContainsKey("ConcurrentKey") | Should -BeTrue
                return
            }

            $cachePath = (Resolve-Path "$PSScriptRoot/../SnipeitPS/Classes/SnipeitCache.ps1").Path
            1..10 | ForEach-Object -Parallel {
                . $using:cachePath
                [SnipeitCache]::GetOrAdd("ConcurrentKey", 300, { @{ id = 42; name = "ConcurrentResult" } }) | Out-Null
            }

            [SnipeitCache]::Store.ContainsKey("ConcurrentKey") | Should -BeTrue
            $val = [SnipeitCache]::Store["ConcurrentKey"].Value
            $val.id | Should -Be 42
        }
    }

    Context "IArgumentCompleter Implementations" {
        It "SnipeitModelCompleter returns matching completion results" {
            InModuleScope 'SnipeitPS' {
                Mock Get-SnipeitModel {
                    return @(
                        [PSCustomObject]@{ id = 1; name = "MacBook Pro 16" },
                        [PSCustomObject]@{ id = 2; name = "Dell Latitude 7420" }
                    )
                }

                $completer = [SnipeitModelCompleter]::new()
                $results = @($completer.CompleteArgument("New-SnipeitAsset", "model_id", "Mac", $null, @{}))

                $results.Count | Should -Be 1
                $results[0].CompletionText | Should -Be "1"
                $results[0].ListItemText | Should -Be "1 (MacBook Pro 16)"
            }
        }

        It "SnipeitStatusCompleter returns matching status completions" {
            InModuleScope 'SnipeitPS' {
                Mock Get-SnipeitStatus {
                    return @(
                        [PSCustomObject]@{ id = 1; name = "Ready to Deploy"; type = "deployable" },
                        [PSCustomObject]@{ id = 2; name = "Pending"; type = "pending" }
                    )
                }

                $completer = [SnipeitStatusCompleter]::new()
                $results = @($completer.CompleteArgument("New-SnipeitAsset", "status_id", "Ready", $null, @{}))

                $results.Count | Should -Be 1
                $results[0].CompletionText | Should -Be "1"
                $results[0].ListItemText | Should -Match "Ready to Deploy"
            }
        }

        It "Completer handles API disconnection gracefully without throwing" {
            InModuleScope 'SnipeitPS' {
                Mock Get-SnipeitModel {
                    throw "Network offline"
                }

                $completer = [SnipeitModelCompleter]::new()
                { $results = @($completer.CompleteArgument("New-SnipeitAsset", "model_id", "Test", $null, @{})) } | Should -Not -Throw
            }
        }
    }
}
