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

    .PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

    System.Management.Automation.PSCustomObject


    .EXAMPLE
    New-SnipeitUser -first_name It -last_name Snipe -username snipeit -activated $false -company_id 1 -location_id 1 -department_id 1
    Creates a new user who can't login to system

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

        [parameter(mandatory = $true)]
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

        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitLocationCompleter])]
        [int]$location_id,

        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitDepartmentCompleter])]
        [int]$department_id,

        [ValidateRange(1, [int]::MaxValue)]
        [ArgumentCompleter([SnipeitUserCompleter])]
        [int]$manager_id,

        [int[]]$groups,

        [string]$employee_num,

        [bool]$ldap_import = $false,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )
    begin {
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

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/users"
            Method = 'post'
            Session = $Session
            Body   = $Values
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
