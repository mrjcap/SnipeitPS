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
}

Describe "Get-SnipeitSetting" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/settings endpoint with GET method" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitSetting
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Api -eq "/api/v1/settings" -and
                $Method -eq "Get"
            }
        }
    }
}

Describe "Get-SnipeitStatusAsset" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/statuslabels/{id}/assetlist endpoint with ID interpolated" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitStatusAsset -id 5
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/statuslabels/{id}/assetlist" -and
                $PathParameter.id -eq 5 -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes GetParameters for pagination" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitStatusAsset -id 5 -limit 10 -offset 20
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/statuslabels/{id}/assetlist" -and
                $PathParameter.id -eq 5 -and
                $Method -eq "Get" -and
                $GetParameters -ne $null
            }
        }
    }

    It "Handles -all pagination parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "Asset1" }
            )}
            $result = Get-SnipeitStatusAsset -id 1 -all
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true
            }
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "Asset1" }
            )}
            $result = Get-SnipeitStatusAsset -id 1 -all -offset 10
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and
                $GetParameters.offset -eq 10
            }
        }
    }

    It "Handles -all pagination delegation" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Asset1" })
            }
            $result = Get-SnipeitStatusAsset -id 1 -all -limit 50
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and
                $GetParameters.limit -eq 50
            }
        }
    }
}

Describe "Get-SnipeitUserEula" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/users/{id}/eulas endpoint with ID interpolated" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitUserEula -id 7
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/users/{id}/eulas" -and
                $PathParameter.id -eq 7 -and
                $Method -eq "Get"
            }
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
                $Route -eq "/api/v1/fieldsets/{id}/fields" -and
                $PathParameter.id -eq 2 -and
                $Method -eq "Post"
            }
        }
    }
}

Describe "Get-SnipeitAssetFile" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/hardware/{id}/files endpoint when only ID specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAssetFile -id 4
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/hardware/{id}/files" -and
                $PathParameter.id -eq 4 -and
                $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/hardware/{id}/files/{file_id} endpoint when file_id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitAssetFile -id 4 -file_id 10
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/hardware/{id}/files/{file_id}" -and
                $PathParameter.id -eq 4 -and
                $PathParameter.file_id -eq 10 -and
                $Method -eq "Get"
            }
        }
    }
}

Describe "Get-SnipeitModelFile" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Calls /api/v1/models/{id}/files endpoint when only ID specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitModelFile -id 6
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/models/{id}/files" -and
                $PathParameter.id -eq 6 -and
                $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/models/{id}/files/{file_id} endpoint when file_id specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitModelFile -id 6 -file_id 12
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/models/{id}/files/{file_id}" -and
                $PathParameter.id -eq 6 -and
                $PathParameter.file_id -eq 12 -and
                $Method -eq "Get"
            }
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
                $Route -eq "/api/v1/groups" -and
                $Method -eq "Get"
            }
        }
    }

    It "Calls /api/v1/groups/{id} endpoint when ID specified" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitGroup -id 3
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/groups/{id}" -and
                $PathParameter.id -eq 3 -and
                $Method -eq "Get"
            }
        }
    }

    It "Passes search in GetParameters" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitGroup -search "Admin"
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Route -eq "/api/v1/groups" -and
                $Method -eq "Get" -and
                $GetParameters -ne $null
            }
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
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true
            }
        }
    }

    It "Handles -all with -offset parameter" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return @(
                [PSCustomObject]@{ id = 1; name = "Item1" }
            )}
            $result = Get-SnipeitGroup -all -offset 10
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and
                $GetParameters.offset -eq 10
            }
        }
    }

    It "Handles -all pagination delegation" {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod {
                return @([PSCustomObject]@{ id = 1; name = "Group1" })
            }
            $result = Get-SnipeitGroup -all -limit 50
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Paginate -eq $true -and
                $GetParameters.limit -eq 50
            }
        }
    }
}

