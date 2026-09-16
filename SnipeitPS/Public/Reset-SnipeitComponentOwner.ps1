<#
    .SYNOPSIS
    Checkin a component in Snipe-IT

    .DESCRIPTION
    Checks in a component that was previously checked out. The ID parameter
    is the component_assets pivot record ID (not the component ID).
    Use Get-SnipeitComponent to find checked out assets and their pivot IDs.

    .PARAMETER id
    The component_assets pivot record ID for the checkout to reverse.
    This is the ID from the component's assets list, not the component ID itself.

    .PARAMETER checkin_qty
    Quantity of the component to checkin

    .PARAMETER note
    Notes about checkin

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Reset-SnipeitComponentOwner -id 15 -checkin_qty 1

    Checkin 1 unit using the component_assets pivot record ID 15.
#>
function Reset-SnipeitComponentOwner() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true)]
        [int]$id,

        [parameter(mandatory = $true)]
        [int]$checkin_qty,

        [string]$note,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = @{
            "checkin_qty" = $checkin_qty
        }

        if ($PSBoundParameters.ContainsKey('note')) { $Values.Add("note", $note) }

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/components/$id/checkin"
            Method = 'POST'
            Session = $Session
            Body   = $Values
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("Component checkout ID $id", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
