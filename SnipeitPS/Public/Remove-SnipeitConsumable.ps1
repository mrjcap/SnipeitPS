<#
    .SYNOPSIS
    Removes consumable from Snipe-IT asset system
    .DESCRIPTION
    Removes consumable or multiple consumables from Snipe-IT asset system
    .PARAMETER ID
    Unique ID for consumable to be removed

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Remove-SnipeitConsumable -ID 44

    .EXAMPLE
    Get-SnipeitConsumable -search "paper" | Remove-SnipeitConsumable
#>

function Remove-SnipeitConsumable () {
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
        foreach($consumable_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/consumables/$consumable_id"
                Method = 'Delete'
                Session = $Session
            }

            if ($PSCmdlet.ShouldProcess("Consumable ID $consumable_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
