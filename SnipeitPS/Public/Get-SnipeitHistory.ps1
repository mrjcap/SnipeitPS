<#
.SYNOPSIS
Gets action history records for an entity from Snipe-IT.

.DESCRIPTION
Retrieves the action audit log / history entries associated with a specific resource across 9 supported entity types:
Accessory, Component, Consumable, Asset, Maintenance, License, Location, Model, and User.

.PARAMETER EntityType
The type of entity whose history is being retrieved.
Allowed values: Accessory, Component, Consumable, Asset, Maintenance, License, Location, Model, User.

.PARAMETER id
The unique identifier of the target entity.

.PARAMETER search
Search query string.

.PARAMETER action_type
Filter by specific action type (e.g. checkout, checkin from, upload, update).

.PARAMETER created_by
Filter by the user ID of the person who initiated the action.

.PARAMETER action_source
Filter by action source (e.g. web, api).

.PARAMETER remote_ip
Filter by client IP address.

.PARAMETER uploads
When specified, restricts results to action logs containing file uploads.

.PARAMETER sort
Specifies the column by which results are sorted.
Allowed values: id, created_at, target_id, created_by, accept_signature, action_type, note, remote_ip, user_agent, target_type, item_type, action_source, action_date.

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
SnipeitPS.HistoryEntry

.EXAMPLE
Get-SnipeitHistory -EntityType Asset -id 10

.EXAMPLE
Get-SnipeitHistory -EntityType User -id 5 -uploads

.EXAMPLE
1..5 | Get-SnipeitHistory -EntityType Asset -All
#>
function Get-SnipeitHistory {
    [CmdletBinding()]
    [OutputType('SnipeitPS.HistoryEntry')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('Accessory', 'Component', 'Consumable', 'Asset', 'Maintenance', 'License', 'Location', 'Model', 'User')]
        [string]$EntityType,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$id,

        [Parameter(Mandatory = $false)]
        [string]$search,

        [Parameter(Mandatory = $false)]
        [string]$action_type,

        [Parameter(Mandatory = $false)]
        [int]$created_by,

        [Parameter(Mandatory = $false)]
        [string]$action_source,

        [Parameter(Mandatory = $false)]
        [string]$remote_ip,

        [Parameter(Mandatory = $false)]
        [switch]$uploads,

        [Parameter(Mandatory = $false)]
        [ValidateSet('id', 'created_at', 'target_id', 'created_by', 'accept_signature', 'action_type', 'note', 'remote_ip', 'user_agent', 'target_type', 'item_type', 'action_source', 'action_date')]
        [string]$sort,

        [Parameter(Mandatory = $false)]
        [ValidateSet('asc', 'desc')]
        [string]$order,

        [Parameter(Mandatory = $false)]
        [int]$offset,

        [Parameter(Mandatory = $false)]
        [int]$limit,

        [Parameter(Mandatory = $false)]
        [switch]$all,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $segment = switch ($EntityType) {
            'Accessory'   { 'accessories' }
            'Component'   { 'components' }
            'Consumable'  { 'consumables' }
            'Asset'       { 'hardware' }
            'Maintenance' { 'maintenances' }
            'License'     { 'licenses' }
            'Location'    { 'locations' }
            'Model'       { 'models' }
            'User'        { 'users' }
        }

        $getParams = @{}
        if ($PSBoundParameters.ContainsKey('search')) { $getParams['search'] = $search }
        if ($PSBoundParameters.ContainsKey('action_type')) { $getParams['action_type'] = $action_type }
        if ($PSBoundParameters.ContainsKey('created_by')) { $getParams['created_by'] = $created_by }
        if ($PSBoundParameters.ContainsKey('action_source')) { $getParams['action_source'] = $action_source }
        if ($PSBoundParameters.ContainsKey('remote_ip')) { $getParams['remote_ip'] = $remote_ip }
        if ($uploads) { $getParams['uploads'] = '1' }
        if ($PSBoundParameters.ContainsKey('sort')) { $getParams['sort'] = $sort }
        if ($PSBoundParameters.ContainsKey('order')) { $getParams['order'] = $order }
        if ($PSBoundParameters.ContainsKey('offset')) { $getParams['offset'] = $offset }
        if ($PSBoundParameters.ContainsKey('limit')) { $getParams['limit'] = $limit }

        $callParams = @{
            Route   = "/api/v1/$segment/$id/history"
            Method  = 'GET'
            Session = $Session
        }
        if ($getParams.Count -gt 0) {
            $callParams['GetParameters'] = $getParams
        }
        if ($all) {
            $callParams['Paginate'] = $true
        }

        Invoke-SnipeitMethod @callParams
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
