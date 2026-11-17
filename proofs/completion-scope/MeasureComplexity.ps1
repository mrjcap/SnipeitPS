[CmdletBinding()]
param([Parameter(Mandatory)][string]$TypeScriptParser)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path "$PSScriptRoot/../..").Path
$production = @('Classes/SnipeitCache.ps1', 'Classes/SnipeitCompleters.ps1', 'Public/Connect-SnipeitPS.ps1', 'Private/Invoke-SnipeitMethod.ps1')
$paths = @($production | ForEach-Object { Join-Path "$root/SnipeitPS" $_ })
$paths += @(Get-ChildItem $PSScriptRoot -Filter '*.ps1' -File | Select-Object -ExpandProperty FullName)
$measurements = foreach ($file in $paths) {
    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$errors)
    $syntaxErrors = @($errors | Where-Object { $_.ErrorId -ne 'TypeNotFound' })
    if ($syntaxErrors.Count) { throw "Parse errors in $file" }
    $nodes = @($ast.FindAll({ param($n) $true }, $true))
    $units = @($nodes | Where-Object { $_ -is [System.Management.Automation.Language.ScriptBlockAst] }).Count
    $decisions = 0
    foreach ($n in $nodes) {
        switch ($n.GetType().Name) {
            'IfStatementAst' { $decisions += $n.Clauses.Count }
            'SwitchStatementAst' { $decisions += $n.Clauses.Count }
            { $_ -in @('ForStatementAst', 'ForEachStatementAst', 'WhileStatementAst', 'DoWhileStatementAst', 'DoUntilStatementAst', 'CatchClauseAst', 'TernaryExpressionAst') } { $decisions++ }
            'BinaryExpressionAst' { if ($n.Operator -in @('And', 'Or')) { $decisions++ } }
            'PipelineChainAst' { $decisions++ }
        }
    }
    [pscustomobject]@{ file = [IO.Path]::GetRelativePath($root, $file); units = $units; decisions = $decisions; complexity = $units + $decisions }
}
$js = & node "$PSScriptRoot/measure-js.mjs" --parser $TypeScriptParser
if ($LASTEXITCODE -ne 0) { throw 'JavaScript AST measurement failed' }
[pscustomobject]@{
    method = 'Sum of 1 per script block (PS), function plus module (JS), plus if clauses, loop, catch, nondefault case, ternary and short-circuit decisions. No TLA or regex decisions.'
    powershell = @($measurements)
    javascript = @($js | ConvertFrom-Json)
} | ConvertTo-Json -Depth 8
