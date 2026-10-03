BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Additional self-service checkout request types' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'offline' -AsPlainText -Force
            $script:requestSession = [SnipeitSession]::new('https://requests.invalid', $key)
            $script:requestSession.ThrottleLimit = 0
            $script:requestCalls = [Collections.Generic.List[object]]::new()
            Mock Invoke-RestMethod {
                param($Uri, $Method, $Body)
                $json = [Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json
                $script:requestCalls.Add(@{ Uri = [string]$Uri; Method = $Method; Body = $json })
                [pscustomobject]@{ status = 'success'; payload = $null; messages = 'Saved' }
            }
        }

        Context '<Command>' -ForEach @(
            @{ Command = 'New-SnipeitAccountRequest'; Suffix = '' }
            @{ Command = 'Remove-SnipeitAccountRequest'; Suffix = '/cancel' }
        ) {
            It 'Uses the inventory <Type> ID and sends no body fields' -ForEach @(
                @{ Type = 'consumable'; Field = 'consumable_id' }
                @{ Type = 'component'; Field = 'component_id' }
                @{ Type = 'license'; Field = 'license_id' }
            ) {
                $parameters = @{ Session = $script:requestSession; Confirm = $false }
                $parameters[$Field] = 42
                & $Command @parameters
                $script:requestCalls.Count | Should -Be 1
                $script:requestCalls[0].Uri | Should -BeExactly "https://requests.invalid/api/v1/account/request/$Type/42$Suffix"
                $script:requestCalls[0].Method | Should -Be 'Post'
                @($script:requestCalls[0].Body.PSObject.Properties).Count | Should -Be 0
            }

            It 'Accepts deliberate <Field> pipeline properties and blocks WhatIf' -ForEach @(
                @{ Field = 'consumable_id' }
                @{ Field = 'component_id' }
                @{ Field = 'license_id' }
            ) {
                $parameters = @{ Session = $script:requestSession; Confirm = $false }
                $parameters[$Field] = 42
                & $Command @parameters -WhatIf
                $script:requestCalls.Count | Should -Be 0
                [pscustomobject]@{ $Field = 42 } | & $Command -Session $script:requestSession -Confirm:$false
                $script:requestCalls.Count | Should -Be 1
            }

            It 'Rejects nonpositive <Field> and conflicting types before HTTP' -ForEach @(
                @{ Field = 'consumable_id' }
                @{ Field = 'component_id' }
                @{ Field = 'license_id' }
            ) {
                $parameters = @{ Session = $script:requestSession; Confirm = $false }
                foreach ($badId in @(0, -1)) {
                    $parameters[$Field] = $badId
                    { & $Command @parameters } | Should -Throw
                }
                $parameters[$Field] = 42
                $parameters.asset_id = 2
                { & $Command @parameters } | Should -Throw
                $script:requestCalls.Count | Should -Be 0
            }

            It 'Does not invent accessory/model/request-row cancellation inputs' {
                foreach ($field in @('accessory_id', 'model_id', 'request_id')) {
                    $parameters = @{ Session = $script:requestSession; Confirm = $false }
                    $parameters[$field] = 42
                    { & $Command @parameters } | Should -Throw
                }
                $script:requestCalls.Count | Should -Be 0
            }
        }
    }
}
