#Requires -Modules PSScriptAnalyzer

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $here
$moduleRoot = "$projectRoot\SnipeitPS"

$publicFunctions = "$moduleRoot\Public"

Describe "SnipeitPS" {
    Context "Style checking" {

        # This section is again from the mastermind, Dave Wyatt. Again, credit
        # goes to him for these tests.

        $files = @(
            Get-ChildItem $here -Include *.ps1, *.psm1
            Get-ChildItem $publicFunctions -Include *.ps1, *.psm1 -Recurse
        )

        It 'Source files contain no trailing whitespace' {
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
        $analysis = Invoke-ScriptAnalyzer -Path "$moduleRoot" -Recurse -Settings "$projectRoot\PSScriptAnalyzerSettings.psd1"
        $scriptAnalyzerRules = Get-ScriptAnalyzerRule

        forEach ($rule in $scriptAnalyzerRules)
        {
            It "Should pass $rule" {
                If (($analysis) -and ($analysis.RuleName -contains $rule))
                {
                    $analysis |
                        Where-Object RuleName -EQ $rule -OutVariable failures |
                        Out-Default
                    $failures.Count | Should -Be 0
                }
            }
        }
    }
}
