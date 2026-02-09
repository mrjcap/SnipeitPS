BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

# ============================================================
# Bug Fix #1: New-SnipeitSupplier endpoint typo
# ============================================================

Describe "New-SnipeitSupplier" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/suppliers endpoint (not /suppilers)" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitSupplier -name "Test Supplier" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/suppliers" -and
                $Method -eq "POST"
            }
        }
    }

    It "Passes name in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitSupplier -name "Acme Corp" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.name -eq "Acme Corp"
            }
        }
    }

    It "Passes optional parameters in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitSupplier -name "Test" -address "123 Main St" -city "Springfield" -phone "555-1234" -email "test@example.com" -contact "John Doe" -notes "Test notes" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.address -eq "123 Main St" -and
                $Body.city -eq "Springfield" -and
                $Body.phone -eq "555-1234" -and
                $Body.email -eq "test@example.com" -and
                $Body.contact -eq "John Doe" -and
                $Body.notes -eq "Test notes"
            }
        }
    }

    It "Passes image path in body when valid file provided" {
        InModuleScope 'SnipeitPS' {
            $tempFile = [System.IO.Path]::GetTempFileName()
            try {
                New-SnipeitSupplier -name "Image Test" -image $tempFile -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tempFile
                }
            } finally {
                Remove-Item $tempFile -ErrorAction SilentlyContinue
            }
        }
    }

    It "Renames supplier_url to url in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitSupplier -name "Test" -supplier_url "https://example.com" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.url -eq "https://example.com" -and
                -not $Body.ContainsKey('supplier_url')
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
            New-SnipeitSupplier -name "Test" -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Bug Fix #2: Set-SnipeitSupplier missing $id parameter
# ============================================================

Describe "Set-SnipeitSupplier" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/suppliers/{id} endpoint with Patch method by default" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitSupplier -id 1 -name "Updated Supplier" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/suppliers/1" -and
                $Method -eq "Patch"
            }
        }
    }

    It "Passes name in body" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitSupplier -id 2 -name "New Name" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/suppliers/2" -and
                $Body.name -eq "New Name"
            }
        }
    }

    It "Uses Put method when RequestType is Put" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitSupplier -id 3 -name "Put Supplier" -RequestType "Put" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/suppliers/3" -and
                $Method -eq "Put"
            }
        }
    }

    It "Passes image path in body when valid file provided" {
        InModuleScope 'SnipeitPS' {
            $tempFile = [System.IO.Path]::GetTempFileName()
            try {
                Set-SnipeitSupplier -id 1 -image $tempFile -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tempFile
                }
            } finally {
                Remove-Item $tempFile -ErrorAction SilentlyContinue
            }
        }
    }

    It "Renames supplier_url to url in body" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitSupplier -id 1 -name "Test" -supplier_url "https://example.com" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.url -eq "https://example.com" -and
                -not $Body.ContainsKey('supplier_url')
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
            Set-SnipeitSupplier -id 1 -name "Test" -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Bug Fix #3: Set-SnipeitManufacturer missing $id parameter
# ============================================================

Describe "Set-SnipeitManufacturer" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/manufacturers/{id} endpoint with Patch method by default" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitManufacturer -id 1 -name "Updated Manufacturer" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/manufacturers/1" -and
                $Method -eq "Patch"
            }
        }
    }

    It "Passes name in body" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitManufacturer -id 5 -name "HP Inc." -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/manufacturers/5" -and
                $Body.name -eq "HP Inc."
            }
        }
    }

    It "Uses Put method when RequestType is Put" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitManufacturer -id 3 -name "Put Manufacturer" -RequestType "Put" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/manufacturers/3" -and
                $Method -eq "Put"
            }
        }
    }

    It "Passes image path in body when valid file provided" {
        InModuleScope 'SnipeitPS' {
            $tempFile = [System.IO.Path]::GetTempFileName()
            try {
                Set-SnipeitManufacturer -id 1 -image $tempFile -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tempFile
                }
            } finally {
                Remove-Item $tempFile -ErrorAction SilentlyContinue
            }
        }
    }

    It "Renames manufacturer_url to url in body" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitManufacturer -id 1 -name "Test" -manufacturer_url "https://hp.com" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.url -eq "https://hp.com" -and
                -not $Body.ContainsKey('manufacturer_url')
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
            Set-SnipeitManufacturer -id 1 -name "Test" -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Bug Fix #4: New-SnipeitLicense license_email type
# ============================================================

Describe "New-SnipeitLicense" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/licenses endpoint with POST method" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitLicense -name "Test License" -seats 5 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/licenses" -and
                $Method -eq "POST" -and
                $Body.name -eq "Test License" -and
                $Body.seats -eq 5
            }
        }
    }

    It "Accepts license_email as string without crashing" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitLicense -name "Email Test" -seats 1 -license_email "test@example.com" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.license_email -eq "test@example.com"
            }
        }
    }

    It "Formats date parameters as yyyy-MM-dd" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitLicense -name "Date Test" -seats 1 -expiration_date ([datetime]"2025-12-31") -purchase_date ([datetime]"2025-01-01") -termination_date ([datetime]"2026-06-30") -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.expiration_date -eq "2025-12-31" -and
                $Body.purchase_date -eq "2025-01-01" -and
                $Body.termination_date -eq "2026-06-30"
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
            New-SnipeitLicense -name "Test" -seats 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Bug Fix #5: Set-SnipeitLicense license_email type
# ============================================================

Describe "Set-SnipeitLicense" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/licenses/{id} endpoint with Patch method by default" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitLicense -id 1 -name "Updated License" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/licenses/1" -and
                $Method -eq "Patch"
            }
        }
    }

    It "Accepts license_email as string without crashing" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitLicense -id 1 -license_email "updated@example.com" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.license_email -eq "updated@example.com"
            }
        }
    }

    It "Formats date parameters as yyyy-MM-dd" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitLicense -id 1 -expiration_date ([datetime]"2025-12-31") -purchase_date ([datetime]"2025-01-01") -termination_date ([datetime]"2026-06-30") -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.expiration_date -eq "2025-12-31" -and
                $Body.purchase_date -eq "2025-01-01" -and
                $Body.termination_date -eq "2026-06-30"
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
            Set-SnipeitLicense -id 1 -name "Test" -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Bug Fix #6: New-SnipeitManufacturer uses Get-ParameterValue
# ============================================================

Describe "New-SnipeitManufacturer" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/manufacturers endpoint with POST method" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitManufacturer -name "HP" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/manufacturers" -and
                $Method -eq "POST" -and
                $Body.name -eq "HP"
            }
        }
    }

    It "Passes image path in body when valid file provided (bug fix #6)" {
        InModuleScope 'SnipeitPS' {
            $tempFile = [System.IO.Path]::GetTempFileName()
            try {
                New-SnipeitManufacturer -name "HP" -image $tempFile -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tempFile -and
                    $Body.name -eq "HP"
                }
            } finally {
                Remove-Item $tempFile -ErrorAction SilentlyContinue
            }
        }
    }

    It "Renames manufacturer_url to url in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitManufacturer -name "Test" -manufacturer_url "https://hp.com" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.url -eq "https://hp.com" -and
                -not $Body.ContainsKey('manufacturer_url')
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
            New-SnipeitManufacturer -name "Test" -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# Bug Fix #7: Set-SnipeitAssetOwner missing status_id
# ============================================================

Describe "Set-SnipeitAssetOwner" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/hardware/{id}/checkout endpoint with POST method" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAssetOwner -id 1 -assigned_id 10 -checkout_to_type user -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/1/checkout" -and
                $Method -eq "POST"
            }
        }
    }

    It "Maps assigned_id to assigned_user for user checkout" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAssetOwner -id 1 -assigned_id 10 -checkout_to_type user -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.assigned_user -eq 10
            }
        }
    }

    It "Maps assigned_id to assigned_location for location checkout" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAssetOwner -id 1 -assigned_id 5 -checkout_to_type location -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.assigned_location -eq 5
            }
        }
    }

    It "Maps assigned_id to assigned_asset for asset checkout" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAssetOwner -id 1 -assigned_id 3 -checkout_to_type asset -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.assigned_asset -eq 3
            }
        }
    }

    It "Passes status_id in body when provided" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAssetOwner -id 1 -assigned_id 10 -checkout_to_type user -status_id 2 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.status_id -eq 2
            }
        }
    }

    It "Formats expected_checkin and checkout_at dates as yyyy-MM-dd" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAssetOwner -id 1 -assigned_id 10 -checkout_to_type user -expected_checkin ([datetime]"2025-12-31") -checkout_at ([datetime]"2025-01-15") -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.expected_checkin -eq "2025-12-31" -and
                $Body.checkout_at -eq "2025-01-15"
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
            Set-SnipeitAssetOwner -id 1 -assigned_id 10 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}
