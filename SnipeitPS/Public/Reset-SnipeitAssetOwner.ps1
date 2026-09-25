<#
.SYNOPSIS
Check in an asset.

.DESCRIPTION
Checks in an asset from its current user, location, or asset.
Supports checkin by asset ID, checkin by asset tag in route, and quickscan checkin by tag/serial in request body.

.PARAMETER id
Unique ID(s) of the asset(s) to check in.

.PARAMETER tag
Unique asset tag(s) of the asset(s) to check in.

.PARAMETER checkin_key
Lookup key value (asset tag or serial number) for body-based checkin.

.PARAMETER checkin_by_field
Field to look up by for body-based checkin: asset_tag or serial. Defaults to asset_tag.

.PARAMETER status_id
Change asset status to this status ID upon checkin.

.PARAMETER location_id
Location ID to change asset location to upon checkin.

.PARAMETER update_default_location
When set, updates the asset's default (RTD) location to the specified location_id.

.PARAMETER name
Optional new asset name upon checkin.

.PARAMETER clear_name
When set, clears the asset's custom name upon checkin.

.PARAMETER checkin_at
Optional date to record as the checkin timestamp.

.PARAMETER note
Notes about the checkin.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Reset-SnipeitAssetOwner -id 44

.EXAMPLE
Reset-SnipeitAssetOwner -tag 'AST-0044' -note 'Returned by employee'

.EXAMPLE
Reset-SnipeitAssetOwner -checkin_key 'SRL-998811' -checkin_by_field 'serial'
#>
function Reset-SnipeitAssetOwner {
    [CmdletBinding(
        DefaultParameterSetName = 'ById',
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium'
    )]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [int[]]$id,

        [Parameter(ParameterSetName = 'ByTagPath', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('asset_tag')]
        [string[]]$tag,

        [Parameter(ParameterSetName = 'ByQuickScan', Mandatory = $true, Position = 0)]
        [string]$checkin_key,

        [Parameter(ParameterSetName = 'ByQuickScan', Mandatory = $false)]
        [ValidateSet('asset_tag', 'serial')]
        [string]$checkin_by_field = 'asset_tag',

        [string]$name,

        [switch]$clear_name,

        [datetime]$checkin_at,

        [Parameter(Position = 1)]
        [int]$status_id,

        [Parameter(Position = 2)]
        [int]$location_id,

        [switch]$update_default_location,

        [Parameter(Position = 3)]
        [string]$note,

        [Parameter(Mandatory = $false, Position = 4)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $body = @{}

        if ($clear_name) {
            $body['clear_name'] = 1
        } elseif ($PSBoundParameters.ContainsKey('name')) {
            $body['name'] = $name
        }

        if ($PSBoundParameters.ContainsKey('checkin_at')) {
            $body['checkin_at'] = $checkin_at.ToString('yyyy-MM-dd')
        }
        if ($PSBoundParameters.ContainsKey('status_id')) {
            $body['status_id'] = $status_id
        }
        if ($PSBoundParameters.ContainsKey('location_id')) {
            $body['location_id'] = $location_id
        }
        if ($update_default_location) {
            $body['update_default_location'] = 1
        }
        if ($PSBoundParameters.ContainsKey('note')) {
            $body['note'] = $note
        }

        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            foreach ($asset_id in $id) {
                if ($PSCmdlet.ShouldProcess("Asset ID $asset_id", $MyInvocation.MyCommand.Name)) {
                    $Parameters = @{
                        Api         = "$script:SnipeitApiPrefix/hardware/$asset_id/checkin"
                        Route       = "$script:SnipeitApiPrefix/hardware/{id}/checkin"
                        RouteTokens = @{ id = $asset_id }
                        Method      = 'Post'
                        Session     = $Session
                        Body        = $body
                    }

                    $result = Invoke-SnipeitMethod @Parameters
                    $result
                }
            }
        } elseif ($PSCmdlet.ParameterSetName -eq 'ByTagPath') {
            foreach ($asset_tag in $tag) {
                if ($PSCmdlet.ShouldProcess("Asset tag $asset_tag", $MyInvocation.MyCommand.Name)) {
                    $Parameters = @{
                        Api         = "$script:SnipeitApiPrefix/hardware/bytag/$asset_tag/checkin"
                        Route       = "$script:SnipeitApiPrefix/hardware/bytag/{tag}/checkin"
                        RouteTokens = @{ tag = $asset_tag }
                        Method      = 'Post'
                        Session     = $Session
                        Body        = $body
                    }

                    $result = Invoke-SnipeitMethod @Parameters
                    $result
                }
            }
        } elseif ($PSCmdlet.ParameterSetName -eq 'ByQuickScan') {
            if ($PSCmdlet.ShouldProcess("Checkin key $checkin_key", $MyInvocation.MyCommand.Name)) {
                $body['checkin_key'] = $checkin_key
                $body['checkin_by_field'] = $checkin_by_field

                $Parameters = @{
                    Api     = "$script:SnipeitApiPrefix/hardware/checkinbytag"
                    Route   = "$script:SnipeitApiPrefix/hardware/checkinbytag"
                    Method  = 'Post'
                    Session = $Session
                    Body    = $body
                }

                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
