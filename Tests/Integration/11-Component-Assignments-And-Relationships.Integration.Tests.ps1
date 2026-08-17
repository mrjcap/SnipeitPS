BeforeAll {
    Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force
    $testUrl = $env:SNIPEIT_TEST_URL ?? 'http://192.168.1.47'
    $testKey = $env:SNIPEIT_TEST_KEY ?? 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMjk1OGM2ZWY2ZDU3ZTAxZWM4NmIxN2NjMGFlZjA1NGVkY2UwOThlMzllNzQ3MTZmMTE4NDhmMTdjNTVlYzc4ODFhMGNjMDE5ZDdiM2NiODYiLCJpYXQiOjE3ODY5MDkzNjIuNjQ5NDgzLCJuYmYiOjE3ODY5MDkzNjIuNjQ5NDksImV4cCI6MjQxODA2MTM2Mi42MjUwOTEsInN1YiI6IjEiLCJzY29wZXMiOltdfQ.E3MaayqG_D3GJ4vBMyQjNJG261xR6Gl5MtZrVLcpUL9hWoCdz7gq3-ModyV2t36JjXMiG2_z_-wNYkmJSTH-K8BKetGjAP9ofUXVieNZbrsqthZffGZV23AZwHnMPDTfXFzkC9xRn9Qf0T55gyHytCGEWl524Zg4EkvUkeGbGBhlvsZ0hJfMg3RpvU1ONtEqAAvLlu4nCJUNscqEltoAuVvqbFhn4oYS20M8o1VJTvdj36V_oP-5BEXWP-x6i5_v2WDk2EF8BItj2g3Q3XGDmX63n3mvXKKuO1xFpLp5zNZISJ1Xl8FWqszrFRnP4x2qz8aWQMeXI2_-hAc4bOjKDZuw_4YUEYB9CE3PHKVjdXQtDpTOsbRu6t-661lk75oOwZpR6dUe-3LB7vQ0tBblJgRNX9wNr7AV0fm1DmLctwkSEFzhW0KqbnzBi_iba8NAwRoZksISUHz9AaBOkcV_kTD1P8NCLl8BkZ8YDuxlLVac0lQmhVIbaOov84qLW3sP_bOhGi64EQXE3FEapNae8cMfSk5_bzQWV2_4vIxsWtpzMjHt7IWpFvb07W6KyjzcQSZKRkbBFJWGduhy9_LcERPh5Gu2izKBP7nRili41JDLsGQ_7Pt0vnBoxdwOMuJBZtph5ZFjHWtOdrDkpJ-pLjQnNiRGIYSGYHC9XfvFaR4'
    Connect-SnipeitPS -URL $testUrl -apiKey $testKey
    $script:testTimestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

    # Pre-requisite entities
    $script:relMfg = New-SnipeitManufacturer -name "INT-RelMfg-$($script:testTimestamp)"
    $script:relCat = New-SnipeitCategory -name "INT-RelCat-$($script:testTimestamp)" -category_type "asset"
    $script:relCmpCat = New-SnipeitCategory -name "INT-RelCmpCat-$($script:testTimestamp)" -category_type "component"
    $script:relStatus = New-SnipeitStatus -name "INT-RelStatus-$($script:testTimestamp)" -type "deployable"
    $script:relModel = New-SnipeitModel -name "INT-RelModel-$($script:testTimestamp)" -category_id $script:relCat.id -manufacturer_id $script:relMfg.id
    $script:relAsset = New-SnipeitAsset -asset_tag "REL-TAG-$($script:testTimestamp)" -model_id $script:relModel.id -status_id $script:relStatus.id
    $script:relUser = New-SnipeitUser -first_name "Rel" -last_name "User" `
        -username "reluser$($script:testTimestamp)" `
        -email "reluser$($script:testTimestamp)@example.com" `
        -password "TestingRel123!"
}

AfterAll {
    if ($script:relAsset -and $script:relAsset.id) {
        Remove-SnipeitAsset -id $script:relAsset.id -Confirm:$false
    }
    if ($script:relModel -and $script:relModel.id) {
        Remove-SnipeitModel -id $script:relModel.id -Confirm:$false
    }
    if ($script:relUser -and $script:relUser.id) {
        Remove-SnipeitUser -id $script:relUser.id -Confirm:$false
    }
    if ($script:relStatus -and $script:relStatus.id) {
        Remove-SnipeitStatus -id $script:relStatus.id -Confirm:$false
    }
    if ($script:relCmpCat -and $script:relCmpCat.id) {
        Remove-SnipeitCategory -id $script:relCmpCat.id -Confirm:$false
    }
    if ($script:relCat -and $script:relCat.id) {
        Remove-SnipeitCategory -id $script:relCat.id -Confirm:$false
    }
    if ($script:relMfg -and $script:relMfg.id) {
        Remove-SnipeitManufacturer -id $script:relMfg.id -Confirm:$false
    }
}

Describe "Live Snipe-IT Integration: Component Assignments & Relationships" -Tag "Integration" {
    Context "Supplier Management" {
        BeforeAll {
            $script:suppName = "INT-Supplier-$($script:testTimestamp)"
            $script:createdSupplier = New-SnipeitSupplier -name $script:suppName -email "supplier@test.local"
        }

        AfterAll {
            if ($script:createdSupplier -and $script:createdSupplier.id) {
                Remove-SnipeitSupplier -id $script:createdSupplier.id -Confirm:$false
            }
        }

        It "Creates a new supplier" {
            $script:createdSupplier | Should -Not -BeNullOrEmpty
            $script:createdSupplier.id | Should -BeGreaterThan 0
        }

        It "Retrieves supplier by ID" {
            $supp = Get-SnipeitSupplier -id $script:createdSupplier.id
            $supp | Should -Not -BeNullOrEmpty
            $supp.name | Should -Be $script:suppName
        }

        It "Updates supplier details" {
            $updatedSuppName = "$($script:suppName)-Upd"
            $null = Set-SnipeitSupplier -id $script:createdSupplier.id -name $updatedSuppName
            $supp = Get-SnipeitSupplier -id $script:createdSupplier.id
            $supp.name | Should -Be $updatedSuppName
        }
    }

    Context "Component Checkout & Checkin to Asset" {
        BeforeAll {
            $script:cmp = New-SnipeitComponent -name "INT-RelCmp-$($script:testTimestamp)" `
                -category_id $script:relCmpCat.id `
                -qty 10
        }

        AfterAll {
            if ($script:cmp -and $script:cmp.id) {
                try {
                    $cmpAssets = Get-SnipeitComponentAsset -id $script:cmp.id
                    foreach ($ca in @($cmpAssets)) {
                        if ($ca.assigned_pivot_id) {
                            Reset-SnipeitComponentOwner -id $ca.assigned_pivot_id -checkin_qty $ca.assigned_qty -Confirm:$false
                        }
                    }
                } catch {}
                Remove-SnipeitComponent -id $script:cmp.id -Confirm:$false
            }
        }

        It "Checks out component to asset" {
            { Set-SnipeitComponentOwner -id $script:cmp.id -assigned_to $script:relAsset.id -assigned_qty 2 } | Should -Not -Throw
        }

        It "Retrieves components allocated to asset" {
            $cmpAssets = Get-SnipeitComponentAsset -id $script:cmp.id
            $cmpAssets | Should -Not -BeNullOrEmpty
            $script:cmpPivotId = ($cmpAssets | Select-Object -First 1).assigned_pivot_id
            $script:cmpPivotId | Should -BeGreaterThan 0
        }

        It "Checks in component from asset" {
            { Reset-SnipeitComponentOwner -id $script:cmpPivotId -checkin_qty 2 } | Should -Not -Throw
        }
    }

    Context "User Relationship Queries" {
        It "Retrieves assets checked out to user" {
            { Get-SnipeitUserAsset -id $script:relUser.id } | Should -Not -Throw
        }

        It "Retrieves accessories checked out to user" {
            { Get-SnipeitUserAccessory -id $script:relUser.id } | Should -Not -Throw
        }

        It "Retrieves user EULA acceptance status" {
            { Get-SnipeitUserEula -id $script:relUser.id } | Should -Not -Throw
        }
    }

    Context "Asset Labels & Aliases" {
        It "Generates printable asset label payload" {
            $labels = New-SnipeitAssetLabel -asset_ids @($script:relAsset.id)
            $labels | Should -Not -BeNullOrEmpty
        }

        It "Updates legacy alias strings in script block" {
            $legacyCode = "Get-SnipeitCompanyList -all"
            $updatedCode = $legacyCode | Update-SnipeitAlias
            $updatedCode | Should -Not -BeNullOrEmpty
        }

        It "Executes Set-SnipeitInfo deprecated compatibility cmdlet" {
            { Set-SnipeitInfo -url $testUrl -apiKey $testKey } | Should -Not -Throw
        }
    }
}
