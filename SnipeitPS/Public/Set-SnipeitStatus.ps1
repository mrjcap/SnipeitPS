<#
.SYNOPSIS
Sets Snipe-IT Status Labels

.PARAMETER id
An ID of a specific Status Label

.PARAMETER name
Name of the status label

.PARAMETER type
Type of status label. Valid values are deployable, undeployable, pending, and archived.

.PARAMETER notes
Notes about the status label

.PARAMETER color
Hex code showing what color the status label should be on the pie chart in the dashboard

.PARAMETER show_in_nav
1 or 0 - determine whether the status label should show in the left-side nav of the web GUI

.PARAMETER default_label
1 or 0 - determine whether it should be bubbled up to the top of the list of available statuses

.PARAMETER RequestType
HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

.PARAMETER url
Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipe-IT system.

.PARAMETER apiKey
Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipe-IT.

.EXAMPLE
Set-SnipeitStatus -id 1 -name "Ready to Deploy" -type deployable

.EXAMPLE
Set-SnipeitStatus -id 3 -name 'Waiting for arrival' -type pending

#>

function Set-SnipeitStatus() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    Param(
        [parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [string]$name,

        [parameter(Mandatory=$true)]
        [ValidateSet('deployable','undeployable','pending','archived')]
        [string]$type,

        [string]$notes,

        [string]$color,

        [bool]$show_in_nav,

        [bool]$default_label,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )

    begin {
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

    process {
        foreach($status_id in $id) {
            $Parameters = @{
                Api           = "/api/v1/statuslabels/$status_id"
                Method        = $RequestType
                Body          = $Values
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
