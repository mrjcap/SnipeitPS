<#
    .SYNOPSIS
    Create a new status label in Snipe-IT

    .DESCRIPTION
    Create a new status label in Snipe-IT

    .PARAMETER name
    Name of the status label

    .PARAMETER type
    Type of the status label. Can be deployable, undeployable, pending or archived

    .PARAMETER notes
    Optional notes for the status label

    .PARAMETER color
    Hex color code for the status label

    .PARAMETER show_in_nav
    Whether to show in the left-side nav of the web GUI

    .PARAMETER default_label
    Whether it should be the default label

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    New-SnipeitStatus -name "Ready to Deploy" -type deployable
#>

function New-SnipeitStatus() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true)]
        [string]$name,

        [parameter(mandatory = $true)]
        [ValidateSet('deployable','undeployable','pending','archived')]
        [string]$type,

        [string]$notes,

        [string]$color,

        [Nullable[bool]]$show_in_nav,

        [Nullable[bool]]$default_label,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/statuslabels"
            Method = 'Post'
            Session = $Session
            Body   = $Values
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("Status '$name'", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
