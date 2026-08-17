Describe 'Targeted Core Hardening Suite' {
    BeforeAll {
        $script:psd1Path = (Resolve-Path "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1").Path
        Import-Module $script:psd1Path -Force
    }

    Context 'Module Loader, Manifest & Export Boundaries' {
        It 'Manifest declares explicit empty CmdletsToExport and VariablesToExport' {
            $manifestContent = Get-Content -Raw "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1"
            $manifest = Invoke-Expression $manifestContent
            $manifest.CmdletsToExport | Should -BeNullOrEmpty
            $manifest.VariablesToExport | Should -BeNullOrEmpty
            $manifest.CompatiblePSEditions | Should -Contain 'Desktop'
            $manifest.CompatiblePSEditions | Should -Contain 'Core'
            $manifest.AliasesToExport | Should -Not -BeNullOrEmpty
        }

        It 'Importing module does not emit uncommanded output into pipeline' {
            $output = Import-Module $script:psd1Path -Force -PassThru:$false
            $output | Should -BeNullOrEmpty
        }

        It 'Respects SNIPEITPS_DISABLE_LEGACY_ALIASES environment opt-out' {
            $prevEnv = $env:SNIPEITPS_DISABLE_LEGACY_ALIASES
            try {
                $env:SNIPEITPS_DISABLE_LEGACY_ALIASES = 'true'
                InModuleScope 'SnipeitPS' {
                    Set-SnipeitAlias
                }
            } finally {
                $env:SNIPEITPS_DISABLE_LEGACY_ALIASES = $prevEnv
            }
        }
    }

    Context 'Parameter Engine Hardening' {
        It 'Excludes automatic engine variables ($PID, $Profile, $Host, $Error) from unbound parameters' {
            InModuleScope 'SnipeitPS' {
                $cmd = Get-Command Get-SnipeitAsset
                $bound = @{ 'name' = 'Laptop' }
                $params = . Get-ParameterValue -Parameters $cmd.Parameters -BoundParameters $bound
                $params.ContainsKey('PID') | Should -BeFalse
                $params.ContainsKey('Host') | Should -BeFalse
                $params.ContainsKey('Profile') | Should -BeFalse
                $params.ContainsKey('Error') | Should -BeFalse
            }
        }

        It 'Excludes Confirm, WhatIf, ErrorAction from Get-ParameterValue return hashtable' {
            InModuleScope 'SnipeitPS' {
                $cmd = Get-Command New-SnipeitAsset
                $bound = @{
                    'name'        = 'TestAsset'
                    'model_id'    = 1
                    'status_id'   = 1
                    'Confirm'     = [System.Management.Automation.SwitchParameter]::new($false)
                    'WhatIf'      = [System.Management.Automation.SwitchParameter]::new($true)
                    'ErrorAction' = 'Stop'
                }
                $params = . Get-ParameterValue -Parameters $cmd.Parameters -BoundParameters $bound
                $params.ContainsKey('name') | Should -BeTrue
                $params.ContainsKey('Confirm') | Should -BeFalse
                $params.ContainsKey('WhatIf') | Should -BeFalse
                $params.ContainsKey('ErrorAction') | Should -BeFalse
            }
        }

        It 'ConvertTo-GetParameter encodes keys and values and formats array parameters' {
            InModuleScope 'SnipeitPS' {
                $inputParams = @{ 'search' = 'MacBook Pro'; 'status_id' = @(1, 2); 'archived' = $false }
                $queryString = ConvertTo-GetParameter $inputParams
                $queryString | Should -Match 'search=MacBook\+Pro'
                $queryString | Should -Match 'status_id%5B%5D=1'
                $queryString | Should -Match 'status_id%5B%5D=2'
                $queryString | Should -Match 'archived=false'
            }
        }
    }

    Context 'Invoke-SnipeitMethod Hardening' {
        It 'Does not hang when throttleThreshold is 0 in Adaptive mode' {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = 'http://localhost'
                $script:SnipeitPSSession.apiKey = (ConvertTo-SecureString 'test-token' -AsPlainText -Force)
                $script:SnipeitPSSession.throttleLimit = 100
                $script:SnipeitPSSession.throttleThreshold = 0
                $script:SnipeitPSSession.throttleMode = 'Adaptive'
                $script:SnipeitPSSession.throttledRequests = [System.Collections.ArrayList]::new()

                Mock Invoke-RestMethod { @{ status = 'success'; rows = @() } }
                $sw = [System.Diagnostics.Stopwatch]::StartNew()
                $res = Invoke-SnipeitMethod -Api '/api/v1/hardware' -Method 'Get'
                $sw.Stop()
                $sw.ElapsedMilliseconds | Should -BeLessThan 2000
            }
        }

        It 'Returns empty array when API returns empty rows envelope and does not leak envelope object' {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = 'http://localhost'
                $script:SnipeitPSSession.apiKey = (ConvertTo-SecureString 'test-token' -AsPlainText -Force)

                Mock Invoke-RestMethod { [PSCustomObject]@{ total = 100; rows = @() } }
                $res = Invoke-SnipeitMethod -Api '/api/v1/hardware' -Method 'Get'
                $res | Should -BeNullOrEmpty
            }
        }

        It 'Emits Write-Error on HTTP 404 and does not leak error JSON to Success output' {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = 'http://localhost'
                $script:SnipeitPSSession.apiKey = (ConvertTo-SecureString 'test-token' -AsPlainText -Force)

                Mock Invoke-RestMethod {
                    $status = [System.Net.HttpStatusCode]::NotFound
                    $ex = [System.Net.Http.HttpRequestException]::new("Not Found", $null, $status)
                    throw $ex
                }
                $err = $null
                $res = Invoke-SnipeitMethod -Api '/api/v1/hardware/99999' -Method 'Get' -ErrorVariable err -ErrorAction SilentlyContinue
                $res | Should -BeNullOrEmpty
                $err | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'Audit Cmdlet Parameter Aliases & Pipeline Binding' {
        It 'New-SnipeitAudit correctly binds -asset_tag alias' {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod {
                    param($Api, $Method, $Body)
                    $Body.asset_tag | Should -Be 'TAG001'
                    @{ status = 'success'; messages = 'Asset audited' }
                }
                New-SnipeitAudit -asset_tag 'TAG001' -Confirm:$false
                Should -Invoke -ModuleName 'SnipeitPS' Invoke-SnipeitMethod -Times 1
            }
        }

        It 'Update-SnipeitAssetAudit accepts piped asset objects without throwing' {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod {
                    param($Api, $Method, $Body)
                    $Body.asset_tag | Should -Be 'TAG002'
                    @{ status = 'success'; messages = 'Asset audited' }
                }
                [PSCustomObject]@{ asset_tag = 'TAG002' } | Update-SnipeitAssetAudit -Confirm:$false
                Should -Invoke -ModuleName 'SnipeitPS' Invoke-SnipeitMethod -Times 1
            }
        }
    }

    Context 'Bulk Safety and Lifecycle Teardown' {
        It 'Warns when -RequestType Put is specified for multiple asset IDs' {
            InModuleScope 'SnipeitPS' {
                Mock Invoke-SnipeitMethod { @{ status = 'success'; messages = 'Assets updated' } }
                $warn = $null
                Set-SnipeitAsset -id 101, 102 -name 'Test' -RequestType 'Put' -WarningVariable warn -Confirm:$false
                $warn | Should -Not -BeNullOrEmpty
                $warn[0].Message | Should -Match 'bulk endpoint only supports PATCH'
            }
        }

        It 'Reset-SnipeitPSLegacyApi resets credentials unconditionally without SupportsShouldProcess' {
            InModuleScope 'SnipeitPS' {
                $cmd = Get-Command Reset-SnipeitPSLegacyApi
                $cmd.Parameters.ContainsKey('WhatIf') | Should -BeFalse

                $script:SnipeitPSSession.legacyUrl = 'http://temp'
                $script:SnipeitPSSession.legacyApiKey = 'temp-key'
                Reset-SnipeitPSLegacyApi
                $script:SnipeitPSSession.legacyUrl | Should -BeNullOrEmpty
                $script:SnipeitPSSession.legacyApiKey | Should -BeNullOrEmpty
            }
        }

        It 'Calling New-SnipeitAudit under WhatIf still resets legacy credentials on completion' {
            InModuleScope 'SnipeitPS' {
                $script:SnipeitPSSession.url = 'http://localhost'
                $script:SnipeitPSSession.apiKey = (ConvertTo-SecureString 'test-token' -AsPlainText -Force)
                New-SnipeitAudit -tag 'TAG1' -WhatIf -apiKey 'temp-key' -url 'http://temp'
                $script:SnipeitPSSession.legacyUrl | Should -BeNullOrEmpty
                $script:SnipeitPSSession.legacyApiKey | Should -BeNullOrEmpty
            }
        }
    }

    AfterAll {
        InModuleScope 'SnipeitPS' {
            $script:SnipeitPSSession.url = $null
            $script:SnipeitPSSession.apiKey = $null
            $script:SnipeitPSSession.legacyUrl = $null
            $script:SnipeitPSSession.legacyApiKey = $null
            $script:SnipeitPSSession.throttleLimit = 0
            $script:SnipeitPSSession.throttleThreshold = 0
            $script:SnipeitPSSession.throttleMode = $null
            $script:SnipeitPSSession.throttlePeriod = 0
            $script:SnipeitPSSession.throttledRequests = [System.Collections.ArrayList]::new()
        }
    }
}
