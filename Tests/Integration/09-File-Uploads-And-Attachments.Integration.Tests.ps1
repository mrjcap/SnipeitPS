$script:uploadTestsSupported = $PSVersionTable.PSVersion.Major -ge 7

Describe "Live Snipe-IT Integration: File Uploads & Attachments" -Tag "Integration" -Skip:(-not $script:uploadTestsSupported) {
    BeforeAll {
        Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force
        $testUrl = $env:SNIPEIT_TEST_URL
        $testKey = $env:SNIPEIT_TEST_KEY
        if ([string]::IsNullOrWhiteSpace($testUrl) -or [string]::IsNullOrWhiteSpace($testKey)) {
            throw "Integration tests require SNIPEIT_TEST_URL and SNIPEIT_TEST_KEY environment variables."
        }
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
