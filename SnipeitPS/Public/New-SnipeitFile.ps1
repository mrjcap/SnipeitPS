<#
.SYNOPSIS
Uploads a file attachment to an entity in Snipe-IT.

.DESCRIPTION
Attaches one or more files to an allowlisted Snipe-IT entity using multipart/form-data upload.
Preserves raw binary bytes and Unicode filenames.

.PARAMETER EntityType
The type of object to upload files to. Supported types:
accessories, audits, assets, components, consumables, hardware, licenses, locations,
maintenances, models, suppliers, users, companies, departments.

.PARAMETER id
The ID of the parent entity to attach files to.

.PARAMETER File
Path(s) or FileInfo object(s) of the file(s) to upload.

.PARAMETER notes
Optional notes associated with the uploaded file(s).

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
New-SnipeitFile -EntityType 'hardware' -id 100 -File 'C:\Docs\manual.pdf' -notes 'Hardware manual'
#>
function New-SnipeitFile {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('accessories', 'audits', 'assets', 'components', 'consumables', 'hardware', 'licenses', 'locations', 'maintenances', 'models', 'suppliers', 'users', 'companies', 'departments')]
        [string]$EntityType,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [int]$id,

        [Parameter(Mandatory = $true, Position = 2)]
        [Alias('Files')]
        [object[]]$File,

        [Parameter(Mandatory = $false)]
        [string]$notes,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        # Fail fast if file paths do not exist before making HTTP requests
        $resolvedFiles = [System.Collections.Generic.List[string]]::new()
        foreach ($item in $File) {
            $path = if ($item -is [System.IO.FileInfo]) { $item.FullName } else { [string]$item }
            if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
                throw [System.IO.FileNotFoundException]::new("Cannot find path '$path' because it does not exist.", $path)
            }
            $resolvedFiles.Add((Resolve-Path -LiteralPath $path).Path)
        }

        if ($PSCmdlet.ShouldProcess("Upload file(s) to $EntityType $id", "Upload file")) {
            $activeSession = if ($null -ne $Session) { $Session } else { $script:SnipeitPSSession }
            $sessUrl = if ($activeSession -is [System.Collections.IDictionary]) { $activeSession['url'] } else { $activeSession.Url }
            if ($null -eq $sessUrl) {
                throw "Please use Connect-SnipeitPS to set up a connection before any other commands."
            }
            $baseUri = ([string]$sessUrl).TrimEnd('/')
            $uploadUri = "$baseUri$script:SnipeitApiPrefix/$EntityType/$id/files"

            $fields = @{}
            if ($PSBoundParameters.ContainsKey('notes') -and $null -ne $notes) {
                $fields['notes'] = $notes
            }

            Send-SnipeitMultipart -Uri $uploadUri `
                                  -Files $resolvedFiles.ToArray() `
                                  -Fields $fields `
                                  -FileFieldName 'file[]' `
                                  -Session $Session
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
