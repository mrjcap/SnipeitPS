function Set-SnipeitAlias()
{
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    param()

    if ($env:SNIPEITPS_DISABLE_LEGACY_ALIASES -eq '1' -or $env:SNIPEITPS_DISABLE_LEGACY_ALIASES -eq 'true') {
        Write-Verbose "Legacy aliases disabled via SNIPEITPS_DISABLE_LEGACY_ALIASES."
        return
    }

    Write-Verbose "Setting compatibility aliases."
    Write-Verbose "All aliases are deprecated."
    $SnipeitAliases = Get-SnipeitAlias
    ForEach ($key in $SnipeitAliases.Keys ) {
        $aliasParams = @{
            Name  = $key
            Value = $($SnipeitAliases[$key])
            Scope = 1
        }
        New-Alias @aliasParams
        Write-Verbose ("{0,5} -> {1}" -f $key,$($SnipeitAliases[$key]))
    }
    Write-Verbose "Please start using native 'Snipeit' prefixed functions instead."
    $getCommandParams = @{
        Module      = 'SnipeitPS'
        CommandType = 'Alias'
    }
    $selectParams = @{
        Property = 'DisplayName','ResolvedCommand'
    }
    $null = Get-Command @getCommandParams | Select-Object @selectParams

}
