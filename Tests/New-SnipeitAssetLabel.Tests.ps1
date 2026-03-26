BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

Describe "New-SnipeitAssetLabel" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/hardware/labels endpoint with POST method" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitAssetLabel -asset_ids 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/labels" -and
                $Method -eq "POST"
            }
        }
    }

    It "Body contains asset_ids" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitAssetLabel -asset_ids 1,2,3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.asset_ids.Count -eq 3 -and
                $Body.asset_ids[0] -eq 1 -and
                $Body.asset_ids[1] -eq 2 -and
                $Body.asset_ids[2] -eq 3
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            New-SnipeitAssetLabel -asset_ids 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}
