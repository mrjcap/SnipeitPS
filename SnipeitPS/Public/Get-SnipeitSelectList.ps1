<#
.SYNOPSIS
Gets Select2-formatted dropdown select lists from Snipe-IT.

.DESCRIPTION
Retrieves Select2 formatted item collections across 13 entity types from Snipe-IT.
Supports searching, pagination, company scoping, and type-specific filter parameters.

.PARAMETER EntityType
The entity category to query.
Allowed values: Accessory, Category, Company, Department, Consumable, Asset, License, Location, Manufacturer, Model, Status, Supplier, User.

.PARAMETER search
Search query string.

.PARAMETER page
Specific page number to retrieve.

.PARAMETER all
When specified, retrieves and streams all pages sequentially.

.PARAMETER preserveResponse
When specified, returns the complete response envelope with pagination metadata.

.PARAMETER ItemType
Sub-type selector required when EntityType is 'Category'.
Allowed values: asset, accessory, consumable, component, license.

.PARAMETER companyId
Company ID or comma-separated company IDs to scope results (supported for Asset, Location, User).

.PARAMETER excludeId
ID of an entity to exclude from results (supported for Asset, Company, Location, User).

.PARAMETER statusType
Status type filter (supported for Asset, e.g. RTD).

.PARAMETER onlyTopLevel
When specified, marks child companies as disabled (supported for Company).

.PARAMETER deployable
Filter for deployable statuses (supported for Status).

.PARAMETER pending
Filter for pending statuses (supported for Status).

.PARAMETER archived
Filter for archived statuses (supported for Status).

.PARAMETER assignedTo
User ID whose assigned assets should appear. Only supported for Asset select lists.

.PARAMETER excludeIds
Location IDs to exclude from Location select lists. Supply an integer array.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.SelectListItem

.EXAMPLE
Get-SnipeitSelectList -EntityType Asset -search "MacBook"

.EXAMPLE
Get-SnipeitSelectList -EntityType Category -ItemType asset

.EXAMPLE
Get-SnipeitSelectList -EntityType Status -deployable
#>
function Get-SnipeitSelectList {
    [CmdletBinding()]
    [OutputType('SnipeitPS.SelectListItem')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('Accessory', 'Category', 'Company', 'Department', 'Consumable', 'Asset', 'License', 'Location', 'Manufacturer', 'Model', 'Status', 'Supplier', 'User')]
        [string]$EntityType,

        [Parameter(Mandatory = $false)]
        [string]$search,

        [Parameter(Mandatory = $false)]
        [int]$page,

        [Parameter(Mandatory = $false)]
        [switch]$all,

        [Parameter(Mandatory = $false)]
        [switch]$preserveResponse,

        [Parameter(Mandatory = $false)]
        [ValidateSet('asset', 'accessory', 'consumable', 'component', 'license')]
        [string]$ItemType = 'asset',

        [Parameter(Mandatory = $false)]
        [string]$companyId,

        [Parameter(Mandatory = $false)]
        [int]$excludeId,

        [Parameter(Mandatory = $false)]
        [ValidateSet('RTD')]
        [string]$statusType,

        [Parameter(Mandatory = $false)]
        [switch]$onlyTopLevel,

        [Parameter(Mandatory = $false)]
        [switch]$deployable,

        [Parameter(Mandatory = $false)]
        [switch]$pending,

        [Parameter(Mandatory = $false)]
        [switch]$archived,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$assignedTo,

        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$excludeIds
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSBoundParameters.ContainsKey('assignedTo') -and $EntityType -ne 'Asset') {
            throw "Parameter 'assignedTo' is only supported for EntityType 'Asset'."
        }
        if ($PSBoundParameters.ContainsKey('excludeIds') -and $EntityType -ne 'Location') {
            throw "Parameter 'excludeIds' is only supported for EntityType 'Location'."
        }
        # Validate entity-specific parameters
        if ($PSBoundParameters.ContainsKey('ItemType') -and $EntityType -ne 'Category') {
            throw "Parameter 'ItemType' is only supported for EntityType 'Category'."
        }
        if ($PSBoundParameters.ContainsKey('companyId') -and $EntityType -notin @('Asset', 'Location', 'User')) {
            throw "Parameter 'companyId' is not supported for EntityType '$EntityType'."
        }
        if ($PSBoundParameters.ContainsKey('excludeId') -and $EntityType -notin @('Asset', 'Company', 'Location', 'User')) {
            throw "Parameter 'excludeId' is not supported for EntityType '$EntityType'."
        }
        if ($PSBoundParameters.ContainsKey('statusType') -and $EntityType -ne 'Asset') {
            throw "Parameter 'statusType' is not supported for EntityType '$EntityType'."
        }
        if ($PSBoundParameters.ContainsKey('onlyTopLevel') -and $EntityType -ne 'Company') {
            throw "Parameter 'onlyTopLevel' is not supported for EntityType '$EntityType'."
        }
        if (($PSBoundParameters.ContainsKey('deployable') -or $PSBoundParameters.ContainsKey('pending') -or $PSBoundParameters.ContainsKey('archived')) -and $EntityType -ne 'Status') {
            throw "Parameter 'deployable' is not supported for EntityType '$EntityType'."
        }

        $route = switch ($EntityType) {
            'Accessory'    { '/api/v1/accessories/selectlist' }
            'Category'     { "/api/v1/categories/$ItemType/selectlist" }
            'Company'      { '/api/v1/companies/selectlist' }
            'Department'   { '/api/v1/departments/selectlist' }
            'Consumable'   { '/api/v1/consumables/selectlist' }
            'Asset'        { '/api/v1/hardware/selectlist' }
            'License'      { '/api/v1/licenses/selectlist' }
            'Location'     { '/api/v1/locations/selectlist' }
            'Manufacturer' { '/api/v1/manufacturers/selectlist' }
            'Model'        { '/api/v1/models/selectlist' }
            'Status'       { '/api/v1/statuslabels/selectlist' }
            'Supplier'     { '/api/v1/suppliers/selectlist' }
            'User'         { '/api/v1/users/selectlist' }
        }

        $getParams = @{}
        if ($PSBoundParameters.ContainsKey('search')) { $getParams['search'] = $search }
        if ($PSBoundParameters.ContainsKey('page')) { $getParams['page'] = $page }
        if ($PSBoundParameters.ContainsKey('companyId')) { $getParams['companyId'] = $companyId }
        if ($PSBoundParameters.ContainsKey('excludeId')) { $getParams['excludeId'] = $excludeId }
        if ($PSBoundParameters.ContainsKey('assignedTo')) { $getParams['assignedTo'] = $assignedTo }
        if ($PSBoundParameters.ContainsKey('excludeIds')) { $getParams['excludeIds'] = $excludeIds -join ',' }
        if ($PSBoundParameters.ContainsKey('statusType')) { $getParams['statusType'] = $statusType }
        if ($onlyTopLevel) { $getParams['onlyTopLevel'] = 'true' }
        if ($deployable) { $getParams['deployable'] = '1' }
        if ($pending) { $getParams['pending'] = '1' }
        if ($archived) { $getParams['archived'] = '1' }

        if ($all) {
            Invoke-SnipeitSelectListPage -Route $route -GetParameters $getParams -Session $Session -All
        } else {
            $callParams = @{
                Route   = $route
                Method  = 'GET'
                Session = $Session
            }
            if ($getParams.Count -gt 0) {
                $callParams['GetParameters'] = $getParams
            }
            $resp = Invoke-SnipeitMethod @callParams

            if ($preserveResponse) {
                if ($resp -is [System.Management.Automation.PSObject] -and -not $resp.PSObject.TypeNames.Contains('SnipeitPS.SelectListEnvelope')) {
                    $resp.PSObject.TypeNames.Insert(0, 'SnipeitPS.SelectListEnvelope')
                }
                $results = @(if ($resp -is [System.Collections.IDictionary]) { $resp['results'] } else { $resp.results })
                if ($results.Count -gt 0) {
                    foreach ($item in $results) {
                        if ($item -is [System.Management.Automation.PSObject] -and -not $item.PSObject.TypeNames.Contains('SnipeitPS.SelectListItem')) {
                            $item.PSObject.TypeNames.Insert(0, 'SnipeitPS.SelectListItem')
                        }
                    }
                }
                $resp
            } else {
                $results = @(if ($resp -is [System.Collections.IDictionary]) { $resp['results'] } else { $resp.results })
                if ($results.Count -gt 0) {
                    foreach ($item in $results) {
                        if ($item -is [System.Management.Automation.PSObject] -and -not $item.PSObject.TypeNames.Contains('SnipeitPS.SelectListItem')) {
                            $item.PSObject.TypeNames.Insert(0, 'SnipeitPS.SelectListItem')
                        }
                        $item
                    }
                }
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
