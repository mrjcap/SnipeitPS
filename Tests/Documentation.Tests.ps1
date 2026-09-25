BeforeAll {
    . "$PSScriptRoot/../SnipeitPS/Classes/SnipeitCache.ps1"
    . "$PSScriptRoot/../SnipeitPS/Classes/SnipeitSession.ps1"
    . "$PSScriptRoot/../SnipeitPS/Classes/SnipeitCompleters.ps1"
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force

    $script:moduleRoot = (Resolve-Path "$PSScriptRoot/../SnipeitPS").Path
    $script:docsRoot = (Resolve-Path "$PSScriptRoot/../docs").Path
    $script:enUsRoot = Join-Path $script:moduleRoot "en-US"
    $script:helpXml = Join-Path $script:enUsRoot "SnipeitPS-help.xml"
    $script:aboutTxt = Join-Path $script:enUsRoot "about_SnipeitPS.help.txt"
}

Describe "Documentation & platyPS MAML Coverage" {
    Context "Compiled MAML Help Files" {
        It "Contains en-US directory with compiled SnipeitPS-help.xml" {
            (Test-Path $script:helpXml) | Should -BeTrue
        }

        It "SnipeitPS-help.xml is valid XML" {
            { [xml](Get-Content $script:helpXml -Raw) } | Should -Not -Throw
        }

        It "Contains about_SnipeitPS.help.txt in en-US" {
            (Test-Path $script:aboutTxt) | Should -BeTrue
        }
    }

    Context "Markdown Help Coverage for Exported Functions" {
        It "Every exported public cmdlet has a matching markdown document" {
            $exportedFunctions = Get-Command -Module SnipeitPS -CommandType Function
            $missingDocs = [System.Collections.Generic.List[string]]::new()

            foreach ($cmd in $exportedFunctions) {
                $docPath = Join-Path $script:docsRoot "$($cmd.Name).md"
                if (-not (Test-Path $docPath)) {
                    $missingDocs.Add($cmd.Name)
                }
            }

            $missingDocs.Count | Should -Be 0
        }

        It 'Documents nullable create inputs for <Family>' -ForEach @(
            @{ Family = 'Accessory' }
            @{ Family = 'Asset' }
            @{ Family = 'Component' }
            @{ Family = 'Consumable' }
            @{ Family = 'Department' }
            @{ Family = 'License' }
            @{ Family = 'Location' }
            @{ Family = 'Model' }
            @{ Family = 'User' }
        ) {
            $markdown = Get-Content (Join-Path $script:docsRoot "New-Snipeit$Family.md") -Raw
            $markdown | Should -Match 'accept[s]? explicit null'
        }

        It "Contains zero unpopulated platyPS template placeholders in markdown files" {
            $placeholders = Get-ChildItem $script:docsRoot -Filter *.md | Select-String -Pattern '\{\{\s*Fill'
            $placeholders.Count | Should -Be 0
        }
    }

    Context "Offline Get-Help Integration" {
        It "Returns structured MAML help for Get-SnipeitAsset" {
            $help = Get-Help Get-SnipeitAsset -Full
            $help | Should -Not -BeNullOrEmpty
            $help.Synopsis | Should -Not -BeNullOrEmpty
        }

        It "Returns conceptual help for about_SnipeitPS" {
            $help = Get-Help about_SnipeitPS
            $help | Should -Not -BeNullOrEmpty
        }
    }
}
