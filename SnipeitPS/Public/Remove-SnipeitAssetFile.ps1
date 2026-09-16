<#
.SYNOPSIS
Removes a file from an asset in Snipe-IT

.PARAMETER id
ID of the asset

.PARAMETER file_id
ID of the file to be removed

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Remove-SnipeitAssetFile -id 1 -file_id 10

#>

function Remove-SnipeitAssetFile () {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "High"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true)]
        [int]$id,

        [parameter(mandatory = $true)]
        [int]$file_id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin{
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Parameters = @{
            Api    = "$script:SnipeitApiPrefix/hardware/$id/files/$file_id/delete"
            Method = 'Delete'
            Session = $Session
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("Asset ID $id file ID $file_id", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
