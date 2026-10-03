<#
.SYNOPSIS
Creates a maintenance type with an optional color.
.DESCRIPTION
Posts to /api/v1/maintenance-types. Sends tag_color only when explicitly bound.
.PARAMETER name
Nonblank maintenance-type name.
.PARAMETER tag_color
Color string, empty string, or null. Omission leaves the server default.
.PARAMETER Session
Optional custom SnipeitSession instance.
.EXAMPLE
New-SnipeitMaintenanceType -name 'Inspection' -tag_color '#123456'
#>
function New-SnipeitMaintenanceType {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ -not [string]::IsNullOrWhiteSpace($_) })]
        [string]$name,

        [SnipeitSession]$Session,
        [AllowNull()]
        [AllowEmptyString()]
        [object]$tag_color
    )
    process {
        if ($null -ne $tag_color -and $tag_color -isnot [string]) {
            throw [ArgumentException]::new('tag_color must be a string or null.', 'tag_color')
        }
        $body = @{ name = $name }
        if ($PSBoundParameters.ContainsKey('tag_color')) { $body['tag_color'] = $PSBoundParameters['tag_color'] }
        if ($PSCmdlet.ShouldProcess("maintenance-types", $MyInvocation.MyCommand.Name)) {
                Invoke-SnipeitMethod -Api "$script:SnipeitApiPrefix/maintenance-types" -Method POST -Body $body -Session $Session
            }
    }
}
