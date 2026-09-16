<#
    .SYNOPSIS
    Associate a custom field with a fieldset in Snipe-IT

    .PARAMETER id
    Unique ID of the custom field

    .PARAMETER fieldset_id
    ID of the fieldset to associate with

    .PARAMETER required
    Whether the field is required in the fieldset

    .PARAMETER order
    Order of the field within the fieldset

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Register-SnipeitCustomField -id 1 -fieldset_id 5
#>
function Register-SnipeitCustomField() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [int]$id,

        [parameter(mandatory = $true)]
        [int]$fieldset_id,

        [Nullable[bool]]$required,

        [int]$order,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin{
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/fields/$id/associate"
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
