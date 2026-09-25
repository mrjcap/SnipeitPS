<#
.SYNOPSIS
Gets the depreciation report for deprecable assets from Snipe-IT.

.DESCRIPTION
Retrieves depreciation report data for assets from Snipe-IT, including purchase cost, current
depreciated value, monthly depreciation amount, and difference. Requires the 'reports.view'
permission on Snipe-IT.

.PARAMETER search
Search string to filter report results.

.PARAMETER filter
Advanced asset search filter. The server gives this precedence over search.

.PARAMETER asset_status
Asset status classification, such as Archived or Deleted. status is an alias.

.PARAMETER status_type
Preferred asset status classification; takes precedence over asset_status.

.PARAMETER status_id
Restrict results to this status label ID.

.PARAMETER asset_tag
Exact asset tag to match.

.PARAMETER serial
Exact serial number to match.

.PARAMETER requestable
True restricts results to requestable assets. False does not filter out requestable assets.

.PARAMETER model_id
One or more model IDs to match.

.PARAMETER category_id
Restrict results to this category ID.

.PARAMETER location_id
Restrict results to this current location ID.

.PARAMETER rtd_location_id
Restrict results to this default return location ID.

.PARAMETER supplier_id
Restrict results to this supplier ID.

.PARAMETER asset_eol_date
Exact end-of-life date, serialized as yyyy-MM-dd.

.PARAMETER assigned_to
Assignment target ID. Supply together with assigned_type.

.PARAMETER assigned_type
Assignment model class, such as App\Models\User. Supply together with assigned_to.

.PARAMETER company_id
Restrict results to this company ID.

.PARAMETER expand_company_hierarchy
Include reachable companies when filtering by company_id.

.PARAMETER manufacturer_id
Restrict results to this manufacturer ID.

.PARAMETER depreciation_id
Restrict results to this depreciation definition ID.

.PARAMETER byod
Filter personally owned versus organization-owned assets.

.PARAMETER order_number
Exact order number to match.

.PARAMETER components
Request component loading in the shared asset handler. The depreciation transformer omits component details.

.PARAMETER customfields
Exact-match custom-field filters, keyed by internal columns such as _snipeit_room_12.
Other query keys are rejected. Use typed parameters for built-in filters.

.PARAMETER sort
Specifies the column by which report results are sorted.

.PARAMETER order
Specifies the sort order (asc or desc).

.PARAMETER offset
Number of records to skip for pagination.

.PARAMETER limit
Maximum number of records to return per page.

.PARAMETER all
When specified, streams all records across pages using dispatcher-managed pagination.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.DepreciationReportEntry

.EXAMPLE
Get-SnipeitDepreciationReport

.EXAMPLE
Get-SnipeitDepreciationReport -search "MacBook" -All
#>
function Get-SnipeitDepreciationReport {
    [CmdletBinding()]
    [OutputType('SnipeitPS.DepreciationReportEntry')]
    param(
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$search,

        [string]$filter,

        [Alias('status')]
        [string]$asset_status,

        [string]$status_type,

        [int]$status_id,

        [string]$asset_tag,

        [string]$serial,

        [Nullable[bool]]$requestable,

        [int[]]$model_id,

        [int]$category_id,

        [int]$location_id,

        [int]$rtd_location_id,

        [int]$supplier_id,

        [datetime]$asset_eol_date,

        [int]$assigned_to,

        [string]$assigned_type,

        [int]$company_id,

        [Nullable[bool]]$expand_company_hierarchy,

        [int]$manufacturer_id,

        [int]$depreciation_id,

        [Nullable[bool]]$byod,

        [string]$order_number,

        [Nullable[bool]]$components,

        [hashtable]$customfields,

        [Parameter(Mandatory = $false, Position = 1)]
        [string]$sort,

        [Parameter(Mandatory = $false, Position = 2)]
        [ValidateSet('asc', 'desc')]
        [string]$order,

        [Parameter(Mandatory = $false, Position = 3)]
        [int]$offset,

        [Parameter(Mandatory = $false, Position = 4)]
        [int]$limit,

        [Parameter(Mandatory = $false)]
        [switch]$all,

        [Parameter(Mandatory = $false, Position = 5)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $getParams = Get-SnipeitAssetIndexParameter -BoundParameters $PSBoundParameters

        $methodParams = @{
            Route   = '/api/v1/reports/depreciation'
            Method  = 'GET'
            Session = $Session
        }
        if ($getParams.Count -gt 0) {
            $methodParams['GetParameters'] = $getParams
        }
        if ($all) {
            $methodParams['Paginate'] = $true
        }
        Invoke-SnipeitMethod @methodParams
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
