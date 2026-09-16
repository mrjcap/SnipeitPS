function ConvertTo-GetParameter {
    <#
    .SYNOPSIS
    Generate the GET parameter string for an URL from a hashtable
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [hashtable]$InputObject
    )

    process {
        if (-not $InputObject -or $InputObject.Count -eq 0) { return "" }
        $queryParts = [System.Collections.Generic.List[string]]::new()

        foreach ($key in $InputObject.Keys) {
            $val = $InputObject[$key]
            if ($null -eq $val) { continue }

            $encodedKey = [System.Net.WebUtility]::UrlEncode([string]$key)

            if ($val -is [System.Collections.IEnumerable] -and $val -isnot [string]) {
                foreach ($item in $val) {
                    if ($null -ne $item) {
                        $encodedItem = [System.Net.WebUtility]::UrlEncode([string]$item)
                        $queryParts.Add("${encodedKey}%5B%5D=$encodedItem")
                    }
                }
            } elseif ($val -is [bool]) {
                $queryParts.Add("$encodedKey=$(if ($val) { 'true' } else { 'false' })")
            } else {
                $queryParts.Add("$encodedKey=$([System.Net.WebUtility]::UrlEncode([string]$val))")
            }
        }

        if ($queryParts.Count -gt 0) {
            return "?" + ($queryParts -join "&")
        }
        return ""
    }
}
