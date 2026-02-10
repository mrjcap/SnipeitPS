BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

# ============================================================
# ValidateScript image param tests
# ============================================================

Describe "New-SnipeitAsset image param" {
    It "Passes image path through ValidateScript" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
            $tempFile = [System.IO.Path]::GetTempFileName()
            try {
                New-SnipeitAsset -status_id 1 -model_id 1 -name "Test" -image $tempFile -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tempFile
                }
            } finally {
                Remove-Item $tempFile -ErrorAction SilentlyContinue
            }
        }
    }
}

Describe "New-SnipeitModel image param" {
    It "Accepts image path through ValidateScript" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
            $tempFile = [System.IO.Path]::GetTempFileName()
            try {
                New-SnipeitModel -name "TestModel" -category_id 1 -manufacturer_id 1 -image $tempFile -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1
            } finally {
                Remove-Item $tempFile -ErrorAction SilentlyContinue
            }
        }
    }
}

Describe "Set-SnipeitCategory image param" {
    It "Passes image path through ValidateScript" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
            $tempFile = [System.IO.Path]::GetTempFileName()
            try {
                Set-SnipeitCategory -id 1 -name "Test" -image $tempFile -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body.image -eq $tempFile
                }
            } finally {
                Remove-Item $tempFile -ErrorAction SilentlyContinue
            }
        }
    }
}

# ============================================================
# Save-SnipeitBackup error handling
# ============================================================

Describe "Save-SnipeitBackup error handling" {
    It "Writes error when Invoke-RestMethod fails" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-RestMethod { throw "Download failed" }
            $SnipeitPSSession.url = "https://snipeit.example.com"
            $SnipeitPSSession.apiKey = ConvertTo-SecureString "testkey" -AsPlainText -Force
            $tempDir = [System.IO.Path]::GetTempPath()
            Save-SnipeitBackup -filename "backup.sql" -path $tempDir -Confirm:$false -ErrorAction SilentlyContinue -ErrorVariable err
            $err.Count | Should -BeGreaterThan 0
        }
    }
}

# ============================================================
# Connect-SnipeitPS throttlePeriod default
# ============================================================

Describe "Connect-SnipeitPS throttlePeriod default" {
    It "Defaults throttlePeriod to 60000 when throttleLimit is set but throttlePeriod is not" {
        InModuleScope 'SnipeitPS' {
            Mock Test-SnipeitPSConnection { return $true }
            Connect-SnipeitPS -url "https://snipeit.example.com" -apiKey "testkey123" -throttleLimit 120
            $SnipeitPSSession.throttlePeriod | Should -Be 60000
        }
    }
}
