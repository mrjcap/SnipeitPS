BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Audit mutation field contracts' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:auditSession = [SnipeitSession]::new('https://contract.invalid', $key)
            $script:auditSession.ThrottleLimit = 0
            $script:auditCalls = [System.Collections.Generic.List[object]]::new()
            Mock Invoke-RestMethod -ModuleName SnipeitPS {
                param($Body, $Uri)
                $script:auditCalls.Add(@{ Json = [Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json; Uri = $Uri })
                [pscustomobject]@{ status = 'success'; payload = @{ id = 1 } }
            }
        }

        Context '<Command> mutation controls' -ForEach @(
            @{ Command = 'New-SnipeitAudit' }
            @{ Command = 'Update-SnipeitAssetAudit' }
        ) {
            It 'Sends flags and custom fields for <Mode>' -ForEach @(
                @{ Mode = 'ID'; Target = @{ id = 4 }; Route = 'hardware/4/audit' }
                @{ Mode = 'bulk'; Target = @{ id = @(4, 5) }; Route = 'hardware/audit/bulk' }
                @{ Mode = 'tag'; Target = @{ asset_tag = 'TEST' }; Route = 'hardware/audit' }
                @{ Mode = 'serial'; Target = @{ serial = 'SERIAL' }; Route = 'hardware/audit' }
            ) {
                & $Command @Target -update_location $true -location_id 2 -clear_name $false -customfields @{ '_snipeit_test_1' = @('A', 'B'); '_snipeit_test_2' = $null } -Session $script:auditSession -Confirm:$false
                $script:auditCalls.Count | Should -Be 1
                $script:auditCalls[0].Uri | Should -BeExactly "https://contract.invalid/api/v1/$Route"
                $json = $script:auditCalls[0].Json
                $json.location_id | Should -Be 2
                $json.update_location | Should -BeTrue
                $json.clear_name | Should -BeFalse
                $json._snipeit_test_1.Count | Should -Be 2
                $json._snipeit_test_1[0] | Should -BeExactly 'A'
                $json._snipeit_test_1[1] | Should -BeExactly 'B'
                $json.PSObject.Properties.Name | Should -Contain '_snipeit_test_2'
                ($null -eq $json._snipeit_test_2) | Should -BeTrue
                $json.PSObject.Properties.Name | Should -Not -Contain 'customfields'
            }

            It 'Can clear the location explicitly without dropping an empty note' {
                & $Command -id 4 -update_location $true -location_id $null -note '' -Session $script:auditSession -Confirm:$false
                $script:auditCalls[0].Json.PSObject.Properties.Name | Should -Contain 'location_id'
                ($null -eq $script:auditCalls[0].Json.location_id) | Should -BeTrue
                $script:auditCalls[0].Json.PSObject.Properties.Name | Should -Contain 'note'
            }

            It 'Omits unbound mutation controls' {
                & $Command -id 4 -Session $script:auditSession -Confirm:$false
                foreach ($field in @('clear_name', 'update_location', 'customfields', 'location_id')) {
                    $script:auditCalls[0].Json.PSObject.Properties.Name | Should -Not -Contain $field
                }
            }

            It 'Rejects non-custom body keys before HTTP' {
                { & $Command -id 4 -customfields @{ status_id = 2 } -Session $script:auditSession -Confirm:$false } | Should -Throw
                $script:auditCalls.Count | Should -Be 0
            }

            It 'Does not send audit mutations under WhatIf' {
                & $Command -id 4 -clear_name $true -customfields @{ '_snipeit_test_1' = 'Test' } -Session $script:auditSession -WhatIf
                $script:auditCalls.Count | Should -Be 0
            }
        }
    }
}
