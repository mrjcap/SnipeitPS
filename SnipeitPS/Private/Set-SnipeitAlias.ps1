function Set-SnipeitAlias()
{
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    param()
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
    Get-Command @getCommandParams | Select-Object @selectParams

}
