<#
.SYNOPSIS
Removes a file from a model in Snipe-IT

.PARAMETER id
ID of the model

.PARAMETER file_id
ID of the file to be removed

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Remove-SnipeitModelFile -id 1 -file_id 10

#>

function Remove-SnipeitModelFile () {
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
            Api    = "$script:SnipeitApiPrefix/models/$id/files/$file_id/delete"
            Method = 'Delete'
            Session = $Session
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("Model ID $id file ID $file_id", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
