#Requires -Modules PSScriptAnalyzer

$ruleData = @(Get-ScriptAnalyzerRule | Select-Object -ExpandProperty RuleName -Unique | ForEach-Object { @{ Rule = $_ } })

Describe "SnipeitPS" {
    BeforeAll {
        $testDir = $PSScriptRoot
        $projectRoot = Split-Path -Parent $testDir
        $moduleRoot = (Resolve-Path "$projectRoot/SnipeitPS").Path
        $settingsPath = (Resolve-Path "$projectRoot/PSScriptAnalyzerSettings.psd1").Path

        $files = @(
            Get-ChildItem -Path $testDir -Include *.ps1, *.psm1
            Get-ChildItem -Path (Join-Path $moduleRoot "Public") -Include *.ps1, *.psm1 -Recurse
        )
        $analysis = @(Get-ChildItem -Path $moduleRoot -Recurse -Include *.ps1, *.psm1, *.psd1 | Invoke-ScriptAnalyzer -Settings $settingsPath)
    }

    Context "Style checking" {
        It 'Source files contain no trailing whitespace' {
            $files | Should -Not -BeNullOrEmpty
            $badLines = @(
                foreach ($file in $files)
                {
                    $lines = [System.IO.File]::ReadAllLines($file.FullName)
                    $lineCount = $lines.Count

                    for ($i = 0; $i -lt $lineCount; $i++)
                    {
                        if ($lines[$i] -match '\s+$')
                        {
                            'File: {0}, Line: {1}' -f $file.FullName, ($i + 1)
                        }
                    }
                }
            )

            if ($badLines.Count -gt 0)
            {
                throw "The following $($badLines.Count) lines contain trailing whitespace: `r`n`r`n$($badLines -join "`r`n")"
            }
        }

        It 'Source files all end with a newline' {
            $files | Should -Not -BeNullOrEmpty
            $badFiles = @(
                foreach ($file in $files)
                {
                    $string = [System.IO.File]::ReadAllText($file.FullName)
                    if ($string.Length -gt 0 -and $string[-1] -ne "`n")
                    {
                        $file.FullName
                    }
                }
            )

            if ($badFiles.Count -gt 0)
            {
                throw "The following files do not end with a newline: `r`n`r`n$($badFiles -join "`r`n")"
            }
        }
    }

    Context 'PSScriptAnalyzer Rules' {
        It "Should pass <Rule>" -ForEach $ruleData {
            param($Rule)

            $failures = @($analysis | Where-Object RuleName -EQ $Rule)
            if ($failures.Count -gt 0)
            {
                $details = $failures | ForEach-Object {
                    "[{0}] {1}:{2} - {3}" -f $_.Severity, $_.ScriptName, $_.Line, $_.Message
                }
                $failureSummary = $details -join "`r`n"
                $failures.Count | Should -Be 0 -Because "Rule '$Rule' failed with:`r`n$failureSummary"
            }
            else
            {
                $failures.Count | Should -Be 0
            }
        }
    }
}
