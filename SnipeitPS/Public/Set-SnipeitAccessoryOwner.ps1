<#
    .SYNOPSIS
    Checkout accessory
    .DESCRIPTION
    Checkout accessory to user

    .PARAMETER id
    Unique ID  For accessory or array of IDs to checkout

    .PARAMETER assigned_to
    Id of target user, asset, or location

    .PARAMETER checkout_to_type
    Checkout accessory to one of following types: user, asset, location

    .PARAMETER note
    Notes about checkout

    .PARAMETER url
    Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipeit system.

    .PARAMETER apiKey
    Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipeit.

    .EXAMPLE
    Set-SnipeitAccessoryOwner -id 1 -assigned_to 1 -checkout_to_type user -note "testing check out to user"
#>
function Set-SnipeitAccessoryOwner() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [parameter(mandatory = $true)]
        [int]$assigned_to,

        [ValidateSet("user","asset","location")]
        [string]$checkout_to_type = "user",

        [string] $note,

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )
    begin{
        $Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        switch ($checkout_to_type) {
            'user' { $Values += @{ "assigned_user" = $assigned_to } }
            'asset' { $Values += @{ "assigned_asset" = $assigned_to } }
            'location' { $Values += @{ "assigned_location" = $assigned_to } }
        }

        if ($Values.ContainsKey('assigned_to')) { $Values.Remove('assigned_to') }
        if ($Values.ContainsKey('checkout_to_type')) { $Values.Remove('checkout_to_type') }
    }

    process {
        foreach($accessory_id in $id) {
            $Parameters = @{
                Api    = "/api/v1/accessories/$accessory_id/checkout"
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

            if ($PSCmdlet.ShouldProcess("ShouldProcess?")) {
                $result = Invoke-SnipeitMethod @Parameters
            }

            return $result
        }
    }

    end {
        # reset legacy sessions
        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url -or $PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Reset-SnipeitPSLegacyApi
        }
    }
}
