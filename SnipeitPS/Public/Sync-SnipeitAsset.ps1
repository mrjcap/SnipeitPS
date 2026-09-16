<#
.SYNOPSIS
Synchronizes an asset with Snipe-IT based on desired state.

.DESCRIPTION
Checks remote state by asset tag.
If Ensure = 'Present' and the asset is missing, creates it.
If the asset exists, compares fields and updates only if properties drifted.
If Ensure = 'Absent' and the asset exists, deletes it.

.PARAMETER asset_tag
Asset tag to match.

.PARAMETER serial
Serial number.

.PARAMETER name
Asset display name.

.PARAMETER model_id
Model ID.

.PARAMETER status_id
Status ID.

.PARAMETER company_id
Company ID.

.PARAMETER location_id
Location ID.

.PARAMETER notes
Notes.

.PARAMETER customfields
Hashtable of custom field values.

.PARAMETER Ensure
Desired state: 'Present' (default) or 'Absent'.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject
When Ensure is 'Present', outputs the created, updated, or verified asset object. When Ensure is 'Absent', returns nothing.

.EXAMPLE
Sync-SnipeitAsset -asset_tag "SRV-001" -name "Core Router" -model_id 12 -status_id 1 -Ensure Present
#>
function Sync-SnipeitAsset {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$asset_tag,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$serial,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$name,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter([SnipeitModelCompleter])]
        [int]$model_id,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter([SnipeitStatusCompleter])]
        [int]$status_id,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter([SnipeitCompanyCompleter])]
        [int]$company_id,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter([SnipeitLocationCompleter])]
        [int]$location_id,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$notes,

        [Parameter(Mandatory = $false)]
        [hashtable]$customfields,

        [ValidateSet("Present", "Absent")]
        [string]$Ensure = "Present",

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    process {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Reconciling state for AssetTag '$asset_tag' (Ensure: $Ensure)"

        $sessionArgs = if ($PSBoundParameters.ContainsKey('Session')) { @{ Session = $Session } } else { @{} }

        # Check if asset exists by tag
        $existing = Get-SnipeitAsset -asset_tag $asset_tag @sessionArgs -ErrorAction Stop

        if ($Ensure -eq 'Absent') {
            if ($null -ne $existing -and $existing.id) {
                if ($PSCmdlet.ShouldProcess("Asset '$asset_tag' (ID: $($existing.id))", "Remove Asset (Ensure: Absent)")) {
                    Remove-SnipeitAsset -id $existing.id -Confirm:$false @sessionArgs
                }
            } else {
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Asset '$asset_tag' is already absent."
            }
            return
        }

        # Ensure: Present
        if ($null -eq $existing -or -not $existing.id) {
            # Asset does not exist -> Create
            $createArgs = @{
                asset_tag = $asset_tag
            }
            if ($PSBoundParameters.ContainsKey('name')) { $createArgs['name'] = $name }
            if ($PSBoundParameters.ContainsKey('serial')) { $createArgs['serial'] = $serial }
            if ($PSBoundParameters.ContainsKey('model_id')) { $createArgs['model_id'] = $model_id }
            if ($PSBoundParameters.ContainsKey('status_id')) { $createArgs['status_id'] = $status_id }
            if ($PSBoundParameters.ContainsKey('company_id')) { $createArgs['company_id'] = $company_id }
            if ($PSBoundParameters.ContainsKey('location_id')) { $createArgs['rtd_location_id'] = $location_id }
            if ($PSBoundParameters.ContainsKey('notes')) { $createArgs['notes'] = $notes }
            if ($PSBoundParameters.ContainsKey('customfields')) { $createArgs['customfields'] = $customfields }

            if ($PSCmdlet.ShouldProcess("Asset '$asset_tag'", "Create New Asset (Ensure: Present)")) {
                New-SnipeitAsset @createArgs @sessionArgs
            }
        } else {
            # Asset exists -> Check for property drift
            $driftDetected = $false
            $updatePayload = @{
                id = $existing.id
            }

            if ($PSBoundParameters.ContainsKey('name') -and $existing.name -ne $name) {
                $updatePayload['name'] = $name
                $driftDetected = $true
            }
            if ($PSBoundParameters.ContainsKey('serial') -and $existing.serial -ne $serial) {
                $updatePayload['serial'] = $serial
                $driftDetected = $true
            }
            if ($PSBoundParameters.ContainsKey('model_id') -and ($null -eq $existing.model -or $existing.model.id -ne $model_id)) {
                $updatePayload['model_id'] = $model_id
                $driftDetected = $true
            }
            if ($PSBoundParameters.ContainsKey('status_id') -and ($null -eq $existing.status_label -or $existing.status_label.id -ne $status_id)) {
                $updatePayload['status_id'] = $status_id
                $driftDetected = $true
            }
            if ($PSBoundParameters.ContainsKey('company_id') -and ($null -eq $existing.company -or $existing.company.id -ne $company_id)) {
                $updatePayload['company_id'] = $company_id
                $driftDetected = $true
            }
            $existingLocId = if ($null -ne $existing.rtd_location -and $null -ne $existing.rtd_location.id) {
                $existing.rtd_location.id
            } elseif ($null -ne $existing.rtd_location_id) {
                $existing.rtd_location_id
            } elseif ($null -ne $existing.location -and $null -ne $existing.location.id) {
                $existing.location.id
            } else { $null }

            if ($PSBoundParameters.ContainsKey('location_id') -and $existingLocId -ne $location_id) {
                $updatePayload['rtd_location_id'] = $location_id
                $driftDetected = $true
            }
            if ($PSBoundParameters.ContainsKey('notes') -and $existing.notes -ne $notes) {
                $updatePayload['notes'] = $notes
                $driftDetected = $true
            }
            if ($PSBoundParameters.ContainsKey('customfields') -and $customfields) {
                $cfDrift = $false
                $existingCF = $existing.custom_fields
                foreach ($pair in $customfields.GetEnumerator()) {
                    $key = if ($null -ne $pair.Key) { $pair.Key } else { $pair.Name }
                    $val = $pair.Value

                    $cfProp = if ($existingCF -is [System.Collections.IDictionary]) {
                        if ($existingCF.ContainsKey($key)) { $existingCF[$key] } else { $null }
                    } elseif ($null -ne $existingCF -and $null -ne $existingCF.PSObject) {
                        $p = $existingCF.PSObject.Properties[$key]
                        if ($null -ne $p) { $p.Value } else { $null }
                    } else { $null }

                    $currentVal = if ($null -ne $cfProp) {
                        if ($cfProp -is [System.Collections.IDictionary]) {
                            if ($cfProp.ContainsKey('value')) { $cfProp['value'] } else { $cfProp }
                        } elseif ($null -ne $cfProp.PSObject -and $null -ne $cfProp.PSObject.Properties['value']) {
                            $cfProp.PSObject.Properties['value'].Value
                        } else {
                            $cfProp
                        }
                    } else { $null }

                    if ("$currentVal" -ne "$val") {
                        $cfDrift = $true
                        break
                    }
                }
                if ($cfDrift) {
                    $updatePayload['customfields'] = $customfields
                    $driftDetected = $true
                }
            }

            if ($driftDetected) {
                if ($PSCmdlet.ShouldProcess("Asset '$asset_tag' (ID: $($existing.id))", "Update Drifted Properties")) {
                    Set-SnipeitAsset @updatePayload @sessionArgs
                }
            } else {
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Asset '$asset_tag' matches desired state; no action taken (Idempotent)."
                $existing
            }
        }
    }
}
