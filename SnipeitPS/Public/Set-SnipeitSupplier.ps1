<#
    .SYNOPSIS
    Modify the supplier

    .DESCRIPTION
    Modifies the supplier on Snipe-IT system

    .PARAMETER id
    ID number of the Supplier to update

    .PARAMETER name
    Supplier Name

    .PARAMETER address
    Address line 1 of supplier

    .PARAMETER address2
    Address line 2 of supplier

    .PARAMETER city
    City

    .PARAMETER state
    State

    .PARAMETER country
    Country

    .PARAMETER zip
    Zip code

    .PARAMETER phone
    Phone number

    .PARAMETER fax
    Fax number

    .PARAMETER email
    Email address

    .PARAMETER contact
    Contact person

    .PARAMETER notes
    Notes about the supplier

    .PARAMETER image
    Image file name and path for item

    .PARAMETER supplier_url
    Website URL of the supplier. Named supplier_url to avoid conflict with the deprecated -url parameter.

    .PARAMETER image_delete
    Remove current image

    .PARAMETER RequestType
    HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Set-SnipeitSupplier -id 1 -name "UpdatedSupplier"

#>

function Set-SnipeitSupplier() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true, ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [string]$name,

        [string]$address,

        [string]$address2,

        [string]$city,

        [string]$state,

        [string]$country,

        [string]$zip,

        [string]$phone,

        [string]$fax,

        [string]$email,

        [string]$contact,

        [string]$notes,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [string]$supplier_url,

        [switch]$image_delete,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        if ($Values.ContainsKey('supplier_url')) {
            $Values['url'] = $Values['supplier_url']
            $Values.Remove('supplier_url')
        }
    }
    process {
        foreach ($supplier_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/suppliers/$supplier_id"
                Method = $RequestType
                Session = $Session
                Body   = $Values.Clone()
            }

            if ($PSCmdlet.ShouldProcess("Supplier ID $supplier_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}

