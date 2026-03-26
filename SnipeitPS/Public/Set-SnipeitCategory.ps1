<#
.SYNOPSIS
Update a Snipe-IT Category

.PARAMETER id
An ID of a specific resource to update

.PARAMETER name
Name of the category

.PARAMETER category_type
Type of category (asset, accessory, consumable, component, license)

.PARAMETER use_default_eula
If switch is present, use the primary default EULA

.PARAMETER eula_text
This allows you to customize your EULAs for specific types of assets

.PARAMETER require_acceptance
If switch is present, require users to confirm acceptance of assets in this category

.PARAMETER checkin_email
Should the user be emailed the EULA and/or an acceptance confirmation email when this item is checked in?

.PARAMETER image
Image file name and path for item

.PARAMETER image_delete
Remove current image

.PARAMETER RequestType
HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

.PARAMETER url
Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipe-IT system.

.PARAMETER apiKey
Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipe-IT.

.EXAMPLE
Set-SnipeitCategory -id 4 -name "Laptops"
#>

function Set-SnipeitCategory() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [string]$name,

        [ValidateSet("asset", "accessory", "consumable", "component", "license")]
        [string]$category_type,

        [string]$eula_text,

        [bool]$use_default_eula,

        [bool]$require_acceptance,

        [bool]$checkin_email,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [switch]$image_delete=$false,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey

    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

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
        foreach($category_id in $id) {
            $Parameters = @{
                Api    = "/api/v1/categories/$category_id"
                Method = $RequestType
                Body   = $values
            }

            if ($PSCmdlet.ShouldProcess("ShouldProcess?")) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
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
