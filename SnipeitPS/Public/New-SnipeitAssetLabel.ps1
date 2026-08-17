<#
.SYNOPSIS
Generate printable asset labels from the Snipe-IT asset system

.DESCRIPTION
Generate printable asset labels from the Snipe-IT asset system

.PARAMETER asset_ids
An array of asset IDs to generate labels for

.PARAMETER url
Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipe-IT system.

.PARAMETER apiKey
Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipe-IT.

.EXAMPLE
New-SnipeitAssetLabel -asset_ids 1,2,3

#>

function New-SnipeitAssetLabel() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]

    Param(
        [parameter(mandatory = $false)]
        [int[]]$asset_ids,

        [parameter(mandatory = $false)]
        [string[]]$asset_tags,

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

        $resolvedTags = @()
        if ($PSBoundParameters.ContainsKey('asset_tags')) {
            $resolvedTags += $asset_tags
        }
        if ($PSBoundParameters.ContainsKey('asset_ids') -and -not $PSBoundParameters.ContainsKey('asset_tags')) {
            foreach ($aid in $asset_ids) {
                try {
                    $foundAsset = Get-SnipeitAsset -id $aid
                    if ($foundAsset -and $foundAsset.asset_tag) {
                        $resolvedTags += $foundAsset.asset_tag
                    }
                } catch {}
            }
        }

        $Values = @{
            "asset_tags" = $resolvedTags
        }

        if ($PSBoundParameters.ContainsKey('asset_ids')) {
            $Values["asset_ids"] = $asset_ids
        }

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/hardware/labels"
            Method = 'Post'
            Body   = $Values
        }

        if ($PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Write-Warning "-apiKey parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyApiKey -apiKey $apiKey
        }

        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url) {
            Write-Warning "-url parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyUrl -url $url
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("Asset IDs $($asset_ids -join ',')", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
        # reset legacy sessions
        if (($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url) -or ($PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey)) {
            Reset-SnipeitPSLegacyApi
        }
    }
}
