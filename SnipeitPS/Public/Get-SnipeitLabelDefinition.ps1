<#
.SYNOPSIS
Gets label definitions from Snipe-IT.

.DESCRIPTION
Queries label definition metadata via GET /api/v1/labels or retrieves a single label definition by name via GET /api/v1/labels/{name}.

.PARAMETER name
The name of the label definition to retrieve.

.PARAMETER search
Optional search filter string.

.PARAMETER limit
Maximum number of results to return.

.PARAMETER offset
Result offset for pagination.

.PARAMETER preserveResponse
When set, preserves the raw response envelope.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.LabelDefinition

.EXAMPLE
Get-SnipeitLabelDefinition

.EXAMPLE
Get-SnipeitLabelDefinition -name 'Default\Avery5160'
#>
function Get-SnipeitLabelDefinition {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    [OutputType('SnipeitPS.LabelDefinition')]
    param(
        [Parameter(ParameterSetName = 'ByName', Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$name,

        [Parameter(ParameterSetName = 'All', Mandatory = $false)]
        [string]$search,

        [Parameter(ParameterSetName = 'All', Mandatory = $false)]
        [int]$limit,

        [Parameter(ParameterSetName = 'All', Mandatory = $false)]
        [int]$offset,

        [switch]$preserveResponse,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $Parameters = @{
                Route            = "$script:SnipeitApiPrefix/labels/{name}"
                RouteTokens      = @{ name = $name }
                Method           = 'Get'
                Session          = $Session
                PreserveResponse = [bool]$preserveResponse
            }
        } else {
            $getParams = @{}
            if ($PSBoundParameters.ContainsKey('search')) { $getParams['search'] = $search }
            if ($PSBoundParameters.ContainsKey('limit')) { $getParams['limit'] = $limit }
            if ($PSBoundParameters.ContainsKey('offset')) { $getParams['offset'] = $offset }

            $Parameters = @{
                Route            = "$script:SnipeitApiPrefix/labels"
                Method           = 'Get'
                Session          = $Session
                GetParameters    = $getParams
                PreserveResponse = [bool]$preserveResponse
            }
        }

        $result = Invoke-SnipeitMethod @Parameters
        $result
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
