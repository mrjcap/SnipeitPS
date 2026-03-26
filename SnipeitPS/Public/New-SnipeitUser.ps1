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

    .PARAMETER company_id
    ID number of company the user belongs to

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

    .PARAMETER url
    Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipe-IT system.

    .PARAMETER apiKey
    Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipe-IT.

    .EXAMPLE
    New-SnipeitUser -first_name It -last_name Snipe -username snipeit -activated $false -company_id 1 -location_id 1 -department_id 1
    Creates a new user who can't login to system

#>
function New-SnipeitUser() {

    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]

    Param(
        [parameter(mandatory = $true)]
        [string]$first_name,

        [parameter(mandatory = $true)]
        [string]$last_name,

        [parameter(mandatory = $true)]
        [string]$username,

        [string]$password,

        [bool]$activated = $false,

        [string]$notes,

        [string]$jobtitle,

        [string]$email,

        [string]$phone,

        [int]$company_id,

        [int]$location_id,

        [int]$department_id,

        [int]$manager_id,

        [int[]]$groups,

        [string]$employee_num,

        [bool]$ldap_import = $false,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [parameter(mandatory = $false)]
        [string]$url,

        [parameter(mandatory = $false)]
        [string]$apiKey
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

        $Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters

        if ($password ) {
                $Values['password_confirmation'] = $password
        }

        $Parameters = @{
            Api    = "/api/v1/users"
            Method = 'post'
            Body   = $Values
        }

        if ($PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Write-Warning "-apiKey parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyApiKey -apiKey $apikey
        }

        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url) {
            Write-Warning "-url parameter is deprecated, please use Connect-SnipeitPS instead."
            Set-SnipeitPSLegacyUrl -url $url
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("ShouldProcess?")) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

     end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
        # reset legacy sessions
        if ($PSBoundParameters.ContainsKey('url') -and '' -ne [string]$url -or $PSBoundParameters.ContainsKey('apiKey') -and '' -ne [string]$apiKey) {
            Reset-SnipeitPSLegacyApi
        }
    }
}
