<#
.SYNOPSIS
Gets files associated with an asset

.PARAMETER id
An ID of a specific Asset

.PARAMETER file_id
An ID of a specific file

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitAssetFile -id 1

#>

function Get-SnipeitAssetFile() {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [int]$id,

        [parameter(ParameterSetName='Get with file ID')]
        [int]$file_id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
}

    process {
        $pathParams = @{ id = $id }
        if ($PSBoundParameters.ContainsKey('file_id')) {
            $route = "$script:SnipeitApiPrefix/hardware/{id}/files/{file_id}"
            $pathParams['file_id'] = $file_id
        } else {
            $route = "$script:SnipeitApiPrefix/hardware/{id}/files"
        }

        $Parameters = @{
            Route         = $route
            PathParameter = $pathParams
            Method        = 'Get'
            Session = $Session
        }

        $result = Invoke-SnipeitMethod @Parameters
        $result
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
