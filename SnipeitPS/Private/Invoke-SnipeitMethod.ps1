<#
    .SYNOPSIS
    Make an API request to Snipe-IT

    .PARAMETER Api
    API part of URL. prefix with slash ie. "$script:SnipeitApiPrefix/hardware"

    .PARAMETER Method
    Method of the invocation, one of the following: "GET", "POST", "PUT", "PATCH" or "DELETE"

    .PARAMETER Body
    Request body as hashtable. Needed for post, put and patch

    .PARAMETER GetParameters
    Get-Parameters as hashtable.
#>

function Invoke-SnipeitMethod {
    [CmdletBinding()]
    [OutputType(
        [PSObject]
    )]

    param (

        [Parameter(Mandatory = $true)]
        [string]$Api,

        [ValidateSet("GET", "POST", "PUT", "PATCH", "DELETE")]
        [string]$Method = "GET",

        [Hashtable]$Body,

        [Hashtable]$GetParameters,

        [switch]$Paginate
    )

    BEGIN {
        # use legacy per command based url and apikey if present
        if ($null -ne $SnipeitPSSession.legacyUrl -and $null -ne $SnipeitPSSession.legacyApiKey) {
            [string]$Url = $SnipeitPSSession.legacyUrl
            Write-Debug "Invoke-SnipeitMethod legacy url: $Url"
            if ($SnipeitPSSession.legacyApiKey -is [System.Security.SecureString]) {
                if ($script:IsPowerShell7) {
                    $Token = ConvertFrom-SecureString -SecureString $SnipeitPSSession.legacyApiKey -AsPlainText
                } else {
                    $Token = (New-Object System.Management.Automation.PSCredential("user", $SnipeitPSSession.legacyApiKey)).GetNetworkCredential().Password
                }
            } else {
                $Token = [string]$SnipeitPSSession.legacyApiKey
            }
        } elseif ($null -ne $SnipeitPSSession.url -and $null -ne $SnipeitPSSession.apiKey) {
            [string]$Url = $SnipeitPSSession.url
            Write-Debug "Invoke-SnipeitMethod url: $Url"
            if ($SnipeitPSSession.apiKey -is [System.Security.SecureString]) {
                if ($script:IsPowerShell7) {
                    $Token = ConvertFrom-SecureString -SecureString $SnipeitPSSession.apiKey -AsPlainText
                } else {
                    $Token = (New-Object System.Management.Automation.PSCredential("user", $SnipeitPSSession.apiKey)).GetNetworkCredential().Password
                }
            } else {
                $Token = [string]$SnipeitPSSession.apiKey
            }
        } else {
            throw "Please use Connect-SnipeitPS to set up a connection before any other commands."
        }

        # Validation of parameters
        if (($Method -in ("POST", "PUT", "PATCH")) -and (-not $Body)) {
            $message = "The following parameters are required when using the ${Method} parameter: Body."
            throw [System.ArgumentException]::new($message)
        }

        # Build request base uri
        $apiUri = "$Url$Api"
    }

    PROCESS {
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
            "User-Agent"    = "SnipeitPS/1.15.0"
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
                    } catch {}
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
            foreach ($key in @('password', 'password_confirmation')) {
                if ($debugBody.ContainsKey($key)) {
                    $debugBody[$key] = '[REDACTED]'
                }
            }
            Write-Debug "$($debugBody | ConvertTo-Json -Depth 4)"
        }

        # Request throttling
        if ($SnipeitPSSession.throttleLimit -gt 0) {
            Write-Verbose "Check for request throttling"
            Write-Debug "ThrottleMode: $($SnipeitPSSession.throttleMode)"
            Write-Debug "ThrottleLimit: $($SnipeitPSSession.throttleLimit)"
            Write-Debug "ThrottlePeriod: $($SnipeitPSSession.throttlePeriod)"
            Write-Debug "ThrottleThreshold: $($SnipeitPSSession.throttleThreshold)"
            Write-Debug "Current count: $($SnipeitPSSession.throttledRequests.Count)"

            $nowFileTime = (Get-Date).ToFileTime()
            $cutoff = $nowFileTime - ($SnipeitPSSession.throttlePeriod * 10000)

            # Filter window to requests within throttlePeriod
            $SnipeitPSSession.throttledRequests = ($SnipeitPSSession.throttledRequests).where({ $_ -gt $cutoff -and $_ -le $nowFileTime })

            $naptime = 0
            switch ($SnipeitPSSession.throttleMode) {
                "Burst" {
                    if ($SnipeitPSSession.throttledRequests.Count -ge $SnipeitPSSession.throttleLimit -and $SnipeitPSSession.throttledRequests.Count -gt 0) {
                        $elapsedMs = [Math]::Round(($nowFileTime - $SnipeitPSSession.throttledRequests[0]) / 10000)
                        $naptime = [Math]::Max(0, ($SnipeitPSSession.throttlePeriod - $elapsedMs))
                        if ($naptime -eq 0) { $naptime = 1 }
                    }
                }

                "Constant" {
                    if ($SnipeitPSSession.throttledRequests.Count -gt 0 -and $SnipeitPSSession.throttleLimit -gt 0) {
                        $prevRequestTime = [Math]::Round(($nowFileTime - $SnipeitPSSession.throttledRequests[$SnipeitPSSession.throttledRequests.Count - 1]) / 10000)
                        $intervalMs = [Math]::Round($SnipeitPSSession.throttlePeriod / $SnipeitPSSession.throttleLimit)
                        $naptime = [Math]::Max(0, ($intervalMs - $prevRequestTime))
                    }
                }

                "Adaptive" {
                    $unThrottledRequests = $SnipeitPSSession.throttleLimit * ($SnipeitPSSession.throttleThreshold / 100)
                    if ($SnipeitPSSession.throttledRequests.Count -ge $unThrottledRequests -and $SnipeitPSSession.throttledRequests.Count -gt 0) {
                        $elapsedMs = [Math]::Round(($nowFileTime - $SnipeitPSSession.throttledRequests[0]) / 10000)
                        $remainingPeriodMs = [Math]::Max(0, ($SnipeitPSSession.throttlePeriod - $elapsedMs))
                        $remaining = $SnipeitPSSession.throttleLimit - $SnipeitPSSession.throttledRequests.Count
                        if ($remaining -lt 1) { $remaining = 1 }
                        $naptime = [Math]::Round($remainingPeriodMs / $remaining)
                        if ($naptime -eq 0 -and $SnipeitPSSession.throttledRequests.Count -ge $SnipeitPSSession.throttleLimit) {
                            $naptime = 1
                        }
                    }
                }
            }

            if ($naptime -gt 0) {
                $safeNap = [int][Math]::Min([int]::MaxValue, [Math]::Max(0, $naptime))
                Write-Verbose "Throttling request for $safeNap ms"
                Start-Sleep -Milliseconds $safeNap
            }

            [void]$SnipeitPSSession.throttledRequests.Add((Get-Date).ToFileTime())
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
            } catch {}

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
                Write-Error "${codeDisplay}error from Snipe-IT API with no response body."
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

                if ($statusVal -eq "error") {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] An error response was received ... resolving"
                    $errMsg = if ($messagesVal) { $messagesVal | Out-String } else { "Snipe-IT API returned error status." }
                    Write-Error $errMsg.Trim()
                } elseif ($statusCodeVal -eq 'Unauthorized' -or $statusCodeVal -eq 401) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] An Unauthorized response was received"
                    Write-Error "Cannot connect to Snipe-IT: Unauthorized."
                    return
                } else {
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

                    Write-Verbose "Status: $statusVal"
                    Write-Verbose "Messages: $messagesVal"

                    $result
                }
            }
            catch {
                Write-Warning "Cannot parse server response. To debug, try adding -Verbose to the command."
            }
        }
    }

    END {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
