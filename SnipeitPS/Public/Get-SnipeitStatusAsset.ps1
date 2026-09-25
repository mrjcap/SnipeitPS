<#
.SYNOPSIS
Gets assets associated with a specific status label

.PARAMETER id
An ID of a specific Status Label

.PARAMETER limit
Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

.PARAMETER offset
Offset to use

.PARAMETER all
Return all results, works with -offset and other parameters

.PARAMETER order
Sort direction, asc or desc.

.PARAMETER sort
Sort by id or name. Other values use the server's created_at default.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitStatusAsset -id 1

#>

function Get-SnipeitStatusAsset() {
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

        [ValidateSet('asc', 'desc')]
        [string]$order,

        [string]$sort
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
            Route         = "$script:SnipeitApiPrefix/statuslabels/{id}/assetlist"
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
