BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

# ============================================================
# Coverage tests for the -all pagination loop branch
# Each of these 7 functions has a while($true) loop that
# recursively calls itself when -all is specified. These tests
# exercise that branch by mocking Invoke-SnipeitMethod to
# return 50 items on the first call (triggering continuation)
# and fewer than 50 on the second call (triggering break).
# ============================================================

# ---- Functions WITH -id parameter (1-5) --------------------

Describe "Get-SnipeitAssetLicense -all pagination" {
    It "Handles -all pagination loop with multiple pages" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Item$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Item51" })
                }
            }
            $result = Get-SnipeitAssetLicense -id 1 -all -limit 50 -offset 10
            $result.Count | Should -Be 51
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter { $GetParameters.offset -eq 10 }
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter { $GetParameters.offset -eq 60 }
        }
    }
}

Describe "Get-SnipeitComponentAsset -all pagination" {
    It "Handles -all pagination loop with multiple pages" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Item$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Item51" })
                }
            }
            $result = Get-SnipeitComponentAsset -id 1 -all -limit 50 -offset 10
            $result.Count | Should -Be 51
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter { $GetParameters.offset -eq 10 }
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter { $GetParameters.offset -eq 60 }
        }
    }
}

Describe "Get-SnipeitUserAsset -all pagination" {
    It "Handles -all pagination loop with multiple pages" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Item$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Item51" })
                }
            }
            $result = Get-SnipeitUserAsset -id 1 -all -limit 50 -offset 10
            $result.Count | Should -Be 51
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter { $GetParameters.offset -eq 10 }
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter { $GetParameters.offset -eq 60 }
        }
    }
}

Describe "Get-SnipeitUserAccessory -all pagination" {
    It "Handles -all pagination loop with multiple pages" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Item$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Item51" })
                }
            }
            $result = Get-SnipeitUserAccessory -id 1 -all -limit 50 -offset 10
            $result.Count | Should -Be 51
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter { $GetParameters.offset -eq 10 }
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter { $GetParameters.offset -eq 60 }
        }
    }
}

Describe "Get-SnipeitUserLicense -all pagination" {
    It "Handles -all pagination loop with multiple pages" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Item$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Item51" })
                }
            }
            $result = Get-SnipeitUserLicense -id 1 -all -limit 50 -offset 10
            $result.Count | Should -Be 51
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter { $GetParameters.offset -eq 10 }
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter { $GetParameters.offset -eq 60 }
        }
    }
}

# ---- Functions WITHOUT -id parameter (6-7) -----------------

Describe "Get-SnipeitConsumableUser -all pagination" {
    It "Handles -all pagination loop with multiple pages" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Item$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Item51" })
                }
            }
            $result = Get-SnipeitConsumableUser -id 1 -all -limit 50 -offset 10
            $result.Count | Should -Be 51
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter { $GetParameters.offset -eq 10 }
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter { $GetParameters.offset -eq 60 }
        }
    }
}

Describe "Get-SnipeitAuditDue -all pagination" {
    It "Handles -all pagination loop with multiple pages" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Item$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Item51" })
                }
            }
            $result = Get-SnipeitAuditDue -all -limit 50 -offset 10
            $result.Count | Should -Be 51
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter { $GetParameters.offset -eq 10 }
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter { $GetParameters.offset -eq 60 }
        }
    }
}

Describe "Get-SnipeitAuditOverdue -all pagination" {
    It "Handles -all pagination loop with multiple pages" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Item$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Item51" })
                }
            }
            $result = Get-SnipeitAuditOverdue -all -limit 50 -offset 10
            $result.Count | Should -Be 51
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter { $GetParameters.offset -eq 10 }
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter { $GetParameters.offset -eq 60 }
        }
    }
}
