BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Additional action field contracts' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:actionSession = [SnipeitSession]::new('https://contract.invalid', $key)
            $script:actionSession.ThrottleLimit = 0
            $script:actionCalls = [System.Collections.Generic.List[object]]::new()
            Mock Invoke-RestMethod -ModuleName SnipeitPS {
                param($Uri, $Body, $Method)
                $parsed = [uri]$Uri
                $query = @{}
                foreach ($pair in $parsed.Query.TrimStart('?').Split('&')) {
                    $parts = $pair.Split('=', 2)
                    $query[[Net.WebUtility]::UrlDecode($parts[0])] = [Net.WebUtility]::UrlDecode($parts[1])
                }
                $json = if ($Body) { [Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json }
                $script:actionCalls.Add(@{ Path = $parsed.AbsolutePath; Query = $query; RawQuery = $parsed.Query; Json = $json })
                if ($Method -eq 'Get') {
                    [pscustomobject]@{ total = 1; rows = @([pscustomobject]@{ id = 1 }) }
                } else {
                    [pscustomobject]@{ status = 'success'; payload = @{ id = 1 } }
                }
            }
        }

        Context '<Command> filters' -ForEach @(
            @{ Command = 'Get-SnipeitLicenseSeat'; Route = 'licenses/4/seats'; Fields = @{ status = 'available'; search = 'A & B'; order = 'asc'; sort = 'assigned_user.company' } }
            @{ Command = 'Get-SnipeitComponentAsset'; Route = 'components/4/assets'; Fields = @{ search = 'A & B' } }
            @{ Command = 'Get-SnipeitStatusAsset'; Route = 'statuslabels/4/assetlist'; Fields = @{ order = 'asc'; sort = 'name' } }
            @{ Command = 'Get-SnipeitUserAsset'; Route = 'users/4/assets'; Fields = @{ category_id = 2; model_id = 3 } }
            @{ Command = 'Get-SnipeitAccessoryOwner'; Route = 'accessories/4/checkedout'; Fields = @{ search = 'A & B' } }
            @{ Command = 'Get-SnipeitAssetFile'; Route = 'hardware/4/files'; Fields = @{ search = 'A & B'; order = 'asc'; sort = 'filename'; offset = 0; limit = 20 } }
            @{ Command = 'Get-SnipeitModelFile'; Route = 'models/4/files'; Fields = @{ search = 'A & B'; order = 'asc'; sort = 'filename'; offset = 0; limit = 20 } }
            @{ Command = 'Get-SnipeitUserEula'; Route = 'users/4/eulas'; Fields = @{ offset = 0; limit = 20 } }
        ) {
            It 'Serializes exact query keys and encoded values' {
                & $Command -id 4 @Fields -Session $script:actionSession
                $script:actionCalls.Count | Should -Be 1
                $script:actionCalls[0].Path | Should -BeExactly "/api/v1/$Route"
                foreach ($entry in $Fields.GetEnumerator()) {
                    $script:actionCalls[0].Query[$entry.Key] | Should -BeExactly ([string]$entry.Value)
                }
            }

            It 'Omits unbound optional filters' {
                & $Command -id 4 -Session $script:actionSession
                $script:actionCalls.Count | Should -Be 1
                foreach ($field in $Fields.Keys) {
                    $script:actionCalls[0].Query.ContainsKey($field) | Should -BeFalse
                }
            }
        }

        It 'Encodes activity filters and enables uploads only when requested' {
            Get-SnipeitActivity -filter 'A & B' -created_by 4 -action_source 'api' -remote_ip '127.0.0.1' -order asc -sort created_at -uploads -Session $script:actionSession
            $query = $script:actionCalls[0].Query
            $query.filter | Should -BeExactly 'A & B'
            $query.created_by | Should -BeExactly '4'
            $query.action_source | Should -BeExactly 'api'
            $query.remote_ip | Should -BeExactly '127.0.0.1'
            $query.order | Should -BeExactly 'asc'
            $query.sort | Should -BeExactly 'created_at'
            $query.uploads | Should -BeExactly 'true'
        }

        It 'Omits disabled uploads rather than sending a nonempty false string' {
            Get-SnipeitActivity -uploads:$false -Session $script:actionSession
            $script:actionCalls[0].Query.ContainsKey('uploads') | Should -BeFalse
        }

        It 'Queries deleted assets through <Selector> without changing lookup routing' -ForEach @(
            @{ Selector = 'asset_tag'; Value = 'TEST-4'; Route = 'bytag/TEST-4' }
            @{ Selector = 'serial'; Value = 'SERIAL-4'; Route = 'byserial/SERIAL-4' }
        ) {
            $parameters = @{ $Selector = $Value }
            Get-SnipeitAsset @parameters -deleted $true -Session $script:actionSession
            $script:actionCalls[0].Path | Should -BeExactly "/api/v1/hardware/$Route"
            $script:actionCalls[0].Query.deleted | Should -BeExactly 'true'
        }

        It 'Supports pagination when serial numbers are shared' {
            Get-SnipeitAsset -serial 'SERIAL-4' -limit 20 -offset 0 -all -Session $script:actionSession
            $script:actionCalls[0].Query.limit | Should -BeExactly '20'
            $script:actionCalls[0].Query.offset | Should -BeExactly '0'
            $script:actionCalls[0].Query.ContainsKey('all') | Should -BeFalse
        }

        It 'Passes <Target> assignment through asset <Mode> updates' -ForEach @(
            @{ Target = 'assigned_user'; Mode = 'single'; Ids = @(4) }
            @{ Target = 'assigned_asset'; Mode = 'single'; Ids = @(4) }
            @{ Target = 'assigned_location'; Mode = 'single'; Ids = @(4) }
            @{ Target = 'assigned_user'; Mode = 'bulk'; Ids = @(4, 5) }
            @{ Target = 'assigned_asset'; Mode = 'bulk'; Ids = @(4, 5) }
            @{ Target = 'assigned_location'; Mode = 'bulk'; Ids = @(4, 5) }
        ) {
            $parameters = @{ $Target = 12 }
            Set-SnipeitAsset -id $Ids @parameters -Session $script:actionSession -Confirm:$false
            $script:actionCalls.Count | Should -Be 1
            $script:actionCalls[0].Json.$Target | Should -Be 12
            $path = if ($Mode -eq 'single') { '/api/v1/hardware/4' } else { '/api/v1/hardware/bulk' }
            $script:actionCalls[0].Path | Should -BeExactly $path
        }

        It 'Rejects conflicting asset update assignment targets before HTTP' {
            { Set-SnipeitAsset -id 4 -assigned_user 12 -assigned_asset 13 -Session $script:actionSession -Confirm:$false } | Should -Throw
            $script:actionCalls.Count | Should -Be 0
        }

        It 'Keeps assignment updates under ShouldProcess' {
            Set-SnipeitAsset -id 4 -assigned_location 12 -Session $script:actionSession -WhatIf
            $script:actionCalls.Count | Should -Be 0
        }

        It 'Supports component expansion on asset show' {
            Get-SnipeitAsset -id 4 -components $false -Session $script:actionSession
            $script:actionCalls[0].Query.components | Should -BeExactly '0'
        }

        It 'Supports multiple models on the user asset route' {
            Get-SnipeitUserAsset -id 4 -model_id 3, 5 -Session $script:actionSession
            $script:actionCalls.Count | Should -Be 1
            $script:actionCalls[0].RawQuery | Should -Match 'model_id%5[Bb]%5[Dd]=3'
            $script:actionCalls[0].RawQuery | Should -Match 'model_id%5[Bb]%5[Dd]=5'
        }

        It 'Supports pagination controls on accessory checkouts without leaking all' {
            Get-SnipeitAccessoryOwner -id 4 -limit 20 -offset 0 -all -Session $script:actionSession
            $script:actionCalls.Count | Should -Be 1
            $script:actionCalls[0].Query.limit | Should -BeExactly '20'
            $script:actionCalls[0].Query.offset | Should -BeExactly '0'
            $script:actionCalls[0].Query.ContainsKey('all') | Should -BeFalse
        }

        It 'Sends checkin notes to the accessory pivot route including an empty note' -ForEach @(
            @{ Note = 'Checked in & inspected' }
            @{ Note = '' }
        ) {
            Reset-SnipeitAccessoryOwner -assigned_pivot_id 12 -note $Note -Session $script:actionSession -Confirm:$false
            $script:actionCalls.Count | Should -Be 1
            $script:actionCalls[0].Path | Should -BeExactly '/api/v1/accessories/12/checkin'
            $script:actionCalls[0].Json.note | Should -BeExactly $Note
        }

        It 'Preserves an explicit false requestable flag during asset checkout' {
            Set-SnipeitAssetOwner -id 4 -assigned_id 12 -requestable $false -Session $script:actionSession -Confirm:$false
            $script:actionCalls.Count | Should -Be 1
            $script:actionCalls[0].Json.requestable | Should -BeOfType [bool]
            $script:actionCalls[0].Json.requestable | Should -BeFalse
        }

        It 'Omits unbound checkout flags and checkin notes' {
            Set-SnipeitAssetOwner -id 4 -assigned_id 12 -Session $script:actionSession -Confirm:$false
            Reset-SnipeitAccessoryOwner -assigned_pivot_id 12 -Session $script:actionSession -Confirm:$false
            $script:actionCalls.Count | Should -Be 2
            $script:actionCalls[0].Json.PSObject.Properties.Name | Should -Not -Contain 'requestable'
            $script:actionCalls[1].Json.PSObject.Properties.Name | Should -Not -Contain 'note'
        }

        It 'Keeps action WhatIf paths free of HTTP calls' {
            Set-SnipeitAssetOwner -id 4 -assigned_id 12 -requestable $false -Session $script:actionSession -WhatIf
            Reset-SnipeitAccessoryOwner -assigned_pivot_id 12 -note 'Test' -Session $script:actionSession -WhatIf
            $script:actionCalls.Count | Should -Be 0
        }
    }
}
