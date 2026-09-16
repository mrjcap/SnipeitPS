<#
    .SYNOPSIS
    Removes Accessory from Snipe-IT asset system
    .DESCRIPTION
    Removes Accessory or multiple Accessories from Snipe-IT asset system
    .PARAMETER ID
    Unique ID for accessory to be removed
    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Remove-SnipeitAccessory -ID 44 -Verbose

    .EXAMPLE
    Get-SnipeitAccessory -search needle | Remove-SnipeitAccessory
#>

function Remove-SnipeitAccessory () {
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
        foreach($accessory_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/accessories/$accessory_id"
                Method = 'Delete'
                Session = $Session
            }

            if ($PSCmdlet.ShouldProcess("Accessory ID $accessory_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
