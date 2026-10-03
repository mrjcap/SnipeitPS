[CmdletBinding()]
param(
    [string]$URL,
    [string]$ApiKey,
    [string]$Path = "./Tests/Integration/",
    [string]$Verbosity = "Detailed"
)

function ConvertTo-SafeIntegrationUrl {
    param(
        [string]$InputUrl
    )

    $parsedUri = $null
    if (-not [System.Uri]::TryCreate($InputUrl, [System.UriKind]::Absolute, [ref]$parsedUri) -or
        [string]::IsNullOrWhiteSpace($parsedUri.Scheme) -or
        [string]::IsNullOrWhiteSpace($parsedUri.Host)) {
        return "[invalid URL]"
    }

    $port = ""
    if (-not $parsedUri.IsDefaultPort) {
        $port = ":$($parsedUri.Port)"
    }

    return "{0}://{1}{2}{3}" -f $parsedUri.Scheme, $parsedUri.Host, $port, $parsedUri.AbsolutePath
}

if ([string]::IsNullOrWhiteSpace($URL)) {
    $URL = $env:SNIPEIT_TEST_URL
}
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    $ApiKey = $env:SNIPEIT_TEST_KEY
}
if ([string]::IsNullOrWhiteSpace($URL) -or [string]::IsNullOrWhiteSpace($ApiKey)) {
    throw "Integration tests require SNIPEIT_TEST_URL and SNIPEIT_TEST_KEY. Supply them as environment variables or script parameters."
}

$env:SNIPEIT_TEST_URL = $URL
$env:SNIPEIT_TEST_KEY = $ApiKey

if ([Environment]::GetCommandLineArgs() -notcontains '-NonInteractive') {
    $runtime = (Get-Process -Id $PID).Path
    $optionsJson = @{ Path = $Path; Verbosity = $Verbosity } | ConvertTo-Json -Compress
    $optionsBase64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($optionsJson))
    $runnerPath = $PSCommandPath.Replace("'", "''")
    $childScript = @"
`$options = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$optionsBase64')) | ConvertFrom-Json
& '$runnerPath' -Path `$options.Path -Verbosity `$options.Verbosity
exit `$LASTEXITCODE
"@
    $encodedScript = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($childScript))
    & $runtime -NoProfile -NonInteractive -EncodedCommand $encodedScript
    exit $LASTEXITCODE
}
$ErrorActionPreference = 'Stop'
$ConfirmPreference = 'None'
Import-Module Pester -RequiredVersion 5.8.0 -Force

$safeURL = ConvertTo-SafeIntegrationUrl -InputUrl $URL
Write-Output "Targeting live Snipe-IT instance at $safeURL..."

$config = New-PesterConfiguration
$config.Run.Path = $Path
$config.Filter.Tag = "Integration"
$config.Output.Verbosity = $Verbosity
$config.Run.PassThru = $true

$result = Invoke-Pester -Configuration $config
Write-Output "`nIntegration Tests Result -> Total: $($result.TotalCount) Passed: $($result.PassedCount) Failed: $($result.FailedCount)"
if ($result.TotalCount -eq 0 -or $result.FailedContainersCount -gt 0 -or $result.SkippedCount -gt 0) {
    throw 'Integration test runner requires nonzero tests, no failed containers, and no skipped tests.'
}
exit $result.FailedCount
