<#
    .SYNOPSIS
    Checkout accessory
    .DESCRIPTION
    Checkout accessory to user

    .PARAMETER id
    Unique ID for accessory or array of IDs to checkout

    .PARAMETER assigned_to
    ID of target user, asset, or location

    .PARAMETER checkout_to_type
    Checkout accessory to one of the following types: user, asset, or location

    .PARAMETER checkout_qty
    Number of accessories to check out. Must be positive. The server defaults to one when omitted.

    .PARAMETER note
    Notes about checkout

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
    System.Management.Automation.PSCustomObject

    .EXAMPLE
    Set-SnipeitAccessoryOwner -id 1 -assigned_to 1 -checkout_to_type user -note "testing check out to user"
#>
function Set-SnipeitAccessoryOwner() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [parameter(mandatory = $true)]
        [int]$assigned_to,

        [ValidateSet("user","asset","location")]
        [string]$checkout_to_type = "user",

        [string] $note,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$checkout_qty
    )
    begin{
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        $Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        switch ($checkout_to_type) {
            'user'     { $Values['assigned_user'] = $assigned_to }
            'asset'    { $Values['assigned_asset'] = $assigned_to }
            'location' { $Values['assigned_location'] = $assigned_to }
        }

        if ($Values.ContainsKey('assigned_to')) { $Values.Remove('assigned_to') }
        if ($Values.ContainsKey('checkout_to_type')) { $Values.Remove('checkout_to_type') }
    }

    process {
        foreach($accessory_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/accessories/$accessory_id/checkout"
                Method = 'POST'
                Session = $Session
                Body   = $Values
            }

            if ($PSCmdlet.ShouldProcess("Accessory ID $accessory_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
