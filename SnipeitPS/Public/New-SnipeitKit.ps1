<#
.SYNOPSIS
Creates a new predefined kit in Snipe-IT.

.DESCRIPTION
Creates a new predefined kit record in Snipe-IT. Only the kit name is writable on creation.

.PARAMETER name
The name of the new predefined kit (maximum 255 characters).

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
New-SnipeitKit -name 'Engineering Onboarding Kit'
#>
function New-SnipeitKit {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(1, 255)]
        [string]$name,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ShouldProcess("Create kit '$name'", "Create kit")) {
            $body = @{
                name = $name
            }
            $params = @{
                Route   = '/api/v1/kits'
                Method  = 'POST'
                Body    = $body
                Session = $Session
            }
            Invoke-SnipeitMethod @params
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
