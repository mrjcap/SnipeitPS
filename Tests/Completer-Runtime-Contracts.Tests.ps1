BeforeAll {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Completer runtime contracts' {
    It 'Normalizes <Kind> factory output to null without caching it' -TestCases @(
        @{ Kind = 'empty pipeline'; Factory = {} },
        @{ Kind = 'empty array'; Factory = { @() } },
        @{ Kind = 'explicit null'; Factory = { $null } }
    ) {
        param($Factory)
        InModuleScope SnipeitPS -Parameters @{ Factory = $Factory } {
            param($Factory)
            [SnipeitCache]::Clear()
            $value = [SnipeitCache]::GetOrAdd('EmptyResult', 300, $Factory)
            ($null -eq $value) | Should -BeTrue
            [SnipeitCache]::Store.ContainsKey('EmptyResult') | Should -BeFalse
        }
    }

    It 'Uses the module fetcher and cache for <Entity> completion' -TestCases @(
        @{ Entity = 'Model' }, @{ Entity = 'Status' }, @{ Entity = 'Category' },
        @{ Entity = 'Location' }, @{ Entity = 'Company' }, @{ Entity = 'Supplier' },
        @{ Entity = 'Department' }, @{ Entity = 'Manufacturer' }, @{ Entity = 'User' }
    ) {
        param($Entity)
        InModuleScope SnipeitPS -Parameters @{ Entity = $Entity } {
            param($Entity)
            [SnipeitCache]::Clear()
            $command = "Get-Snipeit$Entity"
            Mock $command {
                [pscustomobject]@{ id = 11; name = 'Matching item'; username = 'tester' }
                [pscustomobject]@{ id = 22; name = 'Different item'; username = 'other' }
            }
            $completerType = "Snipeit${Entity}Completer" -as [type]
            $completer = $completerType::new()
            $first = @($completer.CompleteArgument('New-SnipeitAsset', 'id', 'Matching', $null, @{}))
            $second = @($completer.CompleteArgument('New-SnipeitAsset', 'id', 'Matching', $null, @{}))
            $first.Count | Should -Be 1
            $first[0].CompletionText | Should -Be '11'
            $first[0].ListItemText | Should -Match 'Matching item'
            $second[0].CompletionText | Should -Be '11'
            Should -Invoke $command -Times 1 -Exactly -ParameterFilter { $all }
            Clear-SnipeitCache
            $afterClear = @($completer.CompleteArgument('New-SnipeitAsset', 'id', 'Matching', $null, @{}))
            $afterClear.Count | Should -Be 1
            Should -Invoke $command -Times 2 -Exactly -ParameterFilter { $all }
        }
    }

    It 'Retries an empty completion result after the connection recovers' {
        InModuleScope SnipeitPS {
            [SnipeitCache]::Clear()
            $script:completionAttempts = 0
            Mock Get-SnipeitModel {
                $script:completionAttempts++
                if ($script:completionAttempts -eq 1) { throw 'Offline' }
                [pscustomobject]@{ id = 33; name = 'Recovered model' }
            }
            $completer = [SnipeitModelCompleter]::new()
            $offline = @($completer.CompleteArgument('New-SnipeitAsset', 'model_id', 'Recovered', $null, @{}))
            $offline.Count | Should -Be 0
            $recovered = @($completer.CompleteArgument('New-SnipeitAsset', 'model_id', 'Recovered', $null, @{}))
            $recovered.Count | Should -Be 1
            $recovered[0].CompletionText | Should -Be '33'
            Should -Invoke Get-SnipeitModel -Times 2 -Exactly
        }
    }
}
