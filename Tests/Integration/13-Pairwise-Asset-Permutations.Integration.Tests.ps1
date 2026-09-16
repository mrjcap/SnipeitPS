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

    # Pre-requisite entities
    $script:pairCat = New-SnipeitCategory -name "INT-PairCat-$($script:testTimestamp)" -category_type "asset"
    $script:pairMfg = New-SnipeitManufacturer -name "INT-PairMfg-$($script:testTimestamp)"
    $script:pairLoc = New-SnipeitLocation -name "INT-PairLoc-$($script:testTimestamp)"
    $script:pairDept = New-SnipeitDepartment -name "INT-PairDept-$($script:testTimestamp)"
    $script:pairSupp = New-SnipeitSupplier -name "INT-PairSupp-$($script:testTimestamp)"
    $script:pairModel = New-SnipeitModel -name "INT-PairModel-$($script:testTimestamp)" -category_id $script:pairCat.id -manufacturer_id $script:pairMfg.id
    $script:pairStatus = New-SnipeitStatus -name "INT-PairStatus-$($script:testTimestamp)" -type "deployable"

    $script:createdPairAssets = @()
    $script:createdPairUsers = @()
}

AfterAll {
    foreach ($a in $script:createdPairAssets) {
        if ($a -and $a.id) {
            Remove-SnipeitAsset -id $a.id -Confirm:$false
        }
    }
    foreach ($u in $script:createdPairUsers) {
        if ($u -and $u.id) {
            Remove-SnipeitUser -id $u.id -Confirm:$false
        }
    }
    if ($script:pairModel -and $script:pairModel.id) {
        Remove-SnipeitModel -id $script:pairModel.id -Confirm:$false
    }
    if ($script:pairStatus -and $script:pairStatus.id) {
        Remove-SnipeitStatus -id $script:pairStatus.id -Confirm:$false
    }
    if ($script:pairSupp -and $script:pairSupp.id) {
        Remove-SnipeitSupplier -id $script:pairSupp.id -Confirm:$false
    }
    if ($script:pairDept -and $script:pairDept.id) {
        Remove-SnipeitDepartment -id $script:pairDept.id -Confirm:$false
    }
    if ($script:pairLoc -and $script:pairLoc.id) {
        Remove-SnipeitLocation -id $script:pairLoc.id -Confirm:$false
    }
    if ($script:pairMfg -and $script:pairMfg.id) {
        Remove-SnipeitManufacturer -id $script:pairMfg.id -Confirm:$false
    }
    if ($script:pairCat -and $script:pairCat.id) {
        Remove-SnipeitCategory -id $script:pairCat.id -Confirm:$false
    }
}

Describe "Live Snipe-IT Integration: Pairwise Parameter Permutations" -Tag "Integration" {
    Context "New-SnipeitAsset Parameter Combinations" {
        It "Creates asset with full optional payload (Financial + Physical + Flags)" {
            $asset = New-SnipeitAsset -asset_tag "PAIR-FULL-$($script:testTimestamp)" `
                -model_id $script:pairModel.id `
                -status_id $script:pairStatus.id `
                -name "Full Permutation Asset" `
                -serial "SN-FULL-$($script:testTimestamp)" `
                -purchase_date "2026-01-15" `
                -purchase_cost "1299.99" `
                -order_number "PO-998811" `
                -supplier_id $script:pairSupp.id `
                -rtd_location_id $script:pairLoc.id `
                -warranty_months 36 `
                -notes "Pairwise full test notes"

            $asset | Should -Not -BeNullOrEmpty
            $asset.id | Should -BeGreaterThan 0
            $asset.asset_tag | Should -Be "PAIR-FULL-$($script:testTimestamp)"
            $script:createdPairAssets += $asset
        }

        It "Creates asset with Financial-Only subset (Cost + Date + Supplier + PO)" {
            $asset = New-SnipeitAsset -asset_tag "PAIR-FIN-$($script:testTimestamp)" `
                -model_id $script:pairModel.id `
                -status_id $script:pairStatus.id `
                -purchase_date "2026-03-01" `
                -purchase_cost "450.50" `
                -supplier_id $script:pairSupp.id `
                -order_number "PO-FIN-4422"

            $asset | Should -Not -BeNullOrEmpty
            $asset.id | Should -BeGreaterThan 0
            $script:createdPairAssets += $asset
        }

        It "Creates asset with Physical-Only subset (Name + Serial + Location + Warranty)" {
            $asset = New-SnipeitAsset -asset_tag "PAIR-PHYS-$($script:testTimestamp)" `
                -model_id $script:pairModel.id `
                -status_id $script:pairStatus.id `
                -name "Physical Only Asset" `
                -serial "SN-PHYS-$($script:testTimestamp)" `
                -rtd_location_id $script:pairLoc.id `
                -warranty_months 12

            $asset | Should -Not -BeNullOrEmpty
            $asset.id | Should -BeGreaterThan 0
            $script:createdPairAssets += $asset
        }

        It "Creates asset with Minimal Required payload (Model + Status + Tag only)" {
            $asset = New-SnipeitAsset -asset_tag "PAIR-MIN-$($script:testTimestamp)" `
                -model_id $script:pairModel.id `
                -status_id $script:pairStatus.id

            $asset | Should -Not -BeNullOrEmpty
            $asset.id | Should -BeGreaterThan 0
            $script:createdPairAssets += $asset
        }
    }

    Context "Set-SnipeitAsset Multi-Parameter Updates" {
        It "Updates financial fields on existing asset" {
            $target = $script:createdPairAssets | Select-Object -First 1
            $updated = Set-SnipeitAsset -id $target.id -purchase_cost "899.00" -order_number "PO-UPD-55" -Confirm:$false
            $updated | Should -Not -BeNullOrEmpty

            $fetched = Get-SnipeitAsset -id $target.id
            $fetched.order_number | Should -Be "PO-UPD-55"
        }

        It "Updates location and warranty on existing asset" {
            $target = $script:createdPairAssets | Select-Object -First 1
            $updated = Set-SnipeitAsset -id $target.id -rtd_location_id $script:pairLoc.id -warranty_months 24 -Confirm:$false
            $updated | Should -Not -BeNullOrEmpty
        }

        It "Pipeline updates asset notes and name simultaneously" {
            $target = $script:createdPairAssets | Select-Object -First 1
            $null = [PSCustomObject]@{ id = $target.id } | Set-SnipeitAsset -name "Pipeline Renamed Asset" -notes "Updated via pipeline" -Confirm:$false
            $fetched = Get-SnipeitAsset -id $target.id
            $fetched.name | Should -Be "Pipeline Renamed Asset"
            $fetched.notes | Should -Be "Updated via pipeline"
        }
    }

    Context "New-SnipeitUser Multi-Parameter Permutations" {
        It "Creates user with full demographic and organizational profile" {
            $user = New-SnipeitUser -first_name "Pairwise" `
                -last_name "Engineer" `
                -username "paireng$($script:testTimestamp)" `
                -email "paireng$($script:testTimestamp)@example.com" `
                -password $script:testPassword `
                -jobtitle "Lead Systems Architect" `
                -employee_num "EMP-7788" `
                -department_id $script:pairDept.id `
                -location_id $script:pairLoc.id `
                -phone "+1-555-0199" `
                -activated $true

            $user | Should -Not -BeNullOrEmpty
            $user.id | Should -BeGreaterThan 0
            $user.username | Should -Be "paireng$($script:testTimestamp)"
            $script:createdPairUsers += $user
        }

        It "Creates user with minimal credentials profile" {
            $user = New-SnipeitUser -first_name "Min" `
                -last_name "User" `
                -username "minuser$($script:testTimestamp)" `
                -email "minuser$($script:testTimestamp)@example.com" `
                -password $script:testPassword

            $user | Should -Not -BeNullOrEmpty
            $user.id | Should -BeGreaterThan 0
            $script:createdPairUsers += $user
        }
    }
}
