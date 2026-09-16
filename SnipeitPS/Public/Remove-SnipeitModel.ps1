<#
    .SYNOPSIS
    Removes Asset model from Snipe-IT asset system
    .DESCRIPTION
    Removes asset model or multiple asset models from Snipe-IT asset system
    .PARAMETER ID
    Unique ID for model to be removed
    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Remove-SnipeitModel -ID 44

    .EXAMPLE
    Get-SnipeitModel -search needle | Remove-SnipeitModel
#>

function Remove-SnipeitModel () {
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
        foreach($model_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/models/$model_id"
                Method = 'Delete'
                Session = $Session
            }

            if ($PSCmdlet.ShouldProcess("Model ID $model_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
