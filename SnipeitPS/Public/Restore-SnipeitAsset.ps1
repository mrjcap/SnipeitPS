<#
    .SYNOPSIS
    Restores a deleted asset in Snipe-IT

    .PARAMETER id
    Unique IDs for assets to restore

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Restore-SnipeitAsset -id 1
#>
function Restore-SnipeitAsset() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin{
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
}

    process{
        foreach($asset_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/hardware/$asset_id/restore"
                Method = 'POST'
                Session = $Session
                Body   = @{}
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
