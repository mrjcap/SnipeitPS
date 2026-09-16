<#
.SYNOPSIS
Gets a list of Snipe-IT Licenses

.PARAMETER search
A text string to search the Licenses data

.PARAMETER id
An ID of a specific License

.PARAMETER user_id
ID of a user to filter licenses checked out to

.PARAMETER asset_id
ID of an asset to filter licenses checked out to

.PARAMETER name
Name of a specific license to search for

.PARAMETER company_id
ID of a company to filter by

.PARAMETER product_key
Product key to search for

.PARAMETER order_number
Order number to search for

.PARAMETER purchase_order
Purchase order to search for

.PARAMETER license_name
Name of the license to search for

.PARAMETER license_email
Email address associated with the license

.PARAMETER manufacturer_id
ID of a manufacturer to filter by

.PARAMETER supplier_id
ID of a supplier to filter by

.PARAMETER depreciation_id
ID of a depreciation schedule to filter by

.PARAMETER category_id
ID of a category to filter by

.PARAMETER order
Sort order for results, one of 'asc' or 'desc'. Defaults to 'desc'

.PARAMETER sort
Specify the column name you wish to sort by

.PARAMETER limit
Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

.PARAMETER offset
Offset to use

.PARAMETER all
Return all results, works with -offset and other parameters


.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitLicense -search SomeLicense

.EXAMPLE
Get-SnipeitLicense -id 1

#>

function Get-SnipeitLicense() {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(ParameterSetName='Search')]
        [string]$search,

        [parameter(ParameterSetName='Get with ID', ValueFromPipelineByPropertyName = $true)]
        [int]$id,

        [parameter(ParameterSetName='Get licenses checked out to user ID', ValueFromPipelineByPropertyName = $true)]
        [Alias('assigned_user')]
        [int]$user_id,

        [parameter(ParameterSetName='Get licenses checked out to asset ID', ValueFromPipelineByPropertyName = $true)]
        [Alias('hardware_id')]
        [int]$asset_id,

        [parameter(ParameterSetName='Search')]
        [string]$name,

        [parameter(ParameterSetName='Search')]
        [int] $company_id,

        [parameter(ParameterSetName='Search')]
        [string]$product_key,

        [parameter(ParameterSetName='Search')]
        [string]$order_number,

        [parameter(ParameterSetName='Search')]
        [string]$purchase_order,

        [parameter(ParameterSetName='Search')]
        [string]$license_name,

        [parameter(ParameterSetName='Search')]
        [mailaddress]$license_email,

        [parameter(ParameterSetName='Search')]
        [int]$manufacturer_id,

        [parameter(ParameterSetName='Search')]
        [int]$supplier_id,

        [parameter(ParameterSetName='Search')]
        [int]$depreciation_id,

        [parameter(ParameterSetName='Search')]
        [int]$category_id,

        [parameter(ParameterSetName='Search')]
        [ValidateSet("asc", "desc")]
        [string]$order = "desc",

        [parameter(ParameterSetName='Search')]
        [ValidateSet('created_at','id', 'name', 'purchase_cost', 'expiration_date', 'purchase_order', 'order_number', 'notes', 'purchase_date', 'serial', 'company', 'category', 'license_name', 'license_email', 'free_seats_count', 'seats', 'manufacturer', 'supplier')]
        [string]$sort = "created_at",

        [parameter(ParameterSetName='Search')]
        [ValidateRange(1,500)]
        [int]$limit = 50,

        [parameter(ParameterSetName='Search')]
        [int]$offset,
        [parameter(ParameterSetName='Get licenses checked out to user ID')]
        [parameter(ParameterSetName='Get licenses checked out to asset ID')]
        [parameter(ParameterSetName='Search')]
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
            'Search' { $route = "$script:SnipeitApiPrefix/licenses" }
            'Get with ID' {
                $route = "$script:SnipeitApiPrefix/licenses/{id}"
                $pathParams['id'] = $id
            }
            'Get licenses checked out to user ID' {
                $route = "$script:SnipeitApiPrefix/users/{user_id}/licenses"
                $pathParams['user_id'] = $user_id
            }
            'Get licenses checked out to asset ID' {
                $route = "$script:SnipeitApiPrefix/hardware/{asset_id}/licenses"
                $pathParams['asset_id'] = $asset_id
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
