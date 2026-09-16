function Remove-SnipeitMaintenanceType {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$id,

        [SnipeitSession]$Session
    )
    process {
        $body = @{}
        foreach ($itemId in $id) {
            if ($PSCmdlet.ShouldProcess("maintenance-types/$itemId", $MyInvocation.MyCommand.Name)) {
                Invoke-SnipeitMethod -Api "$script:SnipeitApiPrefix/maintenance-types/$itemId" -Method DELETE -Body $body -Session $Session
            }
        }
    }
}
