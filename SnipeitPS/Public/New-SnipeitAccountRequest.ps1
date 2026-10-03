<#
.SYNOPSIS
Submits a self-service checkout request for inventory.

.DESCRIPTION
Requests an asset, consumable, component or license on behalf of the current user.
The server fixes the requested quantity to 1 and takes no request body, custom notes
or reservation dates. IDs refer to inventory, not checkout-request rows. Accessory
and model request mutations are not exposed by this API.

.PARAMETER asset_id
Unique ID of the requestable asset to request.

.PARAMETER consumable_id
Positive consumable inventory ID.

.PARAMETER component_id
Positive component inventory ID.

.PARAMETER license_id
Positive license inventory ID.

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
        ConfirmImpact = 'Medium',
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
            "$script:SnipeitApiPrefix/account/request/{asset}"
        } else {
            "$script:SnipeitApiPrefix/account/request/$requestType/{$requestType}"
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
