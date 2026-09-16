<#
.SYNOPSIS
Clears the in-memory cache for SnipeitPS.

.DESCRIPTION
Flushes cached entity lookups (models, categories, statuses, locations, companies, suppliers, and departments) used by argument completers and queries.

.OUTPUTS

None


.EXAMPLE
Clear-SnipeitCache
#>
function Clear-SnipeitCache {
    [CmdletBinding()]
    [OutputType([void])]
    param()

    process {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Clearing in-memory Snipe-IT cache"
        [SnipeitCache]::Clear()
    }
}
