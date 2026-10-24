BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Restore-SnipeitComponent public contract' {
    It 'exports the command exactly once through the manifest' {
        $manifest = Import-PowerShellDataFile "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1"
        @($manifest.FunctionsToExport | Where-Object { $_ -eq 'Restore-SnipeitComponent' }).Count | Should -Be 1
        (Get-Module SnipeitPS).ExportedFunctions.ContainsKey('Restore-SnipeitComponent') | Should -BeTrue
    }

    It 'documents all parameters in Markdown and exactly one compiled help entry' {
        $path = "$PSScriptRoot/../docs/Restore-SnipeitComponent.md"
        Test-Path $path | Should -BeTrue
        $markdown = [IO.File]::ReadAllText($path)
        $markdown | Should -Not -Match '\{\{.*?\}\}'
        [xml]$maml = [IO.File]::ReadAllText("$PSScriptRoot/../SnipeitPS/en-US/SnipeitPS-help.xml")
        $nodes = @($maml.SelectNodes('//*[local-name()="command"]') | Where-Object {
            $_.SelectSingleNode('./*[local-name()="details"]/*[local-name()="name"]').InnerText -eq 'Restore-SnipeitComponent'
        })
        $nodes.Count | Should -Be 1
        $nodes[0].OuterXml | Should -Not -Match '\{\{.*?\}\}'
        $parameters = @($nodes[0].SelectNodes('./*[local-name()="parameters"]/*[local-name()="parameter"]/*[local-name()="name"]') | ForEach-Object InnerText)
        foreach ($name in @('id','Unarchive','Session','WhatIf','Confirm')) {
            $markdown | Should -Match ('(?im)^### -' + $name + '\r?$')
            $parameters | Should -Contain $name
        }
        $nodes[0].OuterXml | Should -Match '/components/\{id\}/restore'
        $nodes[0].OuterXml | Should -Match '/components/\{id\}/unarchive'
        $nodes[0].OuterXml | Should -Match 'delete permission'
        $nodes[0].OuterXml | Should -Match 'update permission'
    }

    InModuleScope SnipeitPS {
        BeforeEach {
            $script:restoreSession = [SnipeitSession]::new('https://restore.invalid', (ConvertTo-SecureString 'offline-restore' -AsPlainText -Force))
            $script:restoreSession.ThrottleLimit = 0
            $script:restoreCalls = [Collections.Generic.List[object]]::new()
            $script:restoreResponse = [pscustomobject]@{ status = 'success'; messages = 'Restored'; payload = $null }
            $script:restoreHttpError = $null
            Mock Invoke-RestMethod {
                param($Uri, $Method, $Body, $Headers)
                $json = if ($Body -is [byte[]]) { [Text.Encoding]::UTF8.GetString($Body) } else { [string]$Body }
                $script:restoreCalls.Add([pscustomobject]@{ Uri = ([uri]$Uri).AbsoluteUri; Method = [string]$Method; Json = $json; Authorization = $Headers.Authorization })
                if ($null -ne $script:restoreHttpError) { throw $script:restoreHttpError }
                $script:restoreResponse
            }
        }

        Context '<Mode> operations' -ForEach @(
            @{ Mode = 'restore'; Unarchive = $false },
            @{ Mode = 'unarchive'; Unarchive = $true }
        ) {
            It 'posts an empty JSON object using the explicit session and forwards null success' {
                $output = Restore-SnipeitComponent -id 7 -Unarchive:$Unarchive -Session $script:restoreSession -Confirm:$false
                $script:restoreCalls.Count | Should -Be 1
                $script:restoreCalls[0].Uri | Should -Be "https://restore.invalid/api/v1/components/7/$Mode"
                $script:restoreCalls[0].Method | Should -Be 'POST'
                $script:restoreCalls[0].Json | Should -Be '{}'
                $script:restoreCalls[0].Authorization | Should -Be 'Bearer offline-restore'
                $output | Should -BeNullOrEmpty
            }

            It 'routes each explicit array ID exactly once' {
                Restore-SnipeitComponent -id @(7, 8) -Unarchive:$Unarchive -Session $script:restoreSession -Confirm:$false
                $script:restoreCalls.Uri | Should -Be @("https://restore.invalid/api/v1/components/7/$Mode", "https://restore.invalid/api/v1/components/8/$Mode")
                $script:restoreCalls.Count | Should -Be 2
                $script:restoreCalls.Json | Should -Be @('{}', '{}')
            }

            It 'binds inventory id and component_id properties without sending object fields' {
                @([pscustomobject]@{ id = 7; notes = 'not a request field' }, [pscustomobject]@{ component_id = 8 }) |
                    Restore-SnipeitComponent -Unarchive:$Unarchive -Session $script:restoreSession -Confirm:$false
                $script:restoreCalls.Uri | Should -Be @("https://restore.invalid/api/v1/components/7/$Mode", "https://restore.invalid/api/v1/components/8/$Mode")
                $script:restoreCalls.Count | Should -Be 2
                $script:restoreCalls.Json | Should -Be @('{}', '{}')
            }

            It 'does not call HTTP under WhatIf for any supplied ID' {
                Restore-SnipeitComponent -id @(7, 8) -Unarchive:$Unarchive -Session $script:restoreSession -WhatIf
                $script:restoreCalls.Count | Should -Be 0
            }

            It 'honors explicit WhatIf false over the caller preference' {
                $WhatIfPreference = $true
                Restore-SnipeitComponent -id 7 -Unarchive:$Unarchive -Session $script:restoreSession -WhatIf:$false -Confirm:$false
                $script:restoreCalls.Count | Should -Be 1
                $script:restoreCalls[0].Uri | Should -Be "https://restore.invalid/api/v1/components/7/$Mode"
            }

            It 'validates <Case> IDs before making any request' -ForEach @(
                @{ Case = 'zero'; InvalidId = @(0) }, @{ Case = 'negative'; InvalidId = @(-1) },
                @{ Case = 'mixed valid and invalid'; InvalidId = @(7, 0) },
                @{ Case = 'null'; InvalidId = $null }, @{ Case = 'empty'; InvalidId = @() }
            ) {
                $caught = $null
                try { Restore-SnipeitComponent -id $InvalidId -Unarchive:$Unarchive -Session $script:restoreSession -Confirm:$false -ErrorAction Stop }
                catch { $caught = $_ }
                $caught.FullyQualifiedErrorId | Should -BeLike 'ParameterArgumentValidationError*'
                $script:restoreCalls.Count | Should -Be 0
            }

            It 'preserves a domain-error envelope without fallback, retry, or success output' {
                $script:restoreResponse = [pscustomobject]@{ status = 'error'; messages = [pscustomobject]@{ archived = @('State change rejected') }; payload = $null }
                $output = @()
                $caught = $null
                try { $output = @(Restore-SnipeitComponent -id 7 -Unarchive:$Unarchive -Session $script:restoreSession -Confirm:$false -ErrorAction Stop) }
                catch { $caught = $_ }
                $caught.FullyQualifiedErrorId | Should -BeLike 'SnipeitApiError*'
                $caught.TargetObject.messages.archived[0] | Should -Be 'State change rejected'
                $output.Count | Should -Be 0
                $script:restoreCalls.Count | Should -Be 1
                $script:restoreCalls[0].Uri | Should -Be "https://restore.invalid/api/v1/components/7/$Mode"
            }

            It 'preserves HTTP <Code> details and does not retry another endpoint' -ForEach @(
                @{ Code = 403 }, @{ Code = 404 }, @{ Code = 422 }
            ) {
                $json = '{"status":"error","messages":"State change rejected","payload":null}'
                $response = [pscustomobject]@{ StatusCode = $Code; Json = $json }
                $response | Add-Member -MemberType ScriptMethod -Name GetResponseStream -Value {
                    [IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes($this.Json))
                }
                $exception = [Exception]::new("HTTP $Code")
                $exception | Add-Member -NotePropertyName Response -NotePropertyValue $response
                $script:restoreHttpError = [Management.Automation.ErrorRecord]::new($exception, 'RestoreFixtureError', [Management.Automation.ErrorCategory]::InvalidOperation, $null)
                $script:restoreHttpError.ErrorDetails = [Management.Automation.ErrorDetails]::new($json)
                $caught = $null
                $output = @()
                try { $output = @(Restore-SnipeitComponent -id 7 -Unarchive:$Unarchive -Session $script:restoreSession -Confirm:$false -ErrorAction Stop) }
                catch { $caught = $_ }
                $caught.FullyQualifiedErrorId | Should -BeLike 'SnipeitApiError*'
                $caught.TargetObject.StatusCode | Should -Be $Code
                $caught.TargetObject.messages | Should -Be 'State change rejected'
                $output.Count | Should -Be 0
                $script:restoreCalls.Count | Should -Be 1
            }
        }

        It 'defaults to restore when Unarchive is omitted' {
            Restore-SnipeitComponent -id 7 -Session $script:restoreSession -Confirm:$false
            $script:restoreCalls[0].Uri | Should -Be 'https://restore.invalid/api/v1/components/7/restore'
            $script:restoreCalls.Count | Should -Be 1
        }
    }
}
