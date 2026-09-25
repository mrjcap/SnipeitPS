<#
.SYNOPSIS
Gets a list of Snipe-IT consumables

.PARAMETER search
A text string to search the consumables

.PARAMETER id
An ID of a specific consumable

.PARAMETER name
Optionally restrict consumable results to this name field

.PARAMETER company_id
ID number of company

.PARAMETER category_id
ID number of category

.PARAMETER manufacturer_id
ID number of manufacturer

.PARAMETER location_id
Location ID number of the consumable to filter by

.PARAMETER sort
Sort results by column

.PARAMETER order
Specify the order (asc or desc) you wish to order by on your sort column

.PARAMETER expand
Whether to include detailed information on categories, etc (true) or just the text name (false)

.PARAMETER limit
Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

.PARAMETER offset
Offset to use

.PARAMETER all
Return all results

.PARAMETER supplier_id
Restrict results to a supplier ID.

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
Get-SnipeitConsumable -all
Returns all consumables

.EXAMPLE
Get-SnipeitConsumable -search paper
Returns search results containing "paper"

.EXAMPLE
Get-SnipeitConsumable -id 1
Returns specific consumable

#>
function Get-SnipeitConsumable() {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(ParameterSetName='Search')]
        [string]$search,

        [parameter(ParameterSetName='Get with ID')]
        [int[]]$id,

        [parameter(ParameterSetName='Search')]
        [string]$name,

        [parameter(ParameterSetName='Search')]
        [int]$category_id,

        [parameter(ParameterSetName='Search')]
        [int]$company_id,

        [parameter(ParameterSetName='Search')]
        [int]$manufacturer_id,

        [parameter(ParameterSetName='Search')]
        [int]$location_id,

        [parameter(ParameterSetName='Search')]
        [ValidateSet("asc", "desc")]
        [string]$order = "desc",

        [parameter(ParameterSetName='Search')]
        [ValidateSet('id', 'name', 'min_amt', 'order_number', 'serial', 'purchase_date', 'purchase_cost', 'company', 'category', 'qty', 'location', 'image', 'created_at')]
        [string]$sort = "created_at",


        [Parameter(ParameterSetName='Search')]
        [switch]$expand,

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
        switch ($PSCmdlet.ParameterSetName) {
            'Search' {
                if ($SearchParameter.ContainsKey('all')) {
                    $SearchParameter.Remove('all')
                }

                $Parameters = @{
                    Route         = "$script:SnipeitApiPrefix/consumables"
                    Method        = 'Get'
                    Session = $Session
                    GetParameters = $SearchParameter
                    Paginate      = [bool]$all
                }

                $result = Invoke-SnipeitMethod @Parameters
                $result
            }

            'Get with ID' {
                foreach ($consumable_id in $id) {
                    $Parameters = @{
                        Route         = "$script:SnipeitApiPrefix/consumables/{id}"
                        PathParameter = @{ id = $consumable_id }
                        Method        = 'Get'
                        Session = $Session
                        GetParameters = $SearchParameter
                    }

                    $result = Invoke-SnipeitMethod @Parameters
                    $result
                }
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
