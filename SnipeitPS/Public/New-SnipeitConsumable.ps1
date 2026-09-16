<#
.SYNOPSIS
Add a new Consumable to Snipe-IT asset system

.DESCRIPTION
Add a new Consumable to Snipe-IT asset system

.PARAMETER name
Required Name of the Consumable

.PARAMETER qty
Required Quantity of consumable

.PARAMETER category_id
Required Category ID of the Consumable, this can be obtained using Get-SnipeitCategory

.PARAMETER min_amt
Optional minimum quantity of consumable

.PARAMETER company_id
Optional Company ID

.PARAMETER order_number
Optional Order number

.PARAMETER manufacturer_id
Manufacturer ID number of the consumable

.PARAMETER location_id
Location ID number of the consumable

.PARAMETER requestable
Is consumable requestable?

.PARAMETER purchase_date
Optional Purchase date of the consumable

.PARAMETER purchase_cost
Optional Purchase cost of the consumable

.PARAMETER model_number
Model number of the consumable

.PARAMETER item_no
Item number for the consumable

.PARAMETER image
Consumable Image filename and path

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS


System.Management.Automation.PSCustomObject



.EXAMPLE
New-SnipeitConsumable -name "Ink pack" -qty 20 -category_id 3 -min_amt 5
Create consumable with stock count 20, alert when stock is 5 or lower

#>

function New-SnipeitConsumable() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true)]
        [string]$name,

        [parameter(mandatory = $true)]
        [int]$qty,

        [parameter(mandatory = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$category_id,

        [parameter(mandatory = $false)]
        [int]$min_amt,

        [parameter(mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$company_id,

        [parameter(mandatory = $false)]
        [string]$order_number,

        [parameter(mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$manufacturer_id,

        [parameter(mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$location_id,

        [parameter(mandatory = $false)]
        [Nullable[bool]]$requestable,

        [parameter(mandatory = $false)]
        [datetime]$purchase_date,

        [parameter(mandatory = $false)]
        [string]$purchase_cost,

        [parameter(mandatory = $false)]
        [string]$model_number,

        [parameter(mandatory = $false)]
        [string]$item_no,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        if ($Values['purchase_date']) {
            $Values['purchase_date'] = $Values['purchase_date'].ToString("yyyy-MM-dd")
        }

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/consumables"
            Method = 'Post'
            Session = $Session
            Body   = $Values
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("Consumable '$name'", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
