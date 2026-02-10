BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

#region New-SnipeitAccessory
Describe "New-SnipeitAccessory" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/accessories endpoint with POST method and mandatory params" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitAccessory -name "TestAccessory" -qty 5 -category_id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/accessories" -and
                $Method -eq "POST" -and
                $Body.name -eq "TestAccessory" -and
                $Body.qty -eq 5 -and
                $Body.category_id -eq 1
            }
        }
    }

    It "Passes optional parameters in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitAccessory -name "TestAccessory" -qty 5 -category_id 1 `
                -company_id 2 -manufacturer_id 3 -model_number "MN100" `
                -order_number "ORD001" -purchase_cost 99.99 -supplier_id 4 `
                -location_id 5 -min_amt 2 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.company_id -eq 2 -and
                $Body.manufacturer_id -eq 3 -and
                $Body.model_number -eq "MN100" -and
                $Body.order_number -eq "ORD001" -and
                $Body.purchase_cost -eq [float]99.99 -and
                $Body.supplier_id -eq 4 -and
                $Body.location_id -eq 5 -and
                $Body.min_amt -eq 2
            }
        }
    }

    It "Formats purchase_date as yyyy-MM-dd string" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitAccessory -name "TestAccessory" -qty 5 -category_id 1 `
                -purchase_date ([datetime]"2025-06-15") -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.purchase_date -eq "2025-06-15"
            }
        }
    }

    It "Passes image parameter when a valid file is provided" {
        InModuleScope 'SnipeitPS' {
            $tf = [System.IO.Path]::GetTempFileName()
            try {
                New-SnipeitAccessory -name "TestAccessory" -qty 5 -category_id 1 `
                    -image $tf -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tf
                }
            } finally {
                Remove-Item $tf -Force -ErrorAction SilentlyContinue
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
            New-SnipeitAccessory -name "TestAccessory" -qty 5 -category_id 1 `
                -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}
#endregion

#region New-SnipeitAsset
Describe "New-SnipeitAsset" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/hardware endpoint with POST method and mandatory params" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitAsset -status_id 1 -model_id 2 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware" -and
                $Method -eq "Post" -and
                $Body.status_id -eq 1 -and
                $Body.model_id -eq 2
            }
        }
    }

    It "Passes optional body parameters" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitAsset -status_id 1 -model_id 2 -name "Machine1" `
                -asset_tag "DEV123" -serial "SN001" -company_id 3 `
                -order_number "ORD001" -notes "test notes" `
                -warranty_months 24 -purchase_cost "500" `
                -supplier_id 4 -rtd_location_id 5 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.name -eq "Machine1" -and
                $Body.asset_tag -eq "DEV123" -and
                $Body.serial -eq "SN001" -and
                $Body.company_id -eq 3 -and
                $Body.order_number -eq "ORD001" -and
                $Body.notes -eq "test notes" -and
                $Body.warranty_months -eq 24 -and
                $Body.purchase_cost -eq "500" -and
                $Body.supplier_id -eq 4 -and
                $Body.rtd_location_id -eq 5
            }
        }
    }

    It "Formats purchase_date as yyyy-MM-dd string" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitAsset -status_id 1 -model_id 2 `
                -purchase_date ([datetime]"2025-06-15") -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.purchase_date -eq "2025-06-15"
            }
        }
    }

    It "Maps checkout_to_type 'user' to assigned_user" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitAsset -status_id 1 -model_id 2 `
                -assigned_id 10 -checkout_to_type "user" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.assigned_user -eq 10 -and
                -not $Body.ContainsKey('assigned_id') -and
                -not $Body.ContainsKey('checkout_to_type')
            }
        }
    }

    It "Maps checkout_to_type 'location' to assigned_location" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitAsset -status_id 1 -model_id 2 `
                -assigned_id 20 -checkout_to_type "location" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.assigned_location -eq 20 -and
                -not $Body.ContainsKey('assigned_id') -and
                -not $Body.ContainsKey('checkout_to_type')
            }
        }
    }

    It "Maps checkout_to_type 'asset' to assigned_asset" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitAsset -status_id 1 -model_id 2 `
                -assigned_id 30 -checkout_to_type "asset" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.assigned_asset -eq 30 -and
                -not $Body.ContainsKey('assigned_id') -and
                -not $Body.ContainsKey('checkout_to_type')
            }
        }
    }

    It "Merges customfields hashtable into body" {
        InModuleScope 'SnipeitPS' {
            $cf = @{ "_snipeit_os_5" = "Windows 10 Pro" }
            New-SnipeitAsset -status_id 1 -model_id 2 -customfields $cf -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.'_snipeit_os_5' -eq "Windows 10 Pro"
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
            New-SnipeitAsset -status_id 1 -model_id 2 `
                -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}
#endregion

#region New-SnipeitAssetMaintenance
Describe "New-SnipeitAssetMaintenance" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/maintenances endpoint with POST method and mandatory params" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitAssetMaintenance -asset_id 1 -supplier_id 2 `
                -asset_maintenance_type "Maintenance" -title "Replace KB" `
                -start_date ([datetime]"2025-01-01") -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/maintenances" -and
                $Method -eq "Post" -and
                $Body.asset_id -eq 1 -and
                $Body.supplier_id -eq 2 -and
                $Body.asset_maintenance_type -eq "Maintenance" -and
                $Body.title -eq "Replace KB"
            }
        }
    }

    It "Formats start_date as yyyy-MM-dd string" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitAssetMaintenance -asset_id 1 -supplier_id 2 `
                -asset_maintenance_type "Maintenance" -title "Test" `
                -start_date ([datetime]"2025-06-15") -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.start_date -eq "2025-06-15"
            }
        }
    }

    It "Formats completion_date as yyyy-MM-dd string" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitAssetMaintenance -asset_id 1 -supplier_id 2 `
                -asset_maintenance_type "Maintenance" -title "Test" `
                -start_date ([datetime]"2025-06-15") `
                -completion_date ([datetime]"2025-07-20") -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.completion_date -eq "2025-07-20"
            }
        }
    }

    It "Passes optional parameters in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitAssetMaintenance -asset_id 1 -supplier_id 2 `
                -asset_maintenance_type "Maintenance" -title "Test" `
                -start_date ([datetime]"2025-01-01") `
                -is_warranty $true -cost 150.50 -notes "test notes" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.is_warranty -eq $true -and
                $Body.cost -eq 150.50 -and
                $Body.notes -eq "test notes"
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
            New-SnipeitAssetMaintenance -asset_id 1 -supplier_id 2 `
                -asset_maintenance_type "Maintenance" -title "Test" `
                -start_date ([datetime]"2025-01-01") `
                -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}
#endregion

#region New-SnipeitCategory
Describe "New-SnipeitCategory" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/categories endpoint with POST method and mandatory params" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitCategory -name "Laptops" -category_type "asset" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/categories" -and
                $Method -eq "POST" -and
                $Body.name -eq "Laptops" -and
                $Body.category_type -eq "asset"
            }
        }
    }

    It "Passes optional switch parameters in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitCategory -name "Laptops" -category_type "asset" `
                -use_default_eula -require_acceptance -checkin_email -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.use_default_eula -eq $true -and
                $Body.require_acceptance -eq $true -and
                $Body.checkin_email -eq $true
            }
        }
    }

    It "Passes eula_text in body when provided" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitCategory -name "Laptops" -category_type "asset" `
                -eula_text "Custom EULA text" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.eula_text -eq "Custom EULA text"
            }
        }
    }

    It "Throws when both eula_text and use_default_eula are set" {
        InModuleScope 'SnipeitPS' {
            { New-SnipeitCategory -name "Laptops" -category_type "asset" `
                -eula_text "Custom" -use_default_eula -Confirm:$false } |
                Should -Throw "*Dont use -use_defalt_eula*"
        }
    }

    It "Passes image parameter when a valid file is provided" {
        InModuleScope 'SnipeitPS' {
            $tf = [System.IO.Path]::GetTempFileName()
            try {
                New-SnipeitCategory -name "Laptops" -category_type "asset" `
                    -image $tf -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tf
                }
            } finally {
                Remove-Item $tf -Force -ErrorAction SilentlyContinue
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
            New-SnipeitCategory -name "Laptops" -category_type "asset" `
                -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}
#endregion

#region New-SnipeitCompany
Describe "New-SnipeitCompany" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/companies endpoint with POST method and name in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitCompany -name "Acme Company" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/companies" -and
                $Method -eq "POST" -and
                $Body.name -eq "Acme Company"
            }
        }
    }

    It "Passes image parameter when a valid file is provided" {
        InModuleScope 'SnipeitPS' {
            $tf = [System.IO.Path]::GetTempFileName()
            try {
                New-SnipeitCompany -name "Acme" -image $tf -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tf
                }
            } finally {
                Remove-Item $tf -Force -ErrorAction SilentlyContinue
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
            New-SnipeitCompany -name "Acme" `
                -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}
#endregion

#region New-SnipeitComponent
Describe "New-SnipeitComponent" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/components endpoint with POST method and mandatory params" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitComponent -name "Display adapter" -qty 10 -category_id 3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/components" -and
                $Method -eq "POST" -and
                $Body.name -eq "Display adapter" -and
                $Body.qty -eq 10 -and
                $Body.category_id -eq 3
            }
        }
    }

    It "Passes optional parameters in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitComponent -name "Display adapter" -qty 10 -category_id 3 `
                -company_id 1 -location_id 2 -order_number "ORD002" `
                -purchase_cost 45.50 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.company_id -eq 1 -and
                $Body.location_id -eq 2 -and
                $Body.order_number -eq "ORD002" -and
                $Body.purchase_cost -eq [float]45.50
            }
        }
    }

    It "Formats purchase_date as yyyy-MM-dd string" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitComponent -name "Display adapter" -qty 10 -category_id 3 `
                -purchase_date ([datetime]"2025-06-15") -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.purchase_date -eq "2025-06-15"
            }
        }
    }

    It "Passes image parameter when a valid file is provided" {
        InModuleScope 'SnipeitPS' {
            $tf = [System.IO.Path]::GetTempFileName()
            try {
                New-SnipeitComponent -name "Display adapter" -qty 10 -category_id 3 `
                    -image $tf -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tf
                }
            } finally {
                Remove-Item $tf -Force -ErrorAction SilentlyContinue
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
            New-SnipeitComponent -name "Display adapter" -qty 10 -category_id 3 `
                -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}
#endregion

#region New-SnipeitConsumable
Describe "New-SnipeitConsumable" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/consumables endpoint with POST method and mandatory params" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitConsumable -name "Ink pack" -qty 20 -category_id 3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/consumables" -and
                $Method -eq "Post" -and
                $Body.name -eq "Ink pack" -and
                $Body.qty -eq 20 -and
                $Body.category_id -eq 3
            }
        }
    }

    It "Passes optional parameters in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitConsumable -name "Ink pack" -qty 20 -category_id 3 `
                -min_amt 5 -company_id 1 -order_number "ORD003" `
                -manufacturer_id 2 -location_id 4 -requestable $true `
                -purchase_cost "10.50" -model_number "INK100" `
                -item_no "ITM001" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.min_amt -eq 5 -and
                $Body.company_id -eq 1 -and
                $Body.order_number -eq "ORD003" -and
                $Body.manufacturer_id -eq 2 -and
                $Body.location_id -eq 4 -and
                $Body.requestable -eq $true -and
                $Body.purchase_cost -eq "10.50" -and
                $Body.model_number -eq "INK100" -and
                $Body.item_no -eq "ITM001"
            }
        }
    }

    It "Formats purchase_date as yyyy-MM-dd string" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitConsumable -name "Ink pack" -qty 20 -category_id 3 `
                -purchase_date ([datetime]"2025-06-15") -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.purchase_date -eq "2025-06-15"
            }
        }
    }

    It "Passes image parameter when a valid file is provided" {
        InModuleScope 'SnipeitPS' {
            $tf = [System.IO.Path]::GetTempFileName()
            try {
                New-SnipeitConsumable -name "Ink pack" -qty 20 -category_id 3 `
                    -image $tf -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tf
                }
            } finally {
                Remove-Item $tf -Force -ErrorAction SilentlyContinue
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
            New-SnipeitConsumable -name "Ink pack" -qty 20 -category_id 3 `
                -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}
#endregion

#region New-SnipeitCustomField
Describe "New-SnipeitCustomField" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/fields endpoint with POST method and mandatory params" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitCustomField -name "AntivirusInstalled" -element "text" `
                -format "BOOLEAN" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/fields" -and
                $Method -eq "post" -and
                $Body.name -eq "AntivirusInstalled" -and
                $Body.element -eq "text" -and
                $Body.format -eq "BOOLEAN"
            }
        }
    }

    It "Passes optional parameters in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitCustomField -name "OS" -element "listbox" -format "ANY" `
                -field_values "Windows,Linux,Mac" -field_encrypted $true `
                -show_in_email $true -help_text "Select the OS" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.field_values -eq "Windows,Linux,Mac" -and
                $Body.field_encrypted -eq $true -and
                $Body.show_in_email -eq $true -and
                $Body.help_text -eq "Select the OS"
            }
        }
    }

    It "Passes custom_format when format is CUSTOM REGEX" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitCustomField -name "SerialNum" -element "text" `
                -format "CUSTOM REGEX" -custom_format "^[A-Z]{3}\d{4}$" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.custom_format -eq "^[A-Z]{3}\d{4}$" -and
                $Body.format -eq "CUSTOM REGEX"
            }
        }
    }

    It "Throws when format is CUSTOM REGEX without custom_format" {
        InModuleScope 'SnipeitPS' {
            { New-SnipeitCustomField -name "Bad" -element "text" `
                -format "CUSTOM REGEX" -Confirm:$false } |
                Should -Throw "*specify regex validation*"
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            New-SnipeitCustomField -name "Test" -element "text" -format "ANY" `
                -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}
#endregion

#region New-SnipeitDepartment
Describe "New-SnipeitDepartment" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/departments endpoint with POST method and name in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitDepartment -name "Department1" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/departments" -and
                $Method -eq "POST" -and
                $Body.name -eq "Department1"
            }
        }
    }

    It "Passes optional parameters in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitDepartment -name "Department1" -company_id 1 `
                -location_id 2 -manager_id 3 -notes "test notes" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.company_id -eq 1 -and
                $Body.location_id -eq 2 -and
                $Body.manager_id -eq 3 -and
                $Body.notes -eq "test notes"
            }
        }
    }

    It "Passes image parameter when a valid file is provided" {
        InModuleScope 'SnipeitPS' {
            $tf = [System.IO.Path]::GetTempFileName()
            try {
                New-SnipeitDepartment -name "Department1" -image $tf -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tf
                }
            } finally {
                Remove-Item $tf -Force -ErrorAction SilentlyContinue
            }
        }
    }

    It "Passes image_delete switch when provided" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitDepartment -name "Department1" -image_delete -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.image_delete -eq $true
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
            New-SnipeitDepartment -name "Department1" `
                -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}
#endregion

#region New-SnipeitLocation
Describe "New-SnipeitLocation" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/locations endpoint with POST method and name in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitLocation -name "Room 1" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/locations" -and
                $Method -eq "post" -and
                $Body.name -eq "Room 1"
            }
        }
    }

    It "Passes optional parameters in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitLocation -name "Room 1" -address "123 Asset St" `
                -address2 "Suite 200" -city "Testville" -state "TX" `
                -country "US" -zip "12345" -currency "USD" `
                -parent_id 14 -manager_id 5 -ldap_ou "OU=Test" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.address -eq "123 Asset St" -and
                $Body.address2 -eq "Suite 200" -and
                $Body.city -eq "Testville" -and
                $Body.state -eq "TX" -and
                $Body.country -eq "US" -and
                $Body.zip -eq "12345" -and
                $Body.currency -eq "USD" -and
                $Body.parent_id -eq 14 -and
                $Body.manager_id -eq 5 -and
                $Body.ldap_ou -eq "OU=Test"
            }
        }
    }

    It "Passes image parameter when a valid file is provided" {
        InModuleScope 'SnipeitPS' {
            $tf = [System.IO.Path]::GetTempFileName()
            try {
                New-SnipeitLocation -name "Room 1" -image $tf -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tf
                }
            } finally {
                Remove-Item $tf -Force -ErrorAction SilentlyContinue
            }
        }
    }

    It "Passes image_delete switch when provided" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitLocation -name "Room 1" -image_delete -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.image_delete -eq $true
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
            New-SnipeitLocation -name "Room 1" `
                -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}
#endregion

#region New-SnipeitModel
Describe "New-SnipeitModel" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/models endpoint with POST method and mandatory params" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitModel -name "DL380" -category_id 1 -manufacturer_id 2 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/models" -and
                $Method -eq "post" -and
                $Body.name -eq "DL380" -and
                $Body.category_id -eq 1 -and
                $Body.manufacturer_id -eq 2
            }
        }
    }

    It "Passes optional model_number and eol in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitModel -name "DL380" -category_id 1 -manufacturer_id 2 `
                -model_number "DL380G10" -eol 60 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.model_number -eq "DL380G10" -and
                $Body.eol -eq 60
            }
        }
    }

    It "Passes fieldset_id when provided" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitModel -name "DL380" -category_id 1 -manufacturer_id 2 `
                -fieldset_id 5 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.fieldset_id -eq 5
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
            New-SnipeitModel -name "DL380" -category_id 1 -manufacturer_id 2 `
                -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}
#endregion

#region New-SnipeitUser
Describe "New-SnipeitUser" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/users endpoint with POST method and mandatory params" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitUser -first_name "It" -last_name "Snipe" `
                -username "snipeit" -activated $false -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/users" -and
                $Method -eq "post" -and
                $Body.first_name -eq "It" -and
                $Body.last_name -eq "Snipe" -and
                $Body.username -eq "snipeit"
            }
        }
    }

    It "Passes optional parameters in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitUser -first_name "It" -last_name "Snipe" `
                -username "snipeit" -activated $true `
                -notes "test notes" -jobtitle "Admin" `
                -email "test@test.com" -phone "555-0100" `
                -company_id 1 -location_id 2 -department_id 3 `
                -manager_id 4 -groups @(1,2) -employee_num "EMP001" `
                -ldap_import $true -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.notes -eq "test notes" -and
                $Body.jobtitle -eq "Admin" -and
                $Body.email -eq "test@test.com" -and
                $Body.phone -eq "555-0100" -and
                $Body.company_id -eq 1 -and
                $Body.location_id -eq 2 -and
                $Body.department_id -eq 3 -and
                $Body.manager_id -eq 4 -and
                $Body.employee_num -eq "EMP001" -and
                $Body.ldap_import -eq $true
            }
        }
    }

    It "Sets password_confirmation when password is provided" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitUser -first_name "It" -last_name "Snipe" `
                -username "snipeit" -activated $false `
                -password "SecureP@ss1" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.password -eq "SecureP@ss1" -and
                $Body.password_confirmation -eq "SecureP@ss1"
            }
        }
    }

    It "Passes image parameter when a valid file is provided" {
        InModuleScope 'SnipeitPS' {
            $tf = [System.IO.Path]::GetTempFileName()
            try {
                New-SnipeitUser -first_name "It" -last_name "Snipe" `
                    -username "snipeit" -activated $false `
                    -image $tf -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tf
                }
            } finally {
                Remove-Item $tf -Force -ErrorAction SilentlyContinue
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
            New-SnipeitUser -first_name "It" -last_name "Snipe" `
                -username "snipeit" -activated $false `
                -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}
#endregion

#region New-SnipeitAudit
Describe "New-SnipeitAudit" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/hardware/audit endpoint with POST method and tag in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitAudit -tag "ASSET001" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/audit" -and
                $Method -eq "Post" -and
                $Body.asset_tag -eq "ASSET001"
            }
        }
    }

    It "Passes location_id in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitAudit -tag "ASSET001" -location_id 5 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.location_id -eq 5
            }
        }
    }

    It "Formats next_audit_date as yyyy-MM-dd string" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitAudit -tag "ASSET001" `
                -next_audit_date ([datetime]"2025-06-15") -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.next_audit_date -eq "2025-06-15"
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
            New-SnipeitAudit -tag "ASSET001" `
                -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}
#endregion
