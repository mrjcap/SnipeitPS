BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Save-SnipeitBackup' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Downloads specific backup by filename via GET /api/v1/settings/backups/download/{file}' {
            Mock Invoke-WebRequest {
                param($Uri, $Method, $Headers, $OutFile)
                $script:capturedCalls.Add(@{ Uri = $Uri; Method = $Method; Headers = $Headers; OutFile = $OutFile })
                [IO.File]::WriteAllBytes($OutFile, [byte[]]@(0, 128, 255))
            }

            $tempDir = $TestDrive
            $res = Save-SnipeitBackup -filename 'test-2026.zip' -path $tempDir -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Uri | Should -Be 'https://contract.invalid/api/v1/settings/backups/download/test-2026.zip'
            $call.Method | Should -Be 'Get'
            $call.OutFile | Should -Not -Be (Join-Path $tempDir 'test-2026.zip')
            Test-Path -LiteralPath $call.OutFile | Should -BeFalse
            [Convert]::ToBase64String([IO.File]::ReadAllBytes($res.path)) | Should -Be 'AID/'
            $res.status | Should -Be 'success'
            $res.filename | Should -Be 'test-2026.zip'
            $res.path | Should -Be (Join-Path $tempDir 'test-2026.zip')
            $res.PSObject.TypeNames.Contains('SnipeitPS.BackupDownload') | Should -Be $true
        }

        It 'Downloads latest backup via GET /api/v1/settings/backups/download/latest' {
            Mock Invoke-WebRequest {
                param($Uri, $Method, $Headers, $OutFile)
                $script:capturedCalls.Add(@{ Uri = $Uri; Method = $Method; Headers = $Headers; OutFile = $OutFile })
                [IO.File]::WriteAllBytes($OutFile, [byte[]]@(0, 128, 255))
            }

            $tempDir = $TestDrive
            $res = Save-SnipeitBackup -Latest -path $tempDir -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $call = $script:capturedCalls[0]
            $call.Uri | Should -Be 'https://contract.invalid/api/v1/settings/backups/download/latest'
            $call.Method | Should -Be 'Get'
            $call.OutFile | Should -Not -Be (Join-Path $tempDir 'latest-backup.zip')
            Test-Path -LiteralPath $call.OutFile | Should -BeFalse
            [Convert]::ToBase64String([IO.File]::ReadAllBytes($res.path)) | Should -Be 'AID/'
            $res.status | Should -Be 'success'
            $res.filename | Should -Be 'latest-backup.zip'
        }

        It 'Downloads latest backup with custom OutFileName' {
            Mock Invoke-WebRequest {
                param($Uri, $Method, $Headers, $OutFile)
                $script:capturedCalls.Add(@{ OutFile = $OutFile })
                [IO.File]::WriteAllBytes($OutFile, [byte[]]@(0, 128, 255))
            }

            $tempDir = $TestDrive
            $res = Save-SnipeitBackup -Latest -path $tempDir -OutFileName 'custom-latest.zip' -Session $script:testSession -Confirm:$false
            $script:capturedCalls.Count | Should -Be 1
            $res.filename | Should -Be 'custom-latest.zip'
            $res.path | Should -Be (Join-Path $tempDir 'custom-latest.zip')
        }

        It 'Performs zero HTTP requests and zero file writes under -WhatIf' {
            Mock Invoke-WebRequest {
                throw "HTTP method should not be invoked under WhatIf"
            }

            $tempDir = [System.IO.Path]::GetTempPath()
            { Save-SnipeitBackup -Latest -path $tempDir -Session $script:testSession -WhatIf } | Should -Not -Throw
        }
    }
}
