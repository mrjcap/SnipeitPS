BeforeAll {
    Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force
    $testUrl = $env:SNIPEIT_TEST_URL ?? 'http://192.168.1.47'
    $testKey = $env:SNIPEIT_TEST_KEY ?? 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMjk1OGM2ZWY2ZDU3ZTAxZWM4NmIxN2NjMGFlZjA1NGVkY2UwOThlMzllNzQ3MTZmMTE4NDhmMTdjNTVlYzc4ODFhMGNjMDE5ZDdiM2NiODYiLCJpYXQiOjE3ODY5MDkzNjIuNjQ5NDgzLCJuYmYiOjE3ODY5MDkzNjIuNjQ5NDksImV4cCI6MjQxODA2MTM2Mi42MjUwOTEsInN1YiI6IjEiLCJzY29wZXMiOltdfQ.E3MaayqG_D3GJ4vBMyQjNJG261xR6Gl5MtZrVLcpUL9hWoCdz7gq3-ModyV2t36JjXMiG2_z_-wNYkmJSTH-K8BKetGjAP9ofUXVieNZbrsqthZffGZV23AZwHnMPDTfXFzkC9xRn9Qf0T55gyHytCGEWl524Zg4EkvUkeGbGBhlvsZ0hJfMg3RpvU1ONtEqAAvLlu4nCJUNscqEltoAuVvqbFhn4oYS20M8o1VJTvdj36V_oP-5BEXWP-x6i5_v2WDk2EF8BItj2g3Q3XGDmX63n3mvXKKuO1xFpLp5zNZISJ1Xl8FWqszrFRnP4x2qz8aWQMeXI2_-hAc4bOjKDZuw_4YUEYB9CE3PHKVjdXQtDpTOsbRu6t-661lk75oOwZpR6dUe-3LB7vQ0tBblJgRNX9wNr7AV0fm1DmLctwkSEFzhW0KqbnzBi_iba8NAwRoZksISUHz9AaBOkcV_kTD1P8NCLl8BkZ8YDuxlLVac0lQmhVIbaOov84qLW3sP_bOhGi64EQXE3FEapNae8cMfSk5_bzQWV2_4vIxsWtpzMjHt7IWpFvb07W6KyjzcQSZKRkbBFJWGduhy9_LcERPh5Gu2izKBP7nRili41JDLsGQ_7Pt0vnBoxdwOMuJBZtph5ZFjHWtOdrDkpJ-pLjQnNiRGIYSGYHC9XfvFaR4'
    Connect-SnipeitPS -URL $testUrl -apiKey $testKey
    $script:testTimestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
}

Describe "Live Snipe-IT Integration: Hardware Catalog" -Tag "Integration" {
    Context "Manufacturer Management" {
        BeforeAll {
            $script:mfgName = "INT-Mfg-$($script:testTimestamp)"
            $script:createdMfg = New-SnipeitManufacturer -name $script:mfgName
        }

        AfterAll {
            if ($script:createdMfg -and $script:createdMfg.id) {
                Remove-SnipeitManufacturer -id $script:createdMfg.id -Confirm:$false
            }
        }

        It "Creates a new manufacturer" {
            $script:createdMfg | Should -Not -BeNullOrEmpty
            $script:createdMfg.id | Should -BeGreaterThan 0
        }

        It "Retrieves manufacturer by ID" {
            $mfg = Get-SnipeitManufacturer -id $script:createdMfg.id
            $mfg | Should -Not -BeNullOrEmpty
            $mfg.name | Should -Be $script:mfgName
        }

        It "Updates manufacturer details" {
            $updatedMfgName = "$($script:mfgName)-Updated"
            $null = Set-SnipeitManufacturer -id $script:createdMfg.id -name $updatedMfgName
            $mfg = Get-SnipeitManufacturer -id $script:createdMfg.id
            $mfg.name | Should -Be $updatedMfgName
        }
    }

    Context "Category Management" {
        BeforeAll {
            $script:catName = "INT-Cat-$($script:testTimestamp)"
            $script:createdCat = New-SnipeitCategory -name $script:catName -category_type "asset"
        }

        AfterAll {
            if ($script:createdCat -and $script:createdCat.id) {
                Remove-SnipeitCategory -id $script:createdCat.id -Confirm:$false
            }
        }

        It "Creates a new category" {
            $script:createdCat | Should -Not -BeNullOrEmpty
            $script:createdCat.id | Should -BeGreaterThan 0
        }

        It "Retrieves category by ID" {
            $cat = Get-SnipeitCategory -id $script:createdCat.id
            $cat | Should -Not -BeNullOrEmpty
            $cat.name | Should -Be $script:catName
        }

        It "Updates category details" {
            $updatedCatName = "$($script:catName)-Desktops"
            $null = Set-SnipeitCategory -id $script:createdCat.id -name $updatedCatName
            $cat = Get-SnipeitCategory -id $script:createdCat.id
            $cat.name | Should -Be $updatedCatName
        }
    }

    Context "Status Label Management" {
        BeforeAll {
            $script:statusName = "INT-Status-$($script:testTimestamp)"
            $script:createdStatus = New-SnipeitStatus -name $script:statusName -type "deployable"
        }

        AfterAll {
            if ($script:createdStatus -and $script:createdStatus.id) {
                Remove-SnipeitStatus -id $script:createdStatus.id -Confirm:$false
            }
        }

        It "Creates a new status label" {
            $script:createdStatus | Should -Not -BeNullOrEmpty
            $script:createdStatus.id | Should -BeGreaterThan 0
        }

        It "Retrieves status label by ID" {
            $status = Get-SnipeitStatus -id $script:createdStatus.id
            $status | Should -Not -BeNullOrEmpty
            $status.name | Should -Be $script:statusName
        }

        It "Updates status label details" {
            $updatedStatusName = "$($script:statusName)-Active"
            $null = Set-SnipeitStatus -id $script:createdStatus.id -name $updatedStatusName -type "deployable"
            $status = Get-SnipeitStatus -id $script:createdStatus.id
            $status.name | Should -Be $updatedStatusName
        }

        It "Retrieves assets associated with status label" {
            { Get-SnipeitStatusAsset -id $script:createdStatus.id } | Should -Not -Throw
        }
    }

    Context "Asset Model Management" {
        BeforeAll {
            $script:modelMfg = New-SnipeitManufacturer -name "INT-ModelMfg-$($script:testTimestamp)"
            $script:modelCat = New-SnipeitCategory -name "INT-ModelCat-$($script:testTimestamp)" -category_type "asset"
            $script:modelName = "INT-Model-$($script:testTimestamp)"
            $script:createdModel = New-SnipeitModel -name $script:modelName `
                -manufacturer_id $script:modelMfg.id `
                -category_id $script:modelCat.id
        }

        AfterAll {
            if ($script:createdModel -and $script:createdModel.id) {
                Remove-SnipeitModel -id $script:createdModel.id -Confirm:$false
            }
            if ($script:modelCat -and $script:modelCat.id) {
                Remove-SnipeitCategory -id $script:modelCat.id -Confirm:$false
            }
            if ($script:modelMfg -and $script:modelMfg.id) {
                Remove-SnipeitManufacturer -id $script:modelMfg.id -Confirm:$false
            }
        }

        It "Creates a new model with foreign key references" {
            $script:createdModel | Should -Not -BeNullOrEmpty
            $script:createdModel.id | Should -BeGreaterThan 0
        }

        It "Retrieves model by ID" {
            $model = Get-SnipeitModel -id $script:createdModel.id
            $model | Should -Not -BeNullOrEmpty
            $model.name | Should -Be $script:modelName
        }

        It "Updates model name and number" {
            $updatedModelName = "$($script:modelName)-Pro"
            $null = Set-SnipeitModel -id $script:createdModel.id -name $updatedModelName -model_number "MOD-101"
            $model = Get-SnipeitModel -id $script:createdModel.id
            $model.name | Should -Be $updatedModelName
            $model.model_number | Should -Be "MOD-101"
        }
    }
}
