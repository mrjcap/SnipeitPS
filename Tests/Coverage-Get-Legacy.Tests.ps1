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
                $Route -eq "/api/v1/hardware" -and $Method -eq "Get"
            }
        }
    }

    # Parameter set: Get with id
    It "Calls /api/v1/hardware/{id} endpoint when ID specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAsset -id 5
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/hardware/{id}" -and $PathParameter.id -eq 5 -and $Method -eq "Get"
            }
        }
    }

    # Parameter set: Get with asset tag
    It "Calls /api/v1/hardware/bytag/{tag} endpoint when asset_tag specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAsset -asset_tag "TAG001"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/hardware/bytag/{tag}" -and $PathParameter.tag -eq "TAG001" -and $Method -eq "Get"
            }
        }
    }

    # Parameter set: Get with serial
    It "Calls /api/v1/hardware/byserial/{serial} endpoint when serial specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAsset -serial "SN1234"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/hardware/byserial/{serial}" -and $PathParameter.serial -eq "SN1234" -and $Method -eq "Get"
            }
        }
    }

    # Parameter set: Assets due auditing soon
    It "Calls /api/v1/hardware/audit/due endpoint for audit_due" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAsset -audit_due
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/hardware/audit/due" -and $Method -eq "Get"
            }
        }
    }

    # Parameter set: Assets overdue for auditing
    It "Calls /api/v1/hardware/audit/overdue endpoint for audit_overdue" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAsset -audit_overdue
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/hardware/audit/overdue" -and $Method -eq "Get"
            }
        }
    }

    # Parameter set: Assets checked out to user id
    It "Calls /api/v1/users/{user_id}/assets endpoint for user_id" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAsset -user_id 4
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/users/{user_id}/assets" -and $PathParameter.user_id -eq 4 -and $Method -eq "Get"
            }
        }
    }

    # Parameter set: Assets with component id
    It "Calls /api/v1/components/{component_id}/assets endpoint for component_id" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAsset -component_id 7
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/components/{component_id}/assets" -and $PathParameter.component_id -eq 7 -and $Method -eq "Get"
            }
        }
    }

    # customfields hashtable merge
    It "Merges customfields hashtable into search parameters" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAsset -customfields @{ "_snipeit_mac_address_1" = "00:11:22:33:44:55" }
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/hardware" -and $Method -eq "Get"
            }
        }
    }

    # -all pagination parameter
    It "Handles -all pagination delegation" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Asset1" })
            }
            $result = Get-SnipeitAsset -all -limit 50
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.limit -eq 50
            }
        }
    }

    # -all with -offset
    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Asset1" }) }
            $result = Get-SnipeitAsset -all -offset 10
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.offset -eq 10
            }
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
                $Route -eq "/api/v1/accessories" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/accessories/{id} endpoint when ID specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAccessory -id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/accessories/{id}" -and $PathParameter.id -eq 3 -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/users/{user_id}/accessories endpoint for user_id" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAccessory -user_id 2
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/users/{user_id}/accessories" -and $PathParameter.user_id -eq 2 -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination delegation" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Acc1" })
            }
            $result = Get-SnipeitAccessory -all -limit 50
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.limit -eq 50
            }
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Acc1" }) }
            $result = Get-SnipeitAccessory -all -offset 5
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.offset -eq 5
            }
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
                $Route -eq "/api/v1/reports/activity" -and $Method -eq "Get"
            }
        }
    }

    It "Passes target_type and target_id parameters" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitActivity -target_type "Asset" -target_id 1
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/reports/activity" -and $Method -eq "Get"
            }
        }
    }

    It "Passes item_type and item_id parameters" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitActivity -item_type "Asset" -item_id 5
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/reports/activity" -and $Method -eq "Get"
            }
        }
    }

    It "Passes action_type parameter" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitActivity -action_type "checkout"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/reports/activity" -and $Method -eq "Get"
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

    It "Handles -all pagination delegation" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Act1" })
            }
            $result = Get-SnipeitActivity -all -limit 50
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.limit -eq 50
            }
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Act1" }) }
            $result = Get-SnipeitActivity -all -offset 10
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.offset -eq 10
            }
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
                $Route -eq "/api/v1/maintenances" -and $Method -eq "Get"
            }
        }
    }

    It "Passes asset_id parameter" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAssetMaintenance -asset_id 10
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/maintenances" -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination delegation" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Maint1" })
            }
            $result = Get-SnipeitAssetMaintenance -all -limit 50
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.limit -eq 50
            }
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Maint1" }) }
            $result = Get-SnipeitAssetMaintenance -all -offset 5
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.offset -eq 5
            }
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
                $Route -eq "/api/v1/categories" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/categories/{id} endpoint when ID specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitCategory -id 2
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/categories/{id}" -and $PathParameter.id -eq 2 -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination delegation" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Cat1" })
            }
            $result = Get-SnipeitCategory -all -limit 50
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.limit -eq 50
            }
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Cat1" }) }
            $result = Get-SnipeitCategory -all -offset 5
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.offset -eq 5
            }
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
                $Route -eq "/api/v1/companies" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/companies/{id} endpoint when ID specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitCompany -id 1
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/companies/{id}" -and $PathParameter.id -eq 1 -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination delegation" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Co1" })
            }
            $result = Get-SnipeitCompany -all -limit 50
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.limit -eq 50
            }
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Co1" }) }
            $result = Get-SnipeitCompany -all -offset 5
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.offset -eq 5
            }
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
                $Route -eq "/api/v1/components" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/components/{id} endpoint when ID specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitComponent -id 4
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/components/{id}" -and $PathParameter.id -eq 4 -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination delegation" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Comp1" })
            }
            $result = Get-SnipeitComponent -all -limit 50
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.limit -eq 50
            }
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Comp1" }) }
            $result = Get-SnipeitComponent -all -offset 5
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.offset -eq 5
            }
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
                $Route -eq "/api/v1/consumables" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/consumables/{id} endpoint when ID specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitConsumable -id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/consumables/{id}" -and $PathParameter.id -eq 3 -and $Method -eq "Get"
            }
        }
    }

    It "Handles multiple ids in Get with ID parameter set" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitConsumable -id 3, 4
            Should -Invoke Invoke-SnipeitMethod -Times 2
        }
    }

    It "Handles -all pagination delegation" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Con1" })
            }
            $result = Get-SnipeitConsumable -all -limit 50
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.limit -eq 50
            }
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Con1" }) }
            $result = Get-SnipeitConsumable -all -offset 5
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.offset -eq 5
            }
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
                $Route -eq "/api/v1/fields" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/fields/{id} endpoint when ID specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitCustomField -id 5
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/fields/{id}" -and $PathParameter.id -eq 5 -and $Method -eq "Get"
            }
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
                $Route -eq "/api/v1/departments" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/departments/{id} endpoint when ID specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitDepartment -id 2
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/departments/{id}" -and $PathParameter.id -eq 2 -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination delegation" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Dept1" })
            }
            $result = Get-SnipeitDepartment -all -limit 50
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.limit -eq 50
            }
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Dept1" }) }
            $result = Get-SnipeitDepartment -all -offset 5
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.offset -eq 5
            }
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
                $Route -eq "/api/v1/fieldsets" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/fieldsets/{id} endpoint when ID specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitFieldset -id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/fieldsets/{id}" -and $PathParameter.id -eq 3 -and $Method -eq "Get"
            }
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
                $Route -eq "/api/v1/licenses" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/licenses/{id} endpoint when ID specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitLicense -id 2
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/licenses/{id}" -and $PathParameter.id -eq 2 -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/users/{user_id}/licenses endpoint for user_id" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitLicense -user_id 5
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/users/{user_id}/licenses" -and $PathParameter.user_id -eq 5 -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/hardware/{asset_id}/licenses endpoint for asset_id" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitLicense -asset_id 8
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/hardware/{asset_id}/licenses" -and $PathParameter.asset_id -eq 8 -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination delegation" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Lic1" })
            }
            $result = Get-SnipeitLicense -all -limit 50
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.limit -eq 50
            }
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Lic1" }) }
            $result = Get-SnipeitLicense -all -offset 5
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.offset -eq 5
            }
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
                $Route -eq "/api/v1/licenses/{id}/seats" -and $PathParameter.id -eq 1 -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/licenses/{id}/seats/{seat_id} endpoint when seat_id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitLicenseSeat -id 1 -seat_id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/licenses/{id}/seats/{seat_id}" -and $PathParameter.id -eq 1 -and $PathParameter.seat_id -eq 3 -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination delegation" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Seat1" })
            }
            $result = Get-SnipeitLicenseSeat -id 1 -all -limit 50
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.limit -eq 50
            }
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Seat1" }) }
            $result = Get-SnipeitLicenseSeat -id 1 -all -offset 5
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.offset -eq 5
            }
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
                $Route -eq "/api/v1/locations" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/locations/{id} endpoint when ID specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitLocation -id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/locations/{id}" -and $PathParameter.id -eq 3 -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination delegation" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Loc1" })
            }
            $result = Get-SnipeitLocation -all -limit 50
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.limit -eq 50
            }
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Loc1" }) }
            $result = Get-SnipeitLocation -all -offset 5
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.offset -eq 5
            }
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
                $Route -eq "/api/v1/manufacturers" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/manufacturers/{id} endpoint when ID specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitManufacturer -id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/manufacturers/{id}" -and $PathParameter.id -eq 3 -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination delegation" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Mfr1" })
            }
            $result = Get-SnipeitManufacturer -all -limit 50
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.limit -eq 50
            }
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Mfr1" }) }
            $result = Get-SnipeitManufacturer -all -offset 5
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.offset -eq 5
            }
        }
    }
}

# ────────────────────────────────────────────
# 16. Get-SnipeitModel
# ────────────────────────────────────
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
                $Route -eq "/api/v1/models" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/models/{id} endpoint when ID specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitModel -id 1
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/models/{id}" -and $PathParameter.id -eq 1 -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination delegation" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Model1" })
            }
            $result = Get-SnipeitModel -all -limit 50
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.limit -eq 50
            }
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Model1" }) }
            $result = Get-SnipeitModel -all -offset 5
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.offset -eq 5
            }
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
                $Route -eq "/api/v1/statuslabels" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/statuslabels/{id} endpoint when ID specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitStatus -id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/statuslabels/{id}" -and $PathParameter.id -eq 3 -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination delegation" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Status1" })
            }
            $result = Get-SnipeitStatus -all -limit 50
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.limit -eq 50
            }
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Status1" }) }
            $result = Get-SnipeitStatus -all -offset 5
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.offset -eq 5
            }
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
                $Route -eq "/api/v1/suppliers" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/suppliers/{id} endpoint when ID specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitSupplier -id 2
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/suppliers/{id}" -and $PathParameter.id -eq 2 -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination delegation" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Sup1" })
            }
            $result = Get-SnipeitSupplier -all -limit 50
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.limit -eq 50
            }
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "Sup1" }) }
            $result = Get-SnipeitSupplier -all -offset 5
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.offset -eq 5
            }
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
                $Route -eq "/api/v1/users" -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/users/{id} endpoint when ID specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitUser -id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/users/{id}" -and $PathParameter.id -eq 3 -and $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/accessories/{accessory_id}/checkedout endpoint for accessory_id" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitUser -accessory_id 7
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/accessories/{accessory_id}/checkedout" -and $PathParameter.accessory_id -eq 7 -and $Method -eq "Get"
            }
        }
    }

    It "Handles -all pagination delegation" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "User1" })
            }
            $result = Get-SnipeitUser -all -limit 50
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.limit -eq 50
            }
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @([PSCustomObject]@{ id = 1; name = "User1" }) }
            $result = Get-SnipeitUser -all -offset 5
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and $GetParameters.offset -eq 5
            }
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
            Get-SnipeitAccessoryOwner -id 1
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/accessories/{id}/checkedout" -and $PathParameter.id -eq 1 -and $Method -eq "GET"
            }
        }
    }
}
