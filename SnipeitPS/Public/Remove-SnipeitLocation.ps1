<#
    .SYNOPSIS
    Removes Location from Snipe-IT asset system
    .DESCRIPTION
    Removes location or multiple locations from Snipe-IT asset system
    .PARAMETER ID
    Unique ID for location to be removed
    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Remove-SnipeitLocation -ID 44

    .EXAMPLE
    Get-SnipeitLocation -city Arkham | Remove-SnipeitLocation
#>

function Remove-SnipeitLocation () {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "High"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
}

    process {
        foreach($location_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/locations/$location_id"
                Method = 'Delete'
                Session = $Session
            }

            if ($PSCmdlet.ShouldProcess("Location ID $location_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
