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
        -password $script:testPassword
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
