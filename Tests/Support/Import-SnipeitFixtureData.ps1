function Import-SnipeitFixtureData {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Path)

    $tokens = $null
    $errors = $null
    $ast = [Management.Automation.Language.Parser]::ParseFile((Resolve-Path $Path).Path, [ref]$tokens, [ref]$errors)
    if ($errors -or $ast.BeginBlock -or $ast.ProcessBlock -or $ast.ParamBlock -or $ast.EndBlock.Statements.Count -ne 1) {
        throw 'Fixture must contain one constant hashtable.'
    }
    function Get-FixtureExpression {
        param($Statement)
        if ($Statement -isnot [Management.Automation.Language.PipelineAst] -or
            $Statement.PipelineElements.Count -ne 1 -or
            $Statement.PipelineElements[0] -isnot [Management.Automation.Language.CommandExpressionAst]) {
            throw 'Fixture contains an unsupported statement.'
        }
        $Statement.PipelineElements[0].Expression
    }
    $root = Get-FixtureExpression $ast.EndBlock.Statements[0]
    if ($root -isnot [Management.Automation.Language.HashtableAst]) { throw 'Fixture must be a hashtable.' }
    $data = @{}
    foreach ($pair in $root.KeyValuePairs) {
        $key = $pair.Item1.SafeGetValue()
        $expression = Get-FixtureExpression $pair.Item2
        if ($expression -is [Management.Automation.Language.ArrayExpressionAst]) {
            $data[$key] = @(foreach ($statement in $expression.SubExpression.Statements) {
                $element = Get-FixtureExpression $statement
                $element.SafeGetValue()
            })
        } else {
            $data[$key] = $expression.SafeGetValue()
        }
    }
    $data
}
