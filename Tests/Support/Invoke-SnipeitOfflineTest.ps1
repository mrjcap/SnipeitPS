[CmdletBinding()]
param(
    [string[]]$Path,
    [string]$ResultFile,
    [switch]$PassThru
)
$ErrorActionPreference = 'Stop'

if ([Environment]::GetCommandLineArgs() -notcontains '-NonInteractive') {
    $runtime = (Get-Process -Id $PID).Path
    $optionsJson = @{ Path = @($Path); ResultFile = $ResultFile; PassThru = [bool]$PassThru } | ConvertTo-Json -Compress
    $optionsBase64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($optionsJson))
    $runnerPath = $PSCommandPath.Replace("'", "''")
    $childScript = @"
`$options = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$optionsBase64')) | ConvertFrom-Json
`$parameters = @{}
if (`$options.Path) { `$parameters['Path'] = [string[]]@(`$options.Path) }
if (`$options.ResultFile) { `$parameters['ResultFile'] = [string]`$options.ResultFile }
if (`$options.PassThru) { `$parameters['PassThru'] = `$true }
& '$runnerPath' @parameters
exit `$LASTEXITCODE
"@
    $encodedScript = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($childScript))
    & $runtime -NoProfile -NonInteractive -EncodedCommand $encodedScript
    exit $LASTEXITCODE
}
$ConfirmPreference = 'None'

# Clean PSModulePath for PS5 child process
if ($PSVersionTable.PSVersion.Major -le 5) {
    if ($env:PSModulePath) {
        $cleanEntries = @($env:PSModulePath -split ';' | Where-Object {
            $_ -and ($_ -notmatch '(?i)Program Files[\\/]PowerShell[\\/]7[\\/]Modules')
        })
        $env:PSModulePath = $cleanEntries -join ';'
    }
}

# Install process-local guard proxies with real command parameter metadata
function Install-SnipeitOfflineGuard {
    [CmdletBinding()]
    param()

    foreach ($cmdletName in @('Invoke-RestMethod', 'Invoke-WebRequest')) {
        $cmd = Get-Command -Name "Microsoft.PowerShell.Utility\$cmdletName" -CommandType Cmdlet -ErrorAction SilentlyContinue
        if ($null -ne $cmd) {
            $meta = New-Object System.Management.Automation.CommandMetadata $cmd
            $paramBlock = [System.Management.Automation.ProxyCommand]::GetParamBlock($meta)
            $funcDef = @"
function global:$cmdletName {
    [CmdletBinding()]
    param(
$paramBlock
    )
    process {
        throw [System.InvalidOperationException]::new('LIVE NETWORK BLOCKED: Unmocked network call to $cmdletName')
    }
}
"@
            $sb = [scriptblock]::Create($funcDef)
            & $sb
        }
    }
}

Install-SnipeitOfflineGuard

# Import Pester 5.8
Import-Module Pester -RequiredVersion 5.8.0 -Force

# Resolve test paths (default to root Tests/*.Tests.ps1 excluding Integration)
$rootDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (-not $Path -or $Path.Count -eq 0) {
    $testFiles = Get-ChildItem -Path $rootDir -Filter '*.Tests.ps1' -File |
        Where-Object { $_.DirectoryName -eq $rootDir } |
        Select-Object -ExpandProperty FullName
    $resolvedPaths = @($testFiles)
} else {
    $resolvedPaths = @($Path | ForEach-Object { (Resolve-Path $_).Path })
}

if ($resolvedPaths.Count -eq 0) {
    Write-Error "Offline test runner error: No test files found matching specified path."
    exit 1
}

# Configure Pester 5.8
$config = New-PesterConfiguration
$config.Run.Path = $resolvedPaths
$config.Filter.ExcludeTag = @('Integration')
$config.Output.Verbosity = 'Detailed'
$config.Run.PassThru = $true

if ($ResultFile) {
    $config.TestResult.Enabled = $true
    $config.TestResult.OutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ResultFile)
    $config.TestResult.OutputFormat = 'NUnitXml'
}

$result = Invoke-Pester -Configuration $config

# Assertions: nonzero total count, zero failed containers, zero failed tests, zero skipped tests
$totalCount = if ($result.PSObject.Properties['TotalCount']) { $result.TotalCount } else { 0 }
$failedCount = if ($result.PSObject.Properties['FailedCount']) { $result.FailedCount } else { 0 }
$skippedCount = if ($result.PSObject.Properties['SkippedCount']) { $result.SkippedCount } else { 0 }
$failedContainers = if ($result.PSObject.Properties['FailedContainersCount']) { $result.FailedContainersCount } else { 0 }

Write-Output "`n[Offline Test Results] Total: $totalCount Passed: $($result.PassedCount) Failed: $failedCount Skipped: $skippedCount FailedContainers: $failedContainers"

if ($totalCount -eq 0) {
    Write-Error "Offline test runner error: zero tests were discovered or executed."
    exit 1
}

if ($failedContainers -gt 0) {
    Write-Error "Offline test runner error: $failedContainers container(s) failed."
    exit 1
}

if ($failedCount -gt 0) {
    Write-Error "Offline test runner error: $failedCount test(s) failed."
    exit $failedCount
}

if ($skippedCount -gt 0) {
    Write-Error "Offline test runner error: $skippedCount test(s) were skipped."
    exit 1
}

if ($PassThru) {
    return $result
}

exit 0
