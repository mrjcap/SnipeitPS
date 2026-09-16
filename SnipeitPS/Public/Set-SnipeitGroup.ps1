<#
.SYNOPSIS
Set properties of a Snipe-IT Group

.PARAMETER id
An ID of a specific Group

.PARAMETER name
Name of the Group

.PARAMETER permissions
Hashtable of permissions

.PARAMETER notes
Notes about the Group

.PARAMETER RequestType
HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Set-SnipeitGroup -id 1 -name "Updated Group"

#>

function Set-SnipeitGroup() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [string]$name,

        [hashtable]$permissions,

        [string]$notes,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
    }

    process {
        foreach($group_id in $id) {
            $Parameters = @{
                Api           = "$script:SnipeitApiPrefix/groups/$group_id"
                Method        = $RequestType
                Session = $Session
                Body          = $Values
            }

            if ($PSCmdlet.ShouldProcess("Group ID $group_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
