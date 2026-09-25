BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Core authorization error propagation' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:deniedSession = [SnipeitSession]::new('https://contract.invalid', $key)
            $script:deniedSession.ThrottleLimit = 0
            Mock Invoke-RestMethod -ModuleName SnipeitPS {
                $exception = [System.Exception]::new('Forbidden')
                $exception | Add-Member -NotePropertyName Response -NotePropertyValue ([pscustomobject]@{ StatusCode = 403 })
                throw $exception
            }
        }

        Context '<Family> authorization failures' -ForEach @(
            @{ Family = 'Accessory'; Create = @{ name = 'Test'; category_id = 1; qty = 2 } }
            @{ Family = 'Asset'; Create = @{ model_id = 1; status_id = 1; asset_tag = 'TEST' } }
            @{ Family = 'Category'; Create = @{ name = 'Test'; category_type = 'asset' } }
            @{ Family = 'Company'; Create = @{ name = 'Test' } }
            @{ Family = 'Component'; Create = @{ name = 'Test'; category_id = 1; qty = 2 } }
            @{ Family = 'Consumable'; Create = @{ name = 'Test'; category_id = 1; qty = 2 } }
            @{ Family = 'CustomField'; Create = @{ name = 'Test'; element = 'text'; format = 'ANY' } }
            @{ Family = 'Department'; Create = @{ name = 'Test' } }
            @{ Family = 'Fieldset'; Create = @{ name = 'Test' } }
            @{ Family = 'Group'; Create = @{ name = 'Test'; permissions = @{ 'assets.view' = 1 } } }
            @{ Family = 'License'; Create = @{ name = 'Test'; category_id = 1; seats = 2 } }
            @{ Family = 'Location'; Create = @{ name = 'Test' } }
            @{ Family = 'Manufacturer'; Create = @{ name = 'Test' } }
            @{ Family = 'Model'; Create = @{ name = 'Test'; category_id = 1 } }
            @{ Family = 'Status'; Create = @{ name = 'Test'; type = 'deployable' } }
            @{ Family = 'Supplier'; Create = @{ name = 'Test' } }
            @{ Family = 'User'; Create = @{ first_name = 'Test'; username = 'test' } }
        ) {
            It 'Surfaces HTTP 403 for <Action> without returning success or retrying' -ForEach @(
                @{ Action = 'index'; Verb = 'Get' }
                @{ Action = 'show'; Verb = 'Get' }
                @{ Action = 'store'; Verb = 'New' }
                @{ Action = 'update'; Verb = 'Set' }
                @{ Action = 'destroy'; Verb = 'Remove' }
            ) {
                $parameters = @{ Session = $script:deniedSession; ErrorAction = 'Stop' }
                if ($Action -eq 'store') {
                    foreach ($entry in $Create.GetEnumerator()) { $parameters[$entry.Key] = $entry.Value }
                }
                if ($Action -in @('show', 'update', 'destroy')) { $parameters['id'] = 4 }
                if ($Action -eq 'update') {
                    $nameField = if ($Family -eq 'User') { 'first_name' } else { 'name' }
                    $parameters[$nameField] = 'Updated'
                }
                if ($Action -in @('store', 'update', 'destroy')) { $parameters['Confirm'] = $false }
                { & "$Verb-Snipeit$Family" @parameters } | Should -Throw '*HTTP 403*'
                Should -Invoke Invoke-RestMethod -ModuleName SnipeitPS -Exactly -Times 1
            }
        }
    }
}
