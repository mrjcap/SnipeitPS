<#
.SYNOPSIS
Gets a list of Snipe-IT Locations

.PARAMETER search
A text string to search the Locations data

.PARAMETER id
An ID of a specific Location

.PARAMETER name
Optionally restrict Location results to this Location name.

.PARAMETER address
Optionally restrict Location results to this Location address.

.PARAMETER address2
Optionally restrict Location results to this Location address2.

.PARAMETER city
Optionally restrict Location results to this Location city.

.PARAMETER zip
Optionally restrict Location results to this Location zip.

.PARAMETER country
Optionally restrict Location results to this Location country.

.PARAMETER sort
Column to sort on

.PARAMETER order
Sort order for results, one of 'asc' or 'desc'. Defaults to 'desc'

.PARAMETER limit
Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

.PARAMETER offset
Offset to use

.PARAMETER all
Return all results, works with -offset and other parameters

.PARAMETER company_id
Restrict results to a company ID.

.PARAMETER parent_id
Restrict results to children of this location ID.

.PARAMETER manager_id
Restrict results to locations managed by this user ID.

.PARAMETER status
Use deleted to request soft-deleted locations.

.PARAMETER filter
Server text-search filter, taking precedence over search.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitLocation -search Location1

.EXAMPLE
Get-SnipeitLocation -id 3

#>

function Get-SnipeitLocation() {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(ParameterSetName='Search')]
        [string]$search,

        [parameter(ParameterSetName='Get with ID', ValueFromPipelineByPropertyName = $true)]
        [int]$id,

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
        [string]$sort = "created_at",

        [parameter(ParameterSetName='Search')]
        [ValidateSet("asc", "desc")]
        [string]$order = "desc",

        [parameter(ParameterSetName='Search')]
        [ValidateRange(1,500)]
        [int]$limit = 50,

        [parameter(ParameterSetName='Search')]
        [int]$offset,

        [parameter(ParameterSetName='Search')]
        [switch]$all = $false,

        [parameter(ParameterSetName='Search')]
        [int]$company_id,

        [parameter(ParameterSetName='Search')]
        [int]$parent_id,

        [parameter(ParameterSetName='Search')]
        [int]$manager_id,

        [parameter(ParameterSetName='Search')]
        [string]$status,

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
            $route = "$script:SnipeitApiPrefix/locations/{id}"
            $pathParams['id'] = $id
        } else {
            $route = "$script:SnipeitApiPrefix/locations"
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

