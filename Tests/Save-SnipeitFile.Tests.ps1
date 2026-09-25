BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Save-SnipeitFile' {
    InModuleScope SnipeitPS {
        BeforeAll {
            [byte[]]$script:binaryFixture = 0, 255, 128, 13, 10, 195, 169, 0
        }

        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
        }

        It 'Downloads file and returns SnipeitPS.FileDownload' {
            $dest = Join-Path $TestDrive 'saved_file.bin'
            Mock Save-SnipeitApiFile -ModuleName SnipeitPS {
                param($Uri, $OutFile, $EntityType, $Id, $FileId, $Force, $Session)
                [System.IO.File]::WriteAllBytes($OutFile, $script:binaryFixture)
                return [pscustomobject]@{
                    PSTypeName  = 'SnipeitPS.FileDownload'
                    EntityType  = $EntityType
                    Id          = $Id
                    FileId      = $FileId
                    Path        = $OutFile
                    Length      = $script:binaryFixture.Length
                    ContentType = 'application/octet-stream'
                }
            }

            $res = Save-SnipeitFile -EntityType 'hardware' -id 1 -file_id 10 -OutFile $dest -Session $script:testSession
            $res.PSObject.TypeNames | Should -Contain 'SnipeitPS.FileDownload'
            $res.Path | Should -Be $dest
            $res.Length | Should -Be $script:binaryFixture.Length

            [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($dest)) |
                Should -Be ([System.Convert]::ToBase64String($script:binaryFixture))
        }

        It 'Honors -WhatIf with zero HTTP or file operations' {
            Mock Save-SnipeitApiFile -ModuleName SnipeitPS {
                throw 'Should not be called when WhatIf is active'
            }

            $dest = Join-Path $TestDrive 'whatif.bin'
            { Save-SnipeitFile -EntityType 'hardware' -id 1 -file_id 10 -OutFile $dest -WhatIf -Session $script:testSession } |
                Should -Not -Throw

            (Test-Path $dest) | Should -BeFalse
        }

        It 'Accepts pipeline input for id and file_id' {
            Mock Save-SnipeitApiFile -ModuleName SnipeitPS {
                param($Uri, $OutFile, $EntityType, $Id, $FileId, $Force, $Session)
                return [pscustomobject]@{
                    PSTypeName  = 'SnipeitPS.FileDownload'
                    EntityType  = $EntityType
                    Id          = $Id
                    FileId      = $FileId
                    Path        = $OutFile
                    Length      = 0
                    ContentType = 'application/octet-stream'
                }
            }

            $inputObj = [pscustomobject]@{ id = 5; file_id = 99 }
            $dest = Join-Path $TestDrive 'pipeline.bin'

            $res = $inputObj | Save-SnipeitFile -EntityType 'licenses' -OutFile $dest -Session $script:testSession
            $res.Id | Should -Be 5
            $res.FileId | Should -Be 99
        }
    }
}
