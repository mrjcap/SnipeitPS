<#
    .SYNOPSIS
    Creates a supplier

    .DESCRIPTION
    Creates a new supplier on Snipe-IT system

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

    .PARAMETER supplier_url
    Website URL of the supplier. Named supplier_url to avoid conflict with the deprecated -url parameter.

    .PARAMETER image
    Image file name and path for item

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    New-SnipeitSupplier -name "Supplier1"

#>

function New-SnipeitSupplier() {
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

        [string]$phone,

        [string]$fax,

        [string]$email,

        [string]$contact,

        [string]$notes,

        [string]$supplier_url,

        [ValidateScript({Test-Path $_})]
        [string]$image,

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

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/suppliers"
            Method = 'POST'
            Session = $Session
            Body   = $Values
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("Supplier '$name'", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}

