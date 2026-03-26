$config = New-PesterConfiguration
$config.Run.Path = "./Tests/"
$config.Output.Verbosity = "Detailed"
$config.Run.PassThru = $true
$result = Invoke-Pester -Configuration $config
Write-Host "`nTotal: $($result.TotalCount) Passed: $($result.PassedCount) Failed: $($result.FailedCount)"
exit $result.FailedCount
