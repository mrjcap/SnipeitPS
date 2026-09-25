<#
.SYNOPSIS
Updates an existing predefined kit in Snipe-IT.

.DESCRIPTION
Updates the name of an existing predefined kit record in Snipe-IT.

.PARAMETER id
The ID of the kit to update.

.PARAMETER name
The updated name for the kit (maximum 255 characters).

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Set-SnipeitKit -id 5 -name 'Updated Engineering Kit'
#>
function Set-SnipeitKit {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [int]$id,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateLength(1, 255)]
        [string]$name,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ShouldProcess("Kit ID $id", "Update kit")) {
            $body = @{
                name = $name
            }
            $params = @{
                Route   = "/api/v1/kits/$id"
                Method  = 'PUT'
                Body    = $body
                Session = $Session
            }
            Invoke-SnipeitMethod @params
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
