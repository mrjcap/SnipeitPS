<#
.SYNOPSIS
Uploads an import file to Snipe-IT.

.DESCRIPTION
Uploads a CSV, TSV, or TXT file to Snipe-IT for subsequent import processing.
Files are uploaded individually using multipart/form-data with field name 'files[]'.

.PARAMETER File
Path(s) or FileInfo object(s) representing the file(s) to upload.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
New-SnipeitImport -File 'C:\Data\assets.csv'
#>
function New-SnipeitImport {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName', 'Path', 'Files')]
        [object[]]$File,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        foreach ($item in $File) {
            $path = if ($item -is [System.IO.FileInfo]) { $item.FullName } else { [string]$item }
            if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
                throw [System.IO.FileNotFoundException]::new("Cannot find path '$path' because it does not exist.", $path)
            }
            $resolvedPath = (Resolve-Path -LiteralPath $path).Path

            if ($PSCmdlet.ShouldProcess("Upload import file '$resolvedPath'", "Upload import file")) {
                $activeSession = if ($null -ne $Session) { $Session } else { $script:SnipeitPSSession }
                $sessUrl = if ($activeSession -is [System.Collections.IDictionary]) { $activeSession['url'] } else { $activeSession.Url }
                if ($null -eq $sessUrl) {
                    throw "Please use Connect-SnipeitPS to set up a connection before any other commands."
                }
                $baseUri = ([string]$sessUrl).TrimEnd('/')
                $uploadUri = "$baseUri$script:SnipeitApiPrefix/imports"

                Send-SnipeitMultipart -Uri $uploadUri `
                                      -Files @($resolvedPath) `
                                      -FileFieldName 'files[]' `
                                      -Session $Session
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
