<#
    .SYNOPSIS
    Returns specific Snipe-IT custom field or a list of all custom fields

    .PARAMETER id
    An ID of a specific field

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Get-SnipeitCustomField
    Get all custom fields

    .EXAMPLE
    Get-SnipeitCustomField -id 1
    Get custom field with ID 1


#>

function Get-SnipeitCustomField() {
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
            $route = "$script:SnipeitApiPrefix/fields/{id}"
            $pathParams['id'] = $id
        } else {
            $route = "$script:SnipeitApiPrefix/fields"
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
