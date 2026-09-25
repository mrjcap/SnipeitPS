<#
.SYNOPSIS
Creates a new depreciation schedule in Snipe-IT.

.DESCRIPTION
Creates a new depreciation schedule in Snipe-IT with a specified name and duration in months (1 to 3600).

.PARAMETER name
The name of the depreciation schedule (1 to 255 characters).

.PARAMETER months
The number of months over which assets are depreciated (1 to 3600).

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.Depreciation

.EXAMPLE
New-SnipeitDepreciation -name "Computer Equipment 36M" -months 36
#>
function New-SnipeitDepreciation {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType('SnipeitPS.Depreciation')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 255)]
        [string]$name,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateRange(1, 3600)]
        [int]$months,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ShouldProcess("$name ($months months)", "Create depreciation")) {
            $body = @{
                name   = $name
                months = $months
            }
            $params = @{
                Route   = '/api/v1/depreciations'
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
