BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'New-SnipeitImport' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedMultipartCalls = [System.Collections.Generic.List[object]]::new()
        }

        It 'Uploads file using Send-SnipeitMultipart with files[] field name' {
            Mock Send-SnipeitMultipart -ModuleName SnipeitPS {
                param($Uri, $Files, $FileFieldName, $Session)
                $script:capturedMultipartCalls.Add(@{
                    Uri           = $Uri
                    Files         = $Files
                    FileFieldName = $FileFieldName
                    Session       = $Session
                })
                return [pscustomobject]@{
                    files = @(
                        [pscustomobject]@{
                            id        = 10
                            file_path = '2026-upload.csv'
                        }
                    )
                }
            }

            $csvFile = Join-Path $TestDrive 'upload.csv'
            [System.IO.File]::WriteAllText($csvFile, 'asset_tag,model')

            $res = New-SnipeitImport -File $csvFile -Session $script:testSession
            $res.files.Count | Should -Be 1
            $res.files[0].id | Should -Be 10

            $script:capturedMultipartCalls.Count | Should -Be 1
            $script:capturedMultipartCalls[0].Uri | Should -Be 'https://contract.invalid/api/v1/imports'
            $script:capturedMultipartCalls[0].Files[0] | Should -Be $csvFile
            $script:capturedMultipartCalls[0].FileFieldName | Should -Be 'files[]'
            $script:capturedMultipartCalls[0].Session | Should -Be $script:testSession
        }

        It 'Rejects non-existent local file before making HTTP requests' {
            Mock Send-SnipeitMultipart -ModuleName SnipeitPS {
                throw 'Should not reach transport'
            }

            $missing = Join-Path $TestDrive 'missing.csv'
            { New-SnipeitImport -File $missing -Session $script:testSession } |
                Should -Throw -ExpectedMessage '*Cannot find path*'
        }

        It 'Performs separate requests for piped files' {
            Mock Send-SnipeitMultipart -ModuleName SnipeitPS {
                param($Uri, $Files, $FileFieldName, $Session)
                $script:capturedMultipartCalls.Add(@{
                    Uri           = $Uri
                    Files         = $Files
                    FileFieldName = $FileFieldName
                })
                return [pscustomobject]@{
                    files = @(
                        [pscustomobject]@{ id = [System.Guid]::NewGuid().ToString() }
                    )
                }
            }

            $file1 = Join-Path $TestDrive 'first.csv'
            $file2 = Join-Path $TestDrive 'second.csv'
            [System.IO.File]::WriteAllText($file1, 'data1')
            [System.IO.File]::WriteAllText($file2, 'data2')

            $results = @(Get-Item $file1, $file2 | New-SnipeitImport -Session $script:testSession)
            $results.Count | Should -Be 2
            $script:capturedMultipartCalls.Count | Should -Be 2
            $script:capturedMultipartCalls[0].Files[0] | Should -Be $file1
            $script:capturedMultipartCalls[1].Files[0] | Should -Be $file2
        }

        It 'Honors -WhatIf with zero HTTP requests' {
            Mock Send-SnipeitMultipart -ModuleName SnipeitPS {
                throw 'Should not be called when WhatIf is active'
            }

            $csvFile = Join-Path $TestDrive 'whatif.csv'
            [System.IO.File]::WriteAllText($csvFile, 'col1,col2')

            New-SnipeitImport -File $csvFile -Session $script:testSession -WhatIf
            $script:capturedMultipartCalls.Count | Should -Be 0
        }
    }
}
