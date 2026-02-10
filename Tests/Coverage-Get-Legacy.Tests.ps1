BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

# ────────────────────────────────────────────
# 1. Get-SnipeitAsset
# ────────────────────────────────────────────
Describe "Get-SnipeitAsset" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    # Parameter set: Search (default)
    It "Calls /api/v1/hardware endpoint for search" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAsset -search "laptop"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware" -and $Method -eq "Get"
            }
        }
    }

    # Parameter set: Get with id
    It "Calls /api/v1/hardware/{id} endpoint when id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAsset -id 5
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/5" -and $Method -eq "Get"
            }
        }
    }

    # Parameter set: Get with asset tag
    It "Calls /api/v1/hardware/bytag/{tag} endpoint when asset_tag specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAsset -asset_tag "TAG001"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/bytag/TAG001" -and $Method -eq "Get"
            }
        }
    }

    # Parameter set: Get with serial
    It "Calls /api/v1/hardware/byserial/{serial} endpoint when serial specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAsset -serial "SN1234"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/byserial/SN1234" -and $Method -eq "Get"
            }
        }
    }

    # Parameter set: Assets due auditing soon
    It "Calls /api/v1/hardware/audit/due endpoint for audit_due" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAsset -audit_due
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/audit/due" -and $Method -eq "Get"
            }
        }
    }

    # Parameter set: Assets overdue for auditing
    It "Calls /api/v1/hardware/audit/overdue endpoint for audit_overdue" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAsset -audit_overdue
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/audit/overdue" -and $Method -eq "Get"
            }
        }
    }

    # Parameter set: Assets checked out to user id
    It "Calls /api/v1/users/{user_id}/assets endpoint for user_id" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAsset -user_id 4
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/users/4/assets" -and $Method -eq "Get"
            }
        }
    }

    # Parameter set: Assets with component id
    It "Calls /api/v1/components/{component_id}/assets endpoint for component_id" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAsset -component_id 7
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/components/7/assets" -and $Method -eq "Get"
            }
        }
    }

    # customfields hashtable merge
    It "Merges customfields hashtable into search parameters" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAsset -customfields @{ "_snipeit_mac_address_1" = "00:11:22:33:44:55" }
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware" -and $Method -eq "Get"
            }
        }
    }

    # -all pagination loop
    It "Handles -all pagination loop" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Asset$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Asset51" })
                }
            }
            $result = Get-SnipeitAsset -all -limit 50
            $result.Count | Should -Be 51
        }
    }

    # -all with offset
    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Asset1" }) }
            $result = Get-SnipeitAsset -all -offset 10
            $result | Should -Not -BeNullOrEmpty
        }
    }

    # legacy url and apiKey
    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitAsset -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ────────────────────────────────────────────
# 2. Get-SnipeitAccessory
# ────────────────────────────────────────────
Describe "Get-SnipeitAccessory" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/accessories endpoint for search" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAccessory -search "Keyboard"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/accessories" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/accessories/{id} endpoint when id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAccessory -id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/accessories/3" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/users/{user_id}/accessories endpoint for user_id" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAccessory -user_id 2
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/users/2/accessories" -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination loop" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Acc$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Acc51" })
                }
            }
            $result = Get-SnipeitAccessory -all -limit 50
            $result.Count | Should -Be 51
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Acc1" }) }
            $result = Get-SnipeitAccessory -all -offset 5
            $result | Should -Not -BeNullOrEmpty
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitAccessory -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ────────────────────────────────────────────
# 3. Get-SnipeitActivity
# ────────────────────────────────────────────
Describe "Get-SnipeitActivity" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/reports/activity endpoint for search" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitActivity -search "checkout"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/reports/activity" -and $Method -eq "Get"
            }
        }
    }

    It "Passes target_type and target_id parameters" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitActivity -target_type "Asset" -target_id 1
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/reports/activity" -and $Method -eq "Get"
            }
        }
    }

    It "Passes item_type and item_id parameters" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitActivity -item_type "Asset" -item_id 5
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/reports/activity" -and $Method -eq "Get"
            }
        }
    }

    It "Passes action_type parameter" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitActivity -action_type "checkout"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/reports/activity" -and $Method -eq "Get"
            }
        }
    }

    It "Throws when target_type without target_id" {
        InModuleScope 'SnipeitPS' {
            { Get-SnipeitActivity -target_type "Asset" } | Should -Throw "Please specify both target_type and target_id"
        }
    }

    It "Throws when target_id without target_type" {
        InModuleScope 'SnipeitPS' {
            { Get-SnipeitActivity -target_id 1 } | Should -Throw "Please specify both target_type and target_id"
        }
    }

    It "Throws when item_type without item_id" {
        InModuleScope 'SnipeitPS' {
            { Get-SnipeitActivity -item_type "Asset" } | Should -Throw "Please specify both item_type and item_id"
        }
    }

    It "Throws when item_id without item_type" {
        InModuleScope 'SnipeitPS' {
            { Get-SnipeitActivity -item_id 1 } | Should -Throw "Please specify both item_type and item_id"
        }
    }

    It "Handles -all pagination loop" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Act$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Act51" })
                }
            }
            $result = Get-SnipeitActivity -all -limit 50
            $result.Count | Should -Be 51
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Act1" }) }
            $result = Get-SnipeitActivity -all -offset 10
            $result | Should -Not -BeNullOrEmpty
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitActivity -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ────────────────────────────────────────────
# 4. Get-SnipeitAssetMaintenance
# ────────────────────────────────────────────
Describe "Get-SnipeitAssetMaintenance" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/maintenances endpoint for search" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAssetMaintenance -search "repair"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/maintenances" -and $Method -eq "Get"
            }
        }
    }

    It "Passes asset_id parameter" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAssetMaintenance -asset_id 10
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/maintenances" -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination loop" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Maint$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Maint51" })
                }
            }
            $result = Get-SnipeitAssetMaintenance -all -limit 50
            $result.Count | Should -Be 51
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Maint1" }) }
            $result = Get-SnipeitAssetMaintenance -all -offset 5
            $result | Should -Not -BeNullOrEmpty
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitAssetMaintenance -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ────────────────────────────────────────────
# 5. Get-SnipeitCategory
# ────────────────────────────────────────────
Describe "Get-SnipeitCategory" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/categories endpoint for search" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitCategory -search "Laptop"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/categories" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/categories/{id} endpoint when id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitCategory -id 2
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/categories/2" -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination loop" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Cat$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Cat51" })
                }
            }
            $result = Get-SnipeitCategory -all -limit 50
            $result.Count | Should -Be 51
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Cat1" }) }
            $result = Get-SnipeitCategory -all -offset 5
            $result | Should -Not -BeNullOrEmpty
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitCategory -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ────────────────────────────────────────────
# 6. Get-SnipeitCompany
# ────────────────────────────────────────────
Describe "Get-SnipeitCompany" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/companies endpoint for search" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitCompany -search "Acme"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/companies" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/companies/{id} endpoint when id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitCompany -id 1
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/companies/1" -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination loop" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Co$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Co51" })
                }
            }
            $result = Get-SnipeitCompany -all -limit 50
            $result.Count | Should -Be 51
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Co1" }) }
            $result = Get-SnipeitCompany -all -offset 5
            $result | Should -Not -BeNullOrEmpty
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitCompany -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ────────────────────────────────────────────
# 7. Get-SnipeitComponent
# ────────────────────────────────────────────
Describe "Get-SnipeitComponent" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/components endpoint for search" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitComponent -search "display"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/components" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/components/{id} endpoint when id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitComponent -id 4
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/components/4" -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination loop" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Comp$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Comp51" })
                }
            }
            $result = Get-SnipeitComponent -all -limit 50
            $result.Count | Should -Be 51
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Comp1" }) }
            $result = Get-SnipeitComponent -all -offset 5
            $result | Should -Not -BeNullOrEmpty
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitComponent -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ────────────────────────────────────────────
# 8. Get-SnipeitConsumable
# ────────────────────────────────────────────
Describe "Get-SnipeitConsumable" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/consumables endpoint for search" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitConsumable -search "paper"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/consumables" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/consumables/{id} endpoint when id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitConsumable -id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -match "/api/v1/consumables/3" -and $Method -eq "Get"
            }
        }
    }

    It "Handles multiple ids in Get with ID parameter set" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitConsumable -id 3, 4
            Should -Invoke Invoke-SnipeitMethod -Times 2
        }
    }

    It "Handles -all pagination loop" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Con$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Con51" })
                }
            }
            $result = Get-SnipeitConsumable -all -limit 50
            $result.Count | Should -Be 51
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Con1" }) }
            $result = Get-SnipeitConsumable -all -offset 5
            $result | Should -Not -BeNullOrEmpty
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitConsumable -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ────────────────────────────────────────────
# 9. Get-SnipeitCustomField
# ────────────────────────────────────────────
Describe "Get-SnipeitCustomField" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/fields endpoint for list all" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitCustomField
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/fields" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/fields/{id} endpoint when id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitCustomField -id 5
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/fields/5" -and $Method -eq "Get"
            }
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitCustomField -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ────────────────────────────────────────────
# 10. Get-SnipeitDepartment
# ────────────────────────────────────────────
Describe "Get-SnipeitDepartment" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/departments endpoint for search" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitDepartment -search "IT"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/departments" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/departments/{id} endpoint when id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitDepartment -id 2
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/departments/2" -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination loop" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Dept$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Dept51" })
                }
            }
            $result = Get-SnipeitDepartment -all -limit 50
            $result.Count | Should -Be 51
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Dept1" }) }
            $result = Get-SnipeitDepartment -all -offset 5
            $result | Should -Not -BeNullOrEmpty
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitDepartment -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ────────────────────────────────────────────
# 11. Get-SnipeitFieldset
# ────────────────────────────────────────────
Describe "Get-SnipeitFieldset" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/fieldsets endpoint for list all" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitFieldset
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/fieldsets" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/fieldsets/{id} endpoint when id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitFieldset -id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/fieldsets/3" -and $Method -eq "Get"
            }
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitFieldset -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ────────────────────────────────────────────
# 12. Get-SnipeitLicense
# ────────────────────────────────────────────
Describe "Get-SnipeitLicense" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/licenses endpoint for search" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitLicense -search "Office"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/licenses" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/licenses/{id} endpoint when id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitLicense -id 2
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/licenses/2" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/users/{user_id}/licenses endpoint for user_id" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitLicense -user_id 5
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/users/5/licenses" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/hardware/{asset_id}/licenses endpoint for asset_id" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitLicense -asset_id 8
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/8/licenses" -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination loop" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Lic$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Lic51" })
                }
            }
            $result = Get-SnipeitLicense -all -limit 50
            $result.Count | Should -Be 51
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Lic1" }) }
            $result = Get-SnipeitLicense -all -offset 5
            $result | Should -Not -BeNullOrEmpty
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitLicense -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ────────────────────────────────────────────
# 13. Get-SnipeitLicenseSeat
# ────────────────────────────────────────────
Describe "Get-SnipeitLicenseSeat" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/licenses/{id}/seats endpoint" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitLicenseSeat -id 1
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/licenses/1/seats" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/licenses/{id}/seats/{seat_id} endpoint when seat_id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitLicenseSeat -id 1 -seat_id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/licenses/1/seats/3" -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination loop" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Seat$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Seat51" })
                }
            }
            $result = Get-SnipeitLicenseSeat -id 1 -all -limit 50
            $result.Count | Should -Be 51
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Seat1" }) }
            $result = Get-SnipeitLicenseSeat -id 1 -all -offset 5
            $result | Should -Not -BeNullOrEmpty
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitLicenseSeat -id 1 -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ────────────────────────────────────────────
# 14. Get-SnipeitLocation
# ────────────────────────────────────────────
Describe "Get-SnipeitLocation" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/locations endpoint for search" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitLocation -search "HQ"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/locations" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/locations/{id} endpoint when id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitLocation -id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/locations/3" -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination loop" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Loc$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Loc51" })
                }
            }
            $result = Get-SnipeitLocation -all -limit 50
            $result.Count | Should -Be 51
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Loc1" }) }
            $result = Get-SnipeitLocation -all -offset 5
            $result | Should -Not -BeNullOrEmpty
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitLocation -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ────────────────────────────────────────────
# 15. Get-SnipeitManufacturer
# ────────────────────────────────────────────
Describe "Get-SnipeitManufacturer" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/manufacturers endpoint for search" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitManufacturer -search "HP"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/manufacturers" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/manufacturers/{id} endpoint when id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitManufacturer -id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/manufacturers/3" -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination loop" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Mfr$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Mfr51" })
                }
            }
            $result = Get-SnipeitManufacturer -all -limit 50
            $result.Count | Should -Be 51
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Mfr1" }) }
            $result = Get-SnipeitManufacturer -all -offset 5
            $result | Should -Not -BeNullOrEmpty
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitManufacturer -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ────────────────────────────────────────────
# 16. Get-SnipeitModel
# ────────────────────────────────────────────
Describe "Get-SnipeitModel" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/models endpoint for search" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitModel -search "DL380"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/models" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/models/{id} endpoint when id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitModel -id 1
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/models/1" -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination loop" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Model$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Model51" })
                }
            }
            $result = Get-SnipeitModel -all -limit 50
            $result.Count | Should -Be 51
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Model1" }) }
            $result = Get-SnipeitModel -all -offset 5
            $result | Should -Not -BeNullOrEmpty
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitModel -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ────────────────────────────────────────────
# 17. Get-SnipeitStatus
# ────────────────────────────────────────────
Describe "Get-SnipeitStatus" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/statuslabels endpoint for search" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitStatus -search "Ready to Deploy"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/statuslabels" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/statuslabels/{id} endpoint when id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitStatus -id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/statuslabels/3" -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination loop" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Status$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Status51" })
                }
            }
            $result = Get-SnipeitStatus -all -limit 50
            $result.Count | Should -Be 51
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Status1" }) }
            $result = Get-SnipeitStatus -all -offset 5
            $result | Should -Not -BeNullOrEmpty
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitStatus -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ────────────────────────────────────────────
# 18. Get-SnipeitSupplier
# ────────────────────────────────────────────
Describe "Get-SnipeitSupplier" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/suppliers endpoint for search" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitSupplier -search "Acme"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/suppliers" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/suppliers/{id} endpoint when id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitSupplier -id 2
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/suppliers/2" -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination loop" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Sup$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Sup51" })
                }
            }
            $result = Get-SnipeitSupplier -all -limit 50
            $result.Count | Should -Be 51
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Sup1" }) }
            $result = Get-SnipeitSupplier -all -offset 5
            $result | Should -Not -BeNullOrEmpty
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitSupplier -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ────────────────────────────────────────────
# 19. Get-SnipeitUser
# ────────────────────────────────────────────
Describe "Get-SnipeitUser" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/users endpoint for search" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitUser -search "John"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/users" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/users/{id} endpoint when id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitUser -id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/users/3" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/accessories/{accessory_id}/checkedout endpoint for accessory_id" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitUser -accessory_id 7
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/accessories/7/checkedout" -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination loop" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "User$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "User51" })
                }
            }
            $result = Get-SnipeitUser -all -limit 50
            $result.Count | Should -Be 51
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "User1" }) }
            $result = Get-SnipeitUser -all -offset 5
            $result | Should -Not -BeNullOrEmpty
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitUser -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ────────────────────────────────────────────
# 20. Get-SnipeitAccessoryOwner
# ────────────────────────────────────────────
Describe "Get-SnipeitAccessoryOwner" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/accessories/{id}/checkedout endpoint" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAccessoryOwner -id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/accessories/1/checkedout" -and $Method -eq "GET"
            }
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitAccessoryOwner -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}
