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
    Retained for compatibility. Custom regex updates are rejected because the supported API does not accept them.
    Omit format and custom_format when updating other properties of an existing regex field.

    .PARAMETER field_encrypted
    Whether the field should be encrypted. (This can cause issues if you change it after the field was created.)

    .PARAMETER help_text
    Any additional text you wish to display under the form field to make it clearer what the values should be.

    .PARAMETER RequestType
    HTTP request type to send to Snipe-IT system. Defaults to Put. You could use Patch if needed.

    .PARAMETER is_unique
Require unique values across assets using this field.

.PARAMETER display_in_user_view
Show the field in the user's asset view.

.PARAMETER auto_add_to_fieldsets
Automatically add the field to newly created fieldsets.

.PARAMETER show_in_listview
Show the field in asset list views.

.PARAMETER display_checkout
Show the field during checkout.

.PARAMETER display_checkin
Show the field during checkin.

.PARAMETER display_audit
Show the field during an audit.

.PARAMETER show_in_requestable_list
Show the field in the requestable asset list.

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
        [ValidateSet('text','textarea','markdown-textarea','listbox','checkbox','radio','date_picker','datetime_picker')]
        [string]$element ,

        [ValidateSet('ANY','CUSTOM REGEX','ALPHA','ALPHA-DASH','NUMERIC','ALPHA-NUMERIC','EMAIL','DATE','DATETIME','URL','IP','IPV4','IPV6','MAC','BOOLEAN','PHONE','FAX')]
        [string]$format,

        [string]$field_values,

        [Nullable[bool]]$field_encrypted,

        [Nullable[bool]]$show_in_email,

        [string]$custom_format,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Put",

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [Nullable[bool]]$is_unique,

        [Nullable[bool]]$display_in_user_view,

        [Nullable[bool]]$auto_add_to_fieldsets,

        [Nullable[bool]]$show_in_listview,

        [Nullable[bool]]$display_checkout,

        [Nullable[bool]]$display_checkin,

        [Nullable[bool]]$display_audit,

        [Nullable[bool]]$show_in_requestable_list
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        if ($format -eq 'CUSTOM REGEX' -and (-not $custom_format)) {
            throw "Please specify regex validation with -custom_format when using -format 'CUSTOM REGEX'"
        }
        if ($PSBoundParameters.ContainsKey('custom_format')) {
            throw [System.NotSupportedException]::new('The supported Snipe-IT API does not support custom regex updates. Omit format and custom_format to update other properties.')
        }

        $Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
        if ($Values.ContainsKey('format')) { $Values['format'] = $format.ToUpperInvariant() }
        if ($Values.ContainsKey('element')) { $Values['element'] = $element.ToLowerInvariant() }
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

