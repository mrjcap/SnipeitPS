BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'New-SnipeitFile' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedMultipart = $null
        }

        It 'Uploads file using Send-SnipeitMultipart with notes' {
            Mock Send-SnipeitMultipart -ModuleName SnipeitPS {
                param($Uri, $Files, $Fields, $FileFieldName, $Session)
                $script:capturedMultipart = @{
                    Uri           = $Uri
                    Files         = $Files
                    Fields        = $Fields
                    FileFieldName = $FileFieldName
                }
                return [pscustomobject]@{
                    status   = 'success'
                    messages = 'Uploaded 1 file'
                    payload  = [pscustomobject]@{ id = 10 }
                }
            }

            $dummyFile = Join-Path $TestDrive 'manual.pdf'
            [System.IO.File]::WriteAllText($dummyFile, 'PDF_CONTENT')

            $res = New-SnipeitFile -EntityType 'hardware' -id 1 -File $dummyFile -notes 'Owner manual' -Session $script:testSession
            $res.status | Should -Be 'success'

            $script:capturedMultipart.Uri | Should -Be 'https://contract.invalid/api/v1/hardware/1/files'
            $script:capturedMultipart.Files[0] | Should -Be $dummyFile
            $script:capturedMultipart.Fields.notes | Should -Be 'Owner manual'
            $script:capturedMultipart.FileFieldName | Should -Be 'file[]'
        }

        It 'Throws SnipeitApiError for HTTP 200 upload rejection with <Kind> messages' -ForEach @(
            @{ Kind = 'text'; Messages = 'No files were submitted'; Expected = '*No files were submitted*' }
            @{ Kind = 'fields'; Messages = @{ file = @('Invalid attachment') }; Expected = '*Invalid attachment*' }
        ) {
            Mock Invoke-RestMethod -ModuleName SnipeitPS {
                [pscustomobject]@{ status = 'error'; messages = $Messages; payload = $null }
            }
            $file = Join-Path $TestDrive 'rejected.txt'
            [System.IO.File]::WriteAllText($file, 'DATA')
            $outputs = [System.Collections.Generic.List[object]]::new()

            { New-SnipeitFile -EntityType hardware -id 1 -File $file -Session $script:testSession `
                -ErrorAction Stop -Confirm:$false | ForEach-Object { $outputs.Add($_) } } |
                Should -Throw -ExpectedMessage $Expected -ErrorId 'SnipeitApiError*'
            $outputs.Count | Should -Be 0
            Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ModuleName SnipeitPS
        }

        It 'Preserves the successful upload envelope through the real multipart helper' {
            Mock Invoke-RestMethod -ModuleName SnipeitPS {
                [pscustomobject]@{ status = 'success'; messages = 'Uploaded'; payload = @{ id = 10 } }
            }
            $file = Join-Path $TestDrive 'accepted.txt'
            [System.IO.File]::WriteAllText($file, 'DATA')
            $result = New-SnipeitFile -EntityType hardware -id 1 -File $file -Session $script:testSession
            $result.status | Should -Be 'success'
            $result.messages | Should -Be 'Uploaded'
            $result.payload.id | Should -Be 10
        }

        It 'Rejects non-existent local file before making HTTP requests' {
            Mock Send-SnipeitMultipart -ModuleName SnipeitPS {
                throw 'Should not reach transport'
            }

            $missing = Join-Path $TestDrive 'missing_file.pdf'
            { New-SnipeitFile -EntityType 'models' -id 5 -File $missing -Session $script:testSession } |
                Should -Throw -ExpectedMessage '*Cannot find path*'
        }

        It 'Honors -WhatIf with zero HTTP requests' {
            Mock Send-SnipeitMultipart -ModuleName SnipeitPS {
                throw 'Should not be called when WhatIf is active'
            }

            $dummyFile = Join-Path $TestDrive 'whatif.txt'
            [System.IO.File]::WriteAllText($dummyFile, 'TEXT')

            { New-SnipeitFile -EntityType 'hardware' -id 1 -File $dummyFile -WhatIf -Session $script:testSession } |
                Should -Not -Throw
        }

        It 'Accepts id from pipeline' {
            Mock Send-SnipeitMultipart -ModuleName SnipeitPS {
                param($Uri)
                $script:capturedMultipart = @{ Uri = $Uri }
                return [pscustomobject]@{ status = 'success' }
            }

            $dummyFile = Join-Path $TestDrive 'pipe.txt'
            [System.IO.File]::WriteAllText($dummyFile, 'DATA')

            $inputObj = [pscustomobject]@{ id = 77 }
            $res = $inputObj | New-SnipeitFile -EntityType 'locations' -File $dummyFile -Session $script:testSession
            $script:capturedMultipart.Uri | Should -Be 'https://contract.invalid/api/v1/locations/77/files'
        }
    }
}
