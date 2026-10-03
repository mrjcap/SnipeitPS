<#
.SYNOPSIS
Updates component

.DESCRIPTION
Updates component on Snipe-IT system. qty is an absolute stock count.
Legacy acquisition parameters remain on the wire for older servers. On the current API,
metadata-only updates do not edit purchase history. A positive qty difference can create
an acquisition using unit_cost and order metadata. Use Invoke-SnipeitQuantityAdjustment
for an explicit signed adjustment or receipt.

.PARAMETER id
ID number of component or array of IDs

.PARAMETER name
Component name

.PARAMETER qty
Quantity of the components you have

.PARAMETER min_amt
Minimum Quantity of the components before alert is triggered

.PARAMETER company_id
Company ID to associate with the component

.PARAMETER location_id
ID number of the location the component is assigned to

.PARAMETER order_number
Order number for the component

.PARAMETER purchase_date
Date component was purchased

.PARAMETER purchase_cost
Cost of item being purchased.

.PARAMETER image
Image file name and path for item

.PARAMETER image_delete
Remove current image

.PARAMETER RequestType
HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

.PARAMETER supplier_id
ID of the supplier. Pass $null to clear it.

.PARAMETER manufacturer_id
ID of the manufacturer. Pass $null to clear it.

.PARAMETER model_number
Manufacturer's model number.

.PARAMETER serial
Serial number recorded for the component.

.PARAMETER notes
Notes stored with the component.

.PARAMETER category_id
ID of the category to assign to the component.

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

.PARAMETER requestable
Whether users can request this component. Accepts true, false, or null.
Omit to leave the stored value unchanged.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Set-SnipeitComponent -id 42 -qty 12
Sets count of component with ID 42 to 12

#>
function Set-SnipeitComponent() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [parameter(mandatory = $false)]
        [int]$qty,

        [Nullable[System.Int32]]$min_amt,

        [string]$name,

        [Nullable[System.Int32]]$company_id,

        [Nullable[System.Int32]]$location_id,


        [string]$order_number,

        [Nullable[datetime]]$purchase_date,

        [string]$purchase_cost,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [switch]$image_delete=$false,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [ArgumentCompleter([SnipeitSupplierCompleter])]
        [Nullable[int]]$supplier_id,

        [ArgumentCompleter([SnipeitManufacturerCompleter])]
        [Nullable[int]]$manufacturer_id,

        [string]$model_number,

        [string]$serial,

        [string]$notes,

        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitCategoryCompleter])]
        [int]$category_id,

        [Nullable[decimal]]$unit_cost,

        [ValidateLength(0, 10)]
        [string]$currency,

        [ValidateLength(0, 65535)]
        [string]$note,

        [ArgumentCompleter([SnipeitSupplierCompleter])]
        [Nullable[int]]$default_supplier_id,

        [Nullable[decimal]]$default_purchase_cost,

        [Nullable[bool]]$requestable
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
        foreach($component_id in $id) {
        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/components/$component_id"
            Method = $RequestType
            Session = $Session
            Body   = $Values.Clone()
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
