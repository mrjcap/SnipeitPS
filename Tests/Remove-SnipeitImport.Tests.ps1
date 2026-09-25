BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Remove-SnipeitImport' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedRequest = $null
        }

        It 'Sends DELETE to /api/v1/imports/{id} on success' {
            Mock Invoke-SnipeitHttpRequest -ModuleName SnipeitPS {
                param($Request, $Session)
                $script:capturedRequest = $Request
                return [pscustomobject]@{
                    status   = 'success'
                    messages = 'File deleted successfully.'
                    payload  = $null
                }
            }

            Remove-SnipeitImport -id 12 -Session $script:testSession -Confirm:$false
            $script:capturedRequest.Uri | Should -Be 'https://contract.invalid/api/v1/imports/12'
            $script:capturedRequest.Method | Should -Be 'DELETE'
        }

        It 'Preserves warning response as warning and does not treat as successful deletion' {
            Mock Invoke-SnipeitHttpRequest -ModuleName SnipeitPS {
                param($Request, $Session)
                $script:capturedRequest = $Request
                return [pscustomobject]@{
                    status   = 'warning'
                    messages = 'File not found or permission denied'
                    payload  = $null
                }
            }

            $warnings = [System.Collections.Generic.List[string]]::new()
            Mock Write-Warning -ModuleName SnipeitPS {
                param($Message)
                $warnings.Add($Message)
            }

            $res = Remove-SnipeitImport -id 99 -Session $script:testSession -Confirm:$false
            $res | Should -BeNullOrEmpty
            $warnings.Count | Should -Be 1
            $warnings[0] | Should -Match 'File not found or permission denied'
        }

        It 'Accepts pipeline input by property name' {
            Mock Invoke-SnipeitHttpRequest -ModuleName SnipeitPS {
                param($Request, $Session)
                return [pscustomobject]@{
                    status   = 'success'
                    messages = 'Deleted'
                    payload  = $null
                }
            }

            $pipeItems = @(
                [pscustomobject]@{ id = 101 },
                [pscustomobject]@{ id = 102 }
            )

            $pipeItems | Remove-SnipeitImport -Session $script:testSession -Confirm:$false
            Should -Invoke Invoke-SnipeitHttpRequest -ModuleName SnipeitPS -Times 2 -Exactly
        }

        It 'Honors -WhatIf with zero HTTP requests' {
            Mock Invoke-SnipeitHttpRequest -ModuleName SnipeitPS {
                throw 'Should not be called when WhatIf is active'
            }

            Remove-SnipeitImport -id 15 -Session $script:testSession -WhatIf
            $script:capturedRequest | Should -BeNullOrEmpty
        }
    }
}
