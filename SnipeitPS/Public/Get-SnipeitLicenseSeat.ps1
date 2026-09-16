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
Offset to use

.PARAMETER all
Return all results, works with -offset and other parameters


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
        [SnipeitSession]$Session
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
