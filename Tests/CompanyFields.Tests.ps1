BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Company writable fields' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:testSession = [SnipeitSession]::new('https://contract.invalid', $key)
            $script:testSession.ThrottleLimit = 0
            $script:companyCalls = [System.Collections.Generic.List[object]]::new()
            Mock Invoke-RestMethod -ModuleName SnipeitPS {
                param($Body)
                $script:companyCalls.Add(([System.Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json))
                [pscustomobject]@{ status = 'success'; payload = @{ id = 1 } }
            }
        }

        It '<Command> serializes all newly supported fields without renaming keys' -ForEach @(
            @{ Command = 'New-SnipeitCompany'; Identity = @{ name = 'Example' } }
            @{ Command = 'Set-SnipeitCompany'; Identity = @{ id = 1 } }
        ) {
            $fields = @{ phone = '+30 2101234567'; fax = '+30 2107654321'; email = 'team@example.invalid'; tag_color = '#123abc'; notes = 'Company notes' }
            & $Command @Identity @fields -Session $script:testSession -Confirm:$false
            $script:companyCalls.Count | Should -Be 1
            foreach ($field in $fields.Keys) {
                $script:companyCalls[0].PSObject.Properties.Name | Should -Contain $field
                $script:companyCalls[0].$field | Should -Be $fields[$field]
            }
        }

        It '<Command> omits unbound fields' -ForEach @(
            @{ Command = 'New-SnipeitCompany'; Identity = @{ name = 'Example' } }
            @{ Command = 'Set-SnipeitCompany'; Identity = @{ id = 1; name = 'Example' } }
        ) {
            & $Command @Identity -Session $script:testSession -Confirm:$false
            $script:companyCalls.Count | Should -Be 1
            foreach ($field in @('phone', 'fax', 'email', 'tag_color', 'notes')) {
                $script:companyCalls[0].PSObject.Properties.Name | Should -Not -Contain $field
            }
        }

        It '<Command> retains explicit null and empty field values' -ForEach @(
            @{ Command = 'New-SnipeitCompany'; Identity = @{ name = 'Example' } }
            @{ Command = 'Set-SnipeitCompany'; Identity = @{ id = 1 } }
        ) {
            $fields = @{ phone = $null; fax = $null; email = $null; tag_color = ''; notes = ''; parent_id = $null }
            & $Command @Identity @fields -Session $script:testSession -Confirm:$false
            $script:companyCalls.Count | Should -Be 1
            foreach ($field in $fields.Keys) {
                $script:companyCalls[0].PSObject.Properties.Name | Should -Contain $field
                $script:companyCalls[0].$field | Should -BeExactly $fields[$field]
            }
        }

        It '<Command> makes zero HTTP requests with new fields under WhatIf' -ForEach @(
            @{ Command = 'New-SnipeitCompany'; Identity = @{ name = 'Example' } }
            @{ Command = 'Set-SnipeitCompany'; Identity = @{ id = 1 } }
        ) {
            & $Command @Identity -email 'team@example.invalid' -Session $script:testSession -WhatIf
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly -ModuleName SnipeitPS
        }
    }
}
