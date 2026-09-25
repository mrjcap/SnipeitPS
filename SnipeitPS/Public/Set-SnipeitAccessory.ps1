<#
.SYNOPSIS
Updates accessory on Snipe-IT system

.DESCRIPTION
Updates accessory on Snipe-IT system

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

        [string]$notes
    )

    begin {
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

