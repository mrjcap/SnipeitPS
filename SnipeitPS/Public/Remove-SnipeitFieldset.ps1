<#
.SYNOPSIS
Removes a fieldset from Snipe-IT

.PARAMETER id
Unique ID of the fieldset to be removed

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Remove-SnipeitFieldset -id 1

#>

function Remove-SnipeitFieldset () {
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
        foreach($fieldset_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/fieldsets/$fieldset_id"
                Method = 'Delete'
                Session = $Session
            }

            if ($PSCmdlet.ShouldProcess("Fieldset ID $fieldset_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
