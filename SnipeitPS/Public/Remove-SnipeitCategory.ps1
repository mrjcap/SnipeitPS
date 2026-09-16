<#
    .SYNOPSIS
    Removes category from Snipe-IT asset system
    .DESCRIPTION
    Removes category or multiple categories from Snipe-IT asset system
    .PARAMETER ID
    Unique ID for category to be removed
    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Remove-SnipeitCategory -ID 44

    .EXAMPLE
    Get-SnipeitCategory -search something | Remove-SnipeitCategory
#>

function Remove-SnipeitCategory () {
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
        foreach($category_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/categories/$category_id"
                Method = 'Delete'
                Session = $Session
            }

            if ($PSCmdlet.ShouldProcess("Category ID $category_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
