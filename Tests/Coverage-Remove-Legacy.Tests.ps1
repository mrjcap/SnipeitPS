BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

# ============================================================
# Remove-SnipeitAccessory  ->  /api/v1/accessories/$id
# ============================================================
Describe "Remove-SnipeitAccessory" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls correct endpoint with Delete" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitAccessory -id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/accessories/1" -and $Method -eq "Delete"
            }
        }
    }

    It "Handles array of ids" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitAccessory -id 1,2,3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 3
        }
    }

    It "Accepts pipeline input" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 5 } | Remove-SnipeitAccessory -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/accessories/5"
            }
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Remove-SnipeitAccessory -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Remove-SnipeitAsset  ->  /api/v1/hardware/$id
# ============================================================
Describe "Remove-SnipeitAsset" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls correct endpoint with Delete" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitAsset -id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/1" -and $Method -eq "Delete"
            }
        }
    }

    It "Handles array of ids" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitAsset -id 1,2,3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 3
        }
    }

    It "Accepts pipeline input" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 5 } | Remove-SnipeitAsset -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/5"
            }
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Remove-SnipeitAsset -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Remove-SnipeitAssetMaintenance  ->  /api/v1/maintenances/$id
# ============================================================
Describe "Remove-SnipeitAssetMaintenance" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls correct endpoint with Delete" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitAssetMaintenance -id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/maintenances/1" -and $Method -eq "Delete"
            }
        }
    }

    It "Handles array of ids" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitAssetMaintenance -id 1,2,3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 3
        }
    }

    It "Accepts pipeline input" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 5 } | Remove-SnipeitAssetMaintenance -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/maintenances/5"
            }
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Remove-SnipeitAssetMaintenance -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Remove-SnipeitCategory  ->  /api/v1/categories/$id
# ============================================================
Describe "Remove-SnipeitCategory" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls correct endpoint with Delete" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitCategory -id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/categories/1" -and $Method -eq "Delete"
            }
        }
    }

    It "Handles array of ids" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitCategory -id 1,2,3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 3
        }
    }

    It "Accepts pipeline input" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 5 } | Remove-SnipeitCategory -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/categories/5"
            }
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Remove-SnipeitCategory -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Remove-SnipeitCompany  ->  /api/v1/companies/$id
# ============================================================
Describe "Remove-SnipeitCompany" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls correct endpoint with Delete" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitCompany -id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/companies/1" -and $Method -eq "Delete"
            }
        }
    }

    It "Handles array of ids" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitCompany -id 1,2,3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 3
        }
    }

    It "Accepts pipeline input" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 5 } | Remove-SnipeitCompany -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/companies/5"
            }
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Remove-SnipeitCompany -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Remove-SnipeitComponent  ->  /api/v1/components/$id
# ============================================================
Describe "Remove-SnipeitComponent" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls correct endpoint with Delete" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitComponent -id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/components/1" -and $Method -eq "Delete"
            }
        }
    }

    It "Handles array of ids" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitComponent -id 1,2,3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 3
        }
    }

    It "Accepts pipeline input" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 5 } | Remove-SnipeitComponent -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/components/5"
            }
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Remove-SnipeitComponent -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Remove-SnipeitConsumable  ->  /api/v1/consumables/$id
# ============================================================
Describe "Remove-SnipeitConsumable" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls correct endpoint with Delete" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitConsumable -id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/consumables/1" -and $Method -eq "Delete"
            }
        }
    }

    It "Handles array of ids" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitConsumable -id 1,2,3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 3
        }
    }

    It "Accepts pipeline input" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 5 } | Remove-SnipeitConsumable -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/consumables/5"
            }
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Remove-SnipeitConsumable -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Remove-SnipeitCustomField  ->  /api/v1/fields/$id
# ============================================================
Describe "Remove-SnipeitCustomField" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls correct endpoint with Delete" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitCustomField -id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/fields/1" -and $Method -eq "Delete"
            }
        }
    }

    It "Handles array of ids" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitCustomField -id 1,2,3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 3
        }
    }

    It "Accepts pipeline input" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 5 } | Remove-SnipeitCustomField -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/fields/5"
            }
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Remove-SnipeitCustomField -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Remove-SnipeitDepartment  ->  /api/v1/departments/$id
# ============================================================
Describe "Remove-SnipeitDepartment" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls correct endpoint with Delete" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitDepartment -id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/departments/1" -and $Method -eq "Delete"
            }
        }
    }

    It "Handles array of ids" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitDepartment -id 1,2,3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 3
        }
    }

    It "Accepts pipeline input" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 5 } | Remove-SnipeitDepartment -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/departments/5"
            }
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Remove-SnipeitDepartment -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Remove-SnipeitLicense  ->  /api/v1/licenses/$id
# ============================================================
Describe "Remove-SnipeitLicense" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls correct endpoint with Delete" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitLicense -id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/licenses/1" -and $Method -eq "Delete"
            }
        }
    }

    It "Handles array of ids" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitLicense -id 1,2,3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 3
        }
    }

    It "Accepts pipeline input" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 5 } | Remove-SnipeitLicense -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/licenses/5"
            }
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Remove-SnipeitLicense -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Remove-SnipeitLocation  ->  /api/v1/locations/$id
# ============================================================
Describe "Remove-SnipeitLocation" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls correct endpoint with Delete" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitLocation -id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/locations/1" -and $Method -eq "Delete"
            }
        }
    }

    It "Handles array of ids" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitLocation -id 1,2,3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 3
        }
    }

    It "Accepts pipeline input" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 5 } | Remove-SnipeitLocation -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/locations/5"
            }
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Remove-SnipeitLocation -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Remove-SnipeitManufacturer  ->  /api/v1/manufacturers/$id
# ============================================================
Describe "Remove-SnipeitManufacturer" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls correct endpoint with Delete" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitManufacturer -id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/manufacturers/1" -and $Method -eq "Delete"
            }
        }
    }

    It "Handles array of ids" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitManufacturer -id 1,2,3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 3
        }
    }

    It "Accepts pipeline input" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 5 } | Remove-SnipeitManufacturer -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/manufacturers/5"
            }
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Remove-SnipeitManufacturer -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Remove-SnipeitModel  ->  /api/v1/models/$id
# ============================================================
Describe "Remove-SnipeitModel" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls correct endpoint with Delete" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitModel -id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/models/1" -and $Method -eq "Delete"
            }
        }
    }

    It "Handles array of ids" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitModel -id 1,2,3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 3
        }
    }

    It "Accepts pipeline input" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 5 } | Remove-SnipeitModel -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/models/5"
            }
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Remove-SnipeitModel -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Remove-SnipeitSupplier  ->  /api/v1/suppliers/$id
# ============================================================
Describe "Remove-SnipeitSupplier" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls correct endpoint with Delete" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitSupplier -id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/suppliers/1" -and $Method -eq "Delete"
            }
        }
    }

    It "Handles array of ids" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitSupplier -id 1,2,3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 3
        }
    }

    It "Accepts pipeline input" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 5 } | Remove-SnipeitSupplier -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/suppliers/5"
            }
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Remove-SnipeitSupplier -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Remove-SnipeitUser  ->  /api/v1/users/$id
# ============================================================
Describe "Remove-SnipeitUser" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls correct endpoint with Delete" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitUser -id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/users/1" -and $Method -eq "Delete"
            }
        }
    }

    It "Handles array of ids" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitUser -id 1,2,3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 3
        }
    }

    It "Accepts pipeline input" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 5 } | Remove-SnipeitUser -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/users/5"
            }
        }
    }

    It "Handles legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Remove-SnipeitUser -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}
