BeforeAll {
    Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force
    $testUrl = $env:SNIPEIT_TEST_URL ?? 'http://192.168.1.47'
    $testKey = $env:SNIPEIT_TEST_KEY ?? 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMjk1OGM2ZWY2ZDU3ZTAxZWM4NmIxN2NjMGFlZjA1NGVkY2UwOThlMzllNzQ3MTZmMTE4NDhmMTdjNTVlYzc4ODFhMGNjMDE5ZDdiM2NiODYiLCJpYXQiOjE3ODY5MDkzNjIuNjQ5NDgzLCJuYmYiOjE3ODY5MDkzNjIuNjQ5NDksImV4cCI6MjQxODA2MTM2Mi42MjUwOTEsInN1YiI6IjEiLCJzY29wZXMiOltdfQ.E3MaayqG_D3GJ4vBMyQjNJG261xR6Gl5MtZrVLcpUL9hWoCdz7gq3-ModyV2t36JjXMiG2_z_-wNYkmJSTH-K8BKetGjAP9ofUXVieNZbrsqthZffGZV23AZwHnMPDTfXFzkC9xRn9Qf0T55gyHytCGEWl524Zg4EkvUkeGbGBhlvsZ0hJfMg3RpvU1ONtEqAAvLlu4nCJUNscqEltoAuVvqbFhn4oYS20M8o1VJTvdj36V_oP-5BEXWP-x6i5_v2WDk2EF8BItj2g3Q3XGDmX63n3mvXKKuO1xFpLp5zNZISJ1Xl8FWqszrFRnP4x2qz8aWQMeXI2_-hAc4bOjKDZuw_4YUEYB9CE3PHKVjdXQtDpTOsbRu6t-661lk75oOwZpR6dUe-3LB7vQ0tBblJgRNX9wNr7AV0fm1DmLctwkSEFzhW0KqbnzBi_iba8NAwRoZksISUHz9AaBOkcV_kTD1P8NCLl8BkZ8YDuxlLVac0lQmhVIbaOov84qLW3sP_bOhGi64EQXE3FEapNae8cMfSk5_bzQWV2_4vIxsWtpzMjHt7IWpFvb07W6KyjzcQSZKRkbBFJWGduhy9_LcERPh5Gu2izKBP7nRili41JDLsGQ_7Pt0vnBoxdwOMuJBZtph5ZFjHWtOdrDkpJ-pLjQnNiRGIYSGYHC9XfvFaR4'
    Connect-SnipeitPS -URL $testUrl -apiKey $testKey
    $script:testTimestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

    # Pre-requisite Category, Manufacturer, Model, Status, Location
    $script:cat = New-SnipeitCategory -name "INT-AudCat-$($script:testTimestamp)" -category_type "asset"
    $script:mfg = New-SnipeitManufacturer -name "INT-AudMfg-$($script:testTimestamp)"
    $script:loc = New-SnipeitLocation -name "INT-AudLoc-$($script:testTimestamp)"
    $script:model = New-SnipeitModel -name "INT-AudModel-$($script:testTimestamp)" -category_id $script:cat.id -manufacturer_id $script:mfg.id
    $script:status = New-SnipeitStatus -name "INT-AudStatus-$($script:testTimestamp)" -type "deployable"
}

AfterAll {
    if ($script:model -and $script:model.id) {
        Remove-SnipeitModel -id $script:model.id -Confirm:$false
    }
    if ($script:status -and $script:status.id) {
        Remove-SnipeitStatus -id $script:status.id -Confirm:$false
    }
    if ($script:mfg -and $script:mfg.id) {
        Remove-SnipeitManufacturer -id $script:mfg.id -Confirm:$false
    }
    if ($script:cat -and $script:cat.id) {
        Remove-SnipeitCategory -id $script:cat.id -Confirm:$false
    }
    if ($script:loc -and $script:loc.id) {
        Remove-SnipeitLocation -id $script:loc.id -Confirm:$false
    }
}

Describe "Live Snipe-IT Integration: Audits, Restores & Backups" -Tag "Integration" {
    Context "Audit Operations" {
        BeforeAll {
            $script:assetToAudit = New-SnipeitAsset -asset_tag "AUD-TAG-$($script:testTimestamp)" `
                -model_id $script:model.id `
                -status_id $script:status.id `
                -rtd_location_id $script:loc.id
        }

        AfterAll {
            if ($script:assetToAudit -and $script:assetToAudit.id) {
                Remove-SnipeitAsset -id $script:assetToAudit.id -Confirm:$false
            }
        }

        It "Creates a new audit record by asset tag" {
            $audit = New-SnipeitAudit -tag $script:assetToAudit.asset_tag -location_id $script:loc.id -note "Verified physically"
            $audit | Should -Not -BeNullOrEmpty
        }

        It "Creates a new audit record by asset ID" {
            $audit = New-SnipeitAudit -id $script:assetToAudit.id -location_id $script:loc.id -note "Verified by ID"
            $audit | Should -Not -BeNullOrEmpty
        }

        It "Queries assets due for audit" {
            { Get-SnipeitAuditDue } | Should -Not -Throw
        }

        It "Queries assets overdue for audit" {
            { Get-SnipeitAuditOverdue } | Should -Not -Throw
        }
    }

    Context "Soft-Delete and Restore Operations" {
        It "Soft-deletes and restores an asset" {
            $tempAsset = New-SnipeitAsset -asset_tag "REST-TAG-$($script:testTimestamp)" `
                -model_id $script:model.id `
                -status_id $script:status.id
            
            $tempAsset | Should -Not -BeNullOrEmpty
            Remove-SnipeitAsset -id $tempAsset.id -Confirm:$false

            $restore = Restore-SnipeitAsset -id $tempAsset.id -Confirm:$false
            $restore | Should -Not -BeNullOrEmpty

            $fetched = Get-SnipeitAsset -id $tempAsset.id
            $fetched | Should -Not -BeNullOrEmpty
            $fetched.id | Should -Be $tempAsset.id

            Remove-SnipeitAsset -id $tempAsset.id -Confirm:$false
        }

        It "Soft-deletes and restores a user" {
            $tempUser = New-SnipeitUser -first_name "Rest" -last_name "User" `
                -username "restuser$($script:testTimestamp)" `
                -email "restuser$($script:testTimestamp)@example.com" `
                -password "TestingRest123!"
            
            $tempUser | Should -Not -BeNullOrEmpty
            Remove-SnipeitUser -id $tempUser.id -Confirm:$false

            { Restore-SnipeitUser -id $tempUser.id -Confirm:$false } | Should -Not -Throw

            $fetched = Get-SnipeitUser -id $tempUser.id
            $fetched | Should -Not -BeNullOrEmpty
            $fetched.id | Should -Be $tempUser.id

            Remove-SnipeitUser -id $tempUser.id -Confirm:$false
        }
    }

    Context "Backup Operations" {
        It "Queries existing backups without error" {
            { Get-SnipeitBackup } | Should -Not -Throw
        }

        It "Validates Save-SnipeitBackup directory parameter constraints" {
            { Save-SnipeitBackup -filename "test.sql" -path "C:\NonExistentTestFolder12345" } | Should -Throw
        }
    }
}
