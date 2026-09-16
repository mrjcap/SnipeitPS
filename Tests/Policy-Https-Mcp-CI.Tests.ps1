BeforeAll {
    $repositoryRoot = Split-Path -Parent $PSScriptRoot
    Import-Module (Join-Path $repositoryRoot 'SnipeitPS/SnipeitPS.psd1') -Force
    $mcpPath = Join-Path $repositoryRoot 'mcp/SnipeitMcpServer.ps1'
    function Invoke-McpInitializeProcess {
        param([string]$Engine, [string]$Path)
        $process = [System.Diagnostics.Process]::new()
        $process.StartInfo = [System.Diagnostics.ProcessStartInfo]::new()
        $process.StartInfo.FileName = $Engine
        $process.StartInfo.Arguments = '-NoProfile -NonInteractive -File "' + $Path + '"'
        $process.StartInfo.UseShellExecute = $false
        $process.StartInfo.RedirectStandardInput = $true
        $process.StartInfo.RedirectStandardOutput = $true
        $process.StartInfo.RedirectStandardError = $true
        try {
            $null = $process.Start()
            $stdout = $process.StandardOutput.ReadToEndAsync()
            $stderr = $process.StandardError.ReadToEndAsync()
            $process.StandardInput.WriteLine('{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}')
            $process.StandardInput.Close()
            if (-not $process.WaitForExit(30000)) {
                $process.Kill()
                throw 'MCP initialize process timed out.'
            }
            [pscustomobject]@{
                Output = $stdout.GetAwaiter().GetResult()
                Error = $stderr.GetAwaiter().GetResult()
                ExitCode = $process.ExitCode
            }
        } finally {
            $process.Dispose()
        }
    }
    $engine = if (Test-Path (Join-Path $PSHOME 'pwsh.exe')) {
        Join-Path $PSHOME 'pwsh.exe'
    } else {
        Join-Path $PSHOME 'powershell.exe'
    }
}

Describe 'HTTPS, module metadata, MCP, and CI policy' {
    It 'uses manifest version for the module and HTTP User-Agent' {
        $manifest = Test-ModuleManifest -Path (Join-Path $repositoryRoot 'SnipeitPS/SnipeitPS.psd1')
        $manifest.Version.ToString() | Should -Be '1.16.0'

        InModuleScope 'SnipeitPS' {
            $script:SnipeitPSSession.url = 'https://test.example'
            $script:SnipeitPSSession.apiKey = ConvertTo-SecureString 'test-key' -AsPlainText -Force
            Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'success' } }
            Invoke-SnipeitMethod -Api '/api/v1/status' -Method Get | Out-Null
            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                $Headers['User-Agent'] -eq 'SnipeitPS/1.16.0'
            }
        }
    }

    It 'rejects HTTP in Connect-SnipeitPS and accepts HTTPS' {
        InModuleScope 'SnipeitPS' {
            Mock Test-SnipeitPSConnection { $true }
            { Connect-SnipeitPS -url 'http://test.example' -apiKey 'test-key' } | Should -Throw
            { Connect-SnipeitPS -url 'https://test.example' -apiKey 'test-key' } | Should -Not -Throw
        }
    }

    It 'rejects HTTP in manually constructed sessions and dispatcher sessions' {
        $key = ConvertTo-SecureString 'test-key' -AsPlainText -Force
        { [SnipeitSession]::new('http://test.example', $key) } | Should -Throw
        { [SnipeitSession]::new('https://test.example', $key) } | Should -Not -Throw

        InModuleScope 'SnipeitPS' {
            $session = [PSCustomObject]@{
                Url = 'http://test.example'
                ApiKey = ConvertTo-SecureString 'test-key' -AsPlainText -Force
            }
            { Invoke-SnipeitMethod -Session $session -Api '/api/v1/status' } | Should -Throw
        }
    }

    It 'requires MCP environment configuration before initialize' {
        $oldUrl = $env:SNIPEIT_MCP_URL
        $oldKey = $env:SNIPEIT_MCP_API_KEY
        try {
            Remove-Item Env:SNIPEIT_MCP_URL -ErrorAction SilentlyContinue
            Remove-Item Env:SNIPEIT_MCP_API_KEY -ErrorAction SilentlyContinue
            $processResult = Invoke-McpInitializeProcess -Engine $engine -Path $mcpPath
            $output = $processResult.Output + $processResult.Error
            $processResult.ExitCode | Should -Not -Be 0
            $processResult.Error | Should -Match 'SNIPEIT_MCP_URL and SNIPEIT_MCP_API_KEY must be set'
            $output | Should -Not -Match '"protocolVersion"'
        } finally {
            if ($null -eq $oldUrl) { Remove-Item Env:SNIPEIT_MCP_URL -ErrorAction SilentlyContinue } else { $env:SNIPEIT_MCP_URL = $oldUrl }
            if ($null -eq $oldKey) { Remove-Item Env:SNIPEIT_MCP_API_KEY -ErrorAction SilentlyContinue } else { $env:SNIPEIT_MCP_API_KEY = $oldKey }
        }
    }

    It 'rejects non-HTTPS MCP URLs before initialize without exposing the key' {
        $oldUrl = $env:SNIPEIT_MCP_URL
        $oldKey = $env:SNIPEIT_MCP_API_KEY
        try {
            $env:SNIPEIT_MCP_URL = 'http://test.example'
            $env:SNIPEIT_MCP_API_KEY = 'mcp-secret-key'
            $processResult = Invoke-McpInitializeProcess -Engine $engine -Path $mcpPath
            $output = $processResult.Output + $processResult.Error
            $processResult.ExitCode | Should -Not -Be 0
            $processResult.Error | Should -Match 'SNIPEIT_MCP_URL must be an absolute HTTPS URL'
            $output | Should -Not -Match '"protocolVersion"'
            $output | Should -Not -Match 'mcp-secret-key'
        } finally {
            if ($null -eq $oldUrl) { Remove-Item Env:SNIPEIT_MCP_URL -ErrorAction SilentlyContinue } else { $env:SNIPEIT_MCP_URL = $oldUrl }
            if ($null -eq $oldKey) { Remove-Item Env:SNIPEIT_MCP_API_KEY -ErrorAction SilentlyContinue } else { $env:SNIPEIT_MCP_API_KEY = $oldKey }
        }
    }

    It 'handles a complete MCP session, reports manifest version, and hides mutation tools by default' {
        $oldUrl = $env:SNIPEIT_MCP_URL
        $oldKey = $env:SNIPEIT_MCP_API_KEY
        $oldWrites = $env:SNIPEIT_MCP_ENABLE_WRITES
        try {
            $env:SNIPEIT_MCP_URL = 'https://test.example'
            $env:SNIPEIT_MCP_API_KEY = 'test-key'
            Remove-Item Env:SNIPEIT_MCP_ENABLE_WRITES -ErrorAction SilentlyContinue
            $requests = @(
                '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}'
                '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}'
                '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'
                '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"snipeit_create_asset","arguments":{}}}'
            )
            $responses = @($requests | & $engine -NoProfile -File $mcpPath | ForEach-Object { $_ | ConvertFrom-Json })

            $responses.Count | Should -Be 3
            @($responses.id) | Should -Be @(1, 2, 3)
            $initialize = $responses | Where-Object id -EQ 1
            $initialize.result.serverInfo.version | Should -Be '1.16.0'
            $list = $responses | Where-Object id -EQ 2
            @($list.result.tools.name) | Should -Not -Contain 'snipeit_create_asset'
            @($list.result.tools.name) | Should -Not -Contain 'snipeit_sync_asset'

            $call = $responses | Where-Object id -EQ 3
            $call.result.isError | Should -BeTrue
            $call.result.content.text | Should -Match 'disabled'

            $env:SNIPEIT_MCP_ENABLE_WRITES = 'true'
            $writeList = ('{"jsonrpc":"2.0","id":4,"method":"tools/list","params":{}}' |
                & $engine -NoProfile -File $mcpPath | ConvertFrom-Json)
            @($writeList.result.tools.name) | Should -Contain 'snipeit_create_asset'
        } finally {
            if ($null -eq $oldUrl) { Remove-Item Env:SNIPEIT_MCP_URL -ErrorAction SilentlyContinue } else { $env:SNIPEIT_MCP_URL = $oldUrl }
            if ($null -eq $oldKey) { Remove-Item Env:SNIPEIT_MCP_API_KEY -ErrorAction SilentlyContinue } else { $env:SNIPEIT_MCP_API_KEY = $oldKey }
            if ($null -eq $oldWrites) { Remove-Item Env:SNIPEIT_MCP_ENABLE_WRITES -ErrorAction SilentlyContinue } else { $env:SNIPEIT_MCP_ENABLE_WRITES = $oldWrites }
        }
    }

    It 'uses Windows tags, explicit Windows PowerShell, and a protected manual integration job' {
        $ci = Get-Content (Join-Path $repositoryRoot '.gitlab-ci.yml') -Raw
        $ci | Should -Match '(?m)^\s*tags:\s*\r?\n\s*- windows\s*$'
        $ci | Should -Match 'powershell\.exe\s+-NoProfile\s+-ExecutionPolicy\s+Bypass\s+-File\s+\.\\run-tests\.ps1'
        $ci | Should -Match '(?ms)^Integration:.*?when:\s*manual'
        $ci | Should -Match '(?ms)^Integration:.*?CI_COMMIT_REF_PROTECTED'
        $ci | Should -Not -Match '(?m)^\s*- release\s*$'
        $ci | Should -Not -Match '(?m)^Release:'
    }
}
