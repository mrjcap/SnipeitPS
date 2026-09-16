function Set-SnipeitMaintenanceType {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$id,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ -not [string]::IsNullOrWhiteSpace($_) })]
        [string]$name,

        [SnipeitSession]$Session
    )
    process {
        $body = @{ name = $name }
        foreach ($itemId in $id) {
            if ($PSCmdlet.ShouldProcess("maintenance-types/$itemId", $MyInvocation.MyCommand.Name)) {
                Invoke-SnipeitMethod -Api "$script:SnipeitApiPrefix/maintenance-types/$itemId" -Method PATCH -Body $body -Session $Session
            }
        }
    }
}
