BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Save-SnipeitApiFile Helper' {
    InModuleScope SnipeitPS {
        BeforeAll {
            [byte[]]$script:binaryFixture = 0, 255, 128, 13, 10, 195, 169, 0
        }

        BeforeEach {
            $script:SnipeitPSSession.url = 'https://contract.invalid'
            $script:SnipeitPSSession.apiKey = 'test-only-key'
            $script:SnipeitPSSession.throttleLimit = 0
        }

        It 'Downloads and preserves binary fixture bytes unchanged' {
            Mock Invoke-WebRequest -ModuleName SnipeitPS {
                param($Uri, $OutFile)
                [System.IO.File]::WriteAllBytes($OutFile, $script:binaryFixture)
                return [pscustomobject]@{
                    StatusCode = 200
                    Headers    = @{ 'Content-Type' = 'application/octet-stream' }
                }
            }

            $dest = Join-Path $TestDrive 'downloaded.bin'
            $res = Save-SnipeitApiFile -Uri 'https://contract.invalid/api/v1/hardware/1/files/10' `
                                       -OutFile $dest `
                                       -EntityType 'hardware' `
                                       -Id 1 `
                                       -FileId 10

            $res | Should -Not -BeNullOrEmpty
            $res.PSObject.TypeNames | Should -Contain 'SnipeitPS.FileDownload'
            $res.Path | Should -Be $dest
            $res.Length | Should -Be $script:binaryFixture.Length

            $readBytes = [System.IO.File]::ReadAllBytes($dest)
            [System.Convert]::ToBase64String($readBytes) |
                Should -Be ([System.Convert]::ToBase64String($script:binaryFixture))
        }

        It 'Refuses to overwrite existing file without -Force and preserves original' {
            Mock Invoke-WebRequest -ModuleName SnipeitPS {
                throw 'Should not be called when file exists and Force is false'
            }

            $dest = Join-Path $TestDrive 'existing.txt'
            [System.IO.File]::WriteAllText($dest, 'ORIGINAL_CONTENT')

            { Save-SnipeitApiFile -Uri 'https://contract.invalid/api/v1/hardware/1/files/10' -OutFile $dest } |
                Should -Throw -ExpectedMessage '*already exists*'

            (Get-Content $dest -Raw) | Should -Be 'ORIGINAL_CONTENT'
        }

        It 'Overwrites existing file when -Force is specified' {
            Mock Invoke-WebRequest -ModuleName SnipeitPS {
                param($Uri, $OutFile)
                [System.IO.File]::WriteAllBytes($OutFile, $script:binaryFixture)
                return [pscustomobject]@{ StatusCode = 200; Headers = @{} }
            }

            $dest = Join-Path $TestDrive 'overwrite_me.bin'
            [System.IO.File]::WriteAllText($dest, 'OLD_DATA')

            Save-SnipeitApiFile -Uri 'https://contract.invalid/api/v1/hardware/1/files/10' `
                                -OutFile $dest `
                                -Force

            $readBytes = [System.IO.File]::ReadAllBytes($dest)
            [System.Convert]::ToBase64String($readBytes) |
                Should -Be ([System.Convert]::ToBase64String($script:binaryFixture))
        }

        It 'Preserves the original when committing the downloaded file fails' {
            Mock Invoke-WebRequest -ModuleName SnipeitPS {
                param($OutFile)
                [System.IO.File]::WriteAllBytes($OutFile, $script:binaryFixture)
                $script:lockedTempPath = $OutFile
                $script:lockedTemp = [System.IO.File]::Open(
                    $OutFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read,
                    [System.IO.FileShare]::Read)
                return [pscustomobject]@{ StatusCode = 200; Headers = @{} }
            }
            $dest = Join-Path $TestDrive 'preserve_on_commit_failure.bin'
            [System.IO.File]::WriteAllText($dest, 'ORIGINAL_DATA')
            $script:lockedTemp = $null
            $script:lockedTempPath = $null
            try {
                { Save-SnipeitApiFile -Uri 'https://contract.invalid/download' -OutFile $dest -Force } |
                    Should -Throw
                Test-Path -LiteralPath $dest | Should -BeTrue
                [System.IO.File]::ReadAllText($dest) | Should -Be 'ORIGINAL_DATA'
            } finally {
                if ($null -ne $script:lockedTemp) { $script:lockedTemp.Dispose() }
                if ($script:lockedTempPath -and (Test-Path -LiteralPath $script:lockedTempPath)) {
                    Remove-Item -LiteralPath $script:lockedTempPath -Force
                }
            }
        }

        It 'Preserves a destination created during transfer without Force and cleans up the temp file' {
            $script:concurrentDest = Join-Path $TestDrive 'concurrent.bin'
            Mock Invoke-WebRequest -ModuleName SnipeitPS {
                param($OutFile)
                [System.IO.File]::WriteAllBytes($OutFile, $script:binaryFixture)
                [System.IO.File]::WriteAllText($script:concurrentDest, 'CONCURRENT_DATA')
                $script:downloadTempPath = $OutFile
                return [pscustomobject]@{ StatusCode = 200; Headers = @{} }
            }

            { Save-SnipeitApiFile -Uri 'https://contract.invalid/download' -OutFile $script:concurrentDest } |
                Should -Throw
            [System.IO.File]::ReadAllText($script:concurrentDest) | Should -Be 'CONCURRENT_DATA'
            Test-Path -LiteralPath $script:downloadTempPath | Should -BeFalse
        }

        It 'Detects HTTP 200 API status=error envelope and throws without writing file' {
            Mock Invoke-WebRequest -ModuleName SnipeitPS {
                param($Uri, $OutFile)
                $errJson = '{"status":"error","messages":"File not found","payload":null}'
                [System.IO.File]::WriteAllText($OutFile, $errJson, [System.Text.Encoding]::UTF8)
                return [pscustomobject]@{
                    StatusCode = 200
                    Headers    = @{ 'Content-Type' = 'application/json' }
                }
            }

            $dest = Join-Path $TestDrive 'not_found.pdf'

            { Save-SnipeitApiFile -Uri 'https://contract.invalid/api/v1/hardware/1/files/999' -OutFile $dest } |
                Should -Throw -ExpectedMessage '*File not found*'

            (Test-Path $dest) | Should -BeFalse
        }

        It 'Allows valid JSON attachment that is not an API error envelope' {
            $jsonAttachment = '{"schema_version": 1, "config": "value"}'
            Mock Invoke-WebRequest -ModuleName SnipeitPS {
                param($Uri, $OutFile)
                [System.IO.File]::WriteAllText($OutFile, $jsonAttachment, [System.Text.Encoding]::UTF8)
                return [pscustomobject]@{
                    StatusCode = 200
                    Headers    = @{ 'Content-Type' = 'application/json' }
                }
            }

            $dest = Join-Path $TestDrive 'config.json'

            $res = Save-SnipeitApiFile -Uri 'https://contract.invalid/api/v1/hardware/1/files/15' `
                                       -OutFile $dest

            $res.Path | Should -Be $dest
            (Test-Path $dest) | Should -BeTrue
            (Get-Content $dest -Raw) | Should -Be $jsonAttachment
        }

        It 'Preserves existing file when transfer fails mid-stream or throws' {
            Mock Invoke-WebRequest -ModuleName SnipeitPS {
                param($Uri, $OutFile)
                [System.IO.File]::WriteAllBytes($OutFile, @(1, 2, 3))
                throw [System.Net.WebException]::new('Connection dropped mid-stream')
            }

            $dest = Join-Path $TestDrive 'preserve_on_fail.dat'
            [System.IO.File]::WriteAllText($dest, 'ORIGINAL_DATA')

            { Save-SnipeitApiFile -Uri 'https://contract.invalid/api/v1/hardware/1/files/10' -OutFile $dest -Force } |
                Should -Throw

            (Get-Content $dest -Raw) | Should -Be 'ORIGINAL_DATA'
        }

        It 'Handles zero-byte files properly' {
            Mock Invoke-WebRequest -ModuleName SnipeitPS {
                param($Uri, $OutFile)
                [System.IO.File]::WriteAllBytes($OutFile, [byte[]]@())
                return [pscustomobject]@{ StatusCode = 200; Headers = @{} }
            }

            $dest = Join-Path $TestDrive 'empty.dat'
            $res = Save-SnipeitApiFile -Uri 'https://contract.invalid/api/v1/hardware/1/files/20' -OutFile $dest

            $res.Length | Should -Be 0
            (Test-Path $dest) | Should -BeTrue
        }
    }
}
