BeforeAll {
    Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force
    $testUrl = $env:SNIPEIT_TEST_URL
    $testKey = $env:SNIPEIT_TEST_KEY
    if ([string]::IsNullOrWhiteSpace($testUrl) -or [string]::IsNullOrWhiteSpace($testKey)) {
        throw "Integration tests require SNIPEIT_TEST_URL and SNIPEIT_TEST_KEY environment variables."
    }
    Connect-SnipeitPS -URL $testUrl -apiKey $testKey
    $script:testTimestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

    # Pre-requisite Category & Manufacturer
    $script:cfCat = New-SnipeitCategory -name "INT-CFCat-$($script:testTimestamp)" -category_type "asset"
    $script:cfMfg = New-SnipeitManufacturer -name "INT-CFMfg-$($script:testTimestamp)"

    # Create Custom Fieldset
    $script:cfFieldset = New-SnipeitFieldset -name "INT-CFSet-$($script:testTimestamp)"

    # Create Diverse Custom Fields
    $script:macField = New-SnipeitCustomField -name "INT-MAC-$($script:testTimestamp)" -element "text" -format "MAC"
    $script:ipField = New-SnipeitCustomField -name "INT-IP-$($script:testTimestamp)" -element "text" -format "IP"
    $script:notesField = New-SnipeitCustomField -name "INT-TextArea-$($script:testTimestamp)" -element "textarea" -format "ANY"

    # Associate Fields to Fieldset via Register-SnipeitCustomField
    if ($script:cfFieldset -and $script:cfFieldset.id) {
        $null = Register-SnipeitCustomField -id $script:macField.id -fieldset_id $script:cfFieldset.id
        $null = Register-SnipeitCustomField -id $script:ipField.id -fieldset_id $script:cfFieldset.id
        $null = Register-SnipeitCustomField -id $script:notesField.id -fieldset_id $script:cfFieldset.id
    }

    # Create Model linked to Fieldset
    $script:cfModel = New-SnipeitModel -name "INT-CFModel-$($script:testTimestamp)" `
        -category_id $script:cfCat.id `
        -manufacturer_id $script:cfMfg.id `
        -fieldset_id $script:cfFieldset.id

    $script:cfStatus = New-SnipeitStatus -name "INT-CFStatus-$($script:testTimestamp)" -type "deployable"
    $script:createdCFAssets = @()
}

AfterAll {
    foreach ($a in $script:createdCFAssets) {
        if ($a -and $a.id) {
            Remove-SnipeitAsset -id $a.id -Confirm:$false
        }
    }
    if ($script:cfModel -and $script:cfModel.id) {
        Remove-SnipeitModel -id $script:cfModel.id -Confirm:$false
    }
    if ($script:cfStatus -and $script:cfStatus.id) {
        Remove-SnipeitStatus -id $script:cfStatus.id -Confirm:$false
    }
    if ($script:cfFieldset -and $script:cfFieldset.id) {
        if ($script:macField -and $script:macField.id) {
            try { Unregister-SnipeitCustomField -id $script:macField.id -fieldset_id $script:cfFieldset.id -Confirm:$false } catch {}
        }
        if ($script:ipField -and $script:ipField.id) {
            try { Unregister-SnipeitCustomField -id $script:ipField.id -fieldset_id $script:cfFieldset.id -Confirm:$false } catch {}
        }
        if ($script:notesField -and $script:notesField.id) {
            try { Unregister-SnipeitCustomField -id $script:notesField.id -fieldset_id $script:cfFieldset.id -Confirm:$false } catch {}
        }
        Remove-SnipeitFieldset -id $script:cfFieldset.id -Confirm:$false
    }
    if ($script:macField -and $script:macField.id) {
        Remove-SnipeitCustomField -id $script:macField.id -Confirm:$false
    }
    if ($script:ipField -and $script:ipField.id) {
        Remove-SnipeitCustomField -id $script:ipField.id -Confirm:$false
    }
    if ($script:notesField -and $script:notesField.id) {
        Remove-SnipeitCustomField -id $script:notesField.id -Confirm:$false
    }
    if ($script:cfMfg -and $script:cfMfg.id) {
        Remove-SnipeitManufacturer -id $script:cfMfg.id -Confirm:$false
    }
    if ($script:cfCat -and $script:cfCat.id) {
        Remove-SnipeitCategory -id $script:cfCat.id -Confirm:$false
    }
}

Describe "Live Snipe-IT Integration: Custom Field Formats & Validation" -Tag "Integration" {
    Context "Custom Field Definition Types" {
        It "Creates MAC address formatted field" {
            $script:macField | Should -Not -BeNullOrEmpty
            $script:macField.id | Should -BeGreaterThan 0
            $script:macField.format | Should -Be "MAC"
        }

        It "Creates IP address formatted field" {
            $script:ipField | Should -Not -BeNullOrEmpty
            $script:ipField.id | Should -BeGreaterThan 0
            $script:ipField.format | Should -Be "IP"
        }

        It "Creates textarea formatted field" {
            $script:notesField | Should -Not -BeNullOrEmpty
            $script:notesField.id | Should -BeGreaterThan 0
            $script:notesField.element | Should -Be "textarea"
        }
    }

    Context "Asset Custom Field Binding and Updates" {
        It "Creates asset with valid custom field values via hashtable" {
            $dbNameMac = $script:macField.db_column_name
            $dbNameIp = $script:ipField.db_column_name

            $cfPayload = @{}
            if ($dbNameMac) { $cfPayload[$dbNameMac] = "AA:BB:CC:DD:EE:FF" }
            if ($dbNameIp) { $cfPayload[$dbNameIp] = "192.168.1.150" }

            $asset = New-SnipeitAsset -asset_tag "CF-TAG-$($script:testTimestamp)" `
                -model_id $script:cfModel.id `
                -status_id $script:cfStatus.id `
                -customfields $cfPayload

            $asset | Should -Not -BeNullOrEmpty
            $asset.id | Should -BeGreaterThan 0
            $script:createdCFAssets += $asset
        }

        It "Updates asset custom field values" {
            $targetAsset = $script:createdCFAssets | Select-Object -First 1
            $dbNameIp = $script:ipField.db_column_name
            
            if ($dbNameIp -and $targetAsset) {
                $updatePayload = @{ $dbNameIp = "192.168.1.200" }
                $updated = Set-SnipeitAsset -id $targetAsset.id -customfields $updatePayload -Confirm:$false
                $updated | Should -Not -BeNullOrEmpty
            }
        }

        It "Searches asset with custom field parameters" {
            $dbNameIp = $script:ipField.db_column_name
            if ($dbNameIp) {
                $searchQuery = @{ $dbNameIp = "192.168.1.200" }
                { Get-SnipeitAsset -customfields $searchQuery } | Should -Not -Throw
            }
        }
    }
}
