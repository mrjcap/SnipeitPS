<#
    .SYNOPSIS
    Checkout a consumable to a user in Snipe-IT

    .PARAMETER id
    Unique IDs for consumables to checkout

    .PARAMETER assigned_to
    The user ID to checkout the consumable to

    .PARAMETER checkout_qty
    Quantity of the consumable to checkout

    .PARAMETER note
    Notes about checkout

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Set-SnipeitConsumableOwner -id 1 -assigned_to 100
#>
function Set-SnipeitConsumableOwner() {
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

        [int]$checkout_qty,

        [string]$note,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin{
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
    }

    process{
        foreach($consumable_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/consumables/$consumable_id/checkout"
                Method = 'POST'
                Session = $Session
                Body   = $Values
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
