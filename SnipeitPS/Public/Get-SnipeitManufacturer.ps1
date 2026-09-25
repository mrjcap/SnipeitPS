<#
    .SYNOPSIS
    Gets a list of Snipe-IT Manufacturers

    .PARAMETER search
    A text string to search the Manufacturers data

    .PARAMETER id
    An ID of a specific Manufacturer

    .PARAMETER name
    Optionally restrict Manufacturer results to this name field

    .PARAMETER sort
    Column to sort on

    .PARAMETER order
    Sort order for results, one of 'asc' or 'desc'. Defaults to 'desc'

    .PARAMETER limit
    Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

    .PARAMETER offset
    Offset to use

    .PARAMETER all
    Return all results, works with -offset and other parameters

    .PARAMETER manufacturer_url
Match the manufacturer's website URL.

.PARAMETER support_url
Match the manufacturer's support website URL.

.PARAMETER warranty_lookup_url
Match the manufacturer's warranty lookup URL.

.PARAMETER support_phone
Match a support phone number.

.PARAMETER support_email
Match a support email address.

.PARAMETER deleted
Return soft-deleted manufacturers.

.PARAMETER status
Use deleted to request soft-deleted manufacturers.

.PARAMETER filter
Server text-search filter, taking precedence over search.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Get-SnipeitManufacturer -search HP
    Search all manufacturers for string HP

    .EXAMPLE
    Get-SnipeitManufacturer -id 3
    Returns manufacturer with ID 3

#>
function Get-SnipeitManufacturer() {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(ParameterSetName='Search')]
        [string]$search,

        [parameter(ParameterSetName='Get with ID', ValueFromPipelineByPropertyName = $true)]
        [int]$id,

        [parameter(ParameterSetName='Search')]
        [string]$name,

        [parameter(ParameterSetName='Search')]
        [string]$sort = "created_at",

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
        [string]$manufacturer_url,

        [parameter(ParameterSetName='Search')]
        [string]$support_url,

        [parameter(ParameterSetName='Search')]
        [string]$warranty_lookup_url,

        [parameter(ParameterSetName='Search')]
        [string]$support_phone,

        [parameter(ParameterSetName='Search')]
        [string]$support_email,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$deleted,

        [parameter(ParameterSetName='Search')]
        [string]$status,

        [parameter(ParameterSetName='Search')]
        [string]$filter,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$SearchParameter = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
        if ($SearchParameter.ContainsKey('manufacturer_url')) {
            $SearchParameter['url'] = $SearchParameter['manufacturer_url']
            $SearchParameter.Remove('manufacturer_url')
        }
    }

    process {
        $pathParams = @{}
        if ($PSBoundParameters.ContainsKey('id')) {
            $route = "$script:SnipeitApiPrefix/manufacturers/{id}"
            $pathParams['id'] = $id
        } else {
            $route = "$script:SnipeitApiPrefix/manufacturers"
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
