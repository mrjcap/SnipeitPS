<#
    .SYNOPSIS
    Checkout asset
    .DESCRIPTION
    Checkout asset to user/location/asset

    .PARAMETER ID
    Unique IDs for assets to checkout

    .PARAMETER assigned_id
    ID of target user, location, or asset

    .PARAMETER checkout_to_type
    Checkout asset to one of the following types: location, asset, or user

    .PARAMETER name
    Optional new asset name. This is useful for changing the asset's name on new checkout,
    for example, an asset that was named "Anna's Macbook Pro" could be renamed on the fly
    when it's checked out to Elizabeth, to "Beth's Macbook Pro"

    .PARAMETER note
    Notes about checkout

    .PARAMETER expected_checkin
    Optional date the asset is expected to be checked in

    .PARAMETER checkout_at
    Optional date to override the checkout time of now

    .PARAMETER status_id
    Optional status ID to set the asset to during checkout

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
    System.Management.Automation.PSCustomObject

    .EXAMPLE
    Set-SnipeitAssetOwner -id 1 -assigned_id 1 -checkout_to_type user -note "testing check out to user"
#>
function Set-SnipeitAssetOwner() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [parameter(mandatory = $true)]
        [int]$assigned_id,

        [ValidateSet("location","asset","user")]
        [string] $checkout_to_type = "user",

        [string] $name,

        [string] $note,

        [datetime] $expected_checkin,

        [datetime]$checkout_at,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$status_id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin{
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        $Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        if ($Values['expected_checkin']) {
            $Values['expected_checkin'] = $Values['expected_checkin'].ToString("yyyy-MM-dd")
        }

        if ($Values['checkout_at']) {
            $Values['checkout_at'] = $Values['checkout_at'].ToString("yyyy-MM-dd")
        }

        switch ($checkout_to_type) {
            'user'     { $Values['assigned_user'] = $assigned_id }
            'asset'    { $Values['assigned_asset'] = $assigned_id }
            'location' { $Values['assigned_location'] = $assigned_id }
        }
        $Values['checkout_to_type'] = $checkout_to_type

        #These are routing parameters, not API body fields
        if ($Values.ContainsKey('assigned_id')) {$Values.Remove('assigned_id')}

    }

    process{
        foreach($asset_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/hardware/$asset_id/checkout"
                Method = 'POST'
                Session = $Session
                Body   = $Values
            }

            if ($PSCmdlet.ShouldProcess("Asset ID $asset_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
