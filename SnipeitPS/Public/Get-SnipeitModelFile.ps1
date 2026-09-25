<#
.SYNOPSIS
Gets files associated with a model

.PARAMETER id
An ID of a specific Model

.PARAMETER file_id
An ID of a specific file

.PARAMETER AsByteArray
Returns a SnipeitPS.FileContent object containing the original bytes. Requires file_id.

.PARAMETER inline
Requests inline disposition for a single file. Requires file_id; only safe file extensions are honored.
Use AsByteArray to preserve binary content.

.PARAMETER search
Search file names and notes.

.PARAMETER sort
File activity column to sort by.

.PARAMETER order
Sort direction, asc or desc.

.PARAMETER limit
Number of files per page. Uses the server default when omitted.

.PARAMETER offset
Number of files to skip.

.PARAMETER all
Retrieve every page of file metadata.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject
SnipeitPS.FileContent


.EXAMPLE
Get-SnipeitModelFile -id 1

#>

function Get-SnipeitModelFile() {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(mandatory = $true)]
        [int]$id,

        [parameter(ParameterSetName='Get with file ID')]
        [int]$file_id,

        [Parameter(ParameterSetName='Get with file ID')]
        [switch]$AsByteArray,

        [Parameter(ParameterSetName='Get with file ID')]
        [switch]$inline,

        [Parameter(ParameterSetName='Search')]
        [string]$search,

        [Parameter(ParameterSetName='Search')]
        [string]$sort,

        [Parameter(ParameterSetName='Search')]
        [ValidateSet('asc', 'desc')]
        [string]$order,

        [Parameter(ParameterSetName='Search')]
        [ValidateRange(1, 500)]
        [int]$limit,

        [Parameter(ParameterSetName='Search')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$offset,

        [Parameter(ParameterSetName='Search')]
        [switch]$all,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
}

    process {
        $fileOptions = @{}
        if ($PSBoundParameters.ContainsKey('inline')) {
            if (-not $PSBoundParameters.ContainsKey('file_id')) { throw 'inline requires file_id.' }
            $fileOptions['inline'] = [bool]$inline
        }
        if ($AsByteArray) {
            if (-not $PSBoundParameters.ContainsKey('file_id')) { throw 'AsByteArray requires file_id.' }
            Get-SnipeitFile -EntityType models -id $id -file_id $file_id -AsByteArray -Session $Session @fileOptions
            return
        }

        $pathParams = @{ id = $id }
        if ($PSBoundParameters.ContainsKey('file_id')) {
            $route = "$script:SnipeitApiPrefix/models/{id}/files/{file_id}"
            $pathParams['file_id'] = $file_id
        } else {
            $route = "$script:SnipeitApiPrefix/models/{id}/files"
        }

        $query = $fileOptions
        foreach ($field in @('search', 'sort', 'order', 'limit', 'offset')) {
            if ($PSBoundParameters.ContainsKey($field)) { $query[$field] = $PSBoundParameters[$field] }
        }
        $Parameters = @{
            Route         = $route
            PathParameter = $pathParams
            Method        = 'Get'
            Session = $Session
            GetParameters = $query
            Paginate = [bool]$all
        }

        $result = Invoke-SnipeitMethod @Parameters
        $result
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
