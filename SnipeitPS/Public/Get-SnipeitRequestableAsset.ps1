<#
.SYNOPSIS
Lists hardware assets available for self-service request.

.DESCRIPTION
Queries requestable assets via GET /api/v1/account/requestable/hardware with search, custom fields, and pagination.

.PARAMETER search
Search string to filter requestable hardware.

.PARAMETER sort
Specify column to sort by.

.PARAMETER order
Sort order ('asc' or 'desc'). Defaults to desc.

.PARAMETER limit
Number of records per page. Defaults to 50.

.PARAMETER offset
Page offset.

.PARAMETER all
When specified, streams all results across pages using dispatcher-managed pagination.

.PARAMETER customfields
Hashtable of custom field name/value pairs to query.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Get-SnipeitRequestableAsset -search "laptop" -all
#>
function Get-SnipeitRequestableAsset {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$search,

        [Parameter(Mandatory = $false)]
        [string]$sort,

        [Parameter(Mandatory = $false)]
        [ValidateSet('asc', 'desc')]
        [string]$order = 'desc',

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 500)]
        [int]$limit = 50,

        [Parameter(Mandatory = $false)]
        [int]$offset,

        [Parameter(Mandatory = $false)]
        [switch]$all = $false,

        [Parameter(Mandatory = $false)]
        [hashtable]$customfields,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $queryParams = @{}

        if ($PSBoundParameters.ContainsKey('search')) { $queryParams['search'] = $search }
        if ($PSBoundParameters.ContainsKey('sort')) { $queryParams['sort'] = $sort }
        if ($PSBoundParameters.ContainsKey('order')) { $queryParams['order'] = $order }
        if ($PSBoundParameters.ContainsKey('limit')) { $queryParams['limit'] = $limit }
        if ($PSBoundParameters.ContainsKey('offset')) { $queryParams['offset'] = $offset }

        if ($customfields) {
            foreach ($k in $customfields.Keys) {
                $queryParams[$k] = $customfields[$k]
            }
        }

        $Parameters = @{
            Route         = "$script:SnipeitApiPrefix/account/requestable/hardware"
            Method        = 'Get'
            Session       = $Session
            GetParameters = $queryParams
            Paginate      = [bool]$all
        }

        $res = Invoke-SnipeitMethod @Parameters
        $res
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
