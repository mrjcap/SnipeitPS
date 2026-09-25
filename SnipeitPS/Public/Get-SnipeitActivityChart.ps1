<#
.SYNOPSIS
Gets the activity report chart data from Snipe-IT.

.DESCRIPTION
Retrieves activity metrics (user, asset, component, consumable, license, accessory events, and maintenance actions)
via GET /api/v1/reports/activity/chart. Supports either a preset number of days (7, 14, 30, 60, 90, 180, 365)
or a custom date range. Preserves all labels, comparison intervals, and series as a single structured SnipeitPS.ActivityChart object.

.PARAMETER days
Number of days of activity data to query: 7, 14, 30, 60, 90, 180, or 365. Defaults to 30.

.PARAMETER start_date
Start date for custom date range.

.PARAMETER end_date
End date for custom date range.

.PARAMETER preserveResponse
When set, returns the raw unadorned response.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.ActivityChart

.EXAMPLE
Get-SnipeitActivityChart

.EXAMPLE
Get-SnipeitActivityChart -days 90

.EXAMPLE
Get-SnipeitActivityChart -start_date ([datetime]'2026-01-01') -end_date ([datetime]'2026-03-31')
#>
function Get-SnipeitActivityChart {
    [CmdletBinding(DefaultParameterSetName = 'ByDays')]
    [OutputType('SnipeitPS.ActivityChart')]
    param(
        [Parameter(ParameterSetName = 'ByDays', Mandatory = $false, Position = 0)]
        [ValidateSet(7, 14, 30, 60, 90, 180, 365)]
        [int]$days = 30,

        [Parameter(ParameterSetName = 'ByDateRange', Mandatory = $true)]
        [datetime]$start_date,

        [Parameter(ParameterSetName = 'ByDateRange', Mandatory = $true)]
        [datetime]$end_date,

        [switch]$preserveResponse,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $getParams = @{}
        if ($PSCmdlet.ParameterSetName -eq 'ByDateRange') {
            $getParams['start_date'] = $start_date.ToString('yyyy-MM-dd')
            $getParams['end_date'] = $end_date.ToString('yyyy-MM-dd')
        } else {
            $getParams['days'] = $days
        }

        $Parameters = @{
            Route            = "$script:SnipeitApiPrefix/reports/activity/chart"
            Method           = 'Get'
            Session          = $Session
            GetParameters    = $getParams
            PreserveResponse = [bool]$preserveResponse
        }

        $result = Invoke-SnipeitMethod @Parameters
        if ($result -and $result -is [System.Management.Automation.PSObject] -and -not $result.PSObject.TypeNames.Contains('SnipeitPS.ActivityChart')) {
            $result.PSObject.TypeNames.Insert(0, 'SnipeitPS.ActivityChart')
        }
        $result
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
