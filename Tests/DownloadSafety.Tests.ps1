BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Authenticated download safety' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:downloadSession = [SnipeitSession]::new('https://contract.invalid', $key)
            Mock Invoke-WebRequest { throw 'Unexpected HTTP' }
            Mock Invoke-RestMethod { throw 'Unexpected HTTP' }
        }

        It 'Rejects unsafe download URI <Uri> before HTTP or destination writes' -ForEach @(
            @{ Uri = 'http://contract.invalid/file' }
            @{ Uri = '/relative/file' }
            @{ Uri = 'file:///C:/file' }
        ) {
            $dest = Join-Path $TestDrive 'preserved.bin'
            [IO.File]::WriteAllText($dest, 'ORIGINAL')
            { Save-SnipeitApiFile -Uri $Uri -OutFile $dest -Force -Session $script:downloadSession } |
                Should -Throw -ExpectedMessage '*absolute HTTPS URL*'
            Should -Invoke Invoke-WebRequest -Times 0 -Exactly
            [IO.File]::ReadAllText($dest) | Should -Be 'ORIGINAL'
        }

        It 'Rejects an HTTP session through the public binary getter' {
            $script:downloadSession.Url = 'http://contract.invalid'
            { Get-SnipeitFile hardware 1 2 -AsByteArray -Session $script:downloadSession } |
                Should -Throw -ExpectedMessage '*absolute HTTPS URL*'
            Should -Invoke Invoke-WebRequest -Times 0 -Exactly
        }

        It 'Preserves the existing <Selection> backup on interrupted transfer' -ForEach @(
            @{ Selection = 'latest'; Arguments = @{ Latest = $true }; Filename = 'latest-backup.zip' }
            @{ Selection = 'named'; Arguments = @{ filename = 'named.zip' }; Filename = 'named.zip' }
        ) {
            $dest = Join-Path $TestDrive $Filename
            [IO.File]::WriteAllText($dest, 'ORIGINAL')
            Mock Invoke-WebRequest {
                param($OutFile)
                [IO.File]::WriteAllText($OutFile, 'PARTIAL')
                throw 'Interrupted transfer'
            }
            Mock Invoke-RestMethod {
                param($OutFile)
                [IO.File]::WriteAllText($OutFile, 'PARTIAL')
                throw 'Interrupted transfer'
            }
            { Save-SnipeitBackup @Arguments -path $TestDrive -Session $script:downloadSession -Confirm:$false -ErrorAction Stop } |
                Should -Throw -ExpectedMessage '*Interrupted transfer*'
            [IO.File]::ReadAllText($dest) | Should -Be 'ORIGINAL'
            @(Get-ChildItem -LiteralPath $TestDrive -Filter '.tmp_*').Count | Should -Be 0
        }

        It 'Downloads backup bytes atomically with redirects disabled and retains output properties' {
            $dest = Join-Path $TestDrive 'latest-backup.zip'
            [IO.File]::WriteAllText($dest, 'OLD')
            [byte[]]$script:backupBytes = 0, 128, 255, 13, 10
            Mock Invoke-WebRequest {
                param($Uri, $Method, $Headers, $OutFile, $MaximumRedirection)
                $script:downloadCall = $PSBoundParameters
                [IO.File]::WriteAllBytes($OutFile, $script:backupBytes)
            }
            $result = Save-SnipeitBackup -Latest -path $TestDrive -Session $script:downloadSession -Confirm:$false
            $script:downloadCall.Uri | Should -Be 'https://contract.invalid/api/v1/settings/backups/download/latest'
            $script:downloadCall.Method | Should -Be 'GET'
            $script:downloadCall.MaximumRedirection | Should -Be 0
            $script:downloadCall.Headers.Authorization | Should -Be 'Bearer test-only-key'
            $script:downloadCall.OutFile | Should -Not -Be $dest
            Test-Path -LiteralPath $script:downloadCall.OutFile | Should -BeFalse
            [Convert]::ToBase64String([IO.File]::ReadAllBytes($dest)) |
                Should -Be ([Convert]::ToBase64String($script:backupBytes))
            $result.status | Should -Be 'success'
            $result.filename | Should -Be 'latest-backup.zip'
            $result.path | Should -Be $dest
            $result.Length | Should -Be 5
            $result.PSObject.TypeNames | Should -Contain 'SnipeitPS.BackupDownload'
        }

        It 'Preserves existing backup when the server returns an API error envelope' {
            $dest = Join-Path $TestDrive 'latest-backup.zip'
            [IO.File]::WriteAllText($dest, 'ORIGINAL')
            Mock Invoke-WebRequest {
                param($OutFile)
                [IO.File]::WriteAllText($OutFile, '{"status":"error","messages":"Backup unavailable"}')
            }
            { Save-SnipeitBackup -Latest -path $TestDrive -Session $script:downloadSession -Confirm:$false -ErrorAction Stop } |
                Should -Throw -ExpectedMessage '*Backup unavailable*'
            [IO.File]::ReadAllText($dest) | Should -Be 'ORIGINAL'
        }

        It 'Performs no HTTP or destination writes under backup WhatIf' {
            $dest = Join-Path $TestDrive 'preview-only.zip'
            Save-SnipeitBackup -Latest -OutFileName 'preview-only.zip' -path $TestDrive -Session $script:downloadSession -WhatIf
            Should -Invoke Invoke-WebRequest -Times 0 -Exactly
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly
            Test-Path -LiteralPath $dest | Should -BeFalse
        }
    }
}
