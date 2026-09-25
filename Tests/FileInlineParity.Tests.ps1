BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'File inline disposition query parity' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:fileSession = [SnipeitSession]::new('https://contract.invalid', $key)
            $script:fileSession.ThrottleLimit = 0
            $script:downloadUris = [System.Collections.Generic.List[string]]::new()
            Mock Invoke-WebRequest {
                param($Uri, $OutFile)
                $script:downloadUris.Add([string]$Uri)
                [IO.File]::WriteAllBytes($OutFile, [byte[]]@(0, 128, 255, 13, 10))
                [pscustomobject]@{ Headers = @{ 'Content-Type' = 'application/octet-stream' } }
            }
            Mock Invoke-RestMethod {
                param($Uri)
                $script:downloadUris.Add([string]$Uri)
                [pscustomobject]@{ id = 8 }
            }
        }

        Context '<Command> retrieval' -ForEach @(
            @{ Command = 'Get-SnipeitFile'; Parameters = @{ EntityType = 'hardware' }; Entity = 'hardware' }
            @{ Command = 'Get-SnipeitAssetFile'; Parameters = @{}; Entity = 'hardware' }
            @{ Command = 'Get-SnipeitModelFile'; Parameters = @{}; Entity = 'models' }
        ) {
            It 'Retains binary bytes with inline=true' {
                $result = & $Command @Parameters -id 2 -file_id 8 -AsByteArray -inline -Session $script:fileSession
                $result.Content | Should -Be ([byte[]]@(0, 128, 255, 13, 10))
                $script:downloadUris.Count | Should -Be 1
                $script:downloadUris[0] | Should -BeExactly "https://contract.invalid/api/v1/$Entity/2/files/8?inline=true"
                Should -Invoke Invoke-RestMethod -Times 0 -Exactly
            }

            It 'Retains explicit false on binary reads' {
                $null = & $Command @Parameters -id 2 -file_id 8 -AsByteArray -inline:$false -Session $script:fileSession
                $script:downloadUris[0] | Should -Match '\?inline=false$'
            }

            It 'Preserves omission on binary reads' {
                $null = & $Command @Parameters -id 2 -file_id 8 -AsByteArray -Session $script:fileSession
                $script:downloadUris[0] | Should -Not -Match '\?'
            }

            It 'Forwards the option for ordinary single-file reads too' {
                $null = & $Command @Parameters -id 2 -file_id 8 -inline -Session $script:fileSession
                $script:downloadUris[0] | Should -Match '\?inline=true$'
            }

            It 'Does not accept inline as a list filter' {
                { & $Command @Parameters -id 2 -inline -Session $script:fileSession } | Should -Throw
                $script:downloadUris.Count | Should -Be 0
            }
        }

        It 'Saves identical bytes with an inline disposition request' {
            $path = Join-Path $TestDrive 'inline.bin'
            $result = Save-SnipeitFile -EntityType models -id 2 -file_id 8 -OutFile $path -inline -Session $script:fileSession -Confirm:$false
            [IO.File]::ReadAllBytes($path) | Should -Be ([byte[]]@(0, 128, 255, 13, 10))
            $result.Length | Should -Be 5
            $script:downloadUris[0] | Should -Match '/models/2/files/8\?inline=true$'
        }

        It 'Does not download or create a file under WhatIf' {
            $path = Join-Path $TestDrive 'whatif.bin'
            Save-SnipeitFile -EntityType models -id 2 -file_id 8 -OutFile $path -inline -Session $script:fileSession -WhatIf
            Test-Path $path | Should -BeFalse
            $script:downloadUris.Count | Should -Be 0
        }
    }
}
