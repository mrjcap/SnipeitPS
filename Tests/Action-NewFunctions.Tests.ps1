BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

Describe "Restore-SnipeitAsset" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/hardware/{id}/restore endpoint with POST method" {
        InModuleScope 'SnipeitPS' {
            Restore-SnipeitAsset -id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/1/restore" -and
                $Method -eq "POST"
            }
        }
    }

    It "Accepts pipeline input for id" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 7 } | Restore-SnipeitAsset -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/7/restore" -and
                $Method -eq "POST"
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
            Restore-SnipeitAsset -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Restore-SnipeitUser" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/users/{id}/restore endpoint with POST method" {
        InModuleScope 'SnipeitPS' {
            Restore-SnipeitUser -id 2 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/users/2/restore" -and
                $Method -eq "POST"
            }
        }
    }

    It "Accepts pipeline input for id" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 9 } | Restore-SnipeitUser -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/users/9/restore" -and
                $Method -eq "POST"
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
            Restore-SnipeitUser -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Set-SnipeitComponentOwner" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/components/{id}/checkout endpoint with POST method" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitComponentOwner -id 3 -assigned_to 100 -assigned_qty 2 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/components/3/checkout" -and
                $Method -eq "POST"
            }
        }
    }

    It "Body contains assigned_to and assigned_qty" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitComponentOwner -id 3 -assigned_to 100 -assigned_qty 2 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.assigned_to -eq 100 -and
                $Body.assigned_qty -eq 2
            }
        }
    }

    It "Body contains note when provided" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitComponentOwner -id 3 -assigned_to 100 -assigned_qty 2 -note "Test note" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.note -eq "Test note"
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
            Set-SnipeitComponentOwner -id 1 -assigned_to 100 -assigned_qty 2 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Reset-SnipeitComponentOwner" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/components/{id}/checkin endpoint with POST method" {
        InModuleScope 'SnipeitPS' {
            Reset-SnipeitComponentOwner -id 4 -checkin_qty 3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/components/4/checkin" -and
                $Method -eq "POST"
            }
        }
    }

    It "Body contains checkin_qty" {
        InModuleScope 'SnipeitPS' {
            Reset-SnipeitComponentOwner -id 4 -checkin_qty 3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.checkin_qty -eq 3
            }
        }
    }

    It "Body contains note when provided" {
        InModuleScope 'SnipeitPS' {
            Reset-SnipeitComponentOwner -id 4 -checkin_qty 3 -note "Checkin note" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.note -eq "Checkin note"
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
            Reset-SnipeitComponentOwner -id 1 -checkin_qty 2 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Set-SnipeitConsumableOwner" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/consumables/{id}/checkout endpoint with POST method" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitConsumableOwner -id 5 -assigned_to 200 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/consumables/5/checkout" -and
                $Method -eq "POST"
            }
        }
    }

    It "Body contains assigned_to" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitConsumableOwner -id 5 -assigned_to 200 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.assigned_to -eq 200
            }
        }
    }

    It "Body contains checkout_qty when provided" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitConsumableOwner -id 5 -assigned_to 200 -checkout_qty 10 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.checkout_qty -eq 10
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
            Set-SnipeitConsumableOwner -id 1 -assigned_to 100 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Register-SnipeitCustomField" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/fields/{id}/associate endpoint with POST method" {
        InModuleScope 'SnipeitPS' {
            Register-SnipeitCustomField -id 1 -fieldset_id 5 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/fields/1/associate" -and
                $Method -eq "POST"
            }
        }
    }

    It "Body contains fieldset_id" {
        InModuleScope 'SnipeitPS' {
            Register-SnipeitCustomField -id 1 -fieldset_id 5 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.fieldset_id -eq 5
            }
        }
    }

    It "Body contains optional required and order when provided" {
        InModuleScope 'SnipeitPS' {
            Register-SnipeitCustomField -id 1 -fieldset_id 5 -required $true -order 3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.fieldset_id -eq 5 -and
                $Body.required -eq $true -and
                $Body.order -eq 3
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
            Register-SnipeitCustomField -id 1 -fieldset_id 5 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Unregister-SnipeitCustomField" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/fields/{id}/disassociate endpoint with POST method" {
        InModuleScope 'SnipeitPS' {
            Unregister-SnipeitCustomField -id 1 -fieldset_id 5 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/fields/1/disassociate" -and
                $Method -eq "POST"
            }
        }
    }

    It "Body contains fieldset_id" {
        InModuleScope 'SnipeitPS' {
            Unregister-SnipeitCustomField -id 1 -fieldset_id 5 -Confirm:$false
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
            Unregister-SnipeitCustomField -id 1 -fieldset_id 5 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Update-SnipeitAssetAudit" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/hardware/{id}/audit endpoint with POST method" {
        InModuleScope 'SnipeitPS' {
            Update-SnipeitAssetAudit -id 10 -location_id 3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/10/audit" -and
                $Method -eq "POST"
            }
        }
    }

    It "Body contains location_id when provided" {
        InModuleScope 'SnipeitPS' {
            Update-SnipeitAssetAudit -id 10 -location_id 3 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.location_id -eq 3
            }
        }
    }

    It "Formats next_audit_date as yyyy-MM-dd" {
        InModuleScope 'SnipeitPS' {
            Update-SnipeitAssetAudit -id 10 -next_audit_date ([datetime]"2025-06-15") -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/10/audit" -and
                $Body.next_audit_date -eq "2025-06-15"
            }
        }
    }

    It "Body contains both location_id and next_audit_date when both provided" {
        InModuleScope 'SnipeitPS' {
            Update-SnipeitAssetAudit -id 10 -location_id 3 -next_audit_date ([datetime]"2025-12-31") -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.location_id -eq 3 -and
                $Body.next_audit_date -eq "2025-12-31"
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
            Update-SnipeitAssetAudit -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}
