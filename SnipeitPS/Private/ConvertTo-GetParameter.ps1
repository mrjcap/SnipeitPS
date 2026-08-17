function ConvertTo-GetParameter {

    <#
    .SYNOPSIS
    Generate the GET parameter string for an URL from a hashtable
    #>
    [CmdletBinding()]
    param (
        [Parameter( Position = 0, Mandatory = $true, ValueFromPipeline = $true )]
        [hashtable]$InputObject
    )

    BEGIN {
        $queryParts = [System.Collections.Generic.List[string]]::new()
    }

    PROCESS {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Making HTTP get parameter string out of a hashtable"
        foreach ($key in $InputObject.Keys) {
            $val = $InputObject[$key]
            if ($null -ne $val) {
                $encodedKey = [System.Net.WebUtility]::UrlEncode([string]$key)

                if ($val -is [System.Collections.IEnumerable] -and $val -isnot [string]) {
                    foreach ($item in $val) {
                        if ($null -ne $item) {
                            $encodedItem = [System.Net.WebUtility]::UrlEncode([string]$item)
                            $queryParts.Add("${encodedKey}%5B%5D=$encodedItem")
                        }
                    }
                } elseif ($val -is [bool]) {
                    $boolStr = if ($val) { 'true' } else { 'false' }
                    $queryParts.Add("$encodedKey=$boolStr")
                } else {
                    $encodedVal = [System.Net.WebUtility]::UrlEncode([string]$val)
                    $queryParts.Add("$encodedKey=$encodedVal")
                }
            }
        }
    }

    END {
        if ($queryParts.Count -gt 0) {
            return "?" + ($queryParts -join "&")
        }
        return ""
    }
}
