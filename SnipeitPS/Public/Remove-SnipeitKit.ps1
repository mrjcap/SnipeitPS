<#
.SYNOPSIS
Removes a predefined kit from Snipe-IT.

.DESCRIPTION
Deletes an existing predefined kit from Snipe-IT, automatically detaching all associated
models, licenses, consumables, and accessories. Confirmation impact is High.

.PARAMETER id
The ID(s) of the kit(s) to remove.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Remove-SnipeitKit -id 5
#>
function Remove-SnipeitKit {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [int[]]$id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        foreach ($kit_id in $id) {
            if ($PSCmdlet.ShouldProcess("Kit ID $kit_id", "Remove kit")) {
                $params = @{
                    Route   = "/api/v1/kits/$kit_id"
                    Method  = 'DELETE'
                    Session = $Session
                }
                Invoke-SnipeitMethod @params
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
