BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Legacy file getter binary output' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:testSession = [SnipeitSession]::new('https://contract.invalid', $key)
            $script:testSession.ThrottleLimit = 0
            [byte[]]$script:binaryFixture = 0, 255, 128, 13, 10, 195, 169, 0
        }

        It '<Command> returns one byte-safe wrapper through the real download path' -ForEach @(
            @{ Command = 'Get-SnipeitAssetFile'; Entity = 'hardware' }
            @{ Command = 'Get-SnipeitModelFile'; Entity = 'models' }
        ) {
            Mock Invoke-WebRequest -ModuleName SnipeitPS {
                param($Uri, $OutFile, $Headers)
                $script:downloadUri = $Uri
                $script:downloadAuth = $Headers.Authorization
                $script:downloadTemp = $OutFile
                [System.IO.File]::WriteAllBytes($OutFile, $script:binaryFixture)
                [pscustomobject]@{ StatusCode = 200; Headers = @{} }
            }
            $items = @(& $Command -id 4 -file_id 10 -AsByteArray -Session $script:testSession)
            $items.Count | Should -Be 1
            $items[0].PSObject.TypeNames | Should -Contain 'SnipeitPS.FileContent'
            $items[0].EntityType | Should -Be $Entity
            $items[0].Id | Should -Be 4
            $items[0].FileId | Should -Be 10
            Should -ActualValue $items[0].Content -BeOfType ([byte[]])
            [Convert]::ToBase64String($items[0].Content) | Should -Be ([Convert]::ToBase64String($script:binaryFixture))
            $items[0].Length | Should -Be $script:binaryFixture.Length
            $script:downloadUri | Should -Be "https://contract.invalid/api/v1/$Entity/4/files/10"
            $script:downloadAuth | Should -Be 'Bearer test-only-key'
            Test-Path -LiteralPath $script:downloadTemp | Should -BeFalse
        }

        It '<Command> rejects binary output without a file ID before HTTP' -ForEach @(
            @{ Command = 'Get-SnipeitAssetFile' }
            @{ Command = 'Get-SnipeitModelFile' }
        ) {
            Mock Invoke-WebRequest -ModuleName SnipeitPS { throw 'Unexpected HTTP' }
            { & $Command -id 4 -AsByteArray -Session $script:testSession } |
                Should -Throw -ExpectedMessage '*AsByteArray requires file_id*'
            Should -Invoke Invoke-WebRequest -Times 0 -Exactly -ModuleName SnipeitPS
        }
    }
}
