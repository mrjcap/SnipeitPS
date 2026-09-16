BeforeAll {
    Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force
    $testUrl = $env:SNIPEIT_TEST_URL
    $testKey = $env:SNIPEIT_TEST_KEY
    if ([string]::IsNullOrWhiteSpace($testUrl) -or [string]::IsNullOrWhiteSpace($testKey)) {
        throw "Integration tests require SNIPEIT_TEST_URL and SNIPEIT_TEST_KEY environment variables."
    }
    Connect-SnipeitPS -URL $testUrl -apiKey $testKey
}

Describe "Live Snipe-IT Integration: Auth & System Info" -Tag "Integration" {
    It "Successfully retrieves current authenticated admin user" {
        $user = Get-SnipeitCurrentUser
        $user | Should -Not -BeNullOrEmpty
        $user.username | Should -Be "admin"
        $user.role | Should -Be "superadmin"
        $user.activated | Should -Be $true
    }

    It "Successfully retrieves API / system version info" {
        $version = Get-SnipeitVersion
        $version | Should -Not -BeNullOrEmpty
        $version.version | Should -Match "v8\."
    }

    It "Successfully retrieves system activity audit log" {
        $activities = Get-SnipeitActivity
        $activities | Should -Not -BeNullOrEmpty
        $activities.Count | Should -BeGreaterThan 0
    }

    It "Executes Get-SnipeitSetting gracefully" {
        { Get-SnipeitSetting -ErrorAction SilentlyContinue } | Should -Not -Throw
    }
}
