BeforeDiscovery { Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force }
Describe 'Offline fixture compatibility with Windows PowerShell' {
    BeforeAll {
        Add-Type 'public class DisplayDecodedSnipeitUri : System.Uri { public DisplayDecodedSnipeitUri(string value) : base(value) {} public override string ToString() { return System.Uri.UnescapeDataString(AbsoluteUri); } }'
    }
    It 'captures encoded URI properties in <File> even when display text is decoded' -ForEach @(
        @{File='ApiReaudit.Parameters.Tests.ps1'}, @{File='CurrentApiEndpoints.Tests.ps1'}
    ) {
        $uri = [DisplayDecodedSnipeitUri]::new('https://capture.invalid/api/v1/test?search=a+%26+b&excludeIds=7%2C8')
        [string]$uri | Should -Match 'search=a\+&\+b'
        $ast = [Management.Automation.Language.Parser]::ParseFile("$PSScriptRoot/$File", [ref]$null, [ref]$null)
        $mock = $ast.Find({param($node) $node -is [Management.Automation.Language.CommandAst] -and $node.GetCommandName() -eq 'Mock' -and $node.CommandElements[1].Value -eq 'Invoke-RestMethod'}, $true)
        $action = @($mock.CommandElements | Where-Object { $_ -is [Management.Automation.Language.ScriptBlockExpressionAst] })[0].ScriptBlock.GetScriptBlock()
        $script:reauditCalls = [Collections.Generic.List[string]]::new()
        $script:endpointCalls = [Collections.Generic.List[object]]::new()
        $null = & $action -Uri $uri
        $captured = if ($File -eq 'ApiReaudit.Parameters.Tests.ps1') { $script:reauditCalls[0] } else { $script:endpointCalls[0].Uri }
        $captured | Should -Match 'search=a\+%26\+b'
        $captured | Should -Match 'excludeIds=7%2C8'
    }
    It 'loads the complete large historical fixture without newer cmdlet switches' {
        . "$PSScriptRoot/Support/Import-SnipeitFixtureData.ps1"
        $data = Import-SnipeitFixtureData "$PSScriptRoot/Fixtures/ApiParity.Contracts.psd1"
        $data.ApiRef | Should -BeExactly '0c381a6482824a9f5d1889a98843393a0b6ad6b3'
        $data.Operations.Count | Should -Be 249
        @($data.Operations | Where-Object Key -eq 'models.assets')[0].State | Should -Be 'BlockedServer'
    }
    It 'rejects executable fixture expressions without running them' {
        . "$PSScriptRoot/Support/Import-SnipeitFixtureData.ps1"
        $fixture = Join-Path $TestDrive 'unsafe.psd1'
        $sentinel = Join-Path $TestDrive 'executed.txt'
        "@{ Value = `$(Set-Content -LiteralPath '$sentinel' -Value 'executed') }" | Set-Content $fixture
        { Import-SnipeitFixtureData $fixture } | Should -Throw
        Test-Path $sentinel | Should -BeFalse
    }
}
Describe 'Runtime-independent empty JSON request bodies' {
    InModuleScope SnipeitPS {
        It 'requests compact JSON through the <Entry> boundary' -ForEach @(@{Entry='Dispatcher'},@{Entry='Transport'}) {
            $key = [Security.SecureString]::new(); $key.AppendChar('x')
            $session = [SnipeitSession]::new('https://json.invalid', $key)
            Mock ConvertTo-Json { param($Compress) if ($Compress) { '{}' } else { "{`r`n`r`n}" } }
            Mock Invoke-RestMethod { param($Body) $script:compatibilityBody = $Body; [pscustomobject]@{status='success';payload=@{id=7}} }
            if ($Entry -eq 'Dispatcher') { $null = Invoke-SnipeitMethod -Route '/api/v1/models/7/restore' -Method POST -Body @{} -Session $session }
            else { $null = Invoke-SnipeitHttpRequest -Request @{Uri='https://json.invalid/api/v1/models/7/restore';Method='POST';Body=@{}} -Session $session }
            [Text.Encoding]::UTF8.GetString($script:compatibilityBody) | Should -BeExactly '{}'
        }
    }
}
