<#
.SYNOPSIS
Downloads a Snipe-IT backup file

.PARAMETER filename
The filename of the backup to download

.PARAMETER path
The directory path where the backup file will be saved

.PARAMETER url
Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipeit system.

.PARAMETER apiKey
Deprecated parameter, please use Connect-SnipeitPS instead. Users API Key for Snipeit.

.EXAMPLE
Save-SnipeitBackup -filename "2024-01-15-backup.sql" -path "C:\Backups"

#>

function Save-SnipeitBackup() {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    Param(
        [parameter(mandatory = $true)]
        [ValidateScript({$_ -notmatch '[\\/]' -and $_ -notmatch '\.\.'})]
        [string]$filename,

        [parameter(mandatory = $true)]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string]$path,

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )
    begin {
        Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

        if ($PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Write-Warning "-apiKey parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyApiKey -apiKey $apikey
        }

        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url) {
            Write-Warning "-url parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyUrl -url $url
        }

        # Resolve auth the same way Invoke-SnipeitMethod does
        if ( $null -ne $SnipeitPSSession.legacyUrl -and $null -ne $SnipeitPSSession.legacyApiKey ) {
            [string]$Url = $SnipeitPSSession.legacyUrl
            $Token = (New-Object PSCredential "user",$SnipeitPSSession.legacyApiKey).GetNetworkCredential().Password
        } elseif ($null -ne $SnipeitPSSession.url -and $null -ne $SnipeitPSSession.apiKey) {
            [string]$Url = $SnipeitPSSession.url
            $Token = (New-Object PSCredential "user",$SnipeitPSSession.apiKey).GetNetworkCredential().Password
        } else {
            throw "Please use Connect-SnipeitPS to setup connection before any other commands."
        }
    }

    process {
        $apiUri = "$Url/api/v1/settings/backups/download/$filename"
        $outFile = Join-Path $path $filename

        if ($PSCmdlet.ShouldProcess($filename, "Download backup")) {
            try {
                $splatParameters = @{
                    Uri             = $apiUri
                    Method          = 'Get'
                    Headers         = @{
                        "Authorization" = "Bearer $Token"
                        "Accept"        = "application/octet-stream"
                    }
                    OutFile         = $outFile
                    UseBasicParsing = $true
                    ErrorAction     = 'Stop'
                }

                Invoke-RestMethod @splatParameters

                [PSCustomObject]@{
                    status   = "success"
                    filename = $filename
                    path     = $outFile
                }
            }
            catch {
                Write-Error "Failed to download backup '$filename': $_"
            }
        }
    }

    end {
        # reset legacy sessions
        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url -or $PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Reset-SnipeitPSLegacyApi
        }
    }
}
