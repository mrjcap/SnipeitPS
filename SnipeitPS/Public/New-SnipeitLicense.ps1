<#
    .SYNOPSIS
    Creates a license

    .DESCRIPTION
    Creates a new license on Snipe-IT system

    .PARAMETER name
    Name of license being created

    .PARAMETER seats
    Number of license seats owned.

    .PARAMETER category_id
    ID number of license category

    .PARAMETER company_id
    ID number of company the license belongs to

    .PARAMETER expiration_date
    Date of license expiration

    .PARAMETER license_email
    Email address associated with license

    .PARAMETER license_name
    Name of license contact person

    .PARAMETER maintained
    Maintained status of license

    .PARAMETER manufacturer_id
    ID number of manufacturer of license.

    .PARAMETER notes
    License Notes

    .PARAMETER order_number
    Order number of license purchase

    .PARAMETER purchase_cost
    Cost of license

    .PARAMETER purchase_date
    Date of license purchase

    .PARAMETER reassignable
    Is license reassignable?

    .PARAMETER serial
    Serial number of license

    .PARAMETER supplier_id
    ID number of license supplier

    .PARAMETER termination_date
    Termination date for license.

    .PARAMETER depreciation_id
ID of the depreciation schedule. The server requires purchase_date when this is set.

.PARAMETER purchase_order
Purchase order reference for the license.

.PARAMETER min_amt
Minimum seat quantity used for inventory alerts.

.PARAMETER requestable
Whether users can request this license. Accepts true, false, or null.
Omit to leave the server default unchanged.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    New-SnipeitLicense -name "License" -seats 3 -company_id 1

.NOTES
company_id, purchase_date, expiration_date, and termination_date accept explicit null.
Unbound optional fields are omitted from the request.
#>

function New-SnipeitLicense() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true)]
        [ValidateLength(3, 255)]
        [string]$name,

        [parameter(mandatory = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$seats,

        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitCategoryCompleter])]
        [int]$category_id,

        [ArgumentCompleter([SnipeitCompanyCompleter])]
        [Nullable[int]]$company_id,

        [Nullable[datetime]]$expiration_date,

        [ValidateLength(1, 120)]
        [string]$license_email,

        [ValidateLength(1, 100)]
        [string]$license_name,

        [Nullable[bool]]$maintained,

        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitManufacturerCompleter])]
        [int]$manufacturer_id,

        [string]$notes,

        [string]$order_number,

        [string]$purchase_cost,

        [Nullable[datetime]]$purchase_date,

        [Nullable[bool]]$reassignable,

        [string]$serial,

        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitSupplierCompleter])]
        [int]$supplier_id,

        [Nullable[datetime]]$termination_date,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [Nullable[int]]$depreciation_id,

        [string]$purchase_order,

        [Nullable[int]]$min_amt,

        [Nullable[bool]]$requestable
    )
    begin {
        if ($null -ne $company_id -and $company_id -lt 1) {
            throw [System.ArgumentOutOfRangeException]::new('company_id', 'Use a positive ID or null.')
        }
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        if ($Values['expiration_date']) {
            $Values['expiration_date'] = $Values['expiration_date'].ToString("yyyy-MM-dd")
        }

        if ($Values['purchase_date']) {
            $Values['purchase_date'] = $Values['purchase_date'].ToString("yyyy-MM-dd")
        }

        if ($Values['termination_date']) {
            $Values['termination_date'] = $Values['termination_date'].ToString("yyyy-MM-dd")
        }

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/licenses"
            Method = 'POST'
            Session = $Session
            Body   = $Values
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("License '$name'", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }
    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}

