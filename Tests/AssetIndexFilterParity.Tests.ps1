BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Shared asset index filter parity' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:filterSession = [SnipeitSession]::new('https://contract.invalid', $key)
            $script:filterSession.ThrottleLimit = 0
            $script:filterUris = [System.Collections.Generic.List[string]]::new()
            Mock Invoke-RestMethod {
                param($Uri)
                $script:filterUris.Add(([uri]$Uri).AbsoluteUri)
                [pscustomobject]@{ total = 1; rows = @([pscustomobject]@{ id = 7 }) }
            }
        }

        Context '<Command> shared asset filters' -ForEach @(
            @{ Command = 'Get-SnipeitDepreciationReport'; Required = @{}; Path = '/reports/depreciation' }
            @{ Command = 'Get-SnipeitAssetDue'; Required = @{ Action = 'Checkin'; Status = 'Due' }; Path = '/hardware/checkins/due' }
        ) {
            It 'Serializes <Field> using the server query key' -ForEach @(
                @{ Field = 'filter'; Value = "name: caf$([char]0xE9) & laptop"; Expected = "name: caf$([char]0xE9) & laptop" }
                @{ Field = 'asset_tag'; Value = 'tag / 1'; Expected = 'tag / 1' }
                @{ Field = 'serial'; Value = 'S&2'; Expected = 'S&2' }
                @{ Field = 'status_type'; Value = 'Deleted'; Expected = 'Deleted' }
                @{ Field = 'status_id'; Value = 2; Expected = '2' }
                @{ Field = 'category_id'; Value = 3; Expected = '3' }
                @{ Field = 'location_id'; Value = 4; Expected = '4' }
                @{ Field = 'rtd_location_id'; Value = 5; Expected = '5' }
                @{ Field = 'supplier_id'; Value = 6; Expected = '6' }
                @{ Field = 'company_id'; Value = 7; Expected = '7' }
                @{ Field = 'manufacturer_id'; Value = 8; Expected = '8' }
                @{ Field = 'depreciation_id'; Value = 9; Expected = '9' }
                @{ Field = 'order_number'; Value = '0'; Expected = '0' }
                @{ Field = 'asset_eol_date'; Value = [datetime]'2026-12-01'; Expected = '2026-12-01' }
                @{ Field = 'requestable'; Value = $true; Expected = 'true' }
                @{ Field = 'requestable'; Value = $false; Expected = 'false' }
                @{ Field = 'byod'; Value = $false; Expected = '0' }
                @{ Field = 'byod'; Value = $true; Expected = '1' }
                @{ Field = 'components'; Value = $false; Expected = '0' }
                @{ Field = 'components'; Value = $true; Expected = '1' }
                @{ Field = 'expand_company_hierarchy'; Value = $false; Expected = 'false' }
            ) {
                $parameters = @{ $Field = $Value }
                & $Command @Required @parameters -Session $script:filterSession
                $script:filterUris.Count | Should -Be 1
                $script:filterUris[0] | Should -Match ([regex]::Escape("${Path}?"))
                $escaped = [System.Net.WebUtility]::UrlEncode($Expected)
                $script:filterUris[0] | Should -Match "[?&]$Field=$([regex]::Escape($escaped))(&|$)"
            }

            It 'Serializes model arrays and custom-field columns without a generic body' {
                & $Command @Required -model_id 3, 4 -customfields @{ _snipeit_room_12 = 'Floor & 2' } -all -Session $script:filterSession
                $query = [System.Net.WebUtility]::UrlDecode($script:filterUris[0])
                $query | Should -Match '[?&]model_id\[\]=3(&|$)'
                $query | Should -Match '[?&]model_id\[\]=4(&|$)'
                $script:filterUris[0] | Should -Match '[?&]_snipeit_room_12=Floor\+%26\+2(&|$)'
                $query | Should -Not -Match '[?&](customfields|all|Action|Status)='
            }

            It 'Rejects custom-field keys that could override typed filters' {
                { & $Command @Required -customfields @{ company_id = 9 } -Session $script:filterSession } | Should -Throw '*custom*'
                $script:filterUris.Count | Should -Be 0
            }

            It 'Preserves assignment IDs and canonical model names together' {
                & $Command @Required -assigned_to 5 -assigned_type 'App\Models\User' -Session $script:filterSession
                $query = [System.Net.WebUtility]::UrlDecode($script:filterUris[0])
                $query | Should -Match '[?&]assigned_to=5(&|$)'
                $query | Should -Match '[?&]assigned_type=App\\Models\\User(&|$)'
            }

            It 'Omits unbound filters and never sends due route selectors as filters' {
                & $Command @Required -Session $script:filterSession
                $script:filterUris[0] | Should -Not -Match '[?&](status|Action|byod|components|company_id|requestable)='
            }
        }

        It 'Keeps the due Status selector separate from the asset status filter' {
            Get-SnipeitAssetDue -Action Audit -Status Overdue -asset_status Archived -Session $script:filterSession
            $script:filterUris[0] | Should -Match '/hardware/audits/overdue\?'
            $script:filterUris[0] | Should -Match '[?&]status=Archived(&|$)'
        }

        It 'Preserves existing positional arguments for the depreciation report' {
            Get-SnipeitDepreciationReport 'laptop' 'name' 'desc' 2 10 $script:filterSession
            $script:filterUris.Count | Should -Be 1
            $query = [System.Net.WebUtility]::UrlDecode($script:filterUris[0])
            foreach ($pair in @('search=laptop', 'sort=name', 'order=desc', 'offset=2', 'limit=10')) {
                $query | Should -Match "[?&]$pair(&|$)"
            }
            $query | Should -Not -Match '[?&](filter|status|status_type|status_id)='
        }

        It 'Accepts the legacy status filter for the depreciation report' {
            Get-SnipeitDepreciationReport -status Pending -Session $script:filterSession
            $script:filterUris[0] | Should -Match '[?&]status=Pending(&|$)'
        }

        It 'Supports model arrays and custom-field sorting in the ordinary asset list' {
            Get-SnipeitAsset -model_id 3, 4 -sort custom_fields._snipeit_room_12 -Session $script:filterSession
            $query = [System.Net.WebUtility]::UrlDecode($script:filterUris[0])
            $query | Should -Match '[?&]model_id\[\]=3(&|$)'
            $query | Should -Match '[?&]model_id\[\]=4(&|$)'
            $query | Should -Match '[?&]sort=custom_fields\._snipeit_room_12(&|$)'
        }
    }
}
