<#
.SYNOPSIS
Replaces old SnipeitPS commands with new ones

.DESCRIPTION
Replaces old SnipeitPS commands with new ones

.PARAMETER String
Input string

.OUTPUTS

System.String


.EXAMPLE
Get-Content [your-script.ps1] | Update-SnipeitAlias | Out-File [new-script-name.ps1]

Replaces old command from file "your-script.ps1" and creates new script "new-script-name.ps1"
After testing new file you can replace old file with new.

#>
function Update-SnipeitAlias() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]

        [string[]]
        $String
    )
    begin{
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        Write-Verbose "Replacing old Snipe-IT functions with new ones."
        $SnipeitAliases = @{
            'Get-Asset'             = 'Get-SnipeitAsset'
            'Get-AssetMaintenance'  = 'Get-SnipeitAssetMaintenance'
            'Get-Category'          = 'Get-SnipeitCategory'
            'Get-Company'           = 'Get-SnipeitCompany'
            'Get-Component'         = 'Get-SnipeitComponent'
            'Get-CustomField'       = 'Get-SnipeitCustomField'
            'Get-Department'        = 'Get-SnipeitDepartment'
            'Get-Fieldset'          = 'Get-SnipeitFieldset'
            'Get-Manufacturer'      = 'Get-SnipeitManufacturer'
            'Get-Model'             = 'Get-SnipeitModel'
            'Get-Status'            = 'Get-SnipeitStatus'
            'Get-Supplier'          = 'Get-SnipeitSupplier'
            'Get-User'              = 'Get-SnipeitUser'
            'New-Asset'             = 'New-SnipeitAsset'
            'New-AssetMaintenance'  = 'New-SnipeitAssetMaintenance'
            'New-Category'          = 'New-SnipeitCategory'
            'New-Component'         = 'New-SnipeitComponent'
            'New-CustomField'       = 'New-SnipeitCustomField'
            'New-Department'        = 'New-SnipeitDepartment'
            'New-License'           = 'New-SnipeitLicense'
            'Set-License'           = 'Set-SnipeitLicense'
            'New-Location'          = 'New-SnipeitLocation'
            'New-Manufacturer'      = 'New-SnipeitManufacturer'
            'New-Model'             = 'New-SnipeitModel'
            'New-User'              = 'New-SnipeitUser'
            'Set-Asset'             = 'Set-SnipeitAsset'
            'Set-AssetOwner'        = 'Set-SnipeitAssetOwner'
            'Set-Component'         = 'Set-SnipeitComponent'
            'Set-Model'             = 'Set-SnipeitModel'
            'Set-Info'              = 'Set-SnipeitInfo'
            'Set-User'              = 'Set-SnipeitUser'
            'New-Accessory'         = 'New-SnipeitAccessory'
            'Set-Accessory'         = 'Set-SnipeitAccessory'
            'Get-Accessory'         = 'Get-SnipeitAccessory'
            'Get-License'           = 'Get-SnipeitLicense'
            'Remove-Asset'          = 'Remove-SnipeitAsset'
            'Remove-User'           = 'Remove-SnipeitUser'
        }
    }
    process {
        if ($PSCmdlet.ShouldProcess("Script content", $MyInvocation.MyCommand.Name)) {
            ForEach ($st in $String) {
                $result = $st
                ForEach ($key in $SnipeitAliases.Keys ) {
                    #Write-Verbose "Replacing $key with $($SnipeitAliases[$key])"
                    $result = $result -replace [regex]::Escape($key), $SnipeitAliases[$key]
                }
                $result
            }
        }
    }
    end{
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
        Write-Verbose "..replacing done"
    }



}
