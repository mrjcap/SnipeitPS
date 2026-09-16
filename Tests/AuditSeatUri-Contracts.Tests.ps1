BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Audit, license seat, and URI server contracts' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $script:SnipeitPSSession.url = 'https://contract.invalid'
            $script:SnipeitPSSession.apiKey = 'test-only-key'
            $script:SnipeitPSSession.throttleLimit = 0
            $script:requests = [System.Collections.Generic.List[object]]::new()
            Mock Invoke-RestMethod {
                $parsed = if ($Body) { [Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json } else { $null }
                $script:requests.Add([pscustomobject]@{ Uri = $Uri.OriginalString; Method = $Method; Body = $parsed })
                [pscustomobject]@{ status = 'success'; messages = 'Saved'; payload = [pscustomobject]@{ id = 1 } }
            }
        }

        It '<Command> sends raw serial audit_key with audit_by_field' -TestCases @(
            @{ Command = 'New-SnipeitAudit' }, @{ Command = 'Update-SnipeitAssetAudit' }
        ) {
            param($Command)
            & $Command -serial 'ABC%20/+' -Confirm:$false
            $script:requests[0].Body.audit_by_field | Should -Be 'serial'
            $script:requests[0].Body.audit_key | Should -Be 'ABC%20/+'
            $script:requests[0].Body.PSObject.Properties.Name | Should -Not -Contain 'serial'
            $script:requests[0].Uri | Should -Be 'https://contract.invalid/api/v1/hardware/audit'
        }

        It '<Command> retains tag, ID, bulk and WhatIf alternatives' -TestCases @(
            @{ Command = 'New-SnipeitAudit' }, @{ Command = 'Update-SnipeitAssetAudit' }
        ) {
            param($Command)
            & $Command -asset_tag 'tag' -Confirm:$false
            & $Command -id 5 -note x -Confirm:$false
            & $Command -id 5,6 -note x -Confirm:$false
            & $Command -serial 'serial' -WhatIf
            $script:requests.Count | Should -Be 3
            $script:requests[0].Body.asset_tag | Should -Be 'tag'
            $script:requests[1].Uri | Should -Be 'https://contract.invalid/api/v1/hardware/5/audit'
            $script:requests[2].Body.ids | Should -Be @(5,6)
        }

        It 'Set-SnipeitLicenseSeat maps notes-only and each exclusive target' {
            Set-SnipeitLicenseSeat -id 1 -seat_id 2 -note 'Issued' -Confirm:$false
            Set-SnipeitLicenseSeat -id 1 -seat_id 2 -assigned_to 4 -note 'User' -Confirm:$false
            Set-SnipeitLicenseSeat -id 1 -seat_id 2 -asset_id 5 -Confirm:$false
            $script:requests[0].Body.notes | Should -Be 'Issued'
            $script:requests[0].Body.PSObject.Properties.Name | Should -Not -Contain 'note'
            $script:requests[1].Body.assigned_to | Should -Be 4
            $script:requests[2].Body.asset_id | Should -Be 5
        }

        It 'Set-SnipeitLicenseSeat rejects two non-null targets before HTTP' {
            { Set-SnipeitLicenseSeat -id 1 -seat_id 2 -assigned_to 4 -asset_id 5 -Confirm:$false } | Should -Throw '*assigned_to*asset_id*'
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly
        }

        It 'Set-SnipeitLicenseSeat preserves explicit assignment nulls for checkin' {
            Set-SnipeitLicenseSeat -id 1 -seat_id 2 -assigned_to $null -asset_id $null -Confirm:$false
            $script:requests[0].Body.PSObject.Properties.Name | Should -Contain 'assigned_to'
            $script:requests[0].Body.PSObject.Properties.Name | Should -Contain 'asset_id'
            $script:requests[0].Body.assigned_to | Should -BeNullOrEmpty
            $script:requests[0].Body.asset_id | Should -BeNullOrEmpty
        }

        It 'Get-SnipeitAsset escapes raw tag and serial <Raw> once' -TestCases @(
            @{ Raw = 'ABC DEF'; Encoded = 'ABC%20DEF' },
            @{ Raw = 'ABC%20DEF'; Encoded = 'ABC%2520DEF' },
            @{ Raw = 'A/B'; Encoded = 'A%2FB' },
            @{ Raw = '100%'; Encoded = '100%25' },
            @{ Raw = 'A+#?'; Encoded = 'A%2B%23%3F' },
            @{ Raw = ([string][char]0x03A9); Encoded = '%CE%A9' }
        ) {
            param($Raw, $Encoded)
            Get-SnipeitAsset -asset_tag $Raw
            Get-SnipeitAsset -serial $Raw
            ($script:requests[0].Uri -split '\?')[0] | Should -Be "https://contract.invalid/api/v1/hardware/bytag/$Encoded"
            ($script:requests[1].Uri -split '\?')[0] | Should -Be "https://contract.invalid/api/v1/hardware/byserial/$Encoded"
        }
    }
}
