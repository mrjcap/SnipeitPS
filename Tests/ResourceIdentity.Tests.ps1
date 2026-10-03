BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Request and assignment resource identities' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:identitySession = [SnipeitSession]::new('https://identity.invalid', $key)
            $script:identitySession.ThrottleLimit = 0
            $script:identityCalls = [System.Collections.Generic.List[string]]::new()
            Mock Invoke-RestMethod {
                param($Uri)
                $script:identityCalls.Add([string]$Uri)
                return [pscustomobject]@{ total = 1; rows = @($script:identityRow) }
            }
        }

        It 'Separates the request ID for <Type> requests when normalization is enabled' -ForEach @(
            @{ Type = 'asset' }
            @{ Type = 'consumable' }
        ) {
            $script:identityRow = [pscustomobject]@{ id = 9001; type = $Type; name = 'Requested item'; qty = 1 }
            $row = Get-SnipeitAccountRequest -NormalizeIdentity -Session $script:identitySession
            $row.request_id | Should -Be 9001
            $row.PSObject.Properties.Name | Should -Not -Contain 'id'
            $row.PSObject.Properties.Name | Should -Not -Contain 'asset_id'
            $row.PSObject.TypeNames | Should -Contain 'SnipeitPS.AccountRequest'
            $script:identityRow.id | Should -Be 9001
        }

        It 'Normalizes assignment IDs for <Command>' -ForEach @(
            @{ Command = 'Get-SnipeitUserAccessory'; Arguments = @{ id = 7 }; Resource = 'accessory'; Related = 'checkout_id' }
            @{ Command = 'Get-SnipeitAccessory'; Arguments = @{ user_id = 7 }; Resource = 'accessory'; Related = 'checkout_id' }
            @{ Command = 'Get-SnipeitUserLicense'; Arguments = @{ id = 7 }; Resource = 'license'; Related = 'seat_id' }
            @{ Command = 'Get-SnipeitLicense'; Arguments = @{ user_id = 7 }; Resource = 'license'; Related = 'seat_id' }
        ) {
            $script:identityRow = [pscustomobject]@{ id = 801; name = 'Assigned item' }
            $script:identityRow | Add-Member -NotePropertyName $Resource -NotePropertyValue ([pscustomobject]@{ id = 101 })
            $row = & $Command @Arguments -NormalizeIdentity -Session $script:identitySession
            $row.id | Should -Be 101
            $row.$Related | Should -Be 801
            $script:identityRow.id | Should -Be 801
            $row.$Resource.id | Should -Be 101
        }

        It 'Keeps legacy assignment rows unchanged for <Command>' -ForEach @(
            @{ Command = 'Get-SnipeitUserAccessory'; Related = 'checkout_id' }
            @{ Command = 'Get-SnipeitUserLicense'; Related = 'seat_id' }
        ) {
            $script:identityRow = [pscustomobject]@{ id = 101; name = 'Legacy item' }
            $row = & $Command -id 7 -Session $script:identitySession
            $row.id | Should -Be 101
            $row.PSObject.Properties.Name | Should -Not -Contain $Related
        }

        It 'Keeps legacy request rows and raw request envelopes unchanged' {
            $script:identityRow = [pscustomobject]@{ name = 'Legacy request'; type = 'asset'; qty = 1 }
            (Get-SnipeitAccountRequest -Session $script:identitySession).name | Should -Be 'Legacy request'
            $script:identityRow | Add-Member -NotePropertyName id -NotePropertyValue 9001
            $raw = Get-SnipeitAccountRequest -preserveResponse -Session $script:identitySession
            $raw.rows[0].id | Should -Be 9001
            $raw.rows[0].PSObject.Properties.Name | Should -Not -Contain 'request_id'
        }

        It 'Normalizes dictionary request rows without changing the response dictionary' {
            $script:identityRow = @{ id = 9001; type = 'asset'; name = 'Dictionary request' }
            $row = Get-SnipeitAccountRequest -NormalizeIdentity -Session $script:identitySession
            $row.request_id | Should -Be 9001
            $row.PSObject.Properties.Name | Should -Not -Contain 'id'
            $script:identityRow.id | Should -Be 9001
        }

        It 'Normalizes dictionary assignment rows for <Command>' -ForEach @(
            @{ Command = 'Get-SnipeitUserAccessory'; Resource = 'accessory'; Related = 'checkout_id' }
            @{ Command = 'Get-SnipeitUserLicense'; Resource = 'license'; Related = 'seat_id' }
        ) {
            $script:identityRow = @{ id = 801; $Resource = @{ id = 101 } }
            $row = & $Command -id 7 -NormalizeIdentity -Session $script:identitySession
            $row.id | Should -Be 101
            $row.$Related | Should -Be 801
            $script:identityRow.id | Should -Be 801
        }

        It 'Does not invoke cancellation when a request row has no asset identity' {
            $script:identityRow = [pscustomobject]@{ id = 9001; type = 'asset'; name = 'Request for asset 101' }
            $errors = @(Get-SnipeitAccountRequest -NormalizeIdentity -Session $script:identitySession |
                Remove-SnipeitAccountRequest -Session $script:identitySession -Confirm:$false -ErrorAction Continue 2>&1)
            $errors.Count | Should -Be 1
            $errors[0].FullyQualifiedErrorId | Should -Be 'InputObjectNotBound,Remove-SnipeitAccountRequest'
            $script:identityCalls.Count | Should -Be 1
        }

        It 'Updates the accessory resource rather than its checkout when rows are piped' {
            $script:identityRow = [pscustomobject]@{ id = 801; accessory = [pscustomobject]@{ id = 101 } }
            Get-SnipeitUserAccessory -id 7 -NormalizeIdentity -Session $script:identitySession |
                Set-SnipeitAccessory -name 'Changed name' -Session $script:identitySession -Confirm:$false
            $script:identityCalls[1] | Should -Be 'https://identity.invalid/api/v1/accessories/101'
        }

        It 'Normalizes IDs on every page of an assignment listing' {
            Mock Invoke-RestMethod {
                param($Uri)
                $offset = if ($Uri -match 'offset=1') { 1 } else { 0 }
                return [pscustomobject]@{ total = 2; rows = @([pscustomobject]@{
                    id = 801 + $offset
                    license = [pscustomobject]@{ id = 101 + $offset }
                }) }
            }
            $rows = @(Get-SnipeitUserLicense -id 7 -limit 1 -all -NormalizeIdentity -Session $script:identitySession)
            $rows.id | Should -Be @(101, 102)
            $rows.seat_id | Should -Be @(801, 802)
        }

        It 'Rejects an assignment row with an invalid resource ID rather than retaining its checkout ID' {
            $script:identityRow = [pscustomobject]@{ id = 801; accessory = [pscustomobject]@{ id = 0 } }
            { Get-SnipeitUserAccessory -id 7 -NormalizeIdentity -Session $script:identitySession -ErrorAction Stop } |
                Should -Throw -ExpectedMessage '*valid accessory ID*'
        }
    }
}
