<#
.SYNOPSIS
Check out an asset to a user, location, or asset.

.DESCRIPTION
Checks out an asset to a user, location, or asset using either asset ID or asset tag.
When using asset ID, calls POST /api/v1/hardware/{id}/checkout.
When using asset tag, calls POST /api/v1/hardware/bytag/{tag}/checkout.

.PARAMETER id
Unique ID(s) of the asset(s) to check out.

.PARAMETER tag
Unique asset tag(s) of the asset(s) to check out.

.PARAMETER assigned_id
ID of target user, location, or asset.

.PARAMETER checkout_to_type
Checkout target entity type: location, asset, or user. Defaults to user.

.PARAMETER name
Optional new asset name during checkout.

.PARAMETER note
Notes about the checkout.

.PARAMETER expected_checkin
Optional expected check-in date.

.PARAMETER checkout_at
Optional date to override the checkout time of now.

.PARAMETER status_id
Optional status ID to set on the asset during checkout.

.PARAMETER requestable
Set whether the checked-out asset may be requested. Omitted values leave the flag unchanged.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Set-SnipeitAssetOwner -id 1 -assigned_id 1 -checkout_to_type user -note "Issued to employee"

.EXAMPLE
Set-SnipeitAssetOwner -tag 'AST-0042' -assigned_id 5 -checkout_to_type location
#>
function Set-SnipeitAssetOwner {
    [CmdletBinding(
        DefaultParameterSetName = 'ById',
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium'
    )]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [int[]]$id,

        [Parameter(ParameterSetName = 'ByTag', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('asset_tag')]
        [string[]]$tag,

        [Parameter(Mandatory = $true, Position = 1)]
        [int]$assigned_id,

        [Parameter(Position = 2)]
        [ValidateSet('location', 'asset', 'user')]
        [string]$checkout_to_type = 'user',

        [Parameter(Position = 3)]
        [string]$name,

        [Parameter(Position = 4)]
        [string]$note,

        [Parameter(Position = 5)]
        [datetime]$expected_checkin,

        [Parameter(Position = 6)]
        [datetime]$checkout_at,

        [Parameter(Position = 7)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$status_id,

        [Nullable[bool]]$requestable,

        [Parameter(Mandatory = $false, Position = 8)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $body = @{
            checkout_to_type = $checkout_to_type
        }

        switch ($checkout_to_type) {
            'user'     { $body['assigned_user'] = $assigned_id }
            'asset'    { $body['assigned_asset'] = $assigned_id }
            'location' { $body['assigned_location'] = $assigned_id }
        }

        if ($PSBoundParameters.ContainsKey('requestable')) { $body['requestable'] = $requestable }
        if ($PSBoundParameters.ContainsKey('name')) { $body['name'] = $name }
        if ($PSBoundParameters.ContainsKey('note')) { $body['note'] = $note }
        if ($PSBoundParameters.ContainsKey('status_id')) { $body['status_id'] = $status_id }
        if ($PSBoundParameters.ContainsKey('expected_checkin')) {
            $body['expected_checkin'] = $expected_checkin.ToString('yyyy-MM-dd')
        }
        if ($PSBoundParameters.ContainsKey('checkout_at')) {
            $body['checkout_at'] = $checkout_at.ToString('yyyy-MM-dd')
        }

        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            foreach ($asset_id in $id) {
                if ($PSCmdlet.ShouldProcess("Asset ID $asset_id", $MyInvocation.MyCommand.Name)) {
                    $Parameters = @{
                        Api         = "$script:SnipeitApiPrefix/hardware/$asset_id/checkout"
                        Route       = "$script:SnipeitApiPrefix/hardware/{id}/checkout"
                        RouteTokens = @{ id = $asset_id }
                        Method      = 'Post'
                        Session     = $Session
                        Body        = $body
                    }

                    $result = Invoke-SnipeitMethod @Parameters
                    $result
                }
            }
        } elseif ($PSCmdlet.ParameterSetName -eq 'ByTag') {
            foreach ($asset_tag in $tag) {
                if ($PSCmdlet.ShouldProcess("Asset tag $asset_tag", $MyInvocation.MyCommand.Name)) {
                    $Parameters = @{
                        Api         = "$script:SnipeitApiPrefix/hardware/bytag/$asset_tag/checkout"
                        Route       = "$script:SnipeitApiPrefix/hardware/bytag/{tag}/checkout"
                        RouteTokens = @{ tag = $asset_tag }
                        Method      = 'Post'
                        Session     = $Session
                        Body        = $body
                    }

                    $result = Invoke-SnipeitMethod @Parameters
                    $result
                }
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
