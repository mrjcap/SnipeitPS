BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Current API fixes on existing commands' {
    InModuleScope SnipeitPS {
        BeforeAll {
            function New-CurrentApiHttpError {
                param([int]$Code, [string]$Json)
                $response = [pscustomobject]@{ StatusCode = $Code; Json = $Json }
                $response | Add-Member ScriptMethod GetResponseStream {
                    [IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes($this.Json))
                }
                $exception = [Exception]::new("HTTP $Code")
                $exception | Add-Member NoteProperty Response $response
                $record = [Management.Automation.ErrorRecord]::new($exception, 'CurrentApiHttpError', [Management.Automation.ErrorCategory]::InvalidOperation, $null)
                $record.ErrorDetails = [Management.Automation.ErrorDetails]::new($Json)
                $record
            }
        }

        BeforeEach {
            $key = ConvertTo-SecureString 'offline-test' -AsPlainText -Force
            $script:currentSession = [SnipeitSession]::new('https://current.invalid', $key)
            $script:currentSession.ThrottleLimit = 0
            $script:currentCalls = [Collections.Generic.List[object]]::new()
            $script:currentResponse = [pscustomobject]@{ status = 'success'; payload = [pscustomobject]@{ id = 2 }; messages = 'Saved' }
            $script:maintenanceRows = @{
                2 = [pscustomobject]@{ id = 2; name = 'Inspection'; tag_color = '&#35;123456' }
                3 = [pscustomobject]@{ id = 3; name = 'Service'; tag_color = '#abcdef' }
            }
            Mock Invoke-RestMethod {
                param($Uri, $Method, $Body)
                $parsed = if ($Body -is [byte[]]) { [Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json } else { $Body }
                $script:currentCalls.Add(@{ Uri = [string]$Uri; Method = $Method; Body = $parsed })
                if ($Method -eq 'Get' -and [string]$Uri -match '/maintenance-types/(\d+)$') {
                    return $script:maintenanceRows[[int]$Matches[1]]
                }
                $script:currentResponse
            }
        }

        It 'Preserves each maintenance color when renaming multiple IDs' {
            Set-SnipeitMaintenanceType -id 2,3 -name 'Updated' -Session $script:currentSession -Confirm:$false
            $script:currentCalls.Count | Should -Be 4
            $script:currentCalls[0].Method | Should -Be 'Get'
            $script:currentCalls[1].Body.tag_color | Should -BeExactly '#123456'
            $script:currentCalls[3].Body.tag_color | Should -BeExactly '#abcdef'
            $script:currentCalls[1].Body.name | Should -BeExactly 'Updated'
            $script:currentCalls[3].Body.name | Should -BeExactly 'Updated'
        }

        It 'Sends explicitly supplied color <Label> without a lookup' -ForEach @(
            @{ Label = 'value'; Color = '#aabbcc' }
            @{ Label = 'empty'; Color = '' }
            @{ Label = 'null'; Color = $null }
        ) {
            Set-SnipeitMaintenanceType -id 2 -name 'Updated' -tag_color $Color -Session $script:currentSession -Confirm:$false
            $script:currentCalls.Count | Should -Be 1
            $script:currentCalls[0].Method | Should -Be 'Patch'
            $script:currentCalls[0].Body.PSObject.Properties.Name | Should -Contain 'tag_color'
            $script:currentCalls[0].Body.tag_color | Should -Be $Color
        }

        It 'Preserves a stored null color and permits historical rows without a color field' {
            $script:maintenanceRows[2] = [pscustomobject]@{ id = 2; tag_color = $null }
            $script:maintenanceRows[3] = [pscustomobject]@{ id = 3; name = 'Historical' }
            Set-SnipeitMaintenanceType -id 2,3 -name 'Updated' -Session $script:currentSession -Confirm:$false
            $script:currentCalls[1].Body.PSObject.Properties.Name | Should -Contain 'tag_color'
            $script:currentCalls[1].Body.tag_color | Should -BeNullOrEmpty
            $script:currentCalls[3].Body.PSObject.Properties.Name | Should -Not -Contain 'tag_color'
        }

        It 'Refuses an empty, mismatched, or ambiguous maintenance lookup' -ForEach @(
            @{ Row = $null }
            @{ Row = [pscustomobject]@{ id = 99; tag_color = '#ffffff' } }
            @{ Row = @([pscustomobject]@{ id = 2 }, [pscustomobject]@{ id = 2 }) }
            @{ Row = [pscustomobject]@{ id = 'invalid'; tag_color = '#ffffff' } }
        ) {
            $script:maintenanceRows[2] = $Row
            { Set-SnipeitMaintenanceType -id 2 -name 'Updated' -Session $script:currentSession -Confirm:$false } | Should -Throw
            @($script:currentCalls | Where-Object Method -EQ 'Patch').Count | Should -Be 0
        }

        It 'Does not read or write maintenance data under WhatIf' {
            Set-SnipeitMaintenanceType -id 2 -name 'Updated' -Session $script:currentSession -WhatIf
            $script:currentCalls.Count | Should -Be 0
        }

        It 'Supports initial maintenance-type color without sending control fields' {
            New-SnipeitMaintenanceType -name 'Inspection' -tag_color '#123456' -Session $script:currentSession -Confirm:$false
            $script:currentCalls[0].Body.tag_color | Should -BeExactly '#123456'
            @($script:currentCalls[0].Body.PSObject.Properties).Count | Should -Be 2
        }

        It 'Sends explicit PreserveBlanks=<Enabled> on every import slice' -ForEach @(
            @{ Enabled = $true }
            @{ Enabled = $false }
        ) {
            $script:currentResponse = [pscustomobject]@{ status = 'success'; payload = @{ tally = @{ updated = 1 }; redirect_url = '/imports' } }
            foreach ($offset in @(0, 10)) {
                Invoke-SnipeitImport -import_id 5 -ImportType asset -Update -PreserveBlanks:$Enabled -Offset $offset -Limit 10 -Session $script:currentSession -Confirm:$false
            }
            $script:currentCalls.Count | Should -Be 2
            foreach ($call in $script:currentCalls) {
                $call.Body.'import-preserve-blanks' | Should -BeOfType [bool]
                $call.Body.'import-preserve-blanks' | Should -Be $Enabled
                $call.Uri | Should -BeExactly 'https://current.invalid/api/v1/imports/process/5'
                $call.Body.PSObject.Properties.Name | Should -Not -Contain 'PreserveBlanks'
            }
        }

        It 'Omits unbound blank preservation and blocks import WhatIf' {
            Invoke-SnipeitImport -import_id 5 -ImportType asset -Session $script:currentSession -Confirm:$false
            $script:currentCalls[0].Body.PSObject.Properties.Name | Should -Not -Contain 'import-preserve-blanks'
            Invoke-SnipeitImport -import_id 5 -ImportType asset -PreserveBlanks -Session $script:currentSession -WhatIf
            $script:currentCalls.Count | Should -Be 1
        }

        It 'Sends checkout-only reassign=<Enabled> on the license checkout action' -ForEach @(
            @{ Enabled = $true }
            @{ Enabled = $false }
        ) {
            Set-SnipeitLicenseOwner -id 2 -assigned_to 3 -seat_id 4 -reassign:$Enabled -Session $script:currentSession -Confirm:$false
            $call = $script:currentCalls[0]
            $call.Uri | Should -BeExactly 'https://current.invalid/api/v1/licenses/2/checkout'
            $call.Body.reassign | Should -BeOfType [bool]
            $call.Body.reassign | Should -Be $Enabled
        }

        It 'Omits unbound reassign and blocks reassignment WhatIf' {
            Set-SnipeitLicenseOwner -id 2 -assigned_to 3 -Session $script:currentSession -Confirm:$false
            $script:currentCalls[0].Body.PSObject.Properties.Name | Should -Not -Contain 'reassign'
            Set-SnipeitLicenseOwner -id 2 -assigned_to 3 -reassign -Session $script:currentSession -WhatIf
            $script:currentCalls.Count | Should -Be 1
        }

        It 'Preserves the server asset-create message only when explicitly requested' {
            $script:currentResponse = [pscustomobject]@{ status = 'success'; payload = [pscustomobject]@{ id = 2 }; messages = 'Created; requested checkout was not performed.' }
            $raw = New-SnipeitAsset -status_id 1 -model_id 1 -assigned_id 3 -checkout_to_type user -PreserveResponse -Session $script:currentSession -Confirm:$false
            $raw.messages | Should -BeExactly 'Created; requested checkout was not performed.'
            $raw.payload.id | Should -Be 2
            $script:currentCalls[0].Body.PSObject.Properties.Name | Should -Not -Contain 'PreserveResponse'
            $asset = New-SnipeitAsset -status_id 1 -model_id 1 -Session $script:currentSession -Confirm:$false
            $asset.id | Should -Be 2
            $asset.PSObject.TypeNames | Should -Contain 'SnipeitPS.Asset'
        }

        It 'Does not preserve business errors as successful asset-create output' {
            $script:currentResponse = [pscustomobject]@{ status = 'error'; payload = $null; messages = 'Denied' }
            { New-SnipeitAsset -status_id 1 -model_id 1 -PreserveResponse -Session $script:currentSession -Confirm:$false -ErrorAction Stop } | Should -Throw '*Denied*'
        }

        It 'Keeps real HTTP <Code> in <Mode> API errors without trusting body status' -ForEach @(
            @{ Code = 404; Mode = 'Legacy' }
            @{ Code = 409; Mode = 'Legacy' }
            @{ Code = 404; Mode = 'Direct' }
            @{ Code = 409; Mode = 'Direct' }
        ) {
            $script:currentHttpError = New-CurrentApiHttpError -Code $Code -Json '{"status":"error","StatusCode":200,"messages":"Conflict","payload":null}'
            Mock Invoke-RestMethod { throw $script:currentHttpError }
            $caught = $null
            try {
                if ($Mode -eq 'Legacy') {
                    Invoke-SnipeitMethod -Api '/api/v1/hardware/2' -Session $script:currentSession -ErrorAction Stop
                } else {
                    Invoke-SnipeitHttpRequest -Request @{ Uri = 'https://current.invalid/api/v1/hardware/2'; Method = 'Get' } -Session $script:currentSession
                }
            } catch { $caught = $_ }
            $caught | Should -Not -BeNullOrEmpty
            $caught.TargetObject.StatusCode | Should -Be $Code
        }
    }
}
