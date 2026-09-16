<#
    .SYNOPSIS
    Removes Asset from Snipe-IT asset system
    .DESCRIPTION
    Removes asset or multiple assets from Snipe-IT asset system
    .PARAMETER ID
    Unique ID for asset to be removed
    .OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Remove-SnipeitAsset -ID 44 -Verbose

    .EXAMPLE
    Get-SnipeitAsset -serial 123456789 | Remove-SnipeitAsset
#>

function Remove-SnipeitAsset () {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "High"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [parameter(mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
}

    process {
        foreach($asset_id in $id) {
            $Parameters = @{
                Api     = "$script:SnipeitApiPrefix/hardware/$asset_id"
                Method  = 'Delete'
                Session = $Session
            }

            if ($PSCmdlet.ShouldProcess("Asset ID $asset_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
