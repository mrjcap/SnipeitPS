BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Dispatcher shared HTTP transport' {
    InModuleScope SnipeitPS {
        BeforeAll {
            function New-SharedTransportTestError {
                param([int]$Code, [string]$Json)
                $response = [pscustomobject]@{ StatusCode = $Code; Json = $Json }
                $response | Add-Member -MemberType ScriptMethod -Name GetResponseStream -Value {
                    [IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes($this.Json))
                }
                $exception = [Exception]::new("HTTP $Code")
                $exception | Add-Member -MemberType NoteProperty -Name Response -Value $response
                $record = [Management.Automation.ErrorRecord]::new(
                    $exception, 'SharedTransportTestError', [Management.Automation.ErrorCategory]::InvalidOperation, $null)
                $record.ErrorDetails = [Management.Automation.ErrorDetails]::new($Json)
                $record
            }
        }

        BeforeEach {
            $script:sharedSession = [ordered]@{
                url = 'https://shared.invalid'
                apiKey = 'shared-test-key'
                throttleLimit = 0
                throttleMode = 'Burst'
                throttleThreshold = 100
                throttlePeriod = 1000
                throttledRequests = [System.Collections.Generic.Queue[long]]::new()
            }
            Mock Invoke-RestMethod { throw 'Unexpected direct HTTP request' }
            Mock Start-Sleep {}
        }

        It 'Uses the existing transport for a resolved single request' {
            Mock Invoke-SnipeitHttpRequest { [pscustomobject]@{ id = 7; name = 'Shared transport' } }
            $result = Invoke-SnipeitMethod -Route '/api/v1/hardware/{id}' -PathParameter @{ id = 7 } `
                -Session $script:sharedSession
            $result.id | Should -Be 7
            $result.PSObject.TypeNames | Should -Contain 'SnipeitPS.Asset'
            Should -Invoke Invoke-SnipeitHttpRequest -Times 1 -Exactly -ParameterFilter {
                $Request.Uri -eq 'https://shared.invalid/api/v1/hardware/7' -and
                $Request.Method -eq 'GET' -and [object]::ReferenceEquals($Session, $script:sharedSession)
            }
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly
        }

        It 'Uses the existing transport on every page and preserves query parameters' {
            Mock Invoke-SnipeitHttpRequest {
                $id = if ($Request.Uri -match 'offset=1') { 2 } else { 1 }
                [pscustomobject]@{ total = 2; rows = @([pscustomobject]@{ id = $id }) }
            }
            $query = @{ limit = 1; offset = 0; search = 'Laptop A' }
            $rows = @(Invoke-SnipeitMethod -Api '/api/v1/hardware' -GetParameters $query `
                -Paginate -Session $script:sharedSession)
            $rows.Count | Should -Be 2
            $rows[0].id | Should -Be 1
            $rows[1].id | Should -Be 2
            $rows[1].PSObject.TypeNames | Should -Contain 'SnipeitPS.Asset'
            $query.offset | Should -Be 0
            Should -Invoke Invoke-SnipeitHttpRequest -Times 2 -Exactly -ParameterFilter {
                $Request.Uri -match 'limit=1' -and $Request.Uri -match 'search=Laptop\+A' -and
                [object]::ReferenceEquals($Session, $script:sharedSession)
            }
            Should -Invoke Invoke-SnipeitHttpRequest -Times 1 -Exactly -ParameterFilter { $Request.Uri -match 'offset=1' }
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly
        }

        It 'Applies <Mode> throttling to later pages without changing tenant headers' -ForEach @(
            @{ Mode = 'Burst' }
            @{ Mode = 'Constant' }
            @{ Mode = 'Adaptive' }
        ) {
            $script:sharedSession.throttleLimit = 1
            $script:sharedSession.throttleMode = $Mode
            Mock Get-Date { [datetime]::new(2026, 9, 24, 12, 0, 0, [DateTimeKind]::Utc) }
            Mock Invoke-RestMethod {
                $id = if ($Uri -match 'offset=1') { 2 } else { 1 }
                [pscustomobject]@{ total = 2; rows = @([pscustomobject]@{ id = $id }) }
            }
            $rows = @(Invoke-SnipeitMethod -Route '/api/v1/hardware' -GetParameters @{ limit = 1 } `
                -Paginate -Session $script:sharedSession)
            $rows.Count | Should -Be 2
            $script:sharedSession.throttledRequests.Count | Should -Be 2
            Should -Invoke Start-Sleep -Times 1 -Exactly -ParameterFilter { $Milliseconds -eq 1000 }
            Should -Invoke Invoke-RestMethod -Times 2 -Exactly -ParameterFilter {
                $Headers.Authorization -eq 'Bearer shared-test-key' -and
                $Headers['User-Agent'] -eq "SnipeitPS/$script:SnipeitModuleVersion" -and
                $MaximumRedirection -eq 0
            }
        }

        It 'Retains HTTP <Code> details in a terminating later-page error' -ForEach @(
            @{ Code = 401 }
            @{ Code = 422 }
            @{ Code = 429 }
            @{ Code = 500 }
        ) {
            $script:sharedHttpError = New-SharedTransportTestError -Code $Code -Json '{"message":"Later page rejected"}'
            Mock Invoke-RestMethod {
                if ($Uri -match 'offset=1') { throw $script:sharedHttpError }
                [pscustomobject]@{ total = 2; rows = @([pscustomobject]@{ id = 1 }) }
            }
            $rows = [System.Collections.Generic.List[object]]::new()
            $failure = $null
            try {
                Invoke-SnipeitMethod -Route '/api/v1/hardware' -GetParameters @{ limit = 1 } `
                    -Paginate -Session $script:sharedSession -ErrorAction SilentlyContinue |
                    ForEach-Object { $rows.Add($_) }
            } catch { $failure = $_ }
            $failure | Should -Not -BeNullOrEmpty
            $failure.FullyQualifiedErrorId | Should -BeLike 'SnipeitPaginationError*'
            $failure.Exception.Message | Should -Match "HTTP $Code"
            $failure.Exception.Message | Should -Match 'Later page rejected'
            $failure.TargetObject.Offset | Should -Be 1
            $failure.TargetObject.TotalRecords | Should -Be 2
            $failure.TargetObject.Uri | Should -Match 'offset=1'
            $rows.Count | Should -Be 1
            $rows[0].id | Should -Be 1
            Should -Invoke Invoke-RestMethod -Times 2 -Exactly
        }

        It 'Rejects a later HTTP 200 API failure instead of returning a partial success' {
            Mock Invoke-RestMethod {
                if ($Uri -match 'offset=1') {
                    return [pscustomobject]@{ status = 'error'; messages = @{ permission = @('Denied') }; rows = @([pscustomobject]@{ id = 999 }) }
                }
                [pscustomobject]@{ total = 2; rows = @([pscustomobject]@{ id = 1 }) }
            }
            $rows = [System.Collections.Generic.List[object]]::new()
            $failure = $null
            try {
                Invoke-SnipeitMethod -Route '/api/v1/hardware' -GetParameters @{ limit = 1 } `
                    -Paginate -Session $script:sharedSession -ErrorAction SilentlyContinue |
                    ForEach-Object { $rows.Add($_) }
            } catch { $failure = $_ }
            $failure | Should -Not -BeNullOrEmpty
            $failure.FullyQualifiedErrorId | Should -BeLike 'SnipeitPaginationError*'
            $failure.Exception.Message | Should -Match 'Denied'
            $rows.Count | Should -Be 1
            $rows[0].id | Should -Be 1
            Should -Invoke Invoke-RestMethod -Times 2 -Exactly
        }
    }
}
