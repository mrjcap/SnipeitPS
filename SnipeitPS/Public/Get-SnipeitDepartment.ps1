<#
.SYNOPSIS
Gets a list of Snipe-IT Departments

.PARAMETER search
A text string to search the Departments data

.PARAMETER id
An ID of a specific Department

.PARAMETER name
Optionally restrict department results to this department name.

.PARAMETER manager_id
Optionally restrict department results to this manager ID.

.PARAMETER company_id
Optionally restrict department results to this company ID.

.PARAMETER location_id
Optionally restrict department results to this location ID.

.PARAMETER limit
Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

.PARAMETER offset
Offset to use

.PARAMETER all
Return all results, works with -offset and other parameters

.PARAMETER sort
Specify the column name you wish to sort by

.PARAMETER tag_color
Match a hexadecimal department tag color.

.PARAMETER filter
Server text-search filter, taking precedence over search.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitDepartment

.EXAMPLE
Get-SnipeitDepartment -search Department1

.EXAMPLE
Get-SnipeitDepartment -id 1

#>

function Get-SnipeitDepartment() {
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
        [int]$manager_id,

        [parameter(ParameterSetName='Search')]
        [int]$company_id,

        [parameter(ParameterSetName='Search')]
        [int]$location_id,

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
        [ValidateSet('id', 'name', 'image', 'users_count', 'created_at')]
        [string]$sort = "created_at",

        [parameter(ParameterSetName='Search')]
        [string]$tag_color,

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
            $route = "$script:SnipeitApiPrefix/departments/{id}"
            $pathParams['id'] = $id
        } else {
            $route = "$script:SnipeitApiPrefix/departments"
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

