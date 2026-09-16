BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

# ============================================================
# Unit tests for -all pagination delegation
# Each of these functions delegates pagination to Invoke-SnipeitMethod
# with -Paginate:$all, streaming each page directly through the pipeline.
# ============================================================

# ---- Functions WITH -id parameter (1-5) --------------------

Describe "Get-SnipeitAssetLicense -all pagination" {
    It "Delegates pagination to Invoke-SnipeitMethod when -all is specified" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Item1" })
            }
            $result = Get-SnipeitAssetLicense -id 1 -all -limit 50 -offset 10
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and
                $GetParameters.offset -eq 10 -and
                $GetParameters.limit -eq 50
            }
        }
    }
}

Describe "Get-SnipeitComponentAsset -all pagination" {
    It "Delegates pagination to Invoke-SnipeitMethod when -all is specified" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Item1" })
            }
            $result = Get-SnipeitComponentAsset -id 1 -all -limit 50 -offset 10
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and
                $GetParameters.offset -eq 10 -and
                $GetParameters.limit -eq 50
            }
        }
    }
}

Describe "Get-SnipeitUserAsset -all pagination" {
    It "Delegates pagination to Invoke-SnipeitMethod when -all is specified" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Item1" })
            }
            $result = Get-SnipeitUserAsset -id 1 -all -limit 50 -offset 10
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and
                $GetParameters.offset -eq 10 -and
                $GetParameters.limit -eq 50
            }
        }
    }
}

Describe "Get-SnipeitUserAccessory -all pagination" {
    It "Delegates pagination to Invoke-SnipeitMethod when -all is specified" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Item1" })
            }
            $result = Get-SnipeitUserAccessory -id 1 -all -limit 50 -offset 10
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and
                $GetParameters.offset -eq 10 -and
                $GetParameters.limit -eq 50
            }
        }
    }
}

Describe "Get-SnipeitUserLicense -all pagination" {
    It "Delegates pagination to Invoke-SnipeitMethod when -all is specified" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Item1" })
            }
            $result = Get-SnipeitUserLicense -id 1 -all -limit 50 -offset 10
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and
                $GetParameters.offset -eq 10 -and
                $GetParameters.limit -eq 50
            }
        }
    }
}

# ---- Functions WITHOUT -id parameter (6-7) -----------------

Describe "Get-SnipeitConsumableUser -all pagination" {
    It "Delegates pagination to Invoke-SnipeitMethod when -all is specified" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Item1" })
            }
            $result = Get-SnipeitConsumableUser -id 1 -all -limit 50 -offset 10
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and
                $GetParameters.offset -eq 10 -and
                $GetParameters.limit -eq 50
            }
        }
    }
}

Describe "Get-SnipeitAuditDue -all pagination" {
    It "Delegates pagination to Invoke-SnipeitMethod when -all is specified" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Item1" })
            }
            $result = Get-SnipeitAuditDue -all -limit 50 -offset 10
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and
                $GetParameters.offset -eq 10 -and
                $GetParameters.limit -eq 50
            }
        }
    }
}

Describe "Get-SnipeitAuditOverdue -all pagination" {
    It "Delegates pagination to Invoke-SnipeitMethod when -all is specified" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Item1" })
            }
            $result = Get-SnipeitAuditOverdue -all -limit 50 -offset 10
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and
                $GetParameters.offset -eq 10 -and
                $GetParameters.limit -eq 50
            }
        }
    }
}
