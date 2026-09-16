function Reset-SnipeitPSLegacyApi {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    param()
    process {
        if ($PSCmdlet.ShouldProcess("Legacy API Session", "Reset")) {
            Write-Verbose 'Reset-SnipeitPSLegacyApi'
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
        }
    }
}
