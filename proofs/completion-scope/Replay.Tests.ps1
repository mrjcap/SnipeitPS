BeforeDiscovery {
    if (-not $env:SNIPEIT_SCOPE_TRACES) { throw 'Set SNIPEIT_SCOPE_TRACES to generated observed/traces.json' }
    $witnesses = @(Get-Content -LiteralPath $env:SNIPEIT_SCOPE_TRACES -Raw | ConvertFrom-Json)
    if ($witnesses.Count -ne 3) { throw 'Expected three generated witnesses' }
    $cases = @($witnesses | ForEach-Object { @{ Rule = $_.rule; Witness = $_ } })
}
BeforeAll {
    Import-Module "$PSScriptRoot/../../SnipeitPS/SnipeitPS.psd1" -Force
}
Describe 'Generated completion-scope witnesses' {
    It 'Replays every action of <Rule> through the real module' -ForEach $cases {
        param($Witness)
        InModuleScope SnipeitPS -Parameters @{ Witness = $Witness } {
            param($Witness)
            Clear-SnipeitCache
            $script:http = [System.Collections.Generic.List[string]]::new()
            Mock Invoke-WebRequest { throw 'Unexpected WebRequest: LIVE NETWORK BLOCKED' }
            Mock Invoke-RestMethod {
                param($Uri, $Headers)
                $url = [uri]$Uri
                $scope = switch ("$($url.Host)|$($Headers.Authorization)") {
                    'tenant-a.invalid|Bearer dummy-A1' { 'A1' }
                    'tenant-a.invalid|Bearer dummy-A2' { 'A2' }
                    'tenant-b.invalid|Bearer dummy-B1' { 'B1' }
                    default { throw 'Unexpected offline identity' }
                }
                $script:http.Add("$scope $($url.AbsolutePath)")
                switch ($url.AbsolutePath) {
                    '/api/v1/statuslabels' { @{ total = 1; rows = @(@{ id = 1; name = 'Ready' }) } }
                    '/api/v1/models' {
                        $id = @{ A1 = 11; A2 = 33; B1 = 22 }[$scope]
                        @{ total = 1; rows = @(@{ id = $id; name = "Model $scope" }) }
                    }
                    default { throw 'Unexpected offline route' }
                }
            }
            $urls = @{ A1 = 'https://tenant-a.invalid'; A2 = 'https://tenant-a.invalid'; B1 = 'https://tenant-b.invalid' }
            $ids = @{ A1 = '11'; A2 = '33'; B1 = '22' }
            $explicit = [SnipeitSession]::new($urls.B1, (ConvertTo-SecureString 'dummy-B1' -AsPlainText -Force))
            $completer = [SnipeitModelCompleter]::new()
            foreach ($item in $Witness.trace) {
                $s = $item.state
                $actual = @()
                $before = $script:http.Count
                switch ($s.event) {
                    'Init' { Connect-SnipeitPS -url $urls.A1 -apiKey 'dummy-A1' }
                    'ConnectB' { Connect-SnipeitPS -url $urls.B1 -apiKey 'dummy-B1' }
                    'RotateA' { Connect-SnipeitPS -url $urls.A2 -apiKey 'dummy-A2' }
                    'CompleteDefault' { $actual = @($completer.CompleteArgument('New-SnipeitAsset', 'model_id', '', $null, @{})) }
                    'CompleteExplicitB' { $actual = @($completer.CompleteArgument('New-SnipeitAsset', 'model_id', '', $null, @{ Session = $explicit })) }
                    default { throw "Unimplemented witness action $($s.event)" }
                }
                $script:SnipeitPSSession.url | Should -Be $urls[$s.connection]
                $credential = [pscredential]::new('offline', $script:SnipeitPSSession.apiKey)
                $credential.GetNetworkCredential().Password | Should -Be "dummy-$($s.connection)"
                if ($s.shown -ne 'none') {
                    $actual.Count | Should -Be 1
                    $actual[0].CompletionText | Should -Be $ids[$s.shown]
                    $actual[0].ListItemText | Should -Be "$($ids[$s.shown]) (Model $($s.shown))"
                    $expectedCalls = [int]($s.operations -eq 1)
                    ($script:http.Count - $before) | Should -Be $expectedCalls
                    if ($expectedCalls) { $script:http[-1] | Should -Be "$($s.connection) /api/v1/models" }
                } else {
                    ($script:http.Count - $before) | Should -Be 1
                    $script:http[-1] | Should -Be "$($s.connection) /api/v1/statuslabels"
                }
                [SnipeitCache]::Store.ContainsKey('Models') | Should -Be ($s.owner -ne 'none')
                if ($s.owner -ne 'none') {
                    [SnipeitCache]::Store['Models'].Value.id | Should -Be $ids[$s.owner]
                    [SnipeitCache]::Store['Models'].IsExpired() | Should -Be (-not $s.fresh)
                }
            }
            Should -Invoke Invoke-WebRequest -Times 0 -Exactly
            if ($env:SNIPEIT_SCOPE_NEGATIVE -eq '1') {
                $actual[0].CompletionText | Should -Be $ids[$s.requested] -Because 'the proposed connection-scope contract must hold'
            }
            Clear-SnipeitCache
        }
    }
}
Describe 'HTTP-only replay positive controls' {
    BeforeEach {
        InModuleScope SnipeitPS {
            Clear-SnipeitCache
            $script:mode = 'success'
            $script:probeFails = $false
            $script:calls = [System.Collections.Generic.List[string]]::new()
            Mock Invoke-WebRequest { throw 'LIVE NETWORK BLOCKED' }
            Mock Invoke-RestMethod {
                param($Uri, $Headers)
                $u = [uri]$Uri
                $identity = "$($u.Host)|$($Headers.Authorization)"
                $scope = switch ($identity) {
                    'tenant-a.invalid|Bearer dummy-A1' { 'A1' }
                    'tenant-a.invalid|Bearer dummy-A2' { 'A2' }
                    'tenant-b.invalid|Bearer dummy-B1' { 'B1' }
                    default { throw 'Unexpected identity' }
                }
                $script:calls.Add("$scope $($u.AbsolutePath)")
                if ($u.AbsolutePath -eq '/api/v1/statuslabels') {
                    if ($script:probeFails) { return @{ total = 0; rows = @() } }
                    return @{ total = 1; rows = @(@{ id = 1; name = 'Ready' }) }
                }
                if ($u.AbsolutePath -ne '/api/v1/models') { throw 'Unexpected route' }
                if ($script:mode -eq 'failure') { throw 'Offline HTTP failure' }
                if ($script:mode -eq 'empty') { return @{ total = 0; rows = @() } }
                @{ total = 1; rows = @(@{ id = @{ A1 = 11; A2 = 33; B1 = 22 }[$scope]; name = "Model $scope" }) }
            }
            Connect-SnipeitPS -url 'https://tenant-a.invalid' -apiKey 'dummy-A1'
        }
    }
    AfterEach { InModuleScope SnipeitPS { Clear-SnipeitCache } }
    It 'Routes explicit Session on the public getter without changing the default' {
        InModuleScope SnipeitPS {
            $b = [SnipeitSession]::new('https://tenant-b.invalid', (ConvertTo-SecureString 'dummy-B1' -AsPlainText -Force))
            @(Get-SnipeitModel -all -Session $b)[0].id | Should -Be 22
            $script:calls[-1] | Should -Be 'B1 /api/v1/models'
            $script:SnipeitPSSession.url | Should -Be 'https://tenant-a.invalid'
        }
    }
    It 'Clear and TTL expiry both force a fetch from the current connection' {
        InModuleScope SnipeitPS {
            $c = [SnipeitModelCompleter]::new()
            @($c.CompleteArgument('New-SnipeitAsset', 'model_id', '', $null, @{}))[0].CompletionText | Should -Be '11'
            Connect-SnipeitPS -url 'https://tenant-b.invalid' -apiKey 'dummy-B1'
            Clear-SnipeitCache
            @($c.CompleteArgument('New-SnipeitAsset', 'model_id', '', $null, @{}))[0].CompletionText | Should -Be '22'
            Connect-SnipeitPS -url 'https://tenant-a.invalid' -apiKey 'dummy-A2'
            [SnipeitCache]::Store['Models'].ExpiresAt = [datetime]::UtcNow.AddSeconds(-1)
            @($c.CompleteArgument('New-SnipeitAsset', 'model_id', '', $null, @{}))[0].CompletionText | Should -Be '33'
            @($script:calls | Where-Object { $_ -like '*/models' }).Count | Should -Be 3
        }
    }
    It 'Does not freshen expired rows after <Mode> and retries successfully' -ForEach @(@{ Mode = 'failure' }, @{ Mode = 'empty' }) {
        param($Mode)
        InModuleScope SnipeitPS -Parameters @{ Mode = $Mode } {
            param($Mode)
            $c = [SnipeitModelCompleter]::new()
            $null = $c.CompleteArgument('New-SnipeitAsset', 'model_id', '', $null, @{})
            [SnipeitCache]::Store['Models'].ExpiresAt = [datetime]::UtcNow.AddSeconds(-1)
            $script:mode = $Mode
            @($c.CompleteArgument('New-SnipeitAsset', 'model_id', '', $null, @{})).Count | Should -Be 0
            [SnipeitCache]::Store['Models'].IsExpired() | Should -BeTrue
            [SnipeitCache]::Store['Models'].Value.id | Should -Be 11
            $script:mode = 'success'
            @($c.CompleteArgument('New-SnipeitAsset', 'model_id', '', $null, @{}))[0].CompletionText | Should -Be '11'
            @($script:calls | Where-Object { $_ -like '*/models' }).Count | Should -Be 3
        }
    }
    It 'A failed probe publishes the candidate default and leaves the old cache' {
        InModuleScope SnipeitPS {
            $c = [SnipeitModelCompleter]::new()
            $null = $c.CompleteArgument('New-SnipeitAsset', 'model_id', '', $null, @{})
            $script:probeFails = $true
            { Connect-SnipeitPS -url 'https://tenant-b.invalid' -apiKey 'dummy-B1' } | Should -Throw '*Cannot verify connection*'
            $script:SnipeitPSSession.url | Should -Be 'https://tenant-b.invalid'
            $script:calls[-1] | Should -Be 'B1 /api/v1/statuslabels'
            @($c.CompleteArgument('New-SnipeitAsset', 'model_id', '', $null, @{}))[0].CompletionText | Should -Be '11'
        }
    }
    It 'Real module removal clears the cache before reload' {
        $module = Get-Module SnipeitPS
        $store = & $module {
            $c = [SnipeitModelCompleter]::new()
            $null = $c.CompleteArgument('New-SnipeitAsset', 'model_id', '', $null, @{})
            ,([SnipeitCache]::Store)
        }
        $store.ContainsKey('Models') | Should -BeTrue
        try {
            Remove-Module SnipeitPS -Force
            $store.Count | Should -Be 0
        } finally {
            Import-Module "$PSScriptRoot/../../SnipeitPS/SnipeitPS.psd1" -Force
        }
    }
}
