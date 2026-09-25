<#
.SYNOPSIS
Restores a deleted manufacturer.

.DESCRIPTION
Restores a soft-deleted manufacturer via POST /api/v1/manufacturers/{id}/restore.
Requires delete authorization on the server.

.PARAMETER id
Unique ID(s) of the manufacturer(s) to restore.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Restore-SnipeitManufacturer -id 5
#>
function Restore-SnipeitManufacturer {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High'
    )]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        foreach ($mId in $id) {
            if ($PSCmdlet.ShouldProcess("Manufacturer ID $mId", $MyInvocation.MyCommand.Name)) {
                $Parameters = @{
                    Route       = "$script:SnipeitApiPrefix/manufacturers/{id}/restore"
                    RouteTokens = @{ id = $mId }
                    Method      = 'Post'
                    Session     = $Session
                    Body        = @{}
                }

                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
