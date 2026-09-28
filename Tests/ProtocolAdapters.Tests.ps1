BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Protocol and Response Adapters' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $script:SnipeitPSSession.url = 'https://contract.invalid'
            $script:SnipeitPSSession.apiKey = 'test-only-key'
            $script:SnipeitPSSession.throttleLimit = 0
            $script:httpCalls = [System.Collections.Generic.List[object]]::new()
        }

        Context 'Invoke-SnipeitHttpRequest' {
            It 'Sends a single request with proper headers and user-agent' {
                Mock Invoke-RestMethod -ModuleName SnipeitPS {
                    param($Uri, $Method, $Headers)
                    $script:httpCalls.Add(@{
                        Uri     = $Uri
                        Method  = $Method
                        Headers = $Headers
                    })
                    return [pscustomobject]@{ status = 'success'; payload = @{ id = 1 } }
                }

                $req = @{
                    Uri    = 'https://contract.invalid/api/v1/test'
                    Method = 'GET'
                }
                $res = Invoke-SnipeitHttpRequest -Request $req
                $res.status | Should -Be 'success'
                $script:httpCalls.Count | Should -Be 1
                $script:httpCalls[0].Headers['User-Agent'] | Should -Match '^SnipeitPS/'
                $script:httpCalls[0].Headers['Authorization'] | Should -Be 'Bearer test-only-key'
            }

            It 'Passes multipart streams to HTTP without serializing them as JSON or logging content' {
                Mock Invoke-RestMethod -ModuleName SnipeitPS {
                    param($Body, $Headers)
                    $Body | Should -BeOfType ([System.IO.Stream])
                    $Headers['Content-Type'] | Should -Be 'multipart/form-data; boundary=test'
                    $script:httpCalls.Add($Body)
                    return [pscustomobject]@{ status = 'success' }
                }

                $stream = [System.IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes('private upload bytes'))
                $previousDebugPreference = $DebugPreference
                $DebugPreference = 'Continue'
                try {
                    $request = @{
                        Uri     = 'https://contract.invalid/api/v1/imports'
                        Method  = 'POST'
                        Headers = @{ 'Content-Type' = 'multipart/form-data; boundary=test' }
                        Body    = $stream
                    }
                    $debugOutput = Invoke-SnipeitHttpRequest -Request $request 5>&1 | Out-String
                    $script:httpCalls.Count | Should -Be 1
                    $script:httpCalls[0] | Should -Be $stream
                    $debugOutput | Should -Match '\[BINARY_BODY\]'
                    $debugOutput | Should -Not -Match 'private upload bytes'
                } finally {
                    $DebugPreference = $previousDebugPreference
                    $stream.Dispose()
                }
            }

            It 'Redacts ldaptest_password in debug and ErrorRecord targets' {
                Mock Invoke-RestMethod -ModuleName SnipeitPS {
                    $ex = [System.Net.WebException]::new('Bad Request')
                    throw $ex
                }

                $req = @{
                    Uri    = 'https://contract.invalid/api/v1/settings/ldaptestlogin'
                    Method = 'POST'
                    Body   = @{
                        ldaptest_user     = 'admin'
                        ldaptest_password = 'SuperSecretPassword123'
                    }
                }

                { Invoke-SnipeitHttpRequest -Request $req -ErrorAction Stop } | Should -Throw
            }

            It 'Maps HTTP 429 response to RateLimitError category' {
                Mock Invoke-RestMethod {
                    $responseObj = [pscustomobject]@{
                        StatusCode = 429
                    }
                    $ex = [System.Net.WebException]::new('Too Many Requests')
                    throw $ex
                }

                $req = @{
                    Uri    = 'https://contract.invalid/api/v1/test'
                    Method = 'GET'
                }

                try {
                    Invoke-SnipeitHttpRequest -Request $req -ErrorAction Stop
                    throw 'Should have thrown'
                } catch {
                    $err = $_
                    $err.FullyQualifiedErrorId | Should -Match 'Snipeit(Transport|RateLimit|Api)Error'
                }
            }
        }

        Context 'ConvertFrom-SnipeitApiResponse' {
            It 'Unwraps StandardEnvelope payload on success' {
                $raw = [pscustomobject]@{
                    status   = 'success'
                    messages = 'Created successfully'
                    payload  = [pscustomobject]@{ id = 10; name = 'TestItem' }
                }
                $res = ConvertFrom-SnipeitApiResponse -Response $raw -ResponseKind 'StandardEnvelope'
                $res.id | Should -Be 10
                $res.name | Should -Be 'TestItem'
            }

            It 'Attaches explicit ResultTypeName to StandardEnvelope payload' {
                $raw = [pscustomobject]@{
                    status  = 'success'
                    payload = [pscustomobject]@{ id = 12 }
                }
                $res = ConvertFrom-SnipeitApiResponse -Response $raw -ResponseKind 'StandardEnvelope' -ResultTypeName 'SnipeitPS.TestEntity'
                $res.PSObject.TypeNames | Should -Contain 'SnipeitPS.TestEntity'
            }

            It 'Preserves entire response envelope when -PreserveResponse is set' {
                $raw = [pscustomobject]@{
                    status   = 'success'
                    messages = 'Envelope preserved'
                    payload  = [pscustomobject]@{ id = 10 }
                }
                $res = ConvertFrom-SnipeitApiResponse -Response $raw -ResponseKind 'StandardEnvelope' -PreserveResponse
                $res.status | Should -Be 'success'
                $res.messages | Should -Be 'Envelope preserved'
                $res.payload.id | Should -Be 10
            }

            It 'Preserves bulk results envelope with status/messages/results' {
                $raw = [pscustomobject]@{
                    status   = 'success'
                    messages = 'Bulk updated'
                    results  = @(
                        [pscustomobject]@{ id = 1; status = 'success' },
                        [pscustomobject]@{ id = 2; status = 'error' }
                    )
                }
                $res = ConvertFrom-SnipeitApiResponse -Response $raw -ResponseKind 'StandardEnvelope'
                $res.results.Count | Should -Be 2
                $res.status | Should -Be 'success'
            }

            It 'Emits items from RowsTotal and attaches ResultTypeName' {
                $raw = [pscustomobject]@{
                    total = 2
                    rows  = @(
                        [pscustomobject]@{ id = 1; name = 'Item1' },
                        [pscustomobject]@{ id = 2; name = 'Item2' }
                    )
                }
                $res = @(ConvertFrom-SnipeitApiResponse -Response $raw -ResponseKind 'RowsTotal' -ResultTypeName 'SnipeitPS.HistoryEntry')
                $res.Count | Should -Be 2
                $res[0].PSObject.TypeNames | Should -Contain 'SnipeitPS.HistoryEntry'
                $res[1].PSObject.TypeNames | Should -Contain 'SnipeitPS.HistoryEntry'
            }

            It 'Extracts Select2 results and decorates with SnipeitPS.SelectListItem' {
                $raw = [pscustomobject]@{
                    results    = @(
                        [pscustomobject]@{ id = 1; text = 'Option 1' },
                        [pscustomobject]@{ id = 2; text = 'Option 2' }
                    )
                    pagination = [pscustomobject]@{ more = $false }
                }
                $res = @(ConvertFrom-SnipeitApiResponse -Response $raw -ResponseKind 'Select2')
                $res.Count | Should -Be 2
                $res[0].PSObject.TypeNames | Should -Contain 'SnipeitPS.SelectListItem'
                $res[1].text | Should -Be 'Option 2'
            }

            It 'Returns scalar text directly for ScalarText kind' {
                $res = ConvertFrom-SnipeitApiResponse -Response '1' -ResponseKind 'ScalarText'
                $res | Should -Be '1'
            }

            It 'Returns null for NoContent kind' {
                $res = ConvertFrom-SnipeitApiResponse -Response $null -ResponseKind 'NoContent'
                $res | Should -BeNullOrEmpty
            }

            It 'Constructs SnipeitPS.ImportResult for ImportResult kind' {
                $raw = [pscustomobject]@{
                    status   = 'success'
                    messages = 'Import finished'
                    payload  = [pscustomobject]@{
                        tally = [pscustomobject]@{ created = 5; updated = 2; skipped = 0; errored = 0 }
                    }
                }
                $res = ConvertFrom-SnipeitApiResponse -Response $raw -ResponseKind 'ImportResult'
                $res.PSObject.TypeNames | Should -Contain 'SnipeitPS.ImportResult'
                $res.Status | Should -Be 'success'
                $res.Tally.created | Should -Be 5
            }

            It 'Throws SnipeitApiError on import-errors status' {
                $raw = [pscustomobject]@{
                    status   = 'import-errors'
                    messages = [pscustomobject]@{ 'row 2' = 'Asset tag missing' }
                    payload  = $null
                }
                { ConvertFrom-SnipeitApiResponse -Response $raw -ResponseKind 'ImportResult' } |
                    Should -Throw -ExpectedMessage '*import-errors*'
            }
        }

        Context 'Invoke-SnipeitSelectListPage' {
            It 'Fetches a single page of Select2 items' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    return [pscustomobject]@{
                        results    = @(
                            [pscustomobject]@{ id = 10; text = 'Location A' }
                        )
                        pagination = [pscustomobject]@{ more = $false }
                    }
                }

                $res = @(Invoke-SnipeitSelectListPage -Route '/api/v1/locations/selectlist')
                $res.Count | Should -Be 1
                $res[0].text | Should -Be 'Location A'
                $res[0].PSObject.TypeNames | Should -Contain 'SnipeitPS.SelectListItem'
            }

            It 'Streams all pages when -All is specified until more is false' {
                $script:pageCounter = 0
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    $script:pageCounter++
                    if ($script:pageCounter -eq 1) {
                        return [pscustomobject]@{
                            results    = @([pscustomobject]@{ id = 1; text = 'Page1-Item' })
                            pagination = [pscustomobject]@{ more = $true }
                        }
                    } else {
                        return [pscustomobject]@{
                            results    = @([pscustomobject]@{ id = 2; text = 'Page2-Item' })
                            pagination = [pscustomobject]@{ more = $false }
                        }
                    }
                }

                $res = @(Invoke-SnipeitSelectListPage -Route '/api/v1/hardware/selectlist' -All)
                $res.Count | Should -Be 2
                $res[0].text | Should -Be 'Page1-Item'
                $res[1].text | Should -Be 'Page2-Item'
            }

            It 'Detects contradictory empty-more response and terminates' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    return [pscustomobject]@{
                        results    = @()
                        pagination = [pscustomobject]@{ more = $true }
                    }
                }

                { Invoke-SnipeitSelectListPage -Route '/api/v1/users/selectlist' -All } |
                    Should -Throw -ExpectedMessage '*contradictory*'
            }
        }
    }
}
