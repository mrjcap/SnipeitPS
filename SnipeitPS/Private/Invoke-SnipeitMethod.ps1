<#
    .SYNOPSIS
    Make an API request to Snipe-IT

    .PARAMETER Api
    API part of URL. prefix with slash ie. "$script:SnipeitApiPrefix/hardware"
    Legacy parameter retained for backward compatibility.

    .PARAMETER Route
    Route template with {token} placeholders (e.g. "/api/v1/hardware/bytag/{tag}").
    Tokens are automatically escaped via [System.Uri]::EscapeDataString().

    .PARAMETER PathParameter
    Hashtable of token names to values for Route template resolution.

    .PARAMETER Method
    Method of the invocation, one of the following: "GET", "POST", "PUT", "PATCH" or "DELETE"

    .PARAMETER Body
    Request body as hashtable. Needed for post, put and patch

    .PARAMETER GetParameters
    Get-Parameters as hashtable.

    .PARAMETER Paginate
    When set, automatically fetches all pages by incrementing offset and streaming
    each record to the pipeline as it arrives.

    .PARAMETER PreserveResponse
    Returns the original success response envelope instead of extracting payload or rows.
    Business errors still use the error stream, with the response in TargetObject.
    Bulk responses always preserve status, messages, and results, independent of this switch.

    .PARAMETER Session
    Optional SnipeitSession instance or session hashtable. Defaults to global session if omitted.
#>

function Invoke-SnipeitMethod {
    [CmdletBinding()]
    [OutputType(
        [PSObject]
    )]

    param (

        [Parameter(Mandatory = $false)]
        [string]$Api,

        [Parameter(Mandatory = $false)]
        [string]$Route,

        [Parameter(Mandatory = $false)]
        [Alias('PathParameters')]
        [Hashtable]$PathParameter,

        [ValidateSet("GET", "POST", "PUT", "PATCH", "DELETE")]
        [string]$Method = "GET",

        [Hashtable]$Body,

        [Hashtable]$GetParameters,

        [switch]$Paginate,

        [switch]$PreserveResponse,

        [Parameter(Mandatory = $false)]
        [object]$Session
    )

    BEGIN {
        $activeSession = if ($null -ne $Session) { $Session } else { $SnipeitPSSession }

        # Helper to read session properties whether dictionary or object
        $sessUrl = if ($activeSession -is [System.Collections.IDictionary]) { $activeSession['url'] } else { $activeSession.Url }
        $sessApiKey = if ($activeSession -is [System.Collections.IDictionary]) { $activeSession['apiKey'] } else { $activeSession.ApiKey }

        if ($null -ne $sessUrl -and $null -ne $sessApiKey) {
            $parsedUrl = $null
            if (-not [System.Uri]::TryCreate([string]$sessUrl, [System.UriKind]::Absolute, [ref]$parsedUrl) -or
                $parsedUrl.Scheme -ne 'https') {
                throw [System.ArgumentException]::new('Snipe-IT URL must be an absolute HTTPS URL.', 'Session.Url')
            }

            [string]$Url = ([string]$sessUrl).TrimEnd('/')
            Write-Debug "Invoke-SnipeitMethod url: $Url"
            if ($sessApiKey -is [System.Security.SecureString]) {
                if ($script:IsPowerShell7) {
                    $Token = ConvertFrom-SecureString -SecureString $sessApiKey -AsPlainText
                } else {
                    $Token = (New-Object System.Management.Automation.PSCredential("user", $sessApiKey)).GetNetworkCredential().Password
                }
            } else {
                $Token = [string]$sessApiKey
            }
        } else {
            throw "Please use Connect-SnipeitPS to set up a connection before any other commands."
        }

        # Validation of parameters
        if (($Method -in ("POST", "PUT", "PATCH")) -and (-not $Body)) {
            $message = "The following parameters are required when using the ${Method} parameter: Body."
            throw [System.ArgumentException]::new($message)
        }

        # Validate that at least -Api or -Route was provided
        if (-not $Api -and -not $Route) {
            throw [System.ArgumentException]::new("Either -Api or -Route must be specified.")
        }

        # Route template resolution: replace {token} placeholders with escaped values
        if ($Route) {
            $resolvedRoute = $Route
            if ($PathParameter) {
                foreach ($key in $PathParameter.Keys) {
                    $rawValue = [string]$PathParameter[$key]
                    $unescaped = try { [System.Uri]::UnescapeDataString($rawValue) } catch { $rawValue }
                    if ($rawValue -match '\.\.' -or $unescaped -match '\.\.') {
                        throw [System.ArgumentException]::new("Path parameter '$key' contains invalid traversal sequence: '$rawValue'")
                    }
                    $escapedValue = [System.Uri]::EscapeDataString($rawValue)
                    $escapedKey = [System.Text.RegularExpressions.Regex]::Escape($key)
                    $resolvedRoute = $resolvedRoute -replace "\{$escapedKey\}", $escapedValue
                }
            }
            $apiUri = "$Url$resolvedRoute"
        } else {
            # Legacy -Api parameter path
            $apiUri = "$Url$Api"
        }
    }

    PROCESS {
        # Defense-in-depth: block mutative HTTP methods under -WhatIf (ADR 0009)
        # Exempt read-only endpoints implemented by Snipe-IT via POST (Picard amendment)
        $isReadOnlyPost = ($Method -eq 'POST' -and $resolvedRoute -match '(?i)/fieldsets/\{?[^/]+\}?/fields')
        if ($WhatIfPreference -and ($Method -in ("POST", "PUT", "PATCH", "DELETE")) -and -not $isReadOnlyPost) {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] WhatIf active: skipping $Method to $apiUri"
            return
        }

        # Preserve original GetParameters for pagination before they get consumed
        $GetParameters_Original = if ($GetParameters) { $GetParameters.Clone() } else { $null }

        if ($GetParameters -and ($apiUri -notlike "*[?]*")) {
            Write-Debug "Using `$GetParameters: $($GetParameters | Out-String)"
            [string]$apiUri = $apiUri + (ConvertTo-GetParameter $GetParameters)
            $GetParameters = $null
        }

        # Per-request header isolation to prevent pipeline mutation leakage
        $_headers = @{
            "Authorization" = "Bearer $($Token)"
            'Content-Type'  = 'application/json; charset=utf-8'
            "Accept"        = "application/json"
            "User-Agent"    = "SnipeitPS/$script:SnipeitModuleVersion"
        }

        $splatParameters = @{
            Uri                = $apiUri
            Method             = $Method
            Headers            = $_headers
            UseBasicParsing    = $true
            MaximumRedirection = 0
            ErrorAction        = 'Stop'
        }

        $effectiveBody = if ($null -ne $Body) { $Body.Clone() } else { $null }

        # Send image requests as multipart/form-data if supported
        if ($null -ne $effectiveBody -and $effectiveBody.ContainsKey('image')) {
            try {
                if ($script:IsPowerShell7) {
                    $effectiveBody['image'] = Get-Item $effectiveBody['image'] -ErrorAction Stop
                    $effectiveBody['_method'] = $Method
                    $splatParameters["Method"] = 'POST'
                    $splatParameters["Form"] = $effectiveBody
                    $_headers.Remove('Content-Type')
                } else {
                    $mimetype = 'application/octet-stream'
                    try {
                        Add-Type -AssemblyName "System.Web"
                        $mimetype = [System.Web.MimeMapping]::GetMimeMapping($effectiveBody['image'])
                    } catch {
                        Write-Debug "MimeMapping resolution failed for '$($effectiveBody['image'])', defaulting to $($mimetype). Error: $_"
                    }
                    $effectiveBody['image'] = 'data:' + $mimetype + ';base64,' + [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($effectiveBody['image']))
                }
            } catch {
                Write-Error "Failed to process image file '$($effectiveBody['image'])': $_"
                return
            }
        }

        # Send file upload requests as multipart/form-data
        if ($null -ne $effectiveBody -and $effectiveBody.ContainsKey('file')) {
            try {
                if ($script:IsPowerShell7) {
                    $effectiveBody['file[]'] = Get-Item $effectiveBody['file'] -ErrorAction Stop
                    $effectiveBody.Remove('file')
                    $effectiveBody['_method'] = $Method
                    $splatParameters["Method"] = 'POST'
                    $splatParameters["Form"] = $effectiveBody
                    $_headers.Remove('Content-Type')
                } else {
                    throw "File uploads require PowerShell 7.0 or later."
                }
            } catch {
                Write-Error "Failed to process file '$($effectiveBody['file'])': $_"
                return
            }
        }

        if ($effectiveBody -and -not $splatParameters.ContainsKey('Form')) {
            $splatParameters["Body"] = [System.Text.Encoding]::UTF8.GetBytes(($effectiveBody | ConvertTo-Json -Depth 10))
        }

        if ($DebugPreference -ne 'SilentlyContinue' -and $null -ne $effectiveBody) {
            $debugBody = $effectiveBody.Clone()
            foreach ($key in @('password', 'password_confirmation', 'apiKey', 'api_key', 'token', 'secret')) {
                if ($debugBody.ContainsKey($key)) {
                    $debugBody[$key] = '[REDACTED]'
                }
            }
            Write-Debug "$($debugBody | ConvertTo-Json -Depth 4)"
        }

        # Request throttling
        $tLimit = if ($activeSession -is [System.Collections.IDictionary]) { [int]$activeSession['throttleLimit'] } else { [int]$activeSession.ThrottleLimit }
        $tPeriod = if ($activeSession -is [System.Collections.IDictionary]) { [int]$activeSession['throttlePeriod'] } else { [int]$activeSession.ThrottlePeriod }
        $tMode = if ($activeSession -is [System.Collections.IDictionary]) { [string]$activeSession['throttleMode'] } else { [string]$activeSession.ThrottleMode }
        $tThreshold = if ($activeSession -is [System.Collections.IDictionary]) { [int]$activeSession['throttleThreshold'] } else { [int]$activeSession.ThrottleThreshold }

        if ($tLimit -gt 0) {
            Write-Verbose "Check for request throttling"
            $nowFileTime = (Get-Date).ToFileTime()
            $cutoff = $nowFileTime - ($tPeriod * 10000)

            # Ensure throttledRequests is Queue[long]
            $queue = if ($activeSession -is [System.Collections.IDictionary]) { $activeSession['throttledRequests'] } else { $activeSession.ThrottledRequests }
            if ($null -eq $queue -or $queue -isnot [System.Collections.Generic.Queue[long]]) {
                $existing = if ($null -ne $queue) { [long[]]$queue } else { @() }
                $queue = [System.Collections.Generic.Queue[long]]::new()
                foreach ($t in $existing) {
                    if ($t -gt $cutoff -and $t -le $nowFileTime) {
                        $queue.Enqueue($t)
                    }
                }
                if ($activeSession -is [System.Collections.IDictionary]) { $activeSession['throttledRequests'] = $queue } else { $activeSession.ThrottledRequests = $queue }
            }

            $naptime = 0
            [System.Threading.Monitor]::Enter($queue)
            try {
                while ($queue.Count -gt 0 -and $queue.Peek() -le $cutoff) {
                    [void]$queue.Dequeue()
                }

                $reqCount = $queue.Count
                switch ($tMode) {
                    "Burst" {
                        if ($reqCount -ge $tLimit -and $reqCount -gt 0) {
                            $oldest = $queue.Peek()
                            $elapsedMs = [Math]::Round(($nowFileTime - $oldest) / 10000)
                            $naptime = [Math]::Max(0, ($tPeriod - $elapsedMs))
                            if ($naptime -eq 0) { $naptime = 1 }
                        }
                    }

                    "Constant" {
                        $lastTime = if ($activeSession -is [System.Collections.IDictionary]) { [long]$activeSession['lastRequestFileTime'] } else { [long]$activeSession.LastRequestFileTime }
                        if ($lastTime -gt 0 -and $tLimit -gt 0) {
                            $prevRequestTime = [Math]::Round(($nowFileTime - $lastTime) / 10000)
                            $intervalMs = [Math]::Round($tPeriod / $tLimit)
                            $naptime = [Math]::Max(0, ($intervalMs - $prevRequestTime))
                        }
                    }

                    "Adaptive" {
                        $unThrottledRequests = $tLimit * ($tThreshold / 100)
                        if ($reqCount -ge $unThrottledRequests -and $reqCount -gt 0) {
                            $oldest = $queue.Peek()
                            $elapsedMs = [Math]::Round(($nowFileTime - $oldest) / 10000)
                            $remainingPeriodMs = [Math]::Max(0, ($tPeriod - $elapsedMs))
                            $remaining = $tLimit - $reqCount
                            if ($remaining -lt 1) { $remaining = 1 }
                            $naptime = [Math]::Round($remainingPeriodMs / $remaining)
                            if ($naptime -eq 0 -and $reqCount -ge $tLimit) {
                                $naptime = 1
                            }
                        }
                    }
                }
                $scheduledTime = $nowFileTime + ($naptime * 10000)
                $queue.Enqueue($scheduledTime)
                if ($activeSession -is [System.Collections.IDictionary]) {
                    $activeSession['lastRequestFileTime'] = $scheduledTime
                } else {
                    $activeSession.LastRequestFileTime = $scheduledTime
                }
            } finally {
                [System.Threading.Monitor]::Exit($queue)
            }

            if ($naptime -gt 0) {
                $safeNap = [int][Math]::Min([int]::MaxValue, [Math]::Max(0, $naptime))
                Write-Verbose "Throttling request for $safeNap ms"
                Start-Sleep -Milliseconds $safeNap
            }
        }

        # Invoke the API
        $webResponse = $null
        $statusCode = $null
        try {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Invoking method $Method to URI $apiUri"
            $debugSplat = $splatParameters.Clone()
            if ($debugSplat.ContainsKey('Headers') -and $debugSplat['Headers'].ContainsKey('Authorization')) {
                $debugSplat['Headers'] = $debugSplat['Headers'].Clone()
                $debugSplat['Headers']['Authorization'] = 'Bearer [REDACTED]'
            }
            if ($debugSplat.ContainsKey('Form') -and $debugSplat['Form'] -is [System.Collections.IDictionary]) {
                $sanitizedForm = $debugSplat['Form'].Clone()
                foreach ($k in @('password', 'password_confirmation', 'apiKey', 'api_key', 'token', 'secret')) {
                    if ($sanitizedForm.ContainsKey($k)) { $sanitizedForm[$k] = '[REDACTED]' }
                }
                $debugSplat['Form'] = $sanitizedForm
            }
            if ($debugSplat.ContainsKey('Body') -and $debugSplat['Body'] -is [byte[]]) {
                $debugSplat['Body'] = '[BYTE_ARRAY]'
            }
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoke-WebRequest with: $($debugSplat | Out-String)"
            $webResponse = Invoke-RestMethod @splatParameters
        }
        catch {
            $httpError = $_
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Failed to get an answer from the server"
            $responseBody = $null

            # Extract status code safely across PS5.1 and PS7+
            try {
                if ($null -ne $httpError.Exception.Response) {
                    $statusCode = [int]$httpError.Exception.Response.StatusCode
                }
            } catch {
                Write-Debug "Failed to extract HTTP status code from error response: $_"
            }

            if ($script:IsPowerShell7) {
                if ($httpError.ErrorDetails -and $httpError.ErrorDetails.Message) {
                    $responseBody = $httpError.ErrorDetails.Message
                }
            } else {
                $stream = $null
                $reader = $null
                try {
                    $errResponse = $httpError.Exception.Response
                    if ($null -ne $errResponse) {
                        $stream = $errResponse.GetResponseStream()
                        if ($null -ne $stream) {
                            $reader = [System.IO.StreamReader]::new($stream)
                            $responseBody = $reader.ReadToEnd()
                        }
                    }
                } catch {
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Could not read error response stream: $_"
                } finally {
                    if ($null -ne $reader) { $reader.Dispose() }
                    if ($null -ne $stream) { $stream.Dispose() }
                }
            }

            # Sanitize HTML proxy errors (e.g., 502/504)
            if ($responseBody -match '(?si)<html.*?>.*?<title>(.*?)</title>') {
                $htmlTitle = $matches[1].Trim()
                $responseBody = "Server returned HTML error ($htmlTitle). Please check reverse proxy / server logs."
            } elseif ($responseBody -match '(?si)<html') {
                $responseBody = "Server returned HTML error response instead of JSON. Please check server availability."
            }

            if ($responseBody) {
                try {
                    $webResponse = $responseBody | ConvertFrom-Json
                } catch {
                    $codeDisplay = if ($statusCode) { "HTTP $statusCode " } else { "" }
                    Write-Error "${codeDisplay}error from Snipe-IT API: $responseBody"
                    $webResponse = $null
                }
            } else {
                $codeDisplay = if ($statusCode) { "HTTP $statusCode " } else { "" }
                $transportError = [System.Management.Automation.ErrorRecord]::new(
                    [System.Exception]::new("${codeDisplay}error from Snipe-IT API with no response body: $($httpError.Exception.Message)", $httpError.Exception),
                    'SnipeitTransportError',
                    [System.Management.Automation.ErrorCategory]::ConnectionError,
                    $apiUri
                )
                $PSCmdlet.WriteError($transportError)
                $webResponse = $null
            }
        }

        Write-Debug "[$($MyInvocation.MyCommand.Name)] Executed WebRequest."

        if ($webResponse) {
            try {
                $statusVal     = if ($webResponse -is [System.Collections.IDictionary]) { $webResponse['status'] } else { $webResponse.status }
                $messagesVal   = if ($webResponse -is [System.Collections.IDictionary]) { $webResponse['messages'] } else { $webResponse.messages }
                $statusCodeVal = if ($webResponse -is [System.Collections.IDictionary]) { $webResponse['StatusCode'] } else { $webResponse.StatusCode }
                $hasPayload    = ($webResponse -is [System.Collections.IDictionary] -and $webResponse.Contains('payload')) -or ($null -ne $webResponse.PSObject.Properties['payload'])
                $hasRows       = ($webResponse -is [System.Collections.IDictionary] -and $webResponse.Contains('rows')) -or ($null -ne $webResponse.PSObject.Properties['rows'])
                $hasTotal      = ($webResponse -is [System.Collections.IDictionary] -and $webResponse.Contains('total')) -or ($null -ne $webResponse.PSObject.Properties['total'])

                # Helper to tag PSTypeName based on route target
                $targetRoute = if ($Route) { $Route } else { $Api }
                $targetTypeName = $null
                if ($targetRoute -match '(?i)/hardware|/audit') { $targetTypeName = 'SnipeitPS.Asset' }
                elseif ($targetRoute -match '(?i)/users') { $targetTypeName = 'SnipeitPS.User' }
                elseif ($targetRoute -match '(?i)/licenses') { $targetTypeName = 'SnipeitPS.License' }
                elseif ($targetRoute -match '(?i)/models') { $targetTypeName = 'SnipeitPS.Model' }
                elseif ($targetRoute -match '(?i)/categories') { $targetTypeName = 'SnipeitPS.Category' }
                elseif ($targetRoute -match '(?i)/locations') { $targetTypeName = 'SnipeitPS.Location' }
                elseif ($targetRoute -match '(?i)/statuslabels|/status') { $targetTypeName = 'SnipeitPS.Status' }
                elseif ($targetRoute -match '(?i)/companies') { $targetTypeName = 'SnipeitPS.Company' }
                elseif ($targetRoute -match '(?i)/suppliers') { $targetTypeName = 'SnipeitPS.Supplier' }
                elseif ($targetRoute -match '(?i)/departments') { $targetTypeName = 'SnipeitPS.Department' }
                elseif ($targetRoute -match '(?i)/accessories') { $targetTypeName = 'SnipeitPS.Accessory' }
                elseif ($targetRoute -match '(?i)/consumables') { $targetTypeName = 'SnipeitPS.Consumable' }
                elseif ($targetRoute -match '(?i)/components') { $targetTypeName = 'SnipeitPS.Component' }
                elseif ($targetRoute -match '(?i)/groups') { $targetTypeName = 'SnipeitPS.Group' }
                elseif ($targetRoute -match '(?i)/fields(?:/|$)|/customfields(?:/|$)') { $targetTypeName = 'SnipeitPS.CustomField' }
                elseif ($targetRoute -match '(?i)/fieldsets') { $targetTypeName = 'SnipeitPS.Fieldset' }
                elseif ($targetRoute -match '(?i)/maintenances') { $targetTypeName = 'SnipeitPS.AssetMaintenance' }
                elseif ($targetRoute -match '(?i)/activity') { $targetTypeName = 'SnipeitPS.Activity' }

                if ($statusVal -eq "error") {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] An error response was received ... resolving"
                    # Format validation dictionaries into readable messages (ADR 0007)
                    if ($messagesVal -is [System.Management.Automation.PSCustomObject] -or $messagesVal -is [System.Collections.IDictionary]) {
                        $formattedParts = [System.Collections.Generic.List[string]]::new()
                        $msgProps = if ($messagesVal -is [System.Collections.IDictionary]) {
                            $messagesVal.GetEnumerator()
                        } else {
                            $messagesVal.PSObject.Properties
                        }
                        foreach ($prop in $msgProps) {
                            $fieldName = if ($null -ne $prop.Key) { $prop.Key } elseif ($null -ne $prop.Name) { $prop.Name } else { "$prop" }
                            $fieldErrors = $prop.Value
                            if ($fieldErrors -is [System.Collections.IEnumerable] -and $fieldErrors -isnot [string]) {
                                foreach ($msg in $fieldErrors) {
                                    $formattedParts.Add("Validation failed for '$fieldName': $msg")
                                }
                            } else {
                                $formattedParts.Add("Validation failed for '$fieldName': $fieldErrors")
                            }
                        }
                        $errMsg = $formattedParts -join [System.Environment]::NewLine
                    } else {
                        $errMsg = if ($messagesVal) { ($messagesVal | Out-String).Trim() } else { "Snipe-IT API returned error status." }
                    }
                    $targetPayload = if ($webResponse -is [System.Management.Automation.PSCustomObject]) {
                        $webResponse.PSObject.Copy()
                    } else {
                        $webResponse
                    }
                    if ($null -ne $targetPayload -and $targetPayload.PSObject.Properties['payload']) {
                        $payloadCopy = if ($targetPayload.payload -is [System.Management.Automation.PSCustomObject]) {
                            $targetPayload.payload.PSObject.Copy()
                        } else {
                            $targetPayload.payload
                        }
                        foreach ($k in @('password', 'password_confirmation', 'apiKey', 'api_key', 'token', 'secret')) {
                            if ($null -ne $payloadCopy -and $payloadCopy.PSObject.Properties[$k]) {
                                $payloadCopy.$k = '[REDACTED]'
                            }
                        }
                        $targetPayload.payload = $payloadCopy
                    }
                    $errRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.Exception]::new($errMsg),
                        'SnipeitApiError',
                        [System.Management.Automation.ErrorCategory]::InvalidData,
                        $targetPayload
                    )
                    Write-Error -ErrorRecord $errRecord
                } elseif ($statusCodeVal -eq 'Unauthorized' -or $statusCodeVal -eq 401) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] An Unauthorized response was received"
                    Write-Error "Cannot connect to Snipe-IT: Unauthorized."
                    return
                } else {
                    Write-Verbose "Status: $statusVal"
                    Write-Verbose "Messages: $messagesVal"

                    $hasResults = if ($webResponse -is [System.Collections.IDictionary]) {
                        $webResponse.Contains('results')
                    } else {
                        $null -ne $webResponse.PSObject.Properties['results']
                    }
                    if ($hasResults -or $PreserveResponse) {
                        $webResponse
                    # Dispatcher-managed pagination streaming (ADR 0005)
                    } elseif ($Paginate -and $hasRows -and $hasTotal) {
                        $totalRecords = if ($webResponse -is [System.Collections.IDictionary]) { [int]$webResponse['total'] } else { [int]$webResponse.total }
                        [array]$pageRows = if ($webResponse -is [System.Collections.IDictionary]) { $webResponse['rows'] } else { $webResponse.rows }
                        $pageLimit = if ($GetParameters_Original -and $GetParameters_Original.ContainsKey('limit')) {
                            [int]$GetParameters_Original['limit']
                        } else { 50 }

                        # Stream first page
                        if ($null -ne $pageRows -and $pageRows.Count -gt 0) {
                            foreach ($row in $pageRows) {
                                if ($targetTypeName -and $row -is [System.Management.Automation.PSObject] -and -not $row.PSObject.TypeNames.Contains($targetTypeName)) {
                                    $row.PSObject.TypeNames.Insert(0, $targetTypeName)
                                }
                                $row
                            }
                        }

                        # Paginate remaining pages
                        $offset = if ($GetParameters_Original -and $GetParameters_Original.ContainsKey('offset')) {
                            [int]$GetParameters_Original['offset'] + $pageRows.Count
                        } else { $pageRows.Count }
                        $maxOffset = [Math]::Min($totalRecords, 10000000) # Hard ceiling to prevent runaway

                        while ($offset -lt $maxOffset -and $pageRows.Count -gt 0) {
                            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Paginating: offset=$offset / total=$totalRecords"

                            # Build next page URL
                            $baseUri = if ($Route) { "$Url$resolvedRoute" } else { "$Url$Api" }
                            $nextParams = if ($GetParameters_Original) { $GetParameters_Original.Clone() } else { @{} }
                            $nextParams['offset'] = $offset
                            if (-not $nextParams.ContainsKey('limit')) { $nextParams['limit'] = $pageLimit }
                            $nextUri = $baseUri + (ConvertTo-GetParameter $nextParams)

                            $nextSplat = $splatParameters.Clone()
                            $nextSplat['Uri'] = $nextUri

                            try {
                                $nextResponse = Invoke-RestMethod @nextSplat
                            } catch {
                                # Picard amendment: mid-stream failure must be terminating
                                $paginationError = [System.Management.Automation.ErrorRecord]::new(
                                    $_.Exception,
                                    'SnipeitPaginationError',
                                    [System.Management.Automation.ErrorCategory]::ConnectionError,
                                    @{ Offset = $offset; TotalRecords = $totalRecords; Uri = $nextUri }
                                )
                                $PSCmdlet.ThrowTerminatingError($paginationError)
                            }

                            [array]$pageRows = if ($nextResponse -is [System.Collections.IDictionary]) { $nextResponse['rows'] } else { $nextResponse.rows }
                            if ($null -ne $pageRows -and $pageRows.Count -gt 0) {
                                foreach ($row in $pageRows) {
                                    if ($targetTypeName -and $row -is [System.Management.Automation.PSObject] -and -not $row.PSObject.TypeNames.Contains($targetTypeName)) {
                                        $row.PSObject.TypeNames.Insert(0, $targetTypeName)
                                    }
                                    $row
                                }
                                $offset += $pageRows.Count
                            } else {
                                break
                            }
                        }
                    } else {
                        # Non-paginated: standard result extraction and emission
                        if ($hasPayload) {
                            $result = if ($webResponse -is [System.Collections.IDictionary]) { $webResponse['payload'] } else { $webResponse.payload }
                        } elseif ($hasRows) {
                            $rows = if ($webResponse -is [System.Collections.IDictionary]) { $webResponse['rows'] } else { $webResponse.rows }
                            if ($null -eq $rows -or ($rows -is [System.Collections.ICollection] -and $rows.Count -eq 0)) {
                                $result = @()
                            } else {
                                $result = $rows
                            }
                        } elseif ($statusVal -eq 'success' -and $messagesVal) {
                            $result = if ($webResponse -is [System.Collections.IDictionary]) { $webResponse['payload'] } else { $webResponse.payload }
                        } elseif ($hasTotal -and ((if ($webResponse -is [System.Collections.IDictionary]) { $webResponse['total'] } else { $webResponse.total }) -eq 0)) {
                            $result = @()
                        } else {
                            $result = $webResponse
                        }

                        if ($result -is [System.Collections.IEnumerable] -and $result -isnot [string] -and $result -isnot [System.Collections.IDictionary]) {
                            foreach ($item in $result) {
                                if ($targetTypeName -and $item -is [System.Management.Automation.PSObject] -and -not $item.PSObject.TypeNames.Contains($targetTypeName)) {
                                    $item.PSObject.TypeNames.Insert(0, $targetTypeName)
                                }
                                $item
                            }
                        } else {
                            if ($targetTypeName -and $result -is [System.Management.Automation.PSObject] -and -not $result.PSObject.TypeNames.Contains($targetTypeName)) {
                                $result.PSObject.TypeNames.Insert(0, $targetTypeName)
                            }
                            $result
                        }
                    }
                }
            }
            catch {
                if ($_.FullyQualifiedErrorId -like '*SnipeitPaginationError*' -or
                    $_.FullyQualifiedErrorId -like '*SnipeitApiError*' -or
                    $_.Exception -is [System.Management.Automation.ActionPreferenceStopException]) {
                    throw
                }
                Write-Warning "Cannot parse server response. To debug, try adding -Verbose to the command."
            }
        }
    }

    END {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
