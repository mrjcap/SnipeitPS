<#
.SYNOPSIS
Cancels a pending self-service checkout request for an asset.

.DESCRIPTION
Cancels an active asset checkout request submitted by the current user via POST /api/v1/account/request/{asset}/cancel.
Takes no body fields.

.PARAMETER asset_id
Unique ID of the asset whose pending request should be canceled.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Remove-SnipeitAccountRequest -asset_id 101
#>
function Remove-SnipeitAccountRequest {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High'
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
                Route       = "$script:SnipeitApiPrefix/account/request/{asset}/cancel"
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
