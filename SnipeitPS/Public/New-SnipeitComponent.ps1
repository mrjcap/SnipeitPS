<#
.SYNOPSIS
Create a new component

.DESCRIPTION
Creates a new component on Snipe-IT system

.PARAMETER name
Component name

.PARAMETER category_id
ID number of category

.PARAMETER qty
Quantity of the components you have

.PARAMETER company_id
ID number of company

.PARAMETER location_id
ID number of the location the component is assigned to

.PARAMETER order_number
Order number of the component

.PARAMETER purchase_date
Date component was purchased

.PARAMETER purchase_cost
Cost of item being purchased.

.PARAMETER image
Component image filename and path

.PARAMETER supplier_id
ID of the supplier associated with the component.

.PARAMETER manufacturer_id
ID of the component manufacturer.

.PARAMETER model_number
Manufacturer's model number.

.PARAMETER serial
Serial number recorded for the component.

.PARAMETER notes
Notes stored with the component.

.PARAMETER min_amt
Minimum stock quantity used for inventory alerts.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
New-SnipeitComponent -name 'Display adapter' -category_id 3 -qty 10


.NOTES
company_id, location_id, and purchase_date accept explicit null.
Unbound optional fields are omitted from the request.
#>

function New-SnipeitComponent() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true)]
        [string]$name,

        [parameter(mandatory = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$category_id,

        [parameter(mandatory = $true)]
        [int]$qty,

        [Nullable[int]]$company_id,

        [Nullable[int]]$location_id,

        [string]$order_number,

        [Nullable[datetime]]$purchase_date,

        [string]$purchase_cost,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [ArgumentCompleter([SnipeitSupplierCompleter])]
        [Nullable[int]]$supplier_id,

        [ArgumentCompleter([SnipeitManufacturerCompleter])]
        [Nullable[int]]$manufacturer_id,

        [string]$model_number,

        [string]$serial,

        [string]$notes,

        [Nullable[int]]$min_amt
    )
    begin {
        foreach ($field in @('company_id', 'location_id')) {
            if ($null -ne $PSBoundParameters[$field] -and $PSBoundParameters[$field] -lt 1) {
                throw [System.ArgumentOutOfRangeException]::new($field, 'Use a positive ID or null.')
            }
        }
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        if ($Values['purchase_date']) {
            $Values['purchase_date'] = $Values['purchase_date'].ToString("yyyy-MM-dd")
        }

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/components"
            Method = 'POST'
            Session = $Session
            Body   = $Values
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("Component '$name'", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}

