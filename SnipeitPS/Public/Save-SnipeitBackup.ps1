<#
.SYNOPSIS
Downloads a Snipe-IT backup file or the latest backup.

.DESCRIPTION
Downloads either a specific backup file by name via GET /api/v1/settings/backups/download/{file}
or the most recent backup via GET /api/v1/settings/backups/download/latest. Requires superuser privileges.
Downloads over HTTPS with redirects disabled. An existing destination is replaced atomically only after a successful
transfer; failed transfers leave it unchanged.

.PARAMETER filename
The filename of the backup to download.

.PARAMETER path
The directory path where the backup file will be saved.

.PARAMETER Latest
When specified, downloads the most recent backup archive from the Snipe-IT server.

.PARAMETER OutFileName
Optional custom filename to use when saving the latest backup. Defaults to latest-backup.zip.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Save-SnipeitBackup -filename "2024-01-15-backup.sql" -path "C:\Backups"

.EXAMPLE
Save-SnipeitBackup -Latest -path "C:\Backups"
#>
function Save-SnipeitBackup {
    [CmdletBinding(
        DefaultParameterSetName = 'ByFilename',
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium'
    )]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(ParameterSetName = 'ByFilename', Mandatory = $true, Position = 0)]
        [ValidateScript({ $_ -notmatch '[\\/]' -and $_ -notmatch '\.\.' })]
        [string]$filename,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateScript({ Test-Path $_ -PathType Container })]
        [string]$path,

        [Parameter(ParameterSetName = 'Latest', Mandatory = $true)]
        [switch]$Latest,

        [Parameter(ParameterSetName = 'Latest', Mandatory = $false)]
        [ValidateScript({ $_ -notmatch '[\\/]' -and $_ -notmatch '\.\.' })]
        [string]$OutFileName,

        [Parameter(Mandatory = $false, Position = 2)]
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
            $downloadSession = @{ url = $sessionUrl; apiKey = $sessionApiKey }
        } else {
            throw "Please use Connect-SnipeitPS to set up a connection before any other commands."
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Latest') {
            $targetName = if ($PSBoundParameters.ContainsKey('OutFileName')) { $OutFileName } else { 'latest-backup.zip' }
            $apiUri = "$Url$script:SnipeitApiPrefix/settings/backups/download/latest"
            $outFile = Join-Path $path $targetName
        } else {
            $targetName = $filename
            $escapedFilename = [Uri]::EscapeDataString($filename)
            $apiUri = "$Url$script:SnipeitApiPrefix/settings/backups/download/$escapedFilename"
            $outFile = Join-Path $path $filename
        }

        if ($PSCmdlet.ShouldProcess($targetName, "Download backup")) {
            try {
                $download = Save-SnipeitApiFile -Uri $apiUri -OutFile $outFile -Force -Session $downloadSession

                [PSCustomObject]@{
                    PSTypeName  = 'SnipeitPS.BackupDownload'
                    status      = "success"
                    filename    = $targetName
                    path        = $outFile
                    Length      = $download.Length
                    ContentType = $download.ContentType
                }
            }
            catch {
                Write-Error "Failed to download backup '$targetName': $_"
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
