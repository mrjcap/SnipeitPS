<#
.SYNOPSIS
Adds a manual note to an asset.

.DESCRIPTION
Appends a manual note to a hardware asset via POST /api/v1/notes/{asset}/store.

.PARAMETER asset_id
Unique ID of the asset.

.PARAMETER note
The note text to attach to the asset.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
New-SnipeitAssetNote -asset_id 101 -note 'Screen replaced by vendor warranty.'
#>
function New-SnipeitAssetNote {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium'
    )]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [Alias('id', 'asset')]
        [int]$asset_id,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$note,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ShouldProcess("Asset ID $asset_id", $MyInvocation.MyCommand.Name)) {
            $Parameters = @{
                Route       = "$script:SnipeitApiPrefix/notes/{asset}/store"
                RouteTokens = @{ asset = $asset_id }
                Method      = 'Post'
                Session     = $Session
                Body        = @{ note = $note }
            }

            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
