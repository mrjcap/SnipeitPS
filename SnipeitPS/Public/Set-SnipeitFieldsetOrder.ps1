<#
.SYNOPSIS
Reorders custom fields within a fieldset.

.DESCRIPTION
Updates the display order of custom fields in a fieldset via POST /api/v1/fields/fieldsets/{id}/order.
The item parameter must contain the complete ordered array of all field IDs currently associated with the fieldset.
Duplicate field IDs are rejected immediately. Inside ShouldProcess, current fieldset membership is verified;
if any existing field ID is omitted or any unknown field ID is present, the operation fails before sending the reorder request.

.PARAMETER id
Unique ID of the fieldset to reorder.

.PARAMETER item
Complete ordered array of field IDs belonging to the fieldset.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Set-SnipeitFieldsetOrder -id 3 -item 12, 10, 15
#>
function Set-SnipeitFieldsetOrder {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium'
    )]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [Alias('fieldset_id')]
        [int]$id,

        [Parameter(Mandatory = $true, Position = 1)]
        [int[]]$item,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $distinct = @($item | Select-Object -Unique)
        if ($distinct.Count -ne $item.Count) {
            throw [System.ArgumentException]::new("The 'item' array contains duplicate field IDs.", 'item')
        }

        if ($PSCmdlet.ShouldProcess("Fieldset ID $id", $MyInvocation.MyCommand.Name)) {
            $currentFields = @(Get-SnipeitFieldsetField -id $id -Session $Session -ErrorAction Stop)
            $currentFieldIds = [System.Collections.Generic.HashSet[int]]::new([int[]]($currentFields | ForEach-Object { $_.id }))
            $passedFieldIds = [System.Collections.Generic.HashSet[int]]::new([int[]]$item)

            $missingIds = [System.Collections.Generic.List[int]]::new()
            foreach ($cfId in $currentFieldIds) {
                if (-not $passedFieldIds.Contains($cfId)) {
                    $missingIds.Add($cfId)
                }
            }

            $extraIds = [System.Collections.Generic.List[int]]::new()
            foreach ($passedId in $passedFieldIds) {
                if (-not $currentFieldIds.Contains($passedId)) {
                    $extraIds.Add($passedId)
                }
            }

            if ($missingIds.Count -gt 0 -or $extraIds.Count -gt 0) {
                $msg = "Field IDs passed do not match current fieldset membership for fieldset $id."
                if ($missingIds.Count -gt 0) { $msg += " Missing field IDs: $($missingIds -join ', ')." }
                if ($extraIds.Count -gt 0) { $msg += " Extra field IDs: $($extraIds -join ', ')." }
                throw [System.InvalidOperationException]::new($msg)
            }

            $Parameters = @{
                Route            = "$script:SnipeitApiPrefix/fields/fieldsets/{id}/order"
                RouteTokens      = @{ id = $id }
                Method           = 'Post'
                Session          = $Session
                Body             = @{ item = $item }
                PreserveResponse = $true
            }

            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
