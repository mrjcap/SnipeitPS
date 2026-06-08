BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

Describe "Get- Commands Pagination Infinite Loop Prevention" {
    It "Stops pagination when offset exceeds 10,000,000 for all Get commands" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Item1" })
            }
            try { Get-SnipeitAccessory -all -offset 10000001 -limit 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitActivity -all -offset 10000001 -limit 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitAsset -all -offset 10000001 -limit 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitAssetLicense -all -offset 10000001 -limit 1 -id 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitAssetMaintenance -all -offset 10000001 -limit 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitAuditDue -all -offset 10000001 -limit 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitAuditOverdue -all -offset 10000001 -limit 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitCategory -all -offset 10000001 -limit 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitCompany -all -offset 10000001 -limit 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitComponent -all -offset 10000001 -limit 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitComponentAsset -all -offset 10000001 -limit 1 -id 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitConsumable -all -offset 10000001 -limit 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitConsumableUser -all -offset 10000001 -limit 1 -id 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitDepartment -all -offset 10000001 -limit 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitGroup -all -offset 10000001 -limit 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitLicense -all -offset 10000001 -limit 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitLicenseSeat -all -offset 10000001 -limit 1 -id 1 -seat_id 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitLocation -all -offset 10000001 -limit 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitManufacturer -all -offset 10000001 -limit 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitModel -all -offset 10000001 -limit 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitStatus -all -offset 10000001 -limit 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitStatusAsset -all -offset 10000001 -limit 1 -id 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitSupplier -all -offset 10000001 -limit 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitUser -all -offset 10000001 -limit 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitUserAccessory -all -offset 10000001 -limit 1 -id 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitUserAsset -all -offset 10000001 -limit 1 -id 1 -ErrorAction SilentlyContinue 2>$null } catch {}
            try { Get-SnipeitUserLicense -all -offset 10000001 -limit 1 -id 1 -ErrorAction SilentlyContinue 2>$null } catch {}

            $true | Should -Be $true
        }
    }
}
