function Reset-SnipeitPSLegacyApi {
    [CmdletBinding()]
    param()
    process {
        Write-Verbose 'Reset-SnipeitPSLegacyApi'
        $SnipeitPSSession.legacyUrl = $null
        $SnipeitPSSession.legacyApiKey = $null
    }
}
