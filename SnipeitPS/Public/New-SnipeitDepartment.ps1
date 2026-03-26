<#
    .SYNOPSIS
    Creates a department

    .DESCRIPTION
    Creates a new department on Snipe-IT system

    .PARAMETER name
    Department Name

    .PARAMETER company_id
    ID number of company

    .PARAMETER location_id
    ID number of location

    .PARAMETER manager_id
    ID number of manager

    .PARAMETER notes
    Notes about the department

    .PARAMETER image
    Department Image filename and path

    .PARAMETER image_delete
    Remove current image

    .PARAMETER url
    Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipe-IT system.

    .PARAMETER apiKey
    Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipe-IT.

    .EXAMPLE
    New-SnipeitDepartment -name "Department1" -company_id 1 -location_id 1 -manager_id 3

#>

function New-SnipeitDepartment() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]

    Param(
        [parameter(mandatory = $true)]
        [string]$name,

        [int]$company_id,

        [int]$location_id,

        [int]$manager_id,

        [string]$notes,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [switch]$image_delete=$false,

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

        $Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        $Parameters = @{
            Api    = "/api/v1/departments"
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
    }

    process {
        if ($PSCmdlet.ShouldProcess("ShouldProcess?")) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
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

