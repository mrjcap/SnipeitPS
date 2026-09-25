<#
.SYNOPSIS
Gets a list of Snipe-IT Categories

.PARAMETER search
A text string to search the Categories data

.PARAMETER id
An ID of a specific Category

.PARAMETER name
Optionally restrict Category results to this Category name.

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

.PARAMETER category_type
Restrict results to an asset, accessory, component, consumable, or license category.

.PARAMETER archived
Include archived categories as supported by the server.

.PARAMETER use_default_eula
Filter categories by use of the default EULA.

.PARAMETER require_acceptance
Filter categories by their acceptance requirement.

.PARAMETER checkin_email
Filter categories by their checkin email setting.

.PARAMETER created_by
Restrict results to the creating user's ID.

.PARAMETER created_at
Exact creation timestamp in server format.

.PARAMETER updated_at
Exact last-update timestamp in server format.

.PARAMETER filter
Server text-search filter, taking precedence over search.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitCategory -id 1

.EXAMPLE
Get-SnipeitCategory -search "Laptop"

#>

function Get-SnipeitCategory() {
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
        [string]$category_type,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$archived,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$use_default_eula,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$require_acceptance,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$checkin_email,

        [parameter(ParameterSetName='Search')]
        [int]$created_by,

        [parameter(ParameterSetName='Search')]
        [string]$created_at,

        [parameter(ParameterSetName='Search')]
        [string]$updated_at,

        [parameter(ParameterSetName='Search')]
        [string]$filter,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$SearchParameter = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
        foreach ($field in @('use_default_eula', 'require_acceptance', 'checkin_email')) {
            if ($null -ne $SearchParameter[$field]) { $SearchParameter[$field] = [int][bool]$SearchParameter[$field] }
        }
    }
    process {
        $pathParams = @{}
        if ($PSBoundParameters.ContainsKey('id')) {
            $route = "$script:SnipeitApiPrefix/categories/{id}"
            $pathParams['id'] = $id
        } else {
            $route = "$script:SnipeitApiPrefix/categories"
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
