<#
.SYNOPSIS
Tests LDAP connection configuration in Snipe-IT.

.DESCRIPTION
Contacts the Snipe-IT LDAP configuration endpoint via GET /api/v1/settings/ldaptest
to verify binding and query sample users. Requires superuser privileges.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.LdapTestResult

.EXAMPLE
Test-SnipeitLdap
#>
function Test-SnipeitLdap {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Low'
    )]
    [OutputType('SnipeitPS.LdapTestResult')]
    param(
        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ShouldProcess("Snipe-IT LDAP configuration", "Test-SnipeitLdap")) {
            $Parameters = @{
                Route   = "$script:SnipeitApiPrefix/settings/ldaptest"
                Method  = 'Get'
                Session = $Session
            }

            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
