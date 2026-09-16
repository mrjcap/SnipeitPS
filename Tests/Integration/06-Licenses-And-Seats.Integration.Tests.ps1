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

    # Pre-requisite category, manufacturer, user, asset
    $script:licCat = New-SnipeitCategory -name "INT-LicCat-$($script:testTimestamp)" -category_type "license"
    $script:licMfg = New-SnipeitManufacturer -name "INT-LicMfg-$($script:testTimestamp)"
    $script:licUser = New-SnipeitUser -first_name "Lic" -last_name "User" `
        -username "licuser$($script:testTimestamp)" `
        -email "licuser$($script:testTimestamp)@example.com" `
        -password $script:testPassword
    
    $script:assetCat = New-SnipeitCategory -name "INT-LicAssetCat-$($script:testTimestamp)" -category_type "asset"
    $script:licModel = New-SnipeitModel -name "INT-LicModel-$($script:testTimestamp)" -category_id $script:assetCat.id -manufacturer_id $script:licMfg.id
    $script:licStatus = New-SnipeitStatus -name "INT-LicStatus-$($script:testTimestamp)" -type "deployable"
    $script:licAsset = New-SnipeitAsset -asset_tag "LIC-TAG-$($script:testTimestamp)" -model_id $script:licModel.id -status_id $script:licStatus.id
}

AfterAll {
    if ($script:licAsset -and $script:licAsset.id) {
        Remove-SnipeitAsset -id $script:licAsset.id -Confirm:$false
    }
    if ($script:licModel -and $script:licModel.id) {
        Remove-SnipeitModel -id $script:licModel.id -Confirm:$false
    }
    if ($script:licStatus -and $script:licStatus.id) {
        Remove-SnipeitStatus -id $script:licStatus.id -Confirm:$false
    }
    if ($script:assetCat -and $script:assetCat.id) {
        Remove-SnipeitCategory -id $script:assetCat.id -Confirm:$false
    }
    if ($script:licUser -and $script:licUser.id) {
        Remove-SnipeitUser -id $script:licUser.id -Confirm:$false
    }
    if ($script:licMfg -and $script:licMfg.id) {
        Remove-SnipeitManufacturer -id $script:licMfg.id -Confirm:$false
    }
    if ($script:licCat -and $script:licCat.id) {
        Remove-SnipeitCategory -id $script:licCat.id -Confirm:$false
    }
}

Describe "Live Snipe-IT Integration: Licenses and Seats" -Tag "Integration" {
    Context "License Lifecycle" {
        BeforeAll {
            $script:licenseName = "INT-License-$($script:testTimestamp)"
            $script:createdLicense = New-SnipeitLicense -name $script:licenseName `
                -seats 5 `
                -category_id $script:licCat.id `
                -manufacturer_id $script:licMfg.id `
                -license_name "Admin Contact" `
                -license_email "admin@example.com"
        }

        AfterAll {
            if ($script:createdLicense -and $script:createdLicense.id) {
                try {
                    $seats = Get-SnipeitLicenseSeat -id $script:createdLicense.id
                    foreach ($s in @($seats)) {
                        if ($s.id -and ($s.assigned_user -or $s.assigned_asset)) {
                            Set-SnipeitLicenseSeat -id $script:createdLicense.id -seat_id $s.id -assigned_to $null -asset_id $null -Confirm:$false
                        }
                    }
                } catch {}
                Remove-SnipeitLicense -id $script:createdLicense.id -Confirm:$false
            }
        }

        It "Creates a new software license with seats" {
            $script:createdLicense | Should -Not -BeNullOrEmpty
            $script:createdLicense.id | Should -BeGreaterThan 0
        }

        It "Retrieves license by ID" {
            $lic = Get-SnipeitLicense -id $script:createdLicense.id
            $lic | Should -Not -BeNullOrEmpty
            $lic.name | Should -Be $script:licenseName
            $lic.seats | Should -Be 5
        }

        It "Updates license details" {
            $updatedLicName = "$($script:licenseName)-Updated"
            $null = Set-SnipeitLicense -id $script:createdLicense.id -name $updatedLicName -notes "Updated via integration test"
            $lic = Get-SnipeitLicense -id $script:createdLicense.id
            $lic.name | Should -Be $updatedLicName
        }

        It "Retrieves license seats" {
            $seats = Get-SnipeitLicenseSeat -id $script:createdLicense.id
            $seats | Should -Not -BeNullOrEmpty
            $seats.Count | Should -BeGreaterOrEqual 1
            $script:seatId = ($seats | Select-Object -First 1).id
        }

        It "Assigns license seat to user" {
            $null = Set-SnipeitLicenseSeat -id $script:createdLicense.id -seat_id $script:seatId -assigned_to $script:licUser.id
            $userLicenses = Get-SnipeitUserLicense -id $script:licUser.id
            $userLicenses | Should -Not -BeNullOrEmpty
        }

        It "Assigns license seat to asset" {
            $seats = Get-SnipeitLicenseSeat -id $script:createdLicense.id
            $seat2 = ($seats | Select-Object -Skip 1 -First 1)
            if ($seat2 -and $seat2.id) {
                $null = Set-SnipeitLicenseSeat -id $script:createdLicense.id -seat_id $seat2.id -asset_id $script:licAsset.id
                $assetLicenses = Get-SnipeitAssetLicense -id $script:licAsset.id
                $assetLicenses | Should -Not -BeNullOrEmpty
            }
        }

        It "Checks in license seat" {
            $null = Set-SnipeitLicenseSeat -id $script:createdLicense.id -seat_id $script:seatId -assigned_to $null -asset_id $null
            $seats = Get-SnipeitLicenseSeat -id $script:createdLicense.id
            $seat1 = ($seats | Where-Object { $_.id -eq $script:seatId })
            $seat1.assigned_user | Should -BeNullOrEmpty
        }
    }
}
