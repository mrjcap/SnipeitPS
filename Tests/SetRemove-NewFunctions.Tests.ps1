BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

# ============================================================
# SET FUNCTIONS
# ============================================================

Describe "Set-SnipeitGroup" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/groups/{id} endpoint with Patch method by default" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitGroup -id 1 -name "Updated Group" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/groups/1" -and
                $Method -eq "Patch"
            }
        }
    }

    It "Body contains name when provided" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitGroup -id 2 -name "Test Group" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/groups/2" -and
                $Body.name -eq "Test Group"
            }
        }
    }

    It "Passes permissions hashtable in body" {
        InModuleScope 'SnipeitPS' {
            $perms = @{ admin = "1" }
            Set-SnipeitGroup -id 3 -permissions $perms -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/groups/3" -and
                $Body.permissions.admin -eq "1"
            }
        }
    }

    It "Uses Put method when RequestType is Put" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitGroup -id 4 -name "Put Group" -RequestType "Put" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/groups/4" -and
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
            Set-SnipeitGroup -id 1 -name "Test" -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Set-SnipeitFieldset" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/fieldsets/{id} endpoint with Patch method by default" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitFieldset -id 1 -name "Updated Fieldset" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/fieldsets/1" -and
                $Method -eq "Patch"
            }
        }
    }

    It "Body contains name when provided" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitFieldset -id 5 -name "Custom Fieldset" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/fieldsets/5" -and
                $Body.name -eq "Custom Fieldset"
            }
        }
    }

    It "Uses Put method when RequestType is Put" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitFieldset -id 6 -name "Put Fieldset" -RequestType "Put" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/fieldsets/6" -and
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
            Set-SnipeitFieldset -id 1 -name "Test" -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Set-SnipeitAssetMaintenance" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/maintenances/{id} endpoint with Patch method by default" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAssetMaintenance -id 1 -title "Updated maintenance" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/maintenances/1" -and
                $Method -eq "Patch"
            }
        }
    }

    It "Body contains title when provided" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAssetMaintenance -id 2 -title "Disk Replacement" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/maintenances/2" -and
                $Body.title -eq "Disk Replacement"
            }
        }
    }

    It "Formats start_date as yyyy-MM-dd string" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAssetMaintenance -id 3 -start_date ([datetime]"2024-06-15") -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/maintenances/3" -and
                $Body.start_date -eq "2024-06-15"
            }
        }
    }

    It "Formats completion_date as yyyy-MM-dd string" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAssetMaintenance -id 4 -completion_date ([datetime]"2024-07-20") -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/maintenances/4" -and
                $Body.completion_date -eq "2024-07-20"
            }
        }
    }

    It "Uses Put method when RequestType is Put" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAssetMaintenance -id 5 -title "Put Maintenance" -RequestType "Put" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/maintenances/5" -and
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
            Set-SnipeitAssetMaintenance -id 1 -title "Test" -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# ============================================================
# REMOVE FUNCTIONS
# ============================================================

Describe "Remove-SnipeitStatus" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/statuslabels/{id} endpoint with Delete method" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitStatus -id 5 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/statuslabels/5" -and
                $Method -eq "Delete"
            }
        }
    }

    It "Works with a different id value" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitStatus -id 42 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/statuslabels/42" -and
                $Method -eq "Delete"
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
            Remove-SnipeitStatus -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Remove-SnipeitGroup" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/groups/{id} endpoint with Delete method" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitGroup -id 10 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/groups/10" -and
                $Method -eq "Delete"
            }
        }
    }

    It "Works with a different id value" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitGroup -id 99 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/groups/99" -and
                $Method -eq "Delete"
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
            Remove-SnipeitGroup -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Remove-SnipeitFieldset" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/fieldsets/{id} endpoint with Delete method" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitFieldset -id 8 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/fieldsets/8" -and
                $Method -eq "Delete"
            }
        }
    }

    It "Works with a different id value" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitFieldset -id 15 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/fieldsets/15" -and
                $Method -eq "Delete"
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
            Remove-SnipeitFieldset -id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Remove-SnipeitAssetFile" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/hardware/{id}/files/{file_id}/delete endpoint with Delete method" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitAssetFile -id 3 -file_id 7 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/3/files/7/delete" -and
                $Method -eq "Delete"
            }
        }
    }

    It "Works with different id and file_id values" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitAssetFile -id 20 -file_id 55 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/20/files/55/delete" -and
                $Method -eq "Delete"
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
            Remove-SnipeitAssetFile -id 1 -file_id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Remove-SnipeitModelFile" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/models/{id}/files/{file_id}/delete endpoint with Delete method" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitModelFile -id 4 -file_id 12 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/models/4/files/12/delete" -and
                $Method -eq "Delete"
            }
        }
    }

    It "Works with different id and file_id values" {
        InModuleScope 'SnipeitPS' {
            Remove-SnipeitModelFile -id 30 -file_id 88 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/models/30/files/88/delete" -and
                $Method -eq "Delete"
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
            Remove-SnipeitModelFile -id 1 -file_id 1 -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}
