<#
    .SYNOPSIS
    Updates a user on Snipe-IT system

    .PARAMETER id
    ID number of Snipe-IT user or array of IDs

    .DESCRIPTION
    Updates a user on Snipe-IT system

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
    Replaces the user's complete company membership list (company_ids on the API).
    The legacy company_id alias also replaces memberships. Omit to preserve existing memberships.

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
    Image file name and path for item

    .PARAMETER image_delete
    Remove current image

    .PARAMETER RequestType
    HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    Set-SnipeitUser -id 3 -first_name It -last_name Snipe -username snipeit -activated $false -company_id 1 -location_id 1 -department_id 1
    Updates user with ID 3

#>
function Set-SnipeitUser() {

    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [ValidateLength(1,256)]
        [string]$first_name,

        [string]$last_name,

        [ValidateLength(1,256)]
        [string]$username,

        [string]$jobtitle,

        [string]$email,

        [string]$phone,

        [object]$password,

        [Alias("company_id")]
        [ArgumentCompleter([SnipeitCompanyCompleter])]
        [int[]]$companies,

        [ArgumentCompleter([SnipeitLocationCompleter])]
        [Nullable[System.Int32]]$location_id,

        [ArgumentCompleter([SnipeitDepartmentCompleter])]
        [Nullable[System.Int32]]$department_id,

        [ArgumentCompleter([SnipeitUserCompleter])]
        [Nullable[System.Int32]]$manager_id,

        [int[]]$groups,

        [string]$employee_num,

        [Nullable[bool]]$activated,

        [string]$notes,

        [Nullable[bool]]$ldap_import,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [switch]$image_delete=$false,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )
    begin{
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

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

    }

    process{
        foreach($user_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/users/$user_id"
                Method = $RequestType
                Session = $Session
                Body   = $Values.Clone()
            }

            if ($PSCmdlet.ShouldProcess("User ID $user_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
