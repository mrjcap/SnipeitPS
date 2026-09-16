<#
.SYNOPSIS
Returns a fieldset or list of Snipe-IT Fieldsets

.PARAMETER id
An ID of a specific fieldset

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitFieldset
Get all fieldsets

.EXAMPLE
Get-SnipeitFieldset | Where-Object {$_.name -eq "Windows" }
Gets fieldset by name

#>

function Get-SnipeitFieldset() {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param(
        [int]$id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
}
    process {
        $pathParams = @{}
        if ($PSBoundParameters.ContainsKey('id')) {
            $route = "$script:SnipeitApiPrefix/fieldsets/{id}"
            $pathParams['id'] = $id
        } else {
            $route = "$script:SnipeitApiPrefix/fieldsets"
        }

        $Parameters = @{
            Route         = $route
            PathParameter = $pathParams
            Method        = 'Get'
            Session = $Session
        }

        $result = Invoke-SnipeitMethod @Parameters
        $result
    }
    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
