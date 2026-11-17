[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Traces,
    [Parameter(Mandatory)][string]$ResultFile,
    [switch]$Negative
)
$ErrorActionPreference = 'Stop'
$env:SNIPEIT_SCOPE_TRACES = (Resolve-Path -LiteralPath $Traces).Path
$env:SNIPEIT_SCOPE_NEGATIVE = [string][int][bool]$Negative
& "$PSScriptRoot/../../run-tests.ps1" -Path "$PSScriptRoot/Replay.Tests.ps1" -ResultFile $ResultFile
exit $LASTEXITCODE
