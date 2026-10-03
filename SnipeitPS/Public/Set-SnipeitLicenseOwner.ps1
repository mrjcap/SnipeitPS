function Set-SnipeitLicenseOwner {
    <#
    .SYNOPSIS
    Check out a license seat to a user or hardware asset.
    .PARAMETER seat_id
    Optional seat ID. Omit or pass null to let the server choose a free seat.
    .PARAMETER assigned_to
    User ID, mutually exclusive with asset_id. The server receives target_type=user.
    .PARAMETER asset_id
    Hardware asset ID. The server receives target_type=asset.
    .PARAMETER reassign
    Permits displacing an occupied seat when the license is reassignable. Sent only
    when explicitly bound. Explicit false is sent as false. This is a checkout
    control, separate from the license's reassignable setting.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'User')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$id,
        [Parameter(Mandatory = $true, ParameterSetName = 'User', ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$assigned_to,
        [Parameter(Mandatory = $true, ParameterSetName = 'Asset', ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$asset_id,
        [Nullable[int]]$seat_id,
        [AllowNull()]
        [string]$notes,
        [SnipeitSession]$Session,
        [switch]$reassign
    )
    process {
        if ($null -ne $seat_id -and $seat_id -lt 1) { throw 'seat_id must be positive or null.' }
        $body = @{}
        if ($PSCmdlet.ParameterSetName -eq 'User') {
            $body.target_type = 'user'
            $body.assigned_to = $assigned_to
        } else {
            $body.target_type = 'asset'
            $body.asset_id = $asset_id
        }
        foreach ($field in @('seat_id', 'notes')) {
            if ($PSBoundParameters.ContainsKey($field)) { $body[$field] = $PSBoundParameters[$field] }
        }
        if ($PSBoundParameters.ContainsKey('reassign')) { $body['reassign'] = [bool]$reassign }
        foreach ($licenseId in $id) {
            if ($PSCmdlet.ShouldProcess("License ID $licenseId", $MyInvocation.MyCommand.Name)) {
                Invoke-SnipeitMethod -Api "$script:SnipeitApiPrefix/licenses/$licenseId/checkout" -Method Post -Body $body -Session $Session
            }
        }
    }
}
