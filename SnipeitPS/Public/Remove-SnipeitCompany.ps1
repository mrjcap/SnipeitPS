<#
    .SYNOPSIS
    Removes Company from Snipe-IT asset system
    .DESCRIPTION
    Removes Company or multiple Companies from Snipe-IT asset system
    .PARAMETER ID
    Unique ID for company to be removed
    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Remove-SnipeitCompany -ID 44

    .EXAMPLE
    Get-SnipeitCompany | Where-Object {$_.name -like '*some*'} | Remove-SnipeitCompany
#>

function Remove-SnipeitCompany () {
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
        foreach($company_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/companies/$company_id"
                Method = 'Delete'
                Session = $Session
            }

            if ($PSCmdlet.ShouldProcess("Company ID $company_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
