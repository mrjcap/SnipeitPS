BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

# ============================================================
# Reset-SnipeitAssetOwner
# ============================================================
Describe "Reset-SnipeitAssetOwner" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/hardware/{id}/checkin endpoint with POST method" {
        InModuleScope 'SnipeitPS' {
            Reset-SnipeitAssetOwner -id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/1/checkin" -and
                $Method -eq "POST"
            }
        }
    }

    It "Includes note in the body" {
        InModuleScope 'SnipeitPS' {
            Reset-SnipeitAssetOwner -id 2 -note "Returned from user" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/2/checkin" -and
                $Body.note -eq "Returned from user"
            }
        }
    }

    It "Includes status_id in the body when provided" {
        InModuleScope 'SnipeitPS' {
            Reset-SnipeitAssetOwner -id 3 -status_id 5 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/3/checkin" -and
                $Body.status_id -eq 5
            }
        }
    }

    It "Includes location_id in the body when provided" {
        InModuleScope 'SnipeitPS' {
            Reset-SnipeitAssetOwner -id 4 -location_id 10 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/4/checkin" -and
                $Body.location_id -eq 10
            }
        }
    }

    It "Includes both status_id and location_id in the body when provided" {
        InModuleScope 'SnipeitPS' {
            Reset-SnipeitAssetOwner -id 5 -status_id 2 -location_id 7 -note "test" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/5/checkin" -and
                $Body.status_id -eq 2 -and
                $Body.location_id -eq 7 -and
                $Body.note -eq "test"
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
            Reset-SnipeitAssetOwner -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Reset-SnipeitAccessoryOwner
# ============================================================
Describe "Reset-SnipeitAccessoryOwner" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/accessories/{assigned_pivot_id}/checkin endpoint with Post method" {
        InModuleScope 'SnipeitPS' {
            Reset-SnipeitAccessoryOwner -assigned_pivot_id 42 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/accessories/42/checkin" -and
                $Method -eq "Post"
            }
        }
    }

    It "Sends empty body" {
        InModuleScope 'SnipeitPS' {
            Reset-SnipeitAccessoryOwner -assigned_pivot_id 99 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/accessories/99/checkin" -and
                $Body.Count -eq 0
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
            Reset-SnipeitAccessoryOwner -assigned_pivot_id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Connect-SnipeitPS
# ============================================================
Describe "Connect-SnipeitPS" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Test-SnipeitPSConnection { return $true }
        }
    }

    It "Sets url and apiKey with default parameter set" {
        InModuleScope 'SnipeitPS' {
            Connect-SnipeitPS -url "https://snipeit.example.com" -apiKey "testapikey123"
            $SnipeitPSSession.url | Should -Be "https://snipeit.example.com"
            $SnipeitPSSession.apiKey | Should -Not -BeNullOrEmpty
        }
    }

    It "Sets url and secureApiKey" {
        InModuleScope 'SnipeitPS' {
            $secKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            Connect-SnipeitPS -url "https://snipeit.example.com" -secureApiKey $secKey
            $SnipeitPSSession.url | Should -Be "https://snipeit.example.com"
            $SnipeitPSSession.apiKey | Should -Be $secKey
        }
    }

    It "Sets url and apiKey from PSCredential" {
        InModuleScope 'SnipeitPS' {
            $secPwd = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $cred = New-Object PSCredential("https://snipeit.example.com", $secPwd)
            Connect-SnipeitPS -siteCred $cred
            $SnipeitPSSession.url | Should -Be "https://snipeit.example.com"
        }
    }

    It "Sets throttle parameters" {
        InModuleScope 'SnipeitPS' {
            Connect-SnipeitPS -url "https://snipeit.example.com" -apiKey "testkey" -throttleLimit 10 -throttlePeriod 30000 -throttleThreshold 80 -throttleMode "Constant"
            $SnipeitPSSession.throttleLimit | Should -Be 10
            $SnipeitPSSession.throttlePeriod | Should -Be 30000
            $SnipeitPSSession.throttleThreshold | Should -Be 80
            $SnipeitPSSession.throttleMode | Should -Be "Constant"
        }
    }

    It "Sets default throttle values when not specified" {
        InModuleScope 'SnipeitPS' {
            Connect-SnipeitPS -url "https://snipeit.example.com" -apiKey "testkey"
            $SnipeitPSSession.throttleLimit | Should -Be 0
            $SnipeitPSSession.throttleThreshold | Should -Be 90
            $SnipeitPSSession.throttleMode | Should -Be "Burst"
        }
    }

    It "Creates throttledRequests list when throttleLimit is greater than 0" {
        InModuleScope 'SnipeitPS' {
            Connect-SnipeitPS -url "https://snipeit.example.com" -apiKey "testkey" -throttleLimit 5 -throttlePeriod 10000
            $SnipeitPSSession.Contains('throttledRequests') | Should -BeTrue
            $SnipeitPSSession.throttlePeriod | Should -Be 10000
        }
    }

    It "Throws when Test-SnipeitPSConnection fails" {
        InModuleScope 'SnipeitPS' {
            Mock Test-SnipeitPSConnection { return $false }
            { Connect-SnipeitPS -url "https://bad.example.com" -apiKey "badkey" } | Should -Throw
        }
    }
}

# ============================================================
# Set-SnipeitInfo
# ============================================================
Describe "Set-SnipeitInfo" {
    It "Calls Connect-SnipeitPS and shows deprecation warning" {
        InModuleScope 'SnipeitPS' {
            Mock Connect-SnipeitPS {}
            Mock Write-Warning {}
            Set-SnipeitInfo -url "https://snipeit.example.com" -apiKey "testkey"
            Should -Invoke Connect-SnipeitPS -Times 1
            Should -Invoke Write-Warning -Times 1
        }
    }
}

# ============================================================
# Update-SnipeitAlias
# ============================================================
Describe "Update-SnipeitAlias" {
    It "Replaces old function names with new ones" {
        InModuleScope 'SnipeitPS' {
            $result = "Get-Asset" | Update-SnipeitAlias -Confirm:$false
            $result | Should -Be "Get-SnipeitAsset"
        }
    }

    It "Handles array of strings via pipeline" {
        InModuleScope 'SnipeitPS' {
            $result = @("Get-Asset", "Set-Asset") | Update-SnipeitAlias -Confirm:$false
            $result.Count | Should -Be 2
            $result[0] | Should -Be "Get-SnipeitAsset"
            $result[1] | Should -Be "Set-SnipeitAsset"
        }
    }

    It "Returns string unchanged when no aliases match" {
        InModuleScope 'SnipeitPS' {
            $result = "Write-Host 'hello'" | Update-SnipeitAlias -Confirm:$false
            $result | Should -Be "Write-Host 'hello'"
        }
    }
}

# ============================================================
# Save-SnipeitBackup
# ============================================================
Describe "Save-SnipeitBackup" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod {}
            # Set up session
            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testkey" -AsPlainText -Force
        }
    }

    It "Calls Invoke-RestMethod with correct URL" {
        InModuleScope 'SnipeitPS' {
            $tempDir = [System.IO.Path]::GetTempPath()
            Save-SnipeitBackup -filename "backup.sql" -path $tempDir -Confirm:$false
            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                $Uri -eq "https://snipeit.example.com/api/v1/settings/backups/download/backup.sql"
            }
        }
    }

    It "Returns a success object with filename and path" {
        InModuleScope 'SnipeitPS' {
            $tempDir = [System.IO.Path]::GetTempPath()
            $result = Save-SnipeitBackup -filename "backup.sql" -path $tempDir -Confirm:$false
            $result.status | Should -Be "success"
            $result.filename | Should -Be "backup.sql"
        }
    }

    It "Throws when no session is configured" {
        InModuleScope 'SnipeitPS' {
            $savedUrl = $SnipeitPSSession.url
            $savedKey = $SnipeitPSSession.apiKey
            $SnipeitPSSession.url = $null
            $SnipeitPSSession.apiKey = $null
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $tempDir = [System.IO.Path]::GetTempPath()
            { Save-SnipeitBackup -filename "backup.sql" -path $tempDir -Confirm:$false } | Should -Throw
            $SnipeitPSSession.url = $savedUrl
            $SnipeitPSSession.apiKey = $savedKey
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod {}
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            # Set up legacy session values for the auth resolution
            $SnipeitPSSession.legacyUrl = "http://legacy.example.com"
            $SnipeitPSSession.legacyApiKey = ConvertTo-SecureString "legacykey" -AsPlainText -Force
            $tempDir = [System.IO.Path]::GetTempPath()
            Save-SnipeitBackup -filename "backup.sql" -path $tempDir -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
            # Clean up
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
        }
    }
}
