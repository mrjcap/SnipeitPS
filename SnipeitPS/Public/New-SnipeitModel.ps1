<#
    .SYNOPSIS
    Add a new Model to Snipe-IT asset system

    .DESCRIPTION
    Add a new Model to Snipe-IT asset system

    .PARAMETER name
    Name of the Asset Model

    .PARAMETER model_number
    Model number of the Asset Model

    .PARAMETER category_id
    Category ID that the model belongs to. This can be obtained using Get-SnipeitCategory

    .PARAMETER manufacturer_id
    Manufacturer ID that the model belongs to. This can be obtained using Get-SnipeitManufacturer

    .PARAMETER eol
    Number of months until end of life

    .PARAMETER fieldset_id
    Fieldset ID that the asset uses (Custom fields)

    .PARAMETER image
    Asset model Image filename and path

    .PARAMETER depreciation_id
ID of the depreciation schedule used by this model.

.PARAMETER min_amt
Minimum model quantity used for inventory alerts.

.PARAMETER notes
Notes stored with the model.

.PARAMETER requestable
Whether assets of this model can be requested.

.PARAMETER require_serial
Require a serial number for assets of this model.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    New-SnipeitModel -name "DL380" -manufacturer_id 2 -fieldset_id 2 -category_id 1
.NOTES
eol accepts explicit null. Unbound optional fields are omitted from the request.
#>

function New-SnipeitModel() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true)]
        [string]$name,

        [string]$model_number,

        [parameter(mandatory = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitCategoryCompleter])]
        [int]$category_id,

        [ArgumentCompleter([SnipeitManufacturerCompleter])]
        [Nullable[int]]$manufacturer_id,

        [Nullable[int]]$eol,

        [parameter(mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$fieldset_id,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [Nullable[int]]$depreciation_id,

        [Nullable[int]]$min_amt,

        [string]$notes,

        [Nullable[bool]]$requestable,

        [Nullable[bool]]$require_serial
    )

    begin {
        if ($null -ne $manufacturer_id -and $manufacturer_id -lt 1) {
            throw [System.ArgumentOutOfRangeException]::new('manufacturer_id', 'Use a positive ID or null to omit the manufacturer.')
        }
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = @{
            name            = $name
            category_id     = $category_id
        }

        foreach ($field in @('depreciation_id', 'min_amt', 'notes', 'requestable', 'require_serial')) {
            if ($PSBoundParameters.ContainsKey($field)) { $Values[$field] = $PSBoundParameters[$field] }
        }

        if ($PSBoundParameters.ContainsKey('manufacturer_id')) { $Values.Add('manufacturer_id', $manufacturer_id) }
        if ($PSBoundParameters.ContainsKey('fieldset_id')) { $Values.Add("fieldset_id", $fieldset_id) }
        if ($PSBoundParameters.ContainsKey('model_number')) { $Values.Add("model_number", $model_number) }
        if ($PSBoundParameters.ContainsKey('eol')) { $Values.Add("eol", $eol) }
        if ($PSBoundParameters.ContainsKey('image')) { $Values.Add("image", $image) }

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/models"
            Method = 'post'
            Session = $Session
            Body   = $Values
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("Model '$name'", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
