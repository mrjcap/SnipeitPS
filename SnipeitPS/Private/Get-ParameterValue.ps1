function Get-ParameterValue {
    #.Synopsis
    #  Get the actual values of parameters which have manually set (non-null) default values or values passed in the call
    #.Description
    #  Unlike $PSBoundParameters, the hashtable returned from Get-ParameterValue includes non-empty default parameter values.
    #  NOTE: Default values that are the same as the implied values are ignored (e.g.: empty strings, zero numbers, nulls).
    #.Example
    #  function Test-Parameters {
    #      [CmdletBinding()]
    #      param(
    #          $Name = $Env:UserName,
    #          $Age
    #      )
    #      $Parameters = . Get-ParameterValue
    #
    #      # This WILL ALWAYS have a value...
    #      Write-Host $Parameters["Name"]
    #
    #      # But this will NOT always have a value...
    #      Write-Host $PSBoundParameters["Name"]
    #  }
    [CmdletBinding()]
    param(
        # Pass $MyInvocation.MyCommand.Parameters to function, PowerShell 7 seems to only populate variables with dot sourcing
        [parameter(mandatory = $true)]
        $Parameters
        ,
        [parameter(mandatory = $true)]
        $BoundParameters,

        [string[]]$DefaultExcludeParameter = @("id", "url", "apiKey", 'Debug', 'Verbose','RequestType','customfields')
    )

    if ($MyInvocation.Line[($MyInvocation.OffsetInLine - 1)] -ne '.') {
        throw "Get-ParameterValue must be dot-sourced, like this: . Get-ParameterValue"
    }

    $commonParams = @(
        'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction',
        'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable',
        'OutBuffer', 'PipelineVariable', 'WhatIf', 'Confirm',
        'PID', 'Host', 'Profile', 'Error', 'ExecutionContext', 'PSBoundParameters',
        'MyInvocation', 'PSScriptRoot', 'PSCommandPath', 'PSVersionTable'
    )

    $excludeLookup = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($item in $DefaultExcludeParameter) { [void]$excludeLookup.Add($item) }
    foreach ($item in $commonParams) { [void]$excludeLookup.Add($item) }

    $ParameterValues = @{}
    foreach ($parameter in $Parameters.GetEnumerator()) {
        $key = $parameter.Key
        if (-not $excludeLookup.Contains($key)) {
            #Fill in default parameters values from scope 0 (local scope of dot-sourced caller)
            if ($null -ne ($value = Get-Variable -Name $key -Scope 0 -ValueOnly -ErrorAction Ignore )) {
                if ($value -ne ($null -as $parameter.Value.ParameterType)) {
                    $ParameterValues[$key] = $value
                }
            }
            #Fill in all given parameters even empty
            if ($BoundParameters.ContainsKey($key)) {
                $ParameterValues[$key] = $BoundParameters[$key]
            }
        }
    }

    #Convert switch parameters to booleans so it converts nicely to json
    foreach ( $key in @($ParameterValues.Keys)) {
      if ($ParameterValues[$key] -is [System.Management.Automation.SwitchParameter]){
        $ParameterValues[$key] = $ParameterValues[$key].IsPresent
      }
    }

    return $ParameterValues
}
