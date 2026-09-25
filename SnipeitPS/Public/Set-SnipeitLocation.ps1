<#
    .SYNOPSIS
    Updates Location in Snipe-IT asset system

    .DESCRIPTION
    Updates Location in Snipe-IT asset system

    .PARAMETER id
    ID number of location or array of IDs

    .PARAMETER name
    Name of Location

    .PARAMETER address
    Address line 1

    .PARAMETER address2
    Address line 2

    .PARAMETER state
    Address State

    .PARAMETER country
    Address Country

    .PARAMETER zip
    Address zipcode

    .PARAMETER manager_id
    Location manager as id

    .PARAMETER city
    City of the location

    .PARAMETER currency
    Currency used at the location

    .PARAMETER ldap_ou
    LDAP OU of Location

    .PARAMETER parent_id
    Parent location as id

    .PARAMETER image
    Image file name and path for item

    .PARAMETER image_delete
    Remove current image

    .PARAMETER RequestType
    HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

    .PARAMETER phone
Location contact phone number.

.PARAMETER fax
Location contact fax number.

.PARAMETER company_id
ID of the company that owns the location. Pass $null to clear it when server policy permits.

.PARAMETER tag_color
Hexadecimal color used for the location tag.

.PARAMETER notes
Notes stored with the location.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Set-SnipeitLocation -id 123 -name "Some storage" -parent_id 100


#>
function Set-SnipeitLocation() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [ValidateLength(3, 255)]
        [string]$name,

        [string]$address,

        [string]$address2,

        [string]$state,

        [string]$country,

        [string]$zip,

        [string]$city,

        [string]$currency,

        [ArgumentCompleter([SnipeitUserCompleter])]
        [Nullable[System.Int32]]$manager_id,

        [string]$ldap_ou,

        [ArgumentCompleter([SnipeitLocationCompleter])]
        [Nullable[System.Int32]]$parent_id,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [switch]$image_delete=$false,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [string]$phone,

        [string]$fax,

        [ArgumentCompleter([SnipeitCompanyCompleter])]
        [Nullable[int]]$company_id,

        [string]$tag_color,

        [string]$notes
    )

    begin{
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
    }

    process{
        foreach ($location_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/locations/$location_id"
                Method = $RequestType
                Session = $Session
                Body   = $Values.Clone()
            }

            if ($PSCmdlet.ShouldProcess("Location ID $location_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}

