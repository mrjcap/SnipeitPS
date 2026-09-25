<#
    .SYNOPSIS
    Add a new Custom Field to Snipe-IT asset system

    .DESCRIPTION
    Add a new Custom Field to Snipe-IT asset system

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
    For 'CUSTOM REGEX', supply a complete Laravel rule with valid delimited PCRE, such as 'regex:/^\d+$/'.
    The client checks the rule prefix, not PHP regex syntax.

    .PARAMETER field_encrypted
    Whether the field should be encrypted. (This can cause issues if you change it after the field was created.)

    .PARAMETER help_text
    Any additional text you wish to display under the new form field to make it clearer what the values should be.

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
    New-SnipeitCustomField -Name "AntivirusInstalled" -element text -Format "BOOLEAN" -HelpText "Is AntiVirus installed on Asset"
#>

function New-SnipeitCustomField() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true)]
        [string]$name,

        [string]$help_text,

        [parameter(mandatory = $true)]
        [ValidateSet('text','textarea','markdown-textarea','listbox','checkbox','radio','date_picker','datetime_picker')]
        [string]$element ,

        [parameter(mandatory = $true)]
        [ValidateSet('ANY','CUSTOM REGEX','ALPHA','ALPHA-DASH','NUMERIC','ALPHA-NUMERIC','EMAIL','DATE','DATETIME','URL','IP','IPV4','IPV6','MAC','BOOLEAN','PHONE','FAX')]
        [string]$format,

        [string]$field_values,

        [bool]$field_encrypted=$false,

        [bool]$show_in_email=$false,

        [string]$custom_format,

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
        if ($format -eq 'CUSTOM REGEX' -and [string]::IsNullOrWhiteSpace($custom_format)) {
            throw "Please specify regex validation with -custom_format when using -format 'CUSTOM REGEX'"
        }
        if ($format -eq 'CUSTOM REGEX' -and $custom_format -cnotmatch '^regex:\S') {
            throw "custom_format must be a complete Laravel regex rule, such as 'regex:/^\d+$/'."
        }

        $Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
        $Values['format'] = $format.ToUpperInvariant()
        $Values['element'] = $element.ToLowerInvariant()
        if ($format -eq 'CUSTOM REGEX') {
            $Values['format'] = $custom_format
            $Values.Remove('custom_format')
        }

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/fields"
            Method = 'post'
            Session = $Session
            Body   = $Values
        }
    }

    process{
        if ($PSCmdlet.ShouldProcess("Field '$name'", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}

