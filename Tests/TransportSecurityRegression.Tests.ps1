BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Transport security regression contracts' {
    InModuleScope SnipeitPS {
        BeforeAll {
            function New-SecurityTestHttpError {
                param([int]$Code, [string]$Json)
                $response = [pscustomobject]@{ StatusCode = $Code; Json = $Json }
                $response | Add-Member -MemberType ScriptMethod -Name GetResponseStream -Value {
                    [IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes($this.Json))
                }
                $exception = [Exception]::new("HTTP $Code")
                $exception | Add-Member -MemberType NoteProperty -Name Response -Value $response
                $record = [Management.Automation.ErrorRecord]::new(
                    $exception, 'SecurityTestHttpError', [Management.Automation.ErrorCategory]::InvalidOperation, $null)
                $record.ErrorDetails = [Management.Automation.ErrorDetails]::new($Json)
                $record
            }
        }

        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:securitySession = [SnipeitSession]::new('https://contract.invalid', $key)
            Mock Invoke-RestMethod { throw 'Unexpected HTTP' }
            Mock Invoke-WebRequest { throw 'Unexpected HTTP' }
        }

        It 'Rejects HTTP <Code> with <Shape> JSON and retains a typed error' -ForEach @(
            @{ Code = 401; Shape = 'authentication'; Json = '{"error":"Unauthorized"}'; ErrorId = 'SnipeitAuthError' }
            @{ Code = 403; Shape = 'message'; Json = '{"message":"Forbidden"}'; ErrorId = 'SnipeitAuthError' }
            @{ Code = 422; Shape = 'validation'; Json = '{"message":"Invalid data","errors":{"name":["Required"]}}'; ErrorId = 'SnipeitValidationError' }
            @{ Code = 429; Shape = 'rate limit'; Json = '{"message":"Too many requests"}'; ErrorId = 'SnipeitRateLimitError' }
            @{ Code = 500; Shape = 'message'; Json = '{"message":"Internal error"}'; ErrorId = 'SnipeitTransportError' }
            @{ Code = 500; Shape = 'success-shaped'; Json = '{"status":"success","payload":{"id":99}}'; ErrorId = 'SnipeitTransportError' }
            @{ Code = 500; Shape = 'null'; Json = 'null'; ErrorId = 'SnipeitTransportError' }
            @{ Code = 500; Shape = 'array'; Json = '[]'; ErrorId = 'SnipeitTransportError' }
            @{ Code = 500; Shape = 'scalar'; Json = '"Internal error"'; ErrorId = 'SnipeitTransportError' }
        ) {
            $script:securityHttpError = New-SecurityTestHttpError -Code $Code -Json $Json
            Mock Invoke-RestMethod { throw $script:securityHttpError }
            $outputs = [System.Collections.Generic.List[object]]::new()
            { Get-SnipeitUser -id 1 -Session $script:securitySession -ErrorAction Stop |
                ForEach-Object { $outputs.Add($_) } } |
                Should -Throw -ExpectedMessage "*HTTP $Code*" -ErrorId "$ErrorId*"
            $outputs.Count | Should -Be 0
            Should -Invoke Invoke-RestMethod -Times 1 -Exactly
        }

        It 'Emits an error and no success output when failed HTTP errors are suppressed' {
            $script:securityHttpError = New-SecurityTestHttpError -Code 401 -Json '{"error":"Unauthorized"}'
            Mock Invoke-RestMethod { throw $script:securityHttpError }
            $failures = @()
            $result = Invoke-SnipeitMethod -Route '/api/v1/users/1' -Session $script:securitySession `
                -PreserveResponse -ErrorAction SilentlyContinue -ErrorVariable failures
            $result | Should -BeNullOrEmpty
            $authErrors = @($failures | Where-Object FullyQualifiedErrorId -Like 'SnipeitAuthError*')
            $authErrors.Count | Should -Be 1
            $authErrors[0].CategoryInfo.Category | Should -Be 'AuthenticationError'
            $authErrors[0].TargetObject | Should -Be 'https://contract.invalid/api/v1/users/1'
        }

        It 'Raises the pinned server LDAP rejection instead of returning a result' {
            $script:securityHttpError = New-SecurityTestHttpError -Code 400 `
                -Json '{"message":"Login Failed. test-user did not successfully bind to LDAP."}'
            Mock Invoke-RestMethod { throw $script:securityHttpError }
            $credential = [Management.Automation.PSCredential]::new('test-user', $script:securitySession.ApiKey)
            { Test-SnipeitLdapCredential -Credential $credential -Session $script:securitySession `
                -Confirm:$false -ErrorAction Stop } | Should -Throw '*Login Failed*'
        }

        It 'Raises a rejected token revocation rather than silently completing' {
            $script:securityHttpError = New-SecurityTestHttpError -Code 401 -Json '{"error":"Unauthorized"}'
            Mock Invoke-RestMethod { throw $script:securityHttpError }
            { Remove-SnipeitPersonalAccessToken -tokenId 'test-id' -Session $script:securitySession `
                -Confirm:$false -ErrorAction Stop } | Should -Throw -ErrorId 'SnipeitAuthError*'
        }

        It 'Retains structured normalized error details for HTTP failures' {
            $script:securityHttpError = New-SecurityTestHttpError -Code 422 `
                -Json '{"status":"error","messages":{"name":["Required"]},"payload":null}'
            Mock Invoke-RestMethod { throw $script:securityHttpError }
            $failure = $null
            try { Get-SnipeitUser -id 1 -Session $script:securitySession -ErrorAction Stop } catch { $failure = $_ }
            $failure | Should -Not -BeNullOrEmpty
            $failure.FullyQualifiedErrorId | Should -BeLike 'SnipeitApiError*'
            $failure.TargetObject.messages.name[0] | Should -Be 'Required'
        }

        It 'Retains successful no-content token revocation' {
            Mock Invoke-RestMethod { return $null }
            $result = Remove-SnipeitPersonalAccessToken -tokenId 'test-id' -Session $script:securitySession -Confirm:$false
            $result | Should -BeNullOrEmpty
            Should -Invoke Invoke-RestMethod -Times 1 -Exactly
        }

        Context '<Operation> upload error metadata' -ForEach @(
            @{ Operation = 'import'; Route = '/api/v1/imports' }
            @{ Operation = 'attachment'; Route = '/api/v1/hardware/1/files' }
        ) {
            It 'Omits confidential upload bytes on <FailureKind> failure' -ForEach @(
                @{ FailureKind = 'transport' }
                @{ FailureKind = 'authentication' }
            ) {
                $file = Join-Path $TestDrive 'confidential.csv'
                [IO.File]::WriteAllText($file, "username,password`ntest-user,UPLOAD_PASSWORD_SENTINEL")
                $script:securityFailureKind = $FailureKind
                Mock Invoke-RestMethod {
                    if ($script:securityFailureKind -eq 'authentication') {
                        throw (New-SecurityTestHttpError -Code 401 -Json '{"error":"Unauthorized"}')
                    }
                    throw [Net.WebException]::new('Interrupted upload')
                }
                $failure = $null
                try {
                    if ($Operation -eq 'import') {
                        New-SnipeitImport -File $file -Session $script:securitySession -Confirm:$false -ErrorAction Stop
                    } else {
                        New-SnipeitFile hardware 1 -File $file -Session $script:securitySession -Confirm:$false -ErrorAction Stop
                    }
                } catch { $failure = $_ }
                $failure | Should -Not -BeNullOrEmpty
                Should -Invoke Invoke-RestMethod -Times 1 -Exactly
                $failure.TargetObject.Uri | Should -Be "https://contract.invalid$Route"
                $failure.TargetObject.Method | Should -Be 'POST'
                if ($FailureKind -eq 'authentication') {
                    $failure.TargetObject.StatusCode | Should -Be 401
                } else {
                    $failure.TargetObject.StatusCode | Should -BeNullOrEmpty
                }
                @($failure.TargetObject.PSObject.Properties.Name | Sort-Object) -join ',' | Should -Be 'Method,StatusCode,Uri'
                ($failure.TargetObject | ConvertTo-Json -Depth 10) | Should -Not -Match 'UPLOAD_PASSWORD_SENTINEL'
                [IO.File]::ReadAllText($file) | Should -Match 'UPLOAD_PASSWORD_SENTINEL'
            }
        }

        It 'Omits raw text request bodies from transport error metadata' {
            Mock Invoke-RestMethod { throw [Net.WebException]::new('Interrupted request') }
            $failure = $null
            try {
                Invoke-SnipeitHttpRequest -Request @{
                    Uri = 'https://contract.invalid/api/v1/imports/process/1'
                    Method = 'POST'
                    Body = '{"password":"TEXT_PASSWORD_SENTINEL"}'
                } -Session $script:securitySession
            } catch { $failure = $_ }
            $failure | Should -Not -BeNullOrEmpty
            $failure.TargetObject.Method | Should -Be 'POST'
            ($failure.TargetObject | ConvertTo-Json -Depth 10) | Should -Not -Match 'TEXT_PASSWORD_SENTINEL'
        }

        It 'Retains server-supplied structured import errors instead of replacing them with request metadata' {
            $script:securityHttpError = New-SecurityTestHttpError -Code 422 `
                -Json '{"status":"import-errors","messages":{"row 2":["Missing asset tag"]},"payload":{"tally":{"errored":1}}}'
            Mock Invoke-RestMethod { throw $script:securityHttpError }
            $failure = $null
            try {
                Invoke-SnipeitHttpRequest -Request @{
                    Uri = 'https://contract.invalid/api/v1/imports/process/1'; Method = 'POST'; Body = @{ 'import-type' = 'asset' }
                } -Session $script:securitySession
            } catch { $failure = $_ }
            $failure | Should -Not -BeNullOrEmpty
            $failure.FullyQualifiedErrorId | Should -BeLike 'SnipeitApiError*'
            $failure.TargetObject.messages.'row 2'[0] | Should -Be 'Missing asset tag'
            $failure.TargetObject.payload.tally.errored | Should -Be 1
        }
    }
}
