<#
.SYNOPSIS
Add a new Audit to Snipe-IT asset system

.DESCRIPTION
Add a new Audit to Snipe-IT asset system

.PARAMETER asset_tag
The asset tag of the asset you wish to audit

.PARAMETER Id
The unique ID or array of IDs of the asset(s) to audit (bulk audit)

.PARAMETER serial
Raw serial number of the asset to audit. The server must have unique_serial enabled.

.PARAMETER next_audit_date
Due date for the asset's next audit

.PARAMETER Location_id
ID of the location you want to associate with the audit

.PARAMETER Note
Optional note for the audit log entry

.PARAMETER Image
Path to an image file to upload and attach to the audit log

.EXAMPLE
New-SnipeitAudit -tag 1 -location_id 1

.PARAMETER update_location
Write location_id to the asset rather than only recording the audit location. Allows an explicit null location.

.PARAMETER clear_name
Clear the asset name when true.

.PARAMETER customfields
Custom audit values keyed by internal _snipeit_ database column names. Only fields enabled for audit are persisted.
Encrypted custom fields additionally require the server's encrypted-field permission.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
New-SnipeitAudit -id 42, 43 -note "Annual audit" -next_audit_date (Get-Date).AddMonths(6)
#>

function New-SnipeitAudit() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium",
        DefaultParameterSetName = 'ById'
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $false, ParameterSetName = 'ById', ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [int[]]$id,

        [parameter(mandatory = $false, ParameterSetName = 'ByTag', ValueFromPipelineByPropertyName = $true)]
        [Alias('tag')]
        [string]$asset_tag,

        [parameter(mandatory = $false, ParameterSetName = 'BySerial', ValueFromPipelineByPropertyName = $true)]
        [string]$serial,

        [Nullable[int]]$location_id,

        [parameter(mandatory = $false)]
        [datetime]$next_audit_date,

        [parameter(mandatory = $false)]
        [Alias('notes')]
        [string]$note,

        [parameter(mandatory = $false)]
        [ValidateScript({Test-Path $_})]
        [string]$image,

        [Nullable[bool]]$update_location,

        [Nullable[bool]]$clear_name,

        [hashtable]$customfields,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
}

    process {
        if (-not $id -and -not $asset_tag -and -not $serial) {
            throw "Must specify -id, -asset_tag, or -serial for audit."
        }

        if ($id -and $id.Count -gt 1 -and $image) {
            throw "Bulk audit with -image is not supported. Image upload forces multipart/form-data which corrupts bulk ID array serialization. Audit assets individually when attaching images."
        }

        if ($null -ne $location_id -and $location_id -lt 1) {
            throw [System.ArgumentOutOfRangeException]::new('location_id', 'Use a positive ID or null.')
        }
        $Values = @{}
        foreach ($field in @('update_location', 'clear_name')) {
            if ($PSBoundParameters.ContainsKey($field)) { $Values[$field] = $PSBoundParameters[$field] }
        }
        foreach ($field in $customfields.Keys) {
            if ($field -notmatch '^_snipeit_[A-Za-z0-9_]+$') {
                throw [System.ArgumentException]::new('Audit custom fields must use internal _snipeit_ column names.')
            }
            $Values[$field] = $customfields[$field]
        }
        if ($asset_tag) { $Values['asset_tag'] = $asset_tag }
        if ($serial) {
            $Values['audit_by_field'] = 'serial'
            $Values['audit_key'] = $serial
        }
        if ($PSBoundParameters.ContainsKey('location_id')) { $Values['location_id'] = $location_id }
        if ($PSBoundParameters.ContainsKey('next_audit_date')) {
            $Values['next_audit_date'] = $next_audit_date.ToString("yyyy-MM-dd")
        }
        if ($PSBoundParameters.ContainsKey('note')) { $Values['note'] = $note }
        if ($image) { $Values['image'] = $image }

        if ($id -and $id.Count -gt 1) {
            $bulkValues = $Values.Clone()
            $bulkValues['ids'] = $id
            $api = "$script:SnipeitApiPrefix/hardware/audit/bulk"
            $body = $bulkValues
            $targetDesc = "Asset IDs $($id -join ', ')"
        } elseif ($id -and $id.Count -eq 1) {
            $assetId = $id[0]
            $api = "$script:SnipeitApiPrefix/hardware/$assetId/audit"
            $body = $Values.Clone()
            $targetDesc = "Asset ID $assetId"
        } else {
            $api = "$script:SnipeitApiPrefix/hardware/audit"
            $body = $Values.Clone()
            $targetDesc = if ($asset_tag) { "Asset tag '$asset_tag'" } else { "Asset serial '$serial'" }
        }

        $Parameters = @{
            Api    = $api
            Method = 'POST'
            Session = $Session
            Body   = $body
        }

        if ($PSCmdlet.ShouldProcess($targetDesc, $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
