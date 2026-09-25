<#
.SYNOPSIS
Downloads a file attachment from Snipe-IT.

.DESCRIPTION
Downloads a file attachment for an allowlisted Snipe-IT entity type to a local destination file.
Ensures byte-preserving downloads, atomic file creation via temporary file, and overwrite protection.

.PARAMETER EntityType
The type of object the file is attached to. Supported types:
accessories, audits, assets, components, consumables, hardware, licenses, locations,
maintenances, models, suppliers, users, companies, departments.

.PARAMETER id
The ID of the parent entity.

.PARAMETER file_id
The ID of the file to download.

.PARAMETER OutFile
The local path where the file should be saved.

.PARAMETER Force
Overwrite the destination file if it already exists.

.PARAMETER inline
Requests inline disposition. The server only honors this for safe file extensions.
The file is still downloaded without changing its bytes.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.FileDownload

.EXAMPLE
Save-SnipeitFile -EntityType 'hardware' -id 100 -file_id 5 -OutFile 'C:\Docs\manual.pdf'
#>
function Save-SnipeitFile {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType('SnipeitPS.FileDownload')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('accessories', 'audits', 'assets', 'components', 'consumables', 'hardware', 'licenses', 'locations', 'maintenances', 'models', 'suppliers', 'users', 'companies', 'departments')]
        [string]$EntityType,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [int]$id,

        [Parameter(Mandatory = $true, Position = 2, ValueFromPipelineByPropertyName = $true)]
        [int]$file_id,

        [Parameter(Mandatory = $true, Position = 3)]
        [string]$OutFile,

        [switch]$Force,

        [switch]$inline,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ShouldProcess("Save file $file_id from $EntityType $id to $OutFile", "Save file")) {
            $activeSession = if ($null -ne $Session) { $Session } else { $script:SnipeitPSSession }
            $sessUrl = if ($activeSession -is [System.Collections.IDictionary]) { $activeSession['url'] } else { $activeSession.Url }
            if ($null -eq $sessUrl) {
                throw "Please use Connect-SnipeitPS to set up a connection before any other commands."
            }
            $baseUri = ([string]$sessUrl).TrimEnd('/')
            $fileUri = "$baseUri$script:SnipeitApiPrefix/$EntityType/$id/files/$file_id"
            if ($PSBoundParameters.ContainsKey('inline')) {
                $fileUri += ConvertTo-GetParameter -InputObject @{ inline = [bool]$inline }
            }

            Save-SnipeitApiFile -Uri $fileUri `
                                -OutFile $OutFile `
                                -EntityType $EntityType `
                                -Id $id `
                                -FileId $file_id `
                                -Force:$Force `
                                -Session $Session
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
