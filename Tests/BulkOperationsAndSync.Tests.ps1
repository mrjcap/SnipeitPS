BeforeAll {
    . "$PSScriptRoot/../SnipeitPS/Classes/SnipeitCache.ps1"
    . "$PSScriptRoot/../SnipeitPS/Classes/SnipeitSession.ps1"
    . "$PSScriptRoot/../SnipeitPS/Classes/SnipeitCompleters.ps1"
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe "Bulk Operations & Declarative State Sync" {
    Context "Bulk Operations" {
        It "Submits batched IDs to PATCH /hardware/bulk" {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = "https://mock.snipeit.local"
                $script:SnipeitPSSession.apiKey = "mock-key"

                $capturedBody = $null
                Mock Invoke-RestMethod {
                    $script:capturedBody = $Body
                    return [PSCustomObject]@{
                        status = "success"
                        messages = "Assets updated"
                    }
                }

                Update-SnipeitAssetBulk -id @(10, 20, 30) -status_id 2 -notes "Bulk test" -Confirm:$false
                $script:capturedBody | Should -Not -BeNullOrEmpty
                $jsonStr = [System.Text.Encoding]::UTF8.GetString($script:capturedBody)
                $parsed = $jsonStr | ConvertFrom-Json
                $parsed.ids.Count | Should -Be 3
                $parsed.status_id | Should -Be 2
                Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
                    $Method -eq 'PATCH' -and $Uri -like '*/hardware/bulk'
                }
            }
        }

        It "Deletes each asset with DELETE /hardware/{id}" {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = "https://mock.snipeit.local"
                $script:SnipeitPSSession.apiKey = "mock-key"

                $capturedBody = $null
                Mock Invoke-RestMethod {
                    $script:capturedBody = $Body
                    return [PSCustomObject]@{
                        status = "success"
                        messages = "Assets deleted"
                    }
                }

                $result = @(Remove-SnipeitAssetBulk -id @(101, 102) -Confirm:$false)
                $script:capturedBody | Should -BeNullOrEmpty
                $result.id | Should -Be @(101,102)
                foreach ($assetId in @(101,102)) {
                    Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
                        $Method -eq 'DELETE' -and $Uri -like "*/hardware/$assetId"
                    }
                }
            }
        }
    }

    Context "Declarative State Sync (Sync-SnipeitAsset)" {
        It "Stops without mutation when the lookup fails for Ensure = Present" {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = "https://mock.snipeit.local"
                $script:SnipeitPSSession.apiKey = "mock-key"

                Mock Get-SnipeitAsset { throw "Asset lookup timed out." }
                Mock New-SnipeitAsset {}
                Mock Set-SnipeitAsset {}
                Mock Remove-SnipeitAsset {}

                $lookupError = $null
                try {
                    Sync-SnipeitAsset -asset_tag "SYNC-FAIL" -model_id 1 -status_id 1 -Ensure Present -Confirm:$false
                } catch {
                    $lookupError = $_
                }

                Should -Invoke New-SnipeitAsset -Times 0 -Exactly
                Should -Invoke Set-SnipeitAsset -Times 0 -Exactly
                Should -Invoke Remove-SnipeitAsset -Times 0 -Exactly
                $lookupError.Exception.Message | Should -Be "Asset lookup timed out."
            }
        }

        It "Stops without mutation when the lookup fails for Ensure = Absent" {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = "https://mock.snipeit.local"
                $script:SnipeitPSSession.apiKey = "mock-key"

                Mock Get-SnipeitAsset { throw "Asset lookup unauthorized." }
                Mock New-SnipeitAsset {}
                Mock Set-SnipeitAsset {}
                Mock Remove-SnipeitAsset {}

                $lookupError = $null
                try {
                    Sync-SnipeitAsset -asset_tag "SYNC-FAIL" -Ensure Absent -Confirm:$false
                } catch {
                    $lookupError = $_
                }

                Should -Invoke New-SnipeitAsset -Times 0 -Exactly
                Should -Invoke Set-SnipeitAsset -Times 0 -Exactly
                Should -Invoke Remove-SnipeitAsset -Times 0 -Exactly
                $lookupError.Exception.Message | Should -Be "Asset lookup unauthorized."
            }
        }

        It "Creates new asset when Ensure = Present and asset is absent" {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = "https://mock.snipeit.local"
                $script:SnipeitPSSession.apiKey = "mock-key"

                Mock Get-SnipeitAsset { return $null }
                Mock New-SnipeitAsset {
                    return [PSCustomObject]@{
                        id = 99
                        asset_tag = "SYNC-001"
                    }
                }

                $res = Sync-SnipeitAsset -asset_tag "SYNC-001" -name "Sync Test" -model_id 1 -status_id 1 -Ensure Present -Confirm:$false
                $res | Should -Not -BeNullOrEmpty
                $res.id | Should -Be 99
            }
        }

        It "Is idempotent when asset matches desired state exactly" {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = "https://mock.snipeit.local"
                $script:SnipeitPSSession.apiKey = "mock-key"

                Mock Get-SnipeitAsset {
                    return [PSCustomObject]@{
                        id = 99
                        asset_tag = "SYNC-001"
                        name = "Sync Test"
                        model = [PSCustomObject]@{ id = 1 }
                        status_label = [PSCustomObject]@{ id = 1 }
                    }
                }

                $setCalled = $false
                Mock Set-SnipeitAsset {
                    $script:setCalled = $true
                }

                $res = Sync-SnipeitAsset -asset_tag "SYNC-001" -name "Sync Test" -model_id 1 -status_id 1 -Ensure Present -Confirm:$false
                $script:setCalled | Should -BeFalse
                $res.id | Should -Be 99
            }
        }

        It "Deletes asset when Ensure = Absent and asset exists" {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = "https://mock.snipeit.local"
                $script:SnipeitPSSession.apiKey = "mock-key"

                Mock Get-SnipeitAsset {
                    return [PSCustomObject]@{
                        id = 88
                        asset_tag = "DELETE-TAG"
                    }
                }

                $deletedId = $null
                Mock Remove-SnipeitAsset {
                    $script:deletedId = $id
                }

                Sync-SnipeitAsset -asset_tag "DELETE-TAG" -Ensure Absent -Confirm:$false
                $script:deletedId | Should -Be 88
            }
        }

        It "Passes custom Session object to all internal cmdlets during sync" {
            InModuleScope 'SnipeitPS' {
                $mockSession = [SnipeitSession]::new("https://tenant.example.com", (ConvertTo-SecureString -String "secret" -AsPlainText -Force))
                $capturedGetSession = $null
                $capturedSetSession = $null

                Mock Get-SnipeitAsset {
                    $script:capturedGetSession = $Session
                    return [PSCustomObject]@{
                        id = 42
                        name = "Old Name"
                        model = [PSCustomObject]@{ id = 1 }
                        status_label = [PSCustomObject]@{ id = 1 }
                    }
                }
                Mock Set-SnipeitAsset {
                    $script:capturedSetSession = $Session
                    return [PSCustomObject]@{ id = 42; name = "New Name" }
                }

                Sync-SnipeitAsset -asset_tag "SRV-01" -name "New Name" -Session $mockSession -Confirm:$false
                $script:capturedGetSession | Should -Be $mockSession
                $script:capturedSetSession | Should -Be $mockSession
            }
        }
    }
}
