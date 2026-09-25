BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Core update pipeline routing' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:pipelineSession = [SnipeitSession]::new('https://contract.invalid', $key)
            $script:pipelineSession.ThrottleLimit = 0
            $script:pipelineCalls = [System.Collections.Generic.List[object]]::new()
            Mock Invoke-RestMethod -ModuleName SnipeitPS {
                param($Uri, $Body)
                $script:pipelineCalls.Add(@{
                    Path = ([uri]$Uri).AbsolutePath
                    Json = [Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json
                })
                [pscustomobject]@{ status = 'success'; payload = @{ id = 1 } }
            }
        }

        It 'Routes differing pipeline IDs for <Family> without serializing IDs into the body' -ForEach @(
            @{ Family = 'Accessory'; Resource = 'accessories' }
            @{ Family = 'Asset'; Resource = 'hardware' }
            @{ Family = 'Category'; Resource = 'categories' }
            @{ Family = 'Company'; Resource = 'companies' }
            @{ Family = 'Component'; Resource = 'components' }
            @{ Family = 'Consumable'; Resource = 'consumables' }
            @{ Family = 'CustomField'; Resource = 'fields' }
            @{ Family = 'Department'; Resource = 'departments' }
            @{ Family = 'Fieldset'; Resource = 'fieldsets' }
            @{ Family = 'Group'; Resource = 'groups' }
            @{ Family = 'License'; Resource = 'licenses' }
            @{ Family = 'Location'; Resource = 'locations' }
            @{ Family = 'Manufacturer'; Resource = 'manufacturers' }
            @{ Family = 'Model'; Resource = 'models' }
            @{ Family = 'Status'; Resource = 'statuslabels' }
            @{ Family = 'Supplier'; Resource = 'suppliers' }
            @{ Family = 'User'; Resource = 'users' }
        ) {
            $parameters = @{ Session = $script:pipelineSession; Confirm = $false }
            $nameField = if ($Family -eq 'User') { 'first_name' } else { 'name' }
            $parameters[$nameField] = 'Updated'
            if ($Family -eq 'Status') {
                $parameters['type'] = 'deployable'
                $parameters['color'] = '#123456'
                $parameters['show_in_nav'] = $false
                $parameters['default_label'] = $false
            }
            @([pscustomobject]@{ id = 11 }, [pscustomobject]@{ id = 22 }) |
                & "Set-Snipeit$Family" @parameters
            $script:pipelineCalls.Count | Should -Be 2
            $script:pipelineCalls[0].Path | Should -BeExactly "/api/v1/$Resource/11"
            $script:pipelineCalls[1].Path | Should -BeExactly "/api/v1/$Resource/22"
            foreach ($call in $script:pipelineCalls) {
                $call.Json.$nameField | Should -BeExactly 'Updated'
                $call.Json.PSObject.Properties.Name | Should -Not -Contain 'id'
            }
        }
    }
}
