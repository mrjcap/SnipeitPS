BeforeAll {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
    $script:acquisitionContract = Import-PowerShellDataFile "$PSScriptRoot/Fixtures/Acquisition.Contracts.psd1"
}

Describe 'Current acquisition contract supplement' {
    It 'Pins acquisition evidence without repinning the historical API ledger' {
        $script:acquisitionContract.ApiRef | Should -BeExactly '5d7fe00370813649d6b535a43d3a47ec51adbab2'
        $ledger = Get-Content "$PSScriptRoot/Fixtures/ApiParity.Contracts.psd1" -Raw
        $ledger | Should -Match "ApiRef = '0c381a6482824a9f5d1889a98843393a0b6ad6b3'"
        $ledger | Should -Match "AcquisitionContract = 'Tests/Fixtures/Acquisition.Contracts.psd1'"
    }

    It 'Records only the four routed acquisition operations' {
        @($script:acquisitionContract.Operations).Count | Should -Be 4
        $script:acquisitionContract.Operations.Key | Should -Be @('order-items.index', 'accessories.adjust-quantity', 'components.adjust-quantity', 'consumables.adjust-quantity')
        foreach ($operation in $script:acquisitionContract.Operations) {
            $operation.Source | Should -Not -BeNullOrEmpty
            $operation.Authorization | Should -Not -BeNullOrEmpty
            $operation.Route | Should -Match '^/api/v1/'
            Get-Command $operation.Command -Module SnipeitPS | Should -Not -BeNullOrEmpty
            Test-Path (Join-Path "$PSScriptRoot/.." $operation.TestFile) | Should -BeTrue
            foreach ($field in $operation.RequiredFields + $operation.NullableFields) {
                ($operation.BodyFields + $operation.QueryFields) | Should -Contain $field
            }
        }
    }

    It 'Exposes every newly recorded field on the existing commands' {
        foreach ($entry in $script:acquisitionContract.ExistingCommandFields) {
            $command = Get-Command $entry.Command
            foreach ($field in $entry.Fields) { $command.Parameters.Keys | Should -Contain $field }
        }
    }

    It 'Includes compiled help for all eight affected commands and their new fields' {
        $helpText = Get-Content "$PSScriptRoot/../SnipeitPS/en-US/SnipeitPS-help.xml" -Raw
        $help = [xml]$helpText
        $namespaces = [Xml.XmlNamespaceManager]::new($help.NameTable)
        $namespaces.AddNamespace('command', 'http://schemas.microsoft.com/maml/dev/command/2004/10')
        $namespaces.AddNamespace('maml', 'http://schemas.microsoft.com/maml/2004/10')
        $commands = @('Get-SnipeitOrderItem', 'Invoke-SnipeitQuantityAdjustment') + $script:acquisitionContract.ExistingCommandFields.Command
        foreach ($name in $commands) {
            $nodes = $help.SelectNodes("//command:command[command:details/command:name='$name']", $namespaces)
            $nodes.Count | Should -Be 1
            $nodes[0].OuterXml | Should -Not -Match '\{\{\s*Fill'
            $fields = @($script:acquisitionContract.ExistingCommandFields | Where-Object Command -EQ $name).Fields
            foreach ($field in $fields) {
                $nodes[0].SelectNodes("command:parameters/command:parameter[maml:name='$field']", $namespaces).Count | Should -Be 1
            }
        }
    }

    It 'Records acquisition persistence and compatibility limitations' {
        $script:acquisitionContract.Limitations.Count | Should -BeGreaterThan 0
        foreach ($limitation in $script:acquisitionContract.Limitations) {
            $limitation.Source | Should -Not -BeNullOrEmpty
            $limitation.Reason | Should -Not -BeNullOrEmpty
        }
    }
}
