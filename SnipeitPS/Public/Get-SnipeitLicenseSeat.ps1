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


.PARAMETER url
Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipe-IT system.

.PARAMETER apiKey
Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipe-IT.

.EXAMPLE
Get-SnipeitLicenseSeat -id 1


#>

function Get-SnipeitLicenseSeat() {
    [CmdletBinding()]
    Param(

        [parameter(mandatory = $true)]
        [int]$id,

        [int]$seat_id,

        [ValidateRange(1,500)]
        [int]$limit = 50,

        [int]$offset,

        [switch]$all = $false,

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

        $SearchParameter = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters -DefaultExcludeParameter 'id', 'seat_id', 'url', 'apiKey', 'Debug', 'Verbose'

        $api = "/api/v1/licenses/$id/seats"


        if ($seat_id) {
        $api= "/api/v1/licenses/$id/seats/$seat_id"
        }

        $Parameters = @{
            Api           = $api
            Method        = 'Get'
            GetParameters = $SearchParameter
        }

        if ($PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Write-Warning "-apiKey parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyApiKey -apiKey $apikey
        }

        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url) {
            Write-Warning "-url parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyUrl -url $url
        }
    }

    process {
        if ($all) {
            $offstart = $(if ($offset) {$offset} Else {0})
            $callargs = $SearchParameter.Clone()
            $callargs.Remove('all')
            $callargs['id'] = $id
            $callargs['seat_id'] = $seat_id

            while ($true) {
                $callargs['offset'] = $offstart
                $callargs['limit'] = $limit
                $res=Get-SnipeitLicenseSeat @callargs
                $res
                if (@($res).Count -lt $limit) {
                    break
                }
                $offstart = $offstart + $limit
                if ($offstart -gt 10000000) {
                    Write-Warning "Pagination exceeded 10,000,000 offset, stopping to prevent infinite loop"
                    break
                }
            }
        } else {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
        # reset legacy sessions
        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url -or $PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Reset-SnipeitPSLegacyApi
        }
    }
}

