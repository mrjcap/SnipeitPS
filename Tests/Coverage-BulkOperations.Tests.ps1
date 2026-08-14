BeforeAll {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe "Snipe-IT Bulk Asset Operations and Auditing (grokability/snipe-it#19271)" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            $script:SnipeitPSSession = @{
                url    = "http://localhost:8080"
                apiKey = (ConvertTo-SecureString "testtoken123" -AsPlainText -Force)
            }
        }
    }

    Context "Set-SnipeitAsset Native Bulk Routing" {
        It "Routes to /hardware/bulk with ids array when multiple IDs are passed" {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { return @{ status = "success" } }
                Set-SnipeitAsset -id 42, 43, 999 -notes "moved to warehouse B" -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Api -eq "/api/v1/hardware/bulk" -and
                    $Method -eq "Patch" -and
                    $Body['ids'][0] -eq 42 -and
                    $Body['ids'][1] -eq 43 -and
                    $Body['ids'][2] -eq 999 -and
                    $Body['notes'] -eq "moved to warehouse B"
                }
            }
        }

        It "Routes to /hardware/{id} for scalar ID" {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { return @{ status = "success" } }
                Set-SnipeitAsset -id 42 -notes "single asset" -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Api -eq "/api/v1/hardware/42" -and
                    $Method -eq "Patch" -and
                    $Body['notes'] -eq "single asset"
                }
            }
        }
    }

    Context "Update-SnipeitAssetAudit Bulk and Single Audits" {
        It "Routes to /hardware/audit/bulk when multiple IDs are passed" {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { return @{ status = "success" } }
                $date = [datetime]"2027-01-15"
                Update-SnipeitAssetAudit -id 42, 43 -note "Q3 quarterly audit" -next_audit_date $date -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Api -eq "/api/v1/hardware/audit/bulk" -and
                    $Method -eq "POST" -and
                    $Body['ids'][0] -eq 42 -and
                    $Body['ids'][1] -eq 43 -and
                    $Body['note'] -eq "Q3 quarterly audit" -and
                    $Body['next_audit_date'] -eq "2027-01-15"
                }
            }
        }

        It "Routes to /hardware/{id}/audit for single ID" {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { return @{ status = "success" } }
                Update-SnipeitAssetAudit -id 42 -note "Single audit" -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Api -eq "/api/v1/hardware/42/audit" -and
                    $Method -eq "POST" -and
                    $Body['note'] -eq "Single audit"
                }
            }
        }

        It "Routes to /hardware/audit when asset_tag or serial is used" {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { return @{ status = "success" } }
                Update-SnipeitAssetAudit -asset_tag "TAG123" -note "Tag audit" -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Api -eq "/api/v1/hardware/audit" -and
                    $Method -eq "POST" -and
                    $Body['asset_tag'] -eq "TAG123" -and
                    $Body['note'] -eq "Tag audit"
                }
            }
        }

        It "Supports image parameter on Update-SnipeitAssetAudit" {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { return @{ status = "success" } }
                # Create a temporary dummy file to satisfy ValidateScript({Test-Path $_})
                $tempFile = [System.IO.Path]::GetTempFileName()
                try {
                    Update-SnipeitAssetAudit -id 42 -image $tempFile -note "With photo" -Confirm:$false
                    Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                        $Api -eq "/api/v1/hardware/42/audit" -and
                        $Body['image'] -eq $tempFile
                    }
                } finally {
                    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
                }
            }
        }

        It "Evaluates parameters per item when processed via pipeline" {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { return @{ status = "success" } }
                @([PSCustomObject]@{ id = 10 }, [PSCustomObject]@{ id = 20 }) | Update-SnipeitAssetAudit -note "Pipelined" -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 2
            }
        }
    }

    Context "New-SnipeitAudit Bulk and Single Audits" {
        It "Routes to /hardware/audit/bulk when multiple IDs are passed" {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { return @{ status = "success" } }
                $date = [datetime]"2027-01-15"
                New-SnipeitAudit -id 42, 43 -note "Bulk audit via New" -next_audit_date $date -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                    $Api -eq "/api/v1/hardware/audit/bulk" -and
                    $Method -eq "Post" -and
                    $Body['ids'][0] -eq 42 -and
                    $Body['ids'][1] -eq 43 -and
                    $Body['note'] -eq "Bulk audit via New" -and
                    $Body['next_audit_date'] -eq "2027-01-15"
                }
            }
        }

        It "Supports image parameter on New-SnipeitAudit" {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { return @{ status = "success" } }
                $tempFile = [System.IO.Path]::GetTempFileName()
                try {
                    New-SnipeitAudit -tag "TAG456" -image $tempFile -Confirm:$false
                    Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                        $Api -eq "/api/v1/hardware/audit" -and
                        $Body['image'] -eq $tempFile
                    }
                } finally {
                    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
                }
            }
        }
    }
}
