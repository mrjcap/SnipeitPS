<#
.SYNOPSIS
Gets a list of Snipe-IT consumables

.PARAMETER search
A text string to search the consumables

.PARAMETER id
An ID of a specific consumable

.PARAMETER name
Optionally restrict consumable results to this name field

.PARAMETER company_id
ID number of company

.PARAMETER category_id
ID number of category

.PARAMETER manufacturer_id
ID number of manufacturer

.PARAMETER location_id
Location ID number of the consumable to filter by

.PARAMETER sort
Sort results by column

.PARAMETER order
Specify the order (asc or desc) you wish to order by on your sort column

.PARAMETER expand
Whether to include detailed information on categories, etc (true) or just the text name (false)

.PARAMETER limit
Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

.PARAMETER offset
Offset to use

.PARAMETER all
Return all results

.PARAMETER url
Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipe-IT system.

.PARAMETER apiKey
Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipe-IT.

.EXAMPLE
Get-SnipeitConsumable -all
Returns all consumables

.EXAMPLE
Get-SnipeitConsumable -search paper
Returns search results containing "paper"

.EXAMPLE
Get-SnipeitConsumable -id 1
Returns specific consumable

#>
function Get-SnipeitConsumable() {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    Param(
        [parameter(ParameterSetName='Search')]
        [string]$search,

        [parameter(ParameterSetName='Get with ID')]
        [int[]]$id,

        [parameter(ParameterSetName='Search')]
        [string]$name,
        
        [parameter(ParameterSetName='Search')]
        [int]$category_id,

        [parameter(ParameterSetName='Search')]
        [int]$company_id,

        [parameter(ParameterSetName='Search')]
        [int]$manufacturer_id,

        [parameter(ParameterSetName='Search')]
        [int]$location_id,

        [parameter(ParameterSetName='Search')]
        [ValidateSet("asc", "desc")]
        [string]$order = "desc",

        [parameter(ParameterSetName='Search')]
        [ValidateSet('id', 'name', 'min_amt', 'order_number', 'serial', 'purchase_date', 'purchase_cost', 'company', 'category', 'qty', 'location', 'image', 'created_at')]
        [string]$sort = "created_at",


        [Parameter(ParameterSetName='Search')]
        [switch]$expand,

        [parameter(ParameterSetName='Search')]
        [int]$limit = 50,

        [parameter(ParameterSetName='Search')]
        [int]$offset,

        [parameter(ParameterSetName='Search')]
        [switch]$all = $false,

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

        $SearchParameter = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

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
        switch ($PSCmdlet.ParameterSetName) {
            'Search' {
                $Parameters = @{
                    Api           = "/api/v1/consumables"
                    Method        = 'Get'
                    GetParameters = $SearchParameter
                }

                if ($all) {
                    $offstart = $(if ($offset) {$offset} Else {0})
                    $callargs = $SearchParameter
                    $callargs.Remove('all')

                    while ($true) {
                        $callargs['offset'] = $offstart
                        $callargs['limit'] = $limit
                        $res=Get-SnipeitConsumable @callargs
                        $res
                        if ($res.count -lt $limit) {
                            break
                        }
                        $offstart = $offstart + $limit
                    }
                } else {
                    $result = Invoke-SnipeitMethod @Parameters
                    $result
                }
            }

            'Get with ID' {
                foreach($consumable_id in $id) {
                    $Parameters = @{
                        Api           = "/api/v1/consumables/$consumable_id"
                        Method        = 'Get'
                        GetParameters = $SearchParameter
                    }

                    $result = Invoke-SnipeitMethod @Parameters
                    $result
                }
            }
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

