<#
.SYNOPSIS
Gets End User License Agreements accepted by the user.

.DESCRIPTION
Retrieves accepted EULAs for the authenticated user or for a direct report if the manager view is enabled.
Queries GET /api/v1/account/eulas.

.PARAMETER user_id
Optional ID of a managed user to view accepted EULAs for.
Requires manager_view_enabled on the server and that the authenticated user is the direct manager.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Get-SnipeitAccountEula

.EXAMPLE
Get-SnipeitAccountEula -user_id 5
#>
function Get-SnipeitAccountEula {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$user_id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $queryParams = @{}
        if ($PSBoundParameters.ContainsKey('user_id')) {
            $queryParams['user_id'] = $user_id
        }

        $Parameters = @{
            Route         = "$script:SnipeitApiPrefix/account/eulas"
            Method        = 'Get'
            Session       = $Session
            GetParameters = $queryParams
        }

        $res = Invoke-SnipeitMethod @Parameters
        $res
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
