[CmdletBinding()]
param(
    [string]$URL = ($env:SNIPEIT_TEST_URL ?? 'http://192.168.1.47'),
    [string]$ApiKey = ($env:SNIPEIT_TEST_KEY ?? 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMjk1OGM2ZWY2ZDU3ZTAxZWM4NmIxN2NjMGFlZjA1NGVkY2UwOThlMzllNzQ3MTZmMTE4NDhmMTdjNTVlYzc4ODFhMGNjMDE5ZDdiM2NiODYiLCJpYXQiOjE3ODY5MDkzNjIuNjQ5NDgzLCJuYmYiOjE3ODY5MDkzNjIuNjQ5NDksImV4cCI6MjQxODA2MTM2Mi42MjUwOTEsInN1YiI6IjEiLCJzY29wZXMiOltdfQ.E3MaayqG_D3GJ4vBMyQjNJG261xR6Gl5MtZrVLcpUL9hWoCdz7gq3-ModyV2t36JjXMiG2_z_-wNYkmJSTH-K8BKetGjAP9ofUXVieNZbrsqthZffGZV23AZwHnMPDTfXFzkC9xRn9Qf0T55gyHytCGEWl524Zg4EkvUkeGbGBhlvsZ0hJfMg3RpvU1ONtEqAAvLlu4nCJUNscqEltoAuVvqbFhn4oYS20M8o1VJTvdj36V_oP-5BEXWP-x6i5_v2WDk2EF8BItj2g3Q3XGDmX63n3mvXKKuO1xFpLp5zNZISJ1Xl8FWqszrFRnP4x2qz8aWQMeXI2_-hAc4bOjKDZuw_4YUEYB9CE3PHKVjdXQtDpTOsbRu6t-661lk75oOwZpR6dUe-3LB7vQ0tBblJgRNX9wNr7AV0fm1DmLctwkSEFzhW0KqbnzBi_iba8NAwRoZksISUHz9AaBOkcV_kTD1P8NCLl8BkZ8YDuxlLVac0lQmhVIbaOov84qLW3sP_bOhGi64EQXE3FEapNae8cMfSk5_bzQWV2_4vIxsWtpzMjHt7IWpFvb07W6KyjzcQSZKRkbBFJWGduhy9_LcERPh5Gu2izKBP7nRili41JDLsGQ_7Pt0vnBoxdwOMuJBZtph5ZFjHWtOdrDkpJ-pLjQnNiRGIYSGYHC9XfvFaR4'),
    [string]$Path = "./Tests/Integration/",
    [string]$Verbosity = "Detailed"
)

$env:SNIPEIT_TEST_URL = $URL
$env:SNIPEIT_TEST_KEY = $ApiKey

Write-Host "Targeting live Snipe-IT instance at $URL..." -ForegroundColor Cyan

$config = New-PesterConfiguration
$config.Run.Path = $Path
$config.Filter.Tag = "Integration"
$config.Output.Verbosity = $Verbosity
$config.Run.PassThru = $true

$result = Invoke-Pester -Configuration $config
Write-Host "`nIntegration Tests Result -> Total: $($result.TotalCount) Passed: $($result.PassedCount) Failed: $($result.FailedCount)" -ForegroundColor $(if ($result.FailedCount -eq 0) { "Green" } else { "Red" })
exit $result.FailedCount
