<#
.SYNOPSIS
Gets predefined kits from Snipe-IT.

.DESCRIPTION
Retrieves one or all predefined kits from Snipe-IT. Supports search filtering, sorting,
and pagination.

.PARAMETER id
The ID of a specific kit to retrieve.

.PARAMETER search
Search string for filtering kits by name.

.PARAMETER sort
Field to sort results by. Allowed values: id, name, created_at, updated_at, created_by.

.PARAMETER order
Sort direction: asc or desc.

.PARAMETER offset
Starting record offset for pagination.

.PARAMETER limit
Maximum number of records to return per page.

.PARAMETER All
Fetches all pages automatically using pagination.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Get-SnipeitKit

.EXAMPLE
Get-SnipeitKit -id 5
#>
function Get-SnipeitKit {
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'SingleKit', ValueFromPipelineByPropertyName = $true)]
        [int]$id,

        [Parameter(ParameterSetName = 'List')]
        [string]$search,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('id', 'name', 'created_at', 'updated_at', 'created_by')]
        [string]$sort,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('asc', 'desc')]
        [string]$order,

        [Parameter(ParameterSetName = 'List')]
        [int]$offset,

        [Parameter(ParameterSetName = 'List')]
        [int]$limit,

        [Parameter(ParameterSetName = 'List')]
        [switch]$All,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'SingleKit') {
            $params = @{
                Route   = "/api/v1/kits/$id"
                Method  = 'GET'
                Session = $Session
            }
            Invoke-SnipeitMethod @params
        } else {
            $queryParams = @{}
            if ($PSBoundParameters.ContainsKey('search')) { $queryParams['search'] = $search }
            if ($PSBoundParameters.ContainsKey('sort')) { $queryParams['sort'] = $sort }
            if ($PSBoundParameters.ContainsKey('order')) { $queryParams['order'] = $order }
            if ($PSBoundParameters.ContainsKey('offset')) { $queryParams['offset'] = $offset }
            if ($PSBoundParameters.ContainsKey('limit')) { $queryParams['limit'] = $limit }

            $params = @{
                Route   = '/api/v1/kits'
                Method  = 'GET'
                Session = $Session
            }
            if ($queryParams.Count -gt 0) {
                $params['GetParameters'] = $queryParams
            }
            if ($All) {
                $params['Paginate'] = $true
            }

            Invoke-SnipeitMethod @params
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
