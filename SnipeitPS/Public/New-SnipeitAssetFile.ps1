<#
    .SYNOPSIS
    Add a file to an asset in Snipe-IT

    .DESCRIPTION
    Add a file to an asset in Snipe-IT

    .PARAMETER id
    ID of the asset to add the file to

    .PARAMETER file
    Path to the file to upload

    .PARAMETER notes
    Optional notes for the file

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    New-SnipeitAssetFile -id 1 -file "C:\path\to\file.pdf"
#>

function New-SnipeitAssetFile() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true)]
        [int]$id,

        [parameter(mandatory = $true)]
        [ValidateScript({Test-Path $_})]
        [string]$file,

        [string]$notes,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters `
                                       -BoundParameters $PSBoundParameters `
                                       -DefaultExcludeParameter 'id', 'url', 'apiKey', 'Debug', 'Verbose'
    }

    process {
        if ($PSCmdlet.ShouldProcess("Asset ID $id", $MyInvocation.MyCommand.Name)) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/hardware/$id/files"
                Method = 'Post'
                Session = $Session
                Body   = $Values
            }
            Invoke-SnipeitMethod @Parameters
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
