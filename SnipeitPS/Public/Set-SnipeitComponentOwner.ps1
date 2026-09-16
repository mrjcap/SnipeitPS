<#
    .SYNOPSIS
    Checkout a component to an asset in Snipe-IT

    .PARAMETER id
    Unique IDs for components to checkout

    .PARAMETER assigned_to
    The asset ID to checkout the component to

    .PARAMETER assigned_qty
    Quantity of the component to checkout

    .PARAMETER note
    Notes about checkout

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Set-SnipeitComponentOwner -id 1 -assigned_to 100 -assigned_qty 2
#>
function Set-SnipeitComponentOwner() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [parameter(mandatory = $true)]
        [int]$assigned_to,

        [parameter(mandatory = $true)]
        [int]$assigned_qty,

        [string]$note,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin{
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
    }

    process{
        foreach($component_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/components/$component_id/checkout"
                Method = 'POST'
                Session = $Session
                Body   = $Values
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
