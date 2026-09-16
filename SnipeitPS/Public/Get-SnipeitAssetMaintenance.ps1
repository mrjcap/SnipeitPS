<#
.SYNOPSIS
Lists Snipe-IT Asset Maintenances

.PARAMETER asset_id
Asset ID of the asset you'd like to return maintenances for

.PARAMETER search
Search string

.PARAMETER sort
Specify the column name you wish to sort by

.PARAMETER order
Specify the order (asc or desc) you wish to order by on your sort column

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
Get-SnipeitAssetMaintenance
.EXAMPLE
Get-SnipeitAssetMaintenance -search "myMachine"

.EXAMPLE
Get-SnipeitAssetMaintenance -asset_id 1
Get maintenance records for a specific asset
#>
function Get-SnipeitAssetMaintenance() {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param(
        [string]$search,

        [int]$asset_id,

        [string]$sort = "created_at",

        [ValidateSet("asc", "desc")]
        [string]$order = "desc",

        [ValidateRange(1,500)]
        [int]$limit = 50,

        [switch]$all = $false,

        [int]$offset,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$SearchParameter = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
    }

    process {
        if ($SearchParameter.ContainsKey('all')) {
            $SearchParameter.Remove('all')
        }

        $Parameters = @{
            Route         = "$script:SnipeitApiPrefix/maintenances"
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
