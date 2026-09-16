BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Status label and maintenance server contracts' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $script:SnipeitPSSession.url = 'https://contract.invalid'
            $script:SnipeitPSSession.apiKey = 'test-only-key'
            $script:SnipeitPSSession.throttleLimit = 0
            $script:requests = [System.Collections.Generic.List[object]]::new()
            Mock Invoke-RestMethod {
                $parsed = if ($Body) { [Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json } else { $null }
                $script:requests.Add([pscustomobject]@{ Uri = $Uri.OriginalString; Method = $Method; Body = $parsed })
                if ($Method -eq 'GET' -and $Uri -like '*/statuslabels/*') {
                    [pscustomobject]@{ id = 1; type = 'pending'; color = '#123456'; show_in_nav = $true; default_label = $false }
                } elseif ($Method -eq 'GET' -and $Uri -like '*/maintenance-types*') {
                    [pscustomobject]@{ total = 1; rows = @([pscustomobject]@{ id = 29; name = 'Custom inspection' }) }
                } else {
                    [pscustomobject]@{ status = 'success'; messages = 'Saved'; payload = [pscustomobject]@{ id = 1 } }
                }
            }
        }

        It 'Set-SnipeitStatus reads and preserves omitted settings for each ID' {
            $result = @(Set-SnipeitStatus -id 1,2 -name Renamed -Confirm:$false)
            $script:requests.Count | Should -Be 4
            $script:requests[0].Method | Should -Be 'GET'
            $script:requests[1].Body.type | Should -Be 'pending'
            $script:requests[1].Body.color | Should -Be '#123456'
            $script:requests[1].Body.show_in_nav | Should -BeTrue
            $script:requests[1].Body.default_label | Should -BeFalse
            $script:requests[3].Uri | Should -Be 'https://contract.invalid/api/v1/statuslabels/2'
            $result.id | Should -Be @(1,1)
        }

        It 'Set-SnipeitStatus preserves explicit false, zero and null instead of read values' {
            Set-SnipeitStatus -id 1 -name Renamed -show_in_nav $false -default_label 0 -color $null -Confirm:$false
            $script:requests[-1].Body.show_in_nav | Should -BeFalse
            $script:requests[-1].Body.default_label | Should -BeFalse
            $script:requests[-1].Body.color | Should -BeNullOrEmpty
            $script:requests[-1].Body.type | Should -Be 'pending'
        }

        It 'Set-SnipeitStatus avoids reads when all replacement settings are explicit' {
            Set-SnipeitStatus -id 1 -type deployable -color '#abcabc' -show_in_nav $true -default_label $null -Confirm:$false
            $script:requests.Count | Should -Be 1
            $script:requests[0].Body.default_label | Should -BeNullOrEmpty
        }

        It 'Status and maintenance read and mutate through the explicit Session' {
            $session = [SnipeitSession]::new('https://tenant.invalid', (ConvertTo-SecureString 'test-key' -AsPlainText -Force))
            Set-SnipeitStatus -id 1 -name Renamed -Session $session -Confirm:$false
            Set-SnipeitAssetMaintenance -id 2 -asset_maintenance_type 'Custom inspection' -Session $session -Confirm:$false
            $script:requests.Count | Should -Be 4
            foreach ($request in $script:requests) { $request.Uri | Should -BeLike 'https://tenant.invalid/*' }
        }

        It 'Set-SnipeitStatus preserves omitted null color and zero flags' {
            Mock Invoke-RestMethod {
                [pscustomobject]@{ id = 1; type = 'undeployable'; color = $null; show_in_nav = $false; default_label = $false }
            } -ParameterFilter { $Method -eq 'GET' }
            Set-SnipeitStatus -id 1 -name Renamed -Confirm:$false
            $script:requests[-1].Body.color | Should -BeNullOrEmpty
            $script:requests[-1].Body.show_in_nav | Should -BeFalse
            $script:requests[-1].Body.default_label | Should -BeFalse
            $script:requests[-1].Body.type | Should -Be 'undeployable'
        }

        It 'Maintenance name resolution honors WhatIf without HTTP' {
            Set-SnipeitAssetMaintenance -id 1 -asset_maintenance_type 'Custom inspection' -WhatIf
            New-SnipeitAssetMaintenance -asset_id 1 -supplier_id 1 -title Inspect -start_date '2026-01-01' -asset_maintenance_type 'Custom inspection' -WhatIf
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly
        }

        It 'Set-SnipeitStatus honors WhatIf without reads or mutation' {
            Set-SnipeitStatus -id 1 -name Renamed -WhatIf
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly
        }

        It 'Set-SnipeitStatus never mutates after a failed read' {
            Mock Invoke-RestMethod { [pscustomobject]@{ status = 'error'; messages = 'Denied' } } -ParameterFilter { $Method -eq 'GET' }
            Set-SnipeitStatus -id 1 -name Renamed -Confirm:$false -ErrorAction SilentlyContinue
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly -ParameterFilter { $Method -eq 'PATCH' }
        }

        It '<Command> resolves custom names to the actual numeric ID' -TestCases @(
            @{ Command = 'New-SnipeitAssetMaintenance'; Inputs = @{ asset_id = 1; supplier_id = 1; title = 'Inspect'; start_date = '2026-01-01' } },
            @{ Command = 'Set-SnipeitAssetMaintenance'; Inputs = @{ id = 1; title = 'Inspect' } }
        ) {
            param($Command, $Inputs)
            & $Command @Inputs -asset_maintenance_type 'Custom inspection' -Confirm:$false
            $script:requests[0].Uri | Should -Match '/maintenance-types\?'
            $script:requests[-1].Body.maintenance_type_id | Should -Be 29
            $script:requests[-1].Body.PSObject.Properties.Name | Should -Not -Contain 'asset_maintenance_type'
        }

        It 'Maintenance type numeric strings avoid lookup and update omission preserves type' {
            New-SnipeitAssetMaintenance -asset_id 1 -supplier_id 1 -title Inspect -start_date '2026-01-01' -asset_maintenance_type '42' -Confirm:$false
            Set-SnipeitAssetMaintenance -id 1 -asset_maintenance_type '43' -Confirm:$false
            Set-SnipeitAssetMaintenance -id 1 -title Renamed -Confirm:$false
            $script:requests.Count | Should -Be 3
            $script:requests[0].Body.maintenance_type_id | Should -Be 42
            $script:requests[1].Body.maintenance_type_id | Should -Be 43
            $script:requests[2].Body.PSObject.Properties.Name | Should -Not -Contain 'maintenance_type_id'
        }

        It 'Maintenance type names fail clearly when missing or ambiguous' {
            Mock Invoke-RestMethod { [pscustomobject]@{ total = 0; rows = @() } } -ParameterFilter { $Method -eq 'GET' }
            { Set-SnipeitAssetMaintenance -id 1 -asset_maintenance_type 'Missing' -Confirm:$false } | Should -Throw '*maintenance type*'
            Mock Invoke-RestMethod { [pscustomobject]@{ total = 2; rows = @(@{id=4;name='Duplicate'},@{id=8;name='Duplicate'}) } } -ParameterFilter { $Method -eq 'GET' }
            { Set-SnipeitAssetMaintenance -id 1 -asset_maintenance_type 'Duplicate' -Confirm:$false } | Should -Throw '*maintenance type*'
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly -ParameterFilter { $Method -eq 'PATCH' }
        }

        It 'Maintenance built-in names use catalog values rather than hard-coded IDs' {
            Mock Invoke-RestMethod { [pscustomobject]@{ total = 1; rows = @(@{id=81;name='Repair'}) } } -ParameterFilter { $Method -eq 'GET' }
            Set-SnipeitAssetMaintenance -id 1 -asset_maintenance_type Repair -Confirm:$false
            $script:requests[-1].Body.maintenance_type_id | Should -Be 81
        }
    }
}
