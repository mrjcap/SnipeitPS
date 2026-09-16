<#
    .SYNOPSIS
    Add a new Location to Snipe-IT asset system

    .DESCRIPTION
    Add a new Location to Snipe-IT asset system

    .PARAMETER name
    Name of the Location

    .PARAMETER address
    Address line 1 of the location

    .PARAMETER address2
    Address line 2 of the location

    .PARAMETER state
    Address State of the location

    .PARAMETER country
    Country of the location

    .PARAMETER zip
    The zip code of the location

    .PARAMETER ldap_ou
    The LDAP OU of the location

    .PARAMETER parent_id
    Parent location ID for the location

    .PARAMETER currency
    Currency used at the location

    .PARAMETER city
    City of the location

    .PARAMETER manager_id
    The manager ID of the location

    .PARAMETER image
    Location Image filename and path

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    New-SnipeitLocation -name "Room 1" -address "123 Asset Street" -parent_id 14
#>

function New-SnipeitLocation() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true)]
        [string]$name,

        [string]$address,

        [string]$address2,

        [string]$city,

        [string]$state,

        [string]$country,

        [string]$zip,

        [string]$currency,

        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitLocationCompleter])]
        [int]$parent_id,

        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitUserCompleter])]
        [int]$manager_id,

        [string]$ldap_ou,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/locations"
            Method = 'post'
            Session = $Session
            Body   = $Values
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("Location '$name'", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
