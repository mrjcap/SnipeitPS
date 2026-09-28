BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Get-SnipeitFile' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $sess = [SnipeitSession]::new('https://contract.invalid', $key)
            $sess.ThrottleLimit = 0
            $script:testSession = $sess
        }

        Context 'Listing files' {
            It 'Calls correct route and passes query parameters for allowlisted EntityType' {
                $script:captured = $null
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $PathParameter, $GetParameters, $Session)
                    $script:captured = @{
                        Route         = $Route
                        PathParameter = $PathParameter
                        GetParameters = $GetParameters
                    }
                    return @([pscustomobject]@{ id = 10; filename = 'asset_doc.pdf' })
                }

                $res = Get-SnipeitFile -EntityType 'hardware' -id 42 -search 'doc' -sort 'created_at' -order 'desc' -Session $script:testSession
                @($res).Count | Should -Be 1
                $res[0].filename | Should -Be 'asset_doc.pdf'

                $script:captured.Route | Should -Be '/api/v1/{object_type}/{id}/files'
                $script:captured.PathParameter.object_type | Should -Be 'hardware'
                $script:captured.PathParameter.id | Should -Be 42
                $script:captured.GetParameters.search | Should -Be 'doc'
                $script:captured.GetParameters.sort | Should -Be 'created_at'
                $script:captured.GetParameters.order | Should -Be 'desc'
            }

            It 'Works with each allowlisted entity type' {
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    return [pscustomobject]@{ total = 0; rows = @() }
                }

                $types = @('accessories', 'audits', 'assets', 'components', 'consumables', 'hardware', 'licenses', 'locations', 'maintenances', 'models', 'suppliers', 'users', 'companies', 'departments')
                foreach ($t in $types) {
                    { Get-SnipeitFile -EntityType $t -id 1 -Session $script:testSession } | Should -Not -Throw
                }
            }
        }

        Context 'Single file retrieval' {
            It 'Rejects <Label> without file_id before transport' -ForEach @(
                @{ Label = 'inline'; Options = @{ inline = $true } }
                @{ Label = 'inline false'; Options = @{ inline = $false } }
                @{ Label = 'AsByteArray'; Options = @{ AsByteArray = $true } }
                @{ Label = 'AsByteArray false'; Options = @{ AsByteArray = $false } }
            ) {
                Mock Invoke-SnipeitMethod {}
                Mock Save-SnipeitApiFile {}

                {
                    Get-SnipeitFile -EntityType hardware -id 42 @Options -Session $script:testSession
                } | Should -Throw -ExpectedMessage 'file_id is required for single-file retrieval.'

                Should -Invoke Invoke-SnipeitMethod -Times 0 -Exactly
                Should -Invoke Save-SnipeitApiFile -Times 0 -Exactly
            }

            It 'Retrieves single file using file_id' {
                $script:captured = $null
                Mock Invoke-SnipeitMethod -ModuleName SnipeitPS {
                    param($Route, $PathParameter, $Session)
                    $script:captured = @{
                        Route         = $Route
                        PathParameter = $PathParameter
                    }
                    return [pscustomobject]@{ id = 5; filename = 'manual.pdf' }
                }

                $res = Get-SnipeitFile -EntityType 'models' -id 12 -file_id 5 -Session $script:testSession
                $res.id | Should -Be 5
                $script:captured.Route | Should -Be '/api/v1/{object_type}/{id}/files/{file_id}'
                $script:captured.PathParameter.object_type | Should -Be 'models'
                $script:captured.PathParameter.id | Should -Be 12
                $script:captured.PathParameter.file_id | Should -Be 5
            }

            It 'Returns structured SnipeitPS.FileContent when -AsByteArray is specified' {
                [byte[]]$bytes = 1, 2, 3, 4, 5
                Mock Save-SnipeitApiFile -ModuleName SnipeitPS {
                    param($Uri, $OutFile, $EntityType, $Id, $FileId, $Force, $Session)
                    [System.IO.File]::WriteAllBytes($OutFile, $bytes)
                    return [pscustomobject]@{
                        PSTypeName  = 'SnipeitPS.FileDownload'
                        EntityType  = $EntityType
                        Id          = $Id
                        FileId      = $FileId
                        Path        = $OutFile
                        Length      = $bytes.Length
                        ContentType = 'application/octet-stream'
                    }
                }

                $res = Get-SnipeitFile -EntityType 'assets' -id 10 -file_id 3 -AsByteArray -Session $script:testSession
                $res.PSObject.TypeNames | Should -Contain 'SnipeitPS.FileContent'
                $res.EntityType | Should -Be 'assets'
                $res.Id | Should -Be 10
                $res.FileId | Should -Be 3
                $res.Content | Should -Be $bytes
                $res.Length | Should -Be 5
            }
        }
    }
}
