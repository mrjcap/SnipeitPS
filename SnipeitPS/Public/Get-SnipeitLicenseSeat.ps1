<#
.SYNOPSIS
Gets a list of Snipe-IT License Seats or specific Seat

.PARAMETER id
An ID of a specific License

.PARAMETER seat_id
An ID of a specific seat

.PARAMETER limit
Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

.PARAMETER offset
Number of seats to skip. The pinned server resets offsets at or beyond the total count to zero.

.PARAMETER all
Return all results, works with -offset and other parameters.
Offsets at or beyond the total count restart from the first page on the pinned server.


.PARAMETER search
Search license seat assignments.

.PARAMETER status
Restrict seats to available or assigned seats.

.PARAMETER order
Sort direction, asc or desc.

.PARAMETER sort
Sort by assigned_user.department or assigned_user.company. Other values use the server's updated_at default.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitLicenseSeat -id 1


#>

function Get-SnipeitLicenseSeat() {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param(

        [parameter(mandatory = $true)]
        [int]$id,

        [int]$seat_id,

        [ValidateRange(1,500)]
        [int]$limit = 50,

        [int]$offset,

        [switch]$all = $false,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [string]$search,

        [ValidateSet('available', 'assigned')]
        [string]$status,

        [ValidateSet('asc', 'desc')]
        [string]$order,

        [string]$sort
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$SearchParameter = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters -DefaultExcludeParameter 'id', 'seat_id', 'url', 'apiKey', 'Debug', 'Verbose'
    }

    process {
        $pathParams = @{ id = $id }
        if ($PSBoundParameters.ContainsKey('seat_id')) {
            $route = "$script:SnipeitApiPrefix/licenses/{id}/seats/{seat_id}"
            $pathParams['seat_id'] = $seat_id
        } else {
            $route = "$script:SnipeitApiPrefix/licenses/{id}/seats"
        }

        if ($SearchParameter.ContainsKey('all')) {
            $SearchParameter.Remove('all')
        }

        $Parameters = @{
            Route         = $route
            PathParameter = $pathParams
            Method        = 'Get'
            Session = $Session
            GetParameters = $SearchParameter
            Paginate      = [bool]$all
        }

        $result = Invoke-SnipeitMethod @Parameters
        $result
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
