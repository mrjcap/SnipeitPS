<#
    .SYNOPSIS
    Updates Model on Snipe-IT asset system

    .DESCRIPTION
    Updates Model on Snipe-IT asset system

    .PARAMETER id
    ID number of the Asset Model or array of IDs

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

    .PARAMETER custom_fieldset_id
    Fieldset ID that the asset uses (Custom fields). Pass $null to remove the fieldset.

    .PARAMETER image
    Image file name and path for item

    .PARAMETER image_delete
    Remove current image

    .PARAMETER RequestType
    HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

    .PARAMETER depreciation_id
ID of the depreciation schedule. Pass $null to clear it.

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
    Set-SnipeitModel -id 1 -name "DL380" -manufacturer_id 2 -fieldset_id 2 -category_id 1
#>

function Set-SnipeitModel() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [ValidateLength(1, 255)]
        [string]$name,

        [string]$model_number,

        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitCategoryCompleter])]
        [int]$category_id,

        [ArgumentCompleter([SnipeitManufacturerCompleter])]
        [Nullable[int]]$manufacturer_id,

        [Nullable[System.Int32]]$eol,

        [Alias("fieldset_id")]
        [Nullable[System.Int32]]$custom_fieldset_id,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [switch]$image_delete=$false,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

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
            throw [System.ArgumentOutOfRangeException]::new('manufacturer_id', 'Use a positive ID or null to clear the manufacturer.')
        }
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
        if ($Values.ContainsKey('custom_fieldset_id')) {
            $Values['fieldset_id'] = $Values['custom_fieldset_id']
            $Values.Remove('custom_fieldset_id')
        }
    }
    process {
        foreach ($model_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/models/$model_id"
                Method = $RequestType
                Session = $Session
                Body   = $Values.Clone()
            }

            if ($PSCmdlet.ShouldProcess("Model ID $model_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
