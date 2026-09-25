<#
.SYNOPSIS
Creates a new personal access token for the authenticated user.

.DESCRIPTION
Mints a new personal access token via POST /api/v1/account/personal-access-tokens.
The generated secret is returned exactly once and converted immediately into a SecureString property
(TokenSecret) on the emitted SnipeitPS.PersonalAccessToken object.
Default formatting suppresses the secret.

.PARAMETER name
Friendly name describing the token's purpose. Defaults to 'Auth Token'.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.PersonalAccessToken

.EXAMPLE
$newToken = New-SnipeitPersonalAccessToken -name "CI Deployment Token"
#>
function New-SnipeitPersonalAccessToken {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High'
    )]
    [OutputType('SnipeitPS.PersonalAccessToken')]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Newly generated API token secret returned from server is immediately encapsulated into a SecureString for safe in-memory handling')]
    param(
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$name = 'Auth Token',

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        if ($PSCmdlet.ShouldProcess("Personal Access Token '$name'", $MyInvocation.MyCommand.Name)) {
            $body = @{
                name = $name
            }

            $Parameters = @{
                Route   = "$script:SnipeitApiPrefix/account/personal-access-tokens"
                Method  = 'Post'
                Session = $Session
                Body    = $body
            }

            $rawResult = Invoke-SnipeitMethod @Parameters

            if ($null -ne $rawResult) {
                $rawSecret = if ($rawResult -is [System.Collections.IDictionary]) { $rawResult['token'] } else { $rawResult.token }
                $tokenId = if ($rawResult -is [System.Collections.IDictionary]) { $rawResult['id'] } else { $rawResult.id }
                $tokenName = if ($rawResult -is [System.Collections.IDictionary]) { $rawResult['name'] } else { $rawResult.name }

                $secureSecret = if ($rawSecret) {
                    ConvertTo-SecureString $rawSecret -AsPlainText -Force
                } else {
                    $null
                }

                $tokenObj = [PSCustomObject]@{
                    id          = $tokenId
                    name        = $tokenName
                    TokenSecret = $secureSecret
                }
                $tokenObj.PSObject.TypeNames.Insert(0, 'SnipeitPS.PersonalAccessToken')
                $tokenObj
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
