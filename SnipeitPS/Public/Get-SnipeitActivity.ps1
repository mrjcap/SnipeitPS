<#
.SYNOPSIS
Gets and searches Snipe-IT Activity history

.DESCRIPTION
Gets a list of Snipe-IT activity history

.PARAMETER search
A text string to search the Activity history

.PARAMETER target_type
Type of target. One of the following: 'Accessory','Asset','AssetMaintenance','AssetModel','Category','Company','Component','Consumable','CustomField','Depreciable','Depreciation','Group','Licence','LicenseSeat','Location','Manufacturer','Statuslabel','Supplier','User'

.PARAMETER target_id
Needed if target_type is specified

.PARAMETER item_type
Type of item. One of the following: 'Accessory','Asset','AssetMaintenance','AssetModel','Category','Company','Component','Consumable','CustomField','Depreciable','Depreciation','Group','Licence','LicenseSeat','Location','Manufacturer','Statuslabel','Supplier','User'

.PARAMETER item_id
Needed if item_type is specified

.PARAMETER action_type
Type of action. One of the following: "add seats", "checkin from", "checkout", "update", "create", "delete", "restore", "upload", "accepted", "declined", "requested"

.PARAMETER limit
Specify the number of results to return

.PARAMETER offset
Result offset to use

.PARAMETER all
Return all results, works with -offset and other parameters

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitActivity -search Keyboard

.EXAMPLE
Get-SnipeitActivity -target_type Asset -target_id 1

#>

function Get-SnipeitActivity() {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param(

        [string]$search,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Accessory','Asset','AssetMaintenance','AssetModel','Category','Company','Component','Consumable','CustomField','Depreciable','Depreciation','Group','Licence','LicenseSeat','Location','Manufacturer','Statuslabel','Supplier','User')]
        [string]$target_type,

        [Parameter(Mandatory=$false)]
        [int]$target_id,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Accessory','Asset','AssetMaintenance','AssetModel','Category','Company','Component','Consumable','CustomField','Depreciable','Depreciation','Group','Licence','LicenseSeat','Location','Manufacturer','Statuslabel','Supplier','User')]
        [string]$item_type,

        [Parameter(Mandatory=$false)]
        [int]$item_id,

        [ValidateSet("add seats", "checkin from", "checkout", "update", "create", "delete", "restore", "upload", "accepted", "declined", "requested")]
        [string]$action_type ,

        [ValidateRange(1,500)]
        [int]$limit = 50,

        [int]$offset,

        [switch]$all = $false,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
if (($target_type -and -not $target_id) -or
            ($target_id -and -not $target_type)) {
            throw "Please specify both target_type and target_id"
        }

        if (($item_type -and -not $item_id) -or
            ($item_id -and -not $item_type)) {
            throw "Please specify both item_type and item_id"
        }

        $SearchParameter = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
    }

    process {
        if ($SearchParameter.ContainsKey('all')) {
            $SearchParameter.Remove('all')
        }

        $Parameters = @{
            Route         = "$script:SnipeitApiPrefix/reports/activity"
            Method        = 'Get'
            Session = $Session
            GetParameters = $SearchParameter
            Paginate      = [bool]$all
        }

        $result = Invoke-SnipeitMethod @Parameters
        $result
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
