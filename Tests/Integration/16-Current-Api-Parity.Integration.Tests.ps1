Describe 'Live current API routes and re-audited collection parameters' -Tag 'Integration' {
    BeforeAll {
        if (-not $env:SNIPEIT_TEST_URL -or -not $env:SNIPEIT_TEST_KEY) { throw 'Integration tests require SNIPEIT_TEST_URL and SNIPEIT_TEST_KEY.' }
        Import-Module "$PSScriptRoot/../../SnipeitPS/SnipeitPS.psd1" -Force
        Connect-SnipeitPS -url $env:SNIPEIT_TEST_URL -apiKey $env:SNIPEIT_TEST_KEY
        $script:parityCurrentUser = Get-SnipeitCurrentUser -ErrorAction Stop
    }
    It 'reads the dedicated <Command> collection' -ForEach @(
        @{Command='Get-SnipeitCheckoutRequest';Collection='rows'}, @{Command='Get-SnipeitDashboardActivity';Collection='rows'},
        @{Command='Get-SnipeitLowStockItem';Collection='rows'}, @{Command='Get-SnipeitCalendarEvent';Collection='events'}
    ) {
        $response = & $Command -PreserveResponse -ErrorAction Stop
        $response.PSObject.Properties.Name | Should -Contain 'total'
        [int]$response.total | Should -BeGreaterOrEqual 0
        $response.PSObject.Properties.Name | Should -Contain $Collection
    }
    It 'reads the <By> dashboard summary' -ForEach @(@{By='Category'},@{By='Company'},@{By='Location'}) {
        $response = Get-SnipeitDashboardSummary -By $By -PreserveResponse -ErrorAction Stop
        $response.PSObject.Properties.Name | Should -Contain 'total'
        [int]$response.total | Should -BeGreaterOrEqual 0
        $response.PSObject.Properties.Name | Should -Contain 'rows'
    }
    It 'reads requestable <Type> inventory' -ForEach @(
        @{Type='Model'},@{Type='Accessory'},@{Type='Consumable'},@{Type='Component'},@{Type='License'}
    ) {
        $response = Get-SnipeitRequestableItem -Type $Type -PreserveResponse -ErrorAction Stop
        $response.PSObject.Properties.Name | Should -Contain 'total'
        [int]$response.total | Should -BeGreaterOrEqual 0
        $response.PSObject.Properties.Name | Should -Contain 'rows'
    }
    It 'sends the past_eol filter to all shared asset collection handlers' {
        { Get-SnipeitAsset -past_eol $true -ErrorAction Stop | Out-Null } | Should -Not -Throw
        { Get-SnipeitAssetDue -Action Audit -Status Due -past_eol $true -ErrorAction Stop | Out-Null } | Should -Not -Throw
        { Get-SnipeitDepreciationReport -past_eol $true -ErrorAction Stop | Out-Null } | Should -Not -Throw
    }
    It 'reads requestable accessories and filters assigned asset select lists' {
        { Get-SnipeitAccessory -requestable $true -ErrorAction Stop | Out-Null } | Should -Not -Throw
        $response = Get-SnipeitSelectList -EntityType Asset -assignedTo $script:parityCurrentUser.id -preserveResponse -ErrorAction Stop
        $response.PSObject.Properties.Name | Should -Contain 'results'
        $response.PSObject.Properties.Name | Should -Contain 'pagination'
    }
    It 'excludes actual location IDs from the location select list' {
        $before = Get-SnipeitSelectList -EntityType Location -preserveResponse -ErrorAction Stop
        if (@($before.results).Count -gt 0) {
            $ids = @($before.results | ForEach-Object { [int]$_.id })
            $after = Get-SnipeitSelectList -EntityType Location -excludeIds $ids -preserveResponse -ErrorAction Stop
            foreach ($row in $after.results) { [int]$row.id | Should -Not -BeIn $ids }
        } else {
            $after = Get-SnipeitSelectList -EntityType Location -excludeIds ([int]::MaxValue) -preserveResponse -ErrorAction Stop
            $after.PSObject.Properties.Name | Should -Contain 'results'
        }
    }
    It 'reads user assignment searches and the user consumable endpoint' {
        { Get-SnipeitUserAccessory -id $script:parityCurrentUser.id -search 'parity-no-match-20261002' -sort name -order asc -ErrorAction Stop | Out-Null } | Should -Not -Throw
        { Get-SnipeitUserLicense -id $script:parityCurrentUser.id -search 'parity-no-match-20261002' -sort created_at -order desc -ErrorAction Stop | Out-Null } | Should -Not -Throw
        { Get-SnipeitUserConsumable -id $script:parityCurrentUser.id -ErrorAction Stop | Out-Null } | Should -Not -Throw
    }
}
