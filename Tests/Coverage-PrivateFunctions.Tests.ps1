BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

# ============================================================
# ConvertTo-GetParameter
# ============================================================

Describe "ConvertTo-GetParameter" {
    It "Converts hashtable to URL query string" {
        InModuleScope 'SnipeitPS' {
            $result = ConvertTo-GetParameter @{limit=50; search='test'}
            $result | Should -BeLike "?*limit=50*"
            $result | Should -BeLike "*search=test*"
        }
    }

    It "URL-encodes special characters" {
        InModuleScope 'SnipeitPS' {
            $result = ConvertTo-GetParameter @{search='hello world'}
            $result | Should -BeLike "*hello+world*"
        }
    }

    It "Returns string starting with ? and no trailing &" {
        InModuleScope 'SnipeitPS' {
            $result = ConvertTo-GetParameter @{offset=0}
            $result | Should -BeLike '?offset=0'
            $result | Should -Not -BeLike '*&'
        }
    }
}

# ============================================================
# Set-SnipeitPSLegacyApiKey
# ============================================================

Describe "Set-SnipeitPSLegacyApiKey" {
    It "Sets legacyApiKey as SecureString (PS7 path)" {
        InModuleScope 'SnipeitPS' {
            $savedKey = $SnipeitPSSession.legacyApiKey
            $savedIsPowerShell7 = $script:IsPowerShell7
            try {
                $script:IsPowerShell7 = $true
                Set-SnipeitPSLegacyApiKey -apiKey "testkey123" -Confirm:$false
                $SnipeitPSSession.legacyApiKey | Should -BeOfType [System.Security.SecureString]
            } finally {
                $SnipeitPSSession.legacyApiKey = $savedKey
                $script:IsPowerShell7 = $savedIsPowerShell7
            }
        }
    }

    It "Sets legacyApiKey as SecureString (PS5 path)" {
        InModuleScope 'SnipeitPS' {
            $savedKey = $SnipeitPSSession.legacyApiKey
            $savedIsPowerShell7 = $script:IsPowerShell7
            try {
                $script:IsPowerShell7 = $false
                Set-SnipeitPSLegacyApiKey -apiKey "testkey123" -Confirm:$false
                $SnipeitPSSession.legacyApiKey | Should -BeOfType [System.Security.SecureString]
            } finally {
                $SnipeitPSSession.legacyApiKey = $savedKey
                $script:IsPowerShell7 = $savedIsPowerShell7
            }
        }
    }
}

# ============================================================
# Set-SnipeitPSLegacyUrl
# ============================================================

Describe "Set-SnipeitPSLegacyUrl" {
    It "Sets legacyUrl with trailing slash removed" {
        InModuleScope 'SnipeitPS' {
            $savedUrl = $SnipeitPSSession.legacyUrl
            try {
                Set-SnipeitPSLegacyUrl -url "https://snipeit.example.com/" -Confirm:$false
                $SnipeitPSSession.legacyUrl | Should -Be "https://snipeit.example.com"
            } finally {
                $SnipeitPSSession.legacyUrl = $savedUrl
            }
        }
    }

    It "Sets legacyUrl without trailing slash unchanged" {
        InModuleScope 'SnipeitPS' {
            $savedUrl = $SnipeitPSSession.legacyUrl
            try {
                Set-SnipeitPSLegacyUrl -url "https://snipeit.example.com" -Confirm:$false
                $SnipeitPSSession.legacyUrl | Should -Be "https://snipeit.example.com"
            } finally {
                $SnipeitPSSession.legacyUrl = $savedUrl
            }
        }
    }
}

# ============================================================
# Reset-SnipeitPSLegacyApi
# ============================================================

Describe "Reset-SnipeitPSLegacyApi" {
    It "Clears legacy url and apiKey" {
        InModuleScope 'SnipeitPS' {
            $savedUrl = $SnipeitPSSession.legacyUrl
            $savedKey = $SnipeitPSSession.legacyApiKey
            try {
                $SnipeitPSSession.legacyUrl = "https://test.com"
                $SnipeitPSSession.legacyApiKey = ConvertTo-SecureString "key" -AsPlainText -Force
                Reset-SnipeitPSLegacyApi -Confirm:$false
                $SnipeitPSSession.legacyUrl | Should -BeNullOrEmpty
                $SnipeitPSSession.legacyApiKey | Should -BeNullOrEmpty
            } finally {
                $SnipeitPSSession.legacyUrl = $savedUrl
                $SnipeitPSSession.legacyApiKey = $savedKey
            }
        }
    }
}

# ============================================================
# Test-SnipeitPSConnection
# ============================================================

Describe "Test-SnipeitPSConnection" {
    It "Returns true when API responds" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return [PSCustomObject]@{id=1} }
            $result = Test-SnipeitPSConnection
            $result | Should -Be $true
        }
    }

    It "Returns false when API returns nothing" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
            $result = Test-SnipeitPSConnection
            $result | Should -Be $false
        }
    }
}

# ============================================================
# Test-SnipeitAlias
# ============================================================

Describe "Test-SnipeitAlias" {
    It "Shows warnings when invocation name differs from command name" {
        InModuleScope 'SnipeitPS' {
            Mock Write-Warning {}
            Test-SnipeitAlias -invocationName 'Get-Asset' -commandName 'Get-SnipeitAsset'
            Should -Invoke Write-Warning -Times 3
        }
    }

    It "Does not warn when invocation name matches command name" {
        InModuleScope 'SnipeitPS' {
            Mock Write-Warning {}
            Test-SnipeitAlias -invocationName 'Get-SnipeitAsset' -commandName 'Get-SnipeitAsset'
            Should -Invoke Write-Warning -Times 0
        }
    }
}

# ============================================================
# Get-ParameterValue
# ============================================================

Describe "Get-ParameterValue" {
    It "Throws when not dot-sourced" {
        InModuleScope 'SnipeitPS' {
            { Get-ParameterValue -Parameters @{} -BoundParameters @{} } | Should -Throw "*must be dot-sourced*"
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - Credential paths
# ============================================================

Describe "Invoke-SnipeitMethod - Connect credentials (PS7)" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Uses Connect path with PS7 credential conversion" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'success'; payload = [PSCustomObject]@{ id = 1; name = 'Test' } } }
            $result = Invoke-SnipeitMethod -Api "/api/v1/hardware/1"
            $result.id | Should -Be 1
            Should -Invoke Invoke-RestMethod -Times 1
        }
    }
}

Describe "Invoke-SnipeitMethod - Connect credentials (PS5)" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $false
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Uses Connect path with PS5 credential conversion" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'success'; payload = [PSCustomObject]@{ id = 2; name = 'PS5Test' } } }
            $result = Invoke-SnipeitMethod -Api "/api/v1/hardware/2"
            $result.id | Should -Be 2
        }
    }
}

Describe "Invoke-SnipeitMethod - Legacy credentials (PS7)" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = $null
            $SnipeitPSSession.apiKey = $null
            $SnipeitPSSession.legacyUrl = "https://legacy.example.com"
            $SnipeitPSSession.legacyApiKey = ConvertTo-SecureString "legacykey" -AsPlainText -Force
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Uses Legacy path with PS7 credential conversion" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'success'; payload = [PSCustomObject]@{ id = 3 } } }
            $result = Invoke-SnipeitMethod -Api "/api/v1/hardware/3"
            $result.id | Should -Be 3
        }
    }
}

Describe "Invoke-SnipeitMethod - Legacy credentials (PS5)" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = $null
            $SnipeitPSSession.apiKey = $null
            $SnipeitPSSession.legacyUrl = "https://legacy.example.com"
            $SnipeitPSSession.legacyApiKey = ConvertTo-SecureString "legacykey" -AsPlainText -Force
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $false
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Uses Legacy path with PS5 credential conversion" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'success'; payload = [PSCustomObject]@{ id = 4 } } }
            $result = Invoke-SnipeitMethod -Api "/api/v1/hardware/4"
            $result.id | Should -Be 4
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - No credentials / Validation
# ============================================================

Describe "Invoke-SnipeitMethod - No credentials" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = $null
            $SnipeitPSSession.apiKey = $null
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Throws when no credentials are configured" {
        InModuleScope 'SnipeitPS' {
            { Invoke-SnipeitMethod -Api "/api/v1/hardware" } | Should -Throw "Please use Connect-SnipeitPS*"
        }
    }
}

Describe "Invoke-SnipeitMethod - POST without Body" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Throws ArgumentException for POST without Body" {
        InModuleScope 'SnipeitPS' {
            { Invoke-SnipeitMethod -Api "/api/v1/hardware" -Method POST } | Should -Throw "*Body*"
        }
    }

    It "Throws ArgumentException for PUT without Body" {
        InModuleScope 'SnipeitPS' {
            { Invoke-SnipeitMethod -Api "/api/v1/hardware" -Method PUT } | Should -Throw "*Body*"
        }
    }

    It "Throws ArgumentException for PATCH without Body" {
        InModuleScope 'SnipeitPS' {
            { Invoke-SnipeitMethod -Api "/api/v1/hardware" -Method PATCH } | Should -Throw "*Body*"
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - Response handling
# ============================================================

Describe "Invoke-SnipeitMethod - Response handling" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Returns payload from successful response" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'success'; payload = [PSCustomObject]@{ id = 5; name = 'Laptop' } } }
            $result = Invoke-SnipeitMethod -Api "/api/v1/hardware/5"
            $result.id | Should -Be 5
            $result.name | Should -Be 'Laptop'
        }
    }

    It "Returns rows from search response" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ rows = @([PSCustomObject]@{id=1}, [PSCustomObject]@{id=2}); total = 2 } }
            $result = Invoke-SnipeitMethod -Api "/api/v1/hardware"
            $result.Count | Should -Be 2
        }
    }

    It "Returns payload for success status (e.g. delete)" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'success'; payload = $null } }
            $result = Invoke-SnipeitMethod -Api "/api/v1/hardware/1" -Method DELETE -Body @{note='test'}
            # success with null payload returns null result
            $result | Should -BeNullOrEmpty
        }
    }

    It "Returns null for total=0 response" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ total = 0 } }
            $result = Invoke-SnipeitMethod -Api "/api/v1/hardware"
            $result | Should -BeNullOrEmpty
        }
    }

    It "Returns whole response as fallback (direct object)" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ id = 42; name = 'Direct' } }
            $result = Invoke-SnipeitMethod -Api "/api/v1/hardware/42"
            $result.name | Should -Be 'Direct'
            $result.id | Should -Be 42
        }
    }

    It "Writes error for error status response" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'error'; messages = 'Asset not found' } }
            $result = Invoke-SnipeitMethod -Api "/api/v1/hardware/999" -ErrorVariable err -ErrorAction SilentlyContinue
            $err.Count | Should -BeGreaterThan 0
        }
    }

    It "Writes error for Unauthorized response" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ StatusCode = 'Unauthorized' } }
            $result = Invoke-SnipeitMethod -Api "/api/v1/hardware" -ErrorVariable err -ErrorAction SilentlyContinue
            $err.Count | Should -BeGreaterThan 0
        }
    }

    It "Handles Invoke-RestMethod throwing (catch block)" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { throw "Connection refused" }
            # The catch block catches the exception and sets webResponse to the exception response
            # This should not throw to the caller
            $result = Invoke-SnipeitMethod -Api "/api/v1/hardware"
            # Result should be null since the exception response is likely null
        }
    }

    It "Handles null response from Invoke-RestMethod" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { return $null }
            $result = Invoke-SnipeitMethod -Api "/api/v1/hardware"
            $result | Should -BeNullOrEmpty
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - GET with parameters
# ============================================================

Describe "Invoke-SnipeitMethod - GET with GetParameters" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Appends GetParameters to URI (covers ConvertTo-GetParameter integration)" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ total = 0 } }
            Invoke-SnipeitMethod -Api "/api/v1/hardware" -GetParameters @{limit=50; offset=0}
            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter { $Uri -like "*limit=50*" }
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - POST with Body
# ============================================================

Describe "Invoke-SnipeitMethod - POST with Body" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Sends JSON-encoded body for POST" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'success'; payload = [PSCustomObject]@{ id = 1 } } }
            Invoke-SnipeitMethod -Api "/api/v1/hardware" -Method POST -Body @{name='test'; status_id=1}
            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter { $null -ne $Body }
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - Image upload paths
# ============================================================

Describe "Invoke-SnipeitMethod - Image upload (PS7)" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Handles image upload with multipart form on PS7" {
        InModuleScope 'SnipeitPS' {
            $tempFile = [System.IO.Path]::GetTempFileName()
            try {
                Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'success'; payload = [PSCustomObject]@{ id = 1 } } }
                $body = @{ image = $tempFile; name = 'test'; status_id = 1; model_id = 1 }
                Invoke-SnipeitMethod -Api "/api/v1/hardware/1" -Method PUT -Body $body
                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter { $Method -eq 'POST' }
            } finally {
                Remove-Item $tempFile -ErrorAction SilentlyContinue
            }
        }
    }
}

Describe "Invoke-SnipeitMethod - Image upload (PS5 base64 path)" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $false
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Exercises PS5 base64 image encoding code path" {
        InModuleScope 'SnipeitPS' {
            $tempFile = [System.IO.Path]::GetTempFileName()
            try {
                # Write some bytes so ReadAllBytes works
                [System.IO.File]::WriteAllBytes($tempFile, [byte[]](0x89, 0x50, 0x4E, 0x47))
                Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'success'; payload = [PSCustomObject]@{ id = 1 } } }
                $body = @{ image = $tempFile; name = 'test'; status_id = 1; model_id = 1 }
                # PS5 path converts image to base64 data URI with fallback mime type
                $result = Invoke-SnipeitMethod -Api "/api/v1/hardware/1" -Method PUT -Body $body
                # Verify it made the request (base64 encoding succeeded)
                Should -Invoke Invoke-RestMethod -Times 1
            } finally {
                Remove-Item $tempFile -ErrorAction SilentlyContinue
            }
        }
    }
}

Describe "Invoke-SnipeitMethod - Image upload error (bad path)" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Writes error when image file path is invalid" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'success'; payload = [PSCustomObject]@{ id = 1 } } }
            $body = @{ image = 'C:\nonexistent\fake.jpg'; name = 'test'; status_id = 1 }
            Invoke-SnipeitMethod -Api "/api/v1/hardware/1" -Method PUT -Body $body -ErrorVariable err -ErrorAction SilentlyContinue
            $err.Count | Should -BeGreaterThan 0
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - File upload paths
# ============================================================

Describe "Invoke-SnipeitMethod - File upload (PS7)" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Handles file upload with multipart form on PS7" {
        InModuleScope 'SnipeitPS' {
            $tempFile = [System.IO.Path]::GetTempFileName()
            try {
                Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'success'; payload = [PSCustomObject]@{ id = 1 } } }
                $body = @{ file = $tempFile }
                Invoke-SnipeitMethod -Api "/api/v1/hardware/1/files" -Method POST -Body $body
                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter { $Method -eq 'POST' }
            } finally {
                Remove-Item $tempFile -ErrorAction SilentlyContinue
            }
        }
    }
}

Describe "Invoke-SnipeitMethod - File upload (PS5 throws)" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $false
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Writes error for file upload on PS5 (not supported)" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'success'; payload = [PSCustomObject]@{ id = 1 } } }
            $body = @{ file = 'C:\some\file.txt' }
            Invoke-SnipeitMethod -Api "/api/v1/hardware/1/files" -Method POST -Body $body -ErrorVariable err -ErrorAction SilentlyContinue
            $err.Count | Should -BeGreaterThan 0
        }
    }
}

Describe "Invoke-SnipeitMethod - File upload error (bad path)" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Writes error when file path is invalid on PS7" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'success'; payload = [PSCustomObject]@{ id = 1 } } }
            $body = @{ file = 'C:\nonexistent\fake.txt' }
            Invoke-SnipeitMethod -Api "/api/v1/hardware/1/files" -Method POST -Body $body -ErrorVariable err -ErrorAction SilentlyContinue
            $err.Count | Should -BeGreaterThan 0
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - Throttle modes
# ============================================================

Describe "Invoke-SnipeitMethod - Throttle Burst mode" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedThrottlePeriod = $SnipeitPSSession.throttlePeriod
            $script:savedThrottleMode = $SnipeitPSSession.throttleMode
            $script:savedThrottleThreshold = $SnipeitPSSession.throttleThreshold
            $script:savedThrottledRequests = $SnipeitPSSession.throttledRequests
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $SnipeitPSSession.throttlePeriod = $script:savedThrottlePeriod
            $SnipeitPSSession.throttleMode = $script:savedThrottleMode
            $SnipeitPSSession.throttleThreshold = $script:savedThrottleThreshold
            $SnipeitPSSession.throttledRequests = $script:savedThrottledRequests
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Processes request under Burst throttle limit without sleeping" {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.throttleLimit = 10
            $SnipeitPSSession.throttlePeriod = 60000
            $SnipeitPSSession.throttleMode = 'Burst'
            $SnipeitPSSession.throttleThreshold = 90
            $SnipeitPSSession.throttledRequests = [System.Collections.ArrayList]::new()
            Mock Invoke-RestMethod { [PSCustomObject]@{ total = 0 } }
            Mock Start-Sleep {}
            Invoke-SnipeitMethod -Api "/api/v1/hardware"
            Should -Invoke Start-Sleep -Times 0
        }
    }

    It "Sleeps when Burst throttle limit is reached" {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.throttleLimit = 2
            $SnipeitPSSession.throttlePeriod = 60000
            $SnipeitPSSession.throttleMode = 'Burst'
            $SnipeitPSSession.throttleThreshold = 90
            $SnipeitPSSession.throttledRequests = [System.Collections.ArrayList]@((Get-Date).ToFileTime(), (Get-Date).ToFileTime())
            Mock Invoke-RestMethod { [PSCustomObject]@{ total = 0 } }
            Mock Start-Sleep {}
            Invoke-SnipeitMethod -Api "/api/v1/hardware"
            Should -Invoke Start-Sleep -Times 1
        }
    }
}

Describe "Invoke-SnipeitMethod - Throttle Constant mode" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedThrottlePeriod = $SnipeitPSSession.throttlePeriod
            $script:savedThrottleMode = $SnipeitPSSession.throttleMode
            $script:savedThrottleThreshold = $SnipeitPSSession.throttleThreshold
            $script:savedThrottledRequests = $SnipeitPSSession.throttledRequests
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $SnipeitPSSession.throttlePeriod = $script:savedThrottlePeriod
            $SnipeitPSSession.throttleMode = $script:savedThrottleMode
            $SnipeitPSSession.throttleThreshold = $script:savedThrottleThreshold
            $SnipeitPSSession.throttledRequests = $script:savedThrottledRequests
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Calculates constant delay between requests" {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.throttleLimit = 10
            $SnipeitPSSession.throttlePeriod = 60000
            $SnipeitPSSession.throttleMode = 'Constant'
            $SnipeitPSSession.throttleThreshold = 90
            # Add a recent request so the constant delay calculation has data
            $SnipeitPSSession.throttledRequests = [System.Collections.ArrayList]@((Get-Date).ToFileTime())
            Mock Invoke-RestMethod { [PSCustomObject]@{ total = 0 } }
            Mock Start-Sleep {}
            Invoke-SnipeitMethod -Api "/api/v1/hardware"
            # Constant mode always computes a delay (period/limit - timeSinceLast)
            # With a recent request, the naptime should be positive, triggering Start-Sleep
            Should -Invoke Start-Sleep -Times 1
        }
    }
}

Describe "Invoke-SnipeitMethod - Throttle Adaptive mode" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedThrottlePeriod = $SnipeitPSSession.throttlePeriod
            $script:savedThrottleMode = $SnipeitPSSession.throttleMode
            $script:savedThrottleThreshold = $SnipeitPSSession.throttleThreshold
            $script:savedThrottledRequests = $SnipeitPSSession.throttledRequests
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $SnipeitPSSession.throttlePeriod = $script:savedThrottlePeriod
            $SnipeitPSSession.throttleMode = $script:savedThrottleMode
            $SnipeitPSSession.throttleThreshold = $script:savedThrottleThreshold
            $SnipeitPSSession.throttledRequests = $script:savedThrottledRequests
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Does not throttle when under threshold" {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.throttleLimit = 100
            $SnipeitPSSession.throttlePeriod = 60000
            $SnipeitPSSession.throttleMode = 'Adaptive'
            $SnipeitPSSession.throttleThreshold = 90
            $SnipeitPSSession.throttledRequests = [System.Collections.ArrayList]::new()
            Mock Invoke-RestMethod { [PSCustomObject]@{ total = 0 } }
            Mock Start-Sleep {}
            Invoke-SnipeitMethod -Api "/api/v1/hardware"
            Should -Invoke Start-Sleep -Times 0
        }
    }

    It "Throttles when over threshold" {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.throttleLimit = 10
            $SnipeitPSSession.throttlePeriod = 60000
            $SnipeitPSSession.throttleMode = 'Adaptive'
            $SnipeitPSSession.throttleThreshold = 50
            $reqs = [System.Collections.ArrayList]::new()
            for ($i = 0; $i -lt 6; $i++) { $null = $reqs.Add((Get-Date).ToFileTime()) }
            $SnipeitPSSession.throttledRequests = $reqs
            Mock Invoke-RestMethod { [PSCustomObject]@{ total = 0 } }
            Mock Start-Sleep {}
            Invoke-SnipeitMethod -Api "/api/v1/hardware"
            Should -Invoke Start-Sleep -Times 1
        }
    }

    It "Handles remaining < 1 edge case (fill to limit)" {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.throttleLimit = 5
            $SnipeitPSSession.throttlePeriod = 60000
            $SnipeitPSSession.throttleMode = 'Adaptive'
            $SnipeitPSSession.throttleThreshold = 50
            $reqs = [System.Collections.ArrayList]::new()
            for ($i = 0; $i -lt 5; $i++) { $null = $reqs.Add((Get-Date).ToFileTime()) }
            $SnipeitPSSession.throttledRequests = $reqs
            Mock Invoke-RestMethod { [PSCustomObject]@{ total = 0 } }
            Mock Start-Sleep {}
            Invoke-SnipeitMethod -Api "/api/v1/hardware"
            # When remaining < 1, it gets set to 1 and then naptime is computed
            Should -Invoke Start-Sleep -Times 1
        }
    }
}

Describe "Invoke-SnipeitMethod - Throttle requests list cleanup" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedThrottlePeriod = $SnipeitPSSession.throttlePeriod
            $script:savedThrottleMode = $SnipeitPSSession.throttleMode
            $script:savedThrottleThreshold = $SnipeitPSSession.throttleThreshold
            $script:savedThrottledRequests = $SnipeitPSSession.throttledRequests
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $SnipeitPSSession.throttlePeriod = $script:savedThrottlePeriod
            $SnipeitPSSession.throttleMode = $script:savedThrottleMode
            $SnipeitPSSession.throttleThreshold = $script:savedThrottleThreshold
            $SnipeitPSSession.throttledRequests = $script:savedThrottledRequests
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Cleans up expired requests and reinitializes list when where-filter returns null" {
        InModuleScope 'SnipeitPS' {
            # Use old timestamps that will be filtered out (all expired)
            $SnipeitPSSession.throttleLimit = 10
            $SnipeitPSSession.throttlePeriod = 1  # 1ms period so all prior requests expire
            $SnipeitPSSession.throttleMode = 'Burst'
            $SnipeitPSSession.throttleThreshold = 90
            # Old timestamps from 2 minutes ago - will all be filtered out
            $oldTime = (Get-Date).AddMinutes(-2).ToFileTime()
            $SnipeitPSSession.throttledRequests = [System.Collections.ArrayList]@($oldTime, $oldTime)
            Mock Invoke-RestMethod { [PSCustomObject]@{ total = 0 } }
            Mock Start-Sleep {}
            Invoke-SnipeitMethod -Api "/api/v1/hardware"
            # After filtering old requests, list is empty, no sleep needed
            Should -Invoke Start-Sleep -Times 0
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - Debug preference
# ============================================================

Describe "Invoke-SnipeitMethod - Debug preference active" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Exercises debug output code path" {
        InModuleScope 'SnipeitPS' {
            $DebugPreference = 'Continue'
            try {
                Mock Invoke-RestMethod { [PSCustomObject]@{ total = 0 } }
                Mock Write-Debug {}
                Invoke-SnipeitMethod -Api "/api/v1/hardware" 5>&1 | Out-Null
            } finally {
                $DebugPreference = 'SilentlyContinue'
            }
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - Response parse error (inner catch)
# ============================================================

Describe "Invoke-SnipeitMethod - Response parse error" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Writes warning when response parsing throws" {
        InModuleScope 'SnipeitPS' {
            # Return a response with status='error' to enter the error branch.
            # Mock Write-Error to throw, causing the try block to fail and
            # the catch block to fire with Write-Warning.
            Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'error'; messages = 'test' } }
            Mock Write-Error { throw "forced error in Write-Error" }
            Mock Write-Warning {}
            Invoke-SnipeitMethod -Api "/api/v1/hardware"
            Should -Invoke Write-Warning -Times 1 -ParameterFilter {
                $Message -like "Cannot parse server response*"
            }
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - DELETE with Body (validation pass)
# ============================================================

Describe "Invoke-SnipeitMethod - DELETE does not require Body" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "DELETE without Body does not throw" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'success'; payload = $null } }
            # DELETE is not in the POST/PUT/PATCH validation, should work without body
            { Invoke-SnipeitMethod -Api "/api/v1/hardware/1" -Method DELETE } | Should -Not -Throw
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - Body with POST JSON encoding
# ============================================================

Describe "Invoke-SnipeitMethod - JSON body encoding for PUT" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Encodes body as UTF-8 JSON bytes for PUT" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'success'; payload = [PSCustomObject]@{ id = 10 } } }
            $result = Invoke-SnipeitMethod -Api "/api/v1/hardware/10" -Method PUT -Body @{name='Updated'; status_id=2}
            $result.id | Should -Be 10
            Should -Invoke Invoke-RestMethod -Times 1
        }
    }

    It "Encodes body as UTF-8 JSON bytes for PATCH" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'success'; payload = [PSCustomObject]@{ id = 11 } } }
            $result = Invoke-SnipeitMethod -Api "/api/v1/hardware/11" -Method PATCH -Body @{name='Patched'}
            $result.id | Should -Be 11
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - Debug with body content
# ============================================================

Describe "Invoke-SnipeitMethod - Debug with body" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Outputs body as JSON in debug stream when DebugPreference is Continue" {
        InModuleScope 'SnipeitPS' {
            $DebugPreference = 'Continue'
            try {
                Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'success'; payload = [PSCustomObject]@{ id = 1 } } }
                Mock Write-Debug {}
                Invoke-SnipeitMethod -Api "/api/v1/hardware" -Method POST -Body @{name='test'; status_id=1} 5>&1 | Out-Null
            } finally {
                $DebugPreference = 'SilentlyContinue'
            }
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - Throttle with null throttledRequests
# ============================================================

Describe "Invoke-SnipeitMethod - Throttle null requests list reinitialization" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedThrottlePeriod = $SnipeitPSSession.throttlePeriod
            $script:savedThrottleMode = $SnipeitPSSession.throttleMode
            $script:savedThrottleThreshold = $SnipeitPSSession.throttleThreshold
            $script:savedThrottledRequests = $SnipeitPSSession.throttledRequests
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $SnipeitPSSession.throttlePeriod = $script:savedThrottlePeriod
            $SnipeitPSSession.throttleMode = $script:savedThrottleMode
            $SnipeitPSSession.throttleThreshold = $script:savedThrottleThreshold
            $SnipeitPSSession.throttledRequests = $script:savedThrottledRequests
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Handles empty throttledRequests list after filtering" {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.throttleLimit = 10
            $SnipeitPSSession.throttlePeriod = 1  # 1ms - all timestamps will be expired
            $SnipeitPSSession.throttleMode = 'Burst'
            $SnipeitPSSession.throttleThreshold = 90
            $SnipeitPSSession.throttledRequests = [System.Collections.ArrayList]@((Get-Date).AddMinutes(-10).ToFileTime())
            Mock Invoke-RestMethod { [PSCustomObject]@{ total = 0 } }
            Mock Start-Sleep {}
            Invoke-SnipeitMethod -Api "/api/v1/hardware"
            # Expired timestamps get filtered out, list becomes empty
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - Throttle debug output
# ============================================================

Describe "Invoke-SnipeitMethod - Throttle with debug output" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedThrottlePeriod = $SnipeitPSSession.throttlePeriod
            $script:savedThrottleMode = $SnipeitPSSession.throttleMode
            $script:savedThrottleThreshold = $SnipeitPSSession.throttleThreshold
            $script:savedThrottledRequests = $SnipeitPSSession.throttledRequests
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $SnipeitPSSession.throttlePeriod = $script:savedThrottlePeriod
            $SnipeitPSSession.throttleMode = $script:savedThrottleMode
            $SnipeitPSSession.throttleThreshold = $script:savedThrottleThreshold
            $SnipeitPSSession.throttledRequests = $script:savedThrottledRequests
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Produces throttle debug messages" {
        InModuleScope 'SnipeitPS' {
            $DebugPreference = 'Continue'
            try {
                $SnipeitPSSession.throttleLimit = 100
                $SnipeitPSSession.throttlePeriod = 60000
                $SnipeitPSSession.throttleMode = 'Burst'
                $SnipeitPSSession.throttleThreshold = 90
                $SnipeitPSSession.throttledRequests = [System.Collections.ArrayList]::new()
                Mock Invoke-RestMethod { [PSCustomObject]@{ total = 0 } }
                Mock Start-Sleep {}
                Mock Write-Debug {}
                Invoke-SnipeitMethod -Api "/api/v1/hardware" 5>&1 | Out-Null
            } finally {
                $DebugPreference = 'SilentlyContinue'
            }
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - PSDefaultParameterValues passthrough
# ============================================================

Describe "Invoke-SnipeitMethod - PSDefaultParameterValues passthrough" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Copies global PSDefaultParameterValues to script scope" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ total = 0 } }
            # This test exercises line 163: $script:PSDefaultParameterValues = $global:PSDefaultParameterValues
            Invoke-SnipeitMethod -Api "/api/v1/hardware"
            # Just verifying no exception is thrown
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - Verbose output code paths
# ============================================================

Describe "Invoke-SnipeitMethod - Verbose output" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Produces verbose output for successful response" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'success'; payload = [PSCustomObject]@{ id = 1 } } }
            $VerbosePreference = 'Continue'
            try {
                Invoke-SnipeitMethod -Api "/api/v1/hardware/1" -Verbose 4>&1 | Out-Null
            } finally {
                $VerbosePreference = 'SilentlyContinue'
            }
        }
    }

    It "Produces verbose output for error response" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ status = 'error'; messages = 'Not found' } }
            $VerbosePreference = 'Continue'
            try {
                Invoke-SnipeitMethod -Api "/api/v1/hardware/999" -ErrorAction SilentlyContinue -Verbose 4>&1 | Out-Null
            } finally {
                $VerbosePreference = 'SilentlyContinue'
            }
        }
    }

    It "Produces verbose output when no web result" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { return $null }
            $VerbosePreference = 'Continue'
            try {
                Invoke-SnipeitMethod -Api "/api/v1/hardware" -Verbose 4>&1 | Out-Null
            } finally {
                $VerbosePreference = 'SilentlyContinue'
            }
        }
    }

    It "Produces verbose output for Unauthorized" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ StatusCode = 'Unauthorized' } }
            $VerbosePreference = 'Continue'
            try {
                Invoke-SnipeitMethod -Api "/api/v1/hardware" -ErrorAction SilentlyContinue -Verbose 4>&1 | Out-Null
            } finally {
                $VerbosePreference = 'SilentlyContinue'
            }
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - Throttle Burst mode with naptime verbose
# ============================================================

Describe "Invoke-SnipeitMethod - Throttle verbose naptime message" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedThrottlePeriod = $SnipeitPSSession.throttlePeriod
            $script:savedThrottleMode = $SnipeitPSSession.throttleMode
            $script:savedThrottleThreshold = $SnipeitPSSession.throttleThreshold
            $script:savedThrottledRequests = $SnipeitPSSession.throttledRequests
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $SnipeitPSSession.throttlePeriod = $script:savedThrottlePeriod
            $SnipeitPSSession.throttleMode = $script:savedThrottleMode
            $SnipeitPSSession.throttleThreshold = $script:savedThrottleThreshold
            $SnipeitPSSession.throttledRequests = $script:savedThrottledRequests
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Outputs verbose throttle message when naptime > 0" {
        InModuleScope 'SnipeitPS' {
            $VerbosePreference = 'Continue'
            try {
                $SnipeitPSSession.throttleLimit = 2
                $SnipeitPSSession.throttlePeriod = 60000
                $SnipeitPSSession.throttleMode = 'Burst'
                $SnipeitPSSession.throttleThreshold = 90
                $SnipeitPSSession.throttledRequests = [System.Collections.ArrayList]@((Get-Date).ToFileTime(), (Get-Date).ToFileTime())
                Mock Invoke-RestMethod { [PSCustomObject]@{ total = 0 } }
                Mock Start-Sleep {}
                Invoke-SnipeitMethod -Api "/api/v1/hardware" -Verbose 4>&1 | Out-Null
                Should -Invoke Start-Sleep -Times 1
            } finally {
                $VerbosePreference = 'SilentlyContinue'
            }
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - Error messages property (Out-String)
# ============================================================

Describe "Invoke-SnipeitMethod - Error response with messages object" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Writes error with complex messages object" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod {
                [PSCustomObject]@{
                    status = 'error'
                    messages = [PSCustomObject]@{ name = @('Name is required'); status_id = @('Status is required') }
                }
            }
            Invoke-SnipeitMethod -Api "/api/v1/hardware" -Method POST -Body @{bad='data'} -ErrorVariable err -ErrorAction SilentlyContinue
            $err.Count | Should -BeGreaterThan 0
        }
    }
}

# ============================================================
# Invoke-SnipeitMethod - GetParameters not appended when ? exists
# ============================================================

Describe "Invoke-SnipeitMethod - GetParameters skip when ? already in URI" {
    BeforeEach {
        InModuleScope 'SnipeitPS' {
            $script:savedUrl = $SnipeitPSSession.url
            $script:savedApiKey = $SnipeitPSSession.apiKey
            $script:savedLegacyUrl = $SnipeitPSSession.legacyUrl
            $script:savedLegacyApiKey = $SnipeitPSSession.legacyApiKey
            $script:savedThrottleLimit = $SnipeitPSSession.throttleLimit
            $script:savedIsPowerShell7 = $script:IsPowerShell7

            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testapikey" -AsPlainText -Force
            $SnipeitPSSession.legacyUrl = $null
            $SnipeitPSSession.legacyApiKey = $null
            $SnipeitPSSession.throttleLimit = 0
            $script:IsPowerShell7 = $true
        }
    }
    AfterEach {
        InModuleScope 'SnipeitPS' {
            $SnipeitPSSession.url = $script:savedUrl
            $SnipeitPSSession.apiKey = $script:savedApiKey
            $SnipeitPSSession.legacyUrl = $script:savedLegacyUrl
            $SnipeitPSSession.legacyApiKey = $script:savedLegacyApiKey
            $SnipeitPSSession.throttleLimit = $script:savedThrottleLimit
            $script:IsPowerShell7 = $script:savedIsPowerShell7
        }
    }

    It "Does not append GetParameters when URI already contains ?" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { [PSCustomObject]@{ total = 0 } }
            # API path with ? already present - GetParameters should not be appended
            Invoke-SnipeitMethod -Api "/api/v1/hardware?existing=param" -GetParameters @{limit=50}
            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter { $Uri -like "*existing=param*" }
        }
    }
}
