BeforeDiscovery { Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force }
Describe 'Parameters found during the current API family re-audit' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $testKey = [Security.SecureString]::new()
            foreach ($character in 'offline'.ToCharArray()) { $testKey.AppendChar($character) }
            $testKey.MakeReadOnly()
            $script:reauditSession = [SnipeitSession]::new('https://reaudit.invalid', $testKey)
            $script:reauditCalls = [Collections.Generic.List[string]]::new()
            Mock Invoke-RestMethod {
                param($Uri)
                $script:reauditCalls.Add(([uri]$Uri).AbsoluteUri)
                [pscustomobject]@{total=0;rows=@();results=@();pagination=@{more=$false}}
            }
        }
        It 'sends explicit past_eol booleans through <Command>' -ForEach @(
            @{Command='Get-SnipeitAsset';Extra=@{}},
            @{Command='Get-SnipeitAssetDue';Extra=@{Action='Audit';Status='Due'}},
            @{Command='Get-SnipeitDepreciationReport';Extra=@{}}
        ) {
            & $Command @Extra -past_eol $true -Session $script:reauditSession
            $script:reauditCalls[0] | Should -Match 'past_eol=true'
            & $Command @Extra -past_eol $false -Session $script:reauditSession
            $script:reauditCalls[1] | Should -Match 'past_eol=false'
            & $Command @Extra -Session $script:reauditSession
            $script:reauditCalls[2] | Should -Not -Match 'past_eol='
        }
        It 'does not accept past_eol for an individual asset lookup' {
            { Get-SnipeitAsset -id 7 -past_eol $true -Session $script:reauditSession } | Should -Throw
            $script:reauditCalls.Count | Should -Be 0
        }
        It 'filters accessory collection requestability without changing omission' {
            Get-SnipeitAccessory -requestable $true -Session $script:reauditSession
            $script:reauditCalls[0] | Should -Match '/accessories\?'
            $script:reauditCalls[0] | Should -Match 'requestable=true'
            Get-SnipeitAccessory -requestable $false -Session $script:reauditSession
            $script:reauditCalls[1] | Should -Match 'requestable=false'
            Get-SnipeitAccessory -Session $script:reauditSession
            $script:reauditCalls[2] | Should -Not -Match 'requestable='
        }
        It 'filters hardware select lists by requesting user' {
            Get-SnipeitSelectList -EntityType Asset -assignedTo 7 -Session $script:reauditSession
            $script:reauditCalls[0] | Should -Match '/hardware/selectlist\?'
            $script:reauditCalls[0] | Should -Match 'assignedTo=7'
            $script:reauditCalls[0] | Should -Not -Match 'Session='
        }
        It 'sends batch location exclusions with the existing scalar exclusion' {
            Get-SnipeitSelectList -EntityType Location -excludeIds 7,8 -excludeId 9 -Session $script:reauditSession
            $script:reauditCalls[0] | Should -Match 'excludeIds=7%2C8'
            $script:reauditCalls[0] | Should -Match 'excludeId=9'
        }
        It 'rejects cross-entity select-list filters before HTTP' {
            { Get-SnipeitSelectList -EntityType Location -assignedTo 7 -Session $script:reauditSession } | Should -Throw
            { Get-SnipeitSelectList -EntityType Asset -excludeIds 7,8 -Session $script:reauditSession } | Should -Throw
            $script:reauditCalls.Count | Should -Be 0
        }
        It 'rejects nonpositive select-list filter IDs' {
            { Get-SnipeitSelectList -EntityType Asset -assignedTo 0 -Session $script:reauditSession } | Should -Throw
            { Get-SnipeitSelectList -EntityType Location -excludeIds 7,0 -Session $script:reauditSession } | Should -Throw
            $script:reauditCalls.Count | Should -Be 0
        }
        It 'sends search, sort, and order for <Command>' -ForEach @(
            @{Command='Get-SnipeitUserAccessory';Leaf='accessories';Sort='created_at';Order='desc'},
            @{Command='Get-SnipeitUserLicense';Leaf='licenses';Sort='name';Order='asc'}
        ) {
            & $Command -id 7 -search 'a & b' -sort created_at -order desc -Session $script:reauditSession
            $script:reauditCalls[0] | Should -Match "/users/7/$Leaf\?"
            $script:reauditCalls[0] | Should -Match 'search=a\+%26\+b'
            $script:reauditCalls[0] | Should -Match 'sort=created_at'
            $script:reauditCalls[0] | Should -Match 'order=desc'
            & $Command -id 7 -Session $script:reauditSession
            $script:reauditCalls[1] | Should -Match "sort=$Sort"
            $script:reauditCalls[1] | Should -Match "order=$Order"
            $script:reauditCalls[1] | Should -Not -Match 'search=|Session='
        }
    }
}
