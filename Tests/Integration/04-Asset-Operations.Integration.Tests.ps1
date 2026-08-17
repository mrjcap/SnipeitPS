BeforeAll {
    Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force
    $testUrl = $env:SNIPEIT_TEST_URL ?? 'http://192.168.1.47'
    $testKey = $env:SNIPEIT_TEST_KEY ?? 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMjk1OGM2ZWY2ZDU3ZTAxZWM4NmIxN2NjMGFlZjA1NGVkY2UwOThlMzllNzQ3MTZmMTE4NDhmMTdjNTVlYzc4ODFhMGNjMDE5ZDdiM2NiODYiLCJpYXQiOjE3ODY5MDkzNjIuNjQ5NDgzLCJuYmYiOjE3ODY5MDkzNjIuNjQ5NDksImV4cCI6MjQxODA2MTM2Mi42MjUwOTEsInN1YiI6IjEiLCJzY29wZXMiOltdfQ.E3MaayqG_D3GJ4vBMyQjNJG261xR6Gl5MtZrVLcpUL9hWoCdz7gq3-ModyV2t36JjXMiG2_z_-wNYkmJSTH-K8BKetGjAP9ofUXVieNZbrsqthZffGZV23AZwHnMPDTfXFzkC9xRn9Qf0T55gyHytCGEWl524Zg4EkvUkeGbGBhlvsZ0hJfMg3RpvU1ONtEqAAvLlu4nCJUNscqEltoAuVvqbFhn4oYS20M8o1VJTvdj36V_oP-5BEXWP-x6i5_v2WDk2EF8BItj2g3Q3XGDmX63n3mvXKKuO1xFpLp5zNZISJ1Xl8FWqszrFRnP4x2qz8aWQMeXI2_-hAc4bOjKDZuw_4YUEYB9CE3PHKVjdXQtDpTOsbRu6t-661lk75oOwZpR6dUe-3LB7vQ0tBblJgRNX9wNr7AV0fm1DmLctwkSEFzhW0KqbnzBi_iba8NAwRoZksISUHz9AaBOkcV_kTD1P8NCLl8BkZ8YDuxlLVac0lQmhVIbaOov84qLW3sP_bOhGi64EQXE3FEapNae8cMfSk5_bzQWV2_4vIxsWtpzMjHt7IWpFvb07W6KyjzcQSZKRkbBFJWGduhy9_LcERPh5Gu2izKBP7nRili41JDLsGQ_7Pt0vnBoxdwOMuJBZtph5ZFjHWtOdrDkpJ-pLjQnNiRGIYSGYHC9XfvFaR4'
    Connect-SnipeitPS -URL $testUrl -apiKey $testKey
    $script:testTimestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

    # Pre-requisite entities
    $script:mfg = New-SnipeitManufacturer -name "INT-AssetMfg-$($script:testTimestamp)"
    $script:cat = New-SnipeitCategory -name "INT-AssetCat-$($script:testTimestamp)" -category_type "asset"
    $script:status = New-SnipeitStatus -name "INT-AssetStatus-$($script:testTimestamp)" -type "deployable"
    $script:model = New-SnipeitModel -name "INT-AssetModel-$($script:testTimestamp)" `
        -manufacturer_id $script:mfg.id `
        -category_id $script:cat.id
    $script:supplier = New-SnipeitSupplier -name "INT-Supplier-$($script:testTimestamp)"
    $script:user = New-SnipeitUser -first_name "Asset" -last_name "Custodian" `
        -username "custodian$($script:testTimestamp)" `
        -email "custodian$($script:testTimestamp)@example.com" `
        -password "TestingPass123!"
}

AfterAll {
    if ($script:user -and $script:user.id) {
        Remove-SnipeitUser -id $script:user.id -Confirm:$false
    }
    if ($script:supplier -and $script:supplier.id) {
        Remove-SnipeitSupplier -id $script:supplier.id -Confirm:$false
    }
    if ($script:model -and $script:model.id) {
        Remove-SnipeitModel -id $script:model.id -Confirm:$false
    }
    if ($script:status -and $script:status.id) {
        Remove-SnipeitStatus -id $script:status.id -Confirm:$false
    }
    if ($script:cat -and $script:cat.id) {
        Remove-SnipeitCategory -id $script:cat.id -Confirm:$false
    }
    if ($script:mfg -and $script:mfg.id) {
        Remove-SnipeitManufacturer -id $script:mfg.id -Confirm:$false
    }
}

Describe "Live Snipe-IT Integration: Asset Operations & Lifecycle" -Tag "Integration" {
    Context "Asset Lifecycle Management" {
        BeforeAll {
            $script:assetTag = "TAG-$($script:testTimestamp)"
            $script:serial = "SN-$($script:testTimestamp)"
            $script:createdAsset = New-SnipeitAsset -asset_tag $script:assetTag `
                -model_id $script:model.id `
                -status_id $script:status.id `
                -serial $script:serial `
                -name "Integration Test Laptop"
        }

        AfterAll {
            if ($script:createdAsset -and $script:createdAsset.id) {
                Remove-SnipeitAsset -id $script:createdAsset.id -Confirm:$false
            }
        }

        It "Creates a new hardware asset" {
            $script:createdAsset | Should -Not -BeNullOrEmpty
            $script:createdAsset.id | Should -BeGreaterThan 0
        }

        It "Retrieves asset by ID and by Asset Tag" {
            $assetById = Get-SnipeitAsset -id $script:createdAsset.id
            $assetById | Should -Not -BeNullOrEmpty
            $assetById.asset_tag | Should -Be $script:assetTag

            $assetByTag = Get-SnipeitAsset -asset_tag $script:assetTag
            $assetByTag | Should -Not -BeNullOrEmpty
            $assetByTag.id | Should -Be $script:createdAsset.id
        }

        It "Updates asset details" {
            $updatedName = "Integration Test Laptop Pro"
            $null = Set-SnipeitAsset -id $script:createdAsset.id -name $updatedName
            $asset = Get-SnipeitAsset -id $script:createdAsset.id
            $asset.name | Should -Be $updatedName
        }

        It "Checks out asset to a user" {
            $checkoutResult = Set-SnipeitAssetOwner -id $script:createdAsset.id `
                -assigned_id $script:user.id `
                -checkout_to_type "user"
            
            $checkoutResult | Should -Not -BeNullOrEmpty
            $asset = Get-SnipeitAsset -id $script:createdAsset.id
            $asset.assigned_to.id | Should -Be $script:user.id
        }

        It "Audits the asset" {
            $audit = Update-SnipeitAssetAudit -asset_tag $script:assetTag -note "Physical verification during integration test"
            $audit | Should -Not -BeNullOrEmpty
        }

        It "Checks in asset back to inventory" {
            $checkinResult = Reset-SnipeitAssetOwner -id $script:createdAsset.id `
                -status_id $script:status.id
            
            $checkinResult | Should -Not -BeNullOrEmpty
            $asset = Get-SnipeitAsset -id $script:createdAsset.id
            $asset.assigned_to | Should -BeNullOrEmpty
        }
    }

    Context "Asset Maintenance Management" {
        BeforeAll {
            $script:maintAsset = New-SnipeitAsset -asset_tag "MAINT-$($script:testTimestamp)" `
                -model_id $script:model.id `
                -status_id $script:status.id `
                -name "Maintenance Target Asset"
            
            $script:createdMaint = New-SnipeitAssetMaintenance -asset_id $script:maintAsset.id `
                -supplier_id $script:supplier.id `
                -asset_maintenance_type "Hardware Support" `
                -title "Annual Hardware Inspection" `
                -start_date (Get-Date).ToString("yyyy-MM-dd")
        }

        AfterAll {
            if ($script:createdMaint -and $script:createdMaint.id) {
                Remove-SnipeitAssetMaintenance -id $script:createdMaint.id -Confirm:$false
            }
            if ($script:maintAsset -and $script:maintAsset.id) {
                Remove-SnipeitAsset -id $script:maintAsset.id -Confirm:$false
            }
        }

        It "Creates a new maintenance record" {
            $script:createdMaint | Should -Not -BeNullOrEmpty
            $script:createdMaint.id | Should -BeGreaterThan 0
        }

        It "Retrieves maintenance record by Asset ID" {
            $maint = Get-SnipeitAssetMaintenance -asset_id $script:maintAsset.id
            $maint | Should -Not -BeNullOrEmpty
            ($maint | Select-Object -First 1).title | Should -Be "Annual Hardware Inspection"
        }

        It "Updates maintenance record title and cost" {
            $null = Set-SnipeitAssetMaintenance -id $script:createdMaint.id `
                -title "Annual Hardware Inspection - Completed" `
                -cost 150.00
            
            $maint = Get-SnipeitAssetMaintenance -asset_id $script:maintAsset.id
            ($maint | Select-Object -First 1).title | Should -Be "Annual Hardware Inspection - Completed"
        }
    }
}
