# Compare-ParamTypes.ps1 — Hostile review: code vs docs param type/mandatory mismatches
Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force -ErrorAction Stop
$docsPath = Join-Path $PSScriptRoot 'docs'
$mismatches = [System.Collections.Generic.List[PSCustomObject]]::new()

foreach ($cmd in (Get-Command -Module SnipeitPS -CommandType Function)) {
    $mdFile = Join-Path $docsPath "$($cmd.Name).md"
    if (-not (Test-Path $mdFile)) {
        $mismatches.Add([PSCustomObject]@{Function=$cmd.Name;Param='(doc)';Issue="No .md doc file found"})
        continue
    }
    $md = Get-Content $mdFile -Raw

    # Parse doc params: ### -name ... Type: X ... Required: True/False
    $docParams = @{}
    $pattern = '(?ms)^### -(\w+).*?```yaml\s*\n(.*?)```'
    foreach ($m in [regex]::Matches($md, $pattern)) {
        $pName = $m.Groups[1].Value
        $yaml = $m.Groups[2].Value
        $type = if ($yaml -match '(?m)^Type:\s*(.+)$') { $Matches[1].Trim() } else { '' }
        $req  = if ($yaml -match '(?m)^Required:\s*(.+)$') { $Matches[1].Trim() } else { '' }
        $docParams[$pName] = @{ Type = $type; Required = $req }
    }

    $codeParams = $cmd.Parameters
    # Skip common params
    $common = [System.Management.Automation.PSCmdlet]::CommonParameters +
              [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

    foreach ($pName in $codeParams.Keys) {
        if ($pName -in $common) { continue }
        $cp = $codeParams[$pName]
        $codeType = $cp.ParameterType.Name
        # Normalize Nullable types
        if ($cp.ParameterType.IsGenericType -and $cp.ParameterType.GetGenericTypeDefinition() -eq [Nullable`1]) {
            $inner = $cp.ParameterType.GenericTypeArguments[0].Name
            $codeType = "Nullable[$inner]"
        }
        $codeMandatory = ($cp.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } |
                          ForEach-Object { $_.Mandatory } | Sort-Object -Unique) -join ','

        if (-not $docParams.ContainsKey($pName)) {
            $mismatches.Add([PSCustomObject]@{Function=$cmd.Name;Param=$pName;Issue="In code but missing from docs"})
            continue
        }
        $dp = $docParams[$pName]

        # Normalize doc type for comparison
        $docType = $dp.Type
        # Map common platyPS display names to .NET type names
        $typeMap = @{
            'SwitchParameter' = 'SwitchParameter'
            'String'          = 'String'
            'String[]'        = 'String[]'
            'Int32'           = 'Int32'
            'Int32[]'         = 'Int32[]'
            'Int64'           = 'Int64'
            'Boolean'         = 'Boolean'
            'Hashtable'       = 'Hashtable'
            'DateTime'        = 'DateTime'
            'Single'          = 'Single'
            'Object'          = 'Object'
            'SecureString'    = 'SecureString'
            'PSCredential'    = 'PSCredential'
            'MailAddress'     = 'MailAddress'
        }

        # Normalize code type for display
        $codeDisplay = $codeType
        $docDisplay  = $docType

        if ($codeDisplay -ne $docDisplay) {
            $mismatches.Add([PSCustomObject]@{
                Function = $cmd.Name
                Param    = $pName
                Issue    = "Type mismatch: code=$codeDisplay, doc=$docDisplay"
            })
        }

        # Check mandatory
        $docReq = $dp.Required
        # Code can have multiple ParameterAttribute with different Mandatory per set
        $mandatoryAttrs = $cp.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] }
        $anyMandatory  = ($mandatoryAttrs | Where-Object { $_.Mandatory }) | Measure-Object | Select-Object -ExpandProperty Count
        $anyOptional   = ($mandatoryAttrs | Where-Object { -not $_.Mandatory }) | Measure-Object | Select-Object -ExpandProperty Count

        if ($docReq -eq 'True' -and $anyMandatory -eq 0) {
            $mismatches.Add([PSCustomObject]@{Function=$cmd.Name;Param=$pName;Issue="Doc says Required=True but code has no mandatory attribute"})
        }
        if ($docReq -eq 'False' -and $anyMandatory -gt 0 -and $anyOptional -eq 0) {
            $mismatches.Add([PSCustomObject]@{Function=$cmd.Name;Param=$pName;Issue="Doc says Required=False but code is mandatory in all sets"})
        }
    }

    # Check for params in docs but not in code
    foreach ($pName in $docParams.Keys) {
        if (-not $codeParams.ContainsKey($pName)) {
            $mismatches.Add([PSCustomObject]@{Function=$cmd.Name;Param=$pName;Issue="In docs but missing from code (orphaned)"})
        }
    }
}

if ($mismatches.Count -eq 0) {
    Write-Host "No mismatches found." -ForegroundColor Green
} else {
    Write-Host "`n=== PARAM TYPE/MANDATORY MISMATCHES: $($mismatches.Count) ===" -ForegroundColor Red
    $mismatches | Sort-Object Function, Param | Format-Table -AutoSize -Wrap
}
