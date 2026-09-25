<#
.SYNOPSIS
Retrieves login attempt records from Snipe-IT.

.DESCRIPTION
Queries login audit attempts via GET /api/v1/settings/login-attempts with sorting
and pagination support. Requires superuser privileges.

.PARAMETER sort
The column by which to sort results: id, username, remote_ip, user_agent, successful, created_at.

.PARAMETER order
Sort direction: asc or desc. Defaults to desc.

.PARAMETER limit
Maximum number of records to return in a single page.

.PARAMETER offset
Zero-based record offset for pagination.

.PARAMETER All
When set, automatically streams all login attempts across pages.

.PARAMETER preserveResponse
When set, preserves the raw response envelope.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.LoginAttempt

.EXAMPLE
Get-SnipeitLoginAttempt -limit 10

.EXAMPLE
Get-SnipeitLoginAttempt -sort created_at -order desc -All
#>
function Get-SnipeitLoginAttempt {
    [CmdletBinding()]
    [OutputType('SnipeitPS.LoginAttempt')]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('id', 'username', 'remote_ip', 'user_agent', 'successful', 'created_at')]
        [string]$sort,

        [Parameter(Mandatory = $false)]
        [ValidateSet('asc', 'desc')]
        [string]$order,

        [Parameter(Mandatory = $false)]
        [int]$limit,

        [Parameter(Mandatory = $false)]
        [int]$offset,

        [switch]$All,

        [switch]$preserveResponse,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $getParams = @{}
        if ($PSBoundParameters.ContainsKey('sort')) { $getParams['sort'] = $sort }
        if ($PSBoundParameters.ContainsKey('order')) { $getParams['order'] = $order }
        if ($PSBoundParameters.ContainsKey('limit')) { $getParams['limit'] = $limit }
        if ($PSBoundParameters.ContainsKey('offset')) { $getParams['offset'] = $offset }

        $Parameters = @{
            Route            = "$script:SnipeitApiPrefix/settings/login-attempts"
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
