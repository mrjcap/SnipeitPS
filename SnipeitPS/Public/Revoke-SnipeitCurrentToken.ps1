<#
.SYNOPSIS
Revokes the Passport access token authenticating this request.
.DESCRIPTION
Posts an empty body to /api/v1/logout with explicit high-impact confirmation.
The server revokes the current access token and its associated refresh tokens.
Success is HTTP 204 with no output. An authentication flow without a Passport
token can return an empty HTTP 401 error. This does not revoke an OIDC provider
session, disconnect the module, or revoke any other user's tokens. Revocation
is never performed automatically by disconnecting a local session.
.PARAMETER Session
Optional custom SnipeitSession instance whose bearer token should be revoked.
.EXAMPLE
Revoke-SnipeitCurrentToken -WhatIf
#>
function Revoke-SnipeitCurrentToken {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([PSCustomObject])]
    param([SnipeitSession]$Session)

    if ($PSCmdlet.ShouldProcess('Current bearer token', 'Revoke access token and associated refresh tokens')) {
        Invoke-SnipeitMethod -Route "$script:SnipeitApiPrefix/logout" -Method Post -Body @{} -Session $Session
    }
}
