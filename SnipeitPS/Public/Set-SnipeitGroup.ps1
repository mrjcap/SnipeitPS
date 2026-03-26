<#
.SYNOPSIS
Set properties of a Snipe-IT Group

.PARAMETER id
An ID of a specific Group

.PARAMETER name
Name of the Group

.PARAMETER permissions
Hashtable of permissions

.PARAMETER notes
Notes about the Group

.PARAMETER RequestType
HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

.PARAMETER url
Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipe-IT system.

.PARAMETER apiKey
Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipe-IT.

.EXAMPLE
Set-SnipeitGroup -id 1 -name "Updated Group"

#>

function Set-SnipeitGroup() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    Param(
        [parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [string]$name,

        [hashtable]$permissions,

        [string]$notes,

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
        foreach($group_id in $id) {
            $Parameters = @{
                Api           = "/api/v1/groups/$group_id"
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
