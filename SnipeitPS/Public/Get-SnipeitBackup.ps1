<#
.SYNOPSIS
Gets a list of available Snipe-IT backups

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitBackup

#>

function Get-SnipeitBackup() {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param(
        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Parameters = @{
            Api           = "$script:SnipeitApiPrefix/settings/backups"
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
