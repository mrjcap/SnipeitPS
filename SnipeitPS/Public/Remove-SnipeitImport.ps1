<#
.SYNOPSIS
Removes an uploaded import file from Snipe-IT.

.DESCRIPTION
Deletes an uploaded CSV/TSV import file and its associated database record in Snipe-IT.
Warning responses from the server (e.g., file could not be deleted or permission denied) are preserved as warnings, not treated as successful deletion.

.PARAMETER id
The ID(s) of the import file record(s) to remove.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
None

.EXAMPLE
Remove-SnipeitImport -id 10
#>
function Remove-SnipeitImport {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('import_id')]
        [int[]]$id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        foreach ($import_id in $id) {
            if ($PSCmdlet.ShouldProcess("Import ID $import_id", "Remove import")) {
                $activeSession = if ($null -ne $Session) { $Session } else { $script:SnipeitPSSession }
                $sessUrl = if ($activeSession -is [System.Collections.IDictionary]) { $activeSession['url'] } else { $activeSession.Url }
                if ($null -eq $sessUrl) {
                    throw "Please use Connect-SnipeitPS to set up a connection before any other commands."
                }
                $baseUri = ([string]$sessUrl).TrimEnd('/')
                $deleteUri = "$baseUri$script:SnipeitApiPrefix/imports/$import_id"

                $req = @{
                    Uri    = $deleteUri
                    Method = 'DELETE'
                }

                $raw = Invoke-SnipeitHttpRequest -Request $req -Session $Session
                ConvertFrom-SnipeitApiResponse -Response $raw -ResponseKind 'StandardEnvelope'
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
