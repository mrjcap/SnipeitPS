BeforeAll {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe "Snipe-IT v8.7.0 Features and Compatibility" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            $script:SnipeitPSSession = @{
                url    = "http://localhost:8080"
                apiKey = (ConvertTo-SecureString "testtoken123" -AsPlainText -Force)
            }
        }
    }

    Context "Maintenance expected_completion_date (grokability/snipe-it#19339)" {
        It "New-SnipeitAssetMaintenance passes expected_completion_date" {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { return @{ status = "success" } }
                $date = [datetime]"2026-12-31"
                New-SnipeitAssetMaintenance -asset_id 1 -supplier_id 1 -asset_maintenance_type "Maintenance" -title "Test" -start_date $date -expected_completion_date $date -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body['expected_completion_date'] -eq "2026-12-31"
                }
            }
        }

        It "New-SnipeitAssetMaintenance accepts completion_date alias" {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { return @{ status = "success" } }
                $date = [datetime]"2026-12-31"
                New-SnipeitAssetMaintenance -asset_id 1 -supplier_id 1 -asset_maintenance_type "Maintenance" -title "Test" -start_date $date -completion_date $date -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body['expected_completion_date'] -eq "2026-12-31"
                }
            }
        }

        It "Set-SnipeitAssetMaintenance passes expected_completion_date" {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { return @{ status = "success" } }
                $date = [datetime]"2026-12-31"
                Set-SnipeitAssetMaintenance -id 1 -expected_completion_date $date -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body['expected_completion_date'] -eq "2026-12-31"
                }
            }
        }

        It "Set-SnipeitAssetMaintenance accepts completion_date alias" {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { return @{ status = "success" } }
                $date = [datetime]"2026-12-31"
                Set-SnipeitAssetMaintenance -id 1 -completion_date $date -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body['expected_completion_date'] -eq "2026-12-31"
                }
            }
        }
    }

    Context "User-Agent Header (grokability/snipe-it#19218)" {
        It "Invoke-SnipeitMethod includes User-Agent header" {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession = @{
                    url    = "http://localhost:8080"
                    apiKey = (ConvertTo-SecureString "testtoken123" -AsPlainText -Force)
                }
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{
                        status = "success"
                    }
                }
                Invoke-SnipeitMethod -Api "/test" -Method "GET"
                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Headers['User-Agent'] -eq "SnipeitPS/1.14.0"
                }
            }
        }
    }

    Context "Asset Audit by Serial or Asset Tag (grokability/snipe-it#19332)" {
        It "Update-SnipeitAssetAudit supports -serial parameter" {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { return @{ status = "success" } }
                Update-SnipeitAssetAudit -serial "SN123456" -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Api -eq "/api/v1/hardware/audit" -and $Body['serial'] -eq "SN123456"
                }
            }
        }

        It "Update-SnipeitAssetAudit supports -asset_tag parameter" {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { return @{ status = "success" } }
                Update-SnipeitAssetAudit -asset_tag "TAG999" -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Api -eq "/api/v1/hardware/audit" -and $Body['asset_tag'] -eq "TAG999"
                }
            }
        }

        It "Update-SnipeitAssetAudit throws when no identifier provided" {
            InModuleScope 'SnipeitPS' {
                { Update-SnipeitAssetAudit -Confirm:$false } | Should -Throw "Must specify -id, -asset_tag, or -serial for audit."
            }
        }
    }

    Context "Requestable Accessories (grokability/snipe-it#19169)" {
        It "New-SnipeitAccessory passes requestable flag" {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { return @{ status = "success" } }
                New-SnipeitAccessory -name "Mouse Pad" -qty 5 -category_id 1 -requestable $true -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body['requestable'] -eq $true
                }
            }
        }

        It "Set-SnipeitAccessory updates requestable flag" {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { return @{ status = "success" } }
                Set-SnipeitAccessory -id 1 -requestable $false -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body['requestable'] -eq $false
                }
            }
        }
    }

    Context "Parent Company Hierarchy (grokability/snipe-it#19230)" {
        It "New-SnipeitCompany passes parent_id parameter" {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { return @{ status = "success" } }
                New-SnipeitCompany -name "Child Corp" -parent_id 10 -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body['parent_id'] -eq 10
                }
            }
        }

        It "Set-SnipeitCompany updates parent_id parameter" {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { return @{ status = "success" } }
                Set-SnipeitCompany -id 5 -parent_id 10 -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Body['parent_id'] -eq 10
                }
            }
        }
    }
}
