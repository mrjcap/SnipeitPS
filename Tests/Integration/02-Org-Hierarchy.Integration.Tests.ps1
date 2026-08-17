BeforeAll {
    Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force
    $testUrl = $env:SNIPEIT_TEST_URL ?? 'http://192.168.1.47'
    $testKey = $env:SNIPEIT_TEST_KEY ?? 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMjk1OGM2ZWY2ZDU3ZTAxZWM4NmIxN2NjMGFlZjA1NGVkY2UwOThlMzllNzQ3MTZmMTE4NDhmMTdjNTVlYzc4ODFhMGNjMDE5ZDdiM2NiODYiLCJpYXQiOjE3ODY5MDkzNjIuNjQ5NDgzLCJuYmYiOjE3ODY5MDkzNjIuNjQ5NDksImV4cCI6MjQxODA2MTM2Mi42MjUwOTEsInN1YiI6IjEiLCJzY29wZXMiOltdfQ.E3MaayqG_D3GJ4vBMyQjNJG261xR6Gl5MtZrVLcpUL9hWoCdz7gq3-ModyV2t36JjXMiG2_z_-wNYkmJSTH-K8BKetGjAP9ofUXVieNZbrsqthZffGZV23AZwHnMPDTfXFzkC9xRn9Qf0T55gyHytCGEWl524Zg4EkvUkeGbGBhlvsZ0hJfMg3RpvU1ONtEqAAvLlu4nCJUNscqEltoAuVvqbFhn4oYS20M8o1VJTvdj36V_oP-5BEXWP-x6i5_v2WDk2EF8BItj2g3Q3XGDmX63n3mvXKKuO1xFpLp5zNZISJ1Xl8FWqszrFRnP4x2qz8aWQMeXI2_-hAc4bOjKDZuw_4YUEYB9CE3PHKVjdXQtDpTOsbRu6t-661lk75oOwZpR6dUe-3LB7vQ0tBblJgRNX9wNr7AV0fm1DmLctwkSEFzhW0KqbnzBi_iba8NAwRoZksISUHz9AaBOkcV_kTD1P8NCLl8BkZ8YDuxlLVac0lQmhVIbaOov84qLW3sP_bOhGi64EQXE3FEapNae8cMfSk5_bzQWV2_4vIxsWtpzMjHt7IWpFvb07W6KyjzcQSZKRkbBFJWGduhy9_LcERPh5Gu2izKBP7nRili41JDLsGQ_7Pt0vnBoxdwOMuJBZtph5ZFjHWtOdrDkpJ-pLjQnNiRGIYSGYHC9XfvFaR4'
    Connect-SnipeitPS -URL $testUrl -apiKey $testKey
    $script:testTimestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
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
                -username $script:userUname -email $script:userEmail -password "TestingPassword123!"
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
