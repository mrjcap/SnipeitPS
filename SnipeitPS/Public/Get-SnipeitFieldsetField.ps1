<#
.SYNOPSIS
Gets fields associated with a specific fieldset

.PARAMETER id
An ID of a specific Fieldset

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitFieldsetField -id 1

#>

function Get-SnipeitFieldsetField() {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(mandatory = $true)]
        [int]$id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
}

    process {
        $Parameters = @{
            Route         = "$script:SnipeitApiPrefix/fieldsets/{id}/fields"
            PathParameter = @{ id = $id }
            Method        = 'Post'
            Session = $Session
            Body          = @{}
        }

        $result = Invoke-SnipeitMethod @Parameters
        $result
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
