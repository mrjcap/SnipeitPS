<#
    .SYNOPSIS
    Checkin asset
    .DESCRIPTION
    Checks asset in from current user/location/asset

    .PARAMETER ID
    Unique ID for asset to checkin

    .PARAMETER status_id
    Change asset status to

    .PARAMETER location_id
    Location ID to change asset location to

    .PARAMETER note
    Notes about checkin

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
    System.Management.Automation.PSCustomObject

    .EXAMPLE
    Reset-SnipeitAssetOwner -ID 44
#>
function Reset-SnipeitAssetOwner() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true)]
        [int]$id,

        [int]$status_id,

        [int]$location_id,

        [string]$note,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = @{}

        if ($PSBoundParameters.ContainsKey('note')) { $Values.Add("note", $note) }
        if ($PSBoundParameters.ContainsKey('location_id')) { $Values.Add("location_id", $location_id) }
        if ($PSBoundParameters.ContainsKey('status_id')) { $Values.Add("status_id", $status_id) }

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/hardware/$id/checkin"
            Method = 'POST'
            Session = $Session
            Body   = $Values
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("Asset ID $id", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
