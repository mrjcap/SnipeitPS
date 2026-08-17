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
Serial number of the asset to audit

.PARAMETER next_audit_date
Due date for the asset's next audit

.PARAMETER Location_id
ID of the location you want to associate with the audit

.PARAMETER Note
Optional note for the audit log entry

.PARAMETER Image
Path to an image file to upload and attach to the audit log

.PARAMETER url
Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipe-IT system.

.PARAMETER apiKey
Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipe-IT.

.EXAMPLE
New-SnipeitAudit -tag 1 -location_id 1

.EXAMPLE
New-SnipeitAudit -id 42, 43 -note "Annual audit" -next_audit_date (Get-Date).AddMonths(6)
#>

function New-SnipeitAudit() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium",
        DefaultParameterSetName = 'ById'
    )]

    Param(
        [parameter(mandatory = $false, ParameterSetName = 'ById', ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [int[]]$id,

        [parameter(mandatory = $false, ParameterSetName = 'ByTag', ValueFromPipelineByPropertyName = $true)]
        [Alias('tag')]
        [string]$asset_tag,

        [parameter(mandatory = $false, ParameterSetName = 'BySerial', ValueFromPipelineByPropertyName = $true)]
        [string]$serial,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$location_id,

        [parameter(mandatory = $false)]
        [datetime]$next_audit_date,

        [parameter(mandatory = $false)]
        [Alias('notes')]
        [string]$note,

        [parameter(mandatory = $false)]
        [ValidateScript({Test-Path $_})]
        [string]$image,

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

        if ($PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Write-Warning "-apiKey parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyApiKey -apiKey $apiKey
        }

        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url) {
            Write-Warning "-url parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyUrl -url $url
        }
    }

    process {
        if (-not $id -and -not $asset_tag -and -not $serial) {
            throw "Must specify -id, -asset_tag (or -tag), or -serial for audit."
        }

        $Values = @{}

        if ($asset_tag) {
            $Values += @{"asset_tag" = $asset_tag}
        }

        if ($serial) {
            $Values += @{"serial" = $serial}
        }

        if ($location_id) {
            $Values += @{"location_id" = $location_id}
        }

        if ($PSBoundParameters.ContainsKey('next_audit_date')) {
            $Values += @{"next_audit_date" = ($next_audit_date).ToString("yyyy-MM-dd")}
        }

        if ($note) {
            $Values += @{"note" = $note}
        }

        if ($image) {
            $Values += @{"image" = $image}
        }

        if ($id -and $id.Count -gt 1 -and $image) {
            throw "Bulk audit with -image is not supported. Image upload forces multipart/form-data which corrupts bulk ID array serialization. Audit assets individually when attaching images."
        }

        if ($id -and $id.Count -gt 1) {
            $bulkValues = $Values.Clone()
            $bulkValues['ids'] = $id
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/hardware/audit/bulk"
                Method = 'POST'
                Body   = $bulkValues
            }
            $targetDesc = "Asset IDs $($id -join ', ')"
        } elseif ($id -and $id.Count -eq 1) {
            $assetId = $id[0]
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/hardware/$assetId/audit"
                Method = 'POST'
                Body   = $Values.Clone()
            }
            $targetDesc = "Asset ID $assetId"
        } else {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/hardware/audit"
                Method = 'POST'
                Body   = $Values.Clone()
            }
            $targetDesc = if ($asset_tag) { "Asset tag '$asset_tag'" } else { "Asset serial '$serial'" }
        }

        if ($PSCmdlet.ShouldProcess($targetDesc, $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
        if (($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url) -or ($PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey)) {
            Reset-SnipeitPSLegacyApi
        }
    }
}
