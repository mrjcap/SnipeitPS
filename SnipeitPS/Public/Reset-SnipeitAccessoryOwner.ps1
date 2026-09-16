<#
    .SYNOPSIS
    Checkin accessories

    .DESCRIPTION
    Checkin accessories

    .PARAMETER assigned_pivot_id
    This is the assigned_pivot_id of the accessory+user relationships in the accessories_users table
    Use Get-SnipeitAccessoryOwner to find out needed value

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    To get the accessories_users table for specific accessory ID number

    Get-SnipeitAccessoryOwner -id 1

    Then select assigned_pivot_id for the user ID you want to check in

    Reset-SnipeitAccessoryOwner -assigned_pivot_id xxx

#>
function Reset-SnipeitAccessoryOwner() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true)]
        [int]$assigned_pivot_id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
}

    process {
        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/accessories/$assigned_pivot_id/checkin"
            Method = 'Post'
            Session = $Session
            Body   = @{}
        }

        if ($PSCmdlet.ShouldProcess("Accessory pivot ID $assigned_pivot_id", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
