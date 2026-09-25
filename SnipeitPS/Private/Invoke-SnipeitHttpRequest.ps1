function Invoke-SnipeitHttpRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Request,

        [Parameter(Mandatory = $false)]
        [object]$Session,

        [switch]$LegacyErrors
    )

    $activeSession = if ($null -ne $Session) { $Session } else { $script:SnipeitPSSession }

    # Helper to read session properties whether dictionary or object
    $sessUrl = if ($activeSession -is [System.Collections.IDictionary]) { $activeSession['url'] } else { $activeSession.Url }
    $sessApiKey = if ($activeSession -is [System.Collections.IDictionary]) { $activeSession['apiKey'] } else { $activeSession.ApiKey }

    if ($null -ne $sessUrl -and $null -ne $sessApiKey) {
        $parsedUrl = $null
        if (-not [System.Uri]::TryCreate([string]$sessUrl, [System.UriKind]::Absolute, [ref]$parsedUrl) -or
            $parsedUrl.Scheme -ne 'https') {
            throw [System.ArgumentException]::new('Snipe-IT URL must be an absolute HTTPS URL.', 'Session.Url')
        }

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

    $reqUri = [string]$Request['Uri']
    $reqMethod = if ($Request.ContainsKey('Method') -and $Request['Method']) { [string]$Request['Method'] } else { 'GET' }

    # Headers isolation
    $_headers = @{
        'Authorization' = "Bearer $Token"
        'Content-Type'  = 'application/json; charset=utf-8'
        'Accept'        = 'application/json'
        'User-Agent'    = "SnipeitPS/$script:SnipeitModuleVersion"
    }
    if ($Request.ContainsKey('Headers') -and $Request['Headers'] -is [System.Collections.IDictionary]) {
        foreach ($hk in $Request['Headers'].Keys) {
            $_headers[$hk] = $Request['Headers'][$hk]
        }
    }

    $splatParameters = @{
        Uri                = $reqUri
        Method             = $reqMethod
        Headers            = $_headers
        UseBasicParsing    = $true
        MaximumRedirection = 0
        ErrorAction        = 'Stop'
    }

    if ($Request.ContainsKey('TimeoutSec')) {
        $splatParameters['TimeoutSec'] = [int]$Request['TimeoutSec']
    }

    # Form or Body handling
    if ($Request.ContainsKey('Form') -and $null -ne $Request['Form']) {
        $splatParameters['Form'] = $Request['Form']
        $_headers.Remove('Content-Type')
    } elseif ($Request.ContainsKey('Body') -and $null -ne $Request['Body']) {
        $bodyVal = $Request['Body']
        if ($bodyVal -is [byte[]] -or $bodyVal -is [System.IO.Stream]) {
            $splatParameters['Body'] = $bodyVal
        } elseif ($bodyVal -is [string]) {
            $splatParameters['Body'] = [System.Text.Encoding]::UTF8.GetBytes($bodyVal)
        } else {
            $splatParameters['Body'] = [System.Text.Encoding]::UTF8.GetBytes(($bodyVal | ConvertTo-Json -Depth 10))
        }
    }

    # Request throttling
    $tLimit = if ($activeSession -is [System.Collections.IDictionary]) { [int]$activeSession['throttleLimit'] } else { [int]$activeSession.ThrottleLimit }
    $tPeriod = if ($activeSession -is [System.Collections.IDictionary]) { [int]$activeSession['throttlePeriod'] } else { [int]$activeSession.ThrottlePeriod }
    $tMode = if ($activeSession -is [System.Collections.IDictionary]) { [string]$activeSession['throttleMode'] } else { [string]$activeSession.ThrottleMode }
    $tThreshold = if ($activeSession -is [System.Collections.IDictionary]) { [int]$activeSession['throttleThreshold'] } else { [int]$activeSession.ThrottleThreshold }

    if ($tLimit -gt 0) {
        $nowFileTime = (Get-Date).ToFileTime()
        $cutoff = $nowFileTime - ($tPeriod * 10000)

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
            Start-Sleep -Milliseconds $safeNap
        }
    }

    # Debug logging with sensitive field redaction
    if ($DebugPreference -ne 'SilentlyContinue') {
        $debugSplat = $splatParameters.Clone()
        if ($debugSplat.ContainsKey('Headers') -and $debugSplat['Headers'].ContainsKey('Authorization')) {
            $debugSplat['Headers'] = $debugSplat['Headers'].Clone()
            $debugSplat['Headers']['Authorization'] = 'Bearer [REDACTED]'
        }
        $redactKeys = @('password', 'password_confirmation', 'ldaptest_password', 'apiKey', 'api_key', 'token', 'secret')
        if ($debugSplat.ContainsKey('Form') -and $debugSplat['Form'] -is [System.Collections.IDictionary]) {
            $sanitizedForm = $debugSplat['Form'].Clone()
            foreach ($k in $redactKeys) {
                if ($sanitizedForm.ContainsKey($k)) { $sanitizedForm[$k] = '[REDACTED]' }
            }
            $debugSplat['Form'] = $sanitizedForm
        }
        if ($debugSplat.ContainsKey('Body') -and
            ($debugSplat['Body'] -is [byte[]] -or $debugSplat['Body'] -is [System.IO.Stream])) {
            $debugSplat['Body'] = '[BINARY_BODY]'
        }
        Write-Debug "Invoke-SnipeitHttpRequest: $($debugSplat | Out-String)"
    }

    $webResponse = $null
    $statusCode = $null
    try {
        $webResponse = Invoke-RestMethod @splatParameters
        return $webResponse
    }
    catch {
        $httpError = $_
        $responseBody = $null

        try {
            if ($null -ne $httpError.Exception.Response) {
                $statusCode = [int]$httpError.Exception.Response.StatusCode
            }
        } catch {
            Write-Debug "Failed to extract HTTP status code: $_"
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
                Write-Debug "Could not read error response stream: $_"
            } finally {
                if ($null -ne $reader) { $reader.Dispose() }
                if ($null -ne $stream) { $stream.Dispose() }
            }
        }

        # Sanitize reverse-proxy HTML errors
        if ($responseBody -match '(?si)<html.*?>.*?<title>(.*?)</title>') {
            $htmlTitle = $matches[1].Trim()
            $responseBody = "Server returned HTML error ($htmlTitle). Please check reverse proxy / server logs."
        } elseif ($responseBody -match '(?si)<html') {
            $responseBody = "Server returned HTML error response instead of JSON. Please check server availability."
        }

        $codeDisplay = if ($statusCode) { "HTTP $statusCode " } else { "" }
        $category = [System.Management.Automation.ErrorCategory]::ConnectionError
        $errorId = 'SnipeitTransportError'

        if ($statusCode -eq 429) {
            $category = [System.Management.Automation.ErrorCategory]::ResourceUnavailable
            $errorId = 'SnipeitRateLimitError'
        } elseif ($statusCode -in @(401, 403)) {
            $category = [System.Management.Automation.ErrorCategory]::AuthenticationError
            $errorId = 'SnipeitAuthError'
        } elseif ($statusCode -eq 422) {
            $category = [System.Management.Automation.ErrorCategory]::InvalidData
            $errorId = 'SnipeitValidationError'
        }

        $jsonObj = $null
        $responseParsed = $false
        if ($responseBody) {
            try {
                $jsonObj = $responseBody | ConvertFrom-Json -ErrorAction Stop
                $responseParsed = $true
            } catch { Write-Debug "Response body is not valid JSON: $_" }
        }

        # The dispatcher formats API envelopes and retains nonterminating HTTP errors.
        if ($LegacyErrors) {
            if ($responseBody -and -not $responseParsed) {
                Write-Error "${codeDisplay}error from Snipe-IT API: $responseBody"
                return
            }
            if ($null -ne $jsonObj -and $jsonObj.status -eq 'error') { return $jsonObj }
            if (-not $responseBody) {
                $category = [System.Management.Automation.ErrorCategory]::ConnectionError
                $errorId = 'SnipeitTransportError'
            }
        }

        if (-not $LegacyErrors -and $null -ne $jsonObj -and ($jsonObj.status -eq 'import-errors' -or $jsonObj.status -eq 'error')) {
            $category = [System.Management.Automation.ErrorCategory]::InvalidData
            $errorId = 'SnipeitApiError'
        }

        # Redact any sensitive fields from the payload in TargetObject
        $targetPayload = if ($LegacyErrors) {
            $reqUri
        } elseif ($null -ne $jsonObj -and ($jsonObj.status -eq 'import-errors' -or $jsonObj.status -eq 'error')) {
            $jsonObj
        } else {
            [pscustomobject]@{
                Uri        = $reqUri
                Method     = $reqMethod
                StatusCode = $statusCode
            }
        }
        if ($targetPayload -is [System.Collections.IDictionary]) {
            $targetPayload = $targetPayload.Clone()
            foreach ($k in @('password', 'password_confirmation', 'ldaptest_password', 'apiKey', 'api_key', 'token', 'secret')) {
                if ($targetPayload.ContainsKey($k)) { $targetPayload[$k] = '[REDACTED]' }
            }
        } elseif ($targetPayload -is [System.Management.Automation.PSCustomObject]) {
            $targetPayload = $targetPayload.PSObject.Copy()
            foreach ($k in @('password', 'password_confirmation', 'ldaptest_password', 'apiKey', 'api_key', 'token', 'secret')) {
                if ($null -ne $targetPayload.PSObject.Properties[$k]) { $targetPayload.$k = '[REDACTED]' }
            }
        }

        $errMessage = if ($responseBody) {
            "${codeDisplay}error from Snipe-IT API: $responseBody"
        } else {
            "${codeDisplay}error from Snipe-IT API with no response body: $($httpError.Exception.Message)"
        }

        $errRecord = [System.Management.Automation.ErrorRecord]::new(
            [System.Exception]::new($errMessage, $httpError.Exception),
            $errorId,
            $category,
            $targetPayload
        )

        if ($LegacyErrors) {
            $PSCmdlet.WriteError($errRecord)
            return
        }
        $PSCmdlet.ThrowTerminatingError($errRecord)
    }
}
