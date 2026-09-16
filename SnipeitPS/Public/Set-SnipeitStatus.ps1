<#
.SYNOPSIS
Sets Snipe-IT Status Labels

.PARAMETER id
An ID of a specific Status Label

.PARAMETER name
Name of the status label

.PARAMETER type
Type of status label. Valid values are deployable, undeployable, pending, and archived.
Omitted type, color, and navigation/default flags are read from the current label before updating.

.PARAMETER notes
Notes about the status label

.PARAMETER color
Hex code showing what color the status label should be on the pie chart in the dashboard

.PARAMETER show_in_nav
1 or 0 - determine whether the status label should show in the left-side nav of the web GUI

.PARAMETER default_label
1 or 0 - determine whether it should be bubbled up to the top of the list of available statuses

.PARAMETER RequestType
HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Set-SnipeitStatus -id 1 -name "Ready to Deploy" -type deployable

.EXAMPLE
Set-SnipeitStatus -id 3 -name 'Waiting for arrival' -type pending

#>

function Set-SnipeitStatus() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [string]$name,

        [parameter(Mandatory=$false)]
        [ValidateSet('deployable','undeployable','pending','archived')]
        [string]$type,

        [string]$notes,

        [string]$color,

        [Nullable[bool]]$show_in_nav,

        [Nullable[bool]]$default_label,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
    }

    process {
        foreach($status_id in $id) {
            $Parameters = @{
                Api           = "$script:SnipeitApiPrefix/statuslabels/$status_id"
                Method        = $RequestType
                Session = $Session
                Body          = $Values.Clone()
            }

            if ($PSCmdlet.ShouldProcess("Status ID $status_id", $MyInvocation.MyCommand.Name)) {
                $preservedFields = @('type', 'color', 'show_in_nav', 'default_label')
                $missingFields = @($preservedFields | Where-Object { -not $Values.ContainsKey($_) })
                if ($missingFields.Count -gt 0) {
                    $current = Invoke-SnipeitMethod -Api $Parameters.Api -Method GET -Session $Session
                    if ($null -eq $current) {
                        Write-Error "Cannot preserve settings for status label $status_id because its lookup failed."
                        continue
                    }
                    $incomplete = $false
                    foreach ($field in $missingFields) {
                        if (-not $current.PSObject.Properties[$field]) {
                            Write-Error "Status label $status_id response is missing '$field'; update cancelled."
                            $incomplete = $true
                            break
                        }
                        $Parameters.Body[$field] = $current.$field
                    }
                    if ($incomplete) { continue }
                    if ($Parameters.Body['type'] -notin @('deployable', 'undeployable', 'pending', 'archived')) {
                        Write-Error "Status label $status_id has an unrecognized type; update cancelled."
                        continue
                    }
                }
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
