<#
.SYNOPSIS
Creates a new Company

.DESCRIPTION
Creates a new company on Snipe-IT system

.PARAMETER name
Company name

.PARAMETER image
Company image filename and path

.PARAMETER url
Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipe-IT system.

.PARAMETER apiKey
Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipe-IT.

.EXAMPLE
New-SnipeitCompany -name "Acme Company"

#>

function New-SnipeitCompany() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]

    Param(
        [parameter(mandatory = $true)]
        [string]$name,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

        $Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        $Parameters = @{
            Api    = "/api/v1/companies"
            Method = 'POST'
            Body   = $Values
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
        if ($PSCmdlet.ShouldProcess("ShouldProcess?")) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
        # reset legacy sessions
        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url -or $PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Reset-SnipeitPSLegacyApi
        }
    }
}

