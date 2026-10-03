<#
.SYNOPSIS
Gets pending checkout requests submitted by the current authenticated user.

.DESCRIPTION
Retrieves pending checkout requests under /api/v1/account/requests, not request history.
Unpaginated. If no requests exist, returns no rows or a raw envelope with total = 0.
By default, id retains its original request ID and request_id is added alongside it.
Use NormalizeIdentity to remove the ambiguous id property. The nested requestable ID
is the inventory ID. Do not use a request ID or cancel_url as an inventory ID.

.PARAMETER preserveResponse
When specified, returns the raw API response object containing total and rows instead of unwrapping rows.

.PARAMETER NormalizeIdentity
Remove id from request rows and expose request_id instead. Off by default.
PreserveResponse takes precedence and returns unchanged rows.

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
        [SnipeitSession]$Session,

        [switch]$NormalizeIdentity
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
                    $row = ConvertTo-SnipeitResourceIdentity -InputObject $row -Route $Parameters.Route -NormalizeIdentity:$NormalizeIdentity
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
