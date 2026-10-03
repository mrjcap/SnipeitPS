<#
.SYNOPSIS
Gets accessories assigned to a specific user

.DESCRIPTION
Lists accessory assignments for a user. By default, id retains its original
assignment ID. For valid nested accessories, accessory_id is the inventory ID
and checkout_id is the assignment ID. Existing ID properties remain unchanged.
Use NormalizeIdentity to replace id with the inventory ID and reject invalid
nested IDs. Rows without a nested accessory remain unchanged.

.PARAMETER id
An ID of a specific user

.PARAMETER limit
Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

.PARAMETER offset
Offset to use

.PARAMETER all
Return all results, works with -offset and other parameters

.PARAMETER search
Search accessory names and checkout notes.

.PARAMETER sort
Sort by accessory name or checkout created_at. Defaults to created_at.

.PARAMETER order
Sort direction: asc or desc. Defaults to desc.

.PARAMETER NormalizeIdentity
Replace assignment id with the accessory inventory ID. Off by default.
Invalid nested inventory IDs raise SnipeitResourceIdentityError only when enabled.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitUserAccessory -id 1

#>

function Get-SnipeitUserAccessory() {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(mandatory = $true)]
        [int]$id,

        [ValidateRange(1,500)]
        [int]$limit = 50,

        [int]$offset,

        [switch]$all = $false,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [string]$search,

        [ValidateSet('name', 'created_at')]
        [string]$sort = 'created_at',

        [ValidateSet('asc', 'desc')]
        [string]$order = 'desc',

        [switch]$NormalizeIdentity
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$SearchParameter = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters -DefaultExcludeParameter 'id', 'url', 'apiKey', 'Debug', 'Verbose'
    }

    process {
        if ($SearchParameter.ContainsKey('all')) {
            $SearchParameter.Remove('all')
        }

        $Parameters = @{
            Route         = "$script:SnipeitApiPrefix/users/{id}/accessories"
            PathParameter = @{ id = $id }
            Method        = 'Get'
            Session = $Session
            GetParameters = $SearchParameter
            Paginate      = [bool]$all
            NormalizeIdentity = [bool]$NormalizeIdentity
        }

        $result = Invoke-SnipeitMethod @Parameters
        $result
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
