<#
.SYNOPSIS
Returns a fieldset or list of Snipe-IT Fieldsets

.PARAMETER id
An ID of a specific fieldset

.PARAMETER url
Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipe-IT system.

.PARAMETER apiKey
Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipe-IT.

.EXAMPLE
Get-SnipeitFieldset
Get all fieldsets

.EXAMPLE
Get-SnipeitFieldset | Where-Object {$_.name -eq "Windows" }
Gets fieldset by name

#>

function Get-SnipeitFieldset() {
    [CmdletBinding()]
    Param(
        [int]$id,

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

        if ($id) {
            $api = "/api/v1/fieldsets/$id"
        } else {
            $api = "/api/v1/fieldsets"
        }

        $Parameters = @{
            Api           = $api
            Method        = 'Get'
        }

        if ($PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Write-Warning "-apiKey parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyApiKey -apiKey $apikey
        }

        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url) {
            Write-Warning "-url parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyUrl -url $url
        }
    }
    process {
        $result = Invoke-SnipeitMethod @Parameters

        $result
    }
    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
        # reset legacy sessions
        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url -or $PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Reset-SnipeitPSLegacyApi
        }
    }
}
