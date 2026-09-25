<#
.SYNOPSIS
Gets asset count summaries by status label or meta status type.

.DESCRIPTION
Retrieves asset count summaries formatted for status reporting via GET /api/v1/statuslabels/assets/name (by label name)
or GET /api/v1/statuslabels/assets/type (by meta status type).
Emits structured SnipeitPS.StatusCount objects retaining label, count, and chart color.

.PARAMETER By
Grouping criteria: Name (count by individual status label) or Type (count by meta status type: RTD, deployed, archived, pending, undeployable). Defaults to Name.

.PARAMETER preserveResponse
When set, returns the raw chart response structure instead of individual status count items.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.StatusCount

.EXAMPLE
Get-SnipeitStatusCount -By Name

.EXAMPLE
Get-SnipeitStatusCount -By Type
#>
function Get-SnipeitStatusCount {
    [CmdletBinding()]
    [OutputType('SnipeitPS.StatusCount')]
    param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateSet('Name', 'Type')]
        [string]$By = 'Name',

        [switch]$preserveResponse,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $route = switch ($By) {
            'Name' { "$script:SnipeitApiPrefix/statuslabels/assets/name" }
            'Type' { "$script:SnipeitApiPrefix/statuslabels/assets/type" }
        }

        $Parameters = @{
            Route            = $route
            Method           = 'Get'
            Session          = $Session
            PreserveResponse = [bool]$preserveResponse
        }

        $res = Invoke-SnipeitMethod @Parameters

        if ($preserveResponse) {
            $res
        } else {
            if ($res -and $res.labels -and $res.datasets) {
                $labels = $res.labels
                $dataset = $res.datasets[0]
                $data = if ($dataset -is [System.Collections.IDictionary]) { $dataset['data'] } else { $dataset.data }
                $colors = if ($dataset -is [System.Collections.IDictionary]) { $dataset['backgroundColor'] } else { $dataset.backgroundColor }

                for ($i = 0; $i -lt $labels.Count; $i++) {
                    $item = [PSCustomObject]@{
                        label = $labels[$i]
                        count = if ($data -and $i -lt $data.Count) { $data[$i] } else { 0 }
                        color = if ($colors -and $i -lt $colors.Count) { $colors[$i] } else { $null }
                    }
                    $item.PSObject.TypeNames.Insert(0, 'SnipeitPS.StatusCount')
                    $item
                }
            } else {
                $res
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
