<#
    .SYNOPSIS
    Removes manufacturer from Snipe-IT asset system
    .DESCRIPTION
    Removes manufacturer or multiple manufacturers from Snipe-IT asset system
    .PARAMETER ID
    Unique ID for manufacturer to be removed
    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Remove-SnipeitManufacturer -ID 44

    .EXAMPLE
    Get-SnipeitManufacturer | Where-object {$_.name -like '*something*'} | Remove-SnipeitManufacturer
#>

function Remove-SnipeitManufacturer () {
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
        foreach($manufacturer_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/manufacturers/$manufacturer_id"
                Method = 'Delete'
                Session = $Session
            }

            if ($PSCmdlet.ShouldProcess("Manufacturer ID $manufacturer_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }

    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
