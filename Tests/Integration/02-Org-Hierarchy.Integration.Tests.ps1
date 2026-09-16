BeforeAll {
    Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force
    $testUrl = $env:SNIPEIT_TEST_URL
    $testKey = $env:SNIPEIT_TEST_KEY
    if ([string]::IsNullOrWhiteSpace($testUrl) -or [string]::IsNullOrWhiteSpace($testKey)) {
        throw "Integration tests require SNIPEIT_TEST_URL and SNIPEIT_TEST_KEY environment variables."
    }
    Connect-SnipeitPS -URL $testUrl -apiKey $testKey
    $script:testTimestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $passwordBytes = [byte[]]::new(24)
    $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
    try {
        $rng.GetBytes($passwordBytes)
    } finally {
        $rng.Dispose()
    }
    $script:testPassword = [Convert]::ToBase64String($passwordBytes)
}

Describe "Live Snipe-IT Integration: Organization Hierarchy" -Tag "Integration" {
    Context "Company Management" {
        BeforeAll {
            $script:companyName = "INT-Company-$($script:testTimestamp)"
            $script:createdCompany = New-SnipeitCompany -name $script:companyName
        }

        AfterAll {
            if ($script:createdCompany -and $script:createdCompany.id) {
                Remove-SnipeitCompany -id $script:createdCompany.id -Confirm:$false
            }
        }

        It "Creates a new company" {
            $script:createdCompany | Should -Not -BeNullOrEmpty
            $script:createdCompany.id | Should -BeGreaterThan 0
        }

        It "Retrieves company by ID" {
            $comp = Get-SnipeitCompany -id $script:createdCompany.id
            $comp | Should -Not -BeNullOrEmpty
            $comp.name | Should -Be $script:companyName
        }

        It "Updates company name" {
            $updatedName = "$($script:companyName)-Updated"
            $null = Set-SnipeitCompany -id $script:createdCompany.id -name $updatedName
            $comp = Get-SnipeitCompany -id $script:createdCompany.id
            $comp.name | Should -Be $updatedName
        }
    }

    Context "Location Management" {
        BeforeAll {
            $script:locName = "INT-Location-$($script:testTimestamp)"
            $script:createdLoc = New-SnipeitLocation -name $script:locName -city "Thessaloniki" -country "GR"
        }

        AfterAll {
            if ($script:createdLoc -and $script:createdLoc.id) {
                Remove-SnipeitLocation -id $script:createdLoc.id -Confirm:$false
            }
        }

        It "Creates a new location" {
            $script:createdLoc | Should -Not -BeNullOrEmpty
            $script:createdLoc.id | Should -BeGreaterThan 0
        }

        It "Retrieves location by ID" {
            $loc = Get-SnipeitLocation -id $script:createdLoc.id
            $loc | Should -Not -BeNullOrEmpty
            $loc.name | Should -Be $script:locName
            $loc.city | Should -Be "Thessaloniki"
        }

        It "Updates location details" {
            $null = Set-SnipeitLocation -id $script:createdLoc.id -city "Athens"
            $loc = Get-SnipeitLocation -id $script:createdLoc.id
            $loc.city | Should -Be "Athens"
        }
    }

    Context "Department Management" {
        BeforeAll {
            $script:deptName = "INT-Dept-$($script:testTimestamp)"
            $script:createdDept = New-SnipeitDepartment -name $script:deptName
        }

        AfterAll {
            if ($script:createdDept -and $script:createdDept.id) {
                Remove-SnipeitDepartment -id $script:createdDept.id -Confirm:$false
            }
        }

        It "Creates a new department" {
            $script:createdDept | Should -Not -BeNullOrEmpty
            $script:createdDept.id | Should -BeGreaterThan 0
        }

        It "Retrieves department by ID" {
            $dept = Get-SnipeitDepartment -id $script:createdDept.id
            $dept | Should -Not -BeNullOrEmpty
            $dept.name | Should -Be $script:deptName
        }

        It "Updates department details" {
            $updatedDeptName = "$($script:deptName)-Dev"
            $null = Set-SnipeitDepartment -id $script:createdDept.id -name $updatedDeptName
            $dept = Get-SnipeitDepartment -id $script:createdDept.id
            $dept.name | Should -Be $updatedDeptName
        }
    }

    Context "User Management" {
        BeforeAll {
            $script:userUname = "intuser$($script:testTimestamp)"
            $script:userEmail = "$script:userUname@example.com"
            $script:createdUser = New-SnipeitUser -first_name "Integration" -last_name "Test" `
                -username $script:userUname -email $script:userEmail -password $script:testPassword
        }

        AfterAll {
            if ($script:createdUser -and $script:createdUser.id) {
                Remove-SnipeitUser -id $script:createdUser.id -Confirm:$false
            }
        }

        It "Creates a new user" {
            $script:createdUser | Should -Not -BeNullOrEmpty
            $script:createdUser.id | Should -BeGreaterThan 0
        }

        It "Retrieves user by ID" {
            $u = Get-SnipeitUser -id $script:createdUser.id
            $u | Should -Not -BeNullOrEmpty
            $u.username | Should -Be $script:userUname
            $u.email | Should -Be $script:userEmail
        }

        It "Updates user job title and details" {
            $null = Set-SnipeitUser -id $script:createdUser.id -jobtitle "Senior QA Lead"
            $u = Get-SnipeitUser -id $script:createdUser.id
            $u.jobtitle | Should -Be "Senior QA Lead"
        }
    }
}
