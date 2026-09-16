<#
.DESCRIPTION
PowerShell API for Snipe-IT Asset Management
#>

# Import Classes first (custom types, completers, cache, session)
$classesRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Classes'
if (Test-Path -Path $classesRoot) {
    Get-ChildItem -Path $classesRoot -Filter '*.ps1' | ForEach-Object {
        . $_.FullName
    }
}

# Import Private functions
$privateRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Private'
if (Test-Path -Path $privateRoot) {
    Get-ChildItem -Path $privateRoot -Filter '*.ps1' | ForEach-Object {
        . $_.FullName
    }
}

# Import Public cmdlets
$publicRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Public'
if (Test-Path -Path $publicRoot) {
    Get-ChildItem -Path $publicRoot -Filter '*.ps1' | ForEach-Object {
        . $_.FullName
    }
}

$manifestPath = Join-Path -Path $PSScriptRoot -ChildPath 'SnipeitPS.psd1'
$loadedManifest = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop
$script:SnipeitModuleVersion = $loadedManifest.Version.ToString()

# Session variable for storing current session information (supports both dictionary and object properties)
$SnipeitPSSession = [ordered]@{
    'url'               = $null
    'apiKey'            = $null
    'throttleLimit'     = 0
    'throttleThreshold' = 0
    'throttleMode'      = $null
    'throttlePeriod'    = 0
    'throttledRequests' = [System.Collections.Generic.Queue[long]]::new()
}
New-Variable -Name SnipeitPSSession -Value $SnipeitPSSession -Scope Script -Force
$script:IsPowerShell7 = $PSVersionTable.PSVersion -ge '7.0'
$script:SnipeitApiPrefix = '/api/v1'

$ExecutionContext.SessionState.Module.OnRemove = {
    if ($script:SnipeitPSSession -is [System.Collections.IDictionary]) {
        $script:SnipeitPSSession.Clear()
    }
    [SnipeitCache]::Clear()
}
