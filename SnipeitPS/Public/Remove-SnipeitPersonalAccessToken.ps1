<#
.SYNOPSIS
Revokes a personal access token for the authenticated user.

.DESCRIPTION
Revokes an active personal access token by string ID via DELETE /api/v1/account/personal-access-tokens/{tokenId}.
Returns no output on success (HTTP 204 No Content).

.PARAMETER tokenId
Opaque string identifier of the token to revoke.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
None

.EXAMPLE
Remove-SnipeitPersonalAccessToken -tokenId "abc123def456"
#>
function Remove-SnipeitPersonalAccessToken {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High'
    )]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$tokenId,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ShouldProcess("Personal Access Token ID $tokenId", $MyInvocation.MyCommand.Name)) {
            $Parameters = @{
                Route       = "$script:SnipeitApiPrefix/account/personal-access-tokens/{tokenId}"
                RouteTokens = @{ tokenId = $tokenId }
                Method      = 'Delete'
                Session     = $Session
            }

            $null = Invoke-SnipeitMethod @Parameters
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
