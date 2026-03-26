<#
    .SYNOPSIS
    Set license seat or checkout license seat
    .DESCRIPTION
    Checkout specific license seat to user, asset or both

    .PARAMETER ID
    Unique ID for license to checkout or array of IDs

    .PARAMETER seat_id
    ID of the license seat

    .PARAMETER assigned_to
    ID of target user

    .PARAMETER asset_id
    ID of target asset

    .PARAMETER note
    Notes about checkout

    .PARAMETER RequestType
    HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

    .PARAMETER url
    Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipe-IT system.

    .PARAMETER apiKey
    Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipe-IT.

    .EXAMPLE
    Set-SnipeitLicenseSeat -ID 1 -seat_id 1 -assigned_id 3
    Checkout license to user ID 3

    .EXAMPLE
    Set-SnipeitLicenseSeat -ID 1 -seat_id 1 -asset_id 3
    Checkout license to asset ID 3

    .EXAMPLE
    Set-SnipeitLicenseSeat -ID 1 -seat_id 1 -asset_id $null -assigned_id $null
    Checkin license seat ID 1 of license ID 1

#>
function Set-SnipeitLicenseSeat() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [parameter(mandatory = $true)]
        [int]$seat_id,

        [Alias('assigned_id')]

        [Nullable[System.Int32]]$assigned_to,


        [Nullable[System.Int32]]$asset_id,

        [string]$note,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )

    begin{
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

        $Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        if ($PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Write-Warning "-apiKey parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyApiKey -apiKey $apikey
        }

        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url) {
            Write-Warning "-url parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyUrl -url $url
        }
    }

    process{
        foreach($license_id in $id) {
            $Parameters = @{
                Api    = "/api/v1/licenses/$license_id/seats/$seat_id"
                Method = $RequestType
                Body   = $Values
            }

            if ($PSCmdlet.ShouldProcess("ShouldProcess?")) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
        # reset legacy sessions
        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url -or $PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Reset-SnipeitPSLegacyApi
        }
    }
}
