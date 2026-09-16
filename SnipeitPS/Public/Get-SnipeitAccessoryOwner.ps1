<#
    .SYNOPSIS
    Gets a list of checked out accessories
    .DESCRIPTION
    Gets a list of checked out accessories

    .PARAMETER id
    Unique ID for accessory to list

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Get-SnipeitAccessoryOwner -id 1
#>
function Get-SnipeitAccessoryOwner() {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [int]$id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
}
    process {
        $Parameters = @{
            Route         = "$script:SnipeitApiPrefix/accessories/{id}/checkedout"
            PathParameter = @{ id = $id }
            Method        = 'GET'
            Session = $Session
        }
        $result = Invoke-SnipeitMethod @Parameters
        $result
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
