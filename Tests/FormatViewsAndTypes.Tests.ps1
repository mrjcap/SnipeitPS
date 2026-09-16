BeforeAll {
    . "$PSScriptRoot/../SnipeitPS/Classes/SnipeitCache.ps1"
    . "$PSScriptRoot/../SnipeitPS/Classes/SnipeitSession.ps1"
    . "$PSScriptRoot/../SnipeitPS/Classes/SnipeitCompleters.ps1"
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe "Type System, PSTypeName & Format Views" {
    Context "PSTypeName Decoration" {
        It "Decorates hardware asset results with SnipeitPS.Asset" {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = "https://mock.snipeit.local"
                $script:SnipeitPSSession.apiKey = "mock-key"

                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{
                        total = 1
                        rows  = @(
                            [PSCustomObject]@{
                                id = 42
                                asset_tag = "TAG-0042"
                                name = "Engineering Laptop"
                                model = [PSCustomObject]@{ id = 1; name = "ThinkPad P1" }
                                status_label = [PSCustomObject]@{ id = 1; name = "Deployed" }
                            }
                        )
                    }
                }

                $asset = Get-SnipeitAsset -id 42
                $asset | Should -Not -BeNullOrEmpty
                $asset.PSObject.TypeNames | Should -Contain "SnipeitPS.Asset"
            }
        }

        It "Decorates user results with SnipeitPS.User" {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = "https://mock.snipeit.local"
                $script:SnipeitPSSession.apiKey = "mock-key"

                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{
                        total = 1
                        rows  = @(
                            [PSCustomObject]@{
                                id = 7
                                username = "jsmith"
                                name = "John Smith"
                                email = "jsmith@example.com"
                            }
                        )
                    }
                }

                $user = Get-SnipeitUser -id 7
                $user | Should -Not -BeNullOrEmpty
                $user.PSObject.TypeNames | Should -Contain "SnipeitPS.User"
            }
        }

        It "Decorates license results with SnipeitPS.License" {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = "https://mock.snipeit.local"
                $script:SnipeitPSSession.apiKey = "mock-key"

                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{
                        total = 1
                        rows  = @(
                            [PSCustomObject]@{
                                id = 15
                                name = "Visual Studio Enterprise"
                                seats = 100
                                free_seats_count = 20
                            }
                        )
                    }
                }

                $license = Get-SnipeitLicense -id 15
                $license | Should -Not -BeNullOrEmpty
                $license.PSObject.TypeNames | Should -Contain "SnipeitPS.License"
            }
        }

        It "Decorates fieldset results with SnipeitPS.Fieldset" {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = "https://mock.snipeit.local"
                $script:SnipeitPSSession.apiKey = "mock-key"

                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{
                        total = 1
                        rows  = @(
                            [PSCustomObject]@{
                                id = 3
                                name = "Laptop fields"
                            }
                        )
                    }
                }

                $fieldset = Get-SnipeitFieldset -id 3
                $fieldset | Should -Not -BeNullOrEmpty
                $fieldset.PSObject.TypeNames | Should -Contain "SnipeitPS.Fieldset"
            }
        }
    }

    Context "Format Definitions" {
        It "Loads SnipeitPS.format.ps1xml without errors" {
            $formatFile = Join-Path "$PSScriptRoot/../SnipeitPS" -ChildPath "SnipeitPS.format.ps1xml"
            Test-Path $formatFile | Should -BeTrue
            { [xml](Get-Content $formatFile -Raw) } | Should -Not -Throw
        }
    }
}
