Describe 'Pester runner noninteractive boundaries' {
    It 'enforces noninteractive execution through <EntryPoint> without caller flags' -ForEach @(
        @{ EntryPoint = 'Tests/Support/Invoke-SnipeitOfflineTest.ps1'; Integration = $false; Expected = 3 }
        @{ EntryPoint = 'run-tests.ps1'; Integration = $false; Expected = 3 }
        @{ EntryPoint = 'run-integration-tests.ps1'; Integration = $true; Expected = 2 }
    ) {
        $runner = Join-Path (Split-Path $PSScriptRoot -Parent) $EntryPoint
        $ast = [Management.Automation.Language.Parser]::ParseFile($runner, [ref]$null, [ref]$null)
        @($ast.ParamBlock.Parameters.Name.VariablePath.UserPath) | Should -Contain 'Path'
        $probePath = Join-Path $TestDrive 'RunnerProbe.Tests.ps1'
        $stdoutPath = Join-Path $TestDrive 'runner-stdout.txt'
        $stderrPath = Join-Path $TestDrive 'runner-stderr.txt'
        $probe = @'
BeforeAll {
    if ([Environment]::GetCommandLineArgs() -notcontains '-NonInteractive') {
        throw 'RUNNER_DID_NOT_ENFORCE_NONINTERACTIVE'
    }
    function Get-MandatoryInputProbe {
        param([Parameter(Mandatory = $true)][string]$Value)
        $Value
    }
    function Invoke-ConfirmationProbe {
        [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
        param()
        $PSCmdlet.ShouldProcess('Test probe', 'Check confirmation default')
    }
}
Describe 'Disposable runner probes' {
    It 'throws for missing mandatory input instead of asking' {
        { Get-MandatoryInputProbe } | Should -Throw
    }
    It 'does not implicitly ask for confirmation' {
        $ConfirmPreference | Should -Be 'None'
        Invoke-ConfirmationProbe | Should -BeTrue
    }
    It 'keeps the live network guard active' {
        { Invoke-RestMethod -Uri 'https://offline-probe.invalid' } | Should -Throw '*LIVE NETWORK BLOCKED*'
    }
}
'@
        if ($Integration) {
            $probe = $probe.Replace("Describe 'Disposable runner probes' {", "Describe 'Disposable runner probes' -Tag 'Integration' {")
            $probe = [regex]::Replace($probe, '(?ms)    It ''keeps the live network guard active'' \{.*?^    \}\r?\n', '')
        }
        $probe | Set-Content -LiteralPath $probePath -Encoding UTF8
        $runtime = (Get-Process -Id $PID).Path
        $startInfo = New-Object Diagnostics.ProcessStartInfo
        $startInfo.FileName = $runtime
        $startInfo.Arguments = '-NoProfile -File "' + $runner + '" -Path "' + $probePath + '"'
        $startInfo.UseShellExecute = $false
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        if ($Integration) {
            $startInfo.EnvironmentVariables['SNIPEIT_TEST_URL'] = 'https://runner-probe.invalid'
            $startInfo.EnvironmentVariables['SNIPEIT_TEST_KEY'] = 'disposable-probe-only'
        }
        $process = New-Object Diagnostics.Process
        $process.StartInfo = $startInfo
        try {
            $null = $process.Start()
            $stdoutTask = $process.StandardOutput.ReadToEndAsync()
            $stderrTask = $process.StandardError.ReadToEndAsync()
            $process.WaitForExit(60000) | Should -BeTrue -Because 'the runner must never wait for user input'
            $stdout = $stdoutTask.GetAwaiter().GetResult()
            $stderr = $stderrTask.GetAwaiter().GetResult()
            $stdout | Set-Content -LiteralPath $stdoutPath
            $stderr | Set-Content -LiteralPath $stderrPath
            $process.ExitCode | Should -Be 0 -Because ($stdout + $stderr)
            $stdout | Should -Match "Total: $Expected Passed: $Expected Failed: 0"
            $stdout | Should -Not -Match 'Supply values for the following parameters'
        } finally {
            if (-not $process.HasExited) { $process.Kill(); $process.WaitForExit() }
            $process.Dispose()
        }
    }
}
