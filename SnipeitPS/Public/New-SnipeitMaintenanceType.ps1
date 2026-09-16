function New-SnipeitMaintenanceType {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ -not [string]::IsNullOrWhiteSpace($_) })]
        [string]$name,

        [SnipeitSession]$Session
    )
    process {
        $body = @{ name = $name }
        if ($PSCmdlet.ShouldProcess("maintenance-types", $MyInvocation.MyCommand.Name)) {
                Invoke-SnipeitMethod -Api "$script:SnipeitApiPrefix/maintenance-types" -Method POST -Body $body -Session $Session
            }
    }
}
