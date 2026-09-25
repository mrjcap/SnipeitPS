<#
.SYNOPSIS
Sends a test email to the configured mail recipient.

.DESCRIPTION
Triggers a test email via POST /api/v1/settings/mailtest using the reply-to address
configured on the Snipe-IT server. Requires superuser privileges.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.MailTestResult

.EXAMPLE
Send-SnipeitTestMail
#>
function Send-SnipeitTestMail {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Low'
    )]
    [OutputType('SnipeitPS.MailTestResult')]
    param(
        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ShouldProcess("Snipe-IT configured mail recipient", "Send-SnipeitTestMail")) {
            $Parameters = @{
                Route   = "$script:SnipeitApiPrefix/settings/mailtest"
                Method  = 'Post'
                Session = $Session
                Body    = @{}
            }

            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
