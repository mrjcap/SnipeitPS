<#
.SYNOPSIS
Gets depreciation schedules from Snipe-IT.

.DESCRIPTION
Retrieves one or more depreciation schedules from Snipe-IT. Supports retrieving a specific
schedule by ID, or searching and listing schedules with sorting, filtering, and pagination.

.PARAMETER id
The ID of a specific depreciation schedule to retrieve.

.PARAMETER search
Search string to filter depreciation schedules by name.

.PARAMETER filter
Advanced search filter string.

.PARAMETER sort
Specifies the column by which results are sorted.
Allowed values: id, name, months, depreciation_min, depreciation_type, created_at, created_by, assets_count, models_count, licenses_count.

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
SnipeitPS.Depreciation

.EXAMPLE
Get-SnipeitDepreciation -All

.EXAMPLE
Get-SnipeitDepreciation -id 5

.EXAMPLE
Get-SnipeitDepreciation -search "Computer" -sort "name" -order "asc"
#>
function Get-SnipeitDepreciation {
    [CmdletBinding(DefaultParameterSetName = 'ByFilter')]
    [OutputType('SnipeitPS.Depreciation')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'ById', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$id,

        [Parameter(ParameterSetName = 'ByFilter')]
        [string]$search,

        [Parameter(ParameterSetName = 'ByFilter')]
        [string]$filter,

        [Parameter(ParameterSetName = 'ByFilter')]
        [ValidateSet('id', 'name', 'months', 'depreciation_min', 'depreciation_type', 'created_at', 'created_by', 'assets_count', 'models_count', 'licenses_count')]
        [string]$sort,

        [Parameter(ParameterSetName = 'ByFilter')]
        [ValidateSet('asc', 'desc')]
        [string]$order,

        [Parameter(ParameterSetName = 'ByFilter')]
        [int]$offset,

        [Parameter(ParameterSetName = 'ByFilter')]
        [int]$limit,

        [Parameter(ParameterSetName = 'ByFilter')]
        [switch]$all,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $params = @{
                Route   = "/api/v1/depreciations/$id"
                Method  = 'GET'
                Session = $Session
            }
            Invoke-SnipeitMethod @params
        } else {
            $getParams = @{}
            if ($PSBoundParameters.ContainsKey('search')) { $getParams['search'] = $search }
            if ($PSBoundParameters.ContainsKey('filter')) { $getParams['filter'] = $filter }
            if ($PSBoundParameters.ContainsKey('sort')) { $getParams['sort'] = $sort }
            if ($PSBoundParameters.ContainsKey('order')) { $getParams['order'] = $order }
            if ($PSBoundParameters.ContainsKey('offset')) { $getParams['offset'] = $offset }
            if ($PSBoundParameters.ContainsKey('limit')) { $getParams['limit'] = $limit }

            $methodParams = @{
                Route   = '/api/v1/depreciations'
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
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
