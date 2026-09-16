<#
.SYNOPSIS
Gets the current authenticated user's details

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitCurrentUser

#>

function Get-SnipeitCurrentUser() {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param(
        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Parameters = @{
            Api           = "$script:SnipeitApiPrefix/users/me"
            Method        = 'Get'
            Session = $Session
        }
    }

    process {
        $result = Invoke-SnipeitMethod @Parameters
        $result
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
