<#
.SYNOPSIS
Gets asset requests submitted by the current authenticated user.

.DESCRIPTION
Retrieves pending or past checkout requests submitted by the current user under /api/v1/account/requests.
Unpaginated. If no requests exist, returns an empty list or total = 0.

.PARAMETER preserveResponse
When specified, returns the raw API response object containing total and rows instead of unwrapping rows.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Get-SnipeitAccountRequest

.EXAMPLE
Get-SnipeitAccountRequest -preserveResponse
#>
function Get-SnipeitAccountRequest {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$preserveResponse,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $Parameters = @{
            Route            = "$script:SnipeitApiPrefix/account/requests"
            Method           = 'Get'
            Session          = $Session
            PreserveResponse = $true
        }

        $res = Invoke-SnipeitMethod @Parameters

        if ($preserveResponse) {
            $res
            return
        }

        if ($null -ne $res) {
            $rows = if ($res -is [System.Collections.IDictionary]) { $res['rows'] } else { $res.rows }
            if ($null -ne $rows) {
                foreach ($row in $rows) {
                    if ($row -is [System.Management.Automation.PSObject] -and -not $row.PSObject.TypeNames.Contains('SnipeitPS.AccountRequest')) {
                        $row.PSObject.TypeNames.Insert(0, 'SnipeitPS.AccountRequest')
                    }
                    $row
                }
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
