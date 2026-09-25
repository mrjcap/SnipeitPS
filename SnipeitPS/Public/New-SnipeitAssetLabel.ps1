<#
.SYNOPSIS
Generate printable asset labels from the Snipe-IT asset system.

.DESCRIPTION
Generates printable PDF asset labels via POST /api/v1/hardware/labels.
Accepts an array of asset tags or asset IDs. When asset IDs are supplied,
they are resolved to asset tags prior to label generation. If any asset ID
fails to resolve, execution halts immediately with an error to prevent
generating incomplete label sets.
All resolution and generation requests are guarded by ShouldProcess to
guarantee zero HTTP requests under -WhatIf.

.PARAMETER asset_ids
An array of asset IDs to generate labels for.

.PARAMETER asset_tags
An array of asset tags to generate labels for.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
New-SnipeitAssetLabel -asset_ids 1,2,3

.EXAMPLE
New-SnipeitAssetLabel -asset_tags 'AST-001', 'AST-002'
#>
function New-SnipeitAssetLabel {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Low'
    )]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $false)]
        [int[]]$asset_ids,

        [Parameter(Mandatory = $false)]
        [string[]]$asset_tags,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $targets = if ($asset_tags) {
            "Asset Tags $($asset_tags -join ',')"
        } elseif ($asset_ids) {
            "Asset IDs $($asset_ids -join ',')"
        } else {
            'All requestable labels'
        }

        if ($PSCmdlet.ShouldProcess($targets, $MyInvocation.MyCommand.Name)) {
            $resolvedTags = [System.Collections.Generic.List[string]]::new()

            if ($PSBoundParameters.ContainsKey('asset_tags')) {
                $resolvedTags.AddRange($asset_tags)
            }

            if ($PSBoundParameters.ContainsKey('asset_ids') -and -not $PSBoundParameters.ContainsKey('asset_tags')) {
                foreach ($aid in $asset_ids) {
                    try {
                        $foundAsset = Get-SnipeitAsset -id $aid -Session $Session -ErrorAction Stop
                        if ($foundAsset -and $foundAsset.asset_tag) {
                            $resolvedTags.Add($foundAsset.asset_tag)
                        } else {
                            throw "Asset ID '$aid' has no asset_tag."
                        }
                    } catch {
                        throw [System.InvalidOperationException]::new("Failed to resolve asset tag for asset ID '$aid'. Cannot generate partial labels: $($_.Exception.Message)")
                    }
                }
            }

            $body = @{
                asset_tags = $resolvedTags.ToArray()
            }

            if ($PSBoundParameters.ContainsKey('asset_ids')) {
                $body['asset_ids'] = $asset_ids
            }

            $Parameters = @{
                Api     = "$script:SnipeitApiPrefix/hardware/labels"
                Method  = 'Post'
                Session = $Session
                Body    = $body
            }

            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
