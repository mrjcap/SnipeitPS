function Send-SnipeitMultipart {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Uri,

        [Parameter(Mandatory = $false)]
        [object[]]$Files,

        [Parameter(Mandatory = $false)]
        [hashtable]$Fields,

        [Parameter(Mandatory = $false)]
        [string]$FileFieldName = 'file[]',

        [Parameter(Mandatory = $false)]
        [object]$Session,

        [Parameter(Mandatory = $false)]
        [string]$Method = 'POST'
    )

    # Validate all file paths upfront
    $resolvedFiles = [System.Collections.Generic.List[string]]::new()
    if ($null -ne $Files) {
        foreach ($fileItem in $Files) {
            $filePath = if ($fileItem -is [System.IO.FileInfo]) { $fileItem.FullName } else { [string]$fileItem }
            if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
                throw [System.IO.FileNotFoundException]::new("File '$filePath' does not exist.", $filePath)
            }
            $resolvedFiles.Add((Resolve-Path -LiteralPath $filePath).Path)
        }
    }

    $boundary = "---------------------------$([System.Guid]::NewGuid().ToString('N'))"
    $crlf = "`r`n"
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)

    $tempPath = [System.IO.Path]::GetTempFileName()
    $bodyStream = $null
    try {
        $bodyStream = [System.IO.FileStream]::new(
            $tempPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite,
            [System.IO.FileShare]::Read, 81920, [System.IO.FileOptions]::DeleteOnClose)
        $writeString = {
            param([string]$text)
            $bytes = $utf8NoBom.GetBytes($text)
            $bodyStream.Write($bytes, 0, $bytes.Length)
        }

        # Write form fields
        if ($null -ne $Fields) {
            foreach ($key in $Fields.Keys) {
                $val = $Fields[$key]
                if ($null -ne $val) {
                    & $writeString "--$boundary$crlf"
                    & $writeString "Content-Disposition: form-data; name=`"$key`"$crlf$crlf"
                    & $writeString "$val$crlf"
                }
            }
        }

        # Write files
        foreach ($file in $resolvedFiles) {
            $fileName = [System.IO.Path]::GetFileName($file)
            & $writeString "--$boundary$crlf"
            & $writeString "Content-Disposition: form-data; name=`"$FileFieldName`"; filename=`"$fileName`"$crlf"
            & $writeString "Content-Type: application/octet-stream$crlf$crlf"

            $fs = [System.IO.File]::OpenRead($file)
            try {
                $fs.CopyTo($bodyStream)
            } finally {
                $fs.Dispose()
            }
            & $writeString "$crlf"
        }

        # Closing boundary
        & $writeString "--$boundary--$crlf"

        $bodyStream.Position = 0
        $req = @{
            Uri     = $Uri
            Method  = $Method
            Headers = @{
                'Content-Type' = "multipart/form-data; boundary=$boundary"
            }
            Body    = $bodyStream
        }

        $response = Invoke-SnipeitHttpRequest -Request $req -Session $Session
        return (ConvertFrom-SnipeitApiResponse -Response $response -ResponseKind DirectObject)
    } finally {
        if ($null -ne $bodyStream) { $bodyStream.Dispose() }
        if (Test-Path -LiteralPath $tempPath) { Remove-Item -LiteralPath $tempPath -Force }
    }
}
