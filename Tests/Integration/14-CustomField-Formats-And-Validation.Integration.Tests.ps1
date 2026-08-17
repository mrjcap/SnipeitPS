BeforeAll {
    Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force
    $testUrl = $env:SNIPEIT_TEST_URL ?? 'http://192.168.1.47'
    $testKey = $env:SNIPEIT_TEST_KEY ?? 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMjk1OGM2ZWY2ZDU3ZTAxZWM4NmIxN2NjMGFlZjA1NGVkY2UwOThlMzllNzQ3MTZmMTE4NDhmMTdjNTVlYzc4ODFhMGNjMDE5ZDdiM2NiODYiLCJpYXQiOjE3ODY5MDkzNjIuNjQ5NDgzLCJuYmYiOjE3ODY5MDkzNjIuNjQ5NDksImV4cCI6MjQxODA2MTM2Mi42MjUwOTEsInN1YiI6IjEiLCJzY29wZXMiOltdfQ.E3MaayqG_D3GJ4vBMyQjNJG261xR6Gl5MtZrVLcpUL9hWoCdz7gq3-ModyV2t36JjXMiG2_z_-wNYkmJSTH-K8BKetGjAP9ofUXVieNZbrsqthZffGZV23AZwHnMPDTfXFzkC9xRn9Qf0T55gyHytCGEWl524Zg4EkvUkeGbGBhlvsZ0hJfMg3RpvU1ONtEqAAvLlu4nCJUNscqEltoAuVvqbFhn4oYS20M8o1VJTvdj36V_oP-5BEXWP-x6i5_v2WDk2EF8BItj2g3Q3XGDmX63n3mvXKKuO1xFpLp5zNZISJ1Xl8FWqszrFRnP4x2qz8aWQMeXI2_-hAc4bOjKDZuw_4YUEYB9CE3PHKVjdXQtDpTOsbRu6t-661lk75oOwZpR6dUe-3LB7vQ0tBblJgRNX9wNr7AV0fm1DmLctwkSEFzhW0KqbnzBi_iba8NAwRoZksISUHz9AaBOkcV_kTD1P8NCLl8BkZ8YDuxlLVac0lQmhVIbaOov84qLW3sP_bOhGi64EQXE3FEapNae8cMfSk5_bzQWV2_4vIxsWtpzMjHt7IWpFvb07W6KyjzcQSZKRkbBFJWGduhy9_LcERPh5Gu2izKBP7nRili41JDLsGQ_7Pt0vnBoxdwOMuJBZtph5ZFjHWtOdrDkpJ-pLjQnNiRGIYSGYHC9XfvFaR4'
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
