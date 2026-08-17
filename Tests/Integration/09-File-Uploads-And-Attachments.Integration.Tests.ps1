BeforeAll {
    Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force
    $testUrl = $env:SNIPEIT_TEST_URL ?? 'http://192.168.1.47'
    $testKey = $env:SNIPEIT_TEST_KEY ?? 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMjk1OGM2ZWY2ZDU3ZTAxZWM4NmIxN2NjMGFlZjA1NGVkY2UwOThlMzllNzQ3MTZmMTE4NDhmMTdjNTVlYzc4ODFhMGNjMDE5ZDdiM2NiODYiLCJpYXQiOjE3ODY5MDkzNjIuNjQ5NDgzLCJuYmYiOjE3ODY5MDkzNjIuNjQ5NDksImV4cCI6MjQxODA2MTM2Mi42MjUwOTEsInN1YiI6IjEiLCJzY29wZXMiOltdfQ.E3MaayqG_D3GJ4vBMyQjNJG261xR6Gl5MtZrVLcpUL9hWoCdz7gq3-ModyV2t36JjXMiG2_z_-wNYkmJSTH-K8BKetGjAP9ofUXVieNZbrsqthZffGZV23AZwHnMPDTfXFzkC9xRn9Qf0T55gyHytCGEWl524Zg4EkvUkeGbGBhlvsZ0hJfMg3RpvU1ONtEqAAvLlu4nCJUNscqEltoAuVvqbFhn4oYS20M8o1VJTvdj36V_oP-5BEXWP-x6i5_v2WDk2EF8BItj2g3Q3XGDmX63n3mvXKKuO1xFpLp5zNZISJ1Xl8FWqszrFRnP4x2qz8aWQMeXI2_-hAc4bOjKDZuw_4YUEYB9CE3PHKVjdXQtDpTOsbRu6t-661lk75oOwZpR6dUe-3LB7vQ0tBblJgRNX9wNr7AV0fm1DmLctwkSEFzhW0KqbnzBi_iba8NAwRoZksISUHz9AaBOkcV_kTD1P8NCLl8BkZ8YDuxlLVac0lQmhVIbaOov84qLW3sP_bOhGi64EQXE3FEapNae8cMfSk5_bzQWV2_4vIxsWtpzMjHt7IWpFvb07W6KyjzcQSZKRkbBFJWGduhy9_LcERPh5Gu2izKBP7nRili41JDLsGQ_7Pt0vnBoxdwOMuJBZtph5ZFjHWtOdrDkpJ-pLjQnNiRGIYSGYHC9XfvFaR4'
    Connect-SnipeitPS -URL $testUrl -apiKey $testKey
    $script:testTimestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

    # Pre-requisite Category, Manufacturer, Model, Status, Asset
    $script:cat = New-SnipeitCategory -name "INT-FileCat-$($script:testTimestamp)" -category_type "asset"
    $script:mfg = New-SnipeitManufacturer -name "INT-FileMfg-$($script:testTimestamp)"
    $script:model = New-SnipeitModel -name "INT-FileModel-$($script:testTimestamp)" -category_id $script:cat.id -manufacturer_id $script:mfg.id
    $script:status = New-SnipeitStatus -name "INT-FileStatus-$($script:testTimestamp)" -type "deployable"
    $script:asset = New-SnipeitAsset -asset_tag "FILE-TAG-$($script:testTimestamp)" -model_id $script:model.id -status_id $script:status.id

    $script:tempUploadFile = Join-Path ([System.IO.Path]::GetTempPath()) "snipeit-test-$($script:testTimestamp).txt"
    "Integration Test File Content $(Get-Date)" | Out-File -FilePath $script:tempUploadFile -Encoding utf8
}

AfterAll {
    if (Test-Path $script:tempUploadFile) {
        Remove-Item -Path $script:tempUploadFile -Force -ErrorAction SilentlyContinue
    }
    if ($script:asset -and $script:asset.id) {
        Remove-SnipeitAsset -id $script:asset.id -Confirm:$false
    }
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
}

Describe "Live Snipe-IT Integration: File Uploads & Attachments" -Tag "Integration" {
    Context "Asset File Operations" {
        It "Uploads a file to an asset" {
            $upload = New-SnipeitAssetFile -id $script:asset.id -file $script:tempUploadFile -notes "Asset test attachment"
            $upload | Should -Not -BeNullOrEmpty
        }

        It "Retrieves files associated with the asset" {
            $files = Get-SnipeitAssetFile -id $script:asset.id
            $files | Should -Not -BeNullOrEmpty
            $script:assetFileId = ($files | Select-Object -First 1).id
            $script:assetFileId | Should -BeGreaterThan 0
        }

        It "Retrieves specific asset file by file_id" {
            $file = Get-SnipeitAssetFile -id $script:asset.id -file_id $script:assetFileId
            $file | Should -Not -BeNullOrEmpty
        }

        It "Deletes file from asset" {
            { Remove-SnipeitAssetFile -id $script:asset.id -file_id $script:assetFileId -Confirm:$false } | Should -Not -Throw
        }
    }

    Context "Model File Operations" {
        It "Uploads a file to a model" {
            $upload = New-SnipeitModelFile -id $script:model.id -file $script:tempUploadFile -notes "Model spec sheet"
            $upload | Should -Not -BeNullOrEmpty
        }

        It "Retrieves files associated with the model" {
            $files = Get-SnipeitModelFile -id $script:model.id
            $files | Should -Not -BeNullOrEmpty
            $script:modelFileId = ($files | Select-Object -First 1).id
            $script:modelFileId | Should -BeGreaterThan 0
        }

        It "Retrieves specific model file by file_id" {
            $file = Get-SnipeitModelFile -id $script:model.id -file_id $script:modelFileId
            $file | Should -Not -BeNullOrEmpty
        }

        It "Deletes file from model" {
            { Remove-SnipeitModelFile -id $script:model.id -file_id $script:modelFileId -Confirm:$false } | Should -Not -Throw
        }
    }
}
