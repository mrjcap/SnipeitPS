BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Additional list query fields' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:querySession = [SnipeitSession]::new('https://contract.invalid', $key)
            $script:querySession.ThrottleLimit = 0
            $script:queryCalls = [System.Collections.Generic.List[object]]::new()
            Mock Invoke-RestMethod -ModuleName SnipeitPS {
                param($Uri)
                $parsed = [uri]$Uri
                $query = @{}
                foreach ($pair in $parsed.Query.TrimStart('?').Split('&')) {
                    $parts = $pair.Split('=', 2)
                    $query[[Net.WebUtility]::UrlDecode($parts[0])] = [Net.WebUtility]::UrlDecode($parts[1])
                }
                $script:queryCalls.Add(@{ Path = $parsed.AbsolutePath; Query = $query })
                [pscustomobject]@{ total = 1; rows = @([pscustomobject]@{ id = 1; name = 'Test' }) }
            }
        }

        Context '<Family> list filters' -ForEach @(
            @{ Family = 'Accessory'; Route = 'accessories'; Fields = @{ location_id = 2; order_number = 'PO & 1'; notes = 'Notes & more'; expand_company_hierarchy = $true }; NumericFlags = @(); Aliases = @{} }
            @{ Family = 'Asset'; Route = 'hardware'; Fields = @{ supplier_id = 2; rtd_location_id = 3; asset_eol_date = '2026-09-17'; assigned_to = 4; assigned_type = 'App\Models\User'; byod = $true; components = $true; status_type = 'Deployed'; expand_company_hierarchy = $true }; NumericFlags = @('byod', 'components'); Aliases = @{} }
            @{ Family = 'Category'; Route = 'categories'; Fields = @{ category_type = 'asset'; archived = $true; use_default_eula = $true; require_acceptance = $true; checkin_email = $true; created_by = 2; created_at = '2026-09-17 00:00:00'; updated_at = '2026-09-17 00:00:00' }; NumericFlags = @('use_default_eula', 'require_acceptance', 'checkin_email'); Aliases = @{} }
            @{ Family = 'Company'; Route = 'companies'; Fields = @{ parent_id = 2; created_by = 3; email = 'test@example.invalid'; tag_color = '#123456' }; NumericFlags = @(); Aliases = @{} }
            @{ Family = 'Component'; Route = 'components'; Fields = @{ supplier_id = 2; manufacturer_id = 3; model_number = 'M & 1'; order_number = 'PO & 1'; notes = 'Notes & more'; expand_company_hierarchy = $true }; NumericFlags = @(); Aliases = @{} }
            @{ Family = 'Consumable'; Route = 'consumables'; Fields = @{ supplier_id = 2; model_number = 'M & 1'; order_number = 'PO & 1'; notes = 'Notes & more'; expand_company_hierarchy = $true }; NumericFlags = @(); Aliases = @{} }
            @{ Family = 'Department'; Route = 'departments'; Fields = @{ tag_color = '#123456' }; NumericFlags = @(); Aliases = @{} }
            @{ Family = 'Group'; Route = 'groups'; Fields = @{ name = 'Group & 1' }; NumericFlags = @(); Aliases = @{} }
            @{ Family = 'License'; Route = 'licenses'; Fields = @{ created_by = 2; maintained = $true; expires = $true; deleted = $true; status = 'expiring'; expand_company_hierarchy = $true }; NumericFlags = @(); Aliases = @{} }
            @{ Family = 'Location'; Route = 'locations'; Fields = @{ company_id = 2; parent_id = 3; manager_id = 4; status = 'deleted' }; NumericFlags = @(); Aliases = @{} }
            @{ Family = 'Manufacturer'; Route = 'manufacturers'; Fields = @{ manufacturer_url = 'https://example.invalid/?x=1&y=2'; support_url = 'https://support.example.invalid'; warranty_lookup_url = 'https://warranty.example.invalid'; support_phone = '+30 210 1234567'; support_email = 'test@example.invalid'; deleted = $true; status = 'deleted' }; NumericFlags = @(); Aliases = @{ manufacturer_url = 'url' } }
            @{ Family = 'Model'; Route = 'models'; Fields = @{ name = 'Model & 1'; model_number = 'M & 1'; notes = 'Notes & more'; category_id = 2; depreciation_id = 3; requestable = $true; status = 'deleted' }; NumericFlags = @(); Aliases = @{} }
            @{ Family = 'Status'; Route = 'statuslabels'; Fields = @{ status_type = 'archived' }; NumericFlags = @(); Aliases = @{} }
            @{ Family = 'Supplier'; Route = 'suppliers'; Fields = @{ supplier_url = 'https://example.invalid/?x=1&y=2' }; NumericFlags = @(); Aliases = @{ supplier_url = 'url' } }
            @{ Family = 'User'; Route = 'users'; Fields = @{ first_name = 'Test'; last_name = 'User'; display_name = 'Test & User'; phone = '+30 210 1234567'; mobile = '+30 690 1234567'; website = 'https://example.invalid'; locale = 'en-US'; manager_id = 2; created_by = 3; start_date = '2026-09-17'; end_date = '2026-09-18'; activated = $true; vip = $true; autoassign_licenses = $true; two_factor_enrolled = $true; two_factor_optin = $true; admins = $true; superadmins = $true; expand_company_hierarchy = $true; manages_users_count = 0; manages_locations_count = 0; assigned_maintenances_count = 0 }; NumericFlags = @('activated', 'vip', 'autoassign_licenses', 'two_factor_enrolled', 'two_factor_optin'); Aliases = @{} }
        ) {
            It 'Encodes each supported query field on the collection route' {
                $parameters = $Fields.Clone()
                $parameters['filter'] = 'Text & more'
                & "Get-Snipeit$Family" @parameters -Session $script:querySession
                $script:queryCalls.Count | Should -Be 1
                $script:queryCalls[0].Path | Should -BeExactly "/api/v1/$Route"
                $query = $script:queryCalls[0].Query
                $query.filter | Should -BeExactly 'Text & more'
                foreach ($entry in $Fields.GetEnumerator()) {
                    $key = $entry.Key
                    if ($Aliases.ContainsKey($key)) { $key = $Aliases[$key] }
                    $query.ContainsKey($key) | Should -BeTrue
                    $expected = [string]$entry.Value
                    if ($entry.Key -in $NumericFlags) { $expected = [string][int]$entry.Value }
                    elseif ($entry.Value -is [bool]) { $expected = $entry.Value.ToString().ToLowerInvariant() }
                    $query[$key] | Should -BeExactly $expected
                }
            }

            It 'Keeps false flags and zero counts when paginating' {
                $parameters = $Fields.Clone()
                foreach ($field in @($parameters.Keys)) {
                    if ($parameters[$field] -is [bool]) { $parameters[$field] = $false }
                }
                & "Get-Snipeit$Family" @parameters -all -Session $script:querySession
                $script:queryCalls.Count | Should -Be 1
                $query = $script:queryCalls[0].Query
                $query.ContainsKey('all') | Should -BeFalse
                foreach ($entry in $parameters.GetEnumerator()) {
                    if ($entry.Value -is [bool]) {
                        $expected = if ($entry.Key -in $NumericFlags) { '0' } else { 'false' }
                        $query[$entry.Key] | Should -BeExactly $expected
                    } elseif ($entry.Value -is [int] -and $entry.Value -eq 0) {
                        $query[$entry.Key] | Should -BeExactly '0'
                    }
                }
            }

            It 'Omits unbound query fields' {
                & "Get-Snipeit$Family" -Session $script:querySession
                $script:queryCalls.Count | Should -Be 1
                $query = $script:queryCalls[0].Query
                foreach ($field in $Fields.Keys) { $query.ContainsKey($field) | Should -BeFalse }
                $query.ContainsKey('filter') | Should -BeFalse
            }
        }

        It 'Includes deleted users independently of pagination: <Paginate>, <IncludeDeleted>' -ForEach @(
            @{ Paginate = $false; IncludeDeleted = $true; Expected = 'true' }
            @{ Paginate = $true; IncludeDeleted = $true; Expected = 'true' }
            @{ Paginate = $true; IncludeDeleted = $false; Expected = 'false' }
        ) {
            Get-SnipeitUser -include_deleted $IncludeDeleted -all:$Paginate -Session $script:querySession
            $script:queryCalls.Count | Should -Be 1
            $script:queryCalls[0].Query.all | Should -BeExactly $Expected
            $script:queryCalls[0].Query.ContainsKey('include_deleted') | Should -BeFalse
        }

        It 'Uses numeric values for existing user SQL boolean filters' {
            Get-SnipeitUser -ldap_import $true -remote $false -Session $script:querySession
            $script:queryCalls.Count | Should -Be 1
            $script:queryCalls[0].Query.ldap_import | Should -BeExactly '1'
            $script:queryCalls[0].Query.remote | Should -BeExactly '0'
        }
    }
}
