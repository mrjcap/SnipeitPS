<#
.SYNOPSIS
Gets items assigned to a specific asset from Snipe-IT.

.DESCRIPTION
Retrieves child assets, accessories, or components checked out or assigned to a target parent asset in Snipe-IT.

.PARAMETER AssignedType
The type of assigned resource to query.
Allowed values: Asset, Accessory, Component.

.PARAMETER id
The ID of the parent asset.

.PARAMETER sort
Specifies the column by which results are sorted.

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
System.Management.Automation.PSCustomObject

.EXAMPLE
Get-SnipeitAssetAssignment -AssignedType Component -id 10

.EXAMPLE
Get-SnipeitAssetAssignment -AssignedType Asset -id 5 -All
#>
function Get-SnipeitAssetAssignment {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('Asset', 'Accessory', 'Component')]
        [string]$AssignedType,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$id,

        [Parameter(Mandatory = $false)]
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
        $segment = switch ($AssignedType) {
            'Asset'     { 'assets' }
            'Accessory' { 'accessories' }
            'Component' { 'components' }
        }

        $getParams = @{}
        if ($PSBoundParameters.ContainsKey('sort')) { $getParams['sort'] = $sort }
        if ($PSBoundParameters.ContainsKey('order')) { $getParams['order'] = $order }
        if ($PSBoundParameters.ContainsKey('offset')) { $getParams['offset'] = $offset }
        if ($PSBoundParameters.ContainsKey('limit')) { $getParams['limit'] = $limit }

        $callParams = @{
            Route   = "/api/v1/hardware/$id/assigned/$segment"
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
