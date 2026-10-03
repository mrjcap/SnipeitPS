BeforeAll {
    . "$PSScriptRoot/Support/Import-SnipeitFixtureData.ps1"
    $script:currentContract = Import-SnipeitFixtureData "$PSScriptRoot/Fixtures/CurrentApi.Contracts.psd1"
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
    $script:historicalContract = Import-SnipeitFixtureData "$PSScriptRoot/Fixtures/ApiParity.Contracts.psd1"
    $script:currentManifest = Import-PowerShellDataFile "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1"
}

Describe 'Current API delta contract' {
    It 'Pins the delta without replacing the historical audit' {
        $script:currentContract.ApiRef | Should -BeExactly '5d7fe00370813649d6b535a43d3a47ec51adbab2'
        $script:currentContract.BaseApiRef | Should -BeExactly $script:historicalContract.ApiRef
        $script:historicalContract.CurrentApiContract | Should -BeExactly 'Tests/Fixtures/CurrentApi.Contracts.psd1'
        $script:currentContract.Scope | Should -BeExactly 'Route delta, parameter re-audit and model-field changes'
        $script:currentContract.Additions.Count | Should -Be 25
        $script:currentContract.Overrides.Count | Should -Be 1
        $script:currentContract.MiddlewareChanges.Count | Should -Be 2
        @($script:currentContract.Additions.Route | Select-Object -Unique).Count | Should -Be 25
    }

    It 'Binds every added and repaired route to an exported tested command' {
        foreach ($operation in @($script:currentContract.Additions) + @($script:currentContract.Overrides)) {
            $operation.Command | Should -BeIn $script:currentManifest.FunctionsToExport
            Test-Path "$PSScriptRoot/../$($operation.TestFile)" | Should -BeTrue
            $operation.Source | Should -Not -BeNullOrEmpty
            $operation.Method | Should -BeIn @('GET', 'POST')
            $operation.State | Should -BeExactly 'VerifiedOffline'
        }
    }

    It 'Keeps the historical model-assets blocker and records the repair separately' {
        $old = $script:historicalContract.Operations | Where-Object Key -EQ 'models.assets'
        $old.Route | Should -BeExactly '/api/v1/models/assets'
        $old.State | Should -BeExactly 'BlockedServer'
        $new = $script:currentContract.Overrides[0]
        $new.Key | Should -BeExactly 'models.assets'
        $new.Route | Should -BeExactly '/api/v1/models/{id}/assets'
        $new.PreviousRoute | Should -BeExactly $old.Route
        $new.QueryFields | Should -Be @('limit', 'offset')
    }

    It 'Records the LDAP throttles as middleware changes, not additions' {
        $script:currentContract.MiddlewareChanges.Route | Should -Contain '/api/v1/settings/ldaptest'
        $script:currentContract.MiddlewareChanges.Route | Should -Contain '/api/v1/settings/ldaptestlogin'
        $script:currentContract.MiddlewareChanges.Middleware | Select-Object -Unique | Should -BeExactly 'throttle:5,1'
    }

    It 'Binds the parameter re-audit to exported tested commands' {
        $fields = @($script:currentContract.ReauditedCommandFields)
        $fields.Count | Should -Be 15
        @($fields.Command | Select-Object -Unique).Count | Should -Be 15
        foreach ($entry in $fields) {
            $entry.Command | Should -BeIn $script:currentManifest.FunctionsToExport
            Test-Path "$PSScriptRoot/../$($entry.TestFile)" | Should -BeTrue
            $entry.Source | Should -Not -BeNullOrEmpty
            $entry.Fields | Should -Not -BeNullOrEmpty
            $command = Get-Command $entry.Command
            foreach ($field in $entry.Fields) {
                $command.Parameters.Keys | Should -Contain $field
            }
        }
    }

    It 'Records all ten model-field parameters separately from new routes' {
        $fields = @($script:currentContract.ReauditedCommandFields | Where-Object ContractKind -EQ 'ModelFields')
        $fields.Count | Should -Be 8
        ($fields | ForEach-Object { $_.Fields.Count } | Measure-Object -Sum).Sum | Should -Be 10
        foreach ($entry in $fields) {
            $command = Get-Command $entry.Command
            foreach ($field in $entry.Fields) {
                $expectedType = if ($field -eq 'requestable') { [Nullable[bool]] } else { [Nullable[decimal]] }
                $command.Parameters[$field].ParameterType | Should -Be $expectedType
            }
        }
    }

    It 'Records the targeted existing-command fields without inventing endpoints' {
        $script:currentContract.ExistingCommandFields.Command | Should -Contain 'New-SnipeitAsset'
        $script:currentContract.ExistingCommandFields.Command | Should -Contain 'Set-SnipeitMaintenanceType'
        $script:currentContract.ExistingCommandFields.Command | Should -Contain 'Invoke-SnipeitImport'
        $script:currentContract.ExistingCommandFields.Command | Should -Contain 'Set-SnipeitLicenseOwner'
        $script:currentContract.Limitations | Should -Not -BeNullOrEmpty
    }
}
