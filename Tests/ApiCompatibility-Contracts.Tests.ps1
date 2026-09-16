BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Verified API compatibility contracts' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $script:SnipeitPSSession.url = 'https://contract.invalid'
            $script:SnipeitPSSession.apiKey = 'test-only-key'
            $script:SnipeitPSSession.throttleLimit = 0
            $script:requests = [System.Collections.Generic.List[object]]::new()
            Mock Invoke-RestMethod {
                $parsed = if ($Body) { [Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json } else { $null }
                $script:requests.Add([pscustomobject]@{ Uri = [string]$Uri; Method = $Method; Body = $parsed })
                [pscustomobject]@{ status = 'success'; messages = 'Saved'; payload = [pscustomobject]@{ id = 1 } }
            }
        }

        It 'New-SnipeitUser sends replacement company_ids for multiple companies and legacy alias' {
            New-SnipeitUser -first_name A -last_name B -username ab -companies 2,7
            New-SnipeitUser -first_name A -last_name B -username ab -company_id 4
            $script:requests[0].Body.company_ids | Should -Be @(2,7)
            $script:requests[1].Body.company_ids | Should -Be @(4)
            $script:requests[0].Body.PSObject.Properties.Name | Should -Not -Contain 'companies'
        }

        It 'Set-SnipeitUser sends replacement company_ids and preserves omission' {
            Set-SnipeitUser -id 1 -companies 2,7 -Confirm:$false
            Set-SnipeitUser -id 1 -company_id 4 -Confirm:$false
            Set-SnipeitUser -id 1 -notes x -Confirm:$false
            $script:requests[0].Body.company_ids | Should -Be @(2,7)
            $script:requests[1].Body.company_ids | Should -Be @(4)
            $script:requests[2].Body.PSObject.Properties.Name | Should -Not -Contain 'company_ids'
            $script:requests[0].Body.PSObject.Properties.Name | Should -Not -Contain 'companies'
        }

        It 'New-SnipeitUser preserves omitted memberships' {
            New-SnipeitUser -first_name A -last_name B -username ab
            $script:requests[0].Body.PSObject.Properties.Name | Should -Not -Contain 'company_ids'
        }

        It 'Update-SnipeitAssetBulk uses PATCH hardware/bulk and retains 100-ID chunks' {
            Update-SnipeitAssetBulk -id (1..101) -notes x -Confirm:$false
            $script:requests.Count | Should -Be 2
            $script:requests[0].Uri | Should -Be 'https://contract.invalid/api/v1/hardware/bulk'
            $script:requests[0].Method | Should -Be 'PATCH'
            $script:requests[0].Body.ids.Count | Should -Be 100
            $script:requests[1].Body.ids | Should -Be @(101)
        }

        It 'Remove-SnipeitAssetBulk deletes each unique ID and emits associated outcomes' {
            $result = @(Remove-SnipeitAssetBulk -id 5,9,5 -Confirm:$false)
            $script:requests.Count | Should -Be 2
            $script:requests[0].Uri | Should -Be 'https://contract.invalid/api/v1/hardware/5'
            $script:requests[1].Uri | Should -Be 'https://contract.invalid/api/v1/hardware/9'
            $script:requests[0].Method | Should -Be 'DELETE'
            $result.id | Should -Be @(5,9)
            $result[0].status | Should -Be 'success'
            $result[0].messages | Should -Be 'Saved'
            $result[0].payload.id | Should -Be 1
        }

        It 'Remove-SnipeitAssetBulk preserves business failure details and continues to the next ID' {
            Mock Invoke-RestMethod {
                [pscustomobject]@{ status = 'error'; messages = @{ id = @('Missing') }; payload = $null }
            } -ParameterFilter { $Uri -like '*/hardware/5' }
            $failures = @()
            $result = @(Remove-SnipeitAssetBulk -id 5,9 -Confirm:$false -ErrorAction SilentlyContinue -ErrorVariable failures)
            $result.Count | Should -Be 2
            $result[0].id | Should -Be 5
            $result[0].status | Should -Be 'error'
            $result[0].messages.id | Should -Be @('Missing')
            $result[0].payload | Should -BeNullOrEmpty
            $result[1].status | Should -Be 'success'
            $failures.Count | Should -BeGreaterThan 0
        }

        It 'Bulk calls propagate explicit Session to HTTP' {
            $session = [SnipeitSession]::new('https://other.invalid', (ConvertTo-SecureString 'test-only-key' -AsPlainText -Force))
            Update-SnipeitAssetBulk -id 1,2 -notes x -Session $session -Confirm:$false
            Remove-SnipeitAssetBulk -id 3 -Session $session -Confirm:$false
            $script:requests[0].Uri | Should -Be 'https://other.invalid/api/v1/hardware/bulk'
            $script:requests[1].Uri | Should -Be 'https://other.invalid/api/v1/hardware/3'
        }

        It 'Bulk mutations honor WhatIf without HTTP calls' {
            Update-SnipeitAssetBulk -id 1,2 -notes x -WhatIf
            Remove-SnipeitAssetBulk -id 1,2 -WhatIf
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly
        }

        It 'Invoke-SnipeitMethod preserves success bulk results before payload extraction' {
            Mock Invoke-RestMethod {
                [pscustomobject]@{ status = 'success'; messages = '2 updated'; results = @(
                    [pscustomobject]@{ id = 1; status = 'success'; messages = 'one'; payload = @{ id = 1 } },
                    [pscustomobject]@{ id = 2; status = 'success'; messages = 'two'; payload = @{ id = 2 } }
                ) }
            }
            $result = Set-SnipeitAsset -id 1,2 -notes x -Confirm:$false
            $result.status | Should -Be 'success'
            $result.results.Count | Should -Be 2
            $result.results[1].messages | Should -Be 'two'
            $result.results[1].payload.id | Should -Be 2
        }

        It 'Invoke-SnipeitMethod preserves partial bulk envelopes' {
            Mock Invoke-RestMethod {
                [pscustomobject]@{ status = 'partial'; messages = '1 failed'; results = @(
                    [pscustomobject]@{ id = 1; status = 'success'; messages = 'ok'; payload = @{ id = 1 } },
                    [pscustomobject]@{ id = 2; status = 'error'; messages = 'denied'; payload = $null }
                ) }
            }
            $result = New-SnipeitAudit -id 1,2 -note x -Confirm:$false
            $result.status | Should -Be 'partial'
            $result.results[1].status | Should -Be 'error'
            $result.results[1].messages | Should -Be 'denied'
        }

        It 'Invoke-SnipeitMethod keeps complete all-error bulk envelope in TargetObject' {
            Mock Invoke-RestMethod {
                [pscustomobject]@{ status = 'error'; messages = 'failed'; results = @(
                    [pscustomobject]@{ id = 1; status = 'error'; messages = 'missing'; payload = $null }
                ) }
            }
            $apiErrors = @()
            $result = Invoke-SnipeitMethod -Api '/api/v1/hardware/bulk' -Method PATCH -Body @{ ids = @(1) } -ErrorAction SilentlyContinue -ErrorVariable apiErrors
            $result | Should -BeNullOrEmpty
            $apiErrors[0].FullyQualifiedErrorId | Should -Match 'SnipeitApiError'
            $apiErrors[0].TargetObject.results[0].messages | Should -Be 'missing'
        }
    }
}
