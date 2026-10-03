<#
.SYNOPSIS
Gets assets due or overdue for audit or check-in.

.DESCRIPTION
Queries the Snipe-IT hardware API for assets matching upcoming status criteria:
audit or checkin action, and due, overdue, or due-or-overdue status.
Calls GET /api/v1/hardware/{action}/{upcoming_status}.

.PARAMETER Action
The upcoming action to query: Audit or Checkin.

.PARAMETER Status
The status filter: Due, Overdue, or DueOrOverdue.

.PARAMETER search
Search query string.

.PARAMETER filter
Advanced asset search filter. The server gives this precedence over search.

.PARAMETER asset_status
Asset status classification, such as Archived or Deleted. Separate from the required due Status selector.

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
Include component relationships in returned assets.

.PARAMETER customfields
Exact-match custom-field filters, keyed by internal columns such as _snipeit_room_12.
Other query keys are rejected. Use typed parameters for built-in filters.

.PARAMETER order
Sort order direction: asc or desc.

.PARAMETER sort
Field to sort results by.

.PARAMETER limit
Specify the number of results to return per page. Defaults to 50.

.PARAMETER offset
Result offset for pagination.

.PARAMETER All
When set, automatically streams all pages of results.

.PARAMETER preserveResponse
When set, returns the original response envelope instead of unwrapping asset records.

.PARAMETER past_eol
True restricts results to assets past their end-of-life date. False leaves this restriction off.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.Asset

.EXAMPLE
Get-SnipeitAssetDue -Action Audit -Status Due

.EXAMPLE
Get-SnipeitAssetDue -Action Checkin -Status Overdue -All
#>
function Get-SnipeitAssetDue {
    [CmdletBinding()]
    [OutputType('SnipeitPS.Asset')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('Audit', 'Checkin')]
        [string]$Action,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet('Due', 'Overdue', 'DueOrOverdue')]
        [string]$Status,

        [string]$search,

        [string]$filter,

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

        [ValidateSet('asc', 'desc')]
        [string]$order,

        [string]$sort,

        [ValidateRange(1, 500)]
        [int]$limit = 50,

        [int]$offset,

        [switch]$All,

        [switch]$preserveResponse,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [Nullable[bool]]$past_eol
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $routeAction = switch ($Action) {
            'Audit'   { 'audits' }
            'Checkin' { 'checkins' }
        }

        $routeStatus = switch ($Status) {
            'Due'          { 'due' }
            'Overdue'      { 'overdue' }
            'DueOrOverdue' { 'due-or-overdue' }
        }

        $getParams = Get-SnipeitAssetIndexParameter -BoundParameters $PSBoundParameters
        $getParams['limit'] = $limit

        $Parameters = @{
            Route            = "$script:SnipeitApiPrefix/hardware/{action}/{upcoming_status}"
            RouteTokens      = @{ action = $routeAction; upcoming_status = $routeStatus }
            Method           = 'Get'
            Session          = $Session
            GetParameters    = $getParams
            Paginate         = [bool]$All
            PreserveResponse = [bool]$preserveResponse
        }

        $result = Invoke-SnipeitMethod @Parameters
        $result
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
