<#
.SYNOPSIS
Synchronizes users from LDAP into Snipe-IT.

.DESCRIPTION
Triggers synchronous LDAP user import via POST /api/v1/users/ldapsync with optional
location_id filtering. Requires user-update permissions.

.PARAMETER location_id
Optional location ID to filter which LDAP users to import or sync.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS
SnipeitPS.LdapSyncResult

.EXAMPLE
Sync-SnipeitLdapUser

.EXAMPLE
Sync-SnipeitLdapUser -location_id 5
#>
function Sync-SnipeitLdapUser {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium'
    )]
    [OutputType('SnipeitPS.LdapSyncResult')]
    param(
        [Parameter(Mandatory = $false)]
        [int]$location_id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
    }

    process {
        $target = if ($PSBoundParameters.ContainsKey('location_id')) {
            "LDAP users for location ID $location_id"
        } else {
            "All LDAP users"
        }

        if ($PSCmdlet.ShouldProcess($target, "Sync-SnipeitLdapUser")) {
            $body = @{}
            if ($PSBoundParameters.ContainsKey('location_id')) {
                $body['location_id'] = $location_id
            }

            $Parameters = @{
                Route            = "$script:SnipeitApiPrefix/users/ldapsync"
                Method           = 'Post'
                Session          = $Session
                Body             = $body
                PreserveResponse = $true
            }

            $raw = Invoke-SnipeitMethod @Parameters
            $statusVal = if ($raw -is [System.Collections.IDictionary]) { $raw['status'] } else { $raw.status }
            $messagesVal = if ($raw -is [System.Collections.IDictionary]) { $raw['messages'] } else { $raw.messages }
            $payloadVal = if ($raw -is [System.Collections.IDictionary]) { $raw['payload'] } else { $raw.payload }

            [PSCustomObject]@{
                PSTypeName = 'SnipeitPS.LdapSyncResult'
                status     = $statusVal
                messages   = $messagesVal
                payload    = $payloadVal
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
