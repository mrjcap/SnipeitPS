<#
.SYNOPSIS
Gets a list of Snipe-IT Suppliers

.PARAMETER search
A text string to search the Suppliers data

.PARAMETER id
An ID of a specific Supplier

.PARAMETER sort
Column to sort on

.PARAMETER order
Sort order for results, one of 'asc' or 'desc'. Defaults to 'desc'

.PARAMETER name
Optionally restrict Supplier results to this Supplier name.

.PARAMETER address
Optionally restrict Supplier results to this Supplier address.

.PARAMETER address2
Optionally restrict Supplier results to this Supplier address2.

.PARAMETER city
Optionally restrict Supplier results to this Supplier city.

.PARAMETER zip
Optionally restrict Supplier results to this Supplier zip.

.PARAMETER country
Optionally restrict Supplier results to this Supplier country.

.PARAMETER fax
Optionally restrict Supplier results to this Supplier fax number.

.PARAMETER email
Optionally restrict Supplier results to this Supplier email address.

.PARAMETER notes
Optionally restrict Supplier results to this Supplier notes field.

.PARAMETER limit
Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

.PARAMETER offset
Offset to use

.PARAMETER all
Return all results, works with -offset and other parameters

.PARAMETER supplier_url
Match the supplier's website URL.

.PARAMETER filter
Server text-search filter, taking precedence over search.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitSupplier -search MySupplier

.EXAMPLE
Get-SnipeitSupplier -id 2

#>
function Get-SnipeitSupplier() {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(ParameterSetName='Search')]
        [string]$search,

        [parameter(ParameterSetName='Get with ID', ValueFromPipelineByPropertyName = $true)]
        [int]$id,

        [parameter(ParameterSetName='Search')]
        [string]$sort = "created_at",

        [parameter(ParameterSetName='Search')]
        [ValidateSet("asc", "desc")]
        [string]$order = "desc",

        [parameter(ParameterSetName='Search')]
        [string]$name,

        [parameter(ParameterSetName='Search')]
        [string]$address,

        [parameter(ParameterSetName='Search')]
        [string]$address2,

        [parameter(ParameterSetName='Search')]
        [string]$city,

        [parameter(ParameterSetName='Search')]
        [string]$zip,

        [parameter(ParameterSetName='Search')]
        [string]$country,

        [parameter(ParameterSetName='Search')]
        [string]$fax,

        [parameter(ParameterSetName='Search')]
        [string]$email,

        [parameter(ParameterSetName='Search')]
        [string]$notes,

        [parameter(ParameterSetName='Search')]
        [ValidateRange(1,500)]
        [int]$limit = 50,

        [parameter(ParameterSetName='Search')]
        [int]$offset,

        [parameter(ParameterSetName='Search')]
        [switch]$all = $false,

        [parameter(ParameterSetName='Search')]
        [string]$supplier_url,

        [parameter(ParameterSetName='Search')]
        [string]$filter,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$SearchParameter = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
        if ($SearchParameter.ContainsKey('supplier_url')) {
            $SearchParameter['url'] = $SearchParameter['supplier_url']
            $SearchParameter.Remove('supplier_url')
        }
    }

    process {
        $pathParams = @{}
        if ($PSBoundParameters.ContainsKey('id')) {
            $route = "$script:SnipeitApiPrefix/suppliers/{id}"
            $pathParams['id'] = $id
        } else {
            $route = "$script:SnipeitApiPrefix/suppliers"
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
