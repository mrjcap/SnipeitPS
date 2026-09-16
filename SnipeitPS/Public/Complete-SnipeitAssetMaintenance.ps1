function Complete-SnipeitAssetMaintenance {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$id,

        [AllowNull()]
        [string]$note,

        [SnipeitSession]$Session
    )
    process {
        $body = @{}
        if ($PSBoundParameters.ContainsKey('note')) { $body.note = $PSBoundParameters['note'] }
        foreach ($itemId in $id) {
            if ($PSCmdlet.ShouldProcess("maintenances/$itemId/complete", $MyInvocation.MyCommand.Name)) {
                Invoke-SnipeitMethod -Api "$script:SnipeitApiPrefix/maintenances/$itemId/complete" -Method POST -Body $body -Session $Session
            }
        }
    }
}
