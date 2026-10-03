<#
.SYNOPSIS
Update a Consumable on Snipe-IT asset system

.DESCRIPTION
Updates a consumable on Snipe-IT. qty is an absolute stock count.
Legacy acquisition parameters remain on the wire for older servers. On the current API,
metadata-only updates do not edit purchase history. A positive qty difference can create
an acquisition using unit_cost and order metadata. Use Invoke-SnipeitQuantityAdjustment
for an explicit signed adjustment or receipt.

.PARAMETER id
Optional ID number of the Consumable

.PARAMETER name
Optional Name of the Consumable

.PARAMETER qty
Optional Quantity of consumable

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
Image file name and path for item

.PARAMETER image_delete
Remove current image

.PARAMETER RequestType
HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

.PARAMETER supplier_id
ID of the supplier. Pass $null to clear it.

.PARAMETER notes
Notes stored with the consumable.

.PARAMETER unit_cost
Per-unit cost used when qty increases on the current API. Historical purchase_cost is not used for this adjustment.

.PARAMETER currency
Currency for an acquisition caused by a positive qty difference.

.PARAMETER note
Reason for a qty change. The server generates one when omitted.

.PARAMETER default_supplier_id
Default supplier for future purchases, separate from historical acquisition suppliers. Accepts null.

.PARAMETER default_purchase_cost
Default cost for future purchases, separate from unit_cost and historical purchase_cost.
Accepts null or a value from 0 to 99999999999999999.99. Omit to leave the stored default unchanged.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS


System.Management.Automation.PSCustomObject



.EXAMPLE
Set-SnipeitConsumable -id 1 -name "Ink pack" -qty 20 -category_id 3 -min_amt 5
Update consumable with stock count 20, alert when stock is 5 or lower

#>

function Set-SnipeitConsumable() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [parameter(mandatory = $false)]
        [string]$name,

        [parameter(mandatory = $false)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$qty,

        [parameter(mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$category_id,

        [parameter(mandatory = $false)]
        [Nullable[System.Int32]]$min_amt,

        [parameter(mandatory = $false)]
        [Nullable[System.Int32]]$company_id,

        [parameter(mandatory = $false)]
        [string]$order_number,

        [parameter(mandatory = $false)]
        [Nullable[System.Int32]]$manufacturer_id,

        [parameter(mandatory = $false)]
        [Nullable[System.Int32]]$location_id,

        [parameter(mandatory = $false)]
        [Nullable[bool]]$requestable,

        [parameter(mandatory = $false)]
        [Nullable[datetime]]$purchase_date,

        [parameter(mandatory = $false)]
        [string]$purchase_cost,

        [parameter(mandatory = $false)]
        [string]$model_number,

        [parameter(mandatory = $false)]
        [string]$item_no,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [switch]$image_delete=$false,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [ArgumentCompleter([SnipeitSupplierCompleter])]
        [Nullable[int]]$supplier_id,

        [string]$notes,

        [Nullable[decimal]]$unit_cost,

        [ValidateLength(0, 10)]
        [string]$currency,

        [ValidateLength(0, 65535)]
        [string]$note,

        [ArgumentCompleter([SnipeitSupplierCompleter])]
        [Nullable[int]]$default_supplier_id,

        [Nullable[decimal]]$default_purchase_cost
    )
    begin {
        if ($null -ne $default_purchase_cost -and ($default_purchase_cost -lt 0 -or $default_purchase_cost -gt 99999999999999999.99d)) {
            throw [ArgumentOutOfRangeException]::new('default_purchase_cost', 'Use a default cost from 0 to 99999999999999999.99, or null.')
        }
        if ($null -ne $unit_cost -and ($unit_cost -lt 0 -or $unit_cost -gt 9999999999999999.9999d)) {
            throw [ArgumentOutOfRangeException]::new('unit_cost', 'Use a nonnegative acquisition cost within the server limit, or null.')
        }
        if ($null -ne $default_supplier_id -and $default_supplier_id -lt 1) {
            throw [ArgumentOutOfRangeException]::new('default_supplier_id', 'Use a positive supplier ID or null.')
        }
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        if ($Values['purchase_date']) {
            $Values['purchase_date'] = $Values['purchase_date'].ToString("yyyy-MM-dd")
        }
    }

    process {
        foreach($consumable_id in $id ) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/consumables/$consumable_id"
                Method = $RequestType
                Session = $Session
                Body   = $Values.Clone()
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
