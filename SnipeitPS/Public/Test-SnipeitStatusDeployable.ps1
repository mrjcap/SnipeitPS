<#
.SYNOPSIS
Tests whether a status label is deployable or pending.

.DESCRIPTION
Queries the Snipe-IT status label deployability check via GET /api/v1/statuslabels/{id}/deployable.
The server returns scalar text '1' or '0'. This cmdlet evaluates exact string equality to '1' and emits
a structured SnipeitPS.StatusDeployable object with boolean deployable property.

.PARAMETER id
Unique ID of the status label to check.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.StatusDeployable

.EXAMPLE
Test-SnipeitStatusDeployable -id 1

.EXAMPLE
Get-SnipeitStatus | Test-SnipeitStatusDeployable
#>
function Test-SnipeitStatusDeployable {
    [CmdletBinding()]
    [OutputType('SnipeitPS.StatusDeployable')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $Parameters = @{
            Route       = "$script:SnipeitApiPrefix/statuslabels/{id}/deployable"
            RouteTokens = @{ id = $id }
            Method      = 'Get'
            Session     = $Session
        }

        $res = Invoke-SnipeitMethod @Parameters

        $isDeployable = ($null -ne $res -and $res.ToString().Trim() -eq '1')

        $result = [PSCustomObject]@{
            id         = $id
            deployable = $isDeployable
        }
        $result.PSObject.TypeNames.Insert(0, 'SnipeitPS.StatusDeployable')
        $result
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
