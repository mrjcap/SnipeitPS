BeforeAll {
    Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force
    $testUrl = $env:SNIPEIT_TEST_URL
    $testKey = $env:SNIPEIT_TEST_KEY
    if ([string]::IsNullOrWhiteSpace($testUrl) -or [string]::IsNullOrWhiteSpace($testKey)) {
        throw "Integration tests require SNIPEIT_TEST_URL and SNIPEIT_TEST_KEY environment variables."
    }
    Connect-SnipeitPS -URL $testUrl -apiKey $testKey
    $script:testTimestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
}

Describe "Live Snipe-IT Integration: Negative Testing & Error Boundaries" -Tag "Integration" {
    Context "Non-Existent Resource Queries" {
        It "Gracefully writes error when querying non-existent asset ID" {
            $ev = $null
            $res = Get-SnipeitAsset -id 99999999 -ErrorVariable ev -ErrorAction SilentlyContinue
            $res | Should -BeNullOrEmpty
            $ev | Should -Not -BeNullOrEmpty
        }

        It "Gracefully writes error when querying non-existent user ID" {
            $ev = $null
            $res = Get-SnipeitUser -id 99999999 -ErrorVariable ev -ErrorAction SilentlyContinue
            $res | Should -BeNullOrEmpty
            $ev | Should -Not -BeNullOrEmpty
        }

        It "Gracefully writes error when querying non-existent license ID" {
            $ev = $null
            $res = Get-SnipeitLicense -id 99999999 -ErrorVariable ev -ErrorAction SilentlyContinue
            $res | Should -BeNullOrEmpty
            $ev | Should -Not -BeNullOrEmpty
        }
    }

    Context "Client-Side Parameter Validation Boundaries" {
        It "Throws ParameterBindingValidationException when limit exceeds ValidateRange(1, 500)" {
            { Get-SnipeitAsset -limit 9999 } | Should -Throw
        }

        It "Throws ParameterBindingValidationException when order value is not in ValidateSet('asc', 'desc')" {
            { Get-SnipeitAsset -sort "created_at" -order "diagonal" } | Should -Throw
        }

        It "Enforces mandatory parameters on New-SnipeitAsset" {
            $cmd = Get-Command New-SnipeitAsset
            $cmd.Parameters['model_id'].Attributes.Mandatory | Should -Contain $true
            $cmd.Parameters['status_id'].Attributes.Mandatory | Should -Contain $true
        }
    }

    Context "Relational Integrity and Deletion Block Constraints" {
        BeforeAll {
            $script:lockedCat = New-SnipeitCategory -name "INT-LockedCat-$($script:testTimestamp)" -category_type "asset"
            $script:lockedMfg = New-SnipeitManufacturer -name "INT-LockedMfg-$($script:testTimestamp)"
            $script:lockedModel = New-SnipeitModel -name "INT-LockedMod-$($script:testTimestamp)" `
                -category_id $script:lockedCat.id `
                -manufacturer_id $script:lockedMfg.id
        }

        AfterAll {
            if ($script:lockedModel -and $script:lockedModel.id) {
                Remove-SnipeitModel -id $script:lockedModel.id -Confirm:$false
            }
            if ($script:lockedCat -and $script:lockedCat.id) {
                Remove-SnipeitCategory -id $script:lockedCat.id -Confirm:$false
            }
            if ($script:lockedMfg -and $script:lockedMfg.id) {
                Remove-SnipeitManufacturer -id $script:lockedMfg.id -Confirm:$false
            }
        }

        It "Prevents deletion of category when active models still reference it" {
            $res = Remove-SnipeitCategory -id $script:lockedCat.id -Confirm:$false
            $res | Should -BeNullOrEmpty
            $model = Get-SnipeitModel -id $script:lockedModel.id
            $model | Should -Not -BeNullOrEmpty
        }

        It "Prevents deletion of manufacturer when active models still reference it" {
            $res = Remove-SnipeitManufacturer -id $script:lockedMfg.id -Confirm:$false
            $res | Should -BeNullOrEmpty
            $model = Get-SnipeitModel -id $script:lockedModel.id
            $model | Should -Not -BeNullOrEmpty
        }
    }
}
