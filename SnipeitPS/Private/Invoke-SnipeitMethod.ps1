<#
    .SYNOPSIS
    Make an API request to Snipe-IT

    .PARAMETER Api
    API part of URL. prefix with slash ie. "/api/v1/hardware"

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

        [Hashtable]$GetParameters
    )

    BEGIN {
        #use legacy per command based url and apikey
        if ( $null -ne $SnipeitPSSession.legacyUrl -and $null -ne $SnipeitPSSession.legacyApiKey ) {
            [string]$Url = $SnipeitPSSession.legacyUrl
            Write-Debug "Invoke-SnipeitMethod url: $Url"
            if($script:IsPowerShell7){
                $convertParams = @{
                    AsPlainText  = $true
                    SecureString = $SnipeitPSSession.legacyApiKey
                }
                $Token = ConvertFrom-SecureString @convertParams
            } else {
                #convert to plaintext via credential
                $credentialParams = @{
                    TypeName     = 'System.Management.Automation.PSCredential'
                    ArgumentList = @("user", $SnipeitPSSession.legacyApiKey)
                }
                $Token = (New-Object @credentialParams).GetNetworkCredential().Password
            }
        } elseif ($null -ne $SnipeitPSSession.url -and $null -ne $SnipeitPSSession.apiKey) {
            [string]$Url = $SnipeitPSSession.url
            Write-Debug "Invoke-SnipeitMethod url: $Url"
            if($script:IsPowerShell7){
                $convertParams = @{
                    AsPlainText  = $true
                    SecureString = $SnipeitPSSession.apiKey
                }
                $Token = ConvertFrom-SecureString @convertParams
            } else {
                #convert to plaintext via credential
                $credentialParams = @{
                    TypeName     = 'System.Management.Automation.PSCredential'
                    ArgumentList = @("user", $SnipeitPSSession.apiKey)
                }
                $Token = (New-Object @credentialParams).GetNetworkCredential().Password
            }
        } else {
            throw "Please use Connect-SnipeitPS to set up a connection before any other commands."
        }

        # Validation of parameters
        if (($Method -in ("POST", "PUT", "PATCH")) -and (!($Body))) {
            $message = "The following parameters are required when using the ${Method} parameter: Body."
            $newObjectParams = @{
                TypeName     = 'System.ArgumentException'
                ArgumentList = $message
            }
            $exception = New-Object @newObjectParams
            Throw $exception
        }

        #Build request uri
        $apiUri = "$Url$Api"
        #To support images "image" property has to be handled before this

        $_headers = @{
            "Authorization" = "Bearer $($Token)"
            'Content-Type'  = 'application/json; charset=utf-8'
            "Accept" = "application/json"
        }
    }

    Process {
        # This can be done using $Body, maybe some day - PetriAsi
        if ($GetParameters -and ($apiUri -notlike "*\?*")){
            Write-Debug "Using `$GetParameters: $($GetParameters | Out-String)"
            [string]$apiUri = $apiUri + (ConvertTo-GetParameter $GetParameters)
            # Prevent recursive appends
            $GetParameters = $null
        }

        # set mandatory parameters
        $splatParameters = @{
            Uri             = $apiUri
            Method          = $Method
            Headers         = $_headers
            UseBasicParsing = $true
            ErrorAction     = 'Stop'
        }

        # Send image requests as multipart/form-data if supported
        if($null -ne $body -and $Body.Keys -contains 'image' ){
            try {
                if($script:IsPowerShell7){
                    $Body['image'] = Get-Item $body['image'] -ErrorAction Stop
                    # As multipart/form-data is always POST we need add
                    # requested method for laravel named as '_method'
                    $Body['_method'] = $Method
                    $splatParameters["Method"] = 'POST'
                    $splatParameters["Form"] = $Body
                } else {
                    # use base64 encoded images for PowerShell version < 7
                    $mimetype = 'application/octet-stream'
                    try { Add-Type -AssemblyName "System.Web"; $mimetype = [System.Web.MimeMapping]::GetMimeMapping($body['image']) } catch {}
                    $Body['image'] = 'data:@'+$mimetype+';base64,'+[Convert]::ToBase64String([IO.File]::ReadAllBytes($Body['image']))
                }
            } catch {
                Write-Error "Failed to process image file '$($body['image'])': $_"
                return
            }
        }

        # Send file upload requests as multipart/form-data
        if($null -ne $body -and $Body.Keys -contains 'file' ){
            try {
                if($script:IsPowerShell7){
                    # Laravel expects file[] (array notation) for file uploads
                    $Body['file[]'] = Get-Item $body['file'] -ErrorAction Stop
                    $Body.Remove('file')
                    $Body['_method'] = $Method
                    $splatParameters["Method"] = 'POST'
                    $splatParameters["Form"] = $Body
                    # Remove Content-Type header so -Form can set multipart/form-data
                    $_headers.Remove('Content-Type')
                } else {
                    throw "File uploads require PowerShell 7.0 or later."
                }
            } catch {
                Write-Error "Failed to process file '$($body['file'])': $_"
                return
            }
        }
        if ($Body -and $splatParameters.Keys -notcontains 'Form') {
            $splatParameters["Body"] =  [System.Text.Encoding]::UTF8.GetBytes(($Body | ConvertTo-Json))
        }

        $script:PSDefaultParameterValues = $global:PSDefaultParameterValues

        if ($DebugPreference -ne 'SilentlyContinue') {
            Write-Debug "$($Body | ConvertTo-Json -Depth 4)"
        }

        #Check throttle limit
        if ($SnipeitPSSession.throttleLimit -gt 0) {
            Write-Verbose "Check for request throttling"
            Write-Debug "ThrottleMode: $($SnipeitPSSession.throttleMode)"
            Write-Debug "ThrottleLimit: $($SnipeitPSSession.throttleLimit)"
            Write-Debug "ThrottlePeriod: $($SnipeitPSSession.throttlePeriod)"
            Write-Debug "ThrottleThreshold: $($SnipeitPSSession.throttleThreshold)"
            Write-Debug "Current count: $($SnipeitPSSession.throttledRequests.count)"

            #current request timestamps in period
            $SnipeitPSSession.throttledRequests = ($SnipeitPSSession.throttledRequests).where({$_ -gt (Get-Date).AddMilliseconds( 0 - $SnipeitPSSession.throttlePeriod).ToFileTime()})

            $naptime = 0
            switch ($SnipeitPSSession.throttleMode) {
                "Burst" {
                    if ($SnipeitPSSession.throttledRequests.count -ge $SnipeitPSSession.throttleLimit) {
                        $naptime =  [Math]::Round(((Get-Date).ToFileTime() - ($SnipeitPSSession.throttledRequests[0]))/10000)
                    }
                }

                "Constant" {
                    $prevrequesttime =[Math]::Round(((Get-Date).ToFileTime() - ($SnipeitPSSession.throttledRequests[$SnipeitPSSession.throttledRequests.count - 1]))/10000)
                    $naptime = [Math]::Round($SnipeitPSSession.throttlePeriod / $SnipeitPSSession.throttleLimit) - $prevrequesttime
                }

                "Adaptive" {
                  $unThrottledRequests = $SnipeitPSSession.throttleLimit * ($SnipeitPSSession.throttleThreshold / 100)
                  if($SnipeitPSSession.throttledRequests.count -ge $unThrottledRequests) {
                     #calculate time left in throttlePeriod and divide it for remaining requests
                     $remaining = $SnipeitPSSession.throttleLimit - $SnipeitPSSession.throttledRequests.count
                     if ($remaining -lt 1) {
                        $remaining = 1
                     }
                     $naptime =  [Math]::Round((((Get-Date).ToFileTime() - ($SnipeitPSSession.throttledRequests[0]))/ 10000) / $remaining)
                  }
                }
            }

            #Do we need a nap
            if ($naptime -gt 0) {
                Write-Verbose "Throttling request for $naptime ms"
                Start-Sleep -Milliseconds $naptime
            }

            $SnipeitPSSession.throttledRequests.Add((Get-Date).ToFileTime())
        }

        # Invoke the API
        try {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Invoking method $Method to URI $apiUri"
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoke-WebRequest with: $($splatParameters | Out-String)"
            $webResponse = Invoke-RestMethod @splatParameters
        }
        catch {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Failed to get an answer from the server"
            $webResponse = $_.Exception.Response
        }

        Write-Debug "[$($MyInvocation.MyCommand.Name)] Executed WebRequest. Access $webResponse to see details"

        if ($webResponse) {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Status code: $($webResponse.StatusCode)"

            if ($webResponse) {
                 Write-Verbose $webResponse

                # API returned a Content: lets work with it
                try{
                    if ($webResponse.status -eq "error") {
                        Write-Verbose "[$($MyInvocation.MyCommand.Name)] An error response was received ... resolving"
                        # This could be handled nicely in a function such as:
                        # ResolveError $response -WriteError
                        Write-Error $($webResponse.messages | Out-String)
                    } elseif ( $webResponse.StatusCode -eq 'Unauthorized') {
                        Write-Verbose "[$($MyInvocation.MyCommand.Name)] An Unauthorized response was received"
                        Write-Error "Cannot connect to Snipe-IT: Unauthorized."
                        return $false
                    } else {
                        #update operations return payload
                        if ($webResponse.payload) {
                            $result = $webResponse.payload
                        }
                        #Search operations return rows
                        elseif ($webResponse.rows) {
                            $result = $webResponse.rows
                        }
                        #Remove operations returns status and message
                        elseif ($webResponse.status -eq 'success') {
                            $result = $webResponse.payload
                        }
                        #Search and query result with no results
                        elseif ($webResponse.total -eq 0){
                            $result = $null
                        }
                        #get operations with id returns just one object
                        else {
                            $result = $webResponse
                        }

                        Write-Verbose "Status: $($webResponse.status)"
                        Write-Verbose "Messages: $($webResponse.messages)"

                        $result
                    }
                }
                catch {
                    Write-Warning "Cannot parse server response. To debug, try adding -Verbose to the command."
                }

            }

        }
        else {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] No web result object was returned. This is unusual!"
        }
    }

    END {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}

