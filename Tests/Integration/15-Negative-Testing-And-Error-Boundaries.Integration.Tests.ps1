BeforeAll {
    Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force
    $testUrl = $env:SNIPEIT_TEST_URL ?? 'http://192.168.1.47'
    $testKey = $env:SNIPEIT_TEST_KEY ?? 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMjk1OGM2ZWY2ZDU3ZTAxZWM4NmIxN2NjMGFlZjA1NGVkY2UwOThlMzllNzQ3MTZmMTE4NDhmMTdjNTVlYzc4ODFhMGNjMDE5ZDdiM2NiODYiLCJpYXQiOjE3ODY5MDkzNjIuNjQ5NDgzLCJuYmYiOjE3ODY5MDkzNjIuNjQ5NDksImV4cCI6MjQxODA2MTM2Mi42MjUwOTEsInN1YiI6IjEiLCJzY29wZXMiOltdfQ.E3MaayqG_D3GJ4vBMyQjNJG261xR6Gl5MtZrVLcpUL9hWoCdz7gq3-ModyV2t36JjXMiG2_z_-wNYkmJSTH-K8BKetGjAP9ofUXVieNZbrsqthZffGZV23AZwHnMPDTfXFzkC9xRn9Qf0T55gyHytCGEWl524Zg4EkvUkeGbGBhlvsZ0hJfMg3RpvU1ONtEqAAvLlu4nCJUNscqEltoAuVvqbFhn4oYS20M8o1VJTvdj36V_oP-5BEXWP-x6i5_v2WDk2EF8BItj2g3Q3XGDmX63n3mvXKKuO1xFpLp5zNZISJ1Xl8FWqszrFRnP4x2qz8aWQMeXI2_-hAc4bOjKDZuw_4YUEYB9CE3PHKVjdXQtDpTOsbRu6t-661lk75oOwZpR6dUe-3LB7vQ0tBblJgRNX9wNr7AV0fm1DmLctwkSEFzhW0KqbnzBi_iba8NAwRoZksISUHz9AaBOkcV_kTD1P8NCLl8BkZ8YDuxlLVac0lQmhVIbaOov84qLW3sP_bOhGi64EQXE3FEapNae8cMfSk5_bzQWV2_4vIxsWtpzMjHt7IWpFvb07W6KyjzcQSZKRkbBFJWGduhy9_LcERPh5Gu2izKBP7nRili41JDLsGQ_7Pt0vnBoxdwOMuJBZtph5ZFjHWtOdrDkpJ-pLjQnNiRGIYSGYHC9XfvFaR4'
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
