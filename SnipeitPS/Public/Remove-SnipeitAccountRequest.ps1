<#
.SYNOPSIS
Cancels a pending self-service checkout request for inventory.

.DESCRIPTION
Cancels the current user's active request for an asset, consumable, component or license.
Takes no body fields. IDs refer to inventory, not checkout-request rows. Do not use
request_id or the web cancel_url as an inventory ID. Accessory and model request
mutations are not exposed by this API.

.PARAMETER asset_id
Unique ID of the asset whose pending request should be canceled.

.PARAMETER consumable_id
Positive consumable inventory ID whose pending request should be canceled.

.PARAMETER component_id
Positive component inventory ID whose pending request should be canceled.

.PARAMETER license_id
Positive license inventory ID whose pending request should be canceled.

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
        ConfirmImpact = 'High',
        DefaultParameterSetName = 'Asset'
    )]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Asset')]
        [ValidateRange(1, [int]::MaxValue)]
        [Alias('id', 'asset')]
        [int]$asset_id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Consumable')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$consumable_id,

        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Component')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$component_id,

        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'License')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$license_id
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $requestType = $PSCmdlet.ParameterSetName.ToLowerInvariant()
        $requestId = $PSBoundParameters["${requestType}_id"]
        $route = if ($requestType -eq 'asset') {
            "$script:SnipeitApiPrefix/account/request/{asset}/cancel"
        } else {
            "$script:SnipeitApiPrefix/account/request/$requestType/{$requestType}/cancel"
        }
        $tokens = @{}
        $tokens[$requestType] = $requestId
        if ($PSCmdlet.ShouldProcess("$($PSCmdlet.ParameterSetName) ID $requestId", $MyInvocation.MyCommand.Name)) {
            $Parameters = @{
                Route       = $route
                RouteTokens = $tokens
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
