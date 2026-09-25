<#
    .SYNOPSIS
    Updates an existing Manufacturer in Snipe-IT asset system

    .DESCRIPTION
    Updates manufacturer on Snipe-IT system

    .PARAMETER id
    ID number of the Manufacturer to update

    .PARAMETER Name
    Name of the Manufacturer

    .PARAMETER image
    Image file name and path for item

    .PARAMETER manufacturer_url
    Website URL of the manufacturer. Named manufacturer_url to avoid conflict with the deprecated -url parameter.

    .PARAMETER image_delete
    Remove current image

    .PARAMETER RequestType
    HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

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
    Set-SnipeitManufacturer -id 1 -name "HP Inc."
#>

function Set-SnipeitManufacturer() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true, ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [string]$name,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [string]$manufacturer_url,

        [switch]$image_delete=$false,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [string]$support_email,

        [string]$support_phone,

        [string]$support_url,

        [string]$warranty_lookup_url,

        [string]$tag_color,

        [string]$notes
    )

    begin{
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        if ($Values.ContainsKey('manufacturer_url')) {
            $Values['url'] = $Values['manufacturer_url']
            $Values.Remove('manufacturer_url')
        }
    }

    process{
        foreach ($manufacturer_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/manufacturers/$manufacturer_id"
                Method = $RequestType
                Session = $Session
                Body   = $Values.Clone()
            }

            if ($PSCmdlet.ShouldProcess("Manufacturer ID $manufacturer_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
