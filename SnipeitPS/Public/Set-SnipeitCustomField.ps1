<#
    .SYNOPSIS
    Updates a Custom Field on Snipe-IT asset system

    .DESCRIPTION
    Updates a Custom Field on Snipe-IT asset system

    .PARAMETER id
    An ID of a specific resource to update

    .PARAMETER name
    The field's name, which is also the form label

    .PARAMETER element
    Form field type that should be displayed.

    .PARAMETER field_values
    In the case of list boxes, etc, this should be a list of the options available

    .PARAMETER show_in_email
    Whether or not to show the custom field in email notifications

    .PARAMETER format
    How the field should be validated

    .PARAMETER custom_format
    In the case of format 'CUSTOM REGEX', this should be the validation regex for this field

    .PARAMETER field_encrypted
    Whether the field should be encrypted. (This can cause issues if you change it after the field was created.)

    .PARAMETER help_text
    Any additional text you wish to display under the form field to make it clearer what the values should be.

    .PARAMETER RequestType
    HTTP request type to send to Snipe-IT system. Defaults to Put. You could use Patch if needed.

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Set-SnipeitCustomField -id 1 -Name "AntivirusInstalled" -element text -Format "BOOLEAN" -HelpText "Is AntiVirus installed on Asset"
#>

function Set-SnipeitCustomField() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [string]$name,

        [string]$help_text,

        [parameter(Mandatory=$false)]
        [ValidateSet('text','textarea','listbox','checkbox','radio')]
        [string]$element ,

        [ValidateSet('ANY','CUSTOM REGEX','ALPHA','ALPHA-DASH','NUMERIC','ALPHA-NUMERIC','EMAIL','DATE','URL','IP','IPV4','IPV6','MAC','BOOLEAN')]
        [string]$format,

        [string]$field_values,

        [Nullable[bool]]$field_encrypted,

        [Nullable[bool]]$show_in_email,

        [string]$custom_format,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Put",

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
if ($format -eq 'CUSTOM REGEX' -and (-not $custom_format)) {
            throw "Please specify regex validation with -custom_format when using -format 'CUSTOM REGEX'"
        }

        $Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
    }

    process{
        foreach($field_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/fields/$field_id"
                Method = $RequestType
                Session = $Session
                Body   = $Values
            }

            if ($PSCmdlet.ShouldProcess("Field ID $field_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }
    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}

