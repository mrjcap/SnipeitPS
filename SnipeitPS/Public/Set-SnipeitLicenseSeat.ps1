<#
    .SYNOPSIS
    Set license seat or checkout license seat
    .DESCRIPTION
    Checkout a specific license seat to a user or asset, or clear assignments with explicit nulls.

    .PARAMETER ID
    Unique ID for license to checkout or array of IDs

    .PARAMETER seat_id
    ID of the license seat

    .PARAMETER assigned_to
    ID of target user

    .PARAMETER asset_id
    ID of target asset

    .PARAMETER note
    Notes about checkout

    .PARAMETER RequestType
    HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Set-SnipeitLicenseSeat -ID 1 -seat_id 1 -assigned_id 3
    Checkout license to user ID 3

    .EXAMPLE
    Set-SnipeitLicenseSeat -ID 1 -seat_id 1 -asset_id 3
    Checkout license to asset ID 3

    .EXAMPLE
    Set-SnipeitLicenseSeat -ID 1 -seat_id 1 -asset_id $null -assigned_id $null
    Checkin license seat ID 1 of license ID 1

#>
function Set-SnipeitLicenseSeat() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [parameter(mandatory = $true)]
        [int]$seat_id,

        [Alias('assigned_id')]

        [Nullable[System.Int32]]$assigned_to,


        [Nullable[System.Int32]]$asset_id,

        [string]$note,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin{
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
        $Values.Remove('seat_id')
        if ($null -ne $assigned_to -and $null -ne $asset_id) {
            throw 'Specify only one non-null assignment target: assigned_to or asset_id.'
        }
        if ($PSBoundParameters.ContainsKey('note')) {
            $Values['notes'] = $note
            $Values.Remove('note')
        }
    }

    process{
        foreach($license_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/licenses/$license_id/seats/$seat_id"
                Method = $RequestType
                Session = $Session
                Body   = $Values
            }

            if ($PSCmdlet.ShouldProcess("License ID $license_id seat $seat_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
