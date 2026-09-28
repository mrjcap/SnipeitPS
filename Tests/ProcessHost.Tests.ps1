Describe 'Subprocess test host selection' {
    BeforeAll {
        $hostAssignments = @(
            foreach ($name in @('Policy-Https-Mcp-CI.Tests.ps1', 'Security-CI.Tests.ps1')) {
                $tokens = $null
                $parseErrors = $null
                $ast = [System.Management.Automation.Language.Parser]::ParseFile(
                    (Join-Path $PSScriptRoot $name), [ref]$tokens, [ref]$parseErrors)
                if ($parseErrors.Count) { throw "Cannot parse $name" }
                $ast.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                    $node.Left -is [System.Management.Automation.Language.VariableExpressionAst] -and
                    $node.Left.VariablePath.UserPath -eq 'engine'
                }, $true)
            }
        )
    }

    It 'reuses the current executable even without a console executable in PSHOME' {
        Mock Test-Path { $false }
        $expected = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
        $hostAssignments.Count | Should -Be 3
        foreach ($assignment in $hostAssignments) {
            $selected = & ([scriptblock]::Create($assignment.Extent.Text + "`n" + '$engine'))
            $selected | Should -Be $expected
        }
    }
}
