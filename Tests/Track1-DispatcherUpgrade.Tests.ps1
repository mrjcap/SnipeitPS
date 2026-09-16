BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

Describe 'Invoke-SnipeitMethod Track 1 Upgrades' {

    AfterAll {
        InModuleScope 'SnipeitPS' {
            $script:SnipeitPSSession.url = $null
            $script:SnipeitPSSession.apiKey = $null
            $script:SnipeitPSSession.legacyUrl = $null
            $script:SnipeitPSSession.legacyApiKey = $null
            $script:SnipeitPSSession.throttleLimit = 0
            $script:SnipeitPSSession.throttledRequests = [System.Collections.ArrayList]::new()
        }
    }

    Context 'Route Template Parameter Resolution (ADR 0006)' {
        It 'Resolves a single {token} in the route template' {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = 'https://test'
                $script:SnipeitPSSession.apiKey = (ConvertTo-SecureString 'key' -AsPlainText -Force)
                $script:SnipeitPSSession.throttleLimit = 0

                Mock Invoke-RestMethod {
                    [PSCustomObject]@{ id = 42; asset_tag = 'LAPTOP-001' }
                } -ParameterFilter { $Uri -like '*/hardware/42' }

                $result = Invoke-SnipeitMethod -Route '/api/v1/hardware/{id}' -PathParameter @{ id = 42 } -Method 'Get'
                $result.id | Should -Be 42
                Should -Invoke Invoke-RestMethod -Times 1
            }
        }

        It 'Escapes special characters in path tokens using EscapeDataString' {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = 'https://test'
                $script:SnipeitPSSession.apiKey = (ConvertTo-SecureString 'key' -AsPlainText -Force)
                $script:SnipeitPSSession.throttleLimit = 0

                $script:TestCapturedUri = $null
                Mock Invoke-RestMethod {
                    $script:TestCapturedUri = if ($Uri -is [System.Uri]) { $Uri.OriginalString } else { [string]$Uri }
                    [PSCustomObject]@{ id = 1; serial = 'SN/123#456' }
                }

                Invoke-SnipeitMethod -Route '/api/v1/hardware/byserial/{serial}' -PathParameter @{ serial = 'SN/123#456' } -Method 'Get'
                $script:TestCapturedUri | Should -BeLike '*SN%2F123%23456*'
                $script:TestCapturedUri | Should -Not -BeLike '*SN/123#456*'
            }
        }

        It 'Resolves multiple {tokens} in a single route' {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = 'https://test'
                $script:SnipeitPSSession.apiKey = (ConvertTo-SecureString 'key' -AsPlainText -Force)
                $script:SnipeitPSSession.throttleLimit = 0

                $script:TestCapturedUri = $null
                Mock Invoke-RestMethod {
                    $script:TestCapturedUri = if ($Uri -is [System.Uri]) { $Uri.OriginalString } else { [string]$Uri }
                    [PSCustomObject]@{ status = 'success' }
                }

                Invoke-SnipeitMethod -Route '/api/v1/hardware/{id}/files/{file_id}/delete' -PathParameter @{ id = 10; file_id = 55 } -Method 'Delete'
                $script:TestCapturedUri | Should -BeLike '*/hardware/10/files/55/delete'
            }
        }

        It 'Preserves literal percent sequences separately from ordinary spaces' {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = 'https://test'
                $script:SnipeitPSSession.apiKey = (ConvertTo-SecureString 'key' -AsPlainText -Force)
                $script:SnipeitPSSession.throttleLimit = 0

                $script:TestCapturedUri = $null
                Mock Invoke-RestMethod {
                    $script:TestCapturedUri = if ($Uri -is [System.Uri]) { $Uri.OriginalString } else { [string]$Uri }
                    [PSCustomObject]@{ id = 1 }
                }

                Invoke-SnipeitMethod -Route '/api/v1/hardware/bytag/{tag}' -PathParameter @{ tag = 'TAG%20123' } -Method 'Get'
                $script:TestCapturedUri | Should -Be 'https://test/api/v1/hardware/bytag/TAG%2520123'
                Invoke-SnipeitMethod -Route '/api/v1/hardware/bytag/{tag}' -PathParameter @{ tag = 'TAG 123' } -Method 'Get'
                $script:TestCapturedUri | Should -Be 'https://test/api/v1/hardware/bytag/TAG%20123'
            }
        }

        It 'Falls back to legacy -Api parameter when -Route is not provided' {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = 'https://test'
                $script:SnipeitPSSession.apiKey = (ConvertTo-SecureString 'key' -AsPlainText -Force)
                $script:SnipeitPSSession.throttleLimit = 0

                $script:TestCapturedUri = $null
                Mock Invoke-RestMethod {
                    $script:TestCapturedUri = if ($Uri -is [System.Uri]) { $Uri.OriginalString } else { [string]$Uri }
                    [PSCustomObject]@{ status = 'success'; rows = @() }
                }

                Invoke-SnipeitMethod -Api '/api/v1/hardware' -Method 'Get'
                $script:TestCapturedUri | Should -Be 'https://test/api/v1/hardware'
            }
        }
    }

    Context 'Structured Error Handling (ADR 0007)' {
        It 'Formats HTTP 422 validation dictionaries into readable error messages' {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = 'https://test'
                $script:SnipeitPSSession.apiKey = (ConvertTo-SecureString 'key' -AsPlainText -Force)
                $script:SnipeitPSSession.throttleLimit = 0

                Mock Invoke-RestMethod {
                    $json = '{"status":"error","messages":{"asset_tag":["Asset tag already exists."],"serial":["Serial must be unique."]}}'
                    $ex = New-Object System.Exception 'Unprocessable Entity'
                    if ($PSVersionTable.PSVersion.Major -lt 7) {
                        $response = [pscustomobject]@{ StatusCode = 422; Bytes = [System.Text.Encoding]::UTF8.GetBytes($json) }
                        $response | Add-Member -MemberType ScriptMethod -Name GetResponseStream -Value {
                            [System.IO.MemoryStream]::new([byte[]]$this.Bytes)
                        }
                        $ex | Add-Member -MemberType NoteProperty -Name Response -Value $response
                    }
                    $err = New-Object System.Management.Automation.ErrorRecord $ex, 'id', 'NotSpecified', $null
                    if ($PSVersionTable.PSVersion.Major -ge 7) {
                        $err.ErrorDetails = New-Object System.Management.Automation.ErrorDetails($json)
                    }
                    throw $err
                }

                $errVar = $null
                Invoke-SnipeitMethod -Api '/api/v1/hardware' -Method 'Post' -Body @{ name = 'test' } -ErrorVariable errVar -ErrorAction SilentlyContinue
                $errVar | Should -Not -BeNullOrEmpty
                $apiErrors = @($errVar | Where-Object { $_.FullyQualifiedErrorId -like 'SnipeitApiError,*' })
                $apiErrors.Count | Should -Be 1
                $errMsg = $apiErrors[0].ToString()
                $errMsg | Should -Match 'asset_tag'
                $errMsg | Should -Match 'Asset tag already exists'
            }
        }

        It 'Attaches raw error payload to ErrorRecord TargetObject for structured errors' {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = 'https://test'
                $script:SnipeitPSSession.apiKey = (ConvertTo-SecureString 'key' -AsPlainText -Force)
                $script:SnipeitPSSession.throttleLimit = 0

                # Return a JSON response with status=error directly (not via HTTP exception)
                # to test the structured error path in response processing
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ status = 'error'; messages = [PSCustomObject]@{ name = @('Name is required.') } }
                }

                $errVar = $null
                Invoke-SnipeitMethod -Api '/api/v1/hardware' -Method 'Get' -ErrorVariable errVar -ErrorAction SilentlyContinue
                $errVar | Should -Not -BeNullOrEmpty
                $errVar[0].TargetObject | Should -Not -BeNullOrEmpty
                $errVar[0].TargetObject.status | Should -Be 'error'
            }
        }

        It 'Maps authentication errors to AuthenticationError category' {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = 'https://test'
                $script:SnipeitPSSession.apiKey = (ConvertTo-SecureString 'key' -AsPlainText -Force)
                $script:SnipeitPSSession.throttleLimit = 0

                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ StatusCode = 'Unauthorized' }
                }

                $errVar = $null
                Invoke-SnipeitMethod -Api '/api/v1/hardware' -Method 'Get' -ErrorVariable errVar -ErrorAction SilentlyContinue
                $errVar | Should -Not -BeNullOrEmpty
                $errVar[0].ToString() | Should -Match 'Unauthorized'
            }
        }
    }

    Context 'Defense-in-Depth WhatIf Guard (ADR 0009)' {
        It 'Blocks mutative HTTP methods when WhatIfPreference is active' {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = 'https://test'
                $script:SnipeitPSSession.apiKey = (ConvertTo-SecureString 'key' -AsPlainText -Force)
                $script:SnipeitPSSession.throttleLimit = 0

                Mock Invoke-RestMethod { throw 'Should not be called under WhatIf' }

                $WhatIfPreference = $true
                Invoke-SnipeitMethod -Api '/api/v1/hardware/1' -Method 'Delete' -ErrorAction SilentlyContinue 4>&1 | Out-Null
                Should -Not -Invoke Invoke-RestMethod
            }
        }

        It 'Allows GET requests even when WhatIfPreference is active' {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = 'https://test'
                $script:SnipeitPSSession.apiKey = (ConvertTo-SecureString 'key' -AsPlainText -Force)
                $script:SnipeitPSSession.throttleLimit = 0

                Mock Invoke-RestMethod { [PSCustomObject]@{ total = 0; rows = @() } }

                $WhatIfPreference = $true
                Invoke-SnipeitMethod -Api '/api/v1/hardware' -Method 'Get'
                Should -Invoke Invoke-RestMethod -Times 1
            }
        }
    }

    Context 'Dispatcher-Managed Pagination Streaming (ADR 0002/0005)' {
        It 'Streams records from multiple pages when -Paginate is used' {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = 'https://test'
                $script:SnipeitPSSession.apiKey = (ConvertTo-SecureString 'key' -AsPlainText -Force)
                $script:SnipeitPSSession.throttleLimit = 0

                $script:PaginateCallCount = 0
                Mock Invoke-RestMethod {
                    $script:PaginateCallCount++
                    if ($script:PaginateCallCount -eq 1) {
                        return [PSCustomObject]@{
                            total = 3
                            rows = @(
                                [PSCustomObject]@{ id = 1; name = 'Asset1' },
                                [PSCustomObject]@{ id = 2; name = 'Asset2' }
                            )
                        }
                    } else {
                        return [PSCustomObject]@{
                            total = 3
                            rows = @(
                                [PSCustomObject]@{ id = 3; name = 'Asset3' }
                            )
                        }
                    }
                }

                $results = @(Invoke-SnipeitMethod -Api '/api/v1/hardware' -Method 'Get' -GetParameters @{ limit = 2; offset = 0 } -Paginate)
                $results.Count | Should -Be 3
                $results[0].id | Should -Be 1
                $results[2].id | Should -Be 3
                Should -Invoke Invoke-RestMethod -Times 2
            }
        }

        It 'Stops paginating when returned rows are fewer than limit' {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = 'https://test'
                $script:SnipeitPSSession.apiKey = (ConvertTo-SecureString 'key' -AsPlainText -Force)
                $script:SnipeitPSSession.throttleLimit = 0

                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{
                        total = 1
                        rows = @(
                            [PSCustomObject]@{ id = 1; name = 'OnlyAsset' }
                        )
                    }
                }

                $results = @(Invoke-SnipeitMethod -Api '/api/v1/hardware' -Method 'Get' -GetParameters @{ limit = 50; offset = 0 } -Paginate)
                $results.Count | Should -Be 1
                Should -Invoke Invoke-RestMethod -Times 1
            }
        }

        It 'Returns empty when API returns zero rows with -Paginate' {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = 'https://test'
                $script:SnipeitPSSession.apiKey = (ConvertTo-SecureString 'key' -AsPlainText -Force)
                $script:SnipeitPSSession.throttleLimit = 0

                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ total = 0; rows = @() }
                }

                $results = @(Invoke-SnipeitMethod -Api '/api/v1/hardware' -Method 'Get' -GetParameters @{ limit = 50; offset = 0 } -Paginate)
                $results.Count | Should -Be 0
                Should -Invoke Invoke-RestMethod -Times 1
            }
        }

        It 'Throws terminating error on mid-stream pagination failure (Picard amendment)' {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = 'https://test'
                $script:SnipeitPSSession.apiKey = (ConvertTo-SecureString 'key' -AsPlainText -Force)
                $script:SnipeitPSSession.throttleLimit = 0

                $script:TermCallCount = 0
                Mock Invoke-RestMethod {
                    $script:TermCallCount++
                    if ($script:TermCallCount -eq 1) {
                        return [PSCustomObject]@{
                            total = 100
                            rows = @(
                                [PSCustomObject]@{ id = 1 },
                                [PSCustomObject]@{ id = 2 }
                            )
                        }
                    } else {
                        throw [System.Net.Http.HttpRequestException]::new('Connection reset')
                    }
                }

                $err = $null
                try {
                    Invoke-SnipeitMethod -Api '/api/v1/hardware' -Method 'Get' -GetParameters @{ limit = 2; offset = 0 } -Paginate -ErrorAction Stop
                } catch {
                    $err = $_
                }
                $err | Should -Not -BeNullOrEmpty
                $err.FullyQualifiedErrorId | Should -Match 'SnipeitPaginationError'
            }
        }
    }
}
