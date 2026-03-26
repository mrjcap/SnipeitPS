<#
    .SYNOPSIS
    Sets authentication information. Deprecated, use Connect-SnipeitPS instead.

    .DESCRIPTION
    Deprecated compatibility function that Sets API Key and URL used to connect to Snipe-IT system.
    Please use Connect-SnipeitPS instead.

    .PARAMETER url
    URL of Snipe-IT system.

    .PARAMETER apiKey
    User's API Key for Snipe-IT.

    .EXAMPLE
    Set-SnipeitInfo -url $url -apiKey $myapikey -Verbose
#>
function Set-SnipeitInfo {
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        [parameter(Mandatory=$true)]
        [Uri]$url,
        [parameter(Mandatory=$true)]
        [String]$apiKey
    )

    BEGIN {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        Write-Warning "Deprecated $($MyInvocation.InvocationName) is still working, please use Connect-SnipeitPS instead."
    }

    PROCESS {
        Connect-SnipeitPS -Url $url -apiKey $apiKey
    }

    END {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
