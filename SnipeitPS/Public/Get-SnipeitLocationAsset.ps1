<#
.SYNOPSIS
Gets all physical assets currently at a specific location from Snipe-IT.

.DESCRIPTION
Retrieves all assets whose physical location matches the specified location ID in Snipe-IT.
The server returns all rows in a single unpaginated response.

.PARAMETER id
The ID of the location to query.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.Asset

.EXAMPLE
Get-SnipeitLocationAsset -id 3
#>
function Get-SnipeitLocationAsset {
    [CmdletBinding()]
    [OutputType('SnipeitPS.Asset')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $callParams = @{
            Route   = "/api/v1/locations/$id/assets"
            Method  = 'GET'
            Session = $Session
        }
        Invoke-SnipeitMethod @callParams
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
