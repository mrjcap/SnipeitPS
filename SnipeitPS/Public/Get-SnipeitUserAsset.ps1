<#
.SYNOPSIS
Gets assets assigned to a specific user

.PARAMETER id
An ID of a specific user

.PARAMETER limit
Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

.PARAMETER offset
Offset to use

.PARAMETER all
Return all results, works with -offset and other parameters

.PARAMETER category_id
Restrict assigned assets to a category.

.PARAMETER model_id
Restrict assigned assets to one or more models.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitUserAsset -id 1

#>

function Get-SnipeitUserAsset() {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [int]$id,

        [ValidateRange(1,500)]
        [int]$limit = 50,

        [int]$offset,

        [switch]$all = $false,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [int]$category_id,

        [int[]]$model_id
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$SearchParameter = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters -DefaultExcludeParameter 'id', 'url', 'apiKey', 'Debug', 'Verbose'
    }

    process {
        if ($SearchParameter.ContainsKey('model_id') -and $model_id.Count -eq 1) {
            $SearchParameter['model_id'] = $model_id[0]
        }
        if ($SearchParameter.ContainsKey('all')) {
            $SearchParameter.Remove('all')
        }

        $Parameters = @{
            Route         = "$script:SnipeitApiPrefix/users/{id}/assets"
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
