<#
.SYNOPSIS
Gets fields associated with a specific fieldset.

.DESCRIPTION
Retrieves custom fields associated with a fieldset via POST /api/v1/fieldsets/{id}/fields.
If an optional model ID is specified, retrieves the fields populated with the model-specific default values via POST /api/v1/fieldsets/{fieldset}/fields/{model}.

.PARAMETER id
An ID of a specific Fieldset.

.PARAMETER model_id
Optional model ID to retrieve fields populated with model default values.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Get-SnipeitFieldsetField -id 1

.EXAMPLE
Get-SnipeitFieldsetField -id 1 -model_id 5
#>
function Get-SnipeitFieldsetField {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$id,

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateRange(1, [int]::MaxValue)]
        [Alias('model')]
        [int]$model_id,

        [Parameter(Mandatory = $false, Position = 1)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSBoundParameters.ContainsKey('model_id')) {
            $Parameters = @{
                Route       = "$script:SnipeitApiPrefix/fieldsets/{fieldset}/fields/{model}"
                RouteTokens = @{ fieldset = $id; model = $model_id }
                Method      = 'Post'
                Session     = $Session
                Body        = @{}
            }
        } else {
            $Parameters = @{
                Route       = "$script:SnipeitApiPrefix/fieldsets/{id}/fields"
                RouteTokens = @{ id = $id }
                Method      = 'Post'
                Session     = $Session
                Body        = @{}
            }
        }

        $result = Invoke-SnipeitMethod @Parameters
        $result
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
