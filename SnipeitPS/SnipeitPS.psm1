<#
.DESCRIPTION
PowerShell API for Snipe-IT Asset Management
#>
$publicRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Public'
Get-ChildItem -Path $publicRoot -Filter '*.ps1' | ForEach-Object {
    . $_.FullName
}

$privateRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Private'
Get-ChildItem -Path $privateRoot -Filter '*.ps1' | ForEach-Object {
    . $_.FullName
}

#Create unprefixed aliases
Set-SnipeitAlias

#Session variable for storing current session information
$SnipeitPSSession = [ordered]@{
    'url'               = $null
    'apiKey'            = $null
    'legacyUrl'         = $null
    'legacyApiKey'      = $null
    'throttleLimit'     = 0
    'throttleThreshold' = 0
    'throttleMode'      = $null
    'throttlePeriod'    = 0
    'throttledRequests' = [System.Collections.ArrayList]::new()
}
New-Variable -Name SnipeitPSSession -Value $SnipeitPSSession -Scope Script -Force
$script:IsPowerShell7 = $PSVersionTable.PSVersion -ge '7.0'
$script:SnipeitApiPrefix = '/api/v1'

$ExecutionContext.SessionState.Module.OnRemove = {
    if ($script:SnipeitPSSession -is [System.Collections.IDictionary]) {
        $script:SnipeitPSSession.Clear()
    }
}

