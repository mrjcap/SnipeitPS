<#
.SYNOPSIS
Builds and compiles PowerShell MAML XML documentation for SnipeitPS using platyPS.

.DESCRIPTION
Generates missing markdown help files in docs/, updates parameter schemas, compiles MAML help into SnipeitPS/en-US/SnipeitPS-help.xml, and packages about_SnipeitPS.help.txt.

.PARAMETER UpdateMarkdown
When specified, synchronizes docs/*.md with current cmdlet AST signatures.

.PARAMETER Force
Overwrites existing compiled help files.

.EXAMPLE
./build-docs.ps1
#>

[CmdletBinding()]
param(
    [switch]$UpdateMarkdown,
    [switch]$Force = $true
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Module -ListAvailable -Name platyPS)) {
    throw "platyPS module is required to build documentation. Run: Install-Module platyPS -Scope CurrentUser"
}

$env:SNIPEITPS_DISABLE_LEGACY_ALIASES = '1'

Import-Module platyPS -Force
$moduleRoot = Join-Path -Path $PSScriptRoot -ChildPath 'SnipeitPS'
$docsRoot = Join-Path -Path $PSScriptRoot -ChildPath 'docs'
$enUsRoot = Join-Path -Path $moduleRoot -ChildPath 'en-US'

if (-not (Test-Path $enUsRoot)) {
    New-Item -Path $enUsRoot -ItemType Directory -Force | Out-Null
}

# Import module to get command metadata
Import-Module (Join-Path $moduleRoot 'SnipeitPS.psd1') -Force

# Set dummy session in case any default values evaluate
$dummyKey = ConvertTo-SecureString "doc-build-key" -AsPlainText -Force
$script:SnipeitPSSession = [SnipeitSession]::new("https://docbuild.snipeit.local", $dummyKey)

Write-Host "Checking for missing cmdlet markdown documentation in $docsRoot..." -ForegroundColor Cyan
$exportedFunctions = Get-Command -Module SnipeitPS -CommandType Function
foreach ($cmd in $exportedFunctions) {
    $cmdDoc = Join-Path $docsRoot "$($cmd.Name).md"
    if (-not (Test-Path $cmdDoc)) {
        Write-Host "Generating new markdown help for $($cmd.Name)..." -ForegroundColor Yellow
        New-MarkdownHelp -Command $cmd.Name -OutputFolder $docsRoot -Force | Out-Null
    }
}

if ($UpdateMarkdown) {
    Write-Host "Updating Markdown help files in $docsRoot..." -ForegroundColor Cyan
    Update-MarkdownHelp -Path $docsRoot -UpdateInputOutput -Force | Out-Null
}

foreach ($docFile in Get-ChildItem $docsRoot -Filter '*.md' -File) {
    $content = [System.IO.File]::ReadAllText($docFile.FullName)
    $updated = $content.Replace('{{ Fill ProgressAction Description }}',
        'Controls how PowerShell displays progress records. Available in PowerShell 7.4 and later.')
    $sourcePath = Join-Path $moduleRoot "Public/$($docFile.BaseName).ps1"
    if ($UpdateMarkdown -and (Test-Path $sourcePath)) {
        $sourceAst = [System.Management.Automation.Language.Parser]::ParseFile($sourcePath, [ref]$null, [ref]$null)
        $functionAst = $sourceAst.Find({ param($node)
            $node -is [System.Management.Automation.Language.FunctionDefinitionAst]
        }, $false)
        $commentHelp = $functionAst.GetHelpContent()
        if ($commentHelp) {
            foreach ($parameter in $commentHelp.Parameters.GetEnumerator()) {
                if ([string]::IsNullOrWhiteSpace($parameter.Value)) { continue }
                $pattern = '(?ims)(^### -' + [regex]::Escape($parameter.Key) + '\r?\n).*?(?=^```yaml)'
                $description = $parameter.Value.Trim()
                $updated = [regex]::Replace($updated, $pattern, {
                    param($match)
                    $match.Groups[1].Value + "`n$description`n`n"
                })
            }
            if (-not [string]::IsNullOrWhiteSpace($commentHelp.Notes)) {
                $notes = $commentHelp.Notes.Trim()
                $updated = [regex]::Replace($updated, '(?ms)(^## NOTES\r?\n).*?(?=^## |\z)', {
                    param($match)
                    $match.Groups[1].Value + "`n$notes`n`n"
                })
            }
        }
    }
    if ($updated -cne $content) {
        [System.IO.File]::WriteAllText($docFile.FullName, $updated, [System.Text.UTF8Encoding]::new($false))
    }
}

Write-Host "Compiling external MAML XML help to $enUsRoot/SnipeitPS-help.xml..." -ForegroundColor Cyan
New-ExternalHelp -Path $docsRoot -OutputPath $enUsRoot -Force | Out-Null

# Generate / Copy about_SnipeitPS.help.txt
$aboutSource = Join-Path $docsRoot 'about_SnipeitPS.md'
$aboutTarget = Join-Path $enUsRoot 'about_SnipeitPS.help.txt'
if (Test-Path $aboutSource) {
    Write-Host "Packaging $aboutTarget..." -ForegroundColor Cyan
    Copy-Item -Path $aboutSource -Destination $aboutTarget -Force
}

Write-Host "Documentation build successfully completed." -ForegroundColor Green
