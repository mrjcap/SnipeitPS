[CmdletBinding()]
param(
    [string[]]$Path,
    [string]$ResultFile,
    [switch]$PassThru
)

& "$PSScriptRoot/Tests/Support/Invoke-SnipeitOfflineTest.ps1" @PSBoundParameters
exit $LASTEXITCODE
