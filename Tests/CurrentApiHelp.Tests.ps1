BeforeDiscovery {
    $helpCommands = @('Get-SnipeitCheckoutRequest','Get-SnipeitRequestableItem','Get-SnipeitDashboardActivity','Get-SnipeitDashboardSummary','Get-SnipeitModelAsset','Get-SnipeitUserConsumable','Get-SnipeitLowStockItem','Get-SnipeitCalendarEvent','Restore-SnipeitModel','Revoke-SnipeitCurrentToken','New-SnipeitAsset','New-SnipeitMaintenanceType','Set-SnipeitMaintenanceType','Invoke-SnipeitImport','Set-SnipeitLicenseOwner','New-SnipeitAccountRequest','Remove-SnipeitAccountRequest','Get-SnipeitAccountRequest','Get-SnipeitUserAccessory','Get-SnipeitUserLicense','Get-SnipeitAccessory','Get-SnipeitLicense','Get-SnipeitOrderItem','Invoke-SnipeitQuantityAdjustment','New-SnipeitAccessory','Set-SnipeitAccessory','New-SnipeitComponent','Set-SnipeitComponent','New-SnipeitConsumable','Set-SnipeitConsumable','New-SnipeitLicense','Set-SnipeitLicense')
}
BeforeAll {
    $repo = Split-Path $PSScriptRoot -Parent
    $env:SNIPEITPS_DISABLE_LEGACY_ALIASES = '1'
    Import-Module "$repo/SnipeitPS/SnipeitPS.psd1" -Force
    $mamlText = [IO.File]::ReadAllText("$repo/SnipeitPS/en-US/SnipeitPS-help.xml")
    $maml = [xml]$mamlText
    $commands = @{}
    foreach ($node in $maml.SelectNodes('//*[local-name()="command"]')) {
        $name = $node.SelectSingleNode('./*[local-name()="details"]/*[local-name()="name"]').InnerText
        $commands[$name] = $node
    }
    $common = @('Verbose','Debug','ErrorAction','WarningAction','InformationAction','ProgressAction','ErrorVariable','WarningVariable','InformationVariable','OutVariable','OutBuffer','PipelineVariable','WhatIf','Confirm')
}
Describe 'Current API Markdown and compiled help' {
    It 'documents exported parameters without placeholders for <_>' -ForEach $helpCommands {
        $name = $_
        $command = Get-Command $name -Module SnipeitPS
        $markdown = [IO.File]::ReadAllText("$repo/docs/$name.md")
        $markdown | Should -Not -Match '\{\{.*?\}\}'
        $commands.ContainsKey($name) | Should -BeTrue
        $commands[$name].OuterXml | Should -Not -Match '\{\{.*?\}\}'
        $documented = @($commands[$name].SelectNodes('./*[local-name()="parameters"]/*[local-name()="parameter"]/*[local-name()="name"]') | ForEach-Object { $_.InnerText })
        foreach ($parameter in $command.Parameters.Keys | Where-Object { $_ -notin $common }) {
            $documented | Should -Contain $parameter
            $markdown | Should -Match ('(?im)^### -' + [regex]::Escape($parameter) + '\r?$')
        }
    }
    It 'explains pending-only listings and inventory identity boundaries' {
        $commands['Get-SnipeitAccountRequest'].OuterXml | Should -Match 'not request history'
        $commands['Get-SnipeitAccountRequest'].OuterXml | Should -Match 'id retains its original request ID'
        $commands['Get-SnipeitAccountRequest'].OuterXml | Should -Match 'NormalizeIdentity'
        $commands['Get-SnipeitRequestableItem'].OuterXml | Should -Match 'no model or accessory account request mutation route'
        $commands['Get-SnipeitUserConsumable'].OuterXml | Should -Match 'checkout_id'
    }
    It 'explains the maintenance read permission and non-atomic preservation' {
        $commands['Set-SnipeitMaintenanceType'].OuterXml | Should -Match 'view permission'
        $commands['Set-SnipeitMaintenanceType'].OuterXml | Should -Match 'not atomic'
    }
    It 'explains flag persistence, license preconditions, and token limits' {
        $commands['Invoke-SnipeitImport'].OuterXml | Should -Match 'every slice'
        $commands['Set-SnipeitLicenseOwner'].OuterXml | Should -Match 'license is reassignable'
        $commands['Revoke-SnipeitCurrentToken'].OuterXml | Should -Match 'OIDC'
        $commands['Revoke-SnipeitCurrentToken'].OuterXml | Should -Match '204'
    }
}
