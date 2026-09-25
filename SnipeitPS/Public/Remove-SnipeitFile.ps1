<#
.SYNOPSIS
Removes a file attachment from an entity in Snipe-IT.

.DESCRIPTION
Deletes a file attachment from an allowlisted Snipe-IT entity. Note that audits files cannot be deleted
by the API and audits is excluded from the allowed entity types.

.PARAMETER EntityType
The type of object to remove the file from. Supported types:
accessories, assets, components, consumables, hardware, licenses, locations,
maintenances, models, suppliers, users, companies, departments.

.PARAMETER id
ID(s) of the parent entity. Accepts pipeline input by property name.

.PARAMETER file_id
ID(s) of the file to remove. Accepts pipeline input by property name.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Remove-SnipeitFile -EntityType 'hardware' -id 1 -file_id 10
#>
function Remove-SnipeitFile {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('accessories', 'assets', 'components', 'consumables', 'hardware', 'licenses', 'locations', 'maintenances', 'models', 'suppliers', 'users', 'companies', 'departments')]
        [string]$EntityType,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [int[]]$id,

        [Parameter(Mandatory = $true, Position = 2, ValueFromPipelineByPropertyName = $true)]
        [int[]]$file_id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        foreach ($singleId in $id) {
            foreach ($singleFileId in $file_id) {
                if ($PSCmdlet.ShouldProcess("Remove file $singleFileId from $EntityType $singleId", "Remove file")) {
                    $params = @{
                        Route         = '/api/v1/{object_type}/{id}/files/{file_id}/delete'
                        PathParameter = @{
                            object_type = $EntityType
                            id          = $singleId
                            file_id     = $singleFileId
                        }
                        Method        = 'DELETE'
                        Session       = $Session
                    }
                    Invoke-SnipeitMethod @params
                }
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
