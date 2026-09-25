<#
.SYNOPSIS
Updates an existing depreciation schedule in Snipe-IT.

.DESCRIPTION
Modifies an existing depreciation schedule's name or duration in months. Only bound parameters are sent to the API.

.PARAMETER id
The ID of the depreciation schedule to update.

.PARAMETER name
New name for the depreciation schedule (1 to 255 characters).

.PARAMETER months
New duration in months (1 to 3600).

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.Depreciation

.EXAMPLE
Set-SnipeitDepreciation -id 5 -months 48

.EXAMPLE
Set-SnipeitDepreciation -id 5 -name "Laptops 48M" -months 48
#>
function Set-SnipeitDepreciation {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType('SnipeitPS.Depreciation')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$id,

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 255)]
        [string]$name,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 3600)]
        [int]$months,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if (-not $PSBoundParameters.ContainsKey('name') -and -not $PSBoundParameters.ContainsKey('months')) {
            throw "At least one property ('name' or 'months') must be provided to update depreciation schedule $id."
        }

        if ($PSCmdlet.ShouldProcess("Depreciation ID $id", "Set depreciation")) {
            $body = @{}
            if ($PSBoundParameters.ContainsKey('name')) { $body['name'] = $name }
            if ($PSBoundParameters.ContainsKey('months')) { $body['months'] = $months }

            $params = @{
                Route   = "/api/v1/depreciations/$id"
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
