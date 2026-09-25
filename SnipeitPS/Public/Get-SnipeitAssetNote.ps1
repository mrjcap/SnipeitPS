<#
.SYNOPSIS
Gets manual notes for an asset.

.DESCRIPTION
Retrieves the unpaginated manual notes recorded on an asset via GET /api/v1/notes/{asset}/index.
Returns each note record from payload.notes decorated with SnipeitPS.AssetNote.

.PARAMETER asset_id
Unique ID of the asset.

.PARAMETER preserveResponse
When set, preserves the raw response envelope instead of streaming note records.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.AssetNote

.EXAMPLE
Get-SnipeitAssetNote -asset_id 101

.EXAMPLE
Get-SnipeitAsset -id 101 | Get-SnipeitAssetNote
#>
function Get-SnipeitAssetNote {
    [CmdletBinding()]
    [OutputType('SnipeitPS.AssetNote')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [Alias('id', 'asset')]
        [int]$asset_id,

        [switch]$preserveResponse,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $Parameters = @{
            Route            = "$script:SnipeitApiPrefix/notes/{asset}/index"
            RouteTokens      = @{ asset = $asset_id }
            Method           = 'Get'
            Session          = $Session
            PreserveResponse = [bool]$preserveResponse
        }

        $res = Invoke-SnipeitMethod @Parameters

        if ($preserveResponse) {
            $res
        } else {
            $notes = if ($res -is [System.Collections.IDictionary]) {
                $res['notes']
            } elseif ($res -and $res.PSObject.Properties['notes']) {
                $res.notes
            } else {
                $res
            }

            if ($null -ne $notes) {
                foreach ($item in $notes) {
                    if ($item -is [System.Management.Automation.PSObject] -and -not $item.PSObject.TypeNames.Contains('SnipeitPS.AssetNote')) {
                        $item.PSObject.TypeNames.Insert(0, 'SnipeitPS.AssetNote')
                    }
                    $item
                }
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
