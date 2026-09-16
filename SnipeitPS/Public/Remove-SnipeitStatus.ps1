<#
.SYNOPSIS
Removes a status label from Snipe-IT

.PARAMETER id
Unique ID of the status label to be removed

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Remove-SnipeitStatus -id 1

#>

function Remove-SnipeitStatus () {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "High"
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

    process {
        foreach($status_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/statuslabels/$status_id"
                Method = 'Delete'
                Session = $Session
            }

            if ($PSCmdlet.ShouldProcess("Status ID $status_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
