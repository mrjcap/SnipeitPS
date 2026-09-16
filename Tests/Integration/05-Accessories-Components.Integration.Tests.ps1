BeforeAll {
    Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force
    $testUrl = $env:SNIPEIT_TEST_URL
    $testKey = $env:SNIPEIT_TEST_KEY
    if ([string]::IsNullOrWhiteSpace($testUrl) -or [string]::IsNullOrWhiteSpace($testKey)) {
        throw "Integration tests require SNIPEIT_TEST_URL and SNIPEIT_TEST_KEY environment variables."
    }
    Connect-SnipeitPS -URL $testUrl -apiKey $testKey
    $script:testTimestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $passwordBytes = [byte[]]::new(24)
    $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
    try {
        $rng.GetBytes($passwordBytes)
    } finally {
        $rng.Dispose()
    }
    $script:testPassword = [Convert]::ToBase64String($passwordBytes)

    # Pre-requisite Categories and Manufacturer
    $script:accCat = New-SnipeitCategory -name "INT-AccCat-$($script:testTimestamp)" -category_type "accessory"
    $script:conCat = New-SnipeitCategory -name "INT-ConCat-$($script:testTimestamp)" -category_type "consumable"
    $script:cmpCat = New-SnipeitCategory -name "INT-CmpCat-$($script:testTimestamp)" -category_type "component"
    $script:mfg = New-SnipeitManufacturer -name "INT-PartsMfg-$($script:testTimestamp)"
    $script:user = New-SnipeitUser -first_name "Parts" -last_name "Recipient" `
        -username "partsuser$($script:testTimestamp)" `
        -email "partsuser$($script:testTimestamp)@example.com" `
        -password $script:testPassword
}

AfterAll {
    if ($script:user -and $script:user.id) {
        Remove-SnipeitUser -id $script:user.id -Confirm:$false
    }
    if ($script:mfg -and $script:mfg.id) {
        Remove-SnipeitManufacturer -id $script:mfg.id -Confirm:$false
    }
    if ($script:cmpCat -and $script:cmpCat.id) {
        Remove-SnipeitCategory -id $script:cmpCat.id -Confirm:$false
    }
    if ($script:conCat -and $script:conCat.id) {
        Remove-SnipeitCategory -id $script:conCat.id -Confirm:$false
    }
    if ($script:accCat -and $script:accCat.id) {
        Remove-SnipeitCategory -id $script:accCat.id -Confirm:$false
    }
}

Describe "Live Snipe-IT Integration: Accessories, Consumables & Components" -Tag "Integration" {
    Context "Accessory Operations" {
        BeforeAll {
            $script:accName = "INT-Accessory-$($script:testTimestamp)"
            $script:createdAcc = New-SnipeitAccessory -name $script:accName `
                -category_id $script:accCat.id `
                -qty 10
        }

        AfterAll {
            if ($script:createdAcc -and $script:createdAcc.id) {
                try {
                    $owners = Get-SnipeitAccessoryOwner -id $script:createdAcc.id
                    foreach ($owner in @($owners)) {
                        if ($owner.id) {
                            Reset-SnipeitAccessoryOwner -assigned_pivot_id $owner.id -Confirm:$false
                        }
                    }
                } catch {}
                Remove-SnipeitAccessory -id $script:createdAcc.id -Confirm:$false
            }
        }

        It "Creates a new accessory" {
            $script:createdAcc | Should -Not -BeNullOrEmpty
            $script:createdAcc.id | Should -BeGreaterThan 0
        }

        It "Retrieves accessory by ID" {
            $acc = Get-SnipeitAccessory -id $script:createdAcc.id
            $acc | Should -Not -BeNullOrEmpty
            $acc.name | Should -Be $script:accName
            $acc.qty | Should -Be 10
        }

        It "Checks out accessory to user" {
            $checkout = Set-SnipeitAccessoryOwner -id $script:createdAcc.id -assigned_to $script:user.id
            $checkout | Should -Not -BeNullOrEmpty
        }

        It "Updates accessory details" {
            $null = Set-SnipeitAccessory -id $script:createdAcc.id -min_amt 2
            $acc = Get-SnipeitAccessory -id $script:createdAcc.id
            $acc.min_amt | Should -Be 2
        }
    }

    Context "Consumable Operations" {
        BeforeAll {
            $script:conName = "INT-Consumable-$($script:testTimestamp)"
            $script:createdCon = New-SnipeitConsumable -name $script:conName `
                -category_id $script:conCat.id `
                -qty 50
        }

        AfterAll {
            if ($script:createdCon -and $script:createdCon.id) {
                Remove-SnipeitConsumable -id $script:createdCon.id -Confirm:$false
            }
        }

        It "Creates a new consumable" {
            $script:createdCon | Should -Not -BeNullOrEmpty
            $script:createdCon.id | Should -BeGreaterThan 0
        }

        It "Retrieves consumable by ID" {
            $con = Get-SnipeitConsumable -id $script:createdCon.id
            $con | Should -Not -BeNullOrEmpty
            $con.name | Should -Be $script:conName
            $con.qty | Should -Be 50
        }

        It "Checks out consumable to user" {
            { Set-SnipeitConsumableOwner -id $script:createdCon.id -assigned_to $script:user.id } | Should -Not -Throw
        }

        It "Updates consumable details" {
            $null = Set-SnipeitConsumable -id $script:createdCon.id -min_amt 5
            $con = Get-SnipeitConsumable -id $script:createdCon.id
            $con.min_amt | Should -Be 5
        }

        It "Retrieves users who checked out consumable" {
            { Get-SnipeitConsumableUser -id $script:createdCon.id } | Should -Not -Throw
        }
    }

    Context "Component Operations" {
        BeforeAll {
            $script:cmpName = "INT-Component-$($script:testTimestamp)"
            $script:createdCmp = New-SnipeitComponent -name $script:cmpName `
                -category_id $script:cmpCat.id `
                -qty 100
        }

        AfterAll {
            if ($script:createdCmp -and $script:createdCmp.id) {
                Remove-SnipeitComponent -id $script:createdCmp.id -Confirm:$false
            }
        }

        It "Creates a new component" {
            $script:createdCmp | Should -Not -BeNullOrEmpty
            $script:createdCmp.id | Should -BeGreaterThan 0
        }

        It "Retrieves component by ID" {
            $cmp = Get-SnipeitComponent -id $script:createdCmp.id
            $cmp | Should -Not -BeNullOrEmpty
            $cmp.name | Should -Be $script:cmpName
            $cmp.qty | Should -Be 100
        }

        It "Updates component min_amt" {
            $null = Set-SnipeitComponent -id $script:createdCmp.id -min_amt 5
            $cmp = Get-SnipeitComponent -id $script:createdCmp.id
            $cmp.min_amt | Should -Be 5
        }
    }
}
