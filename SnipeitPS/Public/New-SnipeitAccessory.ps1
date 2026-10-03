<#
.SYNOPSIS
Creates a new accessory on Snipe-IT system

.DESCRIPTION
Creates a new accessory on Snipe-IT system

.PARAMETER name
Accessory name

.PARAMETER qty
Quantity of the accessory you have

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

.PARAMETER min_amt
Min quantity of the accessory before alert is triggered

.PARAMETER image
Accessory image filename and path

.PARAMETER notes
Notes stored with the accessory.

.PARAMETER currency
Currency of the initial acquisition, up to 10 characters.

.PARAMETER default_supplier_id
Default supplier for future purchases, separate from the acquisition supplier. Accepts null.

.PARAMETER default_purchase_cost
Default cost for future purchases, separate from purchase_cost for the initial acquisition.
Accepts null or a value from 0 to 99999999999999999.99. Omit to leave the server default unchanged.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
New-SnipeitAccessory -name "Accessory" -qty 3 -category_id 1

.NOTES
company_id, location_id, min_amt, and purchase_date accept explicit null.
Unbound optional fields are omitted from the request.
#>
function New-SnipeitAccessory() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true)]
        [ValidateLength(3, 255)]
        [string]$name,

        [parameter(mandatory = $true)]
        [int]$qty,

        [parameter(mandatory = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitCategoryCompleter])]
        [int]$category_id,

        [ArgumentCompleter([SnipeitCompanyCompleter])]
        [Nullable[int]]$company_id,

        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitManufacturerCompleter])]
        [int]$manufacturer_id,

        [string]$order_number,

        [string]$model_number,

        [string]$purchase_cost,

        [Nullable[datetime]]$purchase_date,

        [Nullable[int]]$min_amt,

        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitSupplierCompleter])]
        [int]$supplier_id,

        [ArgumentCompleter([SnipeitLocationCompleter])]
        [Nullable[int]]$location_id,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [Nullable[bool]]$requestable,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [string]$notes,

        [ValidateLength(0, 10)]
        [string]$currency,

        [ArgumentCompleter([SnipeitSupplierCompleter])]
        [Nullable[int]]$default_supplier_id,

        [Nullable[decimal]]$default_purchase_cost
    )
    begin {
        if ($null -ne $default_purchase_cost -and ($default_purchase_cost -lt 0 -or $default_purchase_cost -gt 99999999999999999.99d)) {
            throw [ArgumentOutOfRangeException]::new('default_purchase_cost', 'Use a default cost from 0 to 99999999999999999.99, or null.')
        }
        foreach ($field in @('company_id', 'location_id', 'default_supplier_id')) {
            if ($null -ne $PSBoundParameters[$field] -and $PSBoundParameters[$field] -lt 1) {
                throw [System.ArgumentOutOfRangeException]::new($field, 'Use a positive ID or null.')
            }
        }
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        if ($values['purchase_date']) {
            $values['purchase_date'] = $values['purchase_date'].ToString("yyyy-MM-dd")
        }

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/accessories"
            Method = 'POST'
            Session = $Session
            Body   = $Values
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("Accessory '$name'", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}

