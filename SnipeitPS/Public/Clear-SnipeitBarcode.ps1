<#
.SYNOPSIS
Purges server-cached barcode image files.

.DESCRIPTION
Calls POST /api/v1/settings/purge_barcodes to delete cached PNG barcode files on the Snipe-IT server.
Requires superuser privileges. Uses high confirmation impact.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.PurgeBarcodesResult

.EXAMPLE
Clear-SnipeitBarcode
#>
function Clear-SnipeitBarcode {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High'
    )]
    [OutputType('SnipeitPS.PurgeBarcodesResult')]
    param(
        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ShouldProcess("Snipe-IT server-cached barcode files", "Clear-SnipeitBarcode")) {
            $Parameters = @{
                Route   = "$script:SnipeitApiPrefix/settings/purge_barcodes"
                Method  = 'Post'
                Session = $Session
                Body    = @{}
            }

            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
