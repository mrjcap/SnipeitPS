BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitImport' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
            $script:capturedParams = $null
        }

        It 'Invokes GET /api/v1/imports and returns unpaginated imports' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                param($Route, $Method, $Session)
                $script:capturedParams = @{
                    Route   = $Route
                    Method  = $Method
                    Session = $Session
                }
                return @(
                    [pscustomobject]@{
                        id          = 1
                        name        = 'sample.csv'
                        file_path   = '2026-sample.csv'
                        import_type = 'asset'
                    },
                    [pscustomobject]@{
                        id          = 2
                        name        = 'users.csv'
                        file_path   = '2026-users.csv'
                        import_type = 'user'
                    }
                )
            }

            $res = @(Get-SnipeitImport -Session $script:testSession)
            $res.Count | Should -Be 2
            $res[0].name | Should -Be 'sample.csv'
            $res[1].name | Should -Be 'users.csv'

            $script:capturedParams.Route | Should -Be '/api/v1/imports'
            $script:capturedParams.Method | Should -Be 'GET'
            $script:capturedParams.Session | Should -Be $script:testSession
        }

        It 'Emits zero records for empty API response' {
            Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                return @()
            }

            $res = @(Get-SnipeitImport -Session $script:testSession)
            $res.Count | Should -Be 0
        }
    }
}
