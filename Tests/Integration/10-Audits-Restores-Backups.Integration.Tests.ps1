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
                -password $script:testPassword
            
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
