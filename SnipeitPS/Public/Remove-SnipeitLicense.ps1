<#
    .SYNOPSIS
    Removes license from Snipe-IT asset system
    .DESCRIPTION
    Removes license or multiple licenses from Snipe-IT asset system
    .PARAMETER ID
    Unique ID for license to be removed
    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Remove-SnipeitLicense -ID 44

    .EXAMPLE
    Get-SnipeitLicense -product_key 123456789 | Remove-SnipeitLicense
#>

function Remove-SnipeitLicense () {
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
        foreach($license_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/licenses/$license_id"
                Method = 'Delete'
                Session = $Session
            }

            if ($PSCmdlet.ShouldProcess("License ID $license_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
