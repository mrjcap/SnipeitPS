BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}
Describe 'Custom field format wire contracts' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $script:formatSession = [SnipeitSession]::new('https://contract.invalid', (ConvertTo-SecureString 'test-only' -AsPlainText -Force))
            $script:formatSession.ThrottleLimit = 0
            $script:formatCalls = [System.Collections.Generic.List[object]]::new()
            Mock Invoke-RestMethod -ModuleName SnipeitPS {
                param($Body)
                $script:formatCalls.Add(([Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json))
                [pscustomobject]@{ status = 'success'; payload = @{ id = 1 } }
            }
        }
        It 'Canonicalizes <Format> and <Element> for create and update' -ForEach @(
            'ANY,ALPHA,ALPHA-DASH,NUMERIC,ALPHA-NUMERIC,EMAIL,DATE,DATETIME,URL,IP,IPV4,IPV6,MAC,BOOLEAN,PHONE,FAX' -split ',' | ForEach-Object {
                @{ Format = $_; Element = switch ($_) { DATE { 'date_picker' } DATETIME { 'datetime_picker' } ANY { 'markdown-textarea' } default { 'text' } } }
            }
        ) {
            $fields = @{ format = $Format.ToLowerInvariant(); element = $Element.ToUpperInvariant(); Session = $script:formatSession; Confirm = $false }
            New-SnipeitCustomField -name 'Example' @fields
            Set-SnipeitCustomField -id 1 @fields
            $script:formatCalls.Count | Should -Be 2
            foreach ($body in $script:formatCalls) {
                $body.format | Should -BeExactly $Format
                $body.element | Should -BeExactly $Element
                $body.PSObject.Properties.Name | Should -Not -Contain 'custom_format'
            }
        }
        It 'Preserves regex rule <_> in the single format wire field' -ForEach @('regex:/^\d+$/', 'regex:#^["a-z/]+$#iu') {
            New-SnipeitCustomField -name 'Code' -element text -format 'custom regex' -custom_format $_ -Session $script:formatSession -Confirm:$false
            $script:formatCalls.Count | Should -Be 1
            $script:formatCalls[0].format | Should -BeExactly $_
            $script:formatCalls[0].PSObject.Properties.Name | Should -Not -Contain 'custom_format'
        }
        It 'Rejects missing or unprefixed regex <_> before HTTP' -ForEach @('', ' ', '^\d+$', 'regex:') {
            { New-SnipeitCustomField -name 'Code' -element text -format 'CUSTOM REGEX' -custom_format $_ -Session $script:formatSession -Confirm:$false } | Should -Throw
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly -ModuleName SnipeitPS
        }
        It 'Rejects custom_format updates with or without the selector' -ForEach @(@{ Options = @{} }, @{ Options = @{ format = 'CUSTOM REGEX' } }) {
            { Set-SnipeitCustomField -id 1 @Options -custom_format 'regex:/^\d+$/' -Session $script:formatSession -Confirm:$false } | Should -Throw '*does not support custom regex updates*'
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly -ModuleName SnipeitPS
        }
        It 'Omits format and element during an unrelated update' {
            Set-SnipeitCustomField -id 1 -name 'Renamed' -Session $script:formatSession -Confirm:$false
            $script:formatCalls.Count | Should -Be 1
            foreach ($key in @('format', 'custom_format', 'element')) { $script:formatCalls[0].PSObject.Properties.Name | Should -Not -Contain $key }
        }
        It 'Makes no HTTP requests under WhatIf for valid creation and update' {
            New-SnipeitCustomField -name 'Code' -element text -format 'CUSTOM REGEX' -custom_format 'regex:/^\d+$/' -Session $script:formatSession -WhatIf
            Set-SnipeitCustomField -id 1 -format EMAIL -Session $script:formatSession -WhatIf
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly -ModuleName SnipeitPS
        }
    }
}
