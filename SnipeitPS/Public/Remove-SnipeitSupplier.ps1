<#
    .SYNOPSIS
    Removes supplier from Snipe-IT asset system
    .DESCRIPTION
    Removes supplier or multiple suppliers from Snipe-IT asset system
    .PARAMETER ID
    Unique ID for supplier to be removed
    .PARAMETER url
Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipe-IT system.

    .PARAMETER apiKey
Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipe-IT.

    .EXAMPLE
    Remove-SnipeitSupplier -ID 44

    .EXAMPLE
    Get-SnipeitSupplier | Where-object {$_.name -like '*something*'} | Remove-SnipeitSupplier
#>

function Remove-SnipeitSupplier () {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

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
        foreach($supplier_id in $id) {
            $Parameters = @{
                Api    = "/api/v1/suppliers/$supplier_id"
                Method = 'Delete'
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
