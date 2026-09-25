<#
.SYNOPSIS
Gets items attached to a predefined kit in Snipe-IT.

.DESCRIPTION
Retrieves the list of attached items (licenses, models, accessories, or consumables) for a
specified predefined kit in Snipe-IT.

.PARAMETER kit_id
The ID of the parent predefined kit.

.PARAMETER ItemType
The type of items to retrieve. Allowed values: License, Model, Accessory, Consumable.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Get-SnipeitKitItem -kit_id 5 -ItemType Model
#>
function Get-SnipeitKitItem {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [int]$kit_id,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet('License', 'Model', 'Accessory', 'Consumable')]
        [string]$ItemType,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $segmentMap = @{
            'License'    = 'licenses'
            'Model'      = 'models'
            'Accessory'  = 'accessories'
            'Consumable' = 'consumables'
        }
        $segment = $segmentMap[$ItemType]

        $params = @{
            Route   = "/api/v1/kits/$kit_id/$segment"
            Method  = 'GET'
            Session = $Session
        }

        Invoke-SnipeitMethod @params
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
