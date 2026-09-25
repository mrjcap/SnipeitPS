<#
.SYNOPSIS
Updates component

.DESCRIPTION
Updates component on Snipe-IT system

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
        [int]$category_id
    )
    begin {
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
