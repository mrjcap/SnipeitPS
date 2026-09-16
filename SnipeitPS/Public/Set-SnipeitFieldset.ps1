<#
.SYNOPSIS
Set properties of a Snipe-IT Fieldset

.PARAMETER id
An ID of a specific Fieldset

.PARAMETER name
Name of the Fieldset

.PARAMETER RequestType
HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Set-SnipeitFieldset -id 1 -name "Updated Fieldset"

#>

function Set-SnipeitFieldset() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [string]$name,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
    }

    process {
        foreach($fieldset_id in $id) {
            $Parameters = @{
                Api           = "$script:SnipeitApiPrefix/fieldsets/$fieldset_id"
                Method        = $RequestType
                Session = $Session
                Body          = $Values
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
