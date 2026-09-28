<#
.SYNOPSIS
Gets files associated with an entity in Snipe-IT.

.DESCRIPTION
Retrieves file attachments or file metadata for an allowlisted Snipe-IT entity type.

.PARAMETER EntityType
The type of object to retrieve files for. Supported types:
accessories, audits, assets, components, consumables, hardware, licenses, locations,
maintenances, models, suppliers, users, companies, departments.

.PARAMETER id
The ID of the parent entity.

.PARAMETER file_id
The ID of a specific file to retrieve.

.PARAMETER search
Search query for filtering by filename or note.

.PARAMETER sort
Sort column for results. Allowed values: id, filename, action_type, action_date, note, created_at.

.PARAMETER order
Sort direction: asc or desc.

.PARAMETER offset
Starting record offset for pagination.

.PARAMETER limit
Maximum number of records to return per page.

.PARAMETER All
Fetch all pages automatically using pagination.

.PARAMETER AsByteArray
Opt-in switch for single file retrieval returning binary content wrapped in SnipeitPS.FileContent.

.PARAMETER inline
Requests inline disposition for a single file. The server only honors this for safe file extensions.
Use AsByteArray to preserve binary content; this switch changes disposition, not the response format.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject
SnipeitPS.FileContent

.EXAMPLE
Get-SnipeitFile -EntityType 'hardware' -id 100

.EXAMPLE
Get-SnipeitFile -EntityType 'models' -id 5 -file_id 12 -AsByteArray
#>
function Get-SnipeitFile {
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('accessories', 'audits', 'assets', 'components', 'consumables', 'hardware', 'licenses', 'locations', 'maintenances', 'models', 'suppliers', 'users', 'companies', 'departments')]
        [string]$EntityType,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [int]$id,

        [Parameter(Position = 2, ParameterSetName = 'SingleFile')]
        [int]$file_id,

        [Parameter(ParameterSetName = 'List')]
        [string]$search,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('id', 'filename', 'action_type', 'action_date', 'note', 'created_at')]
        [string]$sort,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('asc', 'desc')]
        [string]$order,

        [Parameter(ParameterSetName = 'List')]
        [int]$offset,

        [Parameter(ParameterSetName = 'List')]
        [int]$limit,

        [Parameter(ParameterSetName = 'List')]
        [switch]$All,

        [Parameter(ParameterSetName = 'SingleFile')]
        [switch]$AsByteArray,

        [Parameter(ParameterSetName = 'SingleFile')]
        [switch]$inline,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'SingleFile') {
            if (-not $PSBoundParameters.ContainsKey('file_id')) {
                throw 'file_id is required for single-file retrieval.'
            }
            $query = @{}
            if ($PSBoundParameters.ContainsKey('inline')) { $query['inline'] = [bool]$inline }
            if ($AsByteArray) {
                $tempPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "snipeit_file_$([System.Guid]::NewGuid().ToString('N')).tmp")
                try {
                    $activeSession = if ($null -ne $Session) { $Session } else { $script:SnipeitPSSession }
                    $sessUrl = if ($activeSession -is [System.Collections.IDictionary]) { $activeSession['url'] } else { $activeSession.Url }
                    $baseUri = ([string]$sessUrl).TrimEnd('/')
                    $fileUri = "$baseUri$script:SnipeitApiPrefix/$EntityType/$id/files/$file_id"
                    $fileUri += ConvertTo-GetParameter -InputObject $query

                    $null = Save-SnipeitApiFile -Uri $fileUri `
                                                -OutFile $tempPath `
                                                -EntityType $EntityType `
                                                -Id $id `
                                                -FileId $file_id `
                                                -Force `
                                                -Session $Session

                    $bytes = [System.IO.File]::ReadAllBytes($tempPath)
                    return [pscustomobject]@{
                        PSTypeName = 'SnipeitPS.FileContent'
                        EntityType = $EntityType
                        Id         = $id
                        FileId     = $file_id
                        Content    = $bytes
                        Length     = $bytes.Length
                    }
                } finally {
                    if (Test-Path -LiteralPath $tempPath) {
                        Remove-Item -LiteralPath $tempPath -Force -ErrorAction SilentlyContinue
                    }
                }
            } else {
                $params = @{
                    Route         = '/api/v1/{object_type}/{id}/files/{file_id}'
                    PathParameter = @{
                        object_type = $EntityType
                        id          = $id
                        file_id     = $file_id
                    }
                    Method        = 'GET'
                    Session       = $Session
                    GetParameters = $query
                }
                Invoke-SnipeitMethod @params
            }
        } else {
            $queryParams = @{}
            if ($PSBoundParameters.ContainsKey('search')) { $queryParams['search'] = $search }
            if ($PSBoundParameters.ContainsKey('sort')) { $queryParams['sort'] = $sort }
            if ($PSBoundParameters.ContainsKey('order')) { $queryParams['order'] = $order }
            if ($PSBoundParameters.ContainsKey('offset')) { $queryParams['offset'] = $offset }
            if ($PSBoundParameters.ContainsKey('limit')) { $queryParams['limit'] = $limit }

            $params = @{
                Route         = '/api/v1/{object_type}/{id}/files'
                PathParameter = @{
                    object_type = $EntityType
                    id          = $id
                }
                Method        = 'GET'
                Session       = $Session
            }
            if ($queryParams.Count -gt 0) {
                $params['GetParameters'] = $queryParams
            }
            if ($All) {
                $params['Paginate'] = $true
            }

            Invoke-SnipeitMethod @params
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
