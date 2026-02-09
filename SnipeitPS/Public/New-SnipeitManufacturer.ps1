<#
    .SYNOPSIS
    Add a new Manufacturer to Snipe-it asset system

    .DESCRIPTION
    Creates a new manufacturer on Snipe-It system

    .PARAMETER Name
    Name of the Manufacturer

    .PARAMETER image
    Manufacturer Image filename and path

    .PARAMETER manufacturer_url
    Website URL of the manufacturer. Named manufacturer_url to avoid conflict with the deprecated -url parameter.

    .PARAMETER image_delete
    Remove current image

    .PARAMETER url
    Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipeit system.

    .PARAMETER apiKey
    Deprecated parameter, please use Connect-SnipeitPS instead. Users API Key for Snipeit.

    .EXAMPLE
    New-SnipeitManufacturer -name "HP"
#>

function New-SnipeitManufacturer() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]

    Param(
        [parameter(mandatory = $true)]
        [string]$Name,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [string]$manufacturer_url,

        [switch]$image_delete=$false,

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )

    begin {
        Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

        $Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        if ($Values.ContainsKey('manufacturer_url')) {
            $Values['url'] = $Values['manufacturer_url']
            $Values.Remove('manufacturer_url')
        }

        $Parameters = @{
            Api    = "/api/v1/manufacturers"
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
        }

        $result
    }
    end {
        # reset legacy sessions
        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url -or $PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Reset-SnipeitPSLegacyApi
        }
    }
}
