<#
.SYNOPSIS
Gets a list of Snipe-IT Departments

.PARAMETER search
A text string to search the Departments data

.PARAMETER id
An ID of a specific Department

.PARAMETER name
Optionally restrict department results to this department name.

.PARAMETER manager_id
Optionally restrict department results to this manager ID.

.PARAMETER company_id
Optionally restrict department results to this company ID.

.PARAMETER location_id
Optionally restrict department results to this location ID.

.PARAMETER limit
Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

.PARAMETER offset
Offset to use

.PARAMETER all
Return all results, works with -offset and other parameters

.PARAMETER sort
Specify the column name you wish to sort by

.PARAMETER url
Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipe-IT system.

.PARAMETER apiKey
Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipe-IT.

.EXAMPLE
Get-SnipeitDepartment

.EXAMPLE
Get-SnipeitDepartment -search Department1

.EXAMPLE
Get-SnipeitDepartment -id 1

#>

function Get-SnipeitDepartment() {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    Param(
        [parameter(ParameterSetName='Search')]
        [string]$search,

        [parameter(ParameterSetName='Get with ID')]
        [int]$id,

        [parameter(ParameterSetName='Search')]
        [string]$name,
        
        [parameter(ParameterSetName='Search')]
        [int]$manager_id,
        
        [parameter(ParameterSetName='Search')]
        [int]$company_id,
        
        [parameter(ParameterSetName='Search')]
        [int]$location_id,
        
        [parameter(ParameterSetName='Search')]
        [ValidateSet("asc", "desc")]
        [string]$order = "desc",

        [parameter(ParameterSetName='Search')]
        [ValidateRange(1,500)]
        [int]$limit = 50,

        [parameter(ParameterSetName='Search')]
        [int]$offset,

        [parameter(ParameterSetName='Search')]
        [switch]$all = $false,

        [parameter(ParameterSetName='Search')]
        [ValidateSet('id', 'name', 'image', 'users_count', 'created_at')]
        [string]$sort = "created_at",

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"

        Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

        $SearchParameter = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        $api = "$script:SnipeitApiPrefix/departments"

        if ($PSBoundParameters.ContainsKey('id')) {
        $api= "$script:SnipeitApiPrefix/departments/$id"
        }

        $Parameters = @{
            Api           = $api
            Method        = 'Get'
            GetParameters = $SearchParameter
        }

        if ($PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Write-Warning "-apiKey parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyApiKey -apiKey $apiKey
        }

        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url) {
            Write-Warning "-url parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyUrl -url $url
        }
    }
    process {
        if ($all) {
            $offstart = $(if ($PSBoundParameters.ContainsKey('offset')) {$offset} Else {0})
            $callargs = $SearchParameter.Clone()
            $callargs.Remove('all')

            while ($true) {
                $callargs['offset'] = $offstart
                $callargs['limit'] = $limit
                $res=Get-SnipeitDepartment @callargs
                if ($null -ne $res) { $res }
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
        if (($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url) -or ($PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey)) {
            Reset-SnipeitPSLegacyApi
        }
    }
}

