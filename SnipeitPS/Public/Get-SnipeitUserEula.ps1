<#
.SYNOPSIS
Gets the EULAs for a specific user

.PARAMETER id
An ID of a specific User

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitUserEula -id 1

#>

function Get-SnipeitUserEula() {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(mandatory = $true)]
        [int]$id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
}

    process {
        $Parameters = @{
            Route         = "$script:SnipeitApiPrefix/users/{id}/eulas"
            PathParameter = @{ id = $id }
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
