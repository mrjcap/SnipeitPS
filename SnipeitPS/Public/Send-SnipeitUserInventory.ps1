<#
.SYNOPSIS
Emails the current inventory of assigned assets to a user.

.DESCRIPTION
Sends an email notification to a user with their currently assigned hardware, licenses,
accessories, and consumables via POST /api/v1/users/{id}/email. Requires user-update permissions.
Supports pipeline input for user ID.

.PARAMETER id
The ID(s) of the user(s) to send the inventory email to.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.UserInventoryEmailResult

.EXAMPLE
Send-SnipeitUserInventory -id 42

.EXAMPLE
10, 20, 30 | Send-SnipeitUserInventory
#>
function Send-SnipeitUserInventory {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium'
    )]
    [OutputType('SnipeitPS.UserInventoryEmailResult')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [int[]]$id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        foreach ($userId in $id) {
            if ($PSCmdlet.ShouldProcess("User ID $userId", "Send-SnipeitUserInventory")) {
                $Parameters = @{
                    Route       = "$script:SnipeitApiPrefix/users/{id}/email"
                    RouteTokens = @{ id = $userId }
                    Method      = 'Post'
                    Session     = $Session
                    Body        = @{}
                }

                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
