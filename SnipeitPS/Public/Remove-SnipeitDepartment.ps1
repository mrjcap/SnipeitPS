<#
    .SYNOPSIS
    Removes department from Snipe-IT asset system
    .DESCRIPTION
    Removes department or multiple departments from Snipe-IT asset system
    .PARAMETER ID
    Unique ID for department to be removed
    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Remove-SnipeitDepartment -ID 44

    .EXAMPLE
    Get-SnipeitDepartment | Where-object {$_.name -like '*head*'} | Remove-SnipeitDepartment
#>

function Remove-SnipeitDepartment () {
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
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
}
    process {
        foreach($department_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/departments/$department_id"
                Method = 'Delete'
                Session = $Session
            }

            if ($PSCmdlet.ShouldProcess("Department ID $department_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
