<#
.SYNOPSIS
Downloads a Snipe-IT backup file

.PARAMETER filename
The filename of the backup to download

.PARAMETER path
The directory path where the backup file will be saved

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Save-SnipeitBackup -filename "2024-01-15-backup.sql" -path "C:\Backups"

#>

function Save-SnipeitBackup() {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(mandatory = $true)]
        [ValidateScript({$_ -notmatch '[\\/]' -and $_ -notmatch '\.\.'})]
        [string]$filename,

        [parameter(mandatory = $true)]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string]$path,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        $activeSession = if ($null -ne $Session) { $Session } else { $SnipeitPSSession }

        if ($activeSession -is [System.Collections.IDictionary]) {
            $sessionUrl = $activeSession['url']
            $sessionApiKey = $activeSession['apiKey']
            if ($null -ne $activeSession['legacyUrl'] -and $null -ne $activeSession['legacyApiKey']) {
                $sessionUrl = $activeSession['legacyUrl']
                $sessionApiKey = $activeSession['legacyApiKey']
            }
        } else {
            $sessionUrl = $activeSession.Url
            $sessionApiKey = $activeSession.ApiKey
        }

        if ($null -ne $sessionUrl -and $null -ne $sessionApiKey) {
            [string]$Url = ([string]$sessionUrl).TrimEnd('/')
            $Token = (New-Object PSCredential "user",$sessionApiKey).GetNetworkCredential().Password
        } else {
            throw "Please use Connect-SnipeitPS to set up a connection before any other commands."
        }
    }

    process {
        $escapedFilename = [Uri]::EscapeDataString($filename)
        $apiUri = "$Url$script:SnipeitApiPrefix/settings/backups/download/$escapedFilename"
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
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
