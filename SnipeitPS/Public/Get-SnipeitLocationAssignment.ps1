<#
.SYNOPSIS
Gets assets or accessories assigned to a specific location from Snipe-IT.

.DESCRIPTION
Retrieves assets or accessories checked out or assigned to a target location in Snipe-IT.
Assigned assets are returned in a single unpaginated response; assigned accessories support pagination.

.PARAMETER AssignedType
The type of assigned resource to query.
Allowed values: Asset, Accessory.

.PARAMETER id
The ID of the location.

.PARAMETER offset
Number of records to skip for pagination (supported for Accessory).

.PARAMETER limit
Maximum number of records to return per page (supported for Accessory).

.PARAMETER all
When specified, streams all records across pages using dispatcher-managed pagination (supported for Accessory).

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Get-SnipeitLocationAssignment -AssignedType Asset -id 3

.EXAMPLE
Get-SnipeitLocationAssignment -AssignedType Accessory -id 3 -All
#>
function Get-SnipeitLocationAssignment {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('Asset', 'Accessory')]
        [string]$AssignedType,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$id,

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
        if ($AssignedType -eq 'Asset') {
            $callParams = @{
                Route   = "/api/v1/locations/$id/assigned/assets"
                Method  = 'GET'
                Session = $Session
            }
            Invoke-SnipeitMethod @callParams
        } else {
            $getParams = @{}
            if ($PSBoundParameters.ContainsKey('offset')) { $getParams['offset'] = $offset }
            if ($PSBoundParameters.ContainsKey('limit')) { $getParams['limit'] = $limit }

            $callParams = @{
                Route   = "/api/v1/locations/$id/assigned/accessories"
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
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
