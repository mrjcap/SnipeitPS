<#
.SYNOPSIS
Deletes multiple hardware assets with individual requests.

.DESCRIPTION
Sends DELETE /api/v1/hardware/{id} for each unique asset ID after confirmation.
Returns id, status, messages, and payload for each response. Failed requests also emit errors.

.PARAMETER id
Array of asset IDs to delete.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Remove-SnipeitAssetBulk -id @(101, 102, 103)
#>
function Remove-SnipeitAssetBulk {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('ids', 'asset_id')]
        [int[]]$id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        $accumulatedIds = [System.Collections.Generic.List[int]]::new()
        $seenIds = [System.Collections.Generic.HashSet[int]]::new()
    }

    process {
        foreach ($singleId in $id) {
            if ($singleId -gt 0 -and $seenIds.Add($singleId)) {
                $accumulatedIds.Add($singleId)
            }
        }
    }

    end {
        if ($accumulatedIds.Count -eq 0) {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] No IDs provided for bulk deletion"
            return
        }

        $totalSummary = "$($accumulatedIds.Count) assets (IDs: $($accumulatedIds -join ', '))"
        if ($PSCmdlet.ShouldProcess($totalSummary, "Bulk Delete Hardware Assets")) {
            foreach ($assetId in $accumulatedIds) {
                $params = @{
                    Api              = "$script:SnipeitApiPrefix/hardware/$assetId"
                    Method           = 'DELETE'
                    Session          = $Session
                    PreserveResponse = $true
                }
                $requestErrors = @()
                $result = Invoke-SnipeitMethod @params -ErrorVariable requestErrors
                if ($null -ne $result) {
                    [pscustomobject]@{
                        id = $assetId
                        status = $result.status
                        messages = $result.messages
                        payload = $result.payload
                    }
                } elseif ($requestErrors.Count -gt 0) {
                    $failure = $requestErrors[-1]
                    $response = $failure.TargetObject
                    $isApiError = $failure.FullyQualifiedErrorId -like 'SnipeitApiError*'
                    [pscustomobject]@{
                        id = $assetId
                        status = 'error'
                        messages = if ($isApiError) { $response.messages } else { $failure.Exception.Message }
                        payload = if ($isApiError) { $response.payload } else { $response }
                    }
                }
            }
        }
    }
}
