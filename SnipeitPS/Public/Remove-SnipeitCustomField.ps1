<#
    .SYNOPSIS
    Removes custom field from Snipe-IT asset system
    .DESCRIPTION
    Removes custom field or multiple fields from Snipe-IT asset system
    .PARAMETER ID
    Unique ID for field to be removed
    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Remove-SnipeitCustomField -ID 44 -Verbose

    .EXAMPLE
    Get-SnipeitCustomField | Where-object {$_.name -like '*address*'} | Remove-SnipeitCustomField
#>

function Remove-SnipeitCustomField () {
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
        foreach($field_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/fields/$field_id"
                Method = 'Delete'
                Session = $Session
            }

            if ($PSCmdlet.ShouldProcess("Field ID $field_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
