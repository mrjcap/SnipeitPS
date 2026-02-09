BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

Describe "Get-SnipeitVersion" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/version endpoint with GET method" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitVersion
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/version" -and
                $Method -eq "Get"
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitVersion -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Get-SnipeitCurrentUser" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/users/me endpoint with GET method" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitCurrentUser
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/users/me" -and
                $Method -eq "Get"
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitCurrentUser -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Get-SnipeitSetting" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/settings/backups endpoint with GET method" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitSetting
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/settings/backups" -and
                $Method -eq "Get"
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitSetting -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Get-SnipeitStatusAsset" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/statuslabels/{id}/assetlist endpoint with id interpolated" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitStatusAsset -id 5
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/statuslabels/5/assetlist" -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes GetParameters for pagination" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitStatusAsset -id 5 -limit 10 -offset 20
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/statuslabels/5/assetlist" -and
                $Method -eq "Get" -and
                $GetParameters -ne $null
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitStatusAsset -id 5 -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }

    It "Handles -all pagination parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "Asset1" }
            )}
            $result = Get-SnipeitStatusAsset -id 1 -all
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "Asset1" }
            )}
            $result = Get-SnipeitStatusAsset -id 1 -all -offset 10
            $result | Should -Not -BeNullOrEmpty
        }
    }

    It "Handles -all pagination loop continuation" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Asset$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Asset51" })
                }
            }
            $result = Get-SnipeitStatusAsset -id 1 -all -limit 50
            $result.Count | Should -Be 51
        }
    }
}

Describe "Get-SnipeitUserEula" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/users/{id}/eulas endpoint with id interpolated" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitUserEula -id 7
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/users/7/eulas" -and
                $Method -eq "Get"
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitUserEula -id 7 -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Get-SnipeitFieldsetField" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/fieldsets/{id}/fields endpoint with POST method" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitFieldsetField -id 2
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/fieldsets/2/fields" -and
                $Method -eq "Post"
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitFieldsetField -id 2 -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Get-SnipeitAssetFile" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/hardware/{id}/files endpoint when only id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAssetFile -id 4
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/4/files" -and
                $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/hardware/{id}/files/{file_id} endpoint when file_id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAssetFile -id 4 -file_id 10
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/hardware/4/files/10" -and
                $Method -eq "Get"
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitAssetFile -id 4 -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Get-SnipeitModelFile" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/models/{id}/files endpoint when only id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitModelFile -id 6
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/models/6/files" -and
                $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/models/{id}/files/{file_id} endpoint when file_id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitModelFile -id 6 -file_id 12
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/models/6/files/12" -and
                $Method -eq "Get"
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitModelFile -id 6 -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }
}

Describe "Get-SnipeitGroup" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/groups endpoint for search" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitGroup
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/groups" -and
                $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/groups/{id} endpoint when id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitGroup -id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/groups/3" -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes search in GetParameters" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitGroup -search "Admin"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/groups" -and
                $Method -eq "Get" -and
                $GetParameters -ne $null
            }
        }
    }

    It "Handles legacy url and apiKey parameters" {
        InModuleScope 'SnipeitPS' {
            Mock Set-SnipeitPSLegacyApiKey {}
            Mock Set-SnipeitPSLegacyUrl {}
            Mock Reset-SnipeitPSLegacyApi {}
            Mock Write-Warning {}
            Get-SnipeitGroup -url "http://test.snipeit.com" -apiKey "testkey"
            Should -Invoke Set-SnipeitPSLegacyApiKey -Times 1
            Should -Invoke Set-SnipeitPSLegacyUrl -Times 1
            Should -Invoke Reset-SnipeitPSLegacyApi -Times 1
        }
    }

    It "Handles -all pagination parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "Item1" }
                [PSCustomObject]@{ id = 2; name = "Item2" }
            )}
            $result = Get-SnipeitGroup -all
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "Item1" }
            )}
            $result = Get-SnipeitGroup -all -offset 10
            $result | Should -Not -BeNullOrEmpty
        }
    }

    It "Handles -all pagination loop continuation" {
        InModuleScope 'SnipeitPS' {
            $script:callCount = 0
            Mock Invoke-SnipeitMethod {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $items = @()
                    for ($i = 1; $i -le 50; $i++) { $items += [PSCustomObject]@{ id = $i; name = "Group$i" } }
                    return $items
                } else {
                    return @([PSCustomObject]@{ id = 51; name = "Group51" })
                }
            }
            $result = Get-SnipeitGroup -all -limit 50
            $result.Count | Should -Be 51
        }
    }
}
