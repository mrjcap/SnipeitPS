<#
    .SYNOPSIS
    Sets authentication information

    .DESCRIPTION
    Sets API Key and URL to connect to Snipe-IT system.
    Based on Set-SnipeitInfo command, which is now just a compatibility wrapper
    and calls Connect-SnipeitPS

    .PARAMETER url
    URL of Snipe-IT system.

    .PARAMETER apiKey
    User's API Key for Snipe-IT.

    .PARAMETER secureApiKey
    Snipe-IT API key as SecureString

    .PARAMETER siteCred
    PSCredential where username should be Snipe-IT URL and password should be
    Snipe-IT API key.

    .PARAMETER throttleLimit
    Throttle request rate to number of requests per throttlePeriod. Defaults to 0, which means requests are not throttled.

    .PARAMETER throttlePeriod
    Throttle period time span in milliseconds. Defaults to 60000 milliseconds.

    .PARAMETER throttleThreshold
    Threshold percentage of used requests per period after which requests are throttled.

    .PARAMETER throttleMode
    RequestThrottling type. "Burst" allows all requests to be used in ThrottlePeriod without delays and then waits
    until there's new requests available. With "Constant" mode there is always a delay between requests. Delay is calculated
    by dividing throttlePeriod with throttleLimit. "Adaptive" mode allows throttleThreshold percentage of request to be
    used without delay, after threshold limit is reached next requests are delayed by dividing available requests
    over throttlePeriod.

    .OUTPUTS

    None


    .EXAMPLE
    Connect-SnipeitPS -Url $url -apiKey $myapikey
    Connect to Snipe-IT API.

    .EXAMPLE
    Connect-SnipeitPS -Url $url -SecureApiKey $myapikey
    Connects to Snipe-IT API with API Key stored as SecureString

    .EXAMPLE
    Connect-SnipeitPS -siteCred (Get-Credential -message "Use site URL as username and API Key as password")
    Connect to Snipe-IT with PSCredential object.
    To use saved credentials you can use Export-Clixml and Import-Clixml cmdlets.

    .EXAMPLE
    Build credential with apikey value from secret vault (Microsoft.PowerShell.SecretManagement)
    $siteurl = "https://mysnipeitsite.url"
    $apikey = Get-Secret -Name SnipeItApiKey
    $siteCred = New-Object -Type PSCredential -Argumentlist $siteurl,$apikey
    Connect-SnipeitPS -siteCred $siteCred



#>
function Connect-SnipeitPS {
    [CmdletBinding(
        DefaultParameterSetName = 'Connect with url and apikey'
    )]
    [OutputType([void])]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Plaintext apiKey is accepted for backward compatibility and converted to SecureString for session storage')]

    param (
        [Parameter(ParameterSetName='Connect with url and apikey',Mandatory=$true)]
        [Parameter(ParameterSetName='Connect with url and secure apikey',Mandatory=$true)]
        [ValidateScript({$_.Scheme -eq 'https'})]
        [Uri]$url,

        [Parameter(ParameterSetName='Connect with url and apikey',Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$apiKey,

        [Parameter(ParameterSetName='Connect with url and secure apikey',Mandatory=$true)]
        [SecureString]$secureApiKey,

        [Parameter(ParameterSetName='Connect with credential',Mandatory=$true)]
        [PSCredential]$siteCred,

        [Parameter(ParameterSetName='Connect with url and apikey',Mandatory=$false)]
        [Parameter(ParameterSetName='Connect with url and secure apikey',Mandatory=$false)]
        [Parameter(ParameterSetName='Connect with credential',Mandatory=$false)]
        [int]$throttleLimit,

        [Parameter(ParameterSetName='Connect with url and apikey',Mandatory=$false)]
        [Parameter(ParameterSetName='Connect with url and secure apikey',Mandatory=$false)]
        [Parameter(ParameterSetName='Connect with credential',Mandatory=$false)]
        [int]$throttlePeriod,

        [Parameter(ParameterSetName='Connect with url and apikey',Mandatory=$false)]
        [Parameter(ParameterSetName='Connect with url and secure apikey',Mandatory=$false)]
        [Parameter(ParameterSetName='Connect with credential',Mandatory=$false)]
        [int]$throttleThreshold,

        [Parameter(ParameterSetName='Connect with url and apikey',Mandatory=$false)]
        [Parameter(ParameterSetName='Connect with url and secure apikey',Mandatory=$false)]
        [Parameter(ParameterSetName='Connect with credential',Mandatory=$false)]
        [ValidateSet("Burst","Constant","Adaptive")]
        [string]$throttleMode
    )


    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        # Enforce TLS 1.2 - PS5.1 with older .NET may default to TLS 1.0/1.1
        if (-not $script:IsPowerShell7) {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        }
    }

    PROCESS {
        $resolvedUrl = if ($siteCred) {
            $siteCred.GetNetworkCredential().UserName
        } else {
            $url.AbsoluteUri
        }
        $resolvedUri = $null
        if (-not [System.Uri]::TryCreate($resolvedUrl, [System.UriKind]::Absolute, [ref]$resolvedUri) -or
            $resolvedUri.Scheme -ne 'https') {
            throw [System.ArgumentException]::new('Snipe-IT URL must be an absolute HTTPS URL.', 'url')
        }
        $SnipeitPSSession.url = $resolvedUrl.TrimEnd('/')

        if ($siteCred) {
            $SnipeitPSSession.apiKey = $siteCred.GetNetworkCredential().SecurePassword
        } elseif ($secureApiKey) {
            $SnipeitPSSession.apiKey = $secureApiKey
        } else {
            $SnipeitPSSession.apiKey = ConvertTo-SecureString -String $apiKey -AsPlainText -Force
        }

        $SnipeitPSSession.throttleLimit = $throttleLimit
        $SnipeitPSSession.throttleThreshold = if ($throttleThreshold -ge 1) { $throttleThreshold } else { 90 }
        $SnipeitPSSession.throttleMode = if ($throttleMode) { $throttleMode } else { "Burst" }

        if ($SnipeitPSSession.throttleLimit -gt 0) {
            $SnipeitPSSession.throttlePeriod = if ($PSBoundParameters.ContainsKey('throttlePeriod')) { $throttlePeriod } else { 60000 }
            $SnipeitPSSession.throttledRequests = [System.Collections.Generic.Queue[long]]::new()
        }

        Write-Debug "Site-url $($SnipeitPSSession.url)"
        Write-Debug "Site apikey: [REDACTED]"

        if (-not (Test-SnipeitPSConnection)) {
            throw "Cannot verify connection to Snipe-IT. Try checking the URL and provided API key or credential parameters."
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
