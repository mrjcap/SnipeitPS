<#
    .SYNOPSIS
    Removes component from Snipe-IT asset system
    .DESCRIPTION
    Removes component or multiple components from Snipe-IT asset system
    .PARAMETER id
    Unique ID for component to be removed
    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Remove-SnipeitComponent -ID 44

    .EXAMPLE
    Get-SnipeitComponent -search 123456789 | Remove-SnipeitComponent
#>

function Remove-SnipeitComponent () {
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
        foreach($component_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/components/$component_id"
                Method = 'Delete'
                Session = $Session
            }

            if ($PSCmdlet.ShouldProcess("Component ID $component_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
