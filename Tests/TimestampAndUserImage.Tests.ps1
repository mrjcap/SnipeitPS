BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Timestamp and user image wire contracts' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:testSession = [SnipeitSession]::new('https://contract.invalid', $key)
            $script:testSession.ThrottleLimit = 0
            $script:wireCalls = [System.Collections.Generic.List[object]]::new()
            $script:imagePath = Join-Path $TestDrive 'avatar.png'
            $script:imageBytes = [Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=')
            [IO.File]::WriteAllBytes($script:imagePath, $script:imageBytes)
            Mock Invoke-RestMethod -ModuleName SnipeitPS {
                param($Body, $Form, $Uri, $Method)
                $json = if ($Body) { [Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json }
                $script:wireCalls.Add(@{ Json = $json; Form = $Form; Uri = $Uri; Method = $Method })
                [pscustomobject]@{ status = 'success'; payload = @{ id = 1 } }
            }
        }

        It 'Preserves checkout time while keeping purchase_date date-only' {
            $date = [datetime]'2026-09-17T12:34:56'
            Set-SnipeitAsset -id 1 -last_checkout $date -purchase_date $date -Session $script:testSession -Confirm:$false
            $script:wireCalls.Count | Should -Be 1
            $script:wireCalls[0].Json.last_checkout | Should -BeExactly '2026-09-17 12:34:56'
            $script:wireCalls[0].Json.purchase_date | Should -BeExactly '2026-09-17'
        }

        It '<Command> sends image content under <Field>' -ForEach @(
            @{ Command = 'New-SnipeitUser'; Identity = @{ first_name = 'Test'; last_name = 'User'; username = 'test' }; Field = 'avatar'; Route = 'users'; Method = 'post' }
            @{ Command = 'Set-SnipeitUser'; Identity = @{ id = 1 }; Field = 'avatar'; Route = 'users/1'; Method = 'Patch' }
            @{ Command = 'Set-SnipeitCompany'; Identity = @{ id = 1 }; Field = 'image'; Route = 'companies/1'; Method = 'Patch' }
        ) {
            & $Command @Identity -image $script:imagePath -Session $script:testSession -Confirm:$false
            $script:wireCalls.Count | Should -Be 1
            $call = $script:wireCalls[0]
            $call.Uri | Should -BeExactly "https://contract.invalid/api/v1/$Route"
            if ($PSVersionTable.PSVersion.Major -ge 7) {
                $call.Method | Should -Be 'POST'
                $call.Form._method | Should -Be $Method
                $call.Form[$Field] | Should -BeOfType ([IO.FileInfo])
                $call.Form[$Field].FullName | Should -Be $script:imagePath
                $keys = $call.Form.Keys
            } else {
                $call.Method | Should -Be $Method
                $call.Json.$Field | Should -BeExactly ('data:image/png;base64,' + [Convert]::ToBase64String($script:imageBytes))
                $keys = $call.Json.PSObject.Properties.Name
            }
            $keys | Should -Contain $Field
            $keys | Should -Not -Contain $(if ($Field -eq 'avatar') { 'image' } else { 'avatar' })
        }

        It 'Retains image_delete without adding an upload field' {
            Set-SnipeitUser -id 1 -image_delete -Session $script:testSession -Confirm:$false
            $script:wireCalls.Count | Should -Be 1
            $script:wireCalls[0].Json.image_delete | Should -BeTrue
            $script:wireCalls[0].Json.PSObject.Properties.Name | Should -Not -Contain 'avatar'
            $script:wireCalls[0].Json.PSObject.Properties.Name | Should -Not -Contain 'image'
        }

        It '<Command> sends no image under WhatIf' -ForEach @(
            @{ Command = 'New-SnipeitUser'; Identity = @{ first_name = 'Test'; last_name = 'User'; username = 'test' } }
            @{ Command = 'Set-SnipeitUser'; Identity = @{ id = 1 } }
        ) {
            & $Command @Identity -image $script:imagePath -Session $script:testSession -WhatIf
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly -ModuleName SnipeitPS
        }
    }
}
