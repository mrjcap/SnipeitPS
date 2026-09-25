<#
.SYNOPSIS
Tests an individual user's credentials against the configured LDAP server in Snipe-IT.

.DESCRIPTION
Sends test login credentials to POST /api/v1/settings/ldaptestlogin to verify user binding.
Requires superuser privileges. Materializes password only at request construction
and never outputs or logs sensitive credentials.

.PARAMETER Credential
PSCredential containing the LDAP username and password to test.

.PARAMETER Username
The LDAP username to test.

.PARAMETER Password
SecureString containing the LDAP password to test.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.LdapLoginTestResult

.EXAMPLE
Test-SnipeitLdapCredential -Credential (Get-Credential)

.EXAMPLE
$secPass = ConvertTo-SecureString 'Secret123!' -AsPlainText -Force
Test-SnipeitLdapCredential -Username 'jdoe' -Password $secPass
#>
function Test-SnipeitLdapCredential {
    [CmdletBinding(
        DefaultParameterSetName = 'Credential',
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Low'
    )]
    [OutputType('SnipeitPS.LdapLoginTestResult')]
    param(
        [Parameter(ParameterSetName = 'Credential', Mandatory = $true, Position = 0)]
        [Management.Automation.PSCredential]$Credential,

        [Parameter(ParameterSetName = 'Explicit', Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Username,

        [Parameter(ParameterSetName = 'Explicit', Mandatory = $true, Position = 1)]
        [Security.SecureString]$Password,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Credential') {
            $user = $Credential.UserName
            $pass = $Credential.GetNetworkCredential().Password
        } else {
            $user = $Username
            $pass = (New-Object System.Management.Automation.PSCredential("user", $Password)).GetNetworkCredential().Password
        }

        if ($PSCmdlet.ShouldProcess("LDAP user '$user'", "Test-SnipeitLdapCredential")) {
            $body = @{
                ldaptest_user     = $user
                ldaptest_password = $pass
            }

            $Parameters = @{
                Route   = "$script:SnipeitApiPrefix/settings/ldaptestlogin"
                Method  = 'Post'
                Session = $Session
                Body    = $body
            }

            try {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
            finally {
                $pass = $null
                $body['ldaptest_password'] = $null
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
