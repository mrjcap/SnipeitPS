<#
    .SYNOPSIS
    Gets a list of checked out accessories
    .DESCRIPTION
    Gets a list of checked out accessories

    .PARAMETER id
    Unique ID for accessory to list

    .PARAMETER search
    Search accessory checkout records.

    .PARAMETER limit
    Number of checkout records per page. Defaults to the server's page size when omitted.

    .PARAMETER offset
    Number of records to skip.

    .PARAMETER all
    Retrieve every page of checkout records.

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Get-SnipeitAccessoryOwner -id 1
#>
function Get-SnipeitAccessoryOwner() {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [int]$id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [string]$search,

        [ValidateRange(1, 500)]
        [int]$limit,

        [ValidateRange(0, [int]::MaxValue)]
        [int]$offset,

        [switch]$all
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
}
    process {
        $query = @{}
        foreach ($field in @('search', 'limit', 'offset')) {
            if ($PSBoundParameters.ContainsKey($field)) { $query[$field] = $PSBoundParameters[$field] }
        }
        $Parameters = @{
            Route         = "$script:SnipeitApiPrefix/accessories/{id}/checkedout"
            PathParameter = @{ id = $id }
            Method        = 'GET'
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
