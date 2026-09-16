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
