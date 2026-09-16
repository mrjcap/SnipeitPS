BeforeAll {
    . "$PSScriptRoot/../SnipeitPS/Classes/SnipeitCache.ps1"
    . "$PSScriptRoot/../SnipeitPS/Classes/SnipeitSession.ps1"
    . "$PSScriptRoot/../SnipeitPS/Classes/SnipeitCompleters.ps1"
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe "Universal Pipeline Fluidity & Chaining" {
    Context "Pipeline Parameter Binding" {
        It "Accepts User ID piped directly into Get-SnipeitAsset" {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = "https://mock.snipeit.local"
                $script:SnipeitPSSession.apiKey = "mock-key"

                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{
                        total = 1
                        rows = @(
                            [PSCustomObject]@{
                                id = 101
                                asset_tag = "TAG-USER-1"
                                name = "User Piped Laptop"
                            }
                        )
                    }
                }

                $userObj = [PSCustomObject]@{
                    user_id = 55
                    username = "pipeuser"
                }

                $asset = $userObj | Get-SnipeitAsset
                $asset | Should -Not -BeNullOrEmpty
                $asset.asset_tag | Should -Be "TAG-USER-1"
            }
        }

        It "Accepts Model ID piped into Get-SnipeitAsset" {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = "https://mock.snipeit.local"
                $script:SnipeitPSSession.apiKey = "mock-key"

                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{
                        total = 1
                        rows = @(
                            [PSCustomObject]@{
                                id = 202
                                asset_tag = "TAG-MODEL-1"
                            }
                        )
                    }
                }

                $modelObj = [PSCustomObject]@{
                    id = 12
                    name = "Precision 5570"
                }

                $assets = $modelObj | Get-SnipeitAsset
                $assets | Should -Not -BeNullOrEmpty
                $assets.id | Should -Be 202
            }
        }

        It "Pipes Assets into Update-SnipeitAssetBulk under -WhatIf safely" {
            InModuleScope 'SnipeitPS' {
                $assets = @(
                    [PSCustomObject]@{ id = 1; asset_tag = "TAG-1" },
                    [PSCustomObject]@{ id = 2; asset_tag = "TAG-2" }
                )

                { $assets | Update-SnipeitAssetBulk -status_id 3 -WhatIf } | Should -Not -Throw
            }
        }
    }
}
