<#
    .SYNOPSIS
    Update a specific Asset in the Snipe-IT asset system

    .DESCRIPTION
    Update a specific Asset in the Snipe-IT asset system

    .PARAMETER id
    ID of the Asset or array of IDs

    .PARAMETER asset_tag
    New tag for asset.

    .PARAMETER Name
    Asset name

    .PARAMETER Status_id
    Status ID of the asset, this can be obtained using Get-SnipeitStatus

    .PARAMETER Model_id
    Model ID of the asset, this can be obtained using Get-SnipeitModel

    .PARAMETER last_checkout
    Date the asset was last checked out

    .PARAMETER assigned_to
    The ID of the user the asset is currently checked out to

    .PARAMETER company_id
    The ID of an associated company ID

    .PARAMETER serial
    Serial number of the asset

    .PARAMETER order_number
    Order number for the asset

    .PARAMETER warranty_months
    Number of months for the asset warranty

    .PARAMETER purchase_cost
    Purchase cost of the asset, without a currency symbol

    .PARAMETER purchase_date
    Date of asset purchase

    .PARAMETER supplier_id
    Supplier ID of the Asset

    .PARAMETER requestable
    Whether or not the asset can be requested by users with the permission to request assets

    .PARAMETER archived
    Whether or not the asset is archived. Archived assets cannot be checked out and do not show up in the deployable asset screens

    .PARAMETER rtd_location_id
    The ID that corresponds to the location where the asset is usually located when not checked out

    .PARAMETER notes
    Notes about asset

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

    .PARAMETER customfields
    Hashtable of custom fields and extra fields that need passing through to Snipe-IT

    .EXAMPLE
    Set-SnipeitAsset -id 1 -status_id 1 -model_id 1 -name "Machine1"

    .EXAMPLE
    Set-SnipeitAsset -id 1 -name "Machine1" -customfields @{ "_snipeit_os_5" = "Windows 10 Pro" ; "_snipeit_os_version" = "1909" }

    .EXAMPLE
    Get-SnipeitAsset -serial 12345678 | Set-SnipeitAsset -notes 'Just updated'
#>

function Set-SnipeitAsset() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [parameter(Mandatory=$false)]
        [string]
        $asset_tag,

        [string]$name,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$status_id,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$model_id,

        [DateTime]$last_checkout,

        [Nullable[System.Int32]]$assigned_to,

        [Nullable[System.Int32]]$company_id,

        [string]$serial,

        [string]$order_number,

        [Nullable[System.Int32]]$warranty_months,

        [double]$purchase_cost,

        [datetime]$purchase_date,

        [parameter(mandatory = $false)]
        [int]$supplier_id,

        [bool]$requestable,

        [bool]$archived,

        [Nullable[System.Int32]]$rtd_location_id,

        [string]$notes,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [switch]$image_delete=$false,

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey,

        [Alias('CustomValues')]
        [hashtable] $customfields
    )
    begin{
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

        $Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        if ($Values['purchase_date']) {
            $Values['purchase_date'] = $Values['purchase_date'].ToString("yyyy-MM-dd")
        }

        if ($customfields) {
            $Values += $customfields
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
        foreach($asset_id in $id) {
            $Parameters = @{
                Api    = "/api/v1/hardware/$asset_id"
                Method = $RequestType
                Body   = $Values
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
