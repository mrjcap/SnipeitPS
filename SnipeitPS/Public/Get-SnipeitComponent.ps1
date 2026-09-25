<#
.SYNOPSIS
Gets a list of Snipe-IT Components

.PARAMETER search
A text string to search the Components data

.PARAMETER id
An ID of a specific Component

.PARAMETER name
Optionally restrict Component results to this name field

.PARAMETER company_id
Optionally restrict Component results to this company_id field

.PARAMETER category_id
Optionally restrict Component results to this category_id field

.PARAMETER location_id
Optionally restrict Component results to this location_id field

.PARAMETER sort
Specify the column name you wish to sort by

.PARAMETER limit
Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

.PARAMETER offset
Offset to use

.PARAMETER all
Return all results, works with -offset and other parameters

.PARAMETER supplier_id
Restrict results to a supplier ID.

.PARAMETER manufacturer_id
Restrict results to a manufacturer ID.

.PARAMETER model_number
Match the manufacturer's model number.

.PARAMETER order_number
Match a purchase order number.

.PARAMETER notes
Match stored notes.

.PARAMETER expand_company_hierarchy
Include descendant companies when filtering by company_id.

.PARAMETER filter
Server text-search filter, taking precedence over search.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitComponent
Returns all components

.EXAMPLE
Get-SnipeitComponent -search display
Returns search results containing "display"

.EXAMPLE
Get-SnipeitComponent -id 1
Returns specific component

#>
function Get-SnipeitComponent() {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(ParameterSetName='Search')]
        [string]$search,

        [parameter(ParameterSetName='Get with ID')]
        [int]$id,

        [parameter(ParameterSetName='Search')]
        [string]$name,

        [parameter(ParameterSetName='Search')]
        [int]$category_id,

        [parameter(ParameterSetName='Search')]
        [int]$company_id,

        [parameter(ParameterSetName='Search')]
        [int]$location_id,

        [parameter(ParameterSetName='Search')]
        [ValidateSet("asc", "desc")]
        [string]$order = "desc",

        [parameter(ParameterSetName='Search')]
        [ValidateSet('id', 'name', 'min_amt', 'order_number', 'serial', 'purchase_date', 'purchase_cost', 'company', 'category', 'qty', 'location', 'image', 'created_at')]
        [string]$sort = "created_at",

        [parameter(ParameterSetName='Search')]
        [ValidateRange(1,500)]
        [int]$limit = 50,

        [parameter(ParameterSetName='Search')]
        [int]$offset,

        [parameter(ParameterSetName='Search')]
        [switch]$all = $false,

        [parameter(ParameterSetName='Search')]
        [int]$supplier_id,

        [parameter(ParameterSetName='Search')]
        [int]$manufacturer_id,

        [parameter(ParameterSetName='Search')]
        [string]$model_number,

        [parameter(ParameterSetName='Search')]
        [string]$order_number,

        [parameter(ParameterSetName='Search')]
        [string]$notes,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$expand_company_hierarchy,

        [parameter(ParameterSetName='Search')]
        [string]$filter,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$SearchParameter = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
    }

    process {
        $pathParams = @{}
        if ($PSBoundParameters.ContainsKey('id')) {
            $route = "$script:SnipeitApiPrefix/components/{id}"
            $pathParams['id'] = $id
        } else {
            $route = "$script:SnipeitApiPrefix/components"
        }

        if ($SearchParameter.ContainsKey('all')) {
            $SearchParameter.Remove('all')
        }

        $Parameters = @{
            Route         = $route
            PathParameter = $pathParams
            Method        = 'Get'
            Session = $Session
            GetParameters = $SearchParameter
            Paginate      = [bool]$all
        }

        $result = Invoke-SnipeitMethod @Parameters
        $result
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
