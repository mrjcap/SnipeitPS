<#
.SYNOPSIS
Gets licenses assigned to a specific user

.DESCRIPTION
Lists license assignments for a user. For rows with a nested license,
id is the license inventory ID and seat_id is the assignment ID.
Legacy rows without a nested license remain unchanged. An invalid nested
inventory ID raises SnipeitResourceIdentityError.

.PARAMETER id
An ID of a specific user

.PARAMETER limit
Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

.PARAMETER offset
Offset to use

.PARAMETER all
Return all results, works with -offset and other parameters

.PARAMETER search
Search license names, purchase orders, and order numbers. Serial search requires permission to view license keys.

.PARAMETER sort
Sort by license name or created_at. Defaults to name.

.PARAMETER order
Sort direction: asc or desc. Defaults to asc.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitUserLicense -id 1

#>

function Get-SnipeitUserLicense() {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(mandatory = $true)]
        [int]$id,

        [ValidateRange(1,500)]
        [int]$limit = 50,

        [int]$offset,

        [switch]$all = $false,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [string]$search,

        [ValidateSet('name', 'created_at')]
        [string]$sort = 'name',

        [ValidateSet('asc', 'desc')]
        [string]$order = 'asc'
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$SearchParameter = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters -DefaultExcludeParameter 'id', 'url', 'apiKey', 'Debug', 'Verbose'
    }

    process {
        if ($SearchParameter.ContainsKey('all')) {
            $SearchParameter.Remove('all')
        }

        $Parameters = @{
            Route         = "$script:SnipeitApiPrefix/users/{id}/licenses"
            PathParameter = @{ id = $id }
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
