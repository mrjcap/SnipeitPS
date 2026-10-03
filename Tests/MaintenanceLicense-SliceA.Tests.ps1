BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
    $cases = @(
        @{ Command='Get-SnipeitMaintenanceType'; Inputs=@{}; Method='GET'; Route='maintenance-types'; Fields=@{} },
        @{ Command='Get-SnipeitMaintenanceType'; Inputs=@{id=2}; Method='GET'; Route='maintenance-types/2'; Fields=@{} },
        @{ Command='New-SnipeitMaintenanceType'; Inputs=@{name='Inspection'}; Method='POST'; Route='maintenance-types'; Fields=@{name='Inspection'} },
        @{ Command='Set-SnipeitMaintenanceType'; Inputs=@{id=2;name='Inspection'}; Method='PATCH'; Route='maintenance-types/2'; Fields=@{name='Inspection'} },
        @{ Command='Remove-SnipeitMaintenanceType'; Inputs=@{id=2}; Method='DELETE'; Route='maintenance-types/2'; Fields=@{} },
        @{ Command='Complete-SnipeitAssetMaintenance'; Inputs=@{id=2;note='Done'}; Method='POST'; Route='maintenances/2/complete'; Fields=@{note='Done'} },
        @{ Command='Get-SnipeitAssetMaintenanceNote'; Inputs=@{id=2}; Method='GET'; Route='maintenances/2/notes'; Fields=@{} },
        @{ Command='New-SnipeitAssetMaintenanceNote'; Inputs=@{id=2;note='Progress'}; Method='POST'; Route='maintenances/2/notes'; Fields=@{note='Progress'} },
        @{ Command='Set-SnipeitLicenseOwner'; Inputs=@{id=2;assigned_to=3}; Method='POST'; Route='licenses/2/checkout'; Fields=@{target_type='user';assigned_to=3} },
        @{ Command='Set-SnipeitLicenseOwner'; Inputs=@{id=2;asset_id=4;seat_id=5;notes='Issue'}; Method='POST'; Route='licenses/2/checkout'; Fields=@{target_type='asset';asset_id=4;seat_id=5;notes='Issue'} },
        @{ Command='Reset-SnipeitLicenseOwner'; Inputs=@{id=2;seat_id=5}; Method='POST'; Route='licenses/2/checkin'; Fields=@{seat_id=5} }
    )
    $mutationCases = @($cases | Where-Object Method -NE 'GET')
}

Describe 'Slice A exported HTTP contracts' {
    BeforeEach {
        InModuleScope SnipeitPS {
            $script:SnipeitPSSession.url = 'https://contract.invalid'
            $script:SnipeitPSSession.apiKey = 'offline-test'
            $script:SnipeitPSSession.throttleLimit = 0
            $script:sliceRequests = [System.Collections.Generic.List[object]]::new()
        Mock Invoke-RestMethod {
            $parsed = if ($Body) { [Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json } else { $null }
            $script:sliceRequests.Add([pscustomobject]@{Uri=$Uri.OriginalString;Method=$Method;Body=$parsed})
            if ($Method -eq 'GET' -and $Uri.AbsolutePath -match '^/api/v1/maintenance-types/(\d+)$') {
                return [pscustomobject]@{ id = [int]$Matches[1] }
            }
            [pscustomobject]@{status='success';payload=[pscustomobject]@{id=2};messages='Saved'}
        }
        }
    }

    It '<Command> is exported and sends <Method> <Route> with exact fields' -ForEach $cases {
        (Get-Command $Command -Module SnipeitPS).Name | Should -Be $Command
        $options = @{}
        if ($Method -ne 'GET') { $options.Confirm = $false }
        $result = & $Command @Inputs @options
        $result.id | Should -Be 2
        $requests = @(InModuleScope SnipeitPS { $script:sliceRequests.ToArray() })
        $expectedCount = if ($Command -eq 'Set-SnipeitMaintenanceType') { 2 } else { 1 }
        $requests.Count | Should -Be $expectedCount
        $request = $requests[$expectedCount - 1]
        $request.Uri.Split('?')[0] | Should -Be "https://contract.invalid/api/v1/$Route"
        $request.Method | Should -Be $Method
        if ($Command -eq 'Set-SnipeitMaintenanceType') {
            $requests[0].Method | Should -Be 'GET'
            $requests[0].Uri | Should -Be "https://contract.invalid/api/v1/$Route"
        }
        if ($Fields.Count) {
            @($request.Body.PSObject.Properties.Name).Count | Should -Be $Fields.Count
            foreach ($key in $Fields.Keys) { $request.Body.$key | Should -Be $Fields[$key] }
        }
    }

    It '<Command> honors Session' -ForEach $cases {
        $session = InModuleScope SnipeitPS { [SnipeitSession]::new('https://tenant.invalid', (ConvertTo-SecureString 'offline' -AsPlainText -Force)) }
        $options = @{Session=$session}
        if ($Method -ne 'GET') { $options.Confirm = $false }
        & $Command @Inputs @options
        $requests = @(InModuleScope SnipeitPS { $script:sliceRequests.ToArray() })
        $requests[0].Uri | Should -BeLike 'https://tenant.invalid/*'
    }

    It '<Command> honors WhatIf without HTTP' -ForEach $mutationCases {
        & $Command @Inputs -WhatIf
        Should -Invoke Invoke-RestMethod -ModuleName SnipeitPS -Times 0 -Exactly
    }

    It '<Command> exposes API errors with ErrorAction Stop' -ForEach $cases {
        Mock Invoke-RestMethod -ModuleName SnipeitPS { [pscustomobject]@{status='error';messages='Denied';payload=$null} }
        $options = @{ErrorAction='Stop'}
        if ($Method -ne 'GET') { $options.Confirm = $false }
        { & $Command @Inputs @options } | Should -Throw '*Denied*'
    }

    It '<Command> exposes transport errors' -ForEach $cases {
        Mock Invoke-RestMethod -ModuleName SnipeitPS { throw 'Offline transport failure' }
        $options = @{ErrorAction='Stop'}
        if ($Method -ne 'GET') { $options.Confirm = $false }
        { & $Command @Inputs @options } | Should -Throw
    }

    It 'Get-SnipeitMaintenanceType preserves list filters and paginates rows' {
        InModuleScope SnipeitPS { Mock Invoke-RestMethod {
            if ($Uri -like '*offset=1*') { [pscustomobject]@{total=2;rows=@(@{id=3})} }
            else { [pscustomobject]@{total=2;rows=@(@{id=2})} }
        } }
        @(Get-SnipeitMaintenanceType -name 'Exact' -search 'Inspect' -deleted $false -sort name -order asc -limit 1 -all).id | Should -Be @(2,3)
        Should -Invoke Invoke-RestMethod -ModuleName SnipeitPS -Times 2 -Exactly -ParameterFilter {
            $Uri -like '*name=Exact*' -and $Uri -like '*deleted=false*' -and $Uri -like '*search=Inspect*'
        }
    }

    It 'Mutation IDs support arrays and property pipelines' {
        Set-SnipeitMaintenanceType -id 2,3 -name 'Updated' -Confirm:$false
        @([pscustomobject]@{id=4},[pscustomobject]@{id=5}) | Complete-SnipeitAssetMaintenance -Confirm:$false
        $requests = @(InModuleScope SnipeitPS { $script:sliceRequests.ToArray() })
        $requests.Count | Should -Be 6
        $requests[3].Uri | Should -BeLike '*/maintenance-types/3'
        $requests[3].Method | Should -Be 'PATCH'
        $requests[5].Uri | Should -BeLike '*/maintenances/5/complete'
    }

    It 'License checkout rejects conflicting targets before HTTP' {
        { Set-SnipeitLicenseOwner -id 2 -assigned_to 3 -asset_id 4 -Confirm:$false } | Should -Throw
        Should -Invoke Invoke-RestMethod -ModuleName SnipeitPS -Times 0 -Exactly
    }

    It 'License verbs preserve explicit nullable seat and notes fields' {
        Set-SnipeitLicenseOwner -id 2 -assigned_to 3 -seat_id $null -notes $null -Confirm:$false
        Reset-SnipeitLicenseOwner -id 2 -seat_id 5 -notes $null -Confirm:$false
        $requests = @(InModuleScope SnipeitPS { $script:sliceRequests.ToArray() })
        $requests[0].Body.PSObject.Properties.Name | Should -Contain 'seat_id'
        $requests[0].Body.seat_id | Should -BeNullOrEmpty
        foreach ($request in $requests) {
            $request.Body.PSObject.Properties.Name | Should -Contain 'notes'
            $request.Body.notes | Should -BeNullOrEmpty
        }
    }

    It 'Completion omits optional note and journal requires nonblank note' {
        Complete-SnipeitAssetMaintenance -id 2 -Confirm:$false
        $requests = @(InModuleScope SnipeitPS { $script:sliceRequests.ToArray() })
        $requests[0].Body.PSObject.Properties.Name | Should -Not -Contain 'note'
        { New-SnipeitAssetMaintenanceNote -id 2 -note ' ' -Confirm:$false } | Should -Throw
    }
}

Describe 'Maintenance relationship semantics' {
    InModuleScope SnipeitPS {
        BeforeEach {
            Mock Invoke-SnipeitMethod { [pscustomobject]@{id=2} }
            Mock Resolve-SnipeitMaintenanceTypeId { 9 }
            $create = @{asset_id=1;supplier_id=2;title='Inspect';start_date='2026-01-01';asset_maintenance_type='9'}
        }

        It 'Rejects any bound legacy assigned_to on New and Set before HTTP' {
            foreach ($legacy in @(3,$null,0)) {
                { New-SnipeitAssetMaintenance @create -assigned_to $legacy -Confirm:$false } | Should -Throw '*assigned_to*responsible_party_id*'
                { Set-SnipeitAssetMaintenance -id 2 -assigned_to $legacy -Confirm:$false } | Should -Throw '*assigned_to*responsible_party_id*'
            }
            Should -Invoke Invoke-SnipeitMethod -Times 0 -Exactly
            Should -Invoke Resolve-SnipeitMaintenanceTypeId -Times 0 -Exactly
        }

        It 'New does not advertise snapshot fields and preserves nullable responsible user' {
            (Get-Command New-SnipeitAssetMaintenance).Parameters.Keys | Should -Not -Contain 'checked_out_to_id'
            (Get-Command New-SnipeitAssetMaintenance).Parameters.Keys | Should -Not -Contain 'checked_out_to_type'
            New-SnipeitAssetMaintenance @create -responsible_party_id $null -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -Exactly -ParameterFilter {
                $Body.ContainsKey('responsible_party_id') -and $null -eq $Body.responsible_party_id -and -not $Body.ContainsKey('checked_out_to_id')
            }
        }

        It 'Set maps canonical server class for <Type>' -TestCases @(@{Type='User'},@{Type='Asset'},@{Type='Location'},@{Type='user'}) {
            param($Type)
            Set-SnipeitAssetMaintenance -id 2 -checked_out_to_id 3 -checked_out_to_type $Type -responsible_party_id 4 -Confirm:$false
            $canonical = @{user='User';asset='Asset';location='Location'}[$Type]
            Should -Invoke Invoke-SnipeitMethod -Times 1 -Exactly -ParameterFilter {
                $Body.checked_out_to_id -eq 3 -and $Body.checked_out_to_type -ceq "App\Models\$canonical" -and $Body.responsible_party_id -eq 4
            }
        }

        It 'Set clears both snapshot fields with explicit JSON null values' {
            Set-SnipeitAssetMaintenance -id 2 -checked_out_to_id $null -checked_out_to_type $null -responsible_party_id $null -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -Exactly -ParameterFilter {
                $Body.ContainsKey('checked_out_to_id') -and $Body.ContainsKey('checked_out_to_type') -and
                $null -eq $Body.checked_out_to_id -and $null -eq $Body.checked_out_to_type -and $null -eq $Body.responsible_party_id
            }
        }

        It 'Set rejects incomplete, mismatched or invalid snapshots' {
            foreach ($pair in @(@{checked_out_to_id=3},@{checked_out_to_type='User'},@{checked_out_to_id=$null;checked_out_to_type='User'},@{checked_out_to_id=3;checked_out_to_type=$null},@{checked_out_to_id=0;checked_out_to_type='User'},@{checked_out_to_id=3;checked_out_to_type='Supplier'})) {
                { Set-SnipeitAssetMaintenance -id 2 @pair -Confirm:$false } | Should -Throw
            }
            Should -Invoke Invoke-SnipeitMethod -Times 0 -Exactly
        }

        It 'Omission preserves relationships and WhatIf does not call HTTP' {
            Set-SnipeitAssetMaintenance -id 2 -title 'Updated' -Confirm:$false
            Should -Invoke Invoke-SnipeitMethod -Times 1 -Exactly -ParameterFilter {
                -not $Body.ContainsKey('checked_out_to_id') -and -not $Body.ContainsKey('checked_out_to_type') -and -not $Body.ContainsKey('responsible_party_id')
            }
            Set-SnipeitAssetMaintenance -id 2 -checked_out_to_id 3 -checked_out_to_type User -WhatIf
            New-SnipeitAssetMaintenance @create -responsible_party_id 3 -WhatIf
            Should -Invoke Invoke-SnipeitMethod -Times 1 -Exactly
        }
    }
}
