<#
    .SYNOPSIS
    Disassociate a custom field from a fieldset in Snipe-IT

    .PARAMETER id
    Unique ID of the custom field

    .PARAMETER fieldset_id
    ID of the fieldset to disassociate from

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Unregister-SnipeitCustomField -id 1 -fieldset_id 5
#>
function Unregister-SnipeitCustomField() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "High"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true)]
        [int]$id,

        [parameter(mandatory = $true)]
        [int]$fieldset_id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin{
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/fields/$id/disassociate"
            Method = 'POST'
            Session = $Session
            Body   = $Values
        }
    }

    process{
        if ($PSCmdlet.ShouldProcess("Field ID $id", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
