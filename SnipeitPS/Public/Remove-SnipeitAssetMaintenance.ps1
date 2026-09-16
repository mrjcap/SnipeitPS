<#
    .SYNOPSIS
    Remove asset maintenance from Snipe-IT asset system

    .DESCRIPTION
    Removes asset maintenance event or events from Snipe-IT asset system by ID

    .PARAMETER ID
    Unique ID of the asset maintenance to be removed

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Remove-SnipeitAssetMaintenance -ID 44
#>
function Remove-SnipeitAssetMaintenance {

    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "High"
    )]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]
        $id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
}

    process {
        foreach($maintenance_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/maintenances/$maintenance_id"
                Method = 'Delete'
                Session = $Session
            }

            if ($PSCmdlet.ShouldProcess("Maintenance ID $maintenance_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
