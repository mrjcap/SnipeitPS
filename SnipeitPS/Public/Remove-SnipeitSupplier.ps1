<#
    .SYNOPSIS
    Removes supplier from Snipe-IT asset system
    .DESCRIPTION
    Removes supplier or multiple suppliers from Snipe-IT asset system
    .PARAMETER ID
    Unique ID for supplier to be removed
    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Remove-SnipeitSupplier -ID 44

    .EXAMPLE
    Get-SnipeitSupplier | Where-object {$_.name -like '*something*'} | Remove-SnipeitSupplier
#>

function Remove-SnipeitSupplier () {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "High"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
}

    process {
        foreach($supplier_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/suppliers/$supplier_id"
                Method = 'Delete'
                Session = $Session
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
