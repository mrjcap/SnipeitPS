<#
.SYNOPSIS
Updates multiple hardware assets in a single batch request.

.DESCRIPTION
Sends asset IDs and property updates to PATCH /api/v1/hardware/bulk in chunks of 100.
Returns each server envelope with overall status, messages, and per-asset results.

.PARAMETER id
Array of asset IDs to update.

.PARAMETER status_id
New status ID.

.PARAMETER model_id
New model ID.

.PARAMETER company_id
New company ID.

.PARAMETER location_id
New location ID.

.PARAMETER rtd_location_id
New default location ID.

.PARAMETER supplier_id
New supplier ID.

.PARAMETER notes
New notes string.

.PARAMETER warranty_months
New warranty duration in months.

.PARAMETER purchase_date
New purchase date.

.PARAMETER customfields
Hashtable of custom field values.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Update-SnipeitAssetBulk -id @(1, 2, 3) -status_id 2 -notes "Bulk updated"
#>
function Update-SnipeitAssetBulk {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('ids', 'asset_id')]
        [int[]]$id,

        [Parameter(Mandatory = $false)]
        [ArgumentCompleter([SnipeitStatusCompleter])]
        [int]$status_id,

        [Parameter(Mandatory = $false)]
        [ArgumentCompleter([SnipeitModelCompleter])]
        [int]$model_id,

        [Parameter(Mandatory = $false)]
        [ArgumentCompleter([SnipeitCompanyCompleter])]
        [int]$company_id,

        [Parameter(Mandatory = $false)]
        [ArgumentCompleter([SnipeitLocationCompleter])]
        [int]$location_id,

        [Parameter(Mandatory = $false)]
        [ArgumentCompleter([SnipeitLocationCompleter])]
        [int]$rtd_location_id,

        [Parameter(Mandatory = $false)]
        [ArgumentCompleter([SnipeitSupplierCompleter])]
        [int]$supplier_id,

        [Parameter(Mandatory = $false)]
        [string]$notes,

        [Parameter(Mandatory = $false)]
        [int]$warranty_months,

        [Parameter(Mandatory = $false)]
        [datetime]$purchase_date,

        [Parameter(Mandatory = $false)]
        [hashtable]$customfields,

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
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] No IDs provided for bulk update"
            return
        }

        $baseBody = @{}

        if ($PSBoundParameters.ContainsKey('status_id')) { $baseBody['status_id'] = $status_id }
        if ($PSBoundParameters.ContainsKey('model_id')) { $baseBody['model_id'] = $model_id }
        if ($PSBoundParameters.ContainsKey('company_id')) { $baseBody['company_id'] = $company_id }
        if ($PSBoundParameters.ContainsKey('location_id')) { $baseBody['location_id'] = $location_id }
        if ($PSBoundParameters.ContainsKey('rtd_location_id')) { $baseBody['rtd_location_id'] = $rtd_location_id }
        if ($PSBoundParameters.ContainsKey('supplier_id')) { $baseBody['supplier_id'] = $supplier_id }
        if ($PSBoundParameters.ContainsKey('notes')) { $baseBody['notes'] = $notes }
        if ($PSBoundParameters.ContainsKey('warranty_months')) { $baseBody['warranty_months'] = $warranty_months }
        if ($PSBoundParameters.ContainsKey('purchase_date')) { $baseBody['purchase_date'] = $purchase_date.ToString("yyyy-MM-dd") }

        if ($customfields) {
            foreach ($pair in $customfields.GetEnumerator()) {
                $baseBody[$pair.Name] = $pair.Value
            }
        }

        $totalSummary = "$($accumulatedIds.Count) assets (IDs: $($accumulatedIds -join ', '))"
        if ($PSCmdlet.ShouldProcess($totalSummary, "Bulk Update Hardware Assets")) {
            $chunkSize = 100
            for ($i = 0; $i -lt $accumulatedIds.Count; $i += $chunkSize) {
                $count = [Math]::Min($chunkSize, $accumulatedIds.Count - $i)
                $chunk = $accumulatedIds.GetRange($i, $count).ToArray()
                $requestBody = $baseBody.Clone()
                $requestBody['ids'] = $chunk

                $params = @{
                    Api     = "$script:SnipeitApiPrefix/hardware/bulk"
                    Method  = "PATCH"
                    Body    = $requestBody
                    Session = $Session
                }
                $result = Invoke-SnipeitMethod @params
                $result
            }
        }
    }
}
