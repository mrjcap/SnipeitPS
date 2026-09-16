class SnipeitSession {
    [string]$Url
    [System.Security.SecureString]$ApiKey
    [int]$ThrottleLimit = 0
    [int]$ThrottleThreshold = 90
    [string]$ThrottleMode = "Burst"
    [int]$ThrottlePeriod = 60000
    [long]$LastRequestFileTime = 0
    [System.Collections.Generic.Queue[long]]$ThrottledRequests = [System.Collections.Generic.Queue[long]]::new()

    SnipeitSession() {}

    SnipeitSession([string]$url, [System.Security.SecureString]$apiKey) {
        $parsedUrl = $null
        if (-not [System.Uri]::TryCreate($url, [System.UriKind]::Absolute, [ref]$parsedUrl) -or
            -not [string]::Equals($parsedUrl.Scheme, 'https', [System.StringComparison]::OrdinalIgnoreCase)) {
            throw [System.ArgumentException]::new('Snipe-IT URL must be an absolute HTTPS URL.', 'url')
        }

        $this.Url = $url.TrimEnd('/')
        $this.ApiKey = $apiKey
    }

    [void] Clear() {
        $this.Url = $null
        $this.ApiKey = $null
        $this.ThrottleLimit = 0
        $this.ThrottleThreshold = 90
        $this.ThrottleMode = "Burst"
        $this.ThrottlePeriod = 60000
        $this.LastRequestFileTime = 0
        $this.ThrottledRequests = [System.Collections.Generic.Queue[long]]::new()
    }
}
