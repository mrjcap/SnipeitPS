<#
.SYNOPSIS
Lists or retrieves Snipe-IT Asset Maintenances

.DESCRIPTION
Retrieves a single asset maintenance by ID or queries asset maintenances using filters and pagination.

.PARAMETER id
Unique ID of the maintenance record to retrieve. Mutually exclusive with query filters.

.PARAMETER asset_id
Asset ID to filter maintenance records by.

.PARAMETER search
Search string to query maintenance records.

.PARAMETER filter
Advanced search filter string. Takes precedence over search when both are provided.

.PARAMETER supplier_id
Supplier ID to filter maintenance records by.

.PARAMETER created_by
User ID of the creator to filter maintenance records by.

.PARAMETER url
URL string to filter maintenance records by.

.PARAMETER maintenance_type
Maintenance type string to filter by.

.PARAMETER maintenance_type_id
Maintenance type ID to filter by.

.PARAMETER responsible_party_id
User ID of the responsible party to filter by.

.PARAMETER checked_out_to_id
Polymorphic ID of the target the underlying asset was checked out to.

.PARAMETER checked_out_to_type
Fully qualified class name for polymorphic checkout target (e.g. App\Models\User).

.PARAMETER completed
Filter by completion state. Bound true queries completed records; bound false queries active records.
Omitted returns both.

.PARAMETER upcoming_status
Upcoming status filter. Allowed values: due, overdue, due-or-overdue.

.PARAMETER sort
Specify the column name you wish to sort by. Defaults to created_at.

.PARAMETER order
Specify the order (asc or desc) you wish to order by. Defaults to desc.

.PARAMETER limit
Specify the number of results to return per page. Defaults to 50.

.PARAMETER offset
Offset to use for pagination.

.PARAMETER format
Set to flat to return the flattened maintenance representation.

.PARAMETER all
When specified, streams all results across pages using dispatcher-managed pagination.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Get-SnipeitAssetMaintenance -id 42

.EXAMPLE
Get-SnipeitAssetMaintenance -asset_id 1 -completed $false

.EXAMPLE
Get-SnipeitAssetMaintenance -filter "printer" -upcoming_status "due" -all
#>
function Get-SnipeitAssetMaintenance {
    [CmdletBinding(DefaultParameterSetName = 'ByFilter')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'ById', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$id,

        [Parameter(ParameterSetName = 'ByFilter', Position = 0)]
        [string]$search,

        [Parameter(ParameterSetName = 'ByFilter')]
        [string]$filter,

        [Parameter(ParameterSetName = 'ByFilter', Position = 1)]
        [int]$asset_id,

        [Parameter(ParameterSetName = 'ByFilter')]
        [int]$supplier_id,

        [Parameter(ParameterSetName = 'ByFilter')]
        [int]$created_by,

        [Parameter(ParameterSetName = 'ByFilter')]
        [string]$url,

        [Parameter(ParameterSetName = 'ByFilter')]
        [string]$maintenance_type,

        [Parameter(ParameterSetName = 'ByFilter')]
        [int]$maintenance_type_id,

        [Parameter(ParameterSetName = 'ByFilter')]
        [int]$responsible_party_id,

        [Parameter(ParameterSetName = 'ByFilter')]
        [int]$checked_out_to_id,

        [Parameter(ParameterSetName = 'ByFilter')]
        [string]$checked_out_to_type,

        [Parameter(ParameterSetName = 'ByFilter')]
        [Nullable[bool]]$completed,

        [Parameter(ParameterSetName = 'ByFilter')]
        [ValidateSet('due', 'overdue', 'due-or-overdue')]
        [string]$upcoming_status,

        [Parameter(ParameterSetName = 'ByFilter', Position = 2)]
        [string]$sort = "created_at",

        [Parameter(ParameterSetName = 'ByFilter', Position = 3)]
        [ValidateSet("asc", "desc")]
        [string]$order = "desc",

        [Parameter(ParameterSetName = 'ByFilter', Position = 4)]
        [ValidateRange(1, 500)]
        [int]$limit = 50,

        [Parameter(ParameterSetName = 'ByFilter')]
        [ValidateSet('flat')]
        [string]$format,

        [Parameter(ParameterSetName = 'ByFilter')]
        [switch]$all = $false,

        [Parameter(ParameterSetName = 'ByFilter', Position = 5)]
        [int]$offset,

        [Parameter(Mandatory = $false, Position = 6)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $Parameters = @{
                Route   = "$script:SnipeitApiPrefix/maintenances/$id"
                Method  = 'Get'
                Session = $Session
            }
            $result = Invoke-SnipeitMethod @Parameters
            $result
        } else {
            $queryParams = @{}

            if ($PSBoundParameters.ContainsKey('filter')) {
                $queryParams['filter'] = $filter
            } elseif ($PSBoundParameters.ContainsKey('search')) {
                $queryParams['search'] = $search
            }

            if ($PSBoundParameters.ContainsKey('asset_id')) { $queryParams['asset_id'] = $asset_id }
            if ($PSBoundParameters.ContainsKey('supplier_id')) { $queryParams['supplier_id'] = $supplier_id }
            if ($PSBoundParameters.ContainsKey('created_by')) { $queryParams['created_by'] = $created_by }
            if ($PSBoundParameters.ContainsKey('url')) { $queryParams['url'] = $url }
            if ($PSBoundParameters.ContainsKey('maintenance_type')) { $queryParams['maintenance_type'] = $maintenance_type }
            if ($PSBoundParameters.ContainsKey('maintenance_type_id')) { $queryParams['maintenance_type_id'] = $maintenance_type_id }
            if ($PSBoundParameters.ContainsKey('responsible_party_id')) { $queryParams['responsible_party_id'] = $responsible_party_id }
            if ($PSBoundParameters.ContainsKey('checked_out_to_id')) { $queryParams['checked_out_to_id'] = $checked_out_to_id }
            if ($PSBoundParameters.ContainsKey('checked_out_to_type')) { $queryParams['checked_out_to_type'] = $checked_out_to_type }

            if ($PSBoundParameters.ContainsKey('completed')) {
                $queryParams['completed'] = if ($completed) { 'true' } else { 'false' }
            }

            if ($PSBoundParameters.ContainsKey('upcoming_status')) { $queryParams['upcoming_status'] = $upcoming_status }
            if ($PSBoundParameters.ContainsKey('format')) { $queryParams['format'] = $format }

            $queryParams['sort'] = $sort
            $queryParams['order'] = $order
            $queryParams['limit'] = $limit

            if ($PSBoundParameters.ContainsKey('offset')) {
                $queryParams['offset'] = $offset
            }

            $Parameters = @{
                Route         = "$script:SnipeitApiPrefix/maintenances"
                Method        = 'Get'
                Session       = $Session
                GetParameters = $queryParams
                Paginate      = [bool]$all
            }

            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
