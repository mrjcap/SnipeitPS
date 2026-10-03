<#
.SYNOPSIS
Processes an uploaded import file in Snipe-IT.

.DESCRIPTION
Processes an existing uploaded CSV/TSV import in Snipe-IT using the specified import type,
column mappings, and optional processing flags. Slicing via Offset and Limit is supported.

.PARAMETER import_id
The ID of the uploaded import record to process.

.PARAMETER ImportType
The entity type to import. Supported values:
asset, assetHistory, assetModel, accessory, consumable, component, license, user,
location, supplier, manufacturer, category.

.PARAMETER ColumnMappings
Hashtable mapping CSV headers to importer field names. Mapping values cannot be null.

.PARAMETER Update
Switch to update existing matching records rather than failing on duplicate keys.
Supports explicit false via -Update:$false.

.PARAMETER SendWelcome
Switch to send welcome email notifications to newly created users.
Supports explicit false via -SendWelcome:$false.

.PARAMETER RunBackup
Switch to trigger an Artisan backup before processing the import file.
Supports explicit false via -RunBackup:$false.

.PARAMETER Offset
Starting record offset within the CSV file for sliced/chunked processing.

.PARAMETER Limit
Maximum number of records to process in this slice.

.PARAMETER MatchUsername
History-matching switch: match asset history user by username. Valid only when ImportType is assetHistory.

.PARAMETER MatchEmail
History-matching switch: match asset history user by email. Valid only when ImportType is assetHistory.

.PARAMETER MatchFirstnameLastname
History-matching switch: match asset history user by firstname.lastname. Valid only when ImportType is assetHistory.

.PARAMETER MatchFlastname
History-matching switch: match asset history user by flastname. Valid only when ImportType is assetHistory.

.PARAMETER MatchFirstname
History-matching switch: match asset history user by firstname. Valid only when ImportType is assetHistory.

.PARAMETER PreserveBlanks
On updates, keeps stored values when the importer treats the CSV value as empty.
The server's empty-value rule includes zero, false and the string '0'. Explicit false
is sent as false; omission leaves the server default. Resend this flag for every slice.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.ImportResult

.EXAMPLE
Invoke-SnipeitImport -import_id 5 -ImportType 'asset' -ColumnMappings @{ 'Asset Tag' = 'asset_tag' }
#>
function Invoke-SnipeitImport {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType('SnipeitPS.ImportResult')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('id')]
        [int]$import_id,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet('asset', 'assetHistory', 'assetModel', 'accessory', 'consumable', 'component', 'license', 'user', 'location', 'supplier', 'manufacturer', 'category')]
        [string]$ImportType,

        [Parameter(Mandatory = $false)]
        [hashtable]$ColumnMappings,

        [Parameter(Mandatory = $false)]
        [switch]$Update,

        [Parameter(Mandatory = $false)]
        [switch]$SendWelcome,

        [Parameter(Mandatory = $false)]
        [switch]$RunBackup,

        [Parameter(Mandatory = $false)]
        [int]$Offset,

        [Parameter(Mandatory = $false)]
        [int]$Limit,

        [Parameter(Mandatory = $false)]
        [switch]$MatchUsername,

        [Parameter(Mandatory = $false)]
        [switch]$MatchEmail,

        [Parameter(Mandatory = $false)]
        [switch]$MatchFirstnameLastname,

        [Parameter(Mandatory = $false)]
        [switch]$MatchFlastname,

        [Parameter(Mandatory = $false)]
        [switch]$MatchFirstname,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [switch]$PreserveBlanks
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $historySwitches = @('MatchUsername', 'MatchEmail', 'MatchFirstnameLastname', 'MatchFlastname', 'MatchFirstname')
        $usedHistorySwitches = @($historySwitches | Where-Object { $PSBoundParameters.ContainsKey($_) })
        if ($ImportType -ne 'assetHistory' -and $usedHistorySwitches.Count -gt 0) {
            $switchNames = $usedHistorySwitches -join ', '
            throw [System.ArgumentException]::new("The history-matching parameters ($switchNames) are only supported when ImportType is 'assetHistory'.", 'ImportType')
        }

        if ($PSBoundParameters.ContainsKey('ColumnMappings') -and $null -ne $ColumnMappings) {
            foreach ($key in $ColumnMappings.Keys) {
                if ($null -eq $ColumnMappings[$key]) {
                    throw [System.ArgumentException]::new("ColumnMappings cannot contain null values for mapping '$key'.", 'ColumnMappings')
                }
            }
        }

        $body = @{
            'import-type'     = $ImportType
            'column-mappings' = if ($PSBoundParameters.ContainsKey('ColumnMappings')) { $ColumnMappings } else { $null }
        }

        if ($PSBoundParameters.ContainsKey('PreserveBlanks')) { $body['import-preserve-blanks'] = [bool]$PreserveBlanks }
        if ($PSBoundParameters.ContainsKey('Update')) { $body['import-update'] = [bool]$Update }
        if ($PSBoundParameters.ContainsKey('SendWelcome')) { $body['send-welcome'] = [bool]$SendWelcome }
        if ($PSBoundParameters.ContainsKey('RunBackup')) { $body['run-backup'] = [bool]$RunBackup }
        if ($PSBoundParameters.ContainsKey('Offset')) { $body['offset'] = $Offset }
        if ($PSBoundParameters.ContainsKey('Limit')) { $body['limit'] = $Limit }

        if ($ImportType -eq 'assetHistory') {
            if ($PSBoundParameters.ContainsKey('MatchUsername')) { $body['match_username'] = [bool]$MatchUsername }
            if ($PSBoundParameters.ContainsKey('MatchEmail')) { $body['match_email'] = [bool]$MatchEmail }
            if ($PSBoundParameters.ContainsKey('MatchFirstnameLastname')) { $body['match_firstnamelastname'] = [bool]$MatchFirstnameLastname }
            if ($PSBoundParameters.ContainsKey('MatchFlastname')) { $body['match_flastname'] = [bool]$MatchFlastname }
            if ($PSBoundParameters.ContainsKey('MatchFirstname')) { $body['match_firstname'] = [bool]$MatchFirstname }
        }

        if ($PSCmdlet.ShouldProcess("Process import $import_id ($ImportType)", "Process import")) {
            $activeSession = if ($null -ne $Session) { $Session } else { $script:SnipeitPSSession }
            $sessUrl = if ($activeSession -is [System.Collections.IDictionary]) { $activeSession['url'] } else { $activeSession.Url }
            if ($null -eq $sessUrl) {
                throw "Please use Connect-SnipeitPS to set up a connection before any other commands."
            }
            $baseUri = ([string]$sessUrl).TrimEnd('/')
            $processUri = "$baseUri$script:SnipeitApiPrefix/imports/process/$import_id"

            $req = @{
                Uri    = $processUri
                Method = 'POST'
                Body   = $body
            }

            $raw = Invoke-SnipeitHttpRequest -Request $req -Session $Session
            ConvertFrom-SnipeitApiResponse -Response $raw -ResponseKind 'ImportResult'
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
