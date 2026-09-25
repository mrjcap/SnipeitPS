BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Invoke-SnipeitImport' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedRequest = $null
        }

        It 'Translates parameters to exact JSON body keys' {
            Mock Invoke-SnipeitHttpRequest -ModuleName SnipeitPS {
                param($Request, $Session)
                $script:capturedRequest = $Request
                return [pscustomobject]@{
                    status   = 'success'
                    messages = 'Import finished successfully.'
                    payload  = [pscustomobject]@{
                        tally = [pscustomobject]@{
                            created = 10
                            updated = 2
                            skipped = 0
                            errored = 0
                        }
                        redirect_url = 'https://contract.invalid/hardware'
                    }
                }
            }

            $mappings = @{
                'Asset Tag'    = 'asset_tag'
                'Model Number' = 'model_number'
            }

            $res = Invoke-SnipeitImport -import_id 5 `
                                        -ImportType 'asset' `
                                        -ColumnMappings $mappings `
                                        -Update `
                                        -SendWelcome:$false `
                                        -RunBackup:$true `
                                        -Offset 0 `
                                        -Limit 50 `
                                        -Session $script:testSession

            $res.PSObject.TypeNames | Should -Contain 'SnipeitPS.ImportResult'
            $res.Status | Should -Be 'success'
            $res.Tally.created | Should -Be 10
            $res.RedirectUrl | Should -Be 'https://contract.invalid/hardware'

            $script:capturedRequest.Uri | Should -Be 'https://contract.invalid/api/v1/imports/process/5'
            $script:capturedRequest.Method | Should -Be 'POST'

            $body = $script:capturedRequest.Body
            $body['import-type'] | Should -Be 'asset'
            $body['column-mappings']['Asset Tag'] | Should -Be 'asset_tag'
            $body['column-mappings']['Model Number'] | Should -Be 'model_number'
            $body['import-update'] | Should -Be $true
            $body['send-welcome'] | Should -Be $false
            $body['run-backup'] | Should -Be $true
            $body['offset'] | Should -Be 0
            $body['limit'] | Should -Be 50
        }

        It 'Distinguishes omitted false from explicit false' {
            Mock Invoke-SnipeitHttpRequest -ModuleName SnipeitPS {
                param($Request, $Session)
                $script:capturedRequest = $Request
                return [pscustomobject]@{
                    status   = 'success'
                    messages = 'Imported'
                    payload  = $null
                }
            }

            # Case A: Update omitted -> body must NOT contain 'import-update'
            $null = Invoke-SnipeitImport -import_id 5 -ImportType 'asset' -Session $script:testSession
            $script:capturedRequest.Body.ContainsKey('import-update') | Should -BeFalse
            $script:capturedRequest.Body.ContainsKey('send-welcome') | Should -BeFalse
            $script:capturedRequest.Body.ContainsKey('run-backup') | Should -BeFalse

            # Case B: Update explicit false -> body MUST contain 'import-update' = false
            $null = Invoke-SnipeitImport -import_id 5 -ImportType 'asset' -Update:$false -Session $script:testSession
            $script:capturedRequest.Body.ContainsKey('import-update') | Should -BeTrue
            $script:capturedRequest.Body['import-update'] | Should -BeFalse
        }

        It 'Allows history-matching switches only for assetHistory' {
            Mock Invoke-SnipeitHttpRequest -ModuleName SnipeitPS {
                param($Request, $Session)
                $script:capturedRequest = $Request
                return [pscustomobject]@{
                    status   = 'success'
                    messages = 'Imported history'
                    payload  = $null
                }
            }

            $null = Invoke-SnipeitImport -import_id 7 `
                                        -ImportType 'assetHistory' `
                                        -MatchUsername `
                                        -MatchEmail `
                                        -MatchFirstnameLastname `
                                        -MatchFlastname `
                                        -MatchFirstname `
                                        -Session $script:testSession

            $body = $script:capturedRequest.Body
            $body['match_username'] | Should -BeTrue
            $body['match_email'] | Should -BeTrue
            $body['match_firstnamelastname'] | Should -BeTrue
            $body['match_flastname'] | Should -BeTrue
            $body['match_firstname'] | Should -BeTrue
        }

        It 'Rejects history-matching switches when ImportType is not assetHistory' {
            Mock Invoke-SnipeitHttpRequest -ModuleName SnipeitPS {
                throw 'Should not reach transport'
            }

            {
                Invoke-SnipeitImport -import_id 7 `
                                     -ImportType 'asset' `
                                     -MatchUsername `
                                     -Session $script:testSession
            } | Should -Throw -ExpectedMessage '*history-matching parameters*assetHistory*'
        }

        It 'Rejects ColumnMappings with null values' {
            Mock Invoke-SnipeitHttpRequest -ModuleName SnipeitPS {
                throw 'Should not reach transport'
            }

            $badMappings = @{
                'Asset Tag' = $null
            }

            {
                Invoke-SnipeitImport -import_id 8 `
                                     -ImportType 'asset' `
                                     -ColumnMappings $badMappings `
                                     -Session $script:testSession
            } | Should -Throw -ExpectedMessage '*ColumnMappings cannot contain null values*'
        }

        It 'Handles tally-null gracefully' {
            Mock Invoke-SnipeitHttpRequest -ModuleName SnipeitPS {
                return [pscustomobject]@{
                    status   = 'success'
                    messages = 'Import complete without tally.'
                    payload  = $null
                }
            }

            $res = Invoke-SnipeitImport -import_id 9 -ImportType 'consumable' -Session $script:testSession
            $res.PSObject.TypeNames | Should -Contain 'SnipeitPS.ImportResult'
            $res.Status | Should -Be 'success'
            $res.Tally | Should -BeNullOrEmpty
        }

        It 'Throws SnipeitApiError on import-errors, preserving nested row errors in ErrorRecord target' {
            Mock Invoke-SnipeitHttpRequest -ModuleName SnipeitPS {
                $errObj = [pscustomobject]@{
                    status   = 'import-errors'
                    messages = [pscustomobject]@{
                        'row 3' = @('Asset tag already exists', 'Serial number duplicate')
                    }
                    payload  = [pscustomobject]@{
                        tally = [pscustomobject]@{
                            created = 2
                            errored = 1
                        }
                    }
                }
                $errRecord = [System.Management.Automation.ErrorRecord]::new(
                    [System.Exception]::new("HTTP 500 error from Snipe-IT API: import-errors"),
                    'SnipeitApiError',
                    [System.Management.Automation.ErrorCategory]::InvalidData,
                    $errObj
                )
                $PSCmdlet.ThrowTerminatingError($errRecord)
            }

            try {
                Invoke-SnipeitImport -import_id 11 -ImportType 'asset' -Session $script:testSession -ErrorAction Stop
                throw 'Should have thrown'
            } catch {
                $err = $_
                $err.FullyQualifiedErrorId | Should -Match 'SnipeitApiError'
                $err.TargetObject.status | Should -Be 'import-errors'
                $err.TargetObject.messages.'row 3'.Count | Should -Be 2
                $err.TargetObject.payload.tally.errored | Should -Be 1
            }
        }

        It 'Handles ownership denial error' {
            Mock Invoke-SnipeitHttpRequest -ModuleName SnipeitPS {
                $errObj = [pscustomobject]@{
                    status   = 'import-errors'
                    messages = @(@('The selected file is invalid.'))
                    payload  = $null
                }
                $errRecord = [System.Management.Automation.ErrorRecord]::new(
                    [System.Exception]::new("HTTP 500 error from Snipe-IT API: The selected file is invalid."),
                    'SnipeitApiError',
                    [System.Management.Automation.ErrorCategory]::InvalidData,
                    $errObj
                )
                $PSCmdlet.ThrowTerminatingError($errRecord)
            }

            try {
                Invoke-SnipeitImport -import_id 999 -ImportType 'asset' -Session $script:testSession -ErrorAction Stop
                throw 'Should have thrown'
            } catch {
                $err = $_
                $err.FullyQualifiedErrorId | Should -Match 'SnipeitApiError'
                $err.TargetObject.status | Should -Be 'import-errors'
            }
        }

        It 'Honors -WhatIf with zero HTTP requests' {
            Mock Invoke-SnipeitHttpRequest -ModuleName SnipeitPS {
                throw 'Should not be called when WhatIf is active'
            }

            Invoke-SnipeitImport -import_id 5 -ImportType 'asset' -Session $script:testSession -WhatIf
            $script:capturedRequest | Should -BeNullOrEmpty
        }
    }
}
