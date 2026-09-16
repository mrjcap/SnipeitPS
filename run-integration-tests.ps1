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

$safeURL = ConvertTo-SafeIntegrationUrl -InputUrl $URL
Write-Host "Targeting live Snipe-IT instance at $safeURL..." -ForegroundColor Cyan

$config = New-PesterConfiguration
$config.Run.Path = $Path
$config.Filter.Tag = "Integration"
$config.Output.Verbosity = $Verbosity
$config.Run.PassThru = $true

$result = Invoke-Pester -Configuration $config
Write-Host "`nIntegration Tests Result -> Total: $($result.TotalCount) Passed: $($result.PassedCount) Failed: $($result.FailedCount)" -ForegroundColor $(if ($result.FailedCount -eq 0) { "Green" } else { "Red" })
exit $result.FailedCount
