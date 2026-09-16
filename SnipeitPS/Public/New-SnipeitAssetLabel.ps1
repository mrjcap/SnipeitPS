<#
.SYNOPSIS
Generate printable asset labels from the Snipe-IT asset system

.DESCRIPTION
Generate printable asset labels from the Snipe-IT asset system

.PARAMETER asset_ids
An array of asset IDs to generate labels for

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
New-SnipeitAssetLabel -asset_ids 1,2,3

#>

function New-SnipeitAssetLabel() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $false)]
        [int[]]$asset_ids,

        [parameter(mandatory = $false)]
        [string[]]$asset_tags,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$resolvedTags = [System.Collections.Generic.List[string]]::new()
        if ($PSBoundParameters.ContainsKey('asset_tags')) {
            $resolvedTags.AddRange($asset_tags)
        }
        if ($PSBoundParameters.ContainsKey('asset_ids') -and -not $PSBoundParameters.ContainsKey('asset_tags')) {
            foreach ($aid in $asset_ids) {
                try {
                    $foundAsset = Get-SnipeitAsset -id $aid -Session $Session
                    if ($foundAsset -and $foundAsset.asset_tag) {
                        $resolvedTags.Add($foundAsset.asset_tag)
                    }
                } catch {
                    Write-Debug "Failed to resolve asset tag for asset ID '$aid': $_"
                }
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
            Session = $Session
            Body   = $Values
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
    }
}
