<#
    .SYNOPSIS
    Creates a department

    .DESCRIPTION
    Creates a new department on Snipe-IT system

    .PARAMETER name
    Department Name

    .PARAMETER company_id
    ID number of company

    .PARAMETER location_id
    ID number of location

    .PARAMETER manager_id
    ID number of manager

    .PARAMETER notes
    Notes about the department

    .PARAMETER image
    Department Image filename and path

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    New-SnipeitDepartment -name "Department1" -company_id 1 -location_id 1 -manager_id 3

#>

function New-SnipeitDepartment() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true)]
        [string]$name,

        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitCompanyCompleter])]
        [int]$company_id,

        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitLocationCompleter])]
        [int]$location_id,

        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitUserCompleter])]
        [int]$manager_id,

        [string]$notes,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/departments"
            Method = 'POST'
            Session = $Session
            Body   = $Values
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("Department '$name'", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}

