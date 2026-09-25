function Save-SnipeitApiFile {
    [CmdletBinding()]
    [OutputType('SnipeitPS.FileDownload')]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Uri,

        [Parameter(Mandatory = $true)]
        [string]$OutFile,

        [Parameter(Mandatory = $false)]
        [string]$EntityType,

        [Parameter(Mandatory = $false)]
        [int]$Id,

        [Parameter(Mandatory = $false)]
        [int]$FileId,

        [Parameter(Mandatory = $false)]
        [switch]$Force,

        [Parameter(Mandatory = $false)]
        [object]$Session
    )

    $parsedUri = $null
    if (-not [System.Uri]::TryCreate($Uri, [System.UriKind]::Absolute, [ref]$parsedUri) -or
        $parsedUri.Scheme -ne 'https') {
        throw [System.ArgumentException]::new('Download URI must be an absolute HTTPS URL.', 'Uri')
    }

    $activeSession = if ($null -ne $Session) { $Session } else { $script:SnipeitPSSession }

    $sessApiKey = if ($activeSession -is [System.Collections.IDictionary]) { $activeSession['apiKey'] } else { $activeSession.ApiKey }
    if ($null -eq $sessApiKey) {
        throw "Please use Connect-SnipeitPS to set up a connection before any other commands."
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

    # Resolve destination path
    $resolvedOutFile = if ([System.IO.Path]::IsPathRooted($OutFile)) {
        $OutFile
    } else {
        [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $OutFile))
    }

    $outDir = [System.IO.Path]::GetDirectoryName($resolvedOutFile)
    if (-not (Test-Path -LiteralPath $outDir -PathType Container)) {
        throw [System.IO.DirectoryNotFoundException]::new("Target directory '$outDir' does not exist.")
    }

    if ((Test-Path -LiteralPath $resolvedOutFile -PathType Leaf) -and -not $Force) {
        throw [System.IO.IOException]::new("File '$resolvedOutFile' already exists. Use -Force to overwrite.")
    }

    $tempFile = [System.IO.Path]::Combine($outDir, ".tmp_$([System.Guid]::NewGuid().ToString('N'))")

    $headers = @{
        'Authorization' = "Bearer $Token"
        'Accept'        = '*/*'
        'User-Agent'    = "SnipeitPS/$script:SnipeitModuleVersion"
    }

    $splat = @{
        Uri                = $Uri
        Method             = 'GET'
        Headers            = $headers
        OutFile            = $tempFile
        UseBasicParsing    = $true
        MaximumRedirection = 0
        ErrorAction        = 'Stop'
    }

    $response = $null
    try {
        $response = Invoke-WebRequest @splat

        # Validate that temporary file was created
        if (-not (Test-Path -LiteralPath $tempFile -PathType Leaf)) {
            throw [System.IO.FileNotFoundException]::new("Downloaded temporary file was not created.", $tempFile)
        }

        # Check for API status=error envelope
        $fi = [System.IO.FileInfo]::new($tempFile)
        $isErrorEnvelope = $false
        $errMsg = $null
        if ($fi.Length -gt 0 -and $fi.Length -lt 8192) {
            try {
                $text = [System.IO.File]::ReadAllText($tempFile, [System.Text.Encoding]::UTF8)
                if ($text.TrimStart().StartsWith('{')) {
                    $parsed = $text | ConvertFrom-Json -ErrorAction SilentlyContinue
                    if ($null -ne $parsed -and $parsed.status -eq 'error') {
                        $isErrorEnvelope = $true
                        $errMsg = if ($parsed.messages) {
                            if ($parsed.messages -is [string]) {
                                $parsed.messages
                            } else {
                                ($parsed.messages.PSObject.Properties | ForEach-Object { "$($_.Name): $($_.Value)" }) -join '; '
                            }
                        } else {
                            "Snipe-IT API returned error for file download."
                        }
                    }
                }
            } catch {
                Write-Debug "Binary content that cannot parse as JSON is valid attachment data: $_"
            }
        }

        if ($isErrorEnvelope) {
            Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
            $err = [System.Management.Automation.ErrorRecord]::new(
                [System.InvalidOperationException]::new($errMsg),
                'SnipeitApiError',
                [System.Management.Automation.ErrorCategory]::InvalidResult,
                @{ Uri = $Uri; OutFile = $resolvedOutFile }
            )
            $PSCmdlet.ThrowTerminatingError($err)
        }

        if ($Force -and (Test-Path -LiteralPath $resolvedOutFile -PathType Leaf)) {
            [System.IO.File]::Replace($tempFile, $resolvedOutFile, [System.Management.Automation.Language.NullString]::Value)
        } else {
            [System.IO.File]::Move($tempFile, $resolvedOutFile)
        }

        $contentType = 'application/octet-stream'
        if ($null -ne $response -and $null -ne $response.Headers) {
            if ($response.Headers -is [System.Collections.IDictionary] -and $response.Headers.Contains('Content-Type')) {
                $contentType = [string]$response.Headers['Content-Type']
            } elseif ($null -ne $response.Headers['Content-Type']) {
                $contentType = [string]$response.Headers['Content-Type']
            }
        }

        $downloadLength = (Get-Item -LiteralPath $resolvedOutFile).Length

        return [pscustomobject]@{
            PSTypeName  = 'SnipeitPS.FileDownload'
            EntityType  = $EntityType
            Id          = $Id
            FileId      = $FileId
            Path        = $resolvedOutFile
            Length      = $downloadLength
            ContentType = $contentType
        }
    } finally {
        if (Test-Path -LiteralPath $tempFile) {
            Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
        }
    }
}
