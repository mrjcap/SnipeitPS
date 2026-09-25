<#
.SYNOPSIS
Removes a depreciation schedule from Snipe-IT.

.DESCRIPTION
Deletes an existing depreciation schedule from Snipe-IT. Note that depreciations currently
associated with one or more models cannot be deleted until those associations are removed.
Confirmation impact is High.

.PARAMETER id
The ID(s) of the depreciation schedule(s) to remove.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Remove-SnipeitDepreciation -id 5

.EXAMPLE
Get-SnipeitDepreciation -search "Old Schedule" | Remove-SnipeitDepreciation
#>
function Remove-SnipeitDepreciation {
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
        foreach ($dep_id in $id) {
            if ($PSCmdlet.ShouldProcess("Depreciation ID $dep_id", "Remove depreciation")) {
                $params = @{
                    Route   = "/api/v1/depreciations/$dep_id"
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
