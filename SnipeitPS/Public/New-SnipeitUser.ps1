<#
    .SYNOPSIS
    Creates a new user

    .DESCRIPTION
    Creates a new user to Snipe-IT system

    .PARAMETER first_name
    User's first name

    .PARAMETER last_name
    User's last name

    .PARAMETER username
    Username for user

    .PARAMETER activated
    Can user log in to Snipe-IT?

    .PARAMETER password
    Password for user

    .PARAMETER notes
    User Notes

    .PARAMETER jobtitle
    User's job title

    .PARAMETER email
    Email address

    .PARAMETER phone
    Phone number

    .PARAMETER companies
    Company IDs for the user's complete membership list (company_ids on the API).
    The legacy company_id alias also supplies this replacement list, not an additive membership.

    .PARAMETER location_id
    ID number of location

    .PARAMETER department_id
    ID number of department

    .PARAMETER manager_id
    ID number of manager

    .PARAMETER groups
    ID numbers of groups

    .PARAMETER employee_num
    Employee number

    .PARAMETER ldap_import
    Mark user as imported from LDAP

    .PARAMETER image
    User Image file name and path

    .PARAMETER display_name
Display name shown instead of the first and last name.

.PARAMETER address
Street address for the user.

.PARAMETER city
City in the user's address.

.PARAMETER state
State or region in the user's address.

.PARAMETER country
Country code in the user's address.

.PARAMETER zip
Postal code in the user's address.

.PARAMETER locale
Preferred Snipe-IT interface locale.

.PARAMETER mobile
Mobile phone number.

.PARAMETER remote
Whether the user works remotely.

.PARAMETER vip
Whether the user is marked as a VIP.

.PARAMETER autoassign_licenses
Allow licenses to be assigned automatically to this user.

.PARAMETER website
User's website URL.

.PARAMETER gravatar
Email address used for the user's Gravatar image.

.PARAMETER scim_externalid
External identity provider identifier.

.PARAMETER start_date
Employment start date, sent as yyyy-MM-dd.

.PARAMETER end_date
Employment end date, sent as yyyy-MM-dd.

.PARAMETER permissions
Direct permission-name to integer-value map. The server enforces privilege restrictions.

.PARAMETER send_welcome
Send a welcome email when the account is activated and has an email address.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    New-SnipeitUser -first_name It -last_name Snipe -username snipeit -activated $false -company_id 1 -location_id 1 -department_id 1
    Creates a new user who can't login to system

.NOTES
manager_id and location_id accept explicit null. Unbound optional fields are omitted from the request.
#>
function New-SnipeitUser() {

    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true)]
        [string]$first_name,

        [string]$last_name,

        [parameter(mandatory = $true)]
        [string]$username,

        [object]$password,

        [bool]$activated = $false,

        [string]$notes,

        [string]$jobtitle,

        [string]$email,

        [string]$phone,

        [Alias("company_id")]
        [ArgumentCompleter([SnipeitCompanyCompleter])]
        [int[]]$companies,

        [ArgumentCompleter([SnipeitLocationCompleter])]
        [Nullable[int]]$location_id,

        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitDepartmentCompleter])]
        [int]$department_id,

        [ArgumentCompleter([SnipeitUserCompleter])]
        [Nullable[int]]$manager_id,

        [int[]]$groups,

        [string]$employee_num,

        [bool]$ldap_import = $false,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [string]$display_name,

        [string]$address,

        [string]$city,

        [string]$state,

        [string]$country,

        [string]$zip,

        [string]$locale,

        [string]$mobile,

        [Nullable[bool]]$remote,

        [Nullable[bool]]$vip,

        [Nullable[bool]]$autoassign_licenses,

        [string]$website,

        [string]$gravatar,

        [string]$scim_externalid,

        [Nullable[datetime]]$start_date,

        [Nullable[datetime]]$end_date,

        [hashtable]$permissions,

        [Nullable[bool]]$send_welcome
    )
    begin {
        foreach ($field in @('manager_id', 'location_id')) {
            if ($null -ne $PSBoundParameters[$field] -and $PSBoundParameters[$field] -lt 1) {
                throw [System.ArgumentOutOfRangeException]::new($field, 'Use a positive ID or null.')
            }
        }
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        foreach ($field in @('start_date', 'end_date')) {
            if ($Values[$field]) {
                $Values[$field] = $Values[$field].ToString('yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)
            }
        }

        if ($PSBoundParameters.ContainsKey('companies')) {
            $Values['company_ids'] = $companies
            $Values.Remove('companies')
        }

        if ($PSBoundParameters.ContainsKey('password')) {
            if ($password -is [System.Security.SecureString]) {
                $passwordPlain = (New-Object PSCredential "user", $password).GetNetworkCredential().Password
            } elseif ($password -is [string]) {
                $passwordPlain = $password
            } else {
                throw "Password must be a [string] or [SecureString]"
            }
            $Values['password'] = $passwordPlain
            $Values['password_confirmation'] = $passwordPlain
        }

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/users"
            Method = 'post'
            Session = $Session
            Body   = $Values
            ImageFieldName = 'avatar'
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("User '$username'", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

     end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
