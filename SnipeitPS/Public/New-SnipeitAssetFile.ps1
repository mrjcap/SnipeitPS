<#
    .SYNOPSIS
    Add a file to an asset in Snipe-it

    .DESCRIPTION
    Add a file to an asset in Snipe-it

    .PARAMETER id
    ID of the asset to add the file to

    .PARAMETER file
    Path to the file to upload

    .PARAMETER notes
    Optional notes for the file

    .PARAMETER url
    Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipeit system.

    .PARAMETER apiKey
    Deprecated parameter, please use Connect-SnipeitPS instead. Users API Key for Snipeit.

    .EXAMPLE
    New-SnipeitAssetFile -id 1 -file "C:\path\to\file.pdf"
#>

function New-SnipeitAssetFile() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]

    Param(
        [parameter(mandatory = $true)]
        [int]$id,

        [parameter(mandatory = $true)]
        [ValidateScript({Test-Path $_})]
        [string]$file,

        [string]$notes,

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )

    begin {
        Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

        $Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters `
                                       -BoundParameters $PSBoundParameters `
                                       -DefaultExcludeParameter 'id', 'url', 'apiKey', 'Debug', 'Verbose'

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
            $Parameters = @{
                Api    = "/api/v1/hardware/$id/files"
                Method = 'Post'
                Body   = $Values
            }
            Invoke-SnipeitMethod @Parameters
        }
    }

    end {
        # reset legacy sessions
        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url -or $PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Reset-SnipeitPSLegacyApi
        }
    }
}
