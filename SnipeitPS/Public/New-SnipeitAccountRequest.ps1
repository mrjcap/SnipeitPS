<#
.SYNOPSIS
Submits a self-service checkout request for an asset.

.DESCRIPTION
Requests an asset on behalf of the current user via POST /api/v1/account/request/{asset}.
The server fixes the requested quantity to 1 and takes no request body or custom notes.

.PARAMETER asset_id
Unique ID of the requestable asset to request.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
New-SnipeitAccountRequest -asset_id 101

.EXAMPLE
Get-SnipeitRequestableAsset | Select-Object -First 1 | New-SnipeitAccountRequest
#>
function New-SnipeitAccountRequest {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium'
    )]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [Alias('id', 'asset')]
        [int]$asset_id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ShouldProcess("Asset ID $asset_id", $MyInvocation.MyCommand.Name)) {
            $Parameters = @{
                Route       = "$script:SnipeitApiPrefix/account/request/{asset}"
                RouteTokens = @{ asset = $asset_id }
                Method      = 'Post'
                Session     = $Session
                Body        = @{}
            }

            $res = Invoke-SnipeitMethod @Parameters
            $res
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
