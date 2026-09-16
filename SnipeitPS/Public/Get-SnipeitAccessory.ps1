<#
.SYNOPSIS
Gets a list of Snipe-IT Accessories

.DESCRIPTION
Gets a list of Snipe-IT Accessories

.PARAMETER search
A text string to search the Accessory data

.PARAMETER user_id
Return Accessories checked out to a user ID

.PARAMETER id
An ID of a specific Accessory

.PARAMETER company_id
Optionally restrict Accessory results to this company_id field

.PARAMETER category_id
Optionally restrict Accessory results to this category_id field

.PARAMETER manufacturer_id
Optionally restrict Accessory results to this manufacturer_id field

.PARAMETER supplier_id
Optionally restrict Accessory results to this supplier_id field

.PARAMETER sort
Column to sort on

.PARAMETER order
Sort order. Can be asc or desc.

.PARAMETER limit
Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

.PARAMETER offset
Result offset to use

.PARAMETER all
Return all results, works with -offset and other parameters

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitAccessory -search Keyboard

.EXAMPLE
Get-SnipeitAccessory -id 1

.EXAMPLE
Get-SnipeitAccessory -user_id 1
Get accessories checked out to user ID 1

#>

function Get-SnipeitAccessory() {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(ParameterSetName='Search')]
        [string]$search,

        [parameter(ParameterSetName='Get by ID')]
        [int]$id,

        [parameter(ParameterSetName='Accessories checked out to user id')]
        [int]$user_id,

        [parameter(ParameterSetName='Search')]
        [int]$company_id,

        [parameter(ParameterSetName='Search')]
        [int]$category_id,

        [parameter(ParameterSetName='Search')]
        [int]$manufacturer_id,

        [parameter(ParameterSetName='Search')]
        [int]$supplier_id,

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
        [parameter(ParameterSetName='Accessories checked out to user id')]
        [switch]$all = $false,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$SearchParameter = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
    }

    process {
        $pathParams = @{}
        switch ($PsCmdlet.ParameterSetName) {
            'Search' { $route = "$script:SnipeitApiPrefix/accessories" }
            'Get by ID' {
                $route = "$script:SnipeitApiPrefix/accessories/{id}"
                $pathParams['id'] = $id
            }
            'Accessories checked out to user id' {
                $route = "$script:SnipeitApiPrefix/users/{user_id}/accessories"
                $pathParams['user_id'] = $user_id
            }
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
