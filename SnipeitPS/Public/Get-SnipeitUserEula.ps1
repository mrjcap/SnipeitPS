<#
.SYNOPSIS
Gets the EULAs for a specific user

.PARAMETER id
An ID of a specific User

.PARAMETER limit
Number of EULA records per page. Uses the server default when omitted.

.PARAMETER offset
Number of records to skip.

.PARAMETER all
Retrieve every page of EULA records.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitUserEula -id 1

#>

function Get-SnipeitUserEula() {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(mandatory = $true)]
        [int]$id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

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
        foreach ($field in @('limit', 'offset')) {
            if ($PSBoundParameters.ContainsKey($field)) { $query[$field] = $PSBoundParameters[$field] }
        }
        $Parameters = @{
            Route         = "$script:SnipeitApiPrefix/users/{id}/eulas"
            PathParameter = @{ id = $id }
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
