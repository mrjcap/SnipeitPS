<#
.SYNOPSIS
Updates the quantity of an item in a predefined kit in Snipe-IT.

.DESCRIPTION
Updates the quantity for an attached item (license, model, accessory, or consumable) in a
predefined kit in Snipe-IT via PUT. Route IDs never enter the request body; only quantity is sent.

.PARAMETER kit_id
The ID of the parent predefined kit.

.PARAMETER ItemType
The type of item to update. Allowed values: License, Model, Accessory, Consumable.

.PARAMETER child_id
The ID of the item attached to the kit.

.PARAMETER quantity
The updated quantity for this item in the kit. Must be at least 1.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Set-SnipeitKitItem -kit_id 5 -ItemType Model -child_id 12 -quantity 4
#>
function Set-SnipeitKitItem {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [int]$kit_id,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet('License', 'Model', 'Accessory', 'Consumable')]
        [string]$ItemType,

        [Parameter(Mandatory = $true, Position = 2)]
        [Alias('item_id', 'id')]
        [int]$child_id,

        [Parameter(Mandatory = $true, Position = 3)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$quantity,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ShouldProcess("Update $ItemType ID $child_id (Qty: $quantity) on kit ID $kit_id", "Update kit item")) {
            $segmentMap = @{
                'License'    = 'licenses'
                'Model'      = 'models'
                'Accessory'  = 'accessories'
                'Consumable' = 'consumables'
            }
            $segment = $segmentMap[$ItemType]

            $body = @{
                quantity = $quantity
            }

            $params = @{
                Route   = "/api/v1/kits/$kit_id/$segment/$child_id"
                Method  = 'PUT'
                Body    = $body
                Session = $Session
            }

            Invoke-SnipeitMethod @params
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
