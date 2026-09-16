<#
.SYNOPSIS
Create a new Snipe-IT Category

.PARAMETER name
Name of new category to be created

.PARAMETER category_type
Type of new category to be created (asset, accessory, consumable, component, license)

.PARAMETER eula_text
This allows you to customize your EULAs for specific types of assets

.PARAMETER use_default_eula
If switch is present, use the primary default EULA

.PARAMETER require_acceptance
If switch is present, require users to confirm acceptance of assets in this category

.PARAMETER checkin_email
If switch is present, send email to user on checkin/checkout

.PARAMETER image
Category image filename and path

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
New-SnipeitCategory -name "Laptops" -category_type asset
#>

function New-SnipeitCategory() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true)]
        [string]$name,

        [parameter(mandatory = $true)]
        [ValidateSet("asset", "accessory", "consumable", "component", "license")]
        [string]$category_type,

        [string]$eula_text,

        [switch]$use_default_eula,

        [switch]$require_acceptance,

        [switch]$checkin_email,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
if ($eula_text -and $use_default_eula) {
            throw "Don't use -use_default_eula if -eula_text is set"
        }

        $Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
    }

    process {

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/categories"
            Method = 'POST'
            Session = $Session
            Body   = $Values
        }

        if ($PSCmdlet.ShouldProcess("Category '$name'", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
