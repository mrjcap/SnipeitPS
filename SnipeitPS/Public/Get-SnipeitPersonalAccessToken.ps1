<#
.SYNOPSIS
Lists active personal access tokens for the authenticated user.

.DESCRIPTION
Retrieves personal access tokens belonging to the current user via GET /api/v1/account/personal-access-tokens.
Note that the server only returns token metadata (id, name, created_at, etc.); secret bearer strings are only
available once upon creation.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.PersonalAccessToken

.EXAMPLE
Get-SnipeitPersonalAccessToken
#>
function Get-SnipeitPersonalAccessToken {
    [CmdletBinding()]
    [OutputType('SnipeitPS.PersonalAccessToken')]
    param(
        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $Parameters = @{
            Route   = "$script:SnipeitApiPrefix/account/personal-access-tokens"
            Method  = 'Get'
            Session = $Session
        }

        $res = Invoke-SnipeitMethod @Parameters
        if ($null -ne $res) {
            foreach ($token in $res) {
                if ($token -is [System.Management.Automation.PSObject] -and -not $token.PSObject.TypeNames.Contains('SnipeitPS.PersonalAccessToken')) {
                    $token.PSObject.TypeNames.Insert(0, 'SnipeitPS.PersonalAccessToken')
                }
                $token
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
