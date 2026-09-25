BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Remove-SnipeitFile' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedDelete = $null
        }

        It 'Deletes file from allowlisted entity type' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $PathParameter, $Method, $Session)
                $script:capturedDelete = @{
                    Route         = $Route
                    PathParameter = $PathParameter
                    Method        = $Method
                }
                return [pscustomobject]@{ status = 'success'; messages = 'File deleted' }
            }

            $res = Remove-SnipeitFile -EntityType 'hardware' -id 1 -file_id 15 -Confirm:$false -Session $script:testSession
            $res.status | Should -Be 'success'

            $script:capturedDelete.Route | Should -Be '/api/v1/{object_type}/{id}/files/{file_id}/delete'
            $script:capturedDelete.PathParameter.object_type | Should -Be 'hardware'
            $script:capturedDelete.PathParameter.id | Should -Be 1
            $script:capturedDelete.PathParameter.file_id | Should -Be 15
            $script:capturedDelete.Method | Should -Be 'DELETE'
        }

        It 'Rejects audits before making any HTTP call' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw 'Should not be called for audits'
            }

            # Audits is excluded from the ValidateSet on EntityType
            { Remove-SnipeitFile -EntityType 'audits' -id 1 -file_id 10 -Session $script:testSession } |
                Should -Throw
        }

        It 'Honors -WhatIf with zero HTTP requests' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                throw 'Should not be called when WhatIf is active'
            }

            { Remove-SnipeitFile -EntityType 'hardware' -id 1 -file_id 10 -WhatIf -Session $script:testSession } |
                Should -Not -Throw
        }

        It 'Accepts pipeline input for id and file_id' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($PathParameter)
                return [pscustomobject]@{ status = 'success' }
            }

            $inputItems = @(
                [pscustomobject]@{ id = 10; file_id = 101 },
                [pscustomobject]@{ id = 20; file_id = 102 }
            )

            $res = $inputItems | Remove-SnipeitFile -EntityType 'models' -Confirm:$false -Session $script:testSession
            @($res).Count | Should -Be 2
        }
    }
}
