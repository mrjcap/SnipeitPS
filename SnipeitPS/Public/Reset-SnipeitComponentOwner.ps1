<#
    .SYNOPSIS
    Checkin a component in Snipe-it

    .DESCRIPTION
    Checks in a component that was previously checked out. The id parameter
    is the component_assets pivot record ID (not the component ID).
    Use Get-SnipeitComponent to find checked out assets and their pivot IDs.

    .PARAMETER id
    The component_assets pivot record ID for the checkout to reverse.
    This is the ID from the component's assets list, not the component ID itself.

    .PARAMETER checkin_qty
    Quantity of the component to checkin

    .PARAMETER note
    Notes about checkin

    .PARAMETER url
    Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipeit system.

    .PARAMETER apiKey
    Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipeit.

    .EXAMPLE
    Reset-SnipeitComponentOwner -id 15 -checkin_qty 1

    Checkin 1 unit using the component_assets pivot record ID 15.
#>
function Reset-SnipeitComponentOwner() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]

    Param(
        [parameter(mandatory = $true)]
        [int]$id,

        [parameter(mandatory = $true)]
        [int]$checkin_qty,

        [string]$note,

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )

    Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

    $Values = @{
        "checkin_qty" = $checkin_qty
    }

    if ($PSBoundParameters.ContainsKey('note')) { $Values.Add("note", $note) }

    $Parameters = @{
        Api    = "/api/v1/components/$id/checkin"
        Method = 'POST'
        Body   = $Values
    }

    if ($PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
        Write-Warning "-apiKey parameter is deprecated, please use Connect-SnipeitPS instead."
        Set-SnipeitPSLegacyApiKey -apiKey $apikey
    }

    if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url) {
        Write-Warning "-url parameter is deprecated, please use Connect-SnipeitPS instead."
        Set-SnipeitPSLegacyUrl -url $url
    }

    if ($PSCmdlet.ShouldProcess("ShouldProcess?")) {
        $result = Invoke-SnipeitMethod @Parameters
    }

    # reset legacy sessions
    if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url -or $PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
        Reset-SnipeitPSLegacyApi
    }

    return $result
}
