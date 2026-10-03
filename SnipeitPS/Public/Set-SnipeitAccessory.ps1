<#
.SYNOPSIS
Updates accessory on Snipe-IT system

.DESCRIPTION
Updates accessory on Snipe-IT system. qty is an absolute stock count.
Legacy acquisition parameters remain on the wire for older servers. On the current API,
metadata-only updates do not edit purchase history. A positive qty difference can create
an acquisition using unit_cost and order metadata. Use Invoke-SnipeitQuantityAdjustment
for an explicit signed adjustment or receipt.

.PARAMETER id
An ID of a specific resource to update

.PARAMETER name
Accessory name

.PARAMETER qty
Quantity of the accessory you have

.PARAMETER min_amt
Minimum amount of the accessory, before alert is triggered

.PARAMETER category_id
ID number of the category the accessory belongs to

.PARAMETER company_id
ID Number of the company the accessory is assigned to

.PARAMETER manufacturer_id
ID number of the manufacturer for this accessory.

.PARAMETER model_number
Model number for this accessory

.PARAMETER order_number
Order number for this accessory.

.PARAMETER purchase_cost
Cost of item being purchased.

.PARAMETER purchase_date
Date accessory was purchased

.PARAMETER supplier_id
ID number of the supplier for this accessory

.PARAMETER location_id
ID number of the location the accessory is assigned to

.PARAMETER image
Image file name and path for item

.PARAMETER image_delete
Remove current image

.PARAMETER RequestType
HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

.PARAMETER notes
Notes stored with the accessory. An empty string clears them.

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
Set-SnipeitAccessory -id 1 -qty 3

#>
function Set-SnipeitAccessory() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [ValidateLength(3, 255)]
        [string]$name,

        [int]$qty,

        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitCategoryCompleter])]
        [int]$category_id,

        [ArgumentCompleter([SnipeitCompanyCompleter])]
        [Nullable[System.Int32]]$company_id,

        [ArgumentCompleter([SnipeitManufacturerCompleter])]
        [Nullable[System.Int32]]$manufacturer_id,

        [string]$model_number,

        [string]$order_number,

        [string]$purchase_cost,

        [Nullable[datetime]]$purchase_date,

        [Nullable[System.Int32]]$min_amt,

        [ArgumentCompleter([SnipeitSupplierCompleter])]
        [Nullable[System.Int32]]$supplier_id,

        [ArgumentCompleter([SnipeitLocationCompleter])]
        [Nullable[System.Int32]]$location_id,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [Nullable[bool]]$requestable,

        [switch]$image_delete=$false,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

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
        foreach($accessory_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/accessories/$accessory_id"
                Method = $RequestType
                Session = $Session
                Body   = $Values.Clone()
            }

            if ($PSCmdlet.ShouldProcess("Accessory ID $accessory_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
       }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}

