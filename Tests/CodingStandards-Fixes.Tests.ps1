BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

# ============================================================
# Fix 1: return bug — Set-*Owner functions must process ALL IDs
# Previously `return $result` inside foreach exited after first ID
# ============================================================

Describe "Set-SnipeitAccessoryOwner processes multiple IDs" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return [PSCustomObject]@{ status = 'success' } }
        }
    }

    It "Calls API once per ID when given array of 3 IDs" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAccessoryOwner -id 1,2,3 -assigned_to 10 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 3
        }
    }

    It "Calls correct endpoint for each ID" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAccessoryOwner -id 10,20 -assigned_to 5 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/accessories/10/checkout"
            }
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/accessories/20/checkout"
            }
        }
    }
}

Describe "Set-SnipeitAssetOwner processes multiple IDs" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return [PSCustomObject]@{ status = 'success' } }
        }
    }

    It "Calls API once per ID when given array of 3 IDs" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAssetOwner -id 1,2,3 -assigned_id 10 -checkout_to_type "user" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 3
        }
    }

    It "Calls correct endpoint for each ID" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitAssetOwner -id 10,20 -assigned_id 5 -checkout_to_type "user" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/10/checkout"
            }
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/20/checkout"
            }
        }
    }
}

Describe "Set-SnipeitComponentOwner processes multiple IDs" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return [PSCustomObject]@{ status = 'success' } }
        }
    }

    It "Calls API once per ID when given array of 3 IDs" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitComponentOwner -id 1,2,3 -assigned_to 10 -assigned_qty 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 3
        }
    }

    It "Calls correct endpoint for each ID" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitComponentOwner -id 10,20 -assigned_to 5 -assigned_qty 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/components/10/checkout"
            }
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/components/20/checkout"
            }
        }
    }
}

Describe "Set-SnipeitConsumableOwner processes multiple IDs" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return [PSCustomObject]@{ status = 'success' } }
        }
    }

    It "Calls API once per ID when given array of 3 IDs" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitConsumableOwner -id 1,2,3 -assigned_to 10 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 3
        }
    }

    It "Calls correct endpoint for each ID" {
        InModuleScope 'SnipeitPS' {
            Set-SnipeitConsumableOwner -id 10,20 -assigned_to 5 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/consumables/10/checkout"
            }
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/consumables/20/checkout"
            }
        }
    }
}

# ============================================================
# Fix 2: ValueFromPipelineByPropertyName on Set-* -id params
# ============================================================

Describe "Set-SnipeitCategory accepts pipeline input" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return [PSCustomObject]@{ status = 'success' } }
        }
    }

    It "Accepts id from pipeline by property name" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 42 } | Set-SnipeitCategory -name "PipeTest" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/categories/42"
            }
        }
    }
}

Describe "Set-SnipeitConsumable accepts pipeline input" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return [PSCustomObject]@{ status = 'success' } }
        }
    }

    It "Accepts id from pipeline by property name" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 99 } | Set-SnipeitConsumable -name "PipeTest" -qty 5 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/consumables/99"
            }
        }
    }
}

Describe "Set-SnipeitLicenseSeat accepts pipeline input" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return [PSCustomObject]@{ status = 'success' } }
        }
    }

    It "Accepts id from pipeline by property name" {
        InModuleScope 'SnipeitPS' {
            [PSCustomObject]@{ id = 7 } | Set-SnipeitLicenseSeat -seat_id 1 -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/licenses/7/seats/1"
            }
        }
    }
}

# ============================================================
# Fix 3: ConvertTo-GetParameter -ErrorAction Stop on Add-Type
# ============================================================

Describe "ConvertTo-GetParameter error handling" {
    It "Has -ErrorAction Stop on Add-Type call" {
        InModuleScope 'SnipeitPS' {
            $funcDef = (Get-Command ConvertTo-GetParameter).ScriptBlock.ToString()
            $funcDef | Should -Match 'Add-Type\s+-AssemblyName\s+System\.Web\s+-ErrorAction\s+Stop'
        }
    }
}

# ============================================================
# Fix 4: Get-ParameterValue has no empty try/finally
# ============================================================

Describe "Get-ParameterValue code quality" {
    It "Does not contain empty finally blocks" {
        InModuleScope 'SnipeitPS' {
            $funcDef = (Get-Command Get-ParameterValue).ScriptBlock.ToString()
            $funcDef | Should -Not -Match 'finally\s*\{\s*\}'
        }
    }
}
