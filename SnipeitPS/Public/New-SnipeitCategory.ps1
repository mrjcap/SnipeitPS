<#
.SYNOPSIS
Create a new Snipe-IT Category

.PARAMETER name
Name of new category to be created

.PARAMETER category_type
Type of new category to be created (asset, accessory, consumable, component, license)

.PARAMETER eula_text
This allows you to customize your EULAs for specific types of assets

.PARAMETER use_default_eula
If switch is present, use the primary default EULA

.PARAMETER require_acceptance
If switch is present, require users to confirm acceptance of assets in this category

.PARAMETER checkin_email
If switch is present, send email to user on checkin/checkout

.PARAMETER image
Category image filename and path

.PARAMETER url
Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipe-IT system.

.PARAMETER apiKey
Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipe-IT.

.EXAMPLE
New-SnipeitCategory -name "Laptops" -category_type asset
#>

function New-SnipeitCategory() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]

    Param(
        [parameter(mandatory = $true)]
        [string]$name,

        [parameter(mandatory = $true)]
        [ValidateSet("asset", "accessory", "consumable", "component", "license")]
        [string]$category_type,

        [string]$eula_text,

        [switch]$use_default_eula,

        [switch]$require_acceptance,

        [switch]$checkin_email,

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

        if ($eula_text -and $use_default_eula) {
            throw "Don't use -use_default_eula if -eula_text is set"
        }

        $Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

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

        $Parameters = @{
            Api    = "/api/v1/categories"
            Method = 'POST'
            Body   = $Values
        }

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
