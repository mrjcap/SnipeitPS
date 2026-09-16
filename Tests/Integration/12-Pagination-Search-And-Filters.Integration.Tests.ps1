BeforeAll {
    Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force
    $testUrl = $env:SNIPEIT_TEST_URL
    $testKey = $env:SNIPEIT_TEST_KEY
    if ([string]::IsNullOrWhiteSpace($testUrl) -or [string]::IsNullOrWhiteSpace($testKey)) {
        throw "Integration tests require SNIPEIT_TEST_URL and SNIPEIT_TEST_KEY environment variables."
    }
    Connect-SnipeitPS -URL $testUrl -apiKey $testKey
    $script:testTimestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

    # Pre-requisite Category, Manufacturer, Model, Status
    $script:pgCat = New-SnipeitCategory -name "INT-PgCat-$($script:testTimestamp)" -category_type "asset"
    $script:pgMfg = New-SnipeitManufacturer -name "INT-PgMfg-$($script:testTimestamp)"
    $script:pgStatus = New-SnipeitStatus -name "INT-PgStatus-$($script:testTimestamp)" -type "deployable"
    $script:pgModel = New-SnipeitModel -name "INT-PgModel-$($script:testTimestamp)" -category_id $script:pgCat.id -manufacturer_id $script:pgMfg.id

    # Create 3 assets for pagination & search
    $script:createdAssets = @()
    1..3 | ForEach-Object {
        $script:createdAssets += New-SnipeitAsset -asset_tag "PG-TAG-$($script:testTimestamp)-$_" `
            -name "Pagination Test Asset $_" `
            -model_id $script:pgModel.id `
            -status_id $script:pgStatus.id
    }
}

AfterAll {
    foreach ($ast in $script:createdAssets) {
        if ($ast -and $ast.id) {
            Remove-SnipeitAsset -id $ast.id -Confirm:$false
        }
    }
    if ($script:pgModel -and $script:pgModel.id) {
        Remove-SnipeitModel -id $script:pgModel.id -Confirm:$false
    }
    if ($script:pgStatus -and $script:pgStatus.id) {
        Remove-SnipeitStatus -id $script:pgStatus.id -Confirm:$false
    }
    if ($script:pgMfg -and $script:pgMfg.id) {
        Remove-SnipeitManufacturer -id $script:pgMfg.id -Confirm:$false
    }
    if ($script:pgCat -and $script:pgCat.id) {
        Remove-SnipeitCategory -id $script:pgCat.id -Confirm:$false
    }
}

Describe "Live Snipe-IT Integration: Pagination, Sorting, Search & Filters" -Tag "Integration" {
    Context "Pagination Parameter Combinations" {
        It "Retrieves assets using -limit and -offset" {
            $page1 = Get-SnipeitAsset -limit 2 -offset 0
            $page1 | Should -Not -BeNullOrEmpty
            @($page1).Count | Should -BeLessOrEqual 2
        }

        It "Retrieves all items using -all switch" {
            $allAssets = Get-SnipeitAsset -all -limit 5
            $allAssets | Should -Not -BeNullOrEmpty
            @($allAssets).Count | Should -BeGreaterOrEqual 3
        }
    }

    Context "Search and Filter Combinations" {
        It "Searches assets by text query" {
            $searchResult = Get-SnipeitAsset -search "PG-TAG-$($script:testTimestamp)-1"
            $searchResult | Should -Not -BeNullOrEmpty
            ($searchResult | Select-Object -First 1).asset_tag | Should -Be "PG-TAG-$($script:testTimestamp)-1"
        }

        It "Filters assets with sorting and order parameters" {
            $sortedDesc = Get-SnipeitAsset -sort "created_at" -order "desc" -limit 3
            $sortedDesc | Should -Not -BeNullOrEmpty

            $sortedAsc = Get-SnipeitAsset -sort "created_at" -order "asc" -limit 3
            $sortedAsc | Should -Not -BeNullOrEmpty
        }
    }

    Context "Pipeline Input Handling" {
        It "Accepts IDs from pipeline by property name" {
            $targetAsset = $script:createdAssets | Select-Object -First 1
            $targetAsset | Should -Not -BeNullOrEmpty
            $pipelinedAsset = [PSCustomObject]@{ id = $targetAsset.id } | Get-SnipeitAsset
            $pipelinedAsset | Should -Not -BeNullOrEmpty
            $pipelinedAsset.id | Should -Be $targetAsset.id
        }
    }
}
