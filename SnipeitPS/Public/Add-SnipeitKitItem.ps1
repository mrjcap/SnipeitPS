<#
.SYNOPSIS
Attaches an item to a predefined kit in Snipe-IT.

.DESCRIPTION
Attaches an existing license, model, accessory, or consumable to a predefined kit with the
specified quantity (default 1). Route IDs never enter the request body.

.PARAMETER kit_id
The ID of the parent predefined kit.

.PARAMETER ItemType
The type of item to attach. Allowed values: License, Model, Accessory, Consumable.

.PARAMETER item_id
The ID of the item to attach to the kit.

.PARAMETER quantity
The quantity of the item to include in the kit. Defaults to 1. Must be at least 1.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Add-SnipeitKitItem -kit_id 5 -ItemType Model -item_id 12 -quantity 2
#>
function Add-SnipeitKitItem {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [int]$kit_id,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet('License', 'Model', 'Accessory', 'Consumable')]
        [string]$ItemType,

        [Parameter(Mandatory = $true, Position = 2)]
        [Alias('id')]
        [int]$item_id,

        [Parameter(Mandatory = $false, Position = 3)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$quantity = 1,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ShouldProcess("Attach $ItemType ID $item_id (Qty: $quantity) to kit ID $kit_id", "Attach kit item")) {
            $segmentMap = @{
                'License'    = 'licenses'
                'Model'      = 'models'
                'Accessory'  = 'accessories'
                'Consumable' = 'consumables'
            }
            $keyMap = @{
                'License'    = 'license'
                'Model'      = 'model'
                'Accessory'  = 'accessory'
                'Consumable' = 'consumable'
            }
            $segment = $segmentMap[$ItemType]
            $bodyKey = $keyMap[$ItemType]

            $body = @{
                $bodyKey = $item_id
                quantity = $quantity
            }

            $params = @{
                Route   = "/api/v1/kits/$kit_id/$segment"
                Method  = 'POST'
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
