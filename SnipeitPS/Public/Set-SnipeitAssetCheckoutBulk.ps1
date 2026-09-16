<#
.SYNOPSIS
Checks out multiple assets to a user, location, or asset.

.DESCRIPTION
Checks out each asset ID to the specified target.

.PARAMETER id
Array of asset IDs to check out.

.PARAMETER assigned_id
ID of the target user, location, or asset.

.PARAMETER checkout_to_type
Target type: 'user', 'location', or 'asset'. Defaults to 'user'.

.PARAMETER note
Checkout note.

.PARAMETER expected_checkin
Expected checkin date.

.PARAMETER checkout_at
Checkout date override.

.PARAMETER status_id
Status ID applied on checkout.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Set-SnipeitAssetCheckoutBulk -id @(1, 2, 3) -assigned_id 42 -checkout_to_type user
#>
function Set-SnipeitAssetCheckoutBulk {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('ids', 'asset_id')]
        [int[]]$id,

        [Parameter(Mandatory = $true)]
        [int]$assigned_id,

        [ValidateSet("location", "asset", "user")]
        [string]$checkout_to_type = "user",

        [string]$note,

        [datetime]$expected_checkin,

        [datetime]$checkout_at,

        [ArgumentCompleter([SnipeitStatusCompleter])]
        [int]$status_id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        $accumulatedIds = [System.Collections.Generic.List[int]]::new()
        $seenIds = [System.Collections.Generic.HashSet[int]]::new()
        $body = @{
            'checkout_to_type' = $checkout_to_type
        }
        switch ($checkout_to_type) {
            'location' { $body['assigned_location'] = $assigned_id }
            'user'     { $body['assigned_user'] = $assigned_id }
            'asset'    { $body['assigned_asset'] = $assigned_id }
        }

        if ($PSBoundParameters.ContainsKey('note')) { $body['note'] = $note }
        if ($PSBoundParameters.ContainsKey('expected_checkin')) { $body['expected_checkin'] = $expected_checkin.ToString("yyyy-MM-dd") }
        if ($PSBoundParameters.ContainsKey('checkout_at')) { $body['checkout_at'] = $checkout_at.ToString("yyyy-MM-dd") }
        if ($PSBoundParameters.ContainsKey('status_id')) { $body['status_id'] = $status_id }
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
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] No IDs provided for bulk checkout"
            return
        }

        $displayIds = if ($accumulatedIds.Count -gt 10) {
            ($accumulatedIds[0..9] -join ', ') + "... ($($accumulatedIds.Count - 10) more)"
        } else {
            $accumulatedIds -join ', '
        }
        $totalSummary = "$($accumulatedIds.Count) assets (IDs: $displayIds)"

        if ($PSCmdlet.ShouldProcess($totalSummary, "Bulk Checkout to $checkout_to_type ID $assigned_id")) {
            foreach ($singleId in $accumulatedIds) {
                $params = @{
                    Api     = "$script:SnipeitApiPrefix/hardware/$singleId/checkout"
                    Method  = "POST"
                    Body    = $body
                    Session = $Session
                }
                $result = Invoke-SnipeitMethod @params
                $result
            }
        }
    }
}
