function Reset-SnipeitLicenseOwner {
    <#
    .SYNOPSIS
    Check in a specific license seat using the license checkin workflow.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$id,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$seat_id,
        [AllowNull()]
        [string]$notes,
        [SnipeitSession]$Session
    )
    process {
        $body = @{ seat_id = $seat_id }
        if ($PSBoundParameters.ContainsKey('notes')) { $body.notes = $PSBoundParameters['notes'] }
        foreach ($licenseId in $id) {
            if ($PSCmdlet.ShouldProcess("License ID $licenseId seat $seat_id", $MyInvocation.MyCommand.Name)) {
                Invoke-SnipeitMethod -Api "$script:SnipeitApiPrefix/licenses/$licenseId/checkin" -Method Post -Body $body -Session $Session
            }
        }
    }
}
