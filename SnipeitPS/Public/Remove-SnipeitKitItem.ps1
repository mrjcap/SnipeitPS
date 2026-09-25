<#
.SYNOPSIS
Detaches an item from a predefined kit in Snipe-IT.

.DESCRIPTION
Detaches an associated item (license, model, accessory, or consumable) from a predefined kit
in Snipe-IT. This only detaches the association; it does not delete the underlying item itself.

.PARAMETER kit_id
The ID of the parent predefined kit.

.PARAMETER ItemType
The type of item to detach. Allowed values: License, Model, Accessory, Consumable.

.PARAMETER child_id
The ID of the attached item to detach from the kit.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Remove-SnipeitKitItem -kit_id 5 -ItemType Model -child_id 12
#>
function Remove-SnipeitKitItem {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
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

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ShouldProcess("Detach $ItemType ID $child_id from kit ID $kit_id", "Detach kit item")) {
            $segmentMap = @{
                'License'    = 'licenses'
                'Model'      = 'models'
                'Accessory'  = 'accessories'
                'Consumable' = 'consumables'
            }
            $segment = $segmentMap[$ItemType]

            $params = @{
                Route   = "/api/v1/kits/$kit_id/$segment/$child_id"
                Method  = 'DELETE'
                Session = $Session
            }

            Invoke-SnipeitMethod @params
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
