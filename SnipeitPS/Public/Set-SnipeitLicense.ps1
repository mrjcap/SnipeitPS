<#
    .SYNOPSIS
    Updates a license

    .DESCRIPTION
    Updates license on Snipe-IT system

    .PARAMETER id
    ID number of license or array of license IDs

    .PARAMETER name
    Name of license

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

    .PARAMETER RequestType
    HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

    .PARAMETER depreciation_id
ID of the depreciation schedule. Pass $null to clear it.

.PARAMETER purchase_order
Purchase order reference for the license.

.PARAMETER min_amt
Minimum seat quantity used for inventory alerts.

.PARAMETER requestable
Whether users can request this license. Accepts true, false, or null.
Omit to leave the stored value unchanged.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Set-SnipeitLicense -id 1 -name "License" -seats 3 -company_id 1

#>

function Set-SnipeitLicense() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true, ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [ValidateLength(3, 255)]
        [string]$name,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$seats,

        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitCategoryCompleter])]
        [int]$category_id,

        [ArgumentCompleter([SnipeitCompanyCompleter])]
        [Nullable[System.Int32]]$company_id,

        [Nullable[datetime]]$expiration_date,

        [string]$license_email,

        [ValidateLength(1, 100)]
        [string]$license_name,

        [Nullable[bool]]$maintained,

        [ArgumentCompleter([SnipeitManufacturerCompleter])]
        [Nullable[int]]$manufacturer_id,

        [string]$notes,

        [string]$order_number,

        [string]$purchase_cost,

        [Nullable[datetime]]$purchase_date,

        [Nullable[bool]]$reassignable,

        [string]$serial,

        [ArgumentCompleter([SnipeitSupplierCompleter])]
        [Nullable[System.Int32]]$supplier_id,

        [Nullable[datetime]]$termination_date,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [Nullable[int]]$depreciation_id,

        [string]$purchase_order,

        [Nullable[int]]$min_amt,

        [Nullable[bool]]$requestable
    )

    begin{
        if ($null -ne $manufacturer_id -and $manufacturer_id -lt 1) {
            throw [System.ArgumentOutOfRangeException]::new('manufacturer_id', 'Use a positive ID or null to clear the manufacturer.')
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
    }

    process {
        foreach($license_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/licenses/$license_id"
                Method = $RequestType
                Session = $Session
                Body   = $Values
            }

            if ($PSCmdlet.ShouldProcess("License ID $license_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }
    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
