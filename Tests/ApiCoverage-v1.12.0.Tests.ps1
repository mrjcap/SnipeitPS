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

    It "Calls /api/v1/hardware/{id}/licenses endpoint with ID interpolated" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAssetLicense -id 5
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/hardware/{id}/licenses" -and
                $PathParameter.id -eq 5 -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes GetParameters for pagination" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAssetLicense -id 5 -limit 10 -offset 20
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/hardware/{id}/licenses" -and
                $PathParameter.id -eq 5 -and
                $Method -eq "Get" -and
                $GetParameters.limit -eq 10 -and
                $GetParameters.offset -eq 20
            }
        }
    }

    It "Handles -all pagination parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "License1" }
            )}
            $result = Get-SnipeitAssetLicense -id 1 -all
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true
            }
        }
    }
}

Describe "Get-SnipeitComponentAsset" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/components/{id}/assets endpoint with ID interpolated" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitComponentAsset -id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/components/{id}/assets" -and
                $PathParameter.id -eq 3 -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes GetParameters for pagination" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitComponentAsset -id 3 -limit 10 -offset 20
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/components/{id}/assets" -and
                $PathParameter.id -eq 3 -and
                $Method -eq "Get" -and
                $GetParameters.limit -eq 10 -and
                $GetParameters.offset -eq 20
            }
        }
    }

    It "Handles -all pagination parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "Asset1" }
            )}
            $result = Get-SnipeitComponentAsset -id 1 -all
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true
            }
        }
    }
}

Describe "Get-SnipeitUserAsset" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/users/{id}/assets endpoint with ID interpolated" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitUserAsset -id 7
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/users/{id}/assets" -and
                $PathParameter.id -eq 7 -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes GetParameters for pagination" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitUserAsset -id 7 -limit 10 -offset 20
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/users/{id}/assets" -and
                $PathParameter.id -eq 7 -and
                $Method -eq "Get" -and
                $GetParameters.limit -eq 10 -and
                $GetParameters.offset -eq 20
            }
        }
    }

    It "Handles -all pagination parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "Asset1" }
            )}
            $result = Get-SnipeitUserAsset -id 1 -all
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true
            }
        }
    }
}

Describe "Get-SnipeitUserAccessory" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/users/{id}/accessories endpoint with ID interpolated" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitUserAccessory -id 7
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/users/{id}/accessories" -and
                $PathParameter.id -eq 7 -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes GetParameters for pagination" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitUserAccessory -id 7 -limit 10 -offset 20
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/users/{id}/accessories" -and
                $PathParameter.id -eq 7 -and
                $Method -eq "Get" -and
                $GetParameters.limit -eq 10 -and
                $GetParameters.offset -eq 20
            }
        }
    }

    It "Handles -all pagination parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "Accessory1" }
            )}
            $result = Get-SnipeitUserAccessory -id 1 -all
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true
            }
        }
    }
}

Describe "Get-SnipeitUserLicense" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/users/{id}/licenses endpoint with ID interpolated" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitUserLicense -id 7
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/users/{id}/licenses" -and
                $PathParameter.id -eq 7 -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes GetParameters for pagination" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitUserLicense -id 7 -limit 10 -offset 20
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/users/{id}/licenses" -and
                $PathParameter.id -eq 7 -and
                $Method -eq "Get" -and
                $GetParameters.limit -eq 10 -and
                $GetParameters.offset -eq 20
            }
        }
    }

    It "Handles -all pagination parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "License1" }
            )}
            $result = Get-SnipeitUserLicense -id 1 -all
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true
            }
        }
    }
}

Describe "Get-SnipeitConsumableUser" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/consumables/{id}/users endpoint with ID interpolated" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitConsumableUser -id 4
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/consumables/{id}/users" -and
                $PathParameter.id -eq 4 -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes GetParameters for pagination" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitConsumableUser -id 4 -limit 10 -offset 20
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/consumables/{id}/users" -and
                $PathParameter.id -eq 4 -and
                $Method -eq "Get" -and
                $GetParameters.limit -eq 10 -and
                $GetParameters.offset -eq 20
            }
        }
    }

    It "Handles -all pagination parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "User1" }
            )}
            $result = Get-SnipeitConsumableUser -id 1 -all
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true
            }
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
                $Route -eq "/api/v1/hardware/audit/due" -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes GetParameters for pagination" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAuditDue -limit 10 -offset 20
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/hardware/audit/due" -and
                $Method -eq "Get" -and
                $GetParameters.limit -eq 10 -and
                $GetParameters.offset -eq 20
            }
        }
    }

    It "Handles -all pagination parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "Asset1" }
            )}
            $result = Get-SnipeitAuditDue -all
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true
            }
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
                $Route -eq "/api/v1/hardware/audit/overdue" -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes GetParameters for pagination" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAuditOverdue -limit 10 -offset 20
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/hardware/audit/overdue" -and
                $Method -eq "Get" -and
                $GetParameters.limit -eq 10 -and
                $GetParameters.offset -eq 20
            }
        }
    }

    It "Handles -all pagination parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "Asset1" }
            )}
            $result = Get-SnipeitAuditOverdue -all
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true
            }
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
