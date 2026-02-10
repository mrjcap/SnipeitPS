BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

# Group A: Paginated GET with $id

Describe "Get-SnipeitAssetLicense" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/hardware/{id}/licenses endpoint with id interpolated" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAssetLicense -id 5
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/5/licenses" -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes GetParameters for pagination" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAssetLicense -id 5 -limit 10 -offset 20
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/5/licenses" -and
                $Method -eq "Get" -and
                $GetParameters.limit -eq 10 -and
                $GetParameters.offset -eq 20
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitAssetLicense -id 5 -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }

    It "Handles -all pagination parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "License1" }
            )}
            $result = Get-SnipeitAssetLicense -id 1 -all
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1
        }
    }
}

Describe "Get-SnipeitComponentAsset" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/components/{id}/assets endpoint with id interpolated" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitComponentAsset -id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/components/3/assets" -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes GetParameters for pagination" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitComponentAsset -id 3 -limit 10 -offset 20
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/components/3/assets" -and
                $Method -eq "Get" -and
                $GetParameters.limit -eq 10 -and
                $GetParameters.offset -eq 20
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitComponentAsset -id 3 -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }

    It "Handles -all pagination parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "Asset1" }
            )}
            $result = Get-SnipeitComponentAsset -id 1 -all
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1
        }
    }
}

Describe "Get-SnipeitUserAsset" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/users/{id}/assets endpoint with id interpolated" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitUserAsset -id 7
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/users/7/assets" -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes GetParameters for pagination" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitUserAsset -id 7 -limit 10 -offset 20
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/users/7/assets" -and
                $Method -eq "Get" -and
                $GetParameters.limit -eq 10 -and
                $GetParameters.offset -eq 20
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitUserAsset -id 7 -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }

    It "Handles -all pagination parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "Asset1" }
            )}
            $result = Get-SnipeitUserAsset -id 1 -all
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1
        }
    }
}

Describe "Get-SnipeitUserAccessory" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/users/{id}/accessories endpoint with id interpolated" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitUserAccessory -id 7
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/users/7/accessories" -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes GetParameters for pagination" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitUserAccessory -id 7 -limit 10 -offset 20
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/users/7/accessories" -and
                $Method -eq "Get" -and
                $GetParameters.limit -eq 10 -and
                $GetParameters.offset -eq 20
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitUserAccessory -id 7 -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }

    It "Handles -all pagination parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "Accessory1" }
            )}
            $result = Get-SnipeitUserAccessory -id 1 -all
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1
        }
    }
}

Describe "Get-SnipeitUserLicense" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/users/{id}/licenses endpoint with id interpolated" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitUserLicense -id 7
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/users/7/licenses" -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes GetParameters for pagination" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitUserLicense -id 7 -limit 10 -offset 20
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/users/7/licenses" -and
                $Method -eq "Get" -and
                $GetParameters.limit -eq 10 -and
                $GetParameters.offset -eq 20
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitUserLicense -id 7 -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }

    It "Handles -all pagination parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "License1" }
            )}
            $result = Get-SnipeitUserLicense -id 1 -all
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1
        }
    }
}

Describe "Get-SnipeitConsumableUser" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/consumables/{id}/users endpoint with id interpolated" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitConsumableUser -id 4
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/consumables/4/users" -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes GetParameters for pagination" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitConsumableUser -id 4 -limit 10 -offset 20
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/consumables/4/users" -and
                $Method -eq "Get" -and
                $GetParameters.limit -eq 10 -and
                $GetParameters.offset -eq 20
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitConsumableUser -id 4 -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }

    It "Handles -all pagination parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "User1" }
            )}
            $result = Get-SnipeitConsumableUser -id 1 -all
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1
        }
    }
}

# Group B: Paginated GET without $id

Describe "Get-SnipeitAuditDue" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/hardware/audit/due endpoint with GET method" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAuditDue
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/audit/due" -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes GetParameters for pagination" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAuditDue -limit 10 -offset 20
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/audit/due" -and
                $Method -eq "Get" -and
                $GetParameters.limit -eq 10 -and
                $GetParameters.offset -eq 20
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitAuditDue -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }

    It "Handles -all pagination parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "Asset1" }
            )}
            $result = Get-SnipeitAuditDue -all
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1
        }
    }
}

Describe "Get-SnipeitAuditOverdue" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/hardware/audit/overdue endpoint with GET method" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAuditOverdue
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/audit/overdue" -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes GetParameters for pagination" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAuditOverdue -limit 10 -offset 20
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/audit/overdue" -and
                $Method -eq "Get" -and
                $GetParameters.limit -eq 10 -and
                $GetParameters.offset -eq 20
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitAuditOverdue -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }

    It "Handles -all pagination parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "Asset1" }
            )}
            $result = Get-SnipeitAuditOverdue -all
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1
        }
    }
}

# Group C: Simple GET

Describe "Get-SnipeitBackup" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/settings/backups endpoint with GET method" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitBackup
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/settings/backups" -and
                $Method -eq "Get"
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitBackup -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

# Group D: File download

Describe "Save-SnipeitBackup" {
    It "Has SupportsShouldProcess attribute" {
        (Get-Command Save-SnipeitBackup).Parameters.Keys | Should -Contain 'WhatIf'
        (Get-Command Save-SnipeitBackup).Parameters.Keys | Should -Contain 'Confirm'
    }

    It "Has mandatory filename parameter" {
        $param = (Get-Command Save-SnipeitBackup).Parameters['filename']
        $param | Should -Not -BeNullOrEmpty
        $param.Attributes.Where({$_ -is [System.Management.Automation.ParameterAttribute]}).Mandatory | Should -Be $true
    }

    It "Has mandatory path parameter" {
        $param = (Get-Command Save-SnipeitBackup).Parameters['path']
        $param | Should -Not -BeNullOrEmpty
        $param.Attributes.Where({$_ -is [System.Management.Automation.ParameterAttribute]}).Mandatory | Should -Be $true
    }

    It "Does not call Invoke-SnipeitMethod (uses Invoke-RestMethod directly)" {
        InModuleScope 'SnipeitPS' {
            # Verify function source does not invoke Invoke-SnipeitMethod (ignore comments)
            $funcDef = (Get-Command Save-SnipeitBackup).ScriptBlock.ToString()
            $lines = $funcDef -split "`n" | Where-Object { $_ -notmatch '^\s*#' }
            ($lines -join "`n") | Should -Not -Match 'Invoke-SnipeitMethod'
        }
    }
}
