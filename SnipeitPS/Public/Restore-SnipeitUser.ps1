<#
    .SYNOPSIS
    Restores a deleted user in Snipe-IT

    .PARAMETER id
    Unique IDs for users to restore

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Restore-SnipeitUser -id 1
#>
function Restore-SnipeitUser() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin{
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
}

    process{
        foreach($user_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/users/$user_id/restore"
                Method = 'POST'
                Session = $Session
                Body   = @{}
            }

            if ($PSCmdlet.ShouldProcess("User ID $user_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
