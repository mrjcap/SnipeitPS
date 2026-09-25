<#
    .SYNOPSIS
    Add a new Manufacturer to Snipe-IT asset system

    .DESCRIPTION
    Creates a new manufacturer on Snipe-IT system

    .PARAMETER Name
    Name of the Manufacturer

    .PARAMETER image
    Manufacturer Image filename and path

    .PARAMETER manufacturer_url
    Website URL of the manufacturer. Named manufacturer_url to avoid conflict with the deprecated -url parameter.

    .PARAMETER support_email
Manufacturer support email address.

.PARAMETER support_phone
Manufacturer support phone number.

.PARAMETER support_url
URL of the manufacturer's support site.

.PARAMETER warranty_lookup_url
Warranty lookup URL, including any serial-number placeholder supported by Snipe-IT.

.PARAMETER tag_color
Hexadecimal color used for the manufacturer tag.

.PARAMETER notes
Notes stored with the manufacturer.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    New-SnipeitManufacturer -name "HP"
#>

function New-SnipeitManufacturer() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true)]
        [string]$name,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [string]$manufacturer_url,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [string]$support_email,

        [string]$support_phone,

        [string]$support_url,

        [string]$warranty_lookup_url,

        [string]$tag_color,

        [string]$notes
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        if ($Values.ContainsKey('manufacturer_url')) {
            $Values['url'] = $Values['manufacturer_url']
            $Values.Remove('manufacturer_url')
        }

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/manufacturers"
            Method = 'POST'
            Session = $Session
            Body   = $Values
        }
    }
    process {
        if ($PSCmdlet.ShouldProcess("Manufacturer '$name'", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }
    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
