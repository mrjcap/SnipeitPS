function Get-SnipeitAssetMaintenanceNote {
    [CmdletBinding()]
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
            Invoke-SnipeitMethod -Api "$script:SnipeitApiPrefix/maintenances/$itemId/notes" -Method GET -Body $body -Session $Session
        }
    }
}
