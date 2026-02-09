BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

Describe "New-SnipeitStatus" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/statuslabels endpoint with POST method and correct body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitStatus -name "Ready to Deploy" -type deployable -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/statuslabels" -and
                $Method -eq "Post" -and
                $Body.name -eq "Ready to Deploy" -and
                $Body.type -eq "deployable"
            }
        }
    }

    It "Passes optional parameters in body when provided" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitStatus -name "Test" -type pending -notes "test notes" -color "#ff0000" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/statuslabels" -and
                $Body.notes -eq "test notes" -and
                $Body.color -eq "#ff0000"
            }
        }
    }

    It "Passes show_in_nav and default_label boolean parameters" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitStatus -name "Nav Status" -type deployable -show_in_nav $true -default_label $false -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/statuslabels" -and
                $Body.show_in_nav -eq $true -and
                $Body.default_label -eq $false
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            New-SnipeitStatus -name "Test" -type deployable -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "New-SnipeitGroup" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/groups endpoint with POST method and name in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitGroup -name "IT Admins" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/groups" -and
                $Method -eq "Post" -and
                $Body.name -eq "IT Admins"
            }
        }
    }

    It "Passes permissions hashtable in body when provided" {
        InModuleScope 'SnipeitPS' {
            $perms = @{ admin = "1"; reports = "1" }
            New-SnipeitGroup -name "Admins" -permissions $perms -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/groups" -and
                $Body.permissions -ne $null
            }
        }
    }

    It "Passes notes in body when provided" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitGroup -name "Dev Team" -notes "Developer group" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/groups" -and
                $Body.notes -eq "Developer group"
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            New-SnipeitGroup -name "Test" -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "New-SnipeitFieldset" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/fieldsets endpoint with POST method and name in body" {
        InModuleScope 'SnipeitPS' {
            New-SnipeitFieldset -name "Laptop Fields" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/fieldsets" -and
                $Method -eq "Post" -and
                $Body.name -eq "Laptop Fields"
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            New-SnipeitFieldset -name "Test" -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "New-SnipeitAssetFile" {
    BeforeAll {
        $script:tempFilePath = [System.IO.Path]::GetTempFileName()
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    AfterAll {
        Remove-Item $script:tempFilePath -Force -ErrorAction SilentlyContinue
    }

    It "Calls /api/v1/hardware/{id}/files endpoint with POST method" {
        InModuleScope 'SnipeitPS' -Parameters @{ tempFile = $script:tempFilePath } {
            New-SnipeitAssetFile -id 5 -file $tempFile -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/5/files" -and
                $Method -eq "Post"
            }
        }
    }

    It "Passes file path in body" {
        InModuleScope 'SnipeitPS' -Parameters @{ tempFile = $script:tempFilePath } {
            New-SnipeitAssetFile -id 3 -file $tempFile -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/3/files" -and
                $Body.file -eq $tempFile
            }
        }
    }

    It "Passes optional notes in body when provided" {
        InModuleScope 'SnipeitPS' -Parameters @{ tempFile = $script:tempFilePath } {
            New-SnipeitAssetFile -id 5 -file $tempFile -notes "warranty doc" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.notes -eq "warranty doc"
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            $tf = [System.IO.Path]::GetTempFileName()
            try {
                Mock Invoke-SnipeitMethod { return $null }
                Mock Set-SnipeitPSLegacyApiKey {}
                Mock Set-SnipeitPSLegacyUrl {}
                Mock Reset-SnipeitPSLegacyApi {}
                Mock Write-Warning {}
                New-SnipeitAssetFile -id 1 -file $tf -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
                Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
                Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
                Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
            } finally {
                Remove-Item $tf -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

Describe "New-SnipeitModelFile" {
    BeforeAll {
        $script:tempFilePath = [System.IO.Path]::GetTempFileName()
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    AfterAll {
        Remove-Item $script:tempFilePath -Force -ErrorAction SilentlyContinue
    }

    It "Calls /api/v1/models/{id}/files endpoint with POST method" {
        InModuleScope 'SnipeitPS' -Parameters @{ tempFile = $script:tempFilePath } {
            New-SnipeitModelFile -id 8 -file $tempFile -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/models/8/files" -and
                $Method -eq "Post"
            }
        }
    }

    It "Passes file path in body" {
        InModuleScope 'SnipeitPS' -Parameters @{ tempFile = $script:tempFilePath } {
            New-SnipeitModelFile -id 2 -file $tempFile -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/models/2/files" -and
                $Body.file -eq $tempFile
            }
        }
    }

    It "Passes optional notes in body when provided" {
        InModuleScope 'SnipeitPS' -Parameters @{ tempFile = $script:tempFilePath } {
            New-SnipeitModelFile -id 8 -file $tempFile -notes "spec sheet" -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Body.notes -eq "spec sheet"
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            $tf = [System.IO.Path]::GetTempFileName()
            try {
                Mock Invoke-SnipeitMethod { return $null }
                Mock Set-SnipeitPSLegacyApiKey {}
                Mock Set-SnipeitPSLegacyUrl {}
                Mock Reset-SnipeitPSLegacyApi {}
                Mock Write-Warning {}
                New-SnipeitModelFile -id 1 -file $tf -url "http://test.snipeit.com" -apiKey "testkey" -Confirm:$false
                Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
                Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
                Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
            } finally {
                Remove-Item $tf -Force -ErrorAction SilentlyContinue
            }
        }
    }
}
