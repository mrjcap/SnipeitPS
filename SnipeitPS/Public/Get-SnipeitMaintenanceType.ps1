function Get-SnipeitMaintenanceType {
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'ById', ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$id,
        [Parameter(ParameterSetName = 'List')]
        [string]$name,
        [Parameter(ParameterSetName = 'List')]
        [string]$search,
        [Parameter(ParameterSetName = 'List')]
        [bool]$deleted,
        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('id', 'name', 'created_at', 'updated_at')]
        [string]$sort = 'name',
        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('asc', 'desc')]
        [string]$order = 'desc',
        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(1, 500)]
        [int]$limit = 50,
        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$offset,
        [Parameter(ParameterSetName = 'List')]
        [switch]$all,
        [SnipeitSession]$Session
    )
    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            foreach ($itemId in $id) {
                Invoke-SnipeitMethod -Api "$script:SnipeitApiPrefix/maintenance-types/$itemId" -Method Get -Session $Session
            }
        } else {
            $query = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
            $query.Remove('all')
            Invoke-SnipeitMethod -Api "$script:SnipeitApiPrefix/maintenance-types" -Method Get -GetParameters $query -Paginate:$all -Session $Session
        }
    }
}
