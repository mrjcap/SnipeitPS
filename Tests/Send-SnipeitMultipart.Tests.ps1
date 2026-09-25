BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Send-SnipeitMultipart Helper' {
    InModuleScope SnipeitPS {
        BeforeAll {
            [byte[]]$script:binaryFixture = 0, 255, 128, 13, 10, 195, 169, 0
        }

        BeforeEach {
            $script:SnipeitPSSession.url = 'https://contract.invalid'
            $script:SnipeitPSSession.apiKey = 'test-only-key'
            $script:SnipeitPSSession.throttleLimit = 0
            $script:capturedRequest = $null
            $script:capturedBody = $null
        }

        It 'Keeps binary bytes unchanged in multipart payload' {
            Mock Invoke-SnipeitHttpRequest -ModuleName SnipeitPS {
                param($Request, $Session)
                $script:capturedRequest = $Request
                $copy = [System.IO.MemoryStream]::new()
                try {
                    $Request.Body.CopyTo($copy)
                    $script:capturedBody = $copy.ToArray()
                } finally {
                    $copy.Dispose()
                }
                return [pscustomobject]@{
                    status   = 'success'
                    messages = 'File uploaded'
                    payload  = [pscustomobject]@{ id = 101 }
                }
            }

            $testFile = Join-Path $TestDrive 'attachment.bin'
            [System.IO.File]::WriteAllBytes($testFile, $script:binaryFixture)

            $res = Send-SnipeitMultipart -Uri 'https://contract.invalid/api/v1/hardware/1/files' `
                                         -Files @($testFile) `
                                         -Fields @{ notes = 'Binary test file' }

            $res.status | Should -Be 'success'
            $script:capturedRequest | Should -Not -BeNullOrEmpty
            $script:capturedRequest.Method | Should -Be 'POST'
            $script:capturedRequest.Headers['Content-Type'] | Should -Match '^multipart/form-data; boundary='

            $script:capturedRequest.Body | Should -BeOfType ([System.IO.Stream])
            $bodyBytes = [byte[]]$script:capturedBody
            $bodyBytes.Length | Should -BeGreaterThan $script:binaryFixture.Length

            # Verify the exact fixture bytes exist consecutively in the body stream
            $found = $false
            for ($i = 0; $i -le ($bodyBytes.Length - $script:binaryFixture.Length); $i++) {
                $match = $true
                for ($j = 0; $j -lt $script:binaryFixture.Length; $j++) {
                    if ($bodyBytes[$i + $j] -ne $script:binaryFixture[$j]) {
                        $match = $false
                        break
                    }
                }
                if ($match) {
                    $found = $true
                    break
                }
            }
            $found | Should -BeTrue
        }

        It 'Preserves Unicode filenames in multipart header' {
            Mock Invoke-SnipeitHttpRequest -ModuleName SnipeitPS {
                param($Request, $Session)
                $script:capturedRequest = $Request
                $copy = [System.IO.MemoryStream]::new()
                try {
                    $Request.Body.CopyTo($copy)
                    $script:capturedBody = $copy.ToArray()
                } finally {
                    $copy.Dispose()
                }
                return [pscustomobject]@{ status = 'success'; payload = $null }
            }

            $unicodeName = "test_unicode_`u{00E9}`u{00F1}`u{03B1}.txt"
            $testFile = Join-Path $TestDrive $unicodeName
            [System.IO.File]::WriteAllText($testFile, 'unicode content', [System.Text.Encoding]::UTF8)

            Send-SnipeitMultipart -Uri 'https://contract.invalid/api/v1/hardware/1/files' `
                                  -Files @($testFile)

            $bodyText = [System.Text.Encoding]::UTF8.GetString([byte[]]$script:capturedBody)
            $bodyText | Should -Match "filename=""$unicodeName"""
        }

        It 'Uses custom form field name when specified (e.g. files[] for imports)' {
            Mock Invoke-SnipeitHttpRequest -ModuleName SnipeitPS {
                param($Request, $Session)
                $script:capturedRequest = $Request
                $copy = [System.IO.MemoryStream]::new()
                try {
                    $Request.Body.CopyTo($copy)
                    $script:capturedBody = $copy.ToArray()
                } finally {
                    $copy.Dispose()
                }
                return [pscustomobject]@{ status = 'success'; payload = $null }
            }

            $testFile = Join-Path $TestDrive 'import.csv'
            [System.IO.File]::WriteAllText($testFile, 'col1,col2', [System.Text.Encoding]::UTF8)

            Send-SnipeitMultipart -Uri 'https://contract.invalid/api/v1/imports' `
                                  -Files @($testFile) `
                                  -FileFieldName 'files[]'

            $bodyText = [System.Text.Encoding]::UTF8.GetString([byte[]]$script:capturedBody)
            $bodyText | Should -Match 'name="files\[\]"'
        }

        It 'Spools a large upload without allocating a complete body buffer and removes the spool file' {
            $testFile = Join-Path $TestDrive 'large.bin'
            $file = [System.IO.File]::OpenWrite($testFile)
            try { $file.SetLength(128MB) } finally { $file.Dispose() }

            Mock Invoke-SnipeitHttpRequest -ModuleName SnipeitPS {
                param($Request, $Session)
                $Request.Body | Should -BeOfType ([System.IO.FileStream])
                $Request.Body.Length | Should -BeGreaterThan 128MB
                $script:spoolPath = $Request.Body.Name
                return [pscustomobject]@{ status = 'success'; payload = $null }
            }

            Send-SnipeitMultipart -Uri 'https://contract.invalid/api/v1/imports' -Files @($testFile) |
                Out-Null
            Test-Path -LiteralPath $script:spoolPath | Should -BeFalse
        }

        It 'Removes the temporary upload after transport failure' {
            $testFile = Join-Path $TestDrive 'failing.bin'
            [System.IO.File]::WriteAllBytes($testFile, $script:binaryFixture)
            Mock Invoke-SnipeitHttpRequest -ModuleName SnipeitPS {
                param($Request, $Session)
                $script:spoolPath = $Request.Body.Name
                throw 'Upload failed'
            }

            { Send-SnipeitMultipart -Uri 'https://contract.invalid/api/v1/imports' -Files @($testFile) } |
                Should -Throw '*Upload failed*'
            Test-Path -LiteralPath $script:spoolPath | Should -BeFalse
        }

        It 'Rejects non-existent file before making any network call' {
            Mock Invoke-SnipeitHttpRequest -ModuleName SnipeitPS {
                throw 'Should not reach transport'
            }

            $missing = Join-Path $TestDrive 'does_not_exist.pdf'
            { Send-SnipeitMultipart -Uri 'https://contract.invalid/api/v1/hardware/1/files' -Files @($missing) } |
                Should -Throw -ExpectedMessage '*does not exist*'
        }
    }
}
