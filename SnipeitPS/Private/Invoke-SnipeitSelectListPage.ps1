function Invoke-SnipeitSelectListPage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Route,

        [Parameter(Mandatory = $false)]
        [hashtable]$GetParameters,

        [Parameter(Mandatory = $false)]
        [object]$Session,

        [switch]$All,

        [switch]$PreserveResponse
    )

    $currentPage = if ($GetParameters -and $GetParameters.ContainsKey('page')) { [int]$GetParameters['page'] } else { 1 }
    $pageParams = if ($GetParameters) { $GetParameters.Clone() } else { @{} }
    $seenPages = [System.Collections.Generic.HashSet[string]]::new()
    $maxPages = 10000
    $pagesFetched = 0

    while ($true) {
        $pageParams['page'] = $currentPage
        $rawResponse = Invoke-SnipeitMethod -Route $Route -GetParameters $pageParams -Session $Session -PreserveResponse

        if ($PreserveResponse -and -not $All) {
            return $rawResponse
        }

        $results = if ($rawResponse -is [System.Collections.IDictionary]) { $rawResponse['results'] } else { $rawResponse.results }
        $pagination = if ($rawResponse -is [System.Collections.IDictionary]) { $rawResponse['pagination'] } else { $rawResponse.pagination }
        $more = if ($null -ne $pagination) {
            if ($pagination -is [System.Collections.IDictionary]) { [bool]$pagination['more'] } else { [bool]$pagination.more }
        } else {
            $false
        }
        $resultCount = if ($null -eq $results) { 0 } else { @($results).Count }

        if ($more -and $resultCount -eq 0) {
            $err = [System.Management.Automation.ErrorRecord]::new(
                [System.InvalidOperationException]::new("Server returned contradictory Select2 response: more=true but results array is empty at page $currentPage."),
                'SnipeitPaginationError',
                [System.Management.Automation.ErrorCategory]::InvalidResult,
                @{ Route = $Route; Page = $currentPage; Response = $rawResponse }
            )
            $PSCmdlet.ThrowTerminatingError($err)
        }

        $pagesFetched++
        if ($All) {
            $returnedPage = if ($rawResponse -is [System.Collections.IDictionary]) { $rawResponse['page'] } else { $rawResponse.page }
            $pageSignature = (@($results | ForEach-Object { [string]$_.id } | Sort-Object) -join ',')
            if (($null -ne $returnedPage -and [int]$returnedPage -ne $currentPage) -or
                ($resultCount -gt 0 -and -not $seenPages.Add($pageSignature))) {
                $err = [System.Management.Automation.ErrorRecord]::new(
                    [System.InvalidOperationException]::new("Select2 pagination returned a repeated or nonadvancing page at page $currentPage."),
                    'SnipeitPaginationError',
                    [System.Management.Automation.ErrorCategory]::InvalidResult,
                    @{ Route = $Route; Page = $currentPage }
                )
                $PSCmdlet.ThrowTerminatingError($err)
            }
        }

        if ($null -ne $results) {
            foreach ($item in $results) {
                if ($item -is [System.Management.Automation.PSObject] -and -not $item.PSObject.TypeNames.Contains('SnipeitPS.SelectListItem')) {
                    $item.PSObject.TypeNames.Insert(0, 'SnipeitPS.SelectListItem')
                }
                $item
            }
        }

        if (-not $All -or -not $more) { break }
        if ($pagesFetched -ge $maxPages) {
            $err = [System.Management.Automation.ErrorRecord]::new(
                [System.InvalidOperationException]::new("Select2 pagination exceeded the $maxPages page limit while more=true."),
                'SnipeitPaginationError',
                [System.Management.Automation.ErrorCategory]::LimitsExceeded,
                @{ Route = $Route; Page = $currentPage }
            )
            $PSCmdlet.ThrowTerminatingError($err)
        }
        $currentPage++
    }
}
