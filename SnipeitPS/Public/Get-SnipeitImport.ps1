<#
.SYNOPSIS
Gets uploaded import files from Snipe-IT.

.DESCRIPTION
Retrieves an unpaginated list of uploaded CSV/TSV import files available to the current user (or all imports for a superuser) in Snipe-IT.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Get-SnipeitImport
#>
function Get-SnipeitImport {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $params = @{
            Route   = '/api/v1/imports'
            Method  = 'GET'
            Session = $Session
        }
        Invoke-SnipeitMethod @params
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
