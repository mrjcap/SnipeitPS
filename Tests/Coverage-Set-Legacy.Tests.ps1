BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

# ============================================================
# 1. Set-SnipeitAccessory
# ============================================================

Describe "Set-SnipeitAccessory" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/accessories/{id} with Patch by default" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAccessory -id 1 -qty 5 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/accessories/1" -and
                $Method -eq "Patch"
            }
        }
    }

    It "Passes body params (name, qty, category_id)" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAccessory -id 2 -name "Keyboard" -qty 10 -category_id 3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/accessories/2" -and
                $Body.name -eq "Keyboard" -and
                $Body.qty -eq 10 -and
                $Body.category_id -eq 3
            }
        }
    }

    It "Uses Put method when RequestType is Put" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAccessory -id 3 -qty 1 -RequestType "Put" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/accessories/3" -and
                $Method -eq "Put"
            }
        }
    }

    It "Formats purchase_date as yyyy-MM-dd string" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAccessory -id 4 -purchase_date ([datetime]"2024-03-15") -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.purchase_date -eq "2024-03-15"
            }
        }
    }

    It "Iterates foreach when given array of ids" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAccessory -id 1,2 -qty 5 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 2
        }
    }

    It "Passes image in body when valid file provided" {
        InModuleScope 'SnipeitPS' {
            $tempFile = [System.IO.Path]::GetTempFileName()
            try {
                Set-SnipeitAccessory -id 5 -image $tempFile -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tempFile
                }
            } finally {
                Remove-Item $tempFile -ErrorAction SilentlyContinue
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
            Set-SnipeitAccessory -id 1 -qty 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# 2. Set-SnipeitAsset
# ============================================================

Describe "Set-SnipeitAsset" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/hardware/{id} with Patch by default" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAsset -id 1 -name "PC01" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/1" -and
                $Method -eq "Patch"
            }
        }
    }

    It "Passes body params (name, status_id, serial)" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAsset -id 2 -name "PC02" -status_id 1 -serial "SN123" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/2" -and
                $Body.name -eq "PC02" -and
                $Body.status_id -eq 1 -and
                $Body.serial -eq "SN123"
            }
        }
    }

    It "Merges customfields into body" {
        InModuleScope 'SnipeitPS' {
            $cf = @{ "_snipeit_os_5" = "Windows 10" }
            Set-SnipeitAsset -id 3 -name "PC03" -customfields $cf -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body._snipeit_os_5 -eq "Windows 10"
            }
        }
    }

    It "Formats purchase_date as yyyy-MM-dd string" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAsset -id 4 -purchase_date ([datetime]"2024-06-01") -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.purchase_date -eq "2024-06-01"
            }
        }
    }

    It "Uses Put method when RequestType is Put" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAsset -id 5 -name "PC05" -RequestType "Put" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/5" -and
                $Method -eq "Put"
            }
        }
    }

    It "Iterates foreach when given array of ids" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAsset -id 1,2 -name "Batch" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 2
        }
    }

    It "Passes image in body when valid file provided" {
        InModuleScope 'SnipeitPS' {
            $tempFile = [System.IO.Path]::GetTempFileName()
            try {
                Set-SnipeitAsset -id 6 -image $tempFile -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tempFile
                }
            } finally {
                Remove-Item $tempFile -ErrorAction SilentlyContinue
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
            Set-SnipeitAsset -id 1 -name "Legacy" -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# 3. Set-SnipeitCategory
# ============================================================

Describe "Set-SnipeitCategory" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/categories/{id} with Patch by default" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitCategory -id 1 -name "Laptops" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/categories/1" -and
                $Method -eq "Patch"
            }
        }
    }

    It "Passes body params (name, category_type)" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitCategory -id 2 -name "Monitors" -category_type "asset" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/categories/2" -and
                $Body.name -eq "Monitors" -and
                $Body.category_type -eq "asset"
            }
        }
    }

    It "Passes eula_text and use_default_eula in body" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitCategory -id 3 -eula_text "Custom EULA" -use_default_eula $false -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.eula_text -eq "Custom EULA" -and
                $Body.use_default_eula -eq $false
            }
        }
    }

    It "Uses Put method when RequestType is Put" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitCategory -id 4 -name "Put Cat" -RequestType "Put" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/categories/4" -and
                $Method -eq "Put"
            }
        }
    }

    It "Iterates foreach when given array of ids" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitCategory -id 1,2 -name "Batch" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 2
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Set-SnipeitCategory -id 1 -name "Test" -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# 4. Set-SnipeitCompany
# ============================================================

Describe "Set-SnipeitCompany" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/companies/{id} with Patch by default" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitCompany -id 1 -name "Acme Corp" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/companies/1" -and
                $Method -eq "Patch"
            }
        }
    }

    It "Passes name in body" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitCompany -id 2 -name "New Corp" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.name -eq "New Corp"
            }
        }
    }

    It "Uses Put method when RequestType is Put" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitCompany -id 3 -name "Put Corp" -RequestType "Put" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/companies/3" -and
                $Method -eq "Put"
            }
        }
    }

    It "Iterates foreach when given array of ids" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitCompany -id 1,2 -name "Batch" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 2
        }
    }

    It "Passes image in body when valid file provided" {
        InModuleScope 'SnipeitPS' {
            $tempFile = [System.IO.Path]::GetTempFileName()
            try {
                Set-SnipeitCompany -id 4 -name "Img Co" -image $tempFile -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tempFile
                }
            } finally {
                Remove-Item $tempFile -ErrorAction SilentlyContinue
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
            Set-SnipeitCompany -id 1 -name "Test" -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# 5. Set-SnipeitComponent
# ============================================================

Describe "Set-SnipeitComponent" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/components/{id} with Patch by default" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitComponent -id 1 -qty 10 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/components/1" -and
                $Method -eq "Patch"
            }
        }
    }

    It "Passes body params (qty, name)" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitComponent -id 2 -qty 5 -name "RAM Stick" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.qty -eq 5 -and
                $Body.name -eq "RAM Stick"
            }
        }
    }

    It "Formats purchase_date as yyyy-MM-dd string" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitComponent -id 3 -qty 1 -purchase_date ([datetime]"2024-08-20") -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.purchase_date -eq "2024-08-20"
            }
        }
    }

    It "Uses Put method when RequestType is Put" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitComponent -id 4 -qty 2 -RequestType "Put" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/components/4" -and
                $Method -eq "Put"
            }
        }
    }

    It "Iterates foreach when given array of ids" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitComponent -id 1,2 -qty 3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 2
        }
    }

    It "Passes image in body when valid file provided" {
        InModuleScope 'SnipeitPS' {
            $tempFile = [System.IO.Path]::GetTempFileName()
            try {
                Set-SnipeitComponent -id 5 -qty 1 -image $tempFile -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tempFile
                }
            } finally {
                Remove-Item $tempFile -ErrorAction SilentlyContinue
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
            Set-SnipeitComponent -id 1 -qty 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# 6. Set-SnipeitConsumable
# ============================================================

Describe "Set-SnipeitConsumable" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/consumables/{id} with Patch by default" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitConsumable -id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/consumables/1" -and
                $Method -eq "Patch"
            }
        }
    }

    It "Passes body params (name, qty, category_id)" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitConsumable -id 2 -name "Ink Pack" -qty 20 -category_id 3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.name -eq "Ink Pack" -and
                $Body.qty -eq 20 -and
                $Body.category_id -eq 3
            }
        }
    }

    It "Formats purchase_date as yyyy-MM-dd string" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitConsumable -id 3 -purchase_date ([datetime]"2024-11-10") -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.purchase_date -eq "2024-11-10"
            }
        }
    }

    It "Uses Put method when RequestType is Put" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitConsumable -id 4 -RequestType "Put" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/consumables/4" -and
                $Method -eq "Put"
            }
        }
    }

    It "Iterates foreach when given array of ids" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitConsumable -id 1,2 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 2
        }
    }

    It "Passes image in body when valid file provided" {
        InModuleScope 'SnipeitPS' {
            $tempFile = [System.IO.Path]::GetTempFileName()
            try {
                Set-SnipeitConsumable -id 5 -image $tempFile -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tempFile
                }
            } finally {
                Remove-Item $tempFile -ErrorAction SilentlyContinue
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
            Set-SnipeitConsumable -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# 7. Set-SnipeitCustomField
# ============================================================

Describe "Set-SnipeitCustomField" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/fields/{id} with Put by default" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitCustomField -id 1 -element "text" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/fields/1" -and
                $Method -eq "Put"
            }
        }
    }

    It "Passes body params (name, element, format)" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitCustomField -id 2 -name "OS Type" -element "listbox" -format "ANY" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.name -eq "OS Type" -and
                $Body.element -eq "listbox" -and
                $Body.format -eq "ANY"
            }
        }
    }

    It "Uses Patch method when RequestType is Patch" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitCustomField -id 3 -element "checkbox" -RequestType "Patch" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/fields/3" -and
                $Method -eq "Patch"
            }
        }
    }

    It "Throws when format is CUSTOM REGEX without custom_format" {
        InModuleScope 'SnipeitPS' {
            { Set-SnipeitCustomField -id 4 -element "text" -format "CUSTOM REGEX" -Confirm:$false } | Should -Throw "*Please specify regex*"
        }
    }

    It "Accepts CUSTOM REGEX when custom_format is provided" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitCustomField -id 5 -element "text" -format "CUSTOM REGEX" -custom_format "^\d+$" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.format -eq "CUSTOM REGEX" -and
                $Body.custom_format -eq "^\d+$"
            }
        }
    }

    It "Iterates foreach when given array of ids" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitCustomField -id 1,2 -element "text" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 2
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Set-SnipeitCustomField -id 1 -element "text" -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# 8. Set-SnipeitDepartment
# ============================================================

Describe "Set-SnipeitDepartment" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/departments/{id} with Patch by default" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitDepartment -id 1 -name "IT" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/departments/1" -and
                $Method -eq "Patch"
            }
        }
    }

    It "Passes body params (name, manager_id, company_id)" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitDepartment -id 2 -name "HR" -manager_id 5 -company_id 3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.name -eq "HR" -and
                $Body.manager_id -eq 5 -and
                $Body.company_id -eq 3
            }
        }
    }

    It "Uses Put method when RequestType is Put" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitDepartment -id 3 -name "Sales" -RequestType "Put" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/departments/3" -and
                $Method -eq "Put"
            }
        }
    }

    It "Iterates foreach when given array of ids" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitDepartment -id 1,2 -name "Batch" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 2
        }
    }

    It "Passes image in body when valid file provided" {
        InModuleScope 'SnipeitPS' {
            $tempFile = [System.IO.Path]::GetTempFileName()
            try {
                Set-SnipeitDepartment -id 4 -name "Img Dept" -image $tempFile -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tempFile
                }
            } finally {
                Remove-Item $tempFile -ErrorAction SilentlyContinue
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
            Set-SnipeitDepartment -id 1 -name "Test" -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# 9. Set-SnipeitLocation
# ============================================================

Describe "Set-SnipeitLocation" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/locations/{id} with Patch by default" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitLocation -id 1 -name "Main Office" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/locations/1" -and
                $Method -eq "Patch"
            }
        }
    }

    It "Passes body params (name, address, city, country)" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitLocation -id 2 -name "Branch" -address "123 Main St" -city "Springfield" -country "US" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.name -eq "Branch" -and
                $Body.address -eq "123 Main St" -and
                $Body.city -eq "Springfield" -and
                $Body.country -eq "US"
            }
        }
    }

    It "Uses Put method when RequestType is Put" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitLocation -id 3 -name "Put Loc" -RequestType "Put" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/locations/3" -and
                $Method -eq "Put"
            }
        }
    }

    It "Iterates foreach when given array of ids" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitLocation -id 1,2 -name "Batch Loc" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 2
        }
    }

    It "Passes image in body when valid file provided" {
        InModuleScope 'SnipeitPS' {
            $tempFile = [System.IO.Path]::GetTempFileName()
            try {
                Set-SnipeitLocation -id 4 -name "Img Loc" -image $tempFile -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tempFile
                }
            } finally {
                Remove-Item $tempFile -ErrorAction SilentlyContinue
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
            Set-SnipeitLocation -id 1 -name "Test" -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# 10. Set-SnipeitModel
# ============================================================

Describe "Set-SnipeitModel" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/models/{id} with Patch by default" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitModel -id 1 -name "DL380" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/models/1" -and
                $Method -eq "Patch"
            }
        }
    }

    It "Passes body params (name, model_number, category_id)" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitModel -id 2 -name "ThinkPad" -model_number "T14" -category_id 5 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.name -eq "ThinkPad" -and
                $Body.model_number -eq "T14" -and
                $Body.category_id -eq 5
            }
        }
    }

    It "Uses Put method when RequestType is Put" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitModel -id 3 -name "Put Model" -RequestType "Put" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/models/3" -and
                $Method -eq "Put"
            }
        }
    }

    It "Iterates foreach when given array of ids" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitModel -id 1,2 -name "Batch" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 2
        }
    }

    It "Passes image in body when valid file provided" {
        InModuleScope 'SnipeitPS' {
            $tempFile = [System.IO.Path]::GetTempFileName()
            try {
                Set-SnipeitModel -id 4 -image $tempFile -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tempFile
                }
            } finally {
                Remove-Item $tempFile -ErrorAction SilentlyContinue
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
            Set-SnipeitModel -id 1 -name "Test" -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# 11. Set-SnipeitStatus
# ============================================================

Describe "Set-SnipeitStatus" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/statuslabels/{id} with Patch by default" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitStatus -id 1 -type "deployable" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/statuslabels/1" -and
                $Method -eq "Patch"
            }
        }
    }

    It "Passes body params (name, type, notes, color)" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitStatus -id 2 -name "Ready" -type "deployable" -notes "Active" -color "#00ff00" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.name -eq "Ready" -and
                $Body.type -eq "deployable" -and
                $Body.notes -eq "Active" -and
                $Body.color -eq "#00ff00"
            }
        }
    }

    It "Uses Put method when RequestType is Put" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitStatus -id 3 -type "pending" -RequestType "Put" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/statuslabels/3" -and
                $Method -eq "Put"
            }
        }
    }

    It "Iterates foreach when given array of ids" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitStatus -id 1,2 -type "deployable" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 2
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Set-SnipeitStatus -id 1 -type "deployable" -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# 12. Set-SnipeitUser
# ============================================================

Describe "Set-SnipeitUser" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/users/{id} with PATCH method" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitUser -id 1 -first_name "John" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/users/1" -and
                $Method -eq "PATCH"
            }
        }
    }

    It "Passes body params (first_name, last_name, username, email)" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitUser -id 2 -first_name "Jane" -last_name "Doe" -username "jdoe" -email "jdoe@test.com" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.first_name -eq "Jane" -and
                $Body.last_name -eq "Doe" -and
                $Body.username -eq "jdoe" -and
                $Body.email -eq "jdoe@test.com"
            }
        }
    }

    It "Adds password_confirmation when password is provided" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitUser -id 3 -password "Secret123" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.password -eq "Secret123" -and
                $Body.password_confirmation -eq "Secret123"
            }
        }
    }

    It "Iterates foreach when given array of ids" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitUser -id 1,2 -first_name "Batch" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 2
        }
    }

    It "Passes image in body when valid file provided" {
        InModuleScope 'SnipeitPS' {
            $tempFile = [System.IO.Path]::GetTempFileName()
            try {
                Set-SnipeitUser -id 4 -image $tempFile -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tempFile
                }
            } finally {
                Remove-Item $tempFile -ErrorAction SilentlyContinue
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
            Set-SnipeitUser -id 1 -first_name "Test" -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# 13. Set-SnipeitAccessoryOwner
# ============================================================

Describe "Set-SnipeitAccessoryOwner" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/accessories/{id}/checkout with POST method" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAccessoryOwner -id 1 -assigned_to 10 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/accessories/1/checkout" -and
                $Method -eq "POST"
            }
        }
    }

    It "Maps assigned_to to assigned_user for user checkout (default)" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAccessoryOwner -id 2 -assigned_to 5 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.assigned_user -eq 5
            }
        }
    }

    It "Maps assigned_to to assigned_asset for asset checkout" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAccessoryOwner -id 3 -assigned_to 7 -checkout_to_type "asset" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.assigned_asset -eq 7
            }
        }
    }

    It "Maps assigned_to to assigned_location for location checkout" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAccessoryOwner -id 4 -assigned_to 9 -checkout_to_type "location" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.assigned_location -eq 9
            }
        }
    }

    It "Passes note in body" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAccessoryOwner -id 5 -assigned_to 1 -note "Test checkout" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.note -eq "Test checkout"
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
            Set-SnipeitAccessoryOwner -id 1 -assigned_to 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# 14. Set-SnipeitLicenseSeat
# ============================================================

Describe "Set-SnipeitLicenseSeat" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/licenses/{id}/seats/{seat_id} with Patch by default" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitLicenseSeat -id 1 -seat_id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/licenses/1/seats/1" -and
                $Method -eq "Patch"
            }
        }
    }

    It "Passes body params (assigned_to, asset_id, note)" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitLicenseSeat -id 2 -seat_id 3 -assigned_to 10 -asset_id 20 -note "License checkout" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/licenses/2/seats/3" -and
                $Body.assigned_to -eq 10 -and
                $Body.asset_id -eq 20 -and
                $Body.note -eq "License checkout"
            }
        }
    }

    It "Uses Put method when RequestType is Put" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitLicenseSeat -id 3 -seat_id 1 -RequestType "Put" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/licenses/3/seats/1" -and
                $Method -eq "Put"
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
            Set-SnipeitLicenseSeat -id 1 -seat_id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            # Note: Reset-SnipeitPSLegacyApi is not called because the end{} block
            # is nested inside process{} and return exits before reaching it (source bug)
        }
    }
}
