function Set-SnipeitPSLegacyApiKey {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    param(
        [string]$apiKey
    )
    process {
        if ($PSCmdlet.ShouldProcess("ShouldProcess?")) {
            if($script:IsPowerShell7){
                $convertParams = @{
                    AsPlainText = $true
                    String      = $apiKey
                }
                $SnipeitPSSession.legacyApiKey = ConvertTo-SecureString @convertParams
            } else {
                $convertParams = @{
                    Force       = $true
                    AsPlainText = $true
                    String      = $apiKey
                }
                $SnipeitPSSession.legacyApiKey = ConvertTo-SecureString @convertParams
            }
        }
    }
}
