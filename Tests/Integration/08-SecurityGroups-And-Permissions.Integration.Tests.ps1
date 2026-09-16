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

Describe "Live Snipe-IT Integration: Security Groups & Permissions" -Tag "Integration" {
    Context "Group Management Lifecycle" {
        BeforeAll {
            $script:groupName = "INT-Group-$($script:testTimestamp)"
            $script:createdGroup = New-SnipeitGroup -name $script:groupName `
                -permissions @{ 'admin' = '0'; 'reports.view' = '1' }
        }

        AfterAll {
            if ($script:createdGroup -and $script:createdGroup.id) {
                Remove-SnipeitGroup -id $script:createdGroup.id -Confirm:$false
            }
        }

        It "Creates a new security group" {
            $script:createdGroup | Should -Not -BeNullOrEmpty
            $script:createdGroup.id | Should -BeGreaterThan 0
        }

        It "Retrieves group by ID" {
            $group = Get-SnipeitGroup -id $script:createdGroup.id
            $group | Should -Not -BeNullOrEmpty
            $group.name | Should -Be $script:groupName
        }

        It "Updates group name and permissions" {
            $updatedGroupName = "$($script:groupName)-Upd"
            $null = Set-SnipeitGroup -id $script:createdGroup.id -name $updatedGroupName
            $group = Get-SnipeitGroup -id $script:createdGroup.id
            $group.name | Should -Be $updatedGroupName
        }
    }
}
