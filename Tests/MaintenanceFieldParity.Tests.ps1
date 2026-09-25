BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Maintenance field parity' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:maintenanceSession = [SnipeitSession]::new('https://contract.invalid', $key)
            $script:maintenanceSession.ThrottleLimit = 0
            $script:maintenanceCalls = [System.Collections.Generic.List[object]]::new()
            Mock Invoke-RestMethod {
                param($Body, $Uri, $Method)
                $json = if ($Body) { [Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json }
                $script:maintenanceCalls.Add(@{ Json = $json; Uri = [string]$Uri; Method = $Method })
                if ($Method -eq 'Get') {
                    [pscustomobject]@{ total = 1; rows = @([pscustomobject]@{ id = 4 }) }
                } else {
                    [pscustomobject]@{ status = 'success'; payload = @{ id = 4 } }
                }
            }
        }

        Context '<Verb> optional maintenance fields' -ForEach @(
            @{ Verb = 'New'; Required = @{ asset_id = 2; title = 'Inspect'; start_date = '2026-01-01'; asset_maintenance_type = '9' } }
            @{ Verb = 'Set'; Required = @{ id = 4; title = 'Inspect' } }
        ) {
            It 'Serializes completion metadata, URL, zero duration and false warranty' {
                & "$Verb-SnipeitAssetMaintenance" @Required -url 'https://work.example.invalid/?a=1&b=2' -completed_at '2026-01-02 14:15:16' -completed_by 3 -asset_maintenance_time 0 -cost 0 -is_warranty $false -Session $script:maintenanceSession -Confirm:$false
                $script:maintenanceCalls.Count | Should -Be 1
                $json = $script:maintenanceCalls[0].Json
                $json.url | Should -BeExactly 'https://work.example.invalid/?a=1&b=2'
                $json.completed_at | Should -BeExactly '2026-01-02 14:15:16'
                $json.completed_by | Should -Be 3
                $json.asset_maintenance_time | Should -Be 0
                $json.cost | Should -Be 0
                $json.is_warranty | Should -BeFalse
                $json.name | Should -BeExactly 'Inspect'
                $json.PSObject.Properties.Name | Should -Not -Contain 'title'
            }

            It 'Preserves nullable fields including the completion_date alias' {
                & "$Verb-SnipeitAssetMaintenance" @Required -supplier_id $null -completion_date $null -completed_at $null -completed_by $null -cost $null -asset_maintenance_time $null -Session $script:maintenanceSession -Confirm:$false
                $script:maintenanceCalls.Count | Should -Be 1
                $json = $script:maintenanceCalls[0].Json
                foreach ($field in @('supplier_id', 'expected_completion_date', 'completed_at', 'completed_by', 'cost', 'asset_maintenance_time')) {
                    $json.PSObject.Properties.Name | Should -Contain $field
                    ($null -eq $json.$field) | Should -BeTrue
                }
                $json.PSObject.Properties.Name | Should -Not -Contain 'completion_date'
            }

            It 'Omits unbound optional fields rather than sending defaults' {
                & "$Verb-SnipeitAssetMaintenance" @Required -Session $script:maintenanceSession -Confirm:$false
                $script:maintenanceCalls.Count | Should -Be 1
                foreach ($field in @('supplier_id', 'completed_at', 'completed_by', 'expected_completion_date', 'asset_maintenance_time', 'cost', 'url')) {
                    $script:maintenanceCalls[0].Json.PSObject.Properties.Name | Should -Not -Contain $field
                }
            }

            It 'Retains positive-ID validation for supplier and completing user' {
                foreach ($field in @('supplier_id', 'completed_by')) {
                    $parameters = @{ $field = -1 }
                    { & "$Verb-SnipeitAssetMaintenance" @Required @parameters -Session $script:maintenanceSession -Confirm:$false } | Should -Throw
                }
                $script:maintenanceCalls.Count | Should -Be 0
            }

            It 'Does not resolve types or call HTTP under WhatIf' {
                & "$Verb-SnipeitAssetMaintenance" @Required -supplier_id $null -completed_by 3 -Session $script:maintenanceSession -WhatIf
                $script:maintenanceCalls.Count | Should -Be 0
            }
        }

        It 'Normalizes legacy maintenance title only in the serialized body' {
            $body = @{ title = 'Inspect'; name = 'Inspect' }
            Invoke-SnipeitMethod -Api '/api/v1/maintenances/4' -Method Patch -Body $body -Session $script:maintenanceSession
            $script:maintenanceCalls.Count | Should -Be 1
            $script:maintenanceCalls[0].Json.name | Should -BeExactly 'Inspect'
            $script:maintenanceCalls[0].Json.PSObject.Properties.Name | Should -Not -Contain 'title'
            $body.title | Should -BeExactly 'Inspect'
        }

        It 'Does not remove title from unrelated endpoint bodies' {
            Invoke-SnipeitMethod -Api '/api/v1/users/4' -Method Patch -Body @{ name = 'Example'; title = 'Engineer' } -Session $script:maintenanceSession
            $script:maintenanceCalls.Count | Should -Be 1
            $script:maintenanceCalls[0].Json.title | Should -BeExactly 'Engineer'
        }

        It 'Preserves the existing positional maintenance notes argument' {
            Set-SnipeitAssetMaintenance 4 2 3 '9' 'Inspect' '2026-01-01' '2026-01-03' $false 0 'Original notes' -Session $script:maintenanceSession -Confirm:$false
            $script:maintenanceCalls.Count | Should -Be 1
            $script:maintenanceCalls[0].Json.notes | Should -BeExactly 'Original notes'
            $script:maintenanceCalls[0].Json.PSObject.Properties.Name | Should -Not -Contain 'url'
        }

        It 'Supports the flat list representation and preserves pagination controls' {
            Get-SnipeitAssetMaintenance -format flat -limit 20 -offset 0 -all -Session $script:maintenanceSession
            $script:maintenanceCalls.Count | Should -Be 1
            $script:maintenanceCalls[0].Uri | Should -Match '[?&]format=flat(&|$)'
            $script:maintenanceCalls[0].Uri | Should -Not -Match '[?&]all='
        }

        It 'Preserves bulk creation arrays while omitting the optional supplier' {
            New-SnipeitAssetMaintenance -asset_ids 2, 3 -title 'Inspect' -start_date '2026-01-01' -asset_maintenance_type '9' -url 'https://work.example.invalid' -Session $script:maintenanceSession -Confirm:$false
            $script:maintenanceCalls.Count | Should -Be 1
            $script:maintenanceCalls[0].Json.asset_ids | Should -Be @(2, 3)
            $script:maintenanceCalls[0].Json.PSObject.Properties.Name | Should -Not -Contain 'supplier_id'
        }

        It 'Rejects bulk images rather than losing the asset ID array in multipart transport' {
            { New-SnipeitAssetMaintenance -asset_ids 2, 3 -title 'Inspect' -start_date '2026-01-01' -asset_maintenance_type '9' -image 'bulk.png' -Session $script:maintenanceSession -Confirm:$false } | Should -Throw '*bulk*image*'
            $script:maintenanceCalls.Count | Should -Be 0
        }

        It 'Passes creation images through the shared image transport' {
            $imagePath = Join-Path $TestDrive 'maintenance.png'
            [IO.File]::WriteAllBytes($imagePath, [byte[]]@(1, 2, 3))
            Mock Invoke-SnipeitMethod { [pscustomobject]@{ id = 4 } }
            New-SnipeitAssetMaintenance -asset_id 2 -title 'Inspect' -start_date '2026-01-01' -asset_maintenance_type '9' -image $imagePath -Session $script:maintenanceSession -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Exactly -Times 1 -ParameterFilter { $Body.image -eq $imagePath }
        }
    }
}
