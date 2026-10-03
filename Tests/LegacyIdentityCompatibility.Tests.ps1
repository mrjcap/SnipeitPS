BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}
Describe '2.0.1 legacy identity compatibility' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = [Security.SecureString]::new()
            $key.AppendChar('x')
            $key.MakeReadOnly()
            $script:compatSession = [SnipeitSession]::new('https://compat.invalid', $key)
            $script:compatSession.ThrottleLimit = 0
            $script:compatUris = [Collections.Generic.List[string]]::new()
            Mock Invoke-RestMethod {
                param($Uri)
                $script:compatUris.Add(([uri]$Uri).AbsoluteUri)
                [pscustomobject]@{ total=1;rows=@($script:compatRow) }
            }
        }
        It 'preserves the account request ID for dictionary=<Dictionary>' -ForEach @(
            @{Dictionary=$false}, @{Dictionary=$true}
        ) {
            $data = @{id=9001;requestable=[pscustomobject]@{id=101};name='Request'}
            $script:compatRow = if ($Dictionary) { $data } else { [pscustomobject]$data }
            $row = Get-SnipeitAccountRequest -Session $script:compatSession
            $row.id | Should -Be 9001
            $row.request_id | Should -Be 9001
            $row.requestable.id | Should -Be 101
            $sourceKeys = if ($Dictionary) { $script:compatRow.Keys } else { $script:compatRow.PSObject.Properties.Name }
            $sourceKeys | Should -Not -Contain 'request_id'
        }
        It 'preserves the assignment ID for <Command> with dictionary=<Dictionary>' -ForEach @(
            @{Command='Get-SnipeitUserAccessory';Arguments=@{id=7};Resource='accessory';Related='checkout_id';Dictionary=$false},
            @{Command='Get-SnipeitAccessory';Arguments=@{user_id=7};Resource='accessory';Related='checkout_id';Dictionary=$false},
            @{Command='Get-SnipeitUserLicense';Arguments=@{id=7};Resource='license';Related='seat_id';Dictionary=$false},
            @{Command='Get-SnipeitLicense';Arguments=@{user_id=7};Resource='license';Related='seat_id';Dictionary=$false},
            @{Command='Get-SnipeitUserAccessory';Arguments=@{id=7};Resource='accessory';Related='checkout_id';Dictionary=$true},
            @{Command='Get-SnipeitUserLicense';Arguments=@{id=7};Resource='license';Related='seat_id';Dictionary=$true}
        ) {
            $data = @{id=801;$Resource=[pscustomobject]@{id=101}}
            $script:compatRow = if ($Dictionary) { $data } else { [pscustomobject]$data }
            $row = & $Command @Arguments -Session $script:compatSession
            $row.id | Should -Be 801
            $row.$Related | Should -Be 801
            $row."${Resource}_id" | Should -Be 101
            $script:compatRow.id | Should -Be 801
            $script:compatUris[0] | Should -Not -Match 'NormalizeIdentity'
        }
        It 'keeps existing explicit ID properties and their meanings' {
            $script:compatRow = [pscustomobject]@{id=801;accessory_id=501;checkout_id=601;accessory=[pscustomobject]@{id=101}}
            $row = Get-SnipeitUserAccessory -id 7 -Session $script:compatSession
            $row.id | Should -Be 801
            $row.accessory_id | Should -Be 501
            $row.checkout_id | Should -Be 601
        }
        It 'does not reject malformed nested IDs in legacy output' {
            $script:compatRow = [pscustomobject]@{id=801;accessory=[pscustomobject]@{id=0}}
            $row = Get-SnipeitUserAccessory -id 7 -Session $script:compatSession -ErrorAction Stop
            $row.id | Should -Be 801
            $row.accessory.id | Should -Be 0
        }
        It 'preserves assignment IDs on every legacy page' {
            Mock Invoke-RestMethod {
                param($Uri)
                $offset = if ($Uri -match 'offset=1') {1} else {0}
                [pscustomobject]@{total=2;rows=@([pscustomobject]@{id=801+$offset;license=[pscustomobject]@{id=101+$offset}})}
            }
            $rows = @(Get-SnipeitUserLicense -id 7 -limit 1 -all -Session $script:compatSession)
            $rows.id | Should -Be @(801,802)
            $rows.license_id | Should -Be @(101,102)
        }
        It 'preserves IDs when normalization is explicitly false' {
            $script:compatRow = [pscustomobject]@{id=9001;requestable=[pscustomobject]@{id=101}}
            $row = Get-SnipeitAccountRequest -NormalizeIdentity:$false -Session $script:compatSession
            $row.id | Should -Be 9001
            $script:compatUris[0] | Should -Not -Match 'NormalizeIdentity'
        }
        It 'allows explicit request normalization without changing raw responses' {
            $script:compatRow = [pscustomobject]@{id=9001;requestable=[pscustomobject]@{id=101}}
            $row = Get-SnipeitAccountRequest -NormalizeIdentity -Session $script:compatSession
            $row.request_id | Should -Be 9001
            $row.PSObject.Properties.Name | Should -Not -Contain 'id'
            $raw = Get-SnipeitAccountRequest -NormalizeIdentity -preserveResponse -Session $script:compatSession
            $raw.rows[0].id | Should -Be 9001
            $raw.rows[0].PSObject.Properties.Name | Should -Not -Contain 'request_id'
        }
        It 'allows opt-in normalization for <Command>' -ForEach @(
            @{Command='Get-SnipeitUserAccessory';Arguments=@{id=7};Resource='accessory'},
            @{Command='Get-SnipeitAccessory';Arguments=@{user_id=7};Resource='accessory'},
            @{Command='Get-SnipeitUserLicense';Arguments=@{id=7};Resource='license'},
            @{Command='Get-SnipeitLicense';Arguments=@{user_id=7};Resource='license'}
        ) {
            $script:compatRow = [pscustomobject]@{id=801;$Resource=[pscustomobject]@{id=101}}
            $row = & $Command @Arguments -NormalizeIdentity -Session $script:compatSession
            $row.id | Should -Be 101
            $script:compatUris[0] | Should -Not -Match 'NormalizeIdentity'
        }
        It 'keeps collection inventory IDs unchanged' {
            $script:compatRow = [pscustomobject]@{id=101;name='Inventory'}
            (Get-SnipeitAccessory -Session $script:compatSession).id | Should -Be 101
            (Get-SnipeitLicense -Session $script:compatSession).id | Should -Be 101
        }
    }
}
