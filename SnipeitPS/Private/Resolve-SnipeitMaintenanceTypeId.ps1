function Resolve-SnipeitMaintenanceTypeId {
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [SnipeitSession]$Session
    )

    if ($Name -match '^\d+$') {
        return [int]$Name
    }

    $types = @(Invoke-SnipeitMethod -Api "$script:SnipeitApiPrefix/maintenance-types" -Method GET `
        -GetParameters @{ name = $Name; limit = 100 } -Paginate -Session $Session)
    $matchingTypes = @($types | Where-Object { [System.Net.WebUtility]::HtmlDecode($_.name) -ceq $Name })
    if ($matchingTypes.Count -ne 1) {
        throw "Expected exactly one maintenance type named '$Name'; found $($matchingTypes.Count). Supply an existing numeric type ID instead."
    }
    return [int]$matchingTypes[0].id
}
