<#
.SYNOPSIS
Gets a list of Snipe-IT Assets or specific asset

.DESCRIPTION
Retrieves hardware asset records from the Snipe-IT REST API based on search criteria, specific IDs, asset tags, serial numbers, audit schedules, user checkout relationships, or component associations. Supports automated client-side pagination via the -all switch.

.OUTPUTS
[PSCustomObject]
Emits Snipe-IT hardware asset objects returned by the API.

.PARAMETER search
A text string to search the assets data

.PARAMETER id
ID number of exact Snipe-IT asset

.PARAMETER asset_tag
Exact asset tag to query

.PARAMETER serial
Exact asset serial number to query

.PARAMETER audit_due
Retrieve a list of assets that are due for auditing soon.

.PARAMETER audit_overdue
Retrieve a list of assets that are overdue for auditing.

.PARAMETER user_id
Retrieve a list of assets checked out to user ID.

.PARAMETER component_id
Retrieve a list of assets assigned this component ID.

.PARAMETER name
Optionally restrict asset results to this asset name

.PARAMETER order_number
Optionally restrict asset results to this order number

.PARAMETER model_id
Optionally restrict asset results to one or more asset model IDs.

.PARAMETER category_id
Optionally restrict asset results to this category ID

.PARAMETER manufacturer_id
Optionally restrict asset results to this manufacturer ID

.PARAMETER company_id
Optionally restrict asset results to this company ID

.PARAMETER location_id
Optionally restrict asset results to this location ID

.PARAMETER depreciation_id
Optionally restrict asset results to this depreciation ID

.PARAMETER requestable
Optionally restrict asset results to those set as requestable

.PARAMETER status
Optionally restrict asset results to one of these status types: RTD, Deployed, Undeployable, Deleted, Archived, Requestable

.PARAMETER status_id
Optionally restrict asset results to this status label ID

.PARAMETER supplier_id
Restrict results to a supplier ID.

.PARAMETER rtd_location_id
Restrict results to the default return location ID.

.PARAMETER asset_eol_date
Match the explicit end-of-life date using yyyy-MM-dd.

.PARAMETER assigned_to
Assignment target ID, used together with assigned_type.

.PARAMETER assigned_type
Assignment model class, such as App\Models\User, used together with assigned_to.

.PARAMETER byod
Restrict results to personally owned or organization-owned assets.

.PARAMETER components
Include component relationships in collection or ID responses.

.PARAMETER deleted
Include deleted matches when looking up an asset by tag or serial.

.PARAMETER Session
Optional custom SnipeitSession instance.

.PARAMETER status_type
Server status classification, such as Deployed, RTD, Archived, or Deleted.

.PARAMETER expand_company_hierarchy
Include descendant companies when filtering by company_id.

.PARAMETER filter
Server text-search filter, taking precedence over search.

.PARAMETER customfields
Hashtable of custom fields and extra fields for searching assets in Snipe-IT.
Use internal field names from Snipe-IT. You can use Get-SnipeitCustomField to get internal field names.

.PARAMETER sort
Specify a server-supported sort column, such as custom_fields._snipeit_room_12 for a custom field.
The server falls back to created_at for unknown columns.

.PARAMETER order
Specify the order (asc or desc) you wish to order by on your sort column

.PARAMETER limit
Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

.PARAMETER offset
Offset to use

.PARAMETER all
Return all results, works with -offset and other parameters

.EXAMPLE
Get-SnipeitAsset -all
Returns all assets

.EXAMPLE
Get-SnipeitAsset -search "myMachine"
Search for specific asset

.EXAMPLE
Get-SnipeitAsset -id 3
Get asset with ID number 3

.EXAMPLE
Get-SnipeitAsset -asset_tag snipe00033
Get asset with asset tag snipe00033

.EXAMPLE
Get-SnipeitAsset -serial 1234
Get asset with serial number 1234

.EXAMPLE
Get-SnipeitAsset -audit_due
Get Assets due auditing soon

.EXAMPLE
Get-SnipeitAsset -audit_overdue
Get Assets overdue for auditing

.EXAMPLE
Get-SnipeitAsset -user_id 4
Get Assets checked out to user ID 4

.EXAMPLE
Get-SnipeitAsset -component_id 5
Get Assets with component ID 5


#>

function Get-SnipeitAsset() {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(ParameterSetName='Search')]
        [string]$search,

        [parameter(ParameterSetName='Get with id', ValueFromPipelineByPropertyName = $true)]
        [int]$id,

        [parameter(ParameterSetName='Get with asset tag')]
        [string]$asset_tag,

        [parameter(ParameterSetName='Get with serial')]
        [Alias('asset_serial')]
        [string]$serial,

        [parameter(ParameterSetName='Assets due auditing soon')]
        [switch]$audit_due,

        [parameter(ParameterSetName='Assets overdue for auditing')]
        [switch]$audit_overdue,

        [parameter(ParameterSetName='Assets checked out to user id', ValueFromPipelineByPropertyName = $true)]
        [Alias('assigned_user', 'assigned_id')]
        [int]$user_id,

        [parameter(ParameterSetName='Assets with component id', ValueFromPipelineByPropertyName = $true)]
        [int]$component_id,

        [parameter(ParameterSetName='Search')]
        [string]$name,

        [parameter(ParameterSetName='Search')]
        [string]$order_number,

        [parameter(ParameterSetName='Search')]
        [ArgumentCompleter([SnipeitModelCompleter])]
        [int[]]$model_id,

        [parameter(ParameterSetName='Search')]
        [ArgumentCompleter([SnipeitCategoryCompleter])]
        [int]$category_id,

        [parameter(ParameterSetName='Search')]
        [ArgumentCompleter([SnipeitManufacturerCompleter])]
        [int]$manufacturer_id,

        [parameter(ParameterSetName='Search')]
        [ArgumentCompleter([SnipeitCompanyCompleter])]
        [int]$company_id,

        [parameter(ParameterSetName='Search')]
        [ArgumentCompleter([SnipeitLocationCompleter])]
        [int]$location_id,

        [parameter(ParameterSetName='Search')]
        [int]$depreciation_id,

        [parameter(ParameterSetName='Search')]
        [switch]$requestable,

        [parameter(ParameterSetName='Search')]
        [ValidateSet("RTD","Deployed","Undeployable","Pending","Archived","Requestable","Deleted")]
        [string]$status,

        [parameter(ParameterSetName='Search')]
        [ArgumentCompleter([SnipeitStatusCompleter])]
        [int]$status_id,

        [parameter(ParameterSetName='Search')]
        [hashtable]$customfields,

        [parameter(ParameterSetName='Search')]
        [parameter(ParameterSetName='Assets due auditing soon')]
        [parameter(ParameterSetName='Assets overdue for auditing')]
        [parameter(ParameterSetName='Assets checked out to user id')]
        [parameter(ParameterSetName='Assets with component id')]
        [string]$sort,

        [parameter(ParameterSetName='Search')]
        [parameter(ParameterSetName='Assets due auditing soon')]
        [parameter(ParameterSetName='Assets overdue for auditing')]
        [parameter(ParameterSetName='Assets checked out to user id')]
        [parameter(ParameterSetName='Assets with component id')]
        [ValidateSet("asc", "desc")]
        [string]$order,

        [parameter(ParameterSetName='Search')]
        [parameter(ParameterSetName='Assets due auditing soon')]
        [parameter(ParameterSetName='Assets overdue for auditing')]
        [parameter(ParameterSetName='Assets checked out to user id')]
        [parameter(ParameterSetName='Assets with component id')]
        [parameter(ParameterSetName='Get with serial')]
        [ValidateRange(1,500)]
        [int]$limit = 50,

        [parameter(ParameterSetName='Search')]
        [parameter(ParameterSetName='Assets due auditing soon')]
        [parameter(ParameterSetName='Assets overdue for auditing')]
        [parameter(ParameterSetName='Assets checked out to user id')]
        [parameter(ParameterSetName='Assets with component id')]
        [parameter(ParameterSetName='Get with serial')]
        [int]$offset,

        [parameter(ParameterSetName='Search')]
        [parameter(ParameterSetName='Assets due auditing soon')]
        [parameter(ParameterSetName='Assets overdue for auditing')]
        [parameter(ParameterSetName='Assets checked out to user id')]
        [parameter(ParameterSetName='Assets with component id')]
        [parameter(ParameterSetName='Get with serial')]
        [switch]$all = $false,

        [parameter(ParameterSetName='Search')]
        [int]$supplier_id,

        [parameter(ParameterSetName='Search')]
        [int]$rtd_location_id,

        [parameter(ParameterSetName='Search')]
        [string]$asset_eol_date,

        [parameter(ParameterSetName='Search')]
        [int]$assigned_to,

        [parameter(ParameterSetName='Search')]
        [string]$assigned_type,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$byod,

        [parameter(ParameterSetName='Search')]
        [parameter(ParameterSetName='Get with id')]
        [Nullable[bool]]$components,

        [parameter(ParameterSetName='Get with asset tag')]
        [parameter(ParameterSetName='Get with serial')]
        [Nullable[bool]]$deleted,

        [parameter(ParameterSetName='Search')]
        [string]$status_type,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$expand_company_hierarchy,

        [parameter(ParameterSetName='Search')]
        [string]$filter,

        [parameter(mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$SearchParameter = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        if ($model_id.Count -eq 1) { $SearchParameter['model_id'] = $model_id[0] }
        foreach ($field in @('byod', 'components')) {
            if ($null -ne $SearchParameter[$field]) { $SearchParameter[$field] = [int][bool]$SearchParameter[$field] }
        }

        # Add in custom fields.
        if ($customfields.Count -gt 0) {
            foreach ($pair in $customfields.GetEnumerator()) {
                if (-Not $SearchParameter.ContainsKey($pair.Name)) {
                    $SearchParameter.Add($pair.Name, $pair.Value)
                }
            }
        }
    }

    process {
        $pathParams = @{}
        switch ($PsCmdlet.ParameterSetName) {
            'Search' { $route = "$script:SnipeitApiPrefix/hardware" }
            'Get with id' {
                $route = "$script:SnipeitApiPrefix/hardware/{id}"
                $pathParams['id'] = $id
            }
            'Get with asset tag' {
                $route = "$script:SnipeitApiPrefix/hardware/bytag/{tag}"
                $pathParams['tag'] = $asset_tag
            }
            'Get with serial' {
                $route = "$script:SnipeitApiPrefix/hardware/byserial/{serial}"
                $pathParams['serial'] = $serial
            }
            'Assets due auditing soon' { $route = "$script:SnipeitApiPrefix/hardware/audit/due" }
            'Assets overdue for auditing' { $route = "$script:SnipeitApiPrefix/hardware/audit/overdue" }
            'Assets checked out to user id' {
                $route = "$script:SnipeitApiPrefix/users/{user_id}/assets"
                $pathParams['user_id'] = $user_id
            }
            'Assets with component id' {
                $route = "$script:SnipeitApiPrefix/components/{component_id}/assets"
                $pathParams['component_id'] = $component_id
            }
        }

        # Remove 'all' switch from query parameters before passing to dispatcher
        if ($SearchParameter.ContainsKey('all')) {
            $SearchParameter.Remove('all')
        }

        $Parameters = @{
            Route         = $route
            PathParameter = $pathParams
            Method        = 'Get'
            GetParameters = $SearchParameter
            Paginate      = [bool]$all
            Session       = $Session
        }

        $result = Invoke-SnipeitMethod @Parameters
        $result
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
